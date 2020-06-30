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
module hunt.shiro.realm.AuthorizingRealm;

import hunt.shiro.realm.AuthenticatingRealm;

import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.credential.CredentialsMatcher;
import hunt.shiro.authz;
import hunt.shiro.authz.permission;
import hunt.shiro.cache.AbstractCacheManager;
import hunt.shiro.cache.Cache;
import hunt.shiro.cache.CacheManager;
import hunt.shiro.Exceptions;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.Common;

import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import core.atomic;
import std.conv;
import std.string;


/**
 * An {@code AuthorizingRealm} extends the {@code AuthenticatingRealm}'s capabilities by adding Authorization
 * (access control) support.
 * <p/>
 * This implementation will perform all role and permission checks automatically (and subclasses do not have to
 * write this logic) as long as the
 * {@link #getAuthorizationInfo(hunt.shiro.subject.PrincipalCollection)} method returns an
 * {@link AuthorizationInfo}.  Please see that method's JavaDoc for an in-depth explanation.
 * <p/>
 * If you find that you do not want to utilize the {@link AuthorizationInfo AuthorizationInfo} construct,
 * you are of course free to subclass the {@link AuthenticatingRealm AuthenticatingRealm} directly instead and
 * implement the remaining Realm interface methods directly.  You might do this if you want have better control
 * over how the Role and Permission checks occur for your specific data source.  However, using AuthorizationInfo
 * (and its default implementation {@link hunt.shiro.authz.SimpleAuthorizationInfo SimpleAuthorizationInfo}) is sufficient in the large
 * majority of Realm cases.
 *
 * @see hunt.shiro.authz.SimpleAuthorizationInfo
 */
abstract class AuthorizingRealm : AuthenticatingRealm,
        Authorizer, PermissionResolverAware, RolePermissionResolverAware {
    
    
    /*-------------------------------------------
    |             C O N S T A N T S             |
    ============================================*/


    /**
     * The default suffix appended to the realm name for caching AuthorizationInfo instances.
     */
    private enum string DEFAULT_AUTHORIZATION_CACHE_SUFFIX = ".authorizationCache";

    private static shared int INSTANCE_COUNT = 0; 

    /*-------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/
    /**
     * The cache used by this realm to store AuthorizationInfo instances associated with individual Subject principals.
     */
    private bool authorizationCachingEnabled;
    private Cache!(Object, AuthorizationInfo) authorizationCache;
    private string authorizationCacheName;

    private PermissionResolver permissionResolver;

    private RolePermissionResolver permissionRoleResolver;

    /*-------------------------------------------
    |         C O N S T R U C T O R S           |
    ============================================*/

    this() {
        this(null, null);
    }

    this(CacheManager cacheManager) {
        this(cacheManager, null);
    }

    this(CredentialsMatcher matcher) {
        this(null, matcher);
    }

    this(CacheManager cacheManager, CredentialsMatcher matcher) {
        super();
        if (cacheManager !is null) setCacheManager(cacheManager);
        if (matcher !is null) setCredentialsMatcher(matcher);

        this.authorizationCachingEnabled = true;
        this.permissionResolver = new WildcardPermissionResolver();

        
        int instanceNumber = atomicOp!("+=")(INSTANCE_COUNT, 1);
        instanceNumber--;
        this.authorizationCacheName = typeid(this).name ~ DEFAULT_AUTHORIZATION_CACHE_SUFFIX;
        if (instanceNumber > 0) {
            this.authorizationCacheName = this.authorizationCacheName ~ "." ~ instanceNumber.to!string();
        }
    }

    /*-------------------------------------------
    |  A C C E S S O R S / M O D I F I E R S    |
    ============================================*/

    override void setName(string name) {
        super.setName(name);
        string authzCacheName = this.authorizationCacheName;
        if (authzCacheName !is null && authzCacheName.startsWith(typeid(this).name)) {
            //get rid of the default class-name based cache name.  Create a more meaningful one
            //based on the application-unique Realm name:
            this.authorizationCacheName = name ~ DEFAULT_AUTHORIZATION_CACHE_SUFFIX;
        }
    }

    void setAuthorizationCache(Cache!(Object, AuthorizationInfo) authorizationCache) {
        this.authorizationCache = authorizationCache;
    }

    Cache!(Object, AuthorizationInfo) getAuthorizationCache() {
        return this.authorizationCache;
    }

    string getAuthorizationCacheName() {
        return authorizationCacheName;
    }

    //@SuppressWarnings({"UnusedDeclaration"})
    void setAuthorizationCacheName(string authorizationCacheName) {
        this.authorizationCacheName = authorizationCacheName;
    }

    /**
     * Returns {@code true} if authorization caching should be utilized if a {@link CacheManager} has been
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) configured}, {@code false} otherwise.
     * <p/>
     * The default value is {@code true}.
     *
     * @return {@code true} if authorization caching should be utilized, {@code false} otherwise.
     */
    bool isAuthorizationCachingEnabled() {
        version(HUNT_SHIRO_DEBUG) {
            tracef("authorizationCachingEnabled=%s, isCachingEnabled=%s", 
                authorizationCachingEnabled, isCachingEnabled());
        }
        return isCachingEnabled() && authorizationCachingEnabled;
    }

    /**
     * Sets whether or not authorization caching should be utilized if a {@link CacheManager} has been
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) configured}, {@code false} otherwise.
     * <p/>
     * The default value is {@code true}.
     *
     * @param authenticationCachingEnabled the value to set
     */
    //@SuppressWarnings({"UnusedDeclaration"})
    void setAuthorizationCachingEnabled(bool authenticationCachingEnabled) {
        this.authorizationCachingEnabled = authenticationCachingEnabled;
        if (authenticationCachingEnabled) {
            setCachingEnabled(true);
        }
    }

    PermissionResolver getPermissionResolver() {
        return permissionResolver;
    }

    void setPermissionResolver(PermissionResolver permissionResolver) {
        if (permissionResolver  is null) throw new IllegalArgumentException("Null PermissionResolver is not allowed");
        this.permissionResolver = permissionResolver;
    }

    RolePermissionResolver getRolePermissionResolver() {
        return permissionRoleResolver;
    }

    void setRolePermissionResolver(RolePermissionResolver permissionRoleResolver) {
        this.permissionRoleResolver = permissionRoleResolver;
    }

    /*--------------------------------------------
    |               M E T H O D S               |
    ============================================*/

    /**
     * Initializes this realm and potentially enables a cache, depending on configuration.
     * <p/>
     * When this method is called, the following logic is executed:
     * <ol>
     * <li>If the {@link #setAuthorizationCache cache} property has been set, it will be
     * used to cache the AuthorizationInfo objects returned from {@link #getAuthorizationInfo}
     * method invocations.
     * All future calls to {@code getAuthorizationInfo} will attempt to use this cache first
     * to alleviate any potentially unnecessary calls to an underlying data store.</li>
     * <li>If the {@link #setAuthorizationCache cache} property has <b>not</b> been set,
     * the {@link #setCacheManager cacheManager} property will be checked.
     * If a {@code cacheManager} has been set, it will be used to create an authorization
     * {@code cache}, and this newly created cache which will be used as specified in #1.</li>
     * <li>If neither the {@link #setAuthorizationCache (hunt.shiro.cache.Cache) cache}
     * or {@link #setCacheManager(hunt.shiro.cache.CacheManager) cacheManager}
     * properties are set, caching will be disabled and authorization look-ups will be delegated to
     * subclass implementations for each authorization check.</li>
     * </ol>
     */
    override protected void onInit() {
        super.onInit();
        //trigger obtaining the authorization cache if possible
        getAvailableAuthorizationCache();
    }

    override protected void afterCacheManagerSet() {
        super.afterCacheManagerSet();
        //trigger obtaining the authorization cache if possible
        getAvailableAuthorizationCache();
    }

    private Cache!(Object, AuthorizationInfo) getAuthorizationCacheLazy() {

        if (this.authorizationCache  is null) {

            version(HUNT_SHIRO_DEBUG) 
            {
                tracef("No authorizationCache instance set.  Checking for a cacheManager...");
            }

            CacheManager cacheManager = getCacheManager();

            if (cacheManager !is null) {
                string cacheName = getAuthorizationCacheName();
                version(HUNT_SHIRO_DEBUG) 
                {
                    tracef("CacheManager [" ~ (cast(Object)cacheManager).toString() ~ 
                            "] has been configured.  Building " ~
                            "authorization cache named [" ~ cacheName ~ "]");
                }
                auto acm = cast(AbstractCacheManager!(Object, AuthorizationInfo))cacheManager;
                this.authorizationCache =  acm.getCache(cacheName);

                version(HUNT_SHIRO_DEBUG) tracef("authorizationCache: %s", this.authorizationCache is null);
            } else {
                version(HUNT_SHIRO_DEBUG) 
                {
                    tracef("No cache or cacheManager properties have been set.  Authorization cache cannot " ~
                            "be obtained.");
                }
            }
        }

        return this.authorizationCache;
    }

    private Cache!(Object, AuthorizationInfo) getAvailableAuthorizationCache() {
        Cache!(Object, AuthorizationInfo) cache = getAuthorizationCache();
        if (cache  is null && isAuthorizationCachingEnabled()) {
            cache = getAuthorizationCacheLazy();
        }
        return cache;
    }

    /**
     * Returns an account's authorization-specific information for the specified {@code principals},
     * or {@code null} if no account could be found.  The resulting {@code AuthorizationInfo} object is used
     * by the other method implementations in this class to automatically perform access control checks for the
     * corresponding {@code Subject}.
     * <p/>
     * This implementation obtains the actual {@code AuthorizationInfo} object from the subclass's
     * implementation of
     * {@link #doGetAuthorizationInfo(hunt.shiro.subject.PrincipalCollection) doGetAuthorizationInfo}, and then
     * caches it for efficient reuse if caching is enabled (see below).
     * <p/>
     * Invocations of this method should be thought of as completely orthogonal to acquiring
     * {@link #getAuthenticationInfo(hunt.shiro.authc.AuthenticationToken) authenticationInfo}, since either could
     * occur in any order.
     * <p/>
     * For example, in &quot;Remember Me&quot; scenarios, the user identity is remembered (and
     * assumed) for their current session and an authentication attempt during that session might never occur.
     * But because their identity would be remembered, that is sufficient enough information to call this method to
     * execute any necessary authorization checks.  For this reason, authentication and authorization should be
     * loosely coupled and not depend on each other.
     * <h3>Caching</h3>
     * The {@code AuthorizationInfo} values returned from this method are cached for efficient reuse
     * if caching is enabled.  Caching is enabled automatically when an {@link #setAuthorizationCache authorizationCache}
     * instance has been explicitly configured, or if a {@link #setCacheManager cacheManager} has been configured, which
     * will be used to lazily create the {@code authorizationCache} as needed.
     * <p/>
     * If caching is enabled, the authorization cache will be checked first and if found, will return the cached
     * {@code AuthorizationInfo} immediately.  If caching is disabled, or there is a cache miss, the authorization
     * info will be looked up from the underlying data store via the
     * {@link #doGetAuthorizationInfo(hunt.shiro.subject.PrincipalCollection)} method, which must be implemented
     * by subclasses.
     * <h4>Changed Data</h4>
     * If caching is enabled and if any authorization data for an account is changed at
     * runtime, such as adding or removing roles and/or permissions, the subclass implementation should clear the
     * cached AuthorizationInfo for that account via the
     * {@link #clearCachedAuthorizationInfo(hunt.shiro.subject.PrincipalCollection) clearCachedAuthorizationInfo}
     * method.  This ensures that the next call to {@code getAuthorizationInfo(PrincipalCollection)} will
     * acquire the account's fresh authorization data, where it will then be cached for efficient reuse.  This
     * ensures that stale authorization data will not be reused.
     *
     * @param principals the corresponding Subject's identifying principals with which to look up the Subject's
     *                   {@code AuthorizationInfo}.
     * @return the authorization information for the account associated with the specified {@code principals},
     *         or {@code null} if no account could be found.
     */
    protected AuthorizationInfo getAuthorizationInfo(PrincipalCollection principals) {

        if (principals is null) {
            return null;
        }

        AuthorizationInfo info = null;

        version(HUNT_SHIRO_DEBUG_MORE) {
            tracef("Retrieving AuthorizationInfo for principals [" ~ (cast(Object)principals).toString() ~ "]");
        }

        Cache!(Object, AuthorizationInfo) cache = getAvailableAuthorizationCache();

        if (cache !is null) {
            version(HUNT_SHIRO_DEBUG_MORE) {
                tracef("Attempting to retrieve the AuthorizationInfo from cache.");
            }
            Object key = getAuthorizationCacheKey(principals);
            info = cache.get(key, null);
            version(HUNT_SHIRO_DEBUG_MORE) {
                if (info  is null) {
                    tracef("No AuthorizationInfo found in cache for principals [" ~ 
                        (cast(Object)principals).toString() ~ "]");
                } else {
                    tracef("AuthorizationInfo found in cache for principals [" ~ 
                        (cast(Object)principals).toString() ~ "]");
                }
            }
        }


        if (info is null) {
            // Call template method if the info was not found in a cache
            info = doGetAuthorizationInfo(principals);
            // If the info is not null and the cache has been created, then cache the authorization info.
            if (info !is null && cache !is null) {
                version(HUNT_SHIRO_DEBUG) {
                    tracef("Caching authorization info for principals: [" ~ 
                        (cast(Object)principals).toString() ~ "].");
                }
                Object key = getAuthorizationCacheKey(principals);
                cache.put(key, info);
            }
        }

        return info;
    }

    protected Object getAuthorizationCacheKey(PrincipalCollection principals) {
        return cast(Object)principals;
    }

    /**
     * Clears out the AuthorizationInfo cache entry for the specified account.
     * <p/>
     * This method is provided as a convenience to subclasses so they can invalidate a cache entry when they
     * change an account's authorization data (add/remove roles or permissions) during runtime.  Because an account's
     * AuthorizationInfo can be cached, there needs to be a way to invalidate the cache for only that account so that
     * subsequent authorization operations don't used the (old) cached value if account data changes.
     * <p/>
     * After this method is called, the next authorization check for that same account will result in a call to
     * {@link #getAuthorizationInfo(hunt.shiro.subject.PrincipalCollection) getAuthorizationInfo}, and the
     * resulting return value will be cached before being returned so it can be reused for later authorization checks.
     * <p/>
     * If you wish to clear out all associated cached data (and not just authorization data), use the
     * {@link #clearCache(hunt.shiro.subject.PrincipalCollection)} method instead (which will in turn call this
     * method by default).
     *
     * @param principals the principals of the account for which to clear the cached AuthorizationInfo.
     */
    protected void clearCachedAuthorizationInfo(PrincipalCollection principals) {
        if (principals  is null) {
            return;
        }

        Cache!(Object, AuthorizationInfo) cache = getAvailableAuthorizationCache();
        //cache instance will be non-null if caching is enabled:
        if (cache !is null) {
            Object key = getAuthorizationCacheKey(principals);
            cache.remove(key);
        }
    }

    /**
     * Retrieves the AuthorizationInfo for the given principals from the underlying data store.  When returning
     * an instance from this method, you might want to consider using an instance of
     * {@link hunt.shiro.authz.SimpleAuthorizationInfo SimpleAuthorizationInfo}, as it is suitable in most cases.
     *
     * @param principals the primary identifying principals of the AuthorizationInfo that should be retrieved.
     * @return the AuthorizationInfo associated with this principals.
     * @see hunt.shiro.authz.SimpleAuthorizationInfo
     */
    protected abstract AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals);

    //visibility changed from private to protected per SHIRO-332
    protected Collection!(Permission) getPermissions(AuthorizationInfo info) {
        Set!(Permission) permissions = new HashSet!(Permission)();

        if (info !is null) {
            Collection!(Permission) perms = info.getObjectPermissions();
            if (!CollectionUtils.isEmpty(perms)) {
                permissions.addAll(perms);
            }
            perms = resolvePermissions(info.getStringPermissions());
            if (!CollectionUtils.isEmpty(perms)) {
                permissions.addAll(perms);
            }

            perms = resolveRolePermissions(info.getRoles());
            if (!CollectionUtils.isEmpty(perms)) {
                permissions.addAll(perms);
            }
        }

        if (permissions.isEmpty()) {
            return Collections.emptySet!(Permission)();
        } else {
            return permissions;
        }
    }

    private Collection!(Permission) resolvePermissions(Collection!(string) stringPerms) {
        Collection!(Permission) perms = Collections.emptySet!Permission();
        PermissionResolver resolver = getPermissionResolver();
        if (resolver !is null && !CollectionUtils.isEmpty(stringPerms)) {
            perms = new LinkedHashSet!(Permission)(stringPerms.size());
            foreach(string strPermission ; stringPerms) {
                Permission permission = resolver.resolvePermission(strPermission);
                perms.add(permission);
            }
        }
        return perms;
    }

    private Collection!(Permission) resolveRolePermissions(Collection!(string) roleNames) {
        Collection!(Permission) perms = Collections.emptySet!Permission();
        RolePermissionResolver resolver = getRolePermissionResolver();
        if (resolver !is null && !CollectionUtils.isEmpty(roleNames)) {
            perms = new LinkedHashSet!(Permission)(roleNames.size());
            foreach(string roleName ; roleNames) {
                Collection!(Permission) resolved = resolver.resolvePermissionsInRole(roleName);
                if (!CollectionUtils.isEmpty(resolved)) {
                    perms.addAll(resolved);
                }
            }
        }
        return perms;
    }

    bool isPermitted(PrincipalCollection principals, string permission) {
        try {
            Permission p = getPermissionResolver().resolvePermission(permission);
            return isPermitted(principals, p);
        } catch(Exception ex) {
            warning(ex.msg);
            version(HUNT_DEBUG) warning(ex);
            return false;
        }
    }

    bool isPermitted(PrincipalCollection principals, Permission permission) {
        try {
            AuthorizationInfo info = getAuthorizationInfo(principals);
            return isPermitted(permission, info);
        } catch(Exception ex) {
            warning(ex.msg);
            version(HUNT_DEBUG) warning(ex);
            return false;
        }
    }

    //visibility changed from private to protected per SHIRO-332
    protected bool isPermitted(Permission permission, AuthorizationInfo info) {
        Collection!(Permission) perms = getPermissions(info);
        if (perms !is null && !perms.isEmpty()) {
            foreach (Permission perm; perms) {
                if (perm.implies(permission)) {
                    return true;
                }
            }
        }
        return false;
    }

    bool[] isPermitted(PrincipalCollection subjectIdentifier, string[] permissions...) {
        List!(Permission) perms = new ArrayList!(Permission)(cast(int) permissions.length);
        foreach (string permString; permissions) {
            perms.add(getPermissionResolver().resolvePermission(permString));
        }
        return isPermitted(subjectIdentifier, perms);
    }

    bool[] isPermitted(PrincipalCollection principals, List!(Permission) permissions) {
        AuthorizationInfo info = getAuthorizationInfo(principals);
        return isPermitted(permissions, info);
    }

    protected bool[] isPermitted(List!(Permission) permissions, AuthorizationInfo info) {
        bool[] result;
        if (permissions !is null && !permissions.isEmpty()) {
            int size = permissions.size();
            result = new bool[size];
            int i = 0;
            foreach (Permission p; permissions) {
                result[i++] = isPermitted(p, info);
            }
        } else {
            result = new bool[0];
        }
        return result;
    }

    bool isPermittedAll(PrincipalCollection subjectIdentifier, string[] permissions...) {
        if (permissions !is null && permissions.length > 0) {
            Collection!(Permission) perms = new ArrayList!(Permission)(cast(int) permissions.length);
            foreach (string permString; permissions) {
                perms.add(getPermissionResolver().resolvePermission(permString));
            }
            return isPermittedAll(subjectIdentifier, perms);
        }
        return false;
    }

    bool isPermittedAll(PrincipalCollection principal, Collection!(Permission) permissions) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        return info !is null && isPermittedAll(permissions, info);
    }

    protected bool isPermittedAll(Collection!(Permission) permissions, AuthorizationInfo info) {
        if (permissions !is null && !permissions.isEmpty()) {
            foreach (Permission p; permissions) {
                if (!isPermitted(p, info)) {
                    return false;
                }
            }
        }
        return true;
    }

    void checkPermission(PrincipalCollection subjectIdentifier, string permission) {
        Permission p = getPermissionResolver().resolvePermission(permission);
        checkPermission(subjectIdentifier, p);
    }

    void checkPermission(PrincipalCollection principal, Permission permission) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        checkPermission(permission, info);
    }

    protected void checkPermission(Permission permission, AuthorizationInfo info) {
        if (!isPermitted(permission, info)) {
            string msg = "User is not permitted [" ~ (cast(Object) permission).toString() ~ "]";
            throw new UnauthorizedException(msg);
        }
    }

    void checkPermissions(PrincipalCollection subjectIdentifier, string[] permissions...) {
        if (permissions !is null) {
            foreach (string permString; permissions) {
                checkPermission(subjectIdentifier, permString);
            }
        }
    }

    void checkPermissions(PrincipalCollection principal, Collection!(Permission) permissions) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        checkPermissions(permissions, info);
    }

    protected void checkPermissions(Collection!(Permission) permissions, AuthorizationInfo info) {
        if (permissions !is null && !permissions.isEmpty()) {
            foreach (Permission p; permissions) {
                checkPermission(p, info);
            }
        }
    }

    bool hasRole(PrincipalCollection principal, string roleIdentifier) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        return hasRole(roleIdentifier, info);
    }

    protected bool hasRole(string roleIdentifier, AuthorizationInfo info) {
        // return info !is null && info.getRoles() !is null && info.getRoles().contains(roleIdentifier);

        version (HUNT_SHIRO_DEBUG)
            tracef("checking: %s", roleIdentifier);
        if (info !is null) {
            Collection!(string) roles = info.getRoles();
            if (roles !is null) {
                bool r = roles.contains(roleIdentifier);
                version (HUNT_SHIRO_DEBUG) {
                    infof("roles: %s, result: %s", roles, r);
                }
                return r;
            }
        }
        return false;
    }

    bool[] hasRoles(PrincipalCollection principal, List!(string) roleIdentifiers) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        if (roleIdentifiers is null || roleIdentifiers.isEmpty()) {
            return new bool[0];
        }

        return hasRoles(roleIdentifiers.toArray(), info);
    }

    bool[] hasRoles(PrincipalCollection principal, string[] roleIdentifiers) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        bool[] result = new bool[roleIdentifiers.length];
        if (info !is null) {
            result = hasRoles(roleIdentifiers, info);
        }
        return result;
    }

    // protected bool[] hasRoles(List!(string) roleIdentifiers, AuthorizationInfo info) {
    //     bool[] result;
    //     if (roleIdentifiers is null || roleIdentifiers.isEmpty()) {
    //         result = new bool[0];
    //     } else {
    //         result = hasRoles(roleIdentifiers.toArray(), info);
    //     }
    //     return result;
    // }

    protected bool[] hasRoles(string[] roleIdentifiers, AuthorizationInfo info) {
        bool[] result;
        if (roleIdentifiers.empty()) {
            result = new bool[0];
        } else {
            result = new bool[roleIdentifiers.length];
            int i = 0;
            foreach (string roleName; roleIdentifiers) {
                result[i++] = hasRole(roleName, info);
            }
        }
        return result;
    }

    bool hasAllRoles(PrincipalCollection principal, Collection!(string) roleIdentifiers) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        return info !is null && hasAllRoles(roleIdentifiers, info);
    }

    bool hasAllRoles(PrincipalCollection principal, string[] roleIdentifiers) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        return info !is null && hasAllRoles(roleIdentifiers, info);
    }

    private bool hasAllRoles(Collection!(string) roleIdentifiers, AuthorizationInfo info) {
        if (roleIdentifiers !is null && !roleIdentifiers.isEmpty()) {
            return hasAllRoles(roleIdentifiers.toArray(), info);
        }
        return true;
    }

    private bool hasAllRoles(string[] roleIdentifiers, AuthorizationInfo info) {
        foreach (string roleName; roleIdentifiers) {
            if (!hasRole(roleName, info)) {
                return false;
            }
        }
        return true;
    }

    void checkRole(PrincipalCollection principal, string role) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        checkRole(role, info);
    }

    protected void checkRole(string role, AuthorizationInfo info) {
        if (!hasRole(role, info)) {
            string msg = "User does not have role [" ~ role ~ "]";
            throw new UnauthorizedException(msg);
        }
    }

    void checkRoles(PrincipalCollection principal, Collection!(string) roles) {
        AuthorizationInfo info = getAuthorizationInfo(principal);
        checkRoles(roles, info);
    }

    void checkRoles(PrincipalCollection principal, string[] roles...) {

        AuthorizationInfo info = getAuthorizationInfo(principal);
        if (!roles.empty()) {
            foreach (string roleName; roles) {
                checkRole(roleName, info);
            }
        }
    }

    protected void checkRoles(Collection!(string) roles, AuthorizationInfo info) {
        if (roles !is null && !roles.isEmpty()) {
            foreach (string roleName; roles) {
                checkRole(roleName, info);
            }
        }
    }

    /**
     * Calls {@code super.doClearCache} to ensure any cached authentication data is removed and then calls
     * {@link #clearCachedAuthorizationInfo(hunt.shiro.subject.PrincipalCollection)} to remove any cached
     * authorization data.
     * <p/>
     * If overriding in a subclass, be sure to call {@code super.doClearCache} to ensure this behavior is maintained.
     *
     * @param principals the principals of the account for which to clear any cached AuthorizationInfo
     */
    override protected void doClearCache(PrincipalCollection principals) {
        super.doClearCache(principals);
        clearCachedAuthorizationInfo(principals);
    }
}
