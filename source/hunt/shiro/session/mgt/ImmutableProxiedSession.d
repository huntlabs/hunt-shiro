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
module hunt.shiro.session.mgt.ImmutableProxiedSession;

import hunt.shiro.Exceptions;
import hunt.shiro.session.ProxiedSession;
import hunt.shiro.session.Session;

import hunt.Exceptions;

/**
 * Implementation of the {@link Session Session} interface that proxies another <code>Session</code>, but does not
 * allow any 'write' operations to the underlying session. It allows 'read' operations only.
 * <p/>
 * The <code>Session</code> write operations are defined as follows.  A call to any of these methods on this
 * proxy will immediately result in an {@link InvalidSessionException} being thrown:
 * <ul>
 * <li>{@link Session#setTimeout(long) Session.setTimeout(long)}</li>
 * <li>{@link Session#touch() Session.touch()}</li>
 * <li>{@link Session#stop() Session.stop()}</li>
 * <li>{@link Session#setAttribute(Object, Object) Session.setAttribute(key,value)}</li>
 * <li>{@link Session#removeAttribute(Object) Session.removeAttribute(key)}</li>
 * </ul>
 * Any other method invocation not listed above will result in a corresponding call to the underlying <code>Session</code>.
 *
 */
class ImmutableProxiedSession : ProxiedSession {

    /**
     * Constructs a new instance of this class proxying the specified <code>Session</code>.
     *
     * @param target the target <code>Session</code> to proxy.
     */
    this(Session target) {
        super(target);
    }

    /**
     * Simply<code>InvalidSessionException</code> indicating that this proxy is immutable.  Used
     * only in the Session's 'write' methods documented in the top class-level JavaDoc.
     *
     * @throws InvalidSessionException in all cases - used by the Session 'write' method implementations.
     */
    protected void throwImmutableException(){
        string msg = "This session is immutable and read-only - it cannot be altered.  This is usually because " ~
                "the session has been stopped or expired already.";
        throw new InvalidSessionException(msg);
    }

    /**
     * Immediately {@link #throwImmutableException() throws} an <code>InvalidSessionException</code> in all
     * cases because this proxy is immutable.
     */
    override void setTimeout(long maxIdleTimeInMillis){
        throwImmutableException();
    }

    /**
     * Immediately {@link #throwImmutableException() throws} an <code>InvalidSessionException</code> in all
     * cases because this proxy is immutable.
     */
    override void touch(){
        throwImmutableException();
    }

    /**
     * Immediately {@link #throwImmutableException() throws} an <code>InvalidSessionException</code> in all
     * cases because this proxy is immutable.
     */
    override void stop(){
        throwImmutableException();
    }

    /**
     * Immediately {@link #throwImmutableException() throws} an <code>InvalidSessionException</code> in all
     * cases because this proxy is immutable.
     */
    override void setAttribute(Object key, Object value){
        throwImmutableException();
    }

    /**
     * Immediately {@link #throwImmutableException() throws} an <code>InvalidSessionException</code> in all
     * cases because this proxy is immutable.
     */
    override Object removeAttribute(Object key){
        throwImmutableException();
        //we should never ever reach this point due to the exception being thrown.
        throw new InternalError("This code should never execute - please report this as a bug!");
    }
}
