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
module hunt.shiro.subject.support.SubjectThreadState;

import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.subject.Subject;
import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.ThreadContext;
import hunt.shiro.util.ThreadState;

import java.util.Map;

/**
 * Manages thread-state for {@link Subject Subject} access (supporting
 * {@code SecurityUtils.}{@link hunt.shiro.SecurityUtils#getSubject() getSubject()} calls)
 * during a thread's execution.
 * <p/>
 * The {@link #bind bind} method will bind a {@link Subject} and a
 * {@link hunt.shiro.mgt.SecurityManager SecurityManager} to the {@link ThreadContext} so they can be retrieved
 * from the {@code ThreadContext} later by any
 * {@code SecurityUtils.}{@link hunt.shiro.SecurityUtils#getSubject() getSubject()} calls that might occur during
 * the thread's execution.
 *
 */
class SubjectThreadState : ThreadState {

    private Map!(Object, Object) originalResources;

    private final Subject subject;
    private  SecurityManager securityManager;

    /**
     * Creates a new {@code SubjectThreadState} that will bind and unbind the specified {@code Subject} to the
     * thread
     *
     * @param subject the {@code Subject} instance to bind and unbind from the {@link ThreadContext}.
     */
     SubjectThreadState(Subject subject) {
        if (subject  is null) {
            throw new IllegalArgumentException("Subject argument cannot be null.");
        }
        this.subject = subject;

        SecurityManager securityManager = null;
        if ( subject instanceof DelegatingSubject) {
            securityManager = ((DelegatingSubject)subject).getSecurityManager();
        }
        if ( securityManager  is null) {
            securityManager = ThreadContext.getSecurityManager();
        }
        this.securityManager = securityManager;
    }

    /**
     * Returns the {@code Subject} instance managed by this {@code ThreadState} implementation.
     *
     * @return the {@code Subject} instance managed by this {@code ThreadState} implementation.
     */
    protected Subject getSubject() {
        return this.subject;
    }

    /**
     * Binds a {@link Subject} and {@link hunt.shiro.mgt.SecurityManager SecurityManager} to the
     * {@link ThreadContext} so they can be retrieved later by any
     * {@code SecurityUtils.}{@link hunt.shiro.SecurityUtils#getSubject() getSubject()} calls that might occur
     * during the thread's execution.
     * <p/>
     * Prior to binding, the {@code ThreadContext}'s existing {@link ThreadContext#getResources() resources} are
     * retained so they can be restored later via the {@link #restore restore} call.
     */
     void bind() {
        SecurityManager securityManager = this.securityManager;
        if ( securityManager  is null ) {
            //try just in case the constructor didn't find one at the time:
            securityManager = ThreadContext.getSecurityManager();
        }
        this.originalResources = ThreadContext.getResources();
        ThreadContext.remove();

        ThreadContext.bind(this.subject);
        if (securityManager !is null) {
            ThreadContext.bind(securityManager);
        }
    }

    /**
     * {@link ThreadContext#remove Remove}s all thread-state that was bound by this instance.  If any previous
     * thread-bound resources existed prior to the {@link #bind bind} call, they are restored back to the
     * {@code ThreadContext} to ensure the thread state is exactly as it was before binding.
     */
     void restore() {
        ThreadContext.remove();
        if (!CollectionUtils.isEmpty(this.originalResources)) {
            ThreadContext.setResources(this.originalResources);
        }
    }

    /**
     * Completely {@link ThreadContext#remove removes} the {@code ThreadContext} state.  Typically this method should
     * only be called in special cases - it is more 'correct' to {@link #restore restore} a thread to its previous
     * state than to clear it entirely.
     */
     void clear() {
        ThreadContext.remove();
    }
}
