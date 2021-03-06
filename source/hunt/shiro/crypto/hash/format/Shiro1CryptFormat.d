/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
module hunt.shiro.crypto.hash.format.Shiro1CryptFormat;

import hunt.shiro.crypto.hash.format.ModularCryptFormat;
import hunt.shiro.crypto.hash.format.ParsableHashFormat;

import hunt.shiro.codec.Base64;
import hunt.shiro.crypto.hash.Hash;
import hunt.shiro.crypto.hash.SimpleHash;
import hunt.shiro.util.ByteSource;
import hunt.shiro.util.SimpleByteSource;
// import hunt.shiro.util.StringUtils;

import hunt.Exceptions;
import hunt.util.StringBuilder;

import std.conv;
import std.string;

/**
 * The {@code Shiro1CryptFormat} is a fully reversible
 * <a href="http://packages.python.org/passlib/modular_crypt_format.html">Modular Crypt Format</a> (MCF).  Because it is
 * fully reversible (i.e. Hash -&gt; string, string -&gt; Hash), it does NOT use the traditional MCF encoding alphabet
 * (the traditional MCF encoding, aka H64, is bit-destructive and cannot be reversed).  Instead, it uses fully
 * reversible Base64 encoding for the Hash digest and any salt value.
 * <h2>Format</h2>
 * <p>Hash instances formatted with this implementation will result in a string with the following dollar-sign ($)
 * delimited format:</p>
 * <pre>
 * <b>$</b>mcfFormatId!(b)$</b>algorithmName!(b)$</b>iterationCount!(b)$</b>base64EncodedSalt!(b)$</b>base64EncodedDigest
 * </pre>
 * <p>Each token is defined as follows:</p>
 * <table>
 *     <tr>
 *         <th>Position</th>
 *         <th>Token</th>
 *         <th>Description</th>
 *         <th>Required?</th>
 *     </tr>
 *     <tr>
 *         <td>1</td>
 *         <td>{@code mcfFormatId}</td>
 *         <td>The Modular Crypt Format identifier for this implementation, equal to <b>{@code shiro1}</b>.
 *             ( This implies that all {@code shiro1} MCF-formatted strings will always begin with the prefix
 *             {@code $shiro1$} ).</td>
 *         <td>true</td>
 *     </tr>
 *     <tr>
 *         <td>2</td>
 *         <td>{@code algorithmName}</td>
 *         <td>The name of the hash algorithm used to perform the hash.  This is an algorithm name understood by
 *         {@code MessageDigest}.{@link java.security.MessageDigest#getInstance(string) getInstance}, for example
 *         {@code MD5}, {@code SHA-256}, {@code SHA-256}, etc.</td>
 *         <td>true</td>
 *     </tr>
 *     <tr>
 *         <td>3</td>
 *         <td>{@code iterationCount}</td>
 *         <td>The number of hash iterations performed.</td>
 *         <td>true (1 <= N <= Integer.MAX_VALUE)</td>
 *     </tr>
 *     <tr>
 *         <td>4</td>
 *         <td>{@code base64EncodedSalt}</td>
 *         <td>The Base64-encoded salt byte array.  This token only exists if a salt was used to perform the hash.</td>
 *         <td>false</td>
 *     </tr>
 *     <tr>
 *         <td>5</td>
 *         <td>{@code base64EncodedDigest}</td>
 *         <td>The Base64-encoded digest byte array.  This is the actual hash result.</td>
 *         <td>true</td>
 *     </tr>
 * </table>
 *
 * @see ModularCryptFormat
 * @see ParsableHashFormat
 *
 */
class Shiro1CryptFormat : ModularCryptFormat, ParsableHashFormat {

    enum string ID = "shiro1";
    enum string MCF_PREFIX = TOKEN_DELIMITER ~ ID ~ TOKEN_DELIMITER;

    this() {
    }

    string getId() {
        return ID;
    }

    string format(Hash hash) {
        if (hash  is null) {
            return null;
        }

        string algorithmName = hash.getAlgorithmName();
        ByteSource salt = hash.getSalt();
        int iterations = hash.getIterations();
        StringBuilder sb = new StringBuilder(MCF_PREFIX).append(algorithmName).append(TOKEN_DELIMITER).append(iterations).append(TOKEN_DELIMITER);

        if (salt !is null) {
            sb.append(salt.toBase64());
        }

        sb.append(TOKEN_DELIMITER);
        sb.append(hash.toBase64());

        return sb.toString();
    }

    Hash parse(string formatted) {
        if (formatted  is null) {
            return null;
        }
        if (!formatted.startsWith(MCF_PREFIX)) {
            //TODO create a HashFormatException class
            string msg = "The argument is not a valid '" ~ ID ~ "' formatted hash.";
            throw new IllegalArgumentException(msg);
        }

        string suffix = formatted[MCF_PREFIX.length .. $];
        string[] parts = suffix.split("\\$");

        //last part is always the digest/checksum, Base64-encoded:
        int i = cast(int)parts.length-1;
        string digestBase64 = parts[i--];
        //second-to-last part is always the salt, Base64-encoded:
        string saltBase64 = parts[i--];
        string iterationsString = parts[i--];
        string algorithmName = parts[i];

        byte[] digest = Base64.decode(digestBase64);
        ByteSource salt = null;

        if (!saltBase64.empty()) {
            byte[] saltBytes = Base64.decode(saltBase64);
            salt = ByteSourceUtil.bytes(saltBytes);
        }

        int iterations;
        try {
            iterations = to!int(iterationsString);
        } catch (NumberFormatException e) {
            string msg = "Unable to parse formatted hash string: " ~ formatted;
            throw new IllegalArgumentException(msg, e);
        }

        SimpleHash hash = new SimpleHash(algorithmName);
        hash.setBytes(digest);
        if (salt !is null) {
            hash.setSalt(salt);
        }
        hash.setIterations(iterations);

        return hash;
    }
}
