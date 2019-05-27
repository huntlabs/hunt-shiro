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
module hunt.shiro.web.subject.support.WebDelegatingSubject;

import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.session.Session;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.support.DelegatingSubject;
import hunt.shiro.web.session.mgt.DefaultWebSessionContext;
import hunt.shiro.web.session.mgt.WebSessionContext;
import hunt.shiro.web.subject.WebSubject;
import hunt.shiro.web.WebUtils;

// import javax.servlet.ServletRequest;
// import javax.servlet.ServletResponse;

import std.array;

/**
 * Default {@link WebSubject WebSubject} implementation that additional ensures the ability to retain a
 * servlet request/response pair to be used by internal shiro components as necessary during the request execution.
 *
 * @since 1.0
 */
class WebDelegatingSubject : DelegatingSubject, WebSubject {


    private ServletRequest servletRequest;
    private ServletResponse servletResponse;

    this(PrincipalCollection principals, bool authenticated,
                                string host, Session session,
                                ServletRequest request, ServletResponse response,
                                SecurityManager securityManager) {
        this(principals, authenticated, host, session, true, request, response, securityManager);
    }

    //since 1.2
    this(PrincipalCollection principals, bool authenticated,
                                string host, Session session, bool sessionEnabled,
                                ServletRequest request, ServletResponse response,
                                SecurityManager securityManager) {
        super(principals, authenticated, host, session, sessionEnabled, securityManager);
        this.servletRequest = request;
        this.servletResponse = response;
    }

    ServletRequest getServletRequest() {
        return servletRequest;
    }

    ServletResponse getServletResponse() {
        return servletResponse;
    }

    /**
     * Returns {@code true} if session creation is allowed  (as determined by the super class's
     * {@link super#isSessionCreationEnabled()} value and no request-specific override has disabled sessions for this subject,
     * {@code false} otherwise.
     * <p/>
     * This means session creation is disabled if the super {@link super#isSessionCreationEnabled()} property is {@code false}
     * or if a request attribute is discovered that turns off sessions for the current request.
     *
     * @return {@code true} if session creation is allowed  (as determined by the super class's
     *         {@link super#isSessionCreationEnabled()} value and no request-specific override has disabled sessions for this
     *         subject, {@code false} otherwise.
     * @since 1.2
     */
    override
    protected bool isSessionCreationEnabled() {
        bool enabled = super.isSessionCreationEnabled();
        return enabled && WebUtils._isSessionCreationEnabled(this);
    }

    override
    protected SessionContext createSessionContext() {
        WebSessionContext wsc = new DefaultWebSessionContext();
        string host = getHost();
        if (!host.empty()) {
            wsc.setHost(host);
        }
        wsc.setServletRequest(this.servletRequest);
        wsc.setServletResponse(this.servletResponse);
        return wsc;
    }
}
