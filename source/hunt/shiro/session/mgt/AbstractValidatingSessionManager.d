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
module hunt.shiro.session.mgt.AbstractValidatingSessionManager;

import hunt.shiro.authz.AuthorizationException;
import hunt.shiro.session.ExpiredSessionException;
import hunt.shiro.session.InvalidSessionException;
import hunt.shiro.session.Session;
import hunt.shiro.session.UnknownSessionException;
import hunt.shiro.util.Destroyable;
import hunt.shiro.util.LifecycleUtils;
import hunt.logger;

import hunt.collection;


/**
 * Default business-tier implementation of the {@link ValidatingSessionManager} interface.
 *
 */
abstract class AbstractValidatingSessionManager : AbstractNativeSessionManager
        implements ValidatingSessionManager, Destroyable {

    //TODO - complete JavaDoc



    /**
     * The default interval at which sessions will be validated (1 hour);
     * This can be overridden by calling {@link #setSessionValidationInterval(long)}
     */
     static final long DEFAULT_SESSION_VALIDATION_INTERVAL = MILLIS_PER_HOUR;

    protected bool sessionValidationSchedulerEnabled;

    /**
     * Scheduler used to validate sessions on a regular basis.
     */
    protected SessionValidationScheduler sessionValidationScheduler;

    protected long sessionValidationInterval;

     AbstractValidatingSessionManager() {
        this.sessionValidationSchedulerEnabled = true;
        this.sessionValidationInterval = DEFAULT_SESSION_VALIDATION_INTERVAL;
    }

     bool isSessionValidationSchedulerEnabled() {
        return sessionValidationSchedulerEnabled;
    }

    //@SuppressWarnings({"UnusedDeclaration"})
     void setSessionValidationSchedulerEnabled(bool sessionValidationSchedulerEnabled) {
        this.sessionValidationSchedulerEnabled = sessionValidationSchedulerEnabled;
    }

     void setSessionValidationScheduler(SessionValidationScheduler sessionValidationScheduler) {
        this.sessionValidationScheduler = sessionValidationScheduler;
    }

     SessionValidationScheduler getSessionValidationScheduler() {
        return sessionValidationScheduler;
    }

    private void enableSessionValidationIfNecessary() {
        SessionValidationScheduler scheduler = getSessionValidationScheduler();
        if (isSessionValidationSchedulerEnabled() && (scheduler  is null || !scheduler.isEnabled())) {
            enableSessionValidation();
        }
    }

    /**
     * If using the underlying default <tt>SessionValidationScheduler</tt> (that is, the
     * {@link #setSessionValidationScheduler(SessionValidationScheduler) setSessionValidationScheduler} method is
     * never called) , this method allows one to specify how
     * frequently session should be validated (to check for orphans).  The default value is
     * {@link #DEFAULT_SESSION_VALIDATION_INTERVAL}.
     * <p/>
     * If you override the default scheduler, it is assumed that overriding instance 'knows' how often to
     * validate sessions, and this attribute will be ignored.
     * <p/>
     * Unless this method is called, the default value is {@link #DEFAULT_SESSION_VALIDATION_INTERVAL}.
     *
     * @param sessionValidationInterval the time in milliseconds between checking for valid sessions to reap orphans.
     */
     void setSessionValidationInterval(long sessionValidationInterval) {
        this.sessionValidationInterval = sessionValidationInterval;
    }

     long getSessionValidationInterval() {
        return sessionValidationInterval;
    }

    override
    protected final Session doGetSession(final SessionKey key){
        enableSessionValidationIfNecessary();

        tracef("Attempting to retrieve session with key {}", key);

        Session s = retrieveSession(key);
        if (s != null) {
            validate(s, key);
        }
        return s;
    }

    /**
     * Looks up a session from the underlying data store based on the specified session key.
     *
     * @param key the session key to use to look up the target session.
     * @return the session identified by {@code sessionId}.
     * @throws UnknownSessionException if there is no session identified by {@code sessionId}.
     */
    protected abstract Session retrieveSession(SessionKey key);

    protected Session createSession(SessionContext context){
        enableSessionValidationIfNecessary();
        return doCreateSession(context);
    }

    protected abstract Session doCreateSession(SessionContext initData);

    protected void validate(Session session, SessionKey key){
        try {
            doValidate(session);
        } catch (ExpiredSessionException ese) {
            onExpiration(session, ese, key);
            throw ese;
        } catch (InvalidSessionException ise) {
            onInvalidation(session, ise, key);
            throw ise;
        }
    }

    protected void onExpiration(Session s, ExpiredSessionException ese, SessionKey key) {
        tracef("Session with id [{}] has expired.", s.getId());
        try {
            onExpiration(s);
            notifyExpiration(s);
        } finally {
            afterExpired(s);
        }
    }

    protected void onExpiration(Session session) {
        onChange(session);
    }

    protected void afterExpired(Session session) {
    }

    protected void onInvalidation(Session s, InvalidSessionException ise, SessionKey key) {
        if (ise instanceof ExpiredSessionException) {
            onExpiration(s, (ExpiredSessionException) ise, key);
            return;
        }
        tracef("Session with id [{}] is invalid.", s.getId());
        try {
            onStop(s);
            notifyStop(s);
        } finally {
            afterStopped(s);
        }
    }

    protected void doValidate(Session session){
        if (session instanceof ValidatingSession) {
            ((ValidatingSession) session).validate();
        } else {
            string msg = "The " ~ typeid(this).name ~ " implementation only supports validating " ~
                    "Session implementations of the " ~ typeid(ValidatingSession).name ~ " interface.  " ~
                    "Please either implement this interface in your session implementation or override the " ~
                    typeid(AbstractValidatingSessionManager).name ~ ".doValidate(Session) method to perform validation.";
            throw new IllegalStateException(msg);
        }
    }

    /**
     * Subclass template hook in case per-session timeout is not based on
     * {@link hunt.shiro.session.Session#getTimeout()}.
     * <p/>
     * <p>This implementation merely returns {@link hunt.shiro.session.Session#getTimeout()}</p>
     *
     * @param session the session for which to determine session timeout.
     * @return the time in milliseconds the specified session may remain idle before expiring.
     */
    protected long getTimeout(Session session) {
        return session.getTimeout();
    }

    protected SessionValidationScheduler createSessionValidationScheduler() {
        ExecutorServiceSessionValidationScheduler scheduler;

        version(HUNT_DEBUG) {
            tracef("No sessionValidationScheduler set.  Attempting to create default instance.");
        }
        scheduler = new ExecutorServiceSessionValidationScheduler(this);
        scheduler.setInterval(getSessionValidationInterval());
        version(HUNT_DEBUG) {
            tracef("Created default SessionValidationScheduler instance of type [" ~ typeid(scheduler).name ~ "].");
        }
        return scheduler;
    }

    protected synchronized void enableSessionValidation() {
        SessionValidationScheduler scheduler = getSessionValidationScheduler();
        if (scheduler  is null) {
            scheduler = createSessionValidationScheduler();
            setSessionValidationScheduler(scheduler);
        }
        // it is possible that that a scheduler was already created and set via 'setSessionValidationScheduler()'
        // but would not have been enabled/started yet
        if (!scheduler.isEnabled()) {
            version(HUNT_DEBUG) {
                info("Enabling session validation scheduler...");
            }
            scheduler.enableSessionValidation();
            afterSessionValidationEnabled();
        }
    }

    protected void afterSessionValidationEnabled() {
    }

    protected synchronized void disableSessionValidation() {
        beforeSessionValidationDisabled();
        SessionValidationScheduler scheduler = getSessionValidationScheduler();
        if (scheduler != null) {
            try {
                scheduler.disableSessionValidation();
                version(HUNT_DEBUG) {
                    info("Disabled session validation scheduler.");
                }
            } catch (Exception e) {
                version(HUNT_DEBUG) {
                    string msg = "Unable to disable SessionValidationScheduler.  Ignoring (shutting down)...";
                    tracef(msg, e);
                }
            }
            LifecycleUtils.destroy(scheduler);
            setSessionValidationScheduler(null);
        }
    }

    protected void beforeSessionValidationDisabled() {
    }

     void destroy() {
        disableSessionValidation();
    }

    /**
     * @see ValidatingSessionManager#validateSessions()
     */
     void validateSessions() {
        version(HUNT_DEBUG) {
            info("Validating all active sessions...");
        }

        int invalidCount = 0;

        Collection!(Session) activeSessions = getActiveSessions();

        if (activeSessions != null && !activeSessions.isEmpty()) {
            foreach(Session s ; activeSessions) {
                try {
                    //simulate a lookup key to satisfy the method signature.
                    //this could probably stand to be cleaned up in future versions:
                    SessionKey key = new DefaultSessionKey(s.getId());
                    validate(s, key);
                } catch (InvalidSessionException e) {
                    version(HUNT_DEBUG) {
                        bool expired = (e instanceof ExpiredSessionException);
                        string msg = "Invalidated session with id [" ~ s.getId() ~ "]" ~
                                (expired ? " (expired)" : " (stopped)");
                        tracef(msg);
                    }
                    invalidCount++;
                }
            }
        }

        version(HUNT_DEBUG) {
            string msg = "Finished session validation.";
            if (invalidCount > 0) {
                msg += "  [" ~ invalidCount ~ "] sessions were stopped.";
            } else {
                msg += "  No sessions were stopped.";
            }
            info(msg);
        }
    }

    protected abstract Collection!(Session) getActiveSessions();
}
