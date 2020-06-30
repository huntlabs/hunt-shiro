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
module hunt.shiro.mgt.SessionsSecurityManager;

import hunt.shiro.mgt.AuthorizingSecurityManager;

import hunt.shiro.Exceptions;
import hunt.shiro.cache.CacheManagerAware;
import hunt.shiro.event.EventBus;
import hunt.shiro.event.EventBusAware;
import hunt.shiro.session.Session;

import hunt.shiro.session.mgt.DefaultSessionManager;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.session.mgt.SessionKey;
import hunt.shiro.session.mgt.SessionManager;
import hunt.shiro.util.LifecycleUtils;

/**
 * Shiro support of a {@link SecurityManager} class hierarchy that delegates all
 * {@link hunt.shiro.session.Session session} operations to a wrapped
 * {@link hunt.shiro.session.mgt.SessionManager SessionManager} instance.  That is, this class implements the
 * methods in the {@link SessionManager SessionManager} interface, but in reality, those methods are merely
 * passthrough calls to the underlying 'real' {@code SessionManager} instance.
 * <p/>
 * The remaining {@code SecurityManager} methods not implemented by this class or its parents are left to be
 * implemented by subclasses.
 * <p/>
 * In keeping with the other classes in this hierarchy and Shiro's desire to minimize configuration whenever
 * possible, suitable default instances for all dependencies will be created upon instantiation.
 *
 */
abstract class SessionsSecurityManager : AuthorizingSecurityManager {

    /**
     * The internal delegate <code>SessionManager</code> used by this security manager that manages all the
     * application's {@link Session Session}s.
     */
    private SessionManager sessionManager;

    /**
     * Default no-arg constructor, internally creates a suitable default {@link SessionManager SessionManager} delegate
     * instance.
     */
    this() {
        super();
        this.sessionManager = new DefaultSessionManager();
        applyCacheManagerToSessionManager();
    }

    /**
     * Sets the underlying delegate {@link SessionManager} instance that will be used to support this implementation's
     * <tt>SessionManager</tt> method calls.
     * <p/>
     * This <tt>SecurityManager</tt> implementation does not provide logic to support the inherited
     * <tt>SessionManager</tt> interface, but instead delegates these calls to an internal
     * <tt>SessionManager</tt> instance.
     * <p/>
     * If a <tt>SessionManager</tt> instance is not set, a default one will be automatically created and
     * initialized appropriately for the the existing runtime environment.
     *
     * @param sessionManager delegate instance to use to support this manager's <tt>SessionManager</tt> method calls.
     */
    void setSessionManager(SessionManager sessionManager) {
        this.sessionManager = sessionManager;
        afterSessionManagerSet();
    }

    protected void afterSessionManagerSet() {
        applyCacheManagerToSessionManager();
        applyEventBusToSessionManager();
    }

    /**
     * Returns this security manager's internal delegate {@link SessionManager SessionManager}.
     *
     * @return this security manager's internal delegate {@link SessionManager SessionManager}.
     * @see #setSessionManager(hunt.shiro.session.mgt.SessionManager) setSessionManager
     */
    SessionManager getSessionManager() {
        return this.sessionManager;
    }

    /**
     * Calls {@link hunt.shiro.mgt.AuthorizingSecurityManager#afterCacheManagerSet() super.afterCacheManagerSet()} and then immediately calls
     * {@link #applyCacheManagerToSessionManager() applyCacheManagerToSessionManager()} to ensure the
     * <code>CacheManager</code> is applied to the SessionManager as necessary.
     */
    override protected void afterCacheManagerSet() {
        super.afterCacheManagerSet();
        applyCacheManagerToSessionManager();
    }

    /**
     * Sets any configured EventBus on the SessionManager if necessary.
     *
     */
    override protected void afterEventBusSet() {
        super.afterEventBusSet();
        applyEventBusToSessionManager();
    }

    /**
     * Ensures the internal delegate <code>SessionManager</code> is injected with the newly set
     * {@link #setCacheManager CacheManager} so it may use it for its internal caching needs.
     * <p/>
     * Note:  This implementation only injects the CacheManager into the SessionManager if the SessionManager
     * instance implements the {@link CacheManagerAware CacheManagerAware} interface.
     */
    protected void applyCacheManagerToSessionManager() {
        CacheManagerAware cma = cast(CacheManagerAware) this.sessionManager;
        if (cma !is null) {
            cma.setCacheManager(getCacheManager());
        }
    }

    /**
     * Ensures the internal delegate <code>SessionManager</code> is injected with the newly set
     * {@link #setEventBus EventBus} so it may use it for its internal event needs.
     * <p/>
     * Note: This implementation only injects the EventBus into the SessionManager if the SessionManager
     * instance implements the {@link EventBusAware EventBusAware} interface.
     *
     */
    protected void applyEventBusToSessionManager() {
        EventBus eventBus = getEventBus();
        EventBusAware eba = cast(EventBusAware) this.sessionManager;
        if (eventBus !is null && eba !is null) {
            eba.setEventBus(eventBus);
        }
    }

    Session start(SessionContext context) {
        return this.sessionManager.start(context);
    }

    Session getSession(SessionKey key) {
        return this.sessionManager.getSession(key);
    }

    override void destroy() {
        LifecycleUtils.destroy(cast(Object) getSessionManager());
        this.sessionManager = null;
        super.destroy();
    }
}
