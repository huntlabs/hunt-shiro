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
module hunt.shiro.crypto.hash.Sha256Hash;

import hunt.shiro.codec.Base64;
import hunt.shiro.codec.Hex;

/**
 * Generates an SHA-256 Hash from a given input <tt>source</tt> with an optional <tt>salt</tt> and hash iterations.
 * <p/>
 * See the {@link SimpleHash SimpleHash} parent class JavaDoc for a detailed explanation of Hashing
 * techniques and how the overloaded constructors function.
 * <p/>
 * <b>JDK Version Note</b> - Attempting to instantiate this class on JREs prior to version 1.4.0 will throw
 * an {@link IllegalStateException IllegalStateException}
 *
 */
class Sha256Hash : SimpleHash {

    //TODO - complete JavaDoc

    enum string ALGORITHM_NAME = "SHA-256";

    this() {
        super(ALGORITHM_NAME);
    }

    this(Object source) {
        super(ALGORITHM_NAME, source);
    }

    this(Object source, Object salt) {
        super(ALGORITHM_NAME, source, salt);
    }

    this(Object source, Object salt, int hashIterations) {
        super(ALGORITHM_NAME, source, salt, hashIterations);
    }

    static Sha256Hash fromHexString(string hex) {
        Sha256Hash hash = new Sha256Hash();
        hash.setBytes(Hex.decode(hex));
        return hash;
    }

    static Sha256Hash fromBase64String(string base64) {
        Sha256Hash hash = new Sha256Hash();
        hash.setBytes(Base64.decode(base64));
        return hash;
    }
}
