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
module hunt.shiro.authc.credential.PasswordMatcher;

import hunt.shiro.authc.credential.CredentialsMatcher;
import hunt.shiro.authc.credential.DefaultPasswordService;
import hunt.shiro.authc.credential.PasswordService;
import hunt.shiro.authc.credential.HashingPasswordService;

import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.crypto.hash.Hash;

import hunt.Exceptions;
import hunt.String;


/**
 * A {@link CredentialsMatcher} that employs best-practices comparisons for hashed text passwords.
 * <p/>
 * This implementation delegates to an internal {@link PasswordService} to perform the actual password
 * comparison.  This class is essentially a bridge between the generic CredentialsMatcher interface and the
 * more specific {@code PasswordService} component.
 *
 */
class PasswordMatcher : CredentialsMatcher {

    private PasswordService passwordService;

     this() {
        this.passwordService = new DefaultPasswordService();
    }

     bool doCredentialsMatch(AuthenticationToken token, AuthenticationInfo info) {

        // PasswordService service = ensurePasswordService();

        // Object submittedPassword = getSubmittedPassword(token);
        // Object storedCredentials = getStoredPassword(info);
        // assertStoredCredentialsType(storedCredentials);
        // auto storedCredentialsCast = cast(Hash) storedCredentials;
        // if (storedCredentialsCast !is null) {
        //     Hash hashedPassword = storedCredentialsCast;
        //     HashingPasswordService hashingService = assertHashingPasswordService(service);
        //     return hashingService.passwordsMatch(submittedPassword, hashedPassword);
        // }
        // //otherwise they are a string (asserted in the 'assertStoredCredentialsType' method call above):
        // string formatted = (cast(String)storedCredentials).value;
        // return passwordService.passwordsMatch(submittedPassword, formatted);
        implementationMissing(false);
        return false;
    }

    private HashingPasswordService assertHashingPasswordService(PasswordService service) {
        auto serviceCast = cast(HashingPasswordService)service;
        if (serviceCast !is null) {
            return serviceCast;
        }
        string msg = "AuthenticationInfo's stored credentials are a Hash instance, but the " ~
                "configured passwordService is not a " ~
                "HashingPasswordService instance.  This is required to perform Hash " ~
                "object password comparisons.";
        throw new IllegalStateException(msg);
    }

    private PasswordService ensurePasswordService() {
        PasswordService service = getPasswordService();
        if (service  is null) {
            string msg = "Required PasswordService has not been configured.";
            throw new IllegalStateException(msg);
        }
        return service;
    }

    protected char[] getSubmittedPassword(AuthenticationToken token) {
        return token !is null ? token.getCredentials() : null;
    }

    private void assertStoredCredentialsType(Object credentials) {
        auto credentialsCast = cast(String)credentials;
        auto credentialsCast2 = cast(Hash)credentials;
        if (credentialsCast !is null || credentialsCast2 !is null) {
            return;
        }

        string msg = "Stored account credentials are expected to be either a " ~
                     "Hash instance or a formatted hash string.";
        throw new IllegalArgumentException(msg);
    }

    protected Object getStoredPassword(AuthenticationInfo storedAccountInfo) {
        Object stored = storedAccountInfo !is null ? storedAccountInfo.getCredentials() : null;
        //fix for https://issues.apache.org/jira/browse/SHIRO-363
        // if (stored instanceof[] char) {
        //     stored = new string((char[])stored);
        // }
        return stored;
    }

     PasswordService getPasswordService() {
        return passwordService;
    }

     void setPasswordService(PasswordService passwordService) {
        this.passwordService = passwordService;
    }
}
