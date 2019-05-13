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
module hunt.shiro.mgt.CachingSecurityManager;

import hunt.shiro.mgt.SecurityManager;

import hunt.shiro.cache.CacheManager;
import hunt.shiro.cache.CacheManagerAware;
import hunt.shiro.event.EventBus;
import hunt.shiro.event.EventBusAware;
import hunt.shiro.event.support.DefaultEventBus;
import hunt.shiro.util.Common;
import hunt.shiro.util.LifecycleUtils;

import hunt.Exceptions;

/**
 * A very basic starting point for the SecurityManager interface that merely provides logging and caching
 * support.  All actual {@code SecurityManager} method implementations are left to subclasses.
 * <p/>
 * <b>Change in 1.0</b> - a default {@code CacheManager} instance is <em>not</em> created by default during
 * instantiation.  As caching strategies can vary greatly depending on an application's needs, a {@code CacheManager}
 * instance must be explicitly configured if caching across the framework is to be enabled.
 *
 */
abstract class CachingSecurityManager : SecurityManager, 
    Destroyable, CacheManagerAware, EventBusAware {

    /**
     * The CacheManager to use to perform caching operations to enhance performance.  Can be null.
     */
    private CacheManager cacheManager;

    /**
     * The EventBus to use to use to publish and receive events of interest during Shiro's lifecycle.
     */
    private EventBus eventBus;

    /**
     * Default no-arg constructor that will automatically attempt to initialize a default cacheManager
     */
    this() {
        //use a default event bus:
        setEventBus(new DefaultEventBus());
    }

    /**
     * Returns the CacheManager used by this SecurityManager.
     *
     * @return the cacheManager used by this SecurityManager
     */
     CacheManager getCacheManager() {
        return cacheManager;
    }

    /**
     * Sets the CacheManager used by this {@code SecurityManager} and potentially any of its
     * children components.
     * <p/>
     * After the cacheManager attribute has been set, the template method
     * {@link #afterCacheManagerSet afterCacheManagerSet()} is executed to allow subclasses to adjust when a
     * cacheManager is available.
     *
     * @param cacheManager the CacheManager used by this {@code SecurityManager} and potentially any of its
     *                     children components.
     */
     void setCacheManager(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
        afterCacheManagerSet();
    }

    /**
     * Template callback to notify subclasses that a
     * {@link hunt.shiro.cache.CacheManager CacheManager} has been set and is available for use via the
     * {@link #getCacheManager getCacheManager()} method.
     */
    protected void afterCacheManagerSet() {
        applyEventBusToCacheManager();
    }

    /**
     * Returns the {@code EventBus} used by this SecurityManager and potentially any of its children components.
     *
     * @return the {@code EventBus} used by this SecurityManager and potentially any of its children components.
     */
     EventBus getEventBus() {
        return eventBus;
    }

    /**
     * Sets the EventBus used by this {@code SecurityManager} and potentially any of its
     * children components.
     * <p/>
     * After the eventBus attribute has been set, the template method
     * {@link #afterEventBusSet() afterEventBusSet()} is executed to allow subclasses to adjust when a
     * eventBus is available.
     *
     * @param eventBus the EventBus used by this {@code SecurityManager} and potentially any of its
     *                     children components.
     */
     void setEventBus(EventBus eventBus) {
        this.eventBus = eventBus;
        afterEventBusSet();
    }

    /**
     */
    protected void applyEventBusToCacheManager() {
        auto cacheManagerCast = cast(EventBusAware)this.cacheManager;
        if (this.eventBus !is null && this.cacheManager !is null && cacheManagerCast !is null) {
            cacheManagerCast.setEventBus(this.eventBus);
        }
    }

    /**
     * Template callback to notify subclasses that an {@link EventBus EventBus} has been set and is available for use
     * via the {@link #getEventBus() getEventBus()} method.
     *
     */
    protected void afterEventBusSet() {
        applyEventBusToCacheManager();
    }

    /**
     * Destroys the {@link #getCacheManager() cacheManager} via {@link LifecycleUtils#destroy LifecycleUtils.destroy}.
     */
     void destroy() {
        LifecycleUtils.destroy(cast(Object)getCacheManager());
        this.cacheManager = null;
        LifecycleUtils.destroy(cast(Object)getEventBus());
        this.eventBus = new DefaultEventBus();
    }

}
