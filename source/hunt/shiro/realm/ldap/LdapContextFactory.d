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
module hunt.shiro.realm.ldap.LdapContextFactory;

import javax.naming.NamingException;
import javax.naming.ldap.LdapContext;

/**
 * Interface that encapsulates the creation of {@code LdapContext} objects that are used by {@link DefaultLdapRealm}s to
 * perform authentication attempts and query for authorization data.
 *
 * @since 0.2
 */
interface LdapContextFactory {

    /**
     * Creates (or retrieves from a pool) a {@code LdapContext} connection bound using the system account, or
     * anonymously if no system account is configured.
     *
     * @return a {@code LdapContext} bound by the system account, or bound anonymously if no system account
     *         is configured.
     * @throws javax.naming.NamingException if there is an error creating the context.
     */
    LdapContext getSystemLdapContext();

    /**
     * Creates (or retrieves from a pool) a {@code LdapContext} connection bound using the username and password
     * specified.
     *
     * @param username the username to use when creating the connection.
     * @param password the password to use when creating the connection.
     * @return a {@code LdapContext} bound using the given username and password.
     * @throws javax.naming.NamingException if there is an error creating the context.
     * deprecated("") the {@link #getLdapContext(Object, Object)} method should be used in all cases to ensure more than
     * string principals and credentials can be used.
     */
    deprecated("")
    LdapContext getLdapContext(string username, string password);

    /**
     * Creates (or retrieves from a pool) an {@code LdapContext} connection bound using the specified principal and
     * credentials.  The format of the principal and credentials are whatever is supported by the underlying
     * LDAP {@link javax.naming.spi.InitialContextFactory InitialContextFactory} implementation.  The default Sun
     * (now Oracle) implementation supports
     * <a href="http://download-llnw.oracle.com/javase/tutorial/jndi/ldap/auth_mechs.html">anonymous, simple, and
     * SASL-based mechanisms</a>.
     * <p/>
     * This method was added in Shiro 1.1 to address the fact that principals and credentials can be more than just
     * {@code string} user DNs and passwords for connecting to LDAP.  For example, the credentials can be an
     * {@code X.509} certificate.
     *
     * @param principal   the principal to use when acquiring a connection to the LDAP directory
     * @param credentials the credentials (password, X.509 certificate, etc) to use when acquiring a connection to the
     *                    LDAP directory
     * @return the acquired {@code LdapContext} connection bound using the specified principal and credentials.
     * @throws NamingException if unable to acquire a connection.
     * @since 1.1
     */
    LdapContext getLdapContext(Object principal, Object credentials);
    
}
