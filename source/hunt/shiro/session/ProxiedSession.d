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
module hunt.shiro.session.ProxiedSession;

import hunt.shiro.session.Session;

import hunt.Exceptions;
import hunt.util.Common;
import hunt.collection;
// // import java.util.Date;

/**
 * Simple <code>Session</code> implementation that immediately delegates all corresponding calls to an
 * underlying proxied session instance.
 * <p/>
 * This class is mostly useful for framework subclassing to intercept certain <code>Session</code> calls
 * and perform additional logic.
 *
 */
class ProxiedSession : Session {

    /**
     * The proxied instance
     */
    protected Session session;

    /**
     * Constructs an instance that proxies the specified <code>target</code>.  Subclasses may access this
     * target via the <code>protected final 'session'</code> attribute, i.e. <code>this.session</code>.
     *
     * @param target the specified target <code>Session</code> to proxy.
     */
     this(Session target) {
        if (target  is null) {
            throw new IllegalArgumentException("Target session to proxy cannot be null.");
        }
        session = target;
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
    string getId() {
        return session.getId();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
    //  Date getStartTimestamp() {
    //     return session.getStartTimestamp();
    // }

    // /**
    //  * Immediately delegates to the underlying proxied session.
    //  */
    //  Date getLastAccessTime() {
    //     return session.getLastAccessTime();
    // }

    /**
     * Immediately delegates to the underlying proxied session.
     */
    long getTimeout(){
        return session.getTimeout();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
    void setTimeout(long maxIdleTimeInMillis){
        session.setTimeout(maxIdleTimeInMillis);
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     string getHost() {
        return session.getHost();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     void touch(){
        session.touch();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     void stop(){
        session.stop();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     Collection!(Object) getAttributeKeys(){
        return session.getAttributeKeys();
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     Object getAttribute(Object key){
        return session.getAttribute(key);
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     void setAttribute(Object key, Object value){
        session.setAttribute(key, value);
    }

    /**
     * Immediately delegates to the underlying proxied session.
     */
     Object removeAttribute(Object key){
        return session.removeAttribute(key);
    }

}
