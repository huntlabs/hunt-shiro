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
module hunt.shiro.session.mgt.DelegatingSession;

import hunt.shiro.session.InvalidSessionException;
import hunt.shiro.session.Session;

import hunt.util.Common;
import hunt.collection;
import java.util.Date;

/**
 * A DelegatingSession is a client-tier representation of a server side
 * {@link hunt.shiro.session.Session Session}.
 * This implementation is basically a proxy to a server-side {@link NativeSessionManager NativeSessionManager},
 * which will return the proper results for each method call.
 * <p/>
 * <p>A <tt>DelegatingSession</tt> will cache data when appropriate to avoid a remote method invocation,
 * only communicating with the server when necessary.
 * <p/>
 * <p>Of course, if used in-process with a NativeSessionManager business POJO, as might be the case in a
 * web-based application where the web classes and server-side business pojos exist in the same
 * JVM, a remote method call will not be incurred.
 *
 */
class DelegatingSession : Session, Serializable {

    //TODO - complete JavaDoc

    private final SessionKey key;

    //cached fields to avoid a server-side method call if out-of-process:
    private Date startTimestamp = null;
    private string host = null;

    /**
     * Handle to the target NativeSessionManager that will support the delegate calls.
     */
    private final  NativeSessionManager sessionManager;


    this(NativeSessionManager sessionManager, SessionKey key) {
        if (sessionManager  is null) {
            throw new IllegalArgumentException("sessionManager argument cannot be null.");
        }
        if (key  is null) {
            throw new IllegalArgumentException("sessionKey argument cannot be null.");
        }
        if (key.getSessionId()  is null) {
            string msg = "The " ~ typeid(DelegatingSession).name ~ " implementation requires that the " ~
                    "SessionKey argument returns a non-null sessionId to support the " ~
                    "Session.getId() invocations.";
            throw new IllegalArgumentException(msg);
        }
        this.sessionManager = sessionManager;
        this.key = key;
    }

    /**
     * @see hunt.shiro.session.Session#getId()
     */
     Serializable getId() {
        return key.getSessionId();
    }

    /**
     * @see hunt.shiro.session.Session#getStartTimestamp()
     */
     Date getStartTimestamp() {
        if (startTimestamp  is null) {
            startTimestamp = sessionManager.getStartTimestamp(key);
        }
        return startTimestamp;
    }

    /**
     * @see hunt.shiro.session.Session#getLastAccessTime()
     */
     Date getLastAccessTime() {
        //can't cache - only business pojo knows the accurate time:
        return sessionManager.getLastAccessTime(key);
    }

     long getTimeout(){
        return sessionManager.getTimeout(key);
    }

     void setTimeout(long maxIdleTimeInMillis){
        sessionManager.setTimeout(key, maxIdleTimeInMillis);
    }

     string getHost() {
        if (host  is null) {
            host = sessionManager.getHost(key);
        }
        return host;
    }

    /**
     * @see hunt.shiro.session.Session#touch()
     */
     void touch(){
        sessionManager.touch(key);
    }

    /**
     * @see hunt.shiro.session.Session#stop()
     */
     void stop(){
        sessionManager.stop(key);
    }

    /**
     * @see hunt.shiro.session.Session#getAttributeKeys
     */
     Collection!(Object) getAttributeKeys(){
        return sessionManager.getAttributeKeys(key);
    }

    /**
     * @see hunt.shiro.session.Session#getAttribute(Object key)
     */
     Object getAttribute(Object attributeKey){
        return sessionManager.getAttribute(this.key, attributeKey);
    }

    /**
     * @see Session#setAttribute(Object key, Object value)
     */
     void setAttribute(Object attributeKey, Object value){
        if (value  is null) {
            removeAttribute(attributeKey);
        } else {
            sessionManager.setAttribute(this.key, attributeKey, value);
        }
    }

    /**
     * @see Session#removeAttribute(Object key)
     */
     Object removeAttribute(Object attributeKey){
        return sessionManager.removeAttribute(this.key, attributeKey);
    }
}
