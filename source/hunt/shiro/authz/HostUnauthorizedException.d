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
module hunt.shiro.authz.HostUnauthorizedException;

/**
 * Thrown when a particular client (that is, host address) has not been enabled to access the system
 * or if the client has been enabled access but is not permitted to perform a particular operation
 * or access a particular resource.
 *
 * @since 0.1
 */
class HostUnauthorizedException : UnauthorizedException {

    private string host;

    /**
     * Creates a new HostUnauthorizedException.
     */
     this() {
        super();
    }

    /**
     * Constructs a new HostUnauthorizedException.
     *
     * @param message the reason for the exception
     */
     this(string message) {
        super(message);
    }

    /**
     * Constructs a new HostUnauthorizedException.
     *
     * @param cause the underlying Throwable that caused this exception to be thrown.
     */
     this(Throwable cause) {
        super(cause);
    }

    /**
     * Constructs a new HostUnauthorizedException.
     *
     * @param message the reason for the exception
     * @param cause   the underlying Throwable that caused this exception to be thrown.
     */
     this(string message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Returns the host associated with this exception.
     *
     * @return the host associated with this exception.
     */
     string getHost() {
        return this.host;
    }

    /**
     * Sets the host associated with this exception.
     *
     * @param host the host associated with this exception.
     */
     void setHostAddress(string host) {
        this.host = host;
    }
}
