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
module hunt.shiro.authc.pam.UnsupportedTokenException;

import hunt.shiro.authc.AuthenticationException;


/**
 * Exception thrown during the authentication process when an
 * {@link hunt.shiro.authc.AuthenticationToken AuthenticationToken} implementation is encountered that is not
 * supported by one or more configured {@link hunt.shiro.realm.Realm Realm}s.
 *
 * @see hunt.shiro.authc.pam.AuthenticationStrategy
 * @since 0.2
 */
class UnsupportedTokenException : AuthenticationException {

    /**
     * Creates a new UnsupportedTokenException.
     */
     this() {
        super();
    }

    /**
     * Constructs a new UnsupportedTokenException.
     *
     * @param message the reason for the exception
     */
     this(string message) {
        super(message);
    }

    /**
     * Constructs a new UnsupportedTokenException.
     *
     * @param cause the underlying Throwable that caused this exception to be thrown.
     */
     this(Throwable cause) {
        super(cause);
    }

    /**
     * Constructs a new UnsupportedTokenException.
     *
     * @param message the reason for the exception
     * @param cause   the underlying Throwable that caused this exception to be thrown.
     */
     this(string message, Throwable cause) {
        super(message, cause);
    }
}
