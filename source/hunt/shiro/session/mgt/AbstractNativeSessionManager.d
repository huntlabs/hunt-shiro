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
module hunt.shiro.session.mgt.AbstractNativeSessionManager;

import hunt.shiro.session.mgt.AbstractSessionManager;
import hunt.shiro.session.mgt.DefaultSessionKey;
import hunt.shiro.session.mgt.DelegatingSession;
import hunt.shiro.session.mgt.ImmutableProxiedSession;
import hunt.shiro.session.mgt.NativeSessionManager;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.session.mgt.SessionKey;

import hunt.shiro.Exceptions;
import hunt.shiro.event.EventBus;
import hunt.shiro.event.EventBusAware;
import hunt.shiro.session.Session;

import hunt.shiro.session.SessionListener;
import hunt.shiro.util.CollectionUtils;

import hunt.Exceptions;
import hunt.collection;
import hunt.logging.ConsoleLogger;

/**
 * Abstract implementation supporting the {@link NativeSessionManager NativeSessionManager} interface, supporting
 * {@link SessionListener SessionListener}s and application of the
 * {@link #getGlobalSessionTimeout() globalSessionTimeout}.
 *
 */
abstract class AbstractNativeSessionManager : 
    AbstractSessionManager, NativeSessionManager, EventBusAware {

    private EventBus eventBus;

    private Collection!(SessionListener) listeners;

    this() {
        this.listeners = new ArrayList!(SessionListener)();
    }

     void setSessionListeners(Collection!(SessionListener) listeners) {
        this.listeners = listeners !is null ? listeners : new ArrayList!(SessionListener)();
    }

    //@SuppressWarnings({"UnusedDeclaration"})
     Collection!(SessionListener) getSessionListeners() {
        return this.listeners;
    }

    /**
     * Returns the EventBus used to publish SessionEvents.
     *
     * @return the EventBus used to publish SessionEvents.
     */
    protected EventBus getEventBus() {
        return eventBus;
    }

    /**
     * Sets the EventBus to use to publish SessionEvents.
     *
     * @param eventBus the EventBus to use to publish SessionEvents.
     */
    void setEventBus(EventBus eventBus) {
        this.eventBus = eventBus;
    }

    /**
     * Publishes events on the event bus if the event bus is non-null, otherwise does nothing.
     *
     * @param event the event to publish on the event bus if the event bus exists.
     */
    protected void publishEvent(Object event) {
        if (this.eventBus !is null) {
            this.eventBus.publish(event);
        }
    }

    Session start(SessionContext context) {
        Session session = createSession(context);
        applyGlobalSessionTimeout(session);
        onStart(session, context);
        notifyStart(session);
        //Don't expose the EIS-tier Session object to the client-tier:
        return createExposedSession(session, context);
    }

    /**
     * Creates a new {@code Session Session} instance based on the specified (possibly {@code null})
     * initialization data.  Implementing classes must manage the persistent state of the returned session such that it
     * could later be acquired via the {@link #getSession(SessionKey)} method.
     *
     * @param context the initialization data that can be used by the implementation or underlying
     *                {@link SessionFactory} when instantiating the internal {@code Session} instance.
     * @return the new {@code Session} instance.
     * @throws hunt.shiro.authz.HostUnauthorizedException
     *                                if the system access control policy restricts access based
     *                                on client location/IP and the specified hostAddress hasn't been enabled.
     * @throws AuthorizationException if the system access control policy does not allow the currently executing
     *                                caller to start sessions.
     */
    protected abstract Session createSession(SessionContext context);

    protected void applyGlobalSessionTimeout(Session session) {
        session.setTimeout(getGlobalSessionTimeout());
        onChange(session);
    }

    /**
     * Template method that allows subclasses to react to a new session being created.
     * <p/>
     * This method is invoked <em>before</em> any session listeners are notified.
     *
     * @param session the session that was just {@link #createSession created}.
     * @param context the {@link SessionContext SessionContext} that was used to start the session.
     */
    protected void onStart(Session session, SessionContext context) {
    }

     Session getSession(SessionKey key){
        Session session = lookupSession(key);
        return session !is null ? createExposedSession(session, key) : null;
    }

    private Session lookupSession(SessionKey key){
        if (key  is null) {
            throw new NullPointerException("SessionKey argument cannot be null.");
        }
        return doGetSession(key);
    }

    private Session lookupRequiredSession(SessionKey key){
        Session session = lookupSession(key);
        if (session  is null) {
            string msg = "Unable to locate required Session instance based on SessionKey [" ~ 
                (cast(Object)key).toString() ~ "].";
            throw new UnknownSessionException(msg);
        }
        return session;
    }

    protected abstract Session doGetSession(SessionKey key);

    protected Session createExposedSession(Session session, SessionContext context) {
        return new DelegatingSession(this, new DefaultSessionKey(session.getId()));
    }

    protected Session createExposedSession(Session session, SessionKey key) {
        return new DelegatingSession(this, new DefaultSessionKey(session.getId()));
    }

    /**
     * Returns the session instance to use to pass to registered {@code SessionListener}s for notification
     * that the session has been invalidated (stopped or expired).
     * <p/>
     * The default implementation returns an {@link ImmutableProxiedSession ImmutableProxiedSession} instance to ensure
     * that the specified {@code session} argument is not modified by any listeners.
     *
     * @param session the {@code Session} object being invalidated.
     * @return the {@code Session} instance to use to pass to registered {@code SessionListener}s for notification.
     */
    protected Session beforeInvalidNotification(Session session) {
        return new ImmutableProxiedSession(session);
    }

    /**
     * Notifies any interested {@link SessionListener}s that a Session has started.  This method is invoked
     * <em>after</em> the {@link #onStart onStart} method is called.
     *
     * @param session the session that has just started that will be delivered to any
     *                {@link #setSessionListeners(java.util.Collection) registered} session listeners.
     * @see SessionListener#onStart(hunt.shiro.session.Session)
     */
    protected void notifyStart(Session session) {
        foreach(SessionListener listener ; this.listeners) {
            listener.onStart(session);
        }
    }

    protected void notifyStop(Session session) {
        Session forNotification = beforeInvalidNotification(session);
        foreach(SessionListener listener ; this.listeners) {
            listener.onStop(forNotification);
        }
    }

    protected void notifyExpiration(Session session) {
        Session forNotification = beforeInvalidNotification(session);
        foreach(SessionListener listener ; this.listeners) {
            listener.onExpiration(forNotification);
        }
    }

    //  Date getStartTimestamp(SessionKey key) {
    //     return lookupRequiredSession(key).getStartTimestamp();
    // }

    //  Date getLastAccessTime(SessionKey key) {
    //     return lookupRequiredSession(key).getLastAccessTime();
    // }

     long getTimeout(SessionKey key){
        return lookupRequiredSession(key).getTimeout();
    }

     void setTimeout(SessionKey key, long maxIdleTimeInMillis){
        Session s = lookupRequiredSession(key);
        s.setTimeout(maxIdleTimeInMillis);
        onChange(s);
    }

     void touch(SessionKey key){
        Session s = lookupRequiredSession(key);
        s.touch();
        onChange(s);
    }

     string getHost(SessionKey key) {
        return lookupRequiredSession(key).getHost();
    }

     Collection!(Object) getAttributeKeys(SessionKey key) {
        Collection!(Object) c = lookupRequiredSession(key).getAttributeKeys();
        if (!CollectionUtils.isEmpty(c)) {
            return c;
        }
        return Collections.emptySet!Object();
    }

     Object getAttribute(SessionKey sessionKey, Object attributeKey){
        return lookupRequiredSession(sessionKey).getAttribute(attributeKey);
    }

     void setAttribute(SessionKey sessionKey, Object attributeKey, Object value){
        if (value  is null) {
            removeAttribute(sessionKey, attributeKey);
        } else {
            Session s = lookupRequiredSession(sessionKey);
            s.setAttribute(attributeKey, value);
            onChange(s);
        }
    }

     Object removeAttribute(SessionKey sessionKey, Object attributeKey){
        Session s = lookupRequiredSession(sessionKey);
        Object removed = s.removeAttribute(attributeKey);
        if (removed !is null) {
            onChange(s);
        }
        return removed;
    }

     bool isValid(SessionKey key) {
        try {
            checkValid(key);
            return true;
        } catch (InvalidSessionException e) {
            return false;
        }
    }

     void stop(SessionKey key){
        Session session = lookupRequiredSession(key);
        try {
            version(HUNT_DEBUG) {
                tracef("Stopping session with id [" ~ session.getId() ~ "]");
            }
            session.stop();
            onStop(session, key);
            notifyStop(session);
        } finally {
            afterStopped(session);
        }
    }

    protected void onStop(Session session, SessionKey key) {
        onStop(session);
    }

    protected void onStop(Session session) {
        onChange(session);
    }

    protected void afterStopped(Session session) {
    }

     void checkValid(SessionKey key){
        //just try to acquire it.  If there is a problem, an exception will be thrown:
        lookupRequiredSession(key);
    }

    protected void onChange(Session s) {
    }
}
