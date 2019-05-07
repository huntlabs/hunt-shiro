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
module hunt.shiro.session.mgt.DefaultSessionManager;

import hunt.shiro.cache.CacheManager;
import hunt.shiro.cache.CacheManagerAware;
import hunt.shiro.session.Session;
import hunt.shiro.session.UnknownSessionException;
import hunt.shiro.session.mgt.eis.MemorySessionDAO;
import hunt.shiro.session.mgt.eis.SessionDAO;
import hunt.logger;

import java.io.Serializable;
import hunt.collection;
import java.util.Collections;
import java.util.Date;

/**
 * Default business-tier implementation of a {@link ValidatingSessionManager}.  All session CRUD operations are
 * delegated to an internal {@link SessionDAO}.
 *
 */
class DefaultSessionManager : AbstractValidatingSessionManager implements CacheManagerAware {

    //TODO - complete JavaDoc



    private SessionFactory sessionFactory;

    protected SessionDAO sessionDAO;  //todo - move SessionDAO up to AbstractValidatingSessionManager?

    private CacheManager cacheManager;

    private bool deleteInvalidSessions;

     DefaultSessionManager() {
        this.deleteInvalidSessions = true;
        this.sessionFactory = new SimpleSessionFactory();
        this.sessionDAO = new MemorySessionDAO();
    }

     void setSessionDAO(SessionDAO sessionDAO) {
        this.sessionDAO = sessionDAO;
        applyCacheManagerToSessionDAO();
    }

     SessionDAO getSessionDAO() {
        return this.sessionDAO;
    }

    /**
     * Returns the {@code SessionFactory} used to generate new {@link Session} instances.  The default instance
     * is a {@link SimpleSessionFactory}.
     *
     * @return the {@code SessionFactory} used to generate new {@link Session} instances.
     */
     SessionFactory getSessionFactory() {
        return sessionFactory;
    }

    /**
     * Sets the {@code SessionFactory} used to generate new {@link Session} instances.  The default instance
     * is a {@link SimpleSessionFactory}.
     *
     * @param sessionFactory the {@code SessionFactory} used to generate new {@link Session} instances.
     */
     void setSessionFactory(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    /**
     * Returns {@code true} if sessions should be automatically deleted after they are discovered to be invalid,
     * {@code false} if invalid sessions will be manually deleted by some process external to Shiro's control.  The
     * default is {@code true} to ensure no orphans exist in the underlying data store.
     * <h4>Usage</h4>
     * It is ok to set this to {@code false} <b><em>ONLY</em></b> if you have some other process that you manage yourself
     * that periodically deletes invalid sessions from the backing data store over time, such as via a Quartz or Cron
     * job.  If you do not do this, the invalid sessions will become 'orphans' and fill up the data store over time.
     * <p/>
     * This property is provided because some systems need the ability to perform querying/reporting against sessions in
     * the data store, even after they have stopped or expired.  Setting this attribute to {@code false} will allow
     * such querying, but with the caveat that the application developer/configurer deletes the sessions themselves by
     * some other means (cron, quartz, etc).
     *
     * @return {@code true} if sessions should be automatically deleted after they are discovered to be invalid,
     *         {@code false} if invalid sessions will be manually deleted by some process external to Shiro's control.
     */
     bool isDeleteInvalidSessions() {
        return deleteInvalidSessions;
    }

    /**
     * Sets whether or not sessions should be automatically deleted after they are discovered to be invalid.  Default
     * value is {@code true} to ensure no orphans will exist in the underlying data store.
     * <h4>WARNING</h4>
     * Only set this value to {@code false} if you are manually going to delete sessions yourself by some process
     * (quartz, cron, etc) external to Shiro's control.  See the
     * {@link #isDeleteInvalidSessions() isDeleteInvalidSessions()} JavaDoc for more.
     *
     * @param deleteInvalidSessions whether or not sessions should be automatically deleted after they are discovered
     *                              to be invalid.
     */
    //@SuppressWarnings({"UnusedDeclaration"})
     void setDeleteInvalidSessions(bool deleteInvalidSessions) {
        this.deleteInvalidSessions = deleteInvalidSessions;
    }

     void setCacheManager(CacheManager cacheManager) {
        this.cacheManager = cacheManager;
        applyCacheManagerToSessionDAO();
    }

    /**
     * Sets the internal {@code CacheManager} on the {@code SessionDAO} if it implements the
     * {@link hunt.shiro.cache.CacheManagerAware CacheManagerAware} interface.
     * <p/>
     * This method is called after setting a cacheManager via the
     * {@link #setCacheManager(hunt.shiro.cache.CacheManager) setCacheManager} method <em>em</em> when
     * setting a {@code SessionDAO} via the {@link #setSessionDAO} method to allow it to be propagated
     * in either case.
     *
     */
    private void applyCacheManagerToSessionDAO() {
        if (this.cacheManager != null && this.sessionDAO != null && this.sessionDAO instanceof CacheManagerAware) {
            ((CacheManagerAware) this.sessionDAO).setCacheManager(this.cacheManager);
        }
    }

    protected Session doCreateSession(SessionContext context) {
        Session s = newSessionInstance(context);
        if (log.isTraceEnabled()) {
            log.trace("Creating session for host {}", s.getHost());
        }
        create(s);
        return s;
    }

    protected Session newSessionInstance(SessionContext context) {
        return getSessionFactory().createSession(context);
    }

    /**
     * Persists the given session instance to an underlying EIS (Enterprise Information System).  This implementation
     * delegates and calls
     * <code>this.{@link SessionDAO sessionDAO}.{@link SessionDAO#create(hunt.shiro.session.Session) create}(session);<code>
     *
     * @param session the Session instance to persist to the underlying EIS.
     */
    protected void create(Session session) {
        if (log.isDebugEnabled()) {
            tracef("Creating new EIS record for new session instance [" ~ session ~ "]");
        }
        sessionDAO.create(session);
    }

    override
    protected void onStop(Session session) {
        if (session instanceof SimpleSession) {
            SimpleSession ss = (SimpleSession) session;
            Date stopTs = ss.getStopTimestamp();
            ss.setLastAccessTime(stopTs);
        }
        onChange(session);
    }

    override
    protected void afterStopped(Session session) {
        if (isDeleteInvalidSessions()) {
            delete(session);
        }
    }

    protected void onExpiration(Session session) {
        if (session instanceof SimpleSession) {
            ((SimpleSession) session).setExpired(true);
        }
        onChange(session);
    }

    override
    protected void afterExpired(Session session) {
        if (isDeleteInvalidSessions()) {
            delete(session);
        }
    }

    protected void onChange(Session session) {
        sessionDAO.update(session);
    }

    protected Session retrieveSession(SessionKey sessionKey){
        Serializable sessionId = getSessionId(sessionKey);
        if (sessionId  is null) {
            tracef("Unable to resolve session ID from SessionKey [{}].  Returning null to indicate a " ~
                    "session could not be found.", sessionKey);
            return null;
        }
        Session s = retrieveSessionFromDataSource(sessionId);
        if (s  is null) {
            //session ID was provided, meaning one is expected to be found, but we couldn't find one:
            string msg = "Could not find session with ID [" ~ sessionId ~ "]";
            throw new UnknownSessionException(msg);
        }
        return s;
    }

    protected Serializable getSessionId(SessionKey sessionKey) {
        return sessionKey.getSessionId();
    }

    protected Session retrieveSessionFromDataSource(Serializable sessionId){
        return sessionDAO.readSession(sessionId);
    }

    protected void delete(Session session) {
        sessionDAO.delete(session);
    }

    protected Collection!(Session) getActiveSessions() {
        Collection!(Session) active = sessionDAO.getActiveSessions();
        return active != null ? active : Collections.<Session>emptySet();
    }

}
