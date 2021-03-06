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
module hunt.shiro.authc.SimpleAuthenticationInfo;

import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.MergableAuthenticationInfo;
import hunt.shiro.authc.SaltedAuthenticationInfo;
import hunt.shiro.subject.MutablePrincipalCollection;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.SimplePrincipalCollection;
import hunt.shiro.util.ByteSource;


import hunt.collection;
import hunt.collection.HashSet;
import hunt.collection.Set;


/**
 * Simple implementation of the {@link hunt.shiro.authc.MergableAuthenticationInfo} interface that holds the principals and
 * credentials.
 *
 * @see hunt.shiro.realm.AuthenticatingRealm
 */
class SimpleAuthenticationInfo : MergableAuthenticationInfo, SaltedAuthenticationInfo {

    /**
     * The principals identifying the account associated with this AuthenticationInfo instance.
     */
    protected PrincipalCollection principals;
    
    /**
     * The credentials verifying the account principals.
     */
    protected Object credentials;

    /**
     * Any salt used in hashing the credentials.
     *
     */
    protected ByteSource credentialsSalt;

    /**
     * Default no-argument constructor.
     */
    this() {
    }

    /**
     * Constructor that takes in a single 'primary' principal of the account and its corresponding credentials,
     * associated with the specified realm.
     * <p/>
     * This is a convenience constructor and will construct a {@link PrincipalCollection PrincipalCollection} based
     * on the {@code principal} and {@code realmName} argument.
     *
     * @param principal   the 'primary' principal associated with the specified realm.
     * @param credentials the credentials that verify the given principal.
     * @param realmName   the realm from where the principal and credentials were acquired.
     */
     this(Object principal, Object credentials, string realmName) {
        this.principals = new SimplePrincipalCollection(principal, realmName);
        this.credentials = credentials;
    }

    /**
     * Constructor that takes in a single 'primary' principal of the account, its corresponding hashed credentials,
     * the salt used to hash the credentials, and the name of the realm to associate with the principals.
     * <p/>
     * This is a convenience constructor and will construct a {@link PrincipalCollection PrincipalCollection} based
     * on the <code>principal</code> and <code>realmName</code> argument.
     *
     * @param principal         the 'primary' principal associated with the specified realm.
     * @param hashedCredentials the hashed credentials that verify the given principal.
     * @param credentialsSalt   the salt used when hashing the given hashedCredentials
     * @param realmName         the realm from where the principal and credentials were acquired.
     * @see hunt.shiro.authc.credential.HashedCredentialsMatcher HashedCredentialsMatcher
     */
     this(Object principal, Object hashedCredentials, ByteSource credentialsSalt, string realmName) {
        this.principals = new SimplePrincipalCollection(principal, realmName);
        this.credentials = hashedCredentials;
        this.credentialsSalt = credentialsSalt;
    }

    /**
     * Constructor that takes in an account's identifying principal(s) and its corresponding credentials that verify
     * the principals.
     *
     * @param principals  a Realm's account's identifying principal(s)
     * @param credentials the accounts corresponding principals that verify the principals.
     */
     this(PrincipalCollection principals, Object credentials) {
        this.principals = new SimplePrincipalCollection(principals);
        this.credentials = credentials;
    }

    /**
     * Constructor that takes in an account's identifying principal(s), hashed credentials used to verify the
     * principals, and the salt used when hashing the credentials.
     *
     * @param principals        a Realm's account's identifying principal(s)
     * @param hashedCredentials the hashed credentials that verify the principals.
     * @param credentialsSalt   the salt used when hashing the hashedCredentials.
     * @see hunt.shiro.authc.credential.HashedCredentialsMatcher HashedCredentialsMatcher
     */
     this(PrincipalCollection principals, Object hashedCredentials, ByteSource credentialsSalt) {
        this.principals = new SimplePrincipalCollection(principals);
        this.credentials = hashedCredentials;
        this.credentialsSalt = credentialsSalt;
    }


    PrincipalCollection getPrincipals() @trusted nothrow {
        return principals;
    }

    /**
     * Sets the identifying principal(s) represented by this instance.
     *
     * @param principals the indentifying attributes of the corresponding Realm account.
     */
     void setPrincipals(PrincipalCollection principals) {
        this.principals = principals;
    }

     Object getCredentials() {
        return credentials;
    }

    /**
     * Sets the credentials that verify the principals/identity of the associated Realm account.
     *
     * @param credentials attribute(s) that verify the account's identity/principals, such as a password or private key.
     */
     void setCredentials(Object credentials) {
        this.credentials = credentials;
    }

    /**
     * Returns the salt used to hash the credentials, or {@code null} if no salt was used or credentials were not
     * hashed at all.
     * <p/>
     * Note that this attribute is <em>NOT</em> handled in the
     * {@link #merge(AuthenticationInfo) merge} method - a hash salt is only useful within a single realm (as each
     * realm will perform it's own Credentials Matching logic), and once finished in that realm, Shiro has no further
     * use for salts.  Therefore it doesn't make sense to 'merge' salts in a multi-realm scenario.
     *
     * @return the salt used to hash the credentials, or {@code null} if no salt was used or credentials were not
     *         hashed at all.
     */
     ByteSource getCredentialsSalt() {
        return credentialsSalt;
    }

    /**
     * Sets the salt used to hash the credentials, or {@code null} if no salt was used or credentials were not
     * hashed at all.
     * <p/>
     * Note that this attribute is <em>NOT</em> handled in the
     * {@link #merge(AuthenticationInfo) merge} method - a hash salt is only useful within a single realm (as each
     * realm will perform it's own Credentials Matching logic), and once finished in that realm, Shiro has no further
     * use for salts.  Therefore it doesn't make sense to 'merge' salts in a multi-realm scenario.
     *
     * @param salt the salt used to hash the credentials, or {@code null} if no salt was used or credentials were not
     *             hashed at all.
     */
     void setCredentialsSalt(ByteSource salt) {
        this.credentialsSalt = salt;
    }

    /**
     * Takes the specified <code>info</code> argument and adds its principals and credentials into this instance.
     *
     * @param info the <code>AuthenticationInfo</code> to add into this instance.
     */

     void merge(AuthenticationInfo info) {
        if (info  is null || info.getPrincipals()  is null || info.getPrincipals().isEmpty()) {
            return;
        }

        if (this.principals  is null) {
            this.principals = info.getPrincipals();
        } else {
            auto principalsCast = cast(MutablePrincipalCollection)this.principals;
            if (principalsCast is null) {
                this.principals = new SimplePrincipalCollection(this.principals);
            }
            principalsCast.addAll(info.getPrincipals());
        }

        //only mess with a salt value if we don't have one yet.  It doesn't make sense
        //to merge salt values from different realms because a salt is used only within
        //the realm's credential matching process.  But if the current instance's salt
        //is null, then it can't hurt to pull in a non-null value if one exists.
        //
        //since 1.1:
        auto infoCast = cast(SaltedAuthenticationInfo)info;
        if (this.credentialsSalt  is null && infoCast !is null) {
            this.credentialsSalt = infoCast.getCredentialsSalt();
        }

        Object thisCredentials = getCredentials();
        Object otherCredentials = info.getCredentials();

        if (otherCredentials  is null) {
            return;
        }

        if (thisCredentials  is null) {
            this.credentials = otherCredentials;
            return;
        }
        auto thisCredentialsCast = cast(Collection!Object) thisCredentials;
        if (thisCredentialsCast is null) {
            Set!Object newSet = new HashSet!Object();
            newSet.add(thisCredentials);
            setCredentials(cast(Object)newSet);
        }

        // At this point, the credentials should be a collection
        Collection!Object credentialCollection = cast(Collection!Object)getCredentials();
        auto otherCredentialsCast = cast(Collection!Object)otherCredentials;
        if (otherCredentialsCast !is null) {
            credentialCollection.addAll(otherCredentialsCast);
        } else {
            credentialCollection.add(otherCredentials);
        }
    }

    /**
     * Returns <code>true</code> if the Object argument is an <code>instanceof SimpleAuthenticationInfo</code> and
     * its {@link #getPrincipals() principals} are equal to this instance's principals, <code>false</code> otherwise.
     *
     * @param o the object to compare for equality.
     * @return <code>true</code> if the Object argument is an <code>instanceof SimpleAuthenticationInfo</code> and
     *         its {@link #getPrincipals() principals} are equal to this instance's principals, <code>false</code> otherwise.
     */
    override bool opEquals(Object o) {
        if (this == o) return true;
        auto oCast = cast(SimpleAuthenticationInfo)o;
        if (oCast is null) return false;

        SimpleAuthenticationInfo that = oCast;

        //noinspection RedundantIfStatement
        if (principals !is null ? principals != that.principals : that.principals !is null) return false;

        return true;
    }

    /**
     * Returns the hashcode of the internal {@link #getPrincipals() principals} instance.
     *
     * @return the hashcode of the internal {@link #getPrincipals() principals} instance.
     */
    override size_t toHash() @trusted nothrow {
        return (principals !is null ? (cast(Object)principals).toHash() : 0);
    }

    /**
     * Simple implementation that merely returns <code>{@link #getPrincipals() principals}.toString()</code>
     *
     * @return <code>{@link #getPrincipals() principals}.toString()</code>
     */
    override string toString() {
        return (cast(Object) principals).toString();
    }

}
