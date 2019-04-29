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
module hunt.shiro.authc.credential.SimpleCredentialsMatcher;

import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.codec.CodecSupport;
import hunt.logger;
import hunt.loggerFactory;

//import java.security.MessageDigest;
//import hunt.util.ArrayHelper;


/**
 * Simple CredentialsMatcher implementation.  Supports direct (plain) comparison for credentials of type
 * byte[], char[], and Strings, and if the arguments do not match these types, then reverts back to simple
 * <code>Object.equals</code> comparison.
 * <p/>
 * <p>Hashing comparisons (the most common technique used in secure applications) are not supported by this class, but
 * instead by the {@link hunt.shiro.authc.credential.HashedCredentialsMatcher HashedCredentialsMatcher}.
 *
 * @see hunt.shiro.authc.credential.HashedCredentialsMatcher
 * @since 0.9
 */
class SimpleCredentialsMatcher : CodecSupport, CredentialsMatcher {



    /**
     * Returns the {@code token}'s credentials.
     * <p/>
     * <p>This default implementation merely returns
     * {@link AuthenticationToken#getCredentials() authenticationToken.getCredentials()} and exists as a template hook
     * if subclasses wish to obtain the credentials in a different way or convert them to a different format before
     * returning.
     *
     * @param token the {@code AuthenticationToken} submitted during the authentication attempt.
     * @return the {@code token}'s associated credentials.
     */
    protected Object getCredentials(AuthenticationToken token) {
        return token.getCredentials();
    }

    /**
     * Returns the {@code account}'s credentials.
     * <p/>
     * <p>This default implementation merely returns
     * {@link AuthenticationInfo#getCredentials() account.getCredentials()} and exists as a template hook if subclasses
     * wish to obtain the credentials in a different way or convert them to a different format before
     * returning.
     *
     * @param info the {@code AuthenticationInfo} stored in the data store to be compared against the submitted authentication
     *             token's credentials.
     * @return the {@code account}'s associated credentials.
     */
    protected Object getCredentials(AuthenticationInfo info) {
        return info.getCredentials();
    }

    /**
     * Returns {@code true} if the {@code tokenCredentials} argument is logically equal to the
     * {@code accountCredentials} argument.
     * <p/>
     * <p>If both arguments are either a byte array (byte[]), char array (char[]) or string, they will be both be
     * converted to raw byte arrays via the {@link #toBytes toBytes} method first, and then resulting byte arrays
     * are compared via {@link Arrays#equals(byte[], byte[]) ArrayHelper.equals(byte[],byte[])}.</p>
     * <p/>
     * <p>If either argument cannot be converted to a byte array as described, a simple Object <code>equals</code>
     * comparison is made.</p>
     * <p/>
     * <p>Subclasses should override this method for more explicit equality checks.
     *
     * @param tokenCredentials   the {@code AuthenticationToken}'s associated credentials.
     * @param accountCredentials the {@code AuthenticationInfo}'s stored credentials.
     * @return {@code true} if the {@code tokenCredentials} are equal to the {@code accountCredentials}.
     */
    protected bool equals(Object tokenCredentials, Object accountCredentials) {
        if (log.isDebugEnabled()) {
            tracef("Performing credentials equality check for tokenCredentials of type [" ~
                    tokenCredentials.getClass().getName() ~ " and accountCredentials of type [" ~
                    accountCredentials.getClass().getName() ~ "]");
        }
        if (isByteSource(tokenCredentials) && isByteSource(accountCredentials)) {
            if (log.isDebugEnabled()) {
                tracef("Both credentials arguments can be easily converted to byte ArrayHelper.  Performing " ~
                        "array equals comparison");
            }
            byte[] tokenBytes = toBytes(tokenCredentials);
            byte[] accountBytes = toBytes(accountCredentials);
            //return MessageDigest.isEqual(tokenBytes, accountBytes);
            return tokenBytes == accountBytes;
        } else {
            return accountCredentials== tokenCredentials;
        }
    }

    /**
     * This implementation acquires the {@code token}'s credentials
     * (via {@link #getCredentials(AuthenticationToken) getCredentials(token)})
     * and then the {@code account}'s credentials
     * (via {@link #getCredentials(hunt.shiro.authc.AuthenticationInfo) getCredentials(account)}) and then passes both of
     * them to the {@link #equals(Object,Object) equals(tokenCredentials, accountCredentials)} method for equality
     * comparison.
     *
     * @param token the {@code AuthenticationToken} submitted during the authentication attempt.
     * @param info  the {@code AuthenticationInfo} stored in the system matching the token principal.
     * @return {@code true} if the provided token credentials are equal to the stored account credentials,
     *         {@code false} otherwise
     */
     bool doCredentialsMatch(AuthenticationToken token, AuthenticationInfo info) {
        Object tokenCredentials = getCredentials(token);
        Object accountCredentials = getCredentials(info);
        return equals(tokenCredentials, accountCredentials);
    }

}
