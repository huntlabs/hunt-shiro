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
module hunt.shiro.mgt.DefaultSubjectFactory;

import hunt.shiro.session.Session;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;
import hunt.shiro.subject.support.DelegatingSubject;


/**
 * Default {@link SubjectFactory SubjectFactory} implementation that creates {@link hunt.shiro.subject.support.DelegatingSubject DelegatingSubject}
 * instances.
 *
 */
class DefaultSubjectFactory : SubjectFactory {

    this() {
    }

     Subject createSubject(SubjectContext context) {
        SecurityManager securityManager = context.resolveSecurityManager();
        Session session = context.resolveSession();
        bool sessionCreationEnabled = context.isSessionCreationEnabled();
        PrincipalCollection principals = context.resolvePrincipals();
        bool authenticated = context.resolveAuthenticated();
        string host = context.resolveHost();

        return new DelegatingSubject(principals, authenticated, host, session, sessionCreationEnabled, securityManager);
    }

    /**
     * deprecated("") since 1.2 - override {@link #createSubject(hunt.shiro.subject.SubjectContext)} directly if you
     *             need to instantiate a custom {@link Subject} class.
     */
    deprecated("")
    protected Subject newSubjectInstance(PrincipalCollection principals, bool authenticated, string host,
                                         Session session, SecurityManager securityManager) {
        return new DelegatingSubject(principals, authenticated, host, session, true, securityManager);
    }

}
