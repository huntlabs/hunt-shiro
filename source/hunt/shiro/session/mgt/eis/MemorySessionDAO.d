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
module hunt.shiro.session.mgt.eis.MemorySessionDAO;

import hunt.shiro.session.mgt.eis.AbstractSessionDAO;

import hunt.shiro.session.Session;
import hunt.shiro.Exceptions;
import hunt.shiro.util.CollectionUtils;

import hunt.collection;
import hunt.Exceptions;
import hunt.logging.Logger;
import hunt.util.Common;

/**
 * Simple memory-based implementation of the SessionDAO that stores all of its sessions in an in-memory
 * {@link ConcurrentMap}.  <b>This implementation does not page to disk and is therefore unsuitable for applications
 * that could experience a large amount of sessions</b> and would therefore cause {@code OutOfMemoryException}s.  It is
 * <em>not</em> recommended for production use in most environments.
 * <h2>Memory Restrictions</h2>
 * If your application is expected to host many sessions beyond what can be stored in the
 * memory available to the JVM, it is highly recommended to use a different {@code SessionDAO} implementation which
 * uses a more expansive or permanent backing data store.
 * <p/>
 * In this case, it is recommended to instead use a custom
 * {@link CachingSessionDAO} implementation that communicates with a higher-capacity data store of your choice
 * (file system, database, etc).
 * <h2>Changes in 1.0</h2>
 * This implementation prior to 1.0 used to subclass the {@link CachingSessionDAO}, but this caused problems with many
 * cache implementations that would expunge entries due to TTL settings, resulting in Sessions that would be randomly
 * (and permanently) lost.  The Shiro 1.0 release refactored this implementation to be 100% memory-based (without
 * {@code Cache} usage to avoid this problem.
 *
 * @see CachingSessionDAO
 */
class MemorySessionDAO : AbstractSessionDAO {

    private Map!(string, Session) sessions;

    this() {
        this.sessions = new HashMap!(string, Session)();
    }

    override protected string doCreate(Session session) {
        string sessionId = generateSessionId(session);
        assignSessionId(session, sessionId);
        storeSession(sessionId, session);
        return sessionId;
    }

    protected Session storeSession(string id, Session session) {
        if (id is null) {
            throw new NullPointerException("id argument cannot be null.");
        }
        return sessions.putIfAbsent(id, session);
    }

    override protected Session doReadSession(string sessionId) {
        return sessions.get(sessionId);
    }

     void update(Session session){
        storeSession(session.getId(), session);
    }

     void remove(Session session) {
        if (session is null) {
            throw new NullPointerException("session argument cannot be null.");
        }
        string id = session.getId();
        if (id !is null) {
            sessions.remove(id);
        }
    }

    Session[] getActiveSessions() {
        Session[] values = sessions.values();
        return values;
    }

}
