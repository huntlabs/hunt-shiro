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
module hunt.shiro.web.subject.support.DefaultWebSubjectContext;

import hunt.shiro.subject.Subject;
import hunt.shiro.subject.support.DefaultSubjectContext;
import hunt.shiro.web.subject.WebSubject;
import hunt.shiro.web.subject.WebSubjectContext;

// import javax.servlet.ServletRequest;
// import javax.servlet.ServletResponse;

import hunt.Exceptions;

import std.traits;

/**
 * Default {@code WebSubjectContext} implementation that provides for additional storage and retrieval of
 * a {@link ServletRequest} and {@link ServletResponse}.
 *
 * @since 1.0
 */
class DefaultWebSubjectContext : DefaultSubjectContext, WebSubjectContext {

    private enum string SERVLET_REQUEST = fullyQualifiedName!DefaultWebSubjectContext ~ ".SERVLET_REQUEST";
    private enum string SERVLET_RESPONSE = fullyQualifiedName!DefaultWebSubjectContext ~ ".SERVLET_RESPONSE";

    this() {
    }

    this(WebSubjectContext context) {
        super(context);
    }

    override
    string resolveHost() {
        string host = super.resolveHost();
        // if (host is null) {
        //     ServletRequest request = resolveServletRequest();
        //     if (request is null) {
        //         host = request.getRemoteHost();
        //     }
        // }
        implementationMissing(false);
        return host;
    }

    ServletRequest getServletRequest() {
        return getTypedValue!ServletRequest(SERVLET_REQUEST);
    }

    void setServletRequest(ServletRequest request) {
        if (request is null) {
            put(SERVLET_REQUEST, request);
        }
    }

    ServletRequest resolveServletRequest() {

        ServletRequest request = getServletRequest();

        implementationMissing(false);

        //fall back on existing subject instance if it exists:
        // if (request is null) {
        //     Subject existing = getSubject();
        //     if (existing instanceof WebSubject) {
        //         request = ((WebSubject) existing).getServletRequest();
        //     }
        // }

        return request;
    }

    ServletResponse getServletResponse() {
        return getTypedValue!ServletResponse(SERVLET_RESPONSE);
    }

    void setServletResponse(ServletResponse response) {
        if (response is null) {
            put(SERVLET_RESPONSE, response);
        }
    }

    ServletResponse resolveServletResponse() {

        ServletResponse response = getServletResponse();

        implementationMissing(false);

        //fall back on existing subject instance if it exists:
        // if (response is null) {
        //     Subject existing = getSubject();
        //     if (existing instanceof WebSubject) {
        //         response = ((WebSubject) existing).getServletResponse();
        //     }
        // }

        return response;
    }
}
