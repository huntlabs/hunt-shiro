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
module hunt.shiro.authz.Authorizer;

import hunt.shiro.subject.PrincipalCollection;

import hunt.collection;
import java.util.List;

/**
 * An <tt>Authorizer</tt> performs authorization (access control) operations for any given Subject
 * (aka 'application user').
 *
 * <p>Each method requires a subject principal to perform the action for the corresponding Subject/user.
 *
 * <p>This principal argument is usually an object representing a user database primary key or a string username or
 * something similar that uniquely identifies an application user.  The runtime value of the this principal
 * is application-specific and provided by the application's configured Realms.
 *
 * <p>Note that there are many *Permission methods in this interface overloaded to accept string arguments instead of
 * {@link Permission Permission} instances. They are a convenience allowing the caller to use a string representation of
 * a {@link Permission Permission} if desired.  Most implementations of this interface will simply convert these
 * string values to {@link Permission Permission} instances and then just call the corresponding type-safe method.
 * (Shiro's default implementations do string-to-Permission conversion for these methods using
 * {@link hunt.shiro.authz.permission.PermissionResolver PermissionResolver}s.)
 *
 * <p>These overloaded *Permission methods <em>do</em> forego type-safety for the benefit of convenience and simplicity,
 * so you should choose which ones to use based on your preferences and needs.
 *
 * @since 0.1
 */
interface Authorizer {

    /**
     * Returns <tt>true</tt> if the corresponding subject/user is permitted to perform an action or access a resource
     * summarized by the specified permission string.
     *
     * <p>This is an overloaded method for the corresponding type-safe {@link Permission Permission} variant.
     * Please see the class-level JavaDoc for more information on these string-based permission methods.
     *
     * @param principals the application-specific subject/user identifier.
     * @param permission the string representation of a Permission that is being checked.
     * @return true if the corresponding Subject/user is permitted, false otherwise.
     * @see #isPermitted(PrincipalCollection principals,Permission permission)
     * @since 0.9
     */
    bool isPermitted(PrincipalCollection principals, string permission);

    /**
     * Returns <tt>true</tt> if the corresponding subject/user is permitted to perform an action or access a resource
     * summarized by the specified permission.
     *
     * <p>More specifically, this method determines if any <tt>Permission</tt>s associated
     * with the subject {@link Permission#implies(Permission) imply} the specified permission.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permission       the permission that is being checked.
     * @return true if the corresponding Subject/user is permitted, false otherwise.
     */
    bool isPermitted(PrincipalCollection subjectPrincipal, Permission permission);

    /**
     * Checks if the corresponding Subject implies the given permission strings and returns a bool array
     * indicating which permissions are implied.
     *
     * <p>This is an overloaded method for the corresponding type-safe {@link Permission Permission} variant.
     * Please see the class-level JavaDoc for more information on these string-based permission methods.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the string representations of the Permissions that are being checked.
     * @return an array of bools whose indices correspond to the index of the
     *         permissions in the given list.  A true value at an index indicates the user is permitted for
     *         for the associated <tt>Permission</tt> string in the list.  A false value at an index
     *         indicates otherwise.
     * @since 0.9
     */
    bool[] isPermitted(PrincipalCollection subjectPrincipal, string[] permissions...);

    /**
     * Checks if the corresponding Subject/user implies the given Permissions and returns a bool array indicating
     * which permissions are implied.
     *
     * <p>More specifically, this method should determine if each <tt>Permission</tt> in
     * the array is {@link Permission#implies(Permission) implied} by permissions
     * already associated with the subject.
     *
     * <p>This is primarily a performance-enhancing method to help reduce the number of
     * {@link #isPermitted} invocations over the wire in client/server systems.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the permissions that are being checked.
     * @return an array of bools whose indices correspond to the index of the
     *         permissions in the given list.  A true value at an index indicates the user is permitted for
     *         for the associated <tt>Permission</tt> object in the list.  A false value at an index
     *         indicates otherwise.
     */
    bool[] isPermitted(PrincipalCollection subjectPrincipal, List!(Permission) permissions);

    /**
     * Returns <tt>true</tt> if the corresponding Subject/user implies all of the specified permission strings,
     * <tt>false</tt> otherwise.
     *
     * <p>This is an overloaded method for the corresponding type-safe {@link Permission Permission} variant.
     * Please see the class-level JavaDoc for more information on these string-based permission methods.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the string representations of the Permissions that are being checked.
     * @return true if the user has all of the specified permissions, false otherwise.
     * @see #isPermittedAll(PrincipalCollection,Collection)
     * @since 0.9
     */
    bool isPermittedAll(PrincipalCollection subjectPrincipal, string[] permissions...);

    /**
     * Returns <tt>true</tt> if the corresponding Subject/user implies all of the specified permissions, <tt>false</tt>
     * otherwise.
     *
     * <p>More specifically, this method determines if all of the given <tt>Permission</tt>s are
     * {@link Permission#implies(Permission) implied by} permissions already associated with the subject.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the permissions to check.
     * @return true if the user has all of the specified permissions, false otherwise.
     */
    bool isPermittedAll(PrincipalCollection subjectPrincipal, Collection!(Permission) permissions);

    /**
     * Ensures the corresponding Subject/user implies the specified permission string.
     *
     * <p>If the subject's existing associated permissions do not {@link Permission#implies(Permission)} imply}
     * the given permission, an {@link AuthorizationException} will be thrown.
     *
     * <p>This is an overloaded method for the corresponding type-safe {@link Permission Permission} variant.
     * Please see the class-level JavaDoc for more information on these string-based permission methods.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permission       the string representation of the Permission to check.
     * @throws AuthorizationException
     *          if the user does not have the permission.
     * @since 0.9
     */
    void checkPermission(PrincipalCollection subjectPrincipal, string permission);

    /**
     * Ensures a subject/user {@link Permission#implies(Permission)} implies} the specified <tt>Permission</tt>.
     * If the subject's existing associated permissions do not {@link Permission#implies(Permission)} imply}
     * the given permission, an {@link AuthorizationException} will be thrown.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permission       the Permission to check.
     * @throws AuthorizationException
     *          if the user does not have the permission.
     */
    void checkPermission(PrincipalCollection subjectPrincipal, Permission permission);

    /**
     * Ensures the corresponding Subject/user
     * {@link Permission#implies(Permission) implies} all of the
     * specified permission strings.
     *
     * If the subject's existing associated permissions do not
     * {@link Permission#implies(Permission) imply} all of the given permissions,
     * an {@link AuthorizationException} will be thrown.
     *
     * <p>This is an overloaded method for the corresponding type-safe {@link Permission Permission} variant.
     * Please see the class-level JavaDoc for more information on these string-based permission methods.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the string representations of Permissions to check.
     * @throws AuthorizationException if the user does not have all of the given permissions.
     * @since 0.9
     */
    void checkPermissions(PrincipalCollection subjectPrincipal, string[] permissions...);

    /**
     * Ensures the corresponding Subject/user
     * {@link Permission#implies(Permission) implies} all of the
     * specified permission strings.
     *
     * If the subject's existing associated permissions do not
     * {@link Permission#implies(Permission) imply} all of the given permissions,
     * an {@link AuthorizationException} will be thrown.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param permissions      the Permissions to check.
     * @throws AuthorizationException if the user does not have all of the given permissions.
     */
    void checkPermissions(PrincipalCollection subjectPrincipal, Collection!(Permission) permissions);

    /**
     * Returns <tt>true</tt> if the corresponding Subject/user has the specified role, <tt>false</tt> otherwise.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifier   the application-specific role identifier (usually a role id or role name).
     * @return <tt>true</tt> if the corresponding subject has the specified role, <tt>false</tt> otherwise.
     */
    bool hasRole(PrincipalCollection subjectPrincipal, string roleIdentifier);

    /**
     * Checks if the corresponding Subject/user has the specified roles, returning a bool array indicating
     * which roles are associated with the given subject.
     *
     * <p>This is primarily a performance-enhancing method to help reduce the number of
     * {@link #hasRole} invocations over the wire in client/server systems.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifiers  the application-specific role identifiers to check (usually role ids or role names).
     * @return an array of bools whose indices correspond to the index of the
     *         roles in the given identifiers.  A true value indicates the user has the
     *         role at that index.  False indicates the user does not have the role at that index.
     */
    bool[] hasRoles(PrincipalCollection subjectPrincipal, List!(string) roleIdentifiers);

    /**
     * Returns <tt>true</tt> if the corresponding Subject/user has all of the specified roles, <tt>false</tt> otherwise.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifiers  the application-specific role identifiers to check (usually role ids or role names).
     * @return true if the user has all the roles, false otherwise.
     */
    bool hasAllRoles(PrincipalCollection subjectPrincipal, Collection!(string) roleIdentifiers);

    /**
     * Asserts the corresponding Subject/user has the specified role by returning quietly if they do or throwing an
     * {@link AuthorizationException} if they do not.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifier   the application-specific role identifier (usually a role id or role name ).
     * @throws AuthorizationException
     *          if the user does not have the role.
     */
    void checkRole(PrincipalCollection subjectPrincipal, string roleIdentifier);

    /**
     * Asserts the corresponding Subject/user has all of the specified roles by returning quietly if they do or
     * throwing an {@link AuthorizationException} if they do not.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifiers  the application-specific role identifiers to check (usually role ids or role names).
     * @throws AuthorizationException
     *          if the user does not have all of the specified roles.
     */
    void checkRoles(PrincipalCollection subjectPrincipal, Collection!(string) roleIdentifiers);

    /**
     * Same as {@link #checkRoles(hunt.shiro.subject.PrincipalCollection, java.util.Collection)
     * checkRoles(PrincipalCollection subjectPrincipal, Collection&lt;string&gt; roleIdentifiers)} but doesn't require a collection
     * as an argument.
     * Asserts the corresponding Subject/user has all of the specified roles by returning quietly if they do or
     * throwing an {@link AuthorizationException} if they do not.
     *
     * @param subjectPrincipal the application-specific subject/user identifier.
     * @param roleIdentifiers  the application-specific role identifiers to check (usually role ids or role names).
     * @throws AuthorizationException
     *          if the user does not have all of the specified roles.
     *          
     *  @since 1.1.0
     */
    void checkRoles(PrincipalCollection subjectPrincipal, string[] roleIdentifiers...);
    
}

