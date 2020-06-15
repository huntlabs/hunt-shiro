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
module hunt.shiro.authz.SimpleAuthorizationInfo;

import hunt.shiro.authz.AuthorizationInfo;
import hunt.shiro.authz.permission.Permission;

import hunt.collection;

/**
 * Simple POJO implementation of the {@link AuthorizationInfo} interface that stores roles and permissions as internal
 * attributes.
 *
 * @see hunt.shiro.realm.AuthorizingRealm
 */
class SimpleAuthorizationInfo : AuthorizationInfo {

    /**
     * The internal roles collection.
     */
    protected Set!(string) roles;

    /**
     * Collection of all string-based permissions associated with the account.
     */
    protected Set!(string) stringPermissions;

    /**
     * Collection of all object-based permissions associated with the account.
     */
    protected Set!(Permission) objectPermissions;

    /**
     * Default no-argument constructor.
     */
    this() {
    }

    /**
     * Creates a new instance with the specified roles and no permissions.
     * @param roles the roles assigned to the realm account.
     */
     this(Set!(string) roles) {
        this.roles = roles;
    }

    Set!(string) getRoles() {
        return roles;
    }

    /**
     * Sets the roles assigned to the account.
     * @param roles the roles assigned to the account.
     */
    void setRoles(Set!(string) roles) {
        this.roles = roles;
    }

    /**
     * Adds (assigns) a role to those associated with the account.  If the account doesn't yet have any roles, a
     * new roles collection (a Set) will be created automatically.
     * @param role the role to add to those associated with the account.
     */
     void addRole(string role) {
        if (this.roles  is null) {
            this.roles = new HashSet!(string)();
        }
        this.roles.add(role);
    }

    /**
     * Adds (assigns) multiple roles to those associated with the account.  If the account doesn't yet have any roles, a
     * new roles collection (a Set) will be created automatically.
     * @param roles the roles to add to those associated with the account.
     */
     void addRoles(Collection!(string) roles) {
        if (this.roles  is null) {
            this.roles = new HashSet!(string)();
        }
        this.roles.addAll(roles);
    }

    void addRoles(string[] roles) {
        if (this.roles  is null) {
            this.roles = new HashSet!(string)();
        }
        this.roles.addAll(roles);
    }

     Set!(string) getStringPermissions() {
        return stringPermissions;
    }

    /**
     * Sets the string-based permissions assigned directly to the account.  The permissions set here, in addition to any
     * {@link #getObjectPermissions() object permissions} constitute the total permissions assigned directly to the
     * account.
     *
     * @param stringPermissions the string-based permissions assigned directly to the account.
     */
     void setStringPermissions(Set!(string) stringPermissions) {
        this.stringPermissions = stringPermissions;
    }

    /**
     * Adds (assigns) a permission to those directly associated with the account.  If the account doesn't yet have any
     * direct permissions, a new permission collection (a Set&lt;string&gt;) will be created automatically.
     * @param permission the permission to add to those directly assigned to the account.
     */
     void addStringPermission(string permission) {
        if (this.stringPermissions  is null) {
            this.stringPermissions = new HashSet!(string)();
        }
        this.stringPermissions.add(permission);
    }

    /**
     * Adds (assigns) multiple permissions to those associated directly with the account.  If the account doesn't yet
     * have any string-based permissions, a  new permissions collection (a Set&lt;string&gt;) will be created automatically.
     * @param permissions the permissions to add to those associated directly with the account.
     */
     void addStringPermissions(Collection!(string) permissions) {
        if (this.stringPermissions  is null) {
            this.stringPermissions = new HashSet!(string)();
        }
        this.stringPermissions.addAll(permissions);
    }

    void addStringPermissions(string[] permissions) {
        if (this.stringPermissions  is null) {
            this.stringPermissions = new HashSet!(string)();
        }
        this.stringPermissions.addAll(permissions);
    }

     Set!(Permission) getObjectPermissions() {
        return objectPermissions;
    }

    /**
     * Sets the object-based permissions assigned directly to the account.  The permissions set here, in addition to any
     * {@link #getStringPermissions() string permissions} constitute the total permissions assigned directly to the
     * account.
     *
     * @param objectPermissions the object-based permissions assigned directly to the account.
     */
     void setObjectPermissions(Set!(Permission) objectPermissions) {
        this.objectPermissions = objectPermissions;
    }

    /**
     * Adds (assigns) a permission to those directly associated with the account.  If the account doesn't yet have any
     * direct permissions, a new permission collection (a Set&lt;{@link Permission Permission}&gt;) will be created automatically.
     * @param permission the permission to add to those directly assigned to the account.
     */
     void addObjectPermission(Permission permission) {
        if (this.objectPermissions  is null) {
            this.objectPermissions = new HashSet!(Permission)();
        }
        this.objectPermissions.add(permission);
    }

    /**
     * Adds (assigns) multiple permissions to those associated directly with the account.  If the account doesn't yet
     * have any object-based permissions, a  new permissions collection (a Set&lt;{@link Permission Permission}&gt;)
     * will be created automatically.
     * @param permissions the permissions to add to those associated directly with the account.
     */
     void addObjectPermissions(Collection!(Permission) permissions) {
        if (this.objectPermissions  is null) {
            this.objectPermissions = new HashSet!(Permission)();
        }
        this.objectPermissions.addAll(permissions);
    }
}
