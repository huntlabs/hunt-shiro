/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
module hunt.shiro.authc.credential.DefaultPasswordService;

import hunt.shiro.authc.credential.HashingPasswordService;

import hunt.shiro.crypto.hash;
import hunt.shiro.util.ByteSource;
import hunt.shiro.util.SimpleByteSource;
import hunt.logging.Logger;

import std.array;

/**
 * Default implementation of the {@link PasswordService} interface that relies on an internal
 * {@link HashService}, {@link HashFormat}, and {@link HashFormatFactory} to function:
 * <h2>Hashing Passwords</h2>
 *
 * <h2>Comparing Passwords</h2>
 * All hashing operations are performed by the internal {@link #getHashService() hashService}.  After the hash
 * is computed, it is formatted into a string value via the internal {@link #getHashFormat() hashFormat}.
 *
 */
class DefaultPasswordService : HashingPasswordService {

    enum string DEFAULT_HASH_ALGORITHM = "SHA-256";
    enum int DEFAULT_HASH_ITERATIONS = 500000; //500,000



    private HashService hashService;
    private HashFormat hashFormat;
    private HashFormatFactory hashFormatFactory;

    private bool hashFormatWarned; //used to avoid excessive log noise

    this() {
        this.hashFormatWarned = false;

        DefaultHashService hashService = new DefaultHashService();
        hashService.setHashAlgorithmName(DEFAULT_HASH_ALGORITHM);
        hashService.setHashIterations(DEFAULT_HASH_ITERATIONS);
        hashService.setGeneratePublicSalt(true); //always want generated salts for user passwords to be most secure
        this.hashService = hashService;

        this.hashFormat = new Shiro1CryptFormat();
        this.hashFormatFactory = new DefaultHashFormatFactory();
    }

    string encryptPassword(Object plaintext) {
        Hash hash = hashPassword(plaintext);
        checkHashFormatDurability();
        return this.hashFormat.format(hash);
    }

    Hash hashPassword(Object plaintext) {
        ByteSource plaintextBytes = createByteSource(plaintext);
        if (plaintextBytes  is null || plaintextBytes.isEmpty()) {
            return null;
        }
        HashRequest request = createHashRequest(plaintextBytes);
        return hashService.computeHash(request);
    }

    bool passwordsMatch(Object plaintext, Hash saved) {
        ByteSource plaintextBytes = createByteSource(plaintext);

        if (saved  is null || saved.isEmpty()) {
            return plaintextBytes  is null || plaintextBytes.isEmpty();
        } else {
            if (plaintextBytes  is null || plaintextBytes.isEmpty()) {
                return false;
            }
        }

        HashRequest request = buildHashRequest(plaintextBytes, saved);

        Hash computed = this.hashService.computeHash(request);

        return saved == computed;
    }

    protected void checkHashFormatDurability() {

        if (!this.hashFormatWarned) {

            version(HUNT_DEBUG) {
                HashFormat format = this.hashFormat;
                ParsableHashFormat formatCast = cast(ParsableHashFormat)format;
                if (!(formatCast !is null)) {
                    string msg = "The configured hashFormat instance [" ~ 
                            typeid(cast(Object)format).name ~ "] is not a " ~
                            typeid(ParsableHashFormat).toString() ~ " implementation.  This is " ~
                            "required if you wish to support backwards compatibility " ~ 
                            "for saved password checking (almost " ~
                            "always desirable).  Without a " ~ 
                            typeid(ParsableHashFormat).toString() ~ " instance, " ~
                            "any hashService configuration changes will break previously hashed/saved passwords.";
                    warning(msg);
                    this.hashFormatWarned = true;
                }
            }
        }
    }

    protected HashRequest createHashRequest(ByteSource plaintext) {
        return new HashRequest.Builder().setSource(plaintext).build();
    }

    protected ByteSource createByteSource(Object o) {
        return ByteSourceUtil.bytes(o);
    }

     bool passwordsMatch(Object submittedPlaintext, string saved) {
        ByteSource plaintextBytes = createByteSource(submittedPlaintext);

        if (saved.empty()) {
            return plaintextBytes  is null || plaintextBytes.isEmpty();
        } else {
            if (plaintextBytes  is null || plaintextBytes.isEmpty()) {
                return false;
            }
        }

        //First check to see if we can reconstitute the original hash - this allows us to
        //perform password hash comparisons even for previously saved passwords that don't
        //match the current HashService configuration values.  This is a very nice feature
        //for password comparisons because it ensures backwards compatibility even after
        //configuration changes.
        HashFormat discoveredFormat = this.hashFormatFactory.getInstance(saved);
        auto discoveredFormatCast = cast(ParsableHashFormat)discoveredFormat;
        if (discoveredFormat !is null && discoveredFormatCast !is null) {

            ParsableHashFormat parsableHashFormat = discoveredFormatCast;
            Hash savedHash = parsableHashFormat.parse(saved);

            return passwordsMatch(submittedPlaintext, savedHash);
        }

        //If we're at this point in the method's execution, We couldn't reconstitute the original hash.
        //So, we need to hash the submittedPlaintext using current HashService configuration and then
        //compare the formatted output with the saved string.  This will correctly compare passwords,
        //but does not allow changing the HashService configuration without breaking previously saved
        //passwords:

        //The saved text value can't be reconstituted into a Hash instance.  We need to format the
        //submittedPlaintext and then compare this formatted value with the saved value:
        HashRequest request = createHashRequest(plaintextBytes);
        Hash computed = this.hashService.computeHash(request);
        string formatted = this.hashFormat.format(computed);

        return saved== formatted;
    }

    protected HashRequest buildHashRequest(ByteSource plaintext, Hash saved) {
        //keep everything from the saved hash except for the source:
        return new HashRequest.Builder().setSource(plaintext)
                //now use the existing saved data:
                .setAlgorithmName(saved.getAlgorithmName())
                .setSalt(saved.getSalt())
                .setIterations(saved.getIterations())
                .build();
    }

     HashService getHashService() {
        return hashService;
    }

     void setHashService(HashService hashService) {
        this.hashService = hashService;
    }

     HashFormat getHashFormat() {
        return hashFormat;
    }

     void setHashFormat(HashFormat hashFormat) {
        this.hashFormat = hashFormat;
    }

     HashFormatFactory getHashFormatFactory() {
        return hashFormatFactory;
    }

     void setHashFormatFactory(HashFormatFactory hashFormatFactory) {
        this.hashFormatFactory = hashFormatFactory;
    }
}
