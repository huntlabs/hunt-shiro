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
module hunt.shiro.mgt.RememberMeManager;

import hunt.shiro.Exceptions;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;

/**
 * A RememberMeManager is responsible for remembering a Subject's identity across that Subject's sessions with
 * the application.
 *
 */
interface RememberMeManager {

    /**
     * Based on the specified subject context map being used to build a Subject instance, returns any previously
     * remembered principals for the subject for automatic identity association (aka 'Remember Me').
     * <p/>
     * The context map is usually populated by a {@link Subject.Builder} implementation.
     * See the {@link SubjectFactory} class constants for Shiro's known map keys.
     *
     * @param subjectContext the contextual data, usually provided by a {@link Subject.Builder} implementation, that
     *                       is being used to construct a {@link Subject} instance.
     * @return he remembered principals or {@code null} if none could be acquired.
     */
    PrincipalCollection getRememberedPrincipals(SubjectContext subjectContext);

    /**
     * Forgets any remembered identity corresponding to the subject context map being used to build a subject instance.
     * <p/>
     * The context map is usually populated by a {@link Subject.Builder} implementation.
     * See the {@link SubjectFactory} class constants for Shiro's known map keys.
     *
     * @param subjectContext the contextual data, usually provided by a {@link Subject.Builder} implementation, that
     *                       is being used to construct a {@link Subject} instance.
     */
    void forgetIdentity(SubjectContext subjectContext);

    /**
     * Reacts to a successful authentication attempt, typically saving the principals to be retrieved ('remembered')
     * for future system access.
     *
     * @param subject the subject that executed a successful authentication attempt
     * @param token   the authentication token submitted resulting in a successful authentication attempt
     * @param info    the authenticationInfo returned as a result of the successful authentication attempt
     */
    void onSuccessfulLogin(Subject subject, AuthenticationToken token, AuthenticationInfo info);

    /**
     * Reacts to a failed authentication attempt, typically by forgetting any previously remembered principals for the
     * Subject.
     *
     * @param subject the subject that executed the failed authentication attempt
     * @param token   the authentication token submitted resulting in the failed authentication attempt
     * @param ae      the authentication exception thrown as a result of the failed authentication attempt
     */
    void onFailedLogin(Subject subject, AuthenticationToken token, AuthenticationException ae);

    /**
     * Reacts to a Subject logging out of the application, typically by forgetting any previously remembered
     * principals for the Subject.
     *
     * @param subject the subject logging out.
     */
    void onLogout(Subject subject);
}
