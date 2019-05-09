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
module hunt.shiro.mgt.AuthorizingSecurityManager;

import hunt.shiro.mgt.AuthenticatingSecurityManager;

import hunt.shiro.Exceptions;
import hunt.shiro.authz.Authorizer;
import hunt.shiro.authz.ModularRealmAuthorizer;
import hunt.shiro.authz.Permission;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.util.LifecycleUtils;

import hunt.collection;
import hunt.Exceptions;


/**
 * Shiro support of a {@link SecurityManager} class hierarchy that delegates all
 * authorization (access control) operations to a wrapped {@link Authorizer Authorizer} instance.  That is,
 * this class implements all the <tt>Authorizer</tt> methods in the {@link SecurityManager SecurityManager}
 * interface, but in reality, those methods are merely passthrough calls to the underlying 'real'
 * <tt>Authorizer</tt> instance.
 *
 * <p>All remaining <tt>SecurityManager</tt> methods not covered by this class or its parents (mostly Session support)
 * are left to be implemented by subclasses.
 *
 * <p>In keeping with the other classes in this hierarchy and Shiro's desire to minimize configuration whenever
 * possible, suitable default instances for all dependencies will be created upon instantiation.
 *
 */
abstract class AuthorizingSecurityManager : AuthenticatingSecurityManager {

    /**
     * The wrapped instance to which all of this <tt>SecurityManager</tt> authorization calls are delegated.
     */
    private Authorizer authorizer;

    /**
     * Default no-arg constructor that initializes an internal default
     * {@link hunt.shiro.authz.ModularRealmAuthorizer ModularRealmAuthorizer}.
     */
     this() {
        super();
        this.authorizer = new ModularRealmAuthorizer();
    }

    /**
     * Returns the underlying wrapped <tt>Authorizer</tt> instance to which this <tt>SecurityManager</tt>
     * implementation delegates all of its authorization calls.
     *
     * @return the wrapped <tt>Authorizer</tt> used by this <tt>SecurityManager</tt> implementation.
     */
     Authorizer getAuthorizer() {
        return authorizer;
    }

    /**
     * Sets the underlying <tt>Authorizer</tt> instance to which this <tt>SecurityManager</tt> implementation will
     * delegate all of its authorization calls.
     *
     * @param authorizer the <tt>Authorizer</tt> this <tt>SecurityManager</tt> should wrap and delegate all of its
     *                   authorization calls to.
     */
     void setAuthorizer(Authorizer authorizer) {
        if (authorizer  is null) {
            string msg = "Authorizer argument cannot be null.";
            throw new IllegalArgumentException(msg);
        }
        this.authorizer = authorizer;
    }

    /**
     * First calls <code>super.afterRealmsSet()</code> and then sets these same <code>Realm</code> objects on this
     * instance's wrapped {@link Authorizer Authorizer}.
     * <p/>
     * The setting of realms the Authorizer will only occur if it is an instance of
     * {@link hunt.shiro.authz.ModularRealmAuthorizer ModularRealmAuthorizer}, that is:
     * <pre>
     * if ( this.authorizer instanceof ModularRealmAuthorizer ) {
     *     ((ModularRealmAuthorizer)this.authorizer).setRealms(realms);
     * }</pre>
     */
    override protected void afterRealmsSet() {
        super.afterRealmsSet();
        auto authorizerCast = cast(ModularRealmAuthorizer) this.authorizer;
        if (authorizerCast !is null) {
            authorizerCast.setRealms(getRealms());
        }
    }

    override void destroy() {
        LifecycleUtils.destroy(cast(Object)getAuthorizer());
        this.authorizer = null;
        super.destroy();
    }

     bool isPermitted(PrincipalCollection principals, string permissionString) {
        return this.authorizer.isPermitted(principals, permissionString);
    }

     bool isPermitted(PrincipalCollection principals, Permission permission) {
        return this.authorizer.isPermitted(principals, permission);
    }

     bool[] isPermitted(PrincipalCollection principals, string[] permissions...) {
        return this.authorizer.isPermitted(principals, permissions);
    }

     bool[] isPermitted(PrincipalCollection principals, List!(Permission) permissions) {
        return this.authorizer.isPermitted(principals, permissions);
    }

     bool isPermittedAll(PrincipalCollection principals, string[] permissions...) {
        return this.authorizer.isPermittedAll(principals, permissions);
    }

     bool isPermittedAll(PrincipalCollection principals, Collection!(Permission) permissions) {
        return this.authorizer.isPermittedAll(principals, permissions);
    }

     void checkPermission(PrincipalCollection principals, string permission){
        this.authorizer.checkPermission(principals, permission);
    }

     void checkPermission(PrincipalCollection principals, Permission permission){
        this.authorizer.checkPermission(principals, permission);
    }

     void checkPermissions(PrincipalCollection principals, string[] permissions...){
        this.authorizer.checkPermissions(principals, permissions);
    }

     void checkPermissions(PrincipalCollection principals, Collection!(Permission) permissions){
        this.authorizer.checkPermissions(principals, permissions);
    }

     bool hasRole(PrincipalCollection principals, string roleIdentifier) {
        return this.authorizer.hasRole(principals, roleIdentifier);
    }

     bool[] hasRoles(PrincipalCollection principals, List!(string) roleIdentifiers) {
        return this.authorizer.hasRoles(principals, roleIdentifiers);
    }

     bool hasAllRoles(PrincipalCollection principals, Collection!(string) roleIdentifiers) {
        return this.authorizer.hasAllRoles(principals, roleIdentifiers);
    }

     void checkRole(PrincipalCollection principals, string role){
        this.authorizer.checkRole(principals, role);
    }

     void checkRoles(PrincipalCollection principals, Collection!(string) roles){
        this.authorizer.checkRoles(principals, roles);
    }
    
     void checkRoles(PrincipalCollection principals, string[] roles...){
        this.authorizer.checkRoles(principals, roles);
    }    
}
