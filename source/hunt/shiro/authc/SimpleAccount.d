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
module hunt.shiro.authc.SimpleAccount;

import hunt.shiro.authc.Account;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.MergableAuthenticationInfo;
import hunt.shiro.authc.SaltedAuthenticationInfo;
import hunt.shiro.authc.SimpleAuthenticationInfo;

import hunt.shiro.authz.Permission;
import hunt.shiro.authz.SimpleAuthorizationInfo;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.SimplePrincipalCollection;
import hunt.shiro.util.ByteSource;

//import hunt.io.Serializable;
import hunt.collection;


/**
 * Simple implementation of the {@link hunt.shiro.authc.Account} interface that
 * contains principal and credential and authorization information (roles and permissions) as instance variables and
 * exposes them via getters and setters using standard JavaBean notation.
 *
 */
class SimpleAccount : Account, MergableAuthenticationInfo, SaltedAuthenticationInfo {

    /*--------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/
    /**
     * The authentication information (principals and credentials) for this account.
     */
    private SimpleAuthenticationInfo authcInfo;

    /**
     * The authorization information for this account.
     */
    private SimpleAuthorizationInfo authzInfo;

    /**
     * Indicates this account is locked.  This isn't honored by all <tt>Realms</tt> but is honored by
     * {@link hunt.shiro.realm.SimpleAccountRealm}.
     */
    private bool locked;

    /**
     * Indicates credentials on this account are expired.  This isn't honored by all <tt>Realms</tt> but is honored by
     * {@link hunt.shiro.realm.SimpleAccountRealm}.
     */
    private bool credentialsExpired;

    /*--------------------------------------------
    |         C O N S T R U C T O R S           |
    ============================================*/

    /**
     * Default no-argument constructor.
     */
    this() {
    }

    /**
     * Constructs a SimpleAccount instance for the specified realm with the given principals and credentials.
     *
     * @param principal   the 'primary' identifying attribute of the account, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param realmName   the name of the realm that accesses this account data
     */
     this(Object principal, Object credentials, string realmName) {
        auto principalCast = cast(PrincipalCollection)principal;
        this(principalCast !is null ? principalCast : new SimplePrincipalCollection(principal, realmName), credentials);
    }

    /**
     * Constructs a SimpleAccount instance for the specified realm with the given principals, hashedCredentials and
     * credentials salt used when hashing the credentials.
     *
     * @param principal         the 'primary' identifying attribute of the account, for example, a user id or username.
     * @param hashedCredentials the credentials that verify identity for the account
     * @param credentialsSalt   the salt used when hashing the credentials
     * @param realmName         the name of the realm that accesses this account data
     * @see hunt.shiro.authc.credential.HashedCredentialsMatcher HashedCredentialsMatcher
     */
     this(Object principal, Object hashedCredentials, ByteSource credentialsSalt, string realmName) {
        auto principalCast = cast(PrincipalCollection)principal;
        this(principalCast !is null ? principalCast : new SimplePrincipalCollection(principal, realmName),
                hashedCredentials, credentialsSalt);
    }

    /**
     * Constructs a SimpleAccount instance for the specified realm with the given principals and credentials.
     *
     * @param principals  the identifying attributes of the account, at least one of which should be considered the
     *                    account's 'primary' identifying attribute, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param realmName   the name of the realm that accesses this account data
     */
    this(Collection!Object principals, Object credentials, string realmName) {
        this(new SimplePrincipalCollection(principals, realmName), credentials);
    }

    /**
     * Constructs a SimpleAccount instance for the specified principals and credentials.
     *
     * @param principals  the identifying attributes of the account, at least one of which should be considered the
     *                    account's 'primary' identifying attribute, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     */
     this(PrincipalCollection principals, Object credentials) {
        this.authcInfo = new SimpleAuthenticationInfo(principals, credentials);
        this.authzInfo = new SimpleAuthorizationInfo();
    }

    /**
     * Constructs a SimpleAccount instance for the specified principals and credentials.
     *
     * @param principals        the identifying attributes of the account, at least one of which should be considered the
     *                          account's 'primary' identifying attribute, for example, a user id or username.
     * @param hashedCredentials the hashed credentials that verify identity for the account
     * @param credentialsSalt   the salt used when hashing the credentials
     * @see hunt.shiro.authc.credential.HashedCredentialsMatcher HashedCredentialsMatcher
     */
     this(PrincipalCollection principals, Object hashedCredentials, ByteSource credentialsSalt) {
        this.authcInfo = new SimpleAuthenticationInfo(principals, hashedCredentials, credentialsSalt);
        this.authzInfo = new SimpleAuthorizationInfo();
    }

    /**
     * Constructs a SimpleAccount instance for the specified principals and credentials, with the assigned roles.
     *
     * @param principals  the identifying attributes of the account, at least one of which should be considered the
     *                    account's 'primary' identifying attribute, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param roles       the names of the roles assigned to this account.
     */
     this(PrincipalCollection principals, Object credentials, Set!(string) roles) {
        this.authcInfo = new SimpleAuthenticationInfo(principals, credentials);
        this.authzInfo = new SimpleAuthorizationInfo(roles);
    }

    /**
     * Constructs a SimpleAccount instance for the specified realm with the given principal and credentials, with the
     * the assigned roles and permissions.
     *
     * @param principal   the 'primary' identifying attributes of the account, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param realmName   the name of the realm that accesses this account data
     * @param roleNames   the names of the roles assigned to this account.
     * @param permissions the permissions assigned to this account directly (not those assigned to any of the realms).
     */
     this(Object principal, Object credentials, string realmName, Set!(string) roleNames, Set!(Permission) permissions) {
        this.authcInfo = new SimpleAuthenticationInfo(new SimplePrincipalCollection(principal, realmName), credentials);
        this.authzInfo = new SimpleAuthorizationInfo(roleNames);
        this.authzInfo.setObjectPermissions(permissions);
    }

    /**
     * Constructs a SimpleAccount instance for the specified realm with the given principals and credentials, with the
     * the assigned roles and permissions.
     *
     * @param principals  the identifying attributes of the account, at least one of which should be considered the
     *                    account's 'primary' identifying attribute, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param realmName   the name of the realm that accesses this account data
     * @param roleNames   the names of the roles assigned to this account.
     * @param permissions the permissions assigned to this account directly (not those assigned to any of the realms).
     */
     this(Collection!Object principals, Object credentials, string realmName, Set!(string) roleNames, Set!(Permission) permissions) {
        this.authcInfo = new SimpleAuthenticationInfo(new SimplePrincipalCollection(principals, realmName), credentials);
        this.authzInfo = new SimpleAuthorizationInfo(roleNames);
        this.authzInfo.setObjectPermissions(permissions);
    }

    /**
     * Constructs a SimpleAccount instance from the given principals and credentials, with the
     * the assigned roles and permissions.
     *
     * @param principals  the identifying attributes of the account, at least one of which should be considered the
     *                    account's 'primary' identifying attribute, for example, a user id or username.
     * @param credentials the credentials that verify identity for the account
     * @param roleNames   the names of the roles assigned to this account.
     * @param permissions the permissions assigned to this account directly (not those assigned to any of the realms).
     */
     this(PrincipalCollection principals, Object credentials, Set!(string) roleNames, Set!(Permission) permissions) {
        this.authcInfo = new SimpleAuthenticationInfo(principals, credentials);
        this.authzInfo = new SimpleAuthorizationInfo(roleNames);
        this.authzInfo.setObjectPermissions(permissions);
    }

    /*--------------------------------------------
    |  A C C E S S O R S / M O D I F I E R S    |
    ============================================*/

    /**
     * Returns the principals, aka the identifying attributes (username, user id, first name, last name, etc) of this
     * Account.
     *
     * @return all the principals, aka the identifying attributes, of this Account.
     */
    PrincipalCollection getPrincipals() @trusted nothrow {
        return authcInfo.getPrincipals();
    }

    /**
     * Sets the principals, aka the identifying attributes (username, user id, first name, last name, etc) of this
     * Account.
     *
     * @param principals all the principals, aka the identifying attributes, of this Account.
     * @see Account#getPrincipals()
     */
     void setPrincipals(PrincipalCollection principals) {
        this.authcInfo.setPrincipals(principals);
    }


    /**
     * Simply returns <code>this.authcInfo.getCredentials</code>.  The <code>authcInfo</code> attribute is constructed
     * via the constructors to wrap the input arguments.
     *
     * @return this Account's credentials.
     */
     Object getCredentials() {
        return authcInfo.getCredentials();
    }

    /**
     * Sets this Account's credentials that verify one or more of the Account's
     * {@link #getPrincipals() principals}, such as a password or private key.
     *
     * @param credentials the credentials associated with this Account that verify one or more of the Account principals.
     * @see hunt.shiro.authc.Account#getCredentials()
     */
     void setCredentials(Object credentials) {
        this.authcInfo.setCredentials(credentials);
    }

    /**
     * Returns the salt used to hash this Account's credentials (eg for password hashing), or {@code null} if no salt
     * was used or credentials were not hashed at all.
     *
     * @return the salt used to hash this Account's credentials (eg for password hashing), or {@code null} if no salt
     *         was used or credentials were not hashed at all.
     */
     ByteSource getCredentialsSalt() {
        return this.authcInfo.getCredentialsSalt();
    }

    /**
     * Sets the salt to use to hash this Account's credentials (eg for password hashing), or {@code null} if no salt
     * is used or credentials are not hashed at all.
     *
     * @param salt the salt to use to hash this Account's credentials (eg for password hashing), or {@code null} if no
     *             salt is used or credentials are not hashed at all.
     */
     void setCredentialsSalt(ByteSource salt) {
        this.authcInfo.setCredentialsSalt(salt);
    }

    /**
     * Returns <code>this.authzInfo.getRoles();</code>
     *
     * @return the Account's assigned roles.
     */
     Collection!(string) getRoles() {
        return authzInfo.getRoles();
    }

    /**
     * Sets the Account's assigned roles.  Simply calls <code>this.authzInfo.setRoles(roles)</code>.
     *
     * @param roles the Account's assigned roles.
     * @see Account#getRoles()
     */
     void setRoles(Set!(string) roles) {
        this.authzInfo.setRoles(roles);
    }

    /**
     * Adds a role to this Account's set of assigned roles.  Simply delegates to
     * <code>this.authzInfo.addRole(role)</code>.
     *
     * @param role a role to assign to this Account.
     */
     void addRole(string role) {
        this.authzInfo.addRole(role);
    }

    /**
     * Adds one or more roles to this Account's set of assigned roles. Simply delegates to
     * <code>this.authzInfo.addRoles(roles)</code>.
     *
     * @param roles one or more roles to assign to this Account.
     */
     void addRole(Collection!(string) roles) {
        this.authzInfo.addRoles(roles);
    }

    /**
     * Returns all string-based permissions assigned to this Account.  Simply delegates to
     * <code>this.authzInfo.getStringPermissions()</code>.
     *
     * @return all string-based permissions assigned to this Account.
     */
     Collection!(string) getStringPermissions() {
        return authzInfo.getStringPermissions();
    }

    /**
     * Sets the string-based permissions assigned to this Account.  Simply delegates to
     * <code>this.authzInfo.setStringPermissions(permissions)</code>.
     *
     * @param permissions all string-based permissions assigned to this Account.
     * @see hunt.shiro.authc.Account#getStringPermissions()
     */
     void setStringPermissions(Set!(string) permissions) {
        this.authzInfo.setStringPermissions(permissions);
    }

    /**
     * Assigns a string-based permission directly to this Account (not to any of its realms).
     *
     * @param permission the string-based permission to assign.
     */
     void addStringPermission(string permission) {
        this.authzInfo.addStringPermission(permission);
    }

    /**
     * Assigns one or more string-based permissions directly to this Account (not to any of its realms).
     *
     * @param permissions one or more string-based permissions to assign.
     */
     void addStringPermissions(Collection!(string) permissions) {
        this.authzInfo.addStringPermissions(permissions);
    }

    /**
     * Returns all object-based permissions assigned directly to this Account (not any of its realms).
     *
     * @return all object-based permissions assigned directly to this Account (not any of its realms).
     */
     Collection!(Permission) getObjectPermissions() {
        return authzInfo.getObjectPermissions();
    }

    /**
     * Sets all object-based permissions assigned directly to this Account (not any of its realms).
     *
     * @param permissions the object-based permissions to assign directly to this Account.
     */
     void setObjectPermissions(Set!(Permission) permissions) {
        this.authzInfo.setObjectPermissions(permissions);
    }

    /**
     * Assigns an object-based permission directly to this Account (not any of its realms).
     *
     * @param permission the object-based permission to assign directly to this Account (not any of its realms).
     */
     void addObjectPermission(Permission permission) {
        this.authzInfo.addObjectPermission(permission);
    }

    /**
     * Assigns one or more object-based permissions directly to this Account (not any of its realms).
     *
     * @param permissions one or more object-based permissions to assign directly to this Account (not any of its realms).
     */
     void addObjectPermissions(Collection!(Permission) permissions) {
        this.authzInfo.addObjectPermissions(permissions);
    }

    /**
     * Returns <code>true</code> if this Account is locked and thus cannot be used to login, <code>false</code> otherwise.
     *
     * @return <code>true</code> if this Account is locked and thus cannot be used to login, <code>false</code> otherwise.
     */
     bool isLocked() {
        return locked;
    }

    /**
     * Sets whether or not the account is locked and can be used to login.
     *
     * @param locked <code>true</code> if this Account is locked and thus cannot be used to login, <code>false</code> otherwise.
     */
     void setLocked(bool locked) {
        this.locked = locked;
    }

    /**
     * Returns whether or not the Account's credentials are expired.  This usually indicates that the Subject or an application
     * administrator would need to change the credentials before the account could be used.
     *
     * @return whether or not the Account's credentials are expired.
     */
     bool isCredentialsExpired() {
        return credentialsExpired;
    }

    /**
     * Sets whether or not the Account's credentials are expired.  A <code>true</code> value indicates that the Subject
     * or application administrator would need to change their credentials before the account could be used.
     *
     * @param credentialsExpired <code>true</code> if this Account's credentials are expired and need to be changed,
     *                           <code>false</code> otherwise.
     */
     void setCredentialsExpired(bool credentialsExpired) {
        this.credentialsExpired = credentialsExpired;
    }


    /**
     * Merges the specified <code>AuthenticationInfo</code> into this <code>Account</code>.
     * <p/>
     * If the specified argument is also an instance of {@link SimpleAccount SimpleAccount}, the
     * {@link #isLocked()} and {@link #isCredentialsExpired()} attributes are merged (set on this instance) as well
     * (only if their values are <code>true</code>).
     *
     * @param info the <code>AuthenticationInfo</code> to merge into this account.
     */
     void merge(AuthenticationInfo info) {
        authcInfo.merge(info);

        // Merge SimpleAccount specific info\
        SimpleAccount infoCast = cast(SimpleAccount)info;
        if (infoCast !is null) {
            SimpleAccount otherAccount = infoCast;
            if (otherAccount.isLocked()) {
                setLocked(true);
            }

            if (otherAccount.isCredentialsExpired()) {
                setCredentialsExpired(true);
            }
        }
    }

    /**
     * If the {@link #getPrincipals() principals} are not null, returns <code>principals.hashCode()</code>, otherwise
     * returns 0 (zero).
     *
     * @return <code>principals.hashCode()</code> if they are not null, 0 (zero) otherwise.
     */
    override size_t toHash() @trusted nothrow {
        PrincipalCollection pc = getPrincipals();
        return (pc !is null ? (cast(Object)pc).toHash() : 0);
    }

    /**
     * Returns <code>true</code> if the specified object is also a {@link SimpleAccount SimpleAccount} and its
     * {@link #getPrincipals() principals} are equal to this object's <code>principals</code>, <code>false</code> otherwise.
     *
     * @param o the object to test for equality.
     * @return <code>true</code> if the specified object is also a {@link SimpleAccount SimpleAccount} and its
     *         {@link #getPrincipals() principals} are equal to this object's <code>principals</code>, <code>false</code> otherwise.
     */
    override bool opEquals(Object o) {
        if (o == this) {
            return true;
        }
        auto oCast = cast(SimpleAccount)o;
        if (oCast !is null) {
            SimpleAccount sa = oCast;
            //principal should be unique across the application, so only check this for equality:
            return (getPrincipals() !is null ? getPrincipals() == sa.getPrincipals() : sa.getPrincipals()  is null);
        }
        return false;
    }

    /**
     * Returns {@link #getPrincipals() principals}.toString() if they are not null, otherwise prints out the string
     * &quot;empty&quot;
     *
     * @return the string representation of this Account object.
     */
    override string toString() {
        PrincipalCollection pc = getPrincipals();
        return pc !is null ? (cast(Object)pc).toString() : "empty";
    }

}