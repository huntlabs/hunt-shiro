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
module hunt.shiro.realm.CachingRealm;

import hunt.shiro.authc.LogoutAware;
import hunt.shiro.cache.CacheManager;
import hunt.shiro.cache.CacheManagerAware;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.Nameable;
import hunt.logger;

import hunt.collection;
import java.util.concurrent.atomic.AtomicInteger;


/**
 * A very basic abstract extension point for the {@link Realm} interface that provides caching support for subclasses.
 * <p/>
 * It also provides a convenience method,
 * {@link #getAvailablePrincipal(hunt.shiro.subject.PrincipalCollection)}, which is useful across all
 * realm subclasses for obtaining a realm-specific principal/identity.
 * <p/>
 * All actual Realm method implementations are left to subclasses.
 *
 * @see #clearCache(hunt.shiro.subject.PrincipalCollection)
 * @see #onLogout(hunt.shiro.subject.PrincipalCollection)
 * @see #getAvailablePrincipal(hunt.shiro.subject.PrincipalCollection)
 */
abstract class CachingRealm : Realm, Nameable, CacheManagerAware, LogoutAware {



    //TODO - complete JavaDoc

    private static final AtomicInteger INSTANCE_COUNT = new AtomicInteger();

    /*--------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/
    private string name;
    private bool cachingEnabled;
    private CacheManager cacheManager;

    /**
     * Default no-argument constructor that defaults
     * {@link #isCachingEnabled() cachingEnabled} (for general caching) to {@code true} and sets a
     * default {@link #getName() name} based on the class name.
     * <p/>
     * Note that while in general, caching may be enabled by default, subclasses have control over
     * if specific caching is enabled.
     */
     this() {
        this.cachingEnabled = true;
        this.name = typeid(this).name ~ "_" ~ INSTANCE_COUNT.getAndIncrement();
    }

    /**
     * Returns the <tt>CacheManager</tt> used for data caching to reduce EIS round trips, or <tt>null</tt> if
     * caching is disabled.
     *
     * @return the <tt>CacheManager</tt> used for data caching to reduce EIS round trips, or <tt>null</tt> if
     *         caching is disabled.
     */
     CacheManager getCacheManager() {
        return this.cacheManager;
    }

    /**
     * Sets the <tt>CacheManager</tt> to be used for data caching to reduce EIS round trips.
     * <p/>
     * This property is <tt>null</tt> by default, indicating that caching is turned off.
     *
     * @param cacheManager the <tt>CacheManager</tt> to use for data caching, or <tt>null</tt> to disable caching.
     */
     void setCacheManager(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
        afterCacheManagerSet();
    }

    /**
     * Returns {@code true} if caching should be used if a {@link CacheManager} has been
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) configured}, {@code false} otherwise.
     * <p/>
     * The default value is {@code true} since the large majority of Realms will benefit from caching if a CacheManager
     * has been configured.  However, memory-only realms should set this value to {@code false} since they would
     * manage account data in memory already lookups would already be as efficient as possible.
     *
     * @return {@code true} if caching will be globally enabled if a {@link CacheManager} has been
     *         configured, {@code false} otherwise
     */
     bool isCachingEnabled() {
        return cachingEnabled;
    }

    /**
     * Sets whether or not caching should be used if a {@link CacheManager} has been
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) configured}.
     *
     * @param cachingEnabled whether or not to globally enable caching for this realm.
     */
     void setCachingEnabled(bool cachingEnabled) {
        this.cachingEnabled = cachingEnabled;
    }

     string getName() {
        return name;
    }

     void setName(string name) {
        this.name = name;
    }

    /**
     * Template method that may be implemented by subclasses should they wish to react to a
     * {@link CacheManager} instance being set on the realm instance via the
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager)} mutator.
     */
    protected void afterCacheManagerSet() {
    }

    /**
     * If caching is enabled, this will clear any cached data associated with the specified account identity.
     * Subclasses are free to override for additional behavior, but be sure to call {@code super.onLogout} first.
     * <p/>
     * This default implementation merely calls {@link #clearCache(hunt.shiro.subject.PrincipalCollection)}.
     *
     * @param principals the application-specific Subject/user identifier that is logging out.
     * @see #clearCache(hunt.shiro.subject.PrincipalCollection)
     * @see #getAvailablePrincipal(hunt.shiro.subject.PrincipalCollection)
     */
     void onLogout(PrincipalCollection principals) {
        clearCache(principals);
    }

    private static bool isEmpty(PrincipalCollection pc) {
        return pc  is null || pc.isEmpty();
    }

    /**
     * Clears out any cached data associated with the specified account identity/identities.
     * <p/>
     * This implementation will return quietly if the principals argument is null or empty.  Otherwise it delegates
     * to {@link #doClearCache(hunt.shiro.subject.PrincipalCollection)}.
     *
     * @param principals the principals of the account for which to clear any cached data.
     */
    protected void clearCache(PrincipalCollection principals) {
        if (!isEmpty(principals)) {
            doClearCache(principals);
            tracef("Cleared cache entries for account with principals [{}]", principals);
        }
    }

    /**
     * This implementation does nothing - it is a template to be overridden by subclasses if necessary.
     *
     * @param principals principals the principals of the account for which to clear any cached data.
     */
    protected void doClearCache(PrincipalCollection principals) {
    }

    /**
     * A utility method for subclasses that returns the first available principal of interest to this particular realm.
     * The heuristic used to acquire the principal is as follows:
     * <ul>
     * <li>Attempt to get <em>this particular Realm's</em> 'primary' principal in the {@code PrincipalCollection} via a
     * <code>principals.{@link PrincipalCollection#fromRealm(string) fromRealm}({@link #getName() getName()})</code>
     * call.</li>
     * <li>If the previous call does not result in any principals, attempt to get the overall 'primary' principal
     * from the PrincipalCollection via {@link hunt.shiro.subject.PrincipalCollection#getPrimaryPrincipal()}.</li>
     * <li>If there are no principals from that call (or the PrincipalCollection argument was null to begin with),
     * return {@code null}</li>
     * </ul>
     *
     * @param principals the PrincipalCollection holding all principals (from all realms) associated with a single Subject.
     * @return the 'primary' principal attributed to this particular realm, or the fallback 'master' principal if it
     *         exists, or if not {@code null}.
     */
    protected Object getAvailablePrincipal(PrincipalCollection principals) {
        Object primary = null;
        if (!isEmpty(principals)) {
            Collection thisPrincipals = principals.fromRealm(getName());
            if (!CollectionUtils.isEmpty(thisPrincipals)) {
                primary = thisPrincipals.iterator().next();
            } else {
                //no principals attributed to this particular realm.  Fall back to the 'master' primary:
                primary = principals.getPrimaryPrincipal();
            }
        }

        return primary;
    }
}
