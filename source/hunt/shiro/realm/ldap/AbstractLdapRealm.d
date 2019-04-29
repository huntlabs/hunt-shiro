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
module hunt.shiro.realm.ldap.AbstractLdapRealm;

import hunt.shiro.authc.AuthenticationException;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authz.AuthorizationException;
import hunt.shiro.authz.AuthorizationInfo;
import hunt.shiro.realm.AuthorizingRealm;
import hunt.shiro.subject.PrincipalCollection;
import hunt.logger;
import hunt.loggerFactory;

import javax.naming.NamingException;

/**
 * <p>A {@link hunt.shiro.realm.Realm} that authenticates with an LDAP
 * server to build the Subject for a user.  This implementation only returns roles for a
 * particular user, and not permissions - but it can be subclassed to build a permission
 * list as well.</p>
 *
 * <p>Implementations would need to implement the
 * {@link #queryForAuthenticationInfo(hunt.shiro.authc.AuthenticationToken ,LdapContextFactory)} and
 * {@link #queryForAuthorizationInfo(hunt.shiro.subject.PrincipalCollection ,LdapContextFactory)} abstract methods.</p>
 *
 * <p>By default, this implementation will create an instance of {@link DefaultLdapContextFactory} to use for
 * creating LDAP connections using the principalSuffix, searchBase, url, systemUsername, and systemPassword properties
 * specified on the realm.  The remaining settings use the defaults of {@link DefaultLdapContextFactory}, which are usually
 * sufficient.  If more customized connections are needed, you should inject a custom {@link LdapContextFactory}, which
 * will cause these properties specified on the realm to be ignored.</p>
 *
 * @see #queryForAuthenticationInfo(hunt.shiro.authc.AuthenticationToken , LdapContextFactory)
 * @see #queryForAuthorizationInfo(hunt.shiro.subject.PrincipalCollection , LdapContextFactory)
 * @since 0.1
 */
abstract class AbstractLdapRealm : AuthorizingRealm {

    //TODO - complete JavaDoc

    /*--------------------------------------------
    |             C O N S T A N T S             |
    ============================================*/



    /*--------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/
    protected string principalSuffix = null;

    protected string searchBase = null;

    protected string url = null;

    protected string systemUsername = null;

    protected string systemPassword = null;

    //SHIRO-115 - prevent potential code injection:
    protected string searchFilter = "(&(objectClass=*)(userPrincipalName={0}))";

    private LdapContextFactory ldapContextFactory = null;

    /*--------------------------------------------
    |         C O N S T R U C T O R S           |
    ============================================*/

    /*--------------------------------------------
    |  A C C E S S O R S / M O D I F I E R S    |
    ============================================*/

    /*--------------------------------------------
    |               M E T H O D S               |
    ============================================*/


    /**
     * Used when initializing the default {@link LdapContextFactory}.  This property is ignored if a custom
     * <tt>LdapContextFactory</tt> is specified.
     *
     * @param principalSuffix the suffix.
     * @see DefaultLdapContextFactory#setPrincipalSuffix(string)
     */
     void setPrincipalSuffix(string principalSuffix) {
        this.principalSuffix = principalSuffix;
    }

    /**
     * Used when initializing the default {@link LdapContextFactory}.  This property is ignored if a custom
     * <tt>LdapContextFactory</tt> is specified.
     *
     * @param searchBase the search base.
     * @see DefaultLdapContextFactory#setSearchBase(string)
     */
     void setSearchBase(string searchBase) {
        this.searchBase = searchBase;
    }

    /**
     * Used when initializing the default {@link LdapContextFactory}.  This property is ignored if a custom
     * <tt>LdapContextFactory</tt> is specified.
     *
     * @param url the LDAP url.
     * @see DefaultLdapContextFactory#setUrl(string)
     */
     void setUrl(string url) {
        this.url = url;
    }

    /**
     * Used when initializing the default {@link LdapContextFactory}.  This property is ignored if a custom
     * <tt>LdapContextFactory</tt> is specified.
     *
     * @param systemUsername the username to use when logging into the LDAP server for authorization.
     * @see DefaultLdapContextFactory#setSystemUsername(string)
     */
     void setSystemUsername(string systemUsername) {
        this.systemUsername = systemUsername;
    }


    /**
     * Used when initializing the default {@link LdapContextFactory}.  This property is ignored if a custom
     * <tt>LdapContextFactory</tt> is specified.
     *
     * @param systemPassword the password to use when logging into the LDAP server for authorization.
     * @see DefaultLdapContextFactory#setSystemPassword(string)
     */
     void setSystemPassword(string systemPassword) {
        this.systemPassword = systemPassword;
    }


    /**
     * Configures the {@link LdapContextFactory} implementation that is used to create LDAP connections for
     * authentication and authorization.  If this is set, the {@link LdapContextFactory} provided will be used.
     * Otherwise, a {@link DefaultLdapContextFactory} instance will be created based on the properties specified
     * in this realm.
     *
     * @param ldapContextFactory the factory to use - if not specified, a default factory will be created automatically.
     */
     void setLdapContextFactory(LdapContextFactory ldapContextFactory) {
        this.ldapContextFactory = ldapContextFactory;
    }


     void setSearchFilter(string searchFilter) {
        this.searchFilter = searchFilter;
    }

    /*--------------------------------------------
    |               M E T H O D S                |
    ============================================*/

    protected void onInit() {
        super.onInit();
        ensureContextFactory();
    }

    private LdapContextFactory ensureContextFactory() {
        if (this.ldapContextFactory  is null) {

            if (log.isDebugEnabled()) {
                tracef("No LdapContextFactory specified - creating a default instance.");
            }

            DefaultLdapContextFactory defaultFactory = new DefaultLdapContextFactory();
            defaultFactory.setPrincipalSuffix(this.principalSuffix);
            defaultFactory.setSearchBase(this.searchBase);
            defaultFactory.setUrl(this.url);
            defaultFactory.setSystemUsername(this.systemUsername);
            defaultFactory.setSystemPassword(this.systemPassword);

            this.ldapContextFactory = defaultFactory;
        }
        return this.ldapContextFactory;
    }


    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token){
        AuthenticationInfo info;
        try {
            info = queryForAuthenticationInfo(token, ensureContextFactory());
        } catch (javax.naming.AuthenticationException e) {
            throw new AuthenticationException("LDAP authentication failed.", e);
        } catch (NamingException e) {
            string msg = "LDAP naming error while attempting to authenticate user.";
            throw new AuthenticationException(msg, e);
        }

        return info;
    }


    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        AuthorizationInfo info;
        try {
            info = queryForAuthorizationInfo(principals, ensureContextFactory());
        } catch (NamingException e) {
            string msg = "LDAP naming error while attempting to retrieve authorization for user [" ~ principals ~ "].";
            throw new AuthorizationException(msg, e);
        }

        return info;
    }


    /**
     * <p>Abstract method that should be implemented by subclasses to builds an
     * {@link AuthenticationInfo} object by querying the LDAP context for the
     * specified username.</p>
     *
     * @param token              the authentication token given during authentication.
     * @param ldapContextFactory factory used to retrieve LDAP connections.
     * @return an {@link AuthenticationInfo} instance containing information retrieved from the LDAP server.
     * @throws NamingException if any LDAP errors occur during the search.
     */
    protected abstract AuthenticationInfo queryForAuthenticationInfo(AuthenticationToken token, LdapContextFactory ldapContextFactory);


    /**
     * <p>Abstract method that should be implemented by subclasses to builds an
     * {@link AuthorizationInfo} object by querying the LDAP context for the
     * specified principal.</p>
     *
     * @param principal          the principal of the Subject whose AuthenticationInfo should be queried from the LDAP server.
     * @param ldapContextFactory factory used to retrieve LDAP connections.
     * @return an {@link AuthorizationInfo} instance containing information retrieved from the LDAP server.
     * @throws NamingException if any LDAP errors occur during the search.
     */
    protected abstract AuthorizationInfo queryForAuthorizationInfo(PrincipalCollection principal, LdapContextFactory ldapContextFactory);

}
