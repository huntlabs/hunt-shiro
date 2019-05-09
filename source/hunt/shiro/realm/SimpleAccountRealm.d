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
module hunt.shiro.realm.SimpleAccountRealm;

import hunt.shiro.realm.AuthorizingRealm;

import hunt.shiro.Exceptions;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.SimpleAccount;
import hunt.shiro.authc.UsernamePasswordToken;
import hunt.shiro.authz.AuthorizationInfo;
import hunt.shiro.authz.SimpleRole;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.util.CollectionUtils;

import hunt.collection.HashSet;
import hunt.collection.LinkedHashMap;
import hunt.collection.Map;
import hunt.collection.Set;
import hunt.Exceptions;

import core.sync.rwmutex;

import std.array;
import std.string;

/**
 * A simple implementation of the {@link Realm Realm} interface that
 * uses a set of configured user accounts and roles to support authentication and authorization.  Each account entry
 * specifies the username, password, and roles for a user.  Roles can also be mapped
 * to permissions and associated with users.
 * <p/>
 * User accounts and roles are stored in two {@code Map}s in memory, so it is expected that the total number of either
 * is not sufficiently large.
 *
 */
class SimpleAccountRealm : AuthorizingRealm {

    //TODO - complete JavaDoc
    protected Map!(string, SimpleAccount) users; //username-to-SimpleAccount
    protected Map!(string, SimpleRole) roles; //roleName-to-SimpleRole
    protected ReadWriteMutex USERS_LOCK;
    protected ReadWriteMutex ROLES_LOCK;

     this() {
        this.users = new LinkedHashMap!(string, SimpleAccount)();
        this.roles = new LinkedHashMap!(string, SimpleRole)();
        USERS_LOCK = new ReadWriteMutex();
        ROLES_LOCK = new ReadWriteMutex();
        //SimpleAccountRealms are memory-only realms - no need for an additional cache mechanism since we're
        //already as memory-efficient as we can be:
        setCachingEnabled(false);
    }

     this(string name) {
        this();
        setName(name);
    }

    protected SimpleAccount getUser(string username) {
        USERS_LOCK.reader().lock();
        try {
            return this.users.get(username);
        } finally {
            USERS_LOCK.reader().unlock();
        }
    }

     bool accountExists(string username) {
        return getUser(username) !is null;
    }

     void addAccount(string username, string password) {
        addAccount(username, password, cast(string[]) null);
    }

     void addAccount(string username, string password, string[] roles...) {
        // Set!(string) roleNames = CollectionUtils.asSet(roles);
        // SimpleAccount account = new SimpleAccount(username, password, getName(), roleNames, null);
        // add(account);
        implementationMissing(false);
    }

    protected string getUsername(SimpleAccount account) {
        return getUsername(account.getPrincipals());
    }

    protected string getUsername(PrincipalCollection principals) {
        return getAvailablePrincipal(principals).toString();
    }

    protected void add(SimpleAccount account) {
        string username = getUsername(account);
        USERS_LOCK.writer().lock();
        try {
            this.users.put(username, account);
        } finally {
            USERS_LOCK.writer().unlock();
        }
    }

    protected SimpleRole getRole(string rolename) {
        ROLES_LOCK.reader().lock();
        try {
            return roles.get(rolename);
        } finally {
            ROLES_LOCK.reader().unlock();
        }
    }

     bool roleExists(string name) {
        return getRole(name) !is null;
    }

     void addRole(string name) {
        add(new SimpleRole(name));
    }

    protected void add(SimpleRole role) {
        ROLES_LOCK.writer().lock();
        try {
            roles.put(role.getName(), role);
        } finally {
            ROLES_LOCK.writer().unlock();
        }
    }

    protected static Set!(string) toSet(string delimited, string delimiter) {
        if (delimited.empty) {
            return null;
        }

        Set!(string) values = new HashSet!(string)();
        string[] rolenamesArray = delimited.split(delimiter);
        foreach(string s ; rolenamesArray) {
            string trimmed = s.strip();
            if (trimmed.length > 0) {
                values.add(trimmed);
            }
        }

        return values;
    }

    override protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token){
        UsernamePasswordToken upToken = cast(UsernamePasswordToken) token;
        SimpleAccount account = getUser(upToken.getUsername());

        if (account !is null) {

            if (account.isLocked()) {
                throw new LockedAccountException("Account [" ~ account.toString() ~ "] is locked.");
            }
            if (account.isCredentialsExpired()) {
                string msg = "The credentials for account [" ~ account.toString() ~ "] are expired";
                throw new ExpiredCredentialsException(msg);
            }

        }

        return account;
    }

    override protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        string username = getUsername(principals);
        USERS_LOCK.reader().lock();
        try {
            return this.users.get(username);
        } finally {
            USERS_LOCK.reader().unlock();
        }
    }
}