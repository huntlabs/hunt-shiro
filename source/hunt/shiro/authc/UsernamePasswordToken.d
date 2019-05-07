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
module hunt.shiro.authc.UsernamePasswordToken;

/**
 * <p>A simple username/password authentication token to support the most widely-used authentication mechanism.  This
 * class also : the {@link RememberMeAuthenticationToken RememberMeAuthenticationToken} interface to support
 * &quot;Remember Me&quot; services across user sessions as well as the
 * {@link hunt.shiro.authc.HostAuthenticationToken HostAuthenticationToken} interface to retain the host name
 * or IP address location from where the authentication attempt is occurring.</p>
 * <p/>
 * <p>&quot;Remember Me&quot; authentications are disabled by default, but if the application developer wishes to allow
 * it for a login attempt, all that is necessary is to call {@link #setRememberMe setRememberMe(true)}.  If the underlying
 * <tt>SecurityManager</tt> implementation also supports <tt>RememberMe</tt> services, the user's identity will be
 * remembered across sessions.
 * <p/>
 * <p>Note that this class stores a password as[] a char instead of a string
 * (which may seem more logical).  This is because Strings are immutable and their
 * internal value cannot be overwritten - meaning even a nulled string instance might be accessible in memory at a later
 * time (e.g. memory dump).  This is not good for sensitive information such as passwords. For more information, see the
 * <a href="http://java.sun.com/j2se/1.5.0/docs/guide/security/jce/JCERefGuide.html#PBEEx">
 * Java Cryptography Extension Reference Guide</a>.</p>
 * <p/>
 * <p>To avoid this possibility of later memory access, the application developer should always call
 * {@link #clear() clear()} after using the token to perform a login attempt.</p>
 *
 */
class UsernamePasswordToken : HostAuthenticationToken, RememberMeAuthenticationToken {

    /*--------------------------------------------
    |             C O N S T A N T S             |
    ============================================*/

    /*--------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/
    /**
     * The username
     */
    private string username;

    /**
     * The password, in[] char format
     */
    private char[] password;

    /**
     * Whether or not 'rememberMe' should be enabled for the corresponding login attempt;
     * default is <code>false</code>
     */
    private bool rememberMe = false;

    /**
     * The location from where the login attempt occurs, or <code>null</code> if not known or explicitly
     * omitted.
     */
    private string host;

    /*--------------------------------------------
    |         C O N S T R U C T O R S           |
    ============================================*/

    /**
     * JavaBeans compatible no-arg constructor.
     */
     this() {
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted
     * during an authentication attempt, with a <tt>null</tt> {@link #getHost() host} and a
     * <tt>rememberMe</tt> default of <tt>false</tt>.
     *
     * @param username the username submitted for authentication
     * @param password the password character array submitted for authentication
     */
     this(string username, char[] password) {
        this(username, password, false, null);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted
     * during an authentication attempt, with a <tt>null</tt> {@link #getHost() host} and
     * a <tt>rememberMe</tt> default of <tt>false</tt>
     * <p/>
     * <p>This is a convenience constructor and maintains the password internally via a character
     * array, i.e. <tt>password.toCharArray();</tt>.  Note that storing a password as a string
     * in your code could have possible security implications as noted in the class JavaDoc.</p>
     *
     * @param username the username submitted for authentication
     * @param password the password string submitted for authentication
     */
     this(string username, string password) {
        this(username, password != null ? password.toCharArray() : null, false, null);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, the
     * inetAddress from where the attempt is occurring, and a default <tt>rememberMe</tt> value of <tt>false</tt>
     *
     * @param username the username submitted for authentication
     * @param password the password string submitted for authentication
     * @param host     the host name or IP string from where the attempt is occurring
     */
     this(string username, char[] password, string host) {
        this(username, password, false, host);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, the
     * inetAddress from where the attempt is occurring, and a default <tt>rememberMe</tt> value of <tt>false</tt>
     * <p/>
     * <p>This is a convenience constructor and maintains the password internally via a character
     * array, i.e. <tt>password.toCharArray();</tt>.  Note that storing a password as a string
     * in your code could have possible security implications as noted in the class JavaDoc.</p>
     *
     * @param username the username submitted for authentication
     * @param password the password string submitted for authentication
     * @param host     the host name or IP string from where the attempt is occurring
     */
     this(string username, string password, string host) {
        this(username, password != null ? password.toCharArray() : null, false, host);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, as well as if the user
     * wishes their identity to be remembered across sessions.
     *
     * @param username   the username submitted for authentication
     * @param password   the password string submitted for authentication
     * @param rememberMe if the user wishes their identity to be remembered across sessions
     */
     this(string username, char[] password, bool rememberMe) {
        this(username, password, rememberMe, null);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, as well as if the user
     * wishes their identity to be remembered across sessions.
     * <p/>
     * <p>This is a convenience constructor and maintains the password internally via a character
     * array, i.e. <tt>password.toCharArray();</tt>.  Note that storing a password as a string
     * in your code could have possible security implications as noted in the class JavaDoc.</p>
     *
     * @param username   the username submitted for authentication
     * @param password   the password string submitted for authentication
     * @param rememberMe if the user wishes their identity to be remembered across sessions
     */
     this(string username, string password, bool rememberMe) {
        this(username, password != null ? password.toCharArray() : null, rememberMe, null);
    }

    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, if the user
     * wishes their identity to be remembered across sessions, and the inetAddress from where the attempt is occurring.
     *
     * @param username   the username submitted for authentication
     * @param password   the password character array submitted for authentication
     * @param rememberMe if the user wishes their identity to be remembered across sessions
     * @param host       the host name or IP string from where the attempt is occurring
     */
     this(string username, char[] password, bool rememberMe, string host) {
        this.username = username;
        this.password = password;
        this.rememberMe = rememberMe;
        this.host = host;
    }


    /**
     * Constructs a new UsernamePasswordToken encapsulating the username and password submitted, if the user
     * wishes their identity to be remembered across sessions, and the inetAddress from where the attempt is occurring.
     * <p/>
     * <p>This is a convenience constructor and maintains the password internally via a character
     * array, i.e. <tt>password.toCharArray();</tt>.  Note that storing a password as a string
     * in your code could have possible security implications as noted in the class JavaDoc.</p>
     *
     * @param username   the username submitted for authentication
     * @param password   the password string submitted for authentication
     * @param rememberMe if the user wishes their identity to be remembered across sessions
     * @param host       the host name or IP string from where the attempt is occurring
     */
     this(string username, string password, bool rememberMe, string host) {
        this(username, password != null ? password.toCharArray() : null, rememberMe, host);
    }

    /*--------------------------------------------
    |  A C C E S S O R S / M O D I F I E R S    |
    ============================================*/

    /**
     * Returns the username submitted during an authentication attempt.
     *
     * @return the username submitted during an authentication attempt.
     */
     string getUsername() {
        return username;
    }

    /**
     * Sets the username for submission during an authentication attempt.
     *
     * @param username the username to be used for submission during an authentication attempt.
     */
     void setUsername(string username) {
        this.username = username;
    }


    /**
     * Returns the password submitted during an authentication attempt as a character array.
     *
     * @return the password submitted during an authentication attempt as a character array.
     */
     char[] getPassword() {
        return password;
    }

    /**
     * Sets the password for submission during an authentication attempt.
     *
     * @param password the password to be used for submission during an authentication attempt.
     */
     void setPassword(char[] password) {
        this.password = password;
    }

    /**
     * Simply returns {@link #getUsername() getUsername()}.
     *
     * @return the {@link #getUsername() username}.
     * @see hunt.shiro.authc.AuthenticationToken#getPrincipal()
     */
     Object getPrincipal() {
        return getUsername();
    }

    /**
     * Returns the {@link #getPassword() password} char array.
     *
     * @return the {@link #getPassword() password} char array.
     * @see hunt.shiro.authc.AuthenticationToken#getCredentials()
     */
     Object getCredentials() {
        return getPassword();
    }

    /**
     * Returns the host name or IP string from where the authentication attempt occurs.  May be <tt>null</tt> if the
     * host name/IP is unknown or explicitly omitted.  It is up to the Authenticator implementation processing this
     * token if an authentication attempt without a host is valid or not.
     * <p/>
     * <p>(Shiro's default Authenticator allows <tt>null</tt> hosts to support localhost and proxy server environments).</p>
     *
     * @return the host from where the authentication attempt occurs, or <tt>null</tt> if it is unknown or
     *         explicitly omitted.
     */
     string getHost() {
        return host;
    }

    /**
     * Sets the host name or IP string from where the authentication attempt occurs.  It is up to the Authenticator
     * implementation processing this token if an authentication attempt without a host is valid or not.
     * <p/>
     * <p>(Shiro's default Authenticator
     * allows <tt>null</tt> hosts to allow localhost and proxy server environments).</p>
     *
     * @param host the host name or IP string from where the attempt is occurring
     */
     void setHost(string host) {
        this.host = host;
    }

    /**
     * Returns <tt>true</tt> if the submitting user wishes their identity (principal(s)) to be remembered
     * across sessions, <tt>false</tt> otherwise.  Unless overridden, this value is <tt>false</tt> by default.
     *
     * @return <tt>true</tt> if the submitting user wishes their identity (principal(s)) to be remembered
     *         across sessions, <tt>false</tt> otherwise (<tt>false</tt> by default).
     */
     bool isRememberMe() {
        return rememberMe;
    }

    /**
     * Sets if the submitting user wishes their identity (principal(s)) to be remembered across sessions.  Unless
     * overridden, the default value is <tt>false</tt>, indicating <em>not</em> to be remembered across sessions.
     *
     * @param rememberMe value indicating if the user wishes their identity (principal(s)) to be remembered across
     *                   sessions.
     */
     void setRememberMe(bool rememberMe) {
        this.rememberMe = rememberMe;
    }

    /*--------------------------------------------
    |               M E T H O D S               |
    ============================================*/

    /**
     * Clears out (nulls) the username, password, rememberMe, and inetAddress.  The password bytes are explicitly set to
     * <tt>0x00</tt> before nulling to eliminate the possibility of memory access at a later time.
     */
     void clear() {
        this.username = null;
        this.host = null;
        this.rememberMe = false;

        if (this.password != null) {
            for (int i = 0; i < password.length; i++) {
                this.password[i] = 0x00;
            }
            this.password = null;
        }

    }

    /**
     * Returns the string representation.  It does not include the password in the resulting
     * string for security reasons to prevent accidentally printing out a password
     * that might be widely viewable).
     *
     * @return the string representation of the <tt>UsernamePasswordToken</tt>, omitting
     *         the password.
     */
     string toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getName());
        sb.append(" - ");
        sb.append(username);
        sb.append(", rememberMe=").append(rememberMe);
        if (host != null) {
            sb.append(" (").append(host).append(")");
        }
        return sb.toString();
    }

}
