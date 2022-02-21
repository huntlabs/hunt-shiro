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
module hunt.shiro.mgt.RealmSecurityManager;

import hunt.shiro.mgt.CachingSecurityManager;

import hunt.shiro.cache.CacheManager;
import hunt.shiro.cache.CacheManagerAware;
import hunt.shiro.event.EventBus;
import hunt.shiro.event.EventBusAware;
import hunt.shiro.realm.Realm;
import hunt.shiro.util.LifecycleUtils;

import hunt.collection;
import hunt.Exceptions;
import std.range;

import hunt.logging.Logger;


/**
 * Shiro support of a {@link SecurityManager} class hierarchy based around a collection of
 * {@link hunt.shiro.realm.Realm}s.  All actual {@code SecurityManager} method implementations are left to
 * subclasses.
 *
 */
abstract class RealmSecurityManager : CachingSecurityManager {

    /**
     * Internal collection of <code>Realm</code>s used for all authentication and authorization operations.
     */
    // private Realm[] realms;
    private Realm[] realms;

    /**
     * Default no-arg constructor.
     */
    this() {
        super();
    }

    /**
     * Convenience method for applications using a single realm that merely wraps the realm in a list and then invokes
     * the {@link #setRealms} method.
     *
     * @param realm the realm to set for a single-realm application.
     */
     void setRealm(Realm realm) {
        if (realm  is null) {
            throw new IllegalArgumentException("Realm argument cannot be null");
        }
        // Realm[] realms = new ArrayList!(Realm)(1);
        // realms.add(realm);
        setRealms([realm]);
    }

    /**
     * Sets the realms managed by this <tt>SecurityManager</tt> instance.
     *
     * @param realms the realms managed by this <tt>SecurityManager</tt> instance.
     * @throws IllegalArgumentException if the realms collection is null or empty.
     */
    //  void setRealms(Realm[] realms) {
    //     if (realms  is null) {
    //         throw new IllegalArgumentException("Realms collection argument cannot be null.");
    //     }
    //     if (realms.isEmpty()) {
    //         throw new IllegalArgumentException("Realms collection argument cannot be empty.");
    //     }
    //     this.realms = realms;
    //     afterRealmsSet();
    // }

    void setRealms(Realm[] realms) {
        if (realms.empty) {
            throw new IllegalArgumentException("Realms collection argument cannot be empty.");
        }
        
        // Realm[] r = new ArrayList!(Realm)(realms);
        this.realms = realms;
        afterRealmsSet();
    }

    protected void afterRealmsSet() {
        applyCacheManagerToRealms();
        applyEventBusToRealms();
    }

    /**
     * Returns the {@link Realm Realm}s managed by this SecurityManager instance.
     *
     * @return the {@link Realm Realm}s managed by this SecurityManager instance.
     */
    Realm[] getRealms() {
        return realms;
    }

    /**
     * Sets the internal {@link #getCacheManager CacheManager} on any internal configured
     * {@link #getRealms Realms} that implement the {@link hunt.shiro.cache.CacheManagerAware CacheManagerAware} interface.
     * <p/>
     * This method is called after setting a cacheManager on this securityManager via the
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) setCacheManager} method to allow it to be propagated
     * down to all the internal Realms that would need to use it.
     * <p/>
     * It is also called after setting one or more realms via the {@link #setRealm setRealm} or
     * {@link #setRealms setRealms} methods to allow these newly available realms to be given the cache manager
     * already in use.
     */
    protected void applyCacheManagerToRealms() {
        CacheManager cacheManager = getCacheManager();
        Realm[] realms = getRealms();
        if (cacheManager !is null && !realms.empty()) {
            foreach(Realm realm ; realms) {
                CacheManagerAware ca = cast(CacheManagerAware) realm;
                if (ca !is null) {
                    ca.setCacheManager(cacheManager);
                }
            }
        }
    }

    /**
     * Sets the internal {@link #getEventBus  EventBus} on any internal configured
     * {@link #getRealms Realms} that implement the {@link EventBusAware} interface.
     * <p/>
     * This method is called after setting an eventBus on this securityManager via the
     * {@link #setEventBus(hunt.shiro.event.EventBus) setEventBus} method to allow it to be propagated
     * down to all the internal Realms that would need to use it.
     * <p/>
     * It is also called after setting one or more realms via the {@link #setRealm setRealm} or
     * {@link #setRealms setRealms} methods to allow these newly available realms to be given the EventBus
     * already in use.
     *
     */
    protected void applyEventBusToRealms() {
        EventBus eventBus = getEventBus();
        Realm[] realms = getRealms();
        if (eventBus !is null && !realms.empty()) {
            foreach(Realm realm ; realms) {
                EventBusAware eba = cast(EventBusAware)realm;
                if (eba !is null) {
                    eba.setEventBus(eventBus);
                }
            }
        }
    }

    /**
     * Simply calls {@link #applyCacheManagerToRealms() applyCacheManagerToRealms()} to allow the
     * newly set {@link hunt.shiro.cache.CacheManager CacheManager} to be propagated to the internal collection of <code>Realm</code>
     * that would need to use it.
     */
    override protected void afterCacheManagerSet() {
        super.afterCacheManagerSet();
        applyCacheManagerToRealms();
    }

    override
    protected void afterEventBusSet() {
        super.afterEventBusSet();
        applyEventBusToRealms();
    }

    override void destroy() {
        // LifecycleUtils.destroy(getRealms());
        
        Realm[] realms = getRealms();
        
        if(realms !is null) {
            foreach(Realm r; realms) {
                LifecycleUtils.destroy(cast(Object)r);
            }
        }
        this.realms = null;
        super.destroy();
    }

}
