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
module hunt.shiro.authz.ModularRealmAuthorizer;

import hunt.shiro.authz.Authorizer;
import hunt.shiro.authz.permission.Permission;
import hunt.shiro.authz.permission.PermissionResolver;
import hunt.shiro.authz.permission.PermissionResolverAware;
import hunt.shiro.authz.permission.RolePermissionResolver;
import hunt.shiro.authz.permission.RolePermissionResolverAware;
import hunt.shiro.Exceptions;
import hunt.shiro.realm.Realm;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.util.CollectionUtils;

import hunt.Exceptions;
import hunt.collection;
import hunt.logging;

import std.conv;
import std.string;
import core.atomic;
import std.range;


/**
 * A <tt>ModularRealmAuthorizer</tt> is an <tt>Authorizer</tt> implementation that consults one or more configured
 * {@link Realm Realm}s during an authorization operation.
 *
 */
class ModularRealmAuthorizer : Authorizer, PermissionResolverAware, RolePermissionResolverAware {

    /**
     * The realms to consult during any authorization check.
     */
    protected Realm[] realms;

    /**
     * A PermissionResolver to be used by <em>all</em> configured realms.  Leave <code>null</code> if you wish
     * to configure different resolvers for different realms.
     */
    protected PermissionResolver permissionResolver;

    /**
     * A RolePermissionResolver to be used by <em>all</em> configured realms.  Leave <code>null</code> if you wish
     * to configure different resolvers for different realms.
     */
    protected RolePermissionResolver rolePermissionResolver;

    /**
     * Default no-argument constructor, does nothing.
     */
    this() {
    }

    /**
     * Constructor that accepts the <code>Realm</code>s to consult during an authorization check.  Immediately calls
     * {@link #setRealms setRealms(realms)}.
     *
     * @param realms the realms to consult during an authorization check.
     */
    this(Realm[] realms) {
        setRealms(realms);
    }

    /**
     * Returns the realms wrapped by this <code>Authorizer</code> which are consulted during an authorization check.
     *
     * @return the realms wrapped by this <code>Authorizer</code> which are consulted during an authorization check.
     */
    Realm[] getRealms() {
        return this.realms;
    }

    /**
     * Sets the realms wrapped by this <code>Authorizer</code> which are consulted during an authorization check.
     *
     * @param realms the realms wrapped by this <code>Authorizer</code> which are consulted during an authorization check.
     */
    void setRealms(Realm[] realms) {
        this.realms = realms;
        applyPermissionResolverToRealms();
        applyRolePermissionResolverToRealms();
    }

    /**
     * Returns the PermissionResolver to be used on <em>all</em> configured realms, or <code>null</code (the default)
     * if all realm instances will each configure their own permission resolver.
     *
     * @return the PermissionResolver to be used on <em>all</em> configured realms, or <code>null</code (the default)
     *         if realm instances will each configure their own permission resolver.
     */
    PermissionResolver getPermissionResolver() {
        return this.permissionResolver;
    }

    /**
     * Sets the specified {@link PermissionResolver PermissionResolver} on <em>all</em> of the wrapped realms that
     * implement the {@link hunt.shiro.authz.permission.PermissionResolverAware PermissionResolverAware} interface.
     * <p/>
     * Only call this method if you want the permission resolver to be passed to all realms that implement the
     * <code>PermissionResolver</code> interface.  If you do not want this to occur, the realms must
     * configure themselves individually (or be configured individually).
     *
     * @param permissionResolver the permissionResolver to set on all of the wrapped realms that implement the
     *                           {@link hunt.shiro.authz.permission.PermissionResolverAware PermissionResolverAware} interface.
     */
    void setPermissionResolver(PermissionResolver permissionResolver) {
        this.permissionResolver = permissionResolver;
        applyPermissionResolverToRealms();
    }

    /**
     * Sets the internal {@link #getPermissionResolver} on any internal configured
     * {@link #getRealms Realms} that implement the {@link hunt.shiro.authz.permission.PermissionResolverAware PermissionResolverAware} interface.
     * <p/>
     * This method is called after setting a permissionResolver on this ModularRealmAuthorizer via the
     * {@link #setPermissionResolver(hunt.shiro.authz.permission.PermissionResolver) setPermissionResolver} method.
     * <p/>
     * It is also called after setting one or more realms via the {@link #setRealms setRealms} method to allow these
     * newly available realms to be given the <code>PermissionResolver</code> already in use.
     *
     */
    protected void applyPermissionResolverToRealms() {
        PermissionResolver resolver = getPermissionResolver();
        Realm[] realms = getRealms();
        if (resolver !is null && !realms.empty()) {
            foreach (Realm realm; realms) {
                auto realmCast = cast(PermissionResolverAware) realm;
                if (realmCast !is null) {
                    realmCast.setPermissionResolver(resolver);
                }
            }
        }
    }

    /**
     * Returns the RolePermissionResolver to be used on <em>all</em> configured realms, or <code>null</code (the default)
     * if all realm instances will each configure their own permission resolver.
     *
     * @return the RolePermissionResolver to be used on <em>all</em> configured realms, or <code>null</code (the default)
     *         if realm instances will each configure their own role permission resolver.
     */
    RolePermissionResolver getRolePermissionResolver() {
        return this.rolePermissionResolver;
    }

    /**
     * Sets the specified {@link RolePermissionResolver RolePermissionResolver} on <em>all</em> of the wrapped realms that
     * implement the {@link hunt.shiro.authz.permission.RolePermissionResolverAware PermissionResolverAware} interface.
     * <p/>
     * Only call this method if you want the permission resolver to be passed to all realms that implement the
     * <code>RolePermissionResolver</code> interface.  If you do not want this to occur, the realms must
     * configure themselves individually (or be configured individually).
     *
     * @param rolePermissionResolver the rolePermissionResolver to set on all of the wrapped realms that implement the
     *                               {@link hunt.shiro.authz.permission.RolePermissionResolverAware RolePermissionResolverAware} interface.
     */
    void setRolePermissionResolver(RolePermissionResolver rolePermissionResolver) {
        this.rolePermissionResolver = rolePermissionResolver;
        applyRolePermissionResolverToRealms();
    }

    /**
     * Sets the internal {@link #getRolePermissionResolver} on any internal configured
     * {@link #getRealms Realms} that implement the {@link hunt.shiro.authz.permission.RolePermissionResolverAware RolePermissionResolverAware} interface.
     * <p/>
     * This method is called after setting a rolePermissionResolver on this ModularRealmAuthorizer via the
     * {@link #setRolePermissionResolver(hunt.shiro.authz.permission.RolePermissionResolver) setRolePermissionResolver} method.
     * <p/>
     * It is also called after setting one or more realms via the {@link #setRealms setRealms} method to allow these
     * newly available realms to be given the <code>RolePermissionResolver</code> already in use.
     *
     */
    protected void applyRolePermissionResolverToRealms() {
        RolePermissionResolver resolver = getRolePermissionResolver();
        Realm[] realms = getRealms();
        if (resolver !is null && realms.empty()) {
            foreach (Realm realm; realms) {
                auto realmCast = cast(RolePermissionResolverAware) realm;
                if (realmCast !is null) {
                    realmCast.setRolePermissionResolver(resolver);
                }
            }
        }
    }

    /**
     * Used by the {@link Authorizer Authorizer} implementation methods to ensure that the {@link #setRealms realms}
     * has been set.  The default implementation ensures the property is not null and not empty.
     *
     * @throws IllegalStateException if the <tt>realms</tt> property is configured incorrectly.
     */
    protected void assertRealmsConfigured() {
        Realm[] realms = getRealms();
        if (realms.empty()) {
            string msg = "Configuration error:  No realms have been configured!  One or more realms must be "
                ~ "present to execute an authorization operation.";
            throw new IllegalStateException(msg);
        }
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermitted(hunt.shiro.subject.PrincipalCollection, string)} returns <code>true</code>,
     * <code>false</code> otherwise.
     */
    bool isPermitted(PrincipalCollection principals, string permission) {
        assertRealmsConfigured();
        foreach (Realm realm; getRealms()) {
            auto realmCast = cast(Authorizer) realm;
            if (realmCast is null)
                continue;
            if (realmCast.isPermitted(principals, permission)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermitted(hunt.shiro.subject.PrincipalCollection, Permission)} call returns <code>true</code>,
     * <code>false</code> otherwise.
     */
    bool isPermitted(PrincipalCollection principals, Permission permission) {
        assertRealmsConfigured();
        foreach (Realm realm; getRealms()) {
            auto realmCast = cast(Authorizer) realm;
            if (realmCast is null)
                continue;
            if (realmCast.isPermitted(principals, permission)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermittedAll(hunt.shiro.subject.PrincipalCollection, string...)} call returns
     * <code>true</code>, <code>false</code> otherwise.
     */
    bool[] isPermitted(PrincipalCollection principals, string[] permissions...) {
        assertRealmsConfigured();
        if (permissions !is null && permissions.length > 0) {
            bool[] r = new bool[permissions.length];
            for (int i = 0; i < permissions.length; i++) {
                r[i] = isPermitted(principals, permissions[i]);
            }
            return r;
        }
        return new bool[0];
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermitted(hunt.shiro.subject.PrincipalCollection, List)} call returns <code>true</code>,
     * <code>false</code> otherwise.
     */
    bool[] isPermitted(PrincipalCollection principals, List!(Permission) permissions) {
        assertRealmsConfigured();
        if (permissions !is null && !permissions.isEmpty()) {
            bool[] r = new bool[permissions.size()];
            int i = 0;
            foreach (Permission p; permissions) {
                r[i++] = isPermitted(principals, p);
            }
            return r;
        }

        return new bool[0];
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermitted(hunt.shiro.subject.PrincipalCollection, string)} call returns <code>true</code>
     * for <em>all</em> of the specified string permissions, <code>false</code> otherwise.
     */
    bool isPermittedAll(PrincipalCollection principals, string[] permissions...) {
        assertRealmsConfigured();
        if (permissions !is null && permissions.length > 0) {
            foreach (string perm; permissions) {
                if (!isPermitted(principals, perm)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #isPermitted(hunt.shiro.subject.PrincipalCollection, Permission)} call returns <code>true</code>
     * for <em>all</em> of the specified Permissions, <code>false</code> otherwise.
     */
    bool isPermittedAll(PrincipalCollection principals, Collection!(Permission) permissions) {
        assertRealmsConfigured();
        if (permissions !is null && !permissions.isEmpty()) {
            foreach (Permission permission; permissions) {
                if (!isPermitted(principals, permission)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * If !{@link #isPermitted(hunt.shiro.subject.PrincipalCollection, string) isPermitted(permission)}, throws
     * an <code>UnauthorizedException</code> otherwise returns quietly.
     */
    void checkPermission(PrincipalCollection principals, string permission) {
        assertRealmsConfigured();
        if (!isPermitted(principals, permission)) {
            throw new UnauthorizedException("Subject does not have permission [" ~ permission ~ "]");
        }
    }

    /**
     * If !{@link #isPermitted(hunt.shiro.subject.PrincipalCollection, Permission) isPermitted(permission)}, throws
     * an <code>UnauthorizedException</code> otherwise returns quietly.
     */
    void checkPermission(PrincipalCollection principals, Permission permission) {
        assertRealmsConfigured();
        if (!isPermitted(principals, permission)) {
            throw new UnauthorizedException("Subject does not have permission [" ~ (cast(Object) permission)
                    .toString() ~ "]");
        }
    }

    /**
     * If !{@link #isPermitted(hunt.shiro.subject.PrincipalCollection, string...) isPermitted(permission)},
     *<code>UnauthorizedException</code> otherwise returns quietly.
     */
    void checkPermissions(PrincipalCollection principals, string[] permissions...) {
        assertRealmsConfigured();
        if (permissions !is null && permissions.length > 0) {
            foreach (string perm; permissions) {
                checkPermission(principals, perm);
            }
        }
    }

    /**
     * If !{@link #isPermitted(hunt.shiro.subject.PrincipalCollection, Permission) isPermitted(permission)} for
     * <em>all</em> the given Permissions, throws
     * an <code>UnauthorizedException</code> otherwise returns quietly.
     */
    void checkPermissions(PrincipalCollection principals, Collection!(Permission) permissions) {
        assertRealmsConfigured();
        if (permissions !is null) {
            foreach (Permission permission; permissions) {
                checkPermission(principals, permission);
            }
        }
    }

    /**
     * Returns <code>true</code> if any of the configured realms'
     * {@link #hasRole(hunt.shiro.subject.PrincipalCollection, string)} call returns <code>true</code>,
     * <code>false</code> otherwise.
     */
    bool hasRole(PrincipalCollection principals, string roleIdentifier) {
        assertRealmsConfigured();
        foreach (Realm realm; getRealms()) {
            Authorizer realmCast = cast(Authorizer) realm;
            if (realmCast is null)
                continue;
            if (realmCast.hasRole(principals, roleIdentifier)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Calls {@link #hasRole(hunt.shiro.subject.PrincipalCollection, string)} for each role name in the specified
     * collection and places the return value from each call at the respective location in the returned array.
     */
    bool[] hasRoles(PrincipalCollection principals, List!(string) roleIdentifiers) {
        if (roleIdentifiers is null || roleIdentifiers.isEmpty()) {
            assertRealmsConfigured();
            return new bool[0];
        }

        return hasRoles(principals, roleIdentifiers.toArray());

    }

    /// ditto
    bool[] hasRoles(PrincipalCollection principals, string[] roleIdentifiers) {
        assertRealmsConfigured();

        if (roleIdentifiers.empty) {
            return new bool[0];
        }

        bool[] hasRoles = new bool[roleIdentifiers.length];
        int i = 0;
        foreach (string roleId; roleIdentifiers) {
            hasRoles[i++] = hasRole(principals, roleId);
        }
        return hasRoles;
    }

    /**
     * Returns <code>true</code> iff any of the configured realms'
     * {@link #hasRole(hunt.shiro.subject.PrincipalCollection, string)} call returns <code>true</code> for
     * <em>all</em> roles specified, <code>false</code> otherwise.
     */
    bool hasAllRoles(PrincipalCollection principals, Collection!(string) roleIdentifiers) {
        return hasAllRoles(principals, roleIdentifiers.toArray());
    }

    bool hasAllRoles(PrincipalCollection principals, string[] roleIdentifiers) {
        assertRealmsConfigured();
        foreach (string roleIdentifier; roleIdentifiers) {
            if (!hasRole(principals, roleIdentifier)) {
                return false;
            }
        }
        return true;
    }

    /**
     * If !{@link #hasRole(hunt.shiro.subject.PrincipalCollection, string) hasRole(role)}, throws
     * an <code>UnauthorizedException</code> otherwise returns quietly.
     */
    void checkRole(PrincipalCollection principals, string role) {
        assertRealmsConfigured();
        if (!hasRole(principals, role)) {
            throw new UnauthorizedException("Subject does not have role [" ~ role ~ "]");
        }
    }

    /**
     * Calls {@link #checkRoles(PrincipalCollection principals, string... roles) checkRoles(PrincipalCollection principals, string... roles) }.
     */
    void checkRoles(PrincipalCollection principals, Collection!(string) roles) {
        //SHIRO-234 - roles.toArray() -> roles.toArray(new string[roles.size()])
        if (roles !is null && !roles.isEmpty()) {
            checkRoles(principals, roles.toArray());
        }
    }

    /**
     * Calls {@link #checkRole(hunt.shiro.subject.PrincipalCollection, string) checkRole} for each role specified.
     */
    void checkRoles(PrincipalCollection principals, string[] roles...) {
        assertRealmsConfigured();
        if (roles !is null) {
            foreach (string role; roles) {
                checkRole(principals, role);
            }
        }
    }
}
