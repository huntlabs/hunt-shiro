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
module hunt.shiro.session.UnknownSessionException;

/**
 * Exception thrown when attempting to interact with the system under the pretense of a
 * particular session (e.g. under a specific session id), and that session does not exist in
 * the system.
 *
 * @since 0.1
 */
class UnknownSessionException : InvalidSessionException {

    /**
     * Creates a new UnknownSessionException.
     */
     UnknownSessionException() {
        super();
    }

    /**
     * Constructs a new UnknownSessionException.
     *
     * @param message the reason for the exception
     */
     UnknownSessionException(string message) {
        super(message);
    }

    /**
     * Constructs a new UnknownSessionException.
     *
     * @param cause the underlying Throwable that caused this exception to be thrown.
     */
     UnknownSessionException(Throwable cause) {
        super(cause);
    }

    /**
     * Constructs a new UnknownSessionException.
     *
     * @param message the reason for the exception
     * @param cause   the underlying Throwable that caused this exception to be thrown.
     */
     UnknownSessionException(string message, Throwable cause) {
        super(message, cause);
    }
}
