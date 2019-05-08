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
module hunt.shiro.mgt.DefaultSessionStorageEvaluator;

import hunt.shiro.mgt.SessionStorageEvaluator;

import hunt.shiro.subject.Subject;

/**
 * A Default {@code SessionStorageEvaluator} that provides reasonable control over if and how Sessions may be used for
 * storing Subject state.  See the {@link #isSessionStorageEnabled(hunt.shiro.subject.Subject)}
 * method for exact behavior.
 *
 */
class DefaultSessionStorageEvaluator : SessionStorageEvaluator {

    /**
     * Global policy determining if Subject sessions may be used to persist Subject state if the Subject's Session
     * does not yet exist.
     */
    private bool sessionStorageEnabled = true;

    /**
     * This implementation functions as follows:
     * <ul>
     * <li>If the specified Subject already has an existing {@code Session} (typically because an application developer
     * has called {@code subject.getSession()} already), Shiro will use that existing session to store subject state.</li>
     * <li>If a Subject does not yet have a Session, this implementation checks the
     * {@link #isSessionStorageEnabled() sessionStorageEnabled} property:
     * <ul>
     * <li>If {@code sessionStorageEnabled} is true (the default setting), a new session may be created to persist
     * Subject state if necessary.</li>
     * <li>If {@code sessionStorageEnabled} is {@code false}, a new session will <em>not</em> be created to persist
     * session state.</li>
     * </ul></li>
     * </ul>
     * Most applications use Sessions and are OK with the default {@code true} setting for {@code sessionStorageEnabled}.
     * <p/>
     * However, if your application is a purely 100% stateless application that never uses sessions,
     * you will want to set {@code sessionStorageEnabled} to {@code false}.  Realize that a {@code false} value will
     * ensure that any subject login only retains the authenticated identity for the duration of a request.  Any other
     * requests, invocations or messages will not be authenticated.
     *
     * @param subject the {@code Subject} for which session state persistence may be enabled
     * @return the value of {@link #isSessionStorageEnabled()} and ignores the {@code Subject} argument.
     */
     bool isSessionStorageEnabled(Subject subject) {
        return (subject !is null && subject.getSession(false) !is null) || isSessionStorageEnabled();
    }

    /**
     * Returns {@code true} if any Subject's {@code Session} may be used to persist that {@code Subject}'s state,
     * {@code false} otherwise.  The default value is {@code true}.
     * <p/>
     * <b>N.B.</b> This is a global configuration setting; setting this value to {@code false} will disable sessions
     * to persist Subject state for all Subjects that do not already have a Session.  It should typically only be set
     * to {@code false} for 100% stateless applications (e.g. when sessions aren't used or when remote clients
     * authenticate on every request).
     *
     * @return {@code true} if any Subject's {@code Session} may be used to persist that {@code Subject}'s state,
     *         {@code false} otherwise.
     */
     bool isSessionStorageEnabled() {
        return sessionStorageEnabled;
    }

    /**
     * Sets if any Subject's {@code Session} may be used to persist that {@code Subject}'s state.  The
     * default value is {@code true}.
     * <p/>
     * <b>N.B.</b> This is a global configuration setting; setting this value to {@code false} will disable sessions
     * to persist Subject state for all Subjects that do not already have a Session.  It should typically only be set
     * to {@code false} for 100% stateless applications (e.g. when sessions aren't used or when remote clients
     * authenticate on every request).
     *
     * @param sessionStorageEnabled if any Subject's {@code Session} may be used to persist that {@code Subject}'s state.
     */
     void setSessionStorageEnabled(bool sessionStorageEnabled) {
        this.sessionStorageEnabled = sessionStorageEnabled;
    }
}
