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
module hunt.shiro.authc.credential.HashingPasswordService;

import hunt.shiro.authc.credential.PasswordService;

import hunt.shiro.crypto.hash.Hash;
import hunt.shiro.util.ByteSource;

/**
 * A {@code HashingPasswordService} is a {@link PasswordService} that performs password encryption and comparisons
 * based on cryptographic {@link Hash}es.
 *
 */
interface HashingPasswordService : PasswordService {

    /**
     * Hashes the specified plaintext password using internal hashing configuration settings pertinent to password
     * hashing.
     * <p/>
     * Note
     * that this method is only likely to be used in more complex environments that wish to format and/or save the
     * returned {@code Hash} object in a custom manner.  Most applications will find the
     * {@link #encryptPassword(Object) encryptPassword} method suitable enough for safety
     * and ease-of-use.
     * <h3>Usage</h3>
     * The input argument type can be any 'byte backed' {@code Object} - almost always either a
     * string or character array representing passwords (character arrays are often a safer way to represent passwords
     * as they can be cleared/nulled-out after use.  Any argument type supported by
     * {@link ByteSourceUtil#isCompatible(Object)} is valid.
     * <p/>
     * Regardless of your choice of using Strings or character arrays to represent submitted passwords, you can wrap
     * either as a {@code ByteSource} by using {@link ByteSourceUtil}, for example, when the passwords are captured as
     * Strings:
     * <pre>
     * ByteSource passwordBytes = ByteSourceUtil.bytes(submittedPasswordString);
     * Hash hashedPassword = hashingPasswordService.hashPassword(passwordBytes);
     * </pre>
     * or, identically, when captured as a character array:
     * <pre>
     * ByteSource passwordBytes = ByteSourceUtil.bytes(submittedPasswordCharacterArray);
     * Hash hashedPassword = hashingPasswordService.hashPassword(passwordBytes);
     * </pre>
     *
     * @param plaintext the raw password as 'byte-backed' object (string, character array, {@link ByteSource},
     *                  etc) usually acquired from your application's 'new user' or 'password reset' workflow.
     * @return the hashed password.
     * @throws IllegalArgumentException if the argument cannot be easily converted to bytes as defined by
     *                                  {@link ByteSourceUtil#isCompatible(Object)}.
     * @see ByteSourceUtil#isCompatible(Object)
     * @see #encryptPassword(Object)
     */
    Hash hashPassword(Object plaintext);

    /**
     * Returns {@code true} if the {@code submittedPlaintext} password matches the existing {@code savedPasswordHash},
     * {@code false} otherwise.  Note that this method is only likely to be used in more complex environments that
     * save hashes in a custom manner.  Most applications will find the
     * {@link #passwordsMatch(Object, string) passwordsMatch(plaintext,string)} method
     * sufficient if {@link #encryptPassword(Object) encrypting passwords as Strings}.
     * <h3>Usage</h3>
     * The {@code submittedPlaintext} argument type can be any 'byte backed' {@code Object} - almost always either a
     * string or character array representing passwords (character arrays are often a safer way to represent passwords
     * as they can be cleared/nulled-out after use.  Any argument type supported by
     * {@link ByteSourceUtil#isCompatible(Object)} is valid.
     *
     * @param plaintext a raw/plaintext password submitted by an end user/Subject.
     * @param savedPasswordHash  the previously hashed password known to be associated with an account.
     *                           This value is expected to have been previously generated from the
     *                           {@link #hashPassword(Object) hashPassword} method (typically
     *                           when the account is created or the account's password is reset).
     * @return {@code true} if the {@code plaintext} password matches the existing {@code savedPasswordHash},
     *         {@code false} otherwise.
     */
    bool passwordsMatch(Object plaintext, Hash savedPasswordHash);
}
