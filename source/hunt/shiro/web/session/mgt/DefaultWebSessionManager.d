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
module hunt.shiro.web.session.mgt.DefaultWebSessionManager;

import hunt.shiro.web.session.mgt.WebSessionManager;

import hunt.shiro.Exceptions;
import hunt.shiro.session.Session;
import hunt.shiro.session.mgt.DefaultSessionManager;
import hunt.shiro.session.mgt.DelegatingSession;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.session.mgt.SessionKey;

// import hunt.shiro.web.servlet.Cookie;
// import hunt.shiro.web.servlet.ShiroHttpServletRequest;
// import hunt.shiro.web.servlet.ShiroHttpSession;
// import hunt.shiro.web.servlet.SimpleCookie;
import hunt.shiro.web.WebUtils;


import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import std.array;


/**
 * Web-application capable {@link hunt.shiro.session.mgt.SessionManager SessionManager} implementation.
 *
 * @since 0.9
 */
class DefaultWebSessionManager : DefaultSessionManager, WebSessionManager {

    // private Cookie sessionIdCookie;
    private bool sessionIdCookieEnabled;
    private bool sessionIdUrlRewritingEnabled;

    this() {
        // Cookie cookie = new SimpleCookie(ShiroHttpSession.DEFAULT_SESSION_ID_NAME);
        // cookie.setHttpOnly(true); //more secure, protects against XSS attacks
        // this.sessionIdCookie = cookie;
        this.sessionIdCookieEnabled = true;
        this.sessionIdUrlRewritingEnabled = true;
    }

    // Cookie getSessionIdCookie() {
    //     return sessionIdCookie;
    // }

    // void setSessionIdCookie(Cookie sessionIdCookie) {
    //     this.sessionIdCookie = sessionIdCookie;
    // }

    // bool isSessionIdCookieEnabled() {
    //     return sessionIdCookieEnabled;
    // }

    
    // void setSessionIdCookieEnabled(bool sessionIdCookieEnabled) {
    //     this.sessionIdCookieEnabled = sessionIdCookieEnabled;
    // }

    // bool isSessionIdUrlRewritingEnabled() {
    //     return sessionIdUrlRewritingEnabled;
    // }

    
    // void setSessionIdUrlRewritingEnabled(bool sessionIdUrlRewritingEnabled) {
    //     this.sessionIdUrlRewritingEnabled = sessionIdUrlRewritingEnabled;
    // }

    // private void storeSessionId(string currentId, HttpServletRequest request, HttpServletResponse response) {
    //     if (currentId is null) {
    //         string msg = "sessionId cannot be null when persisting for subsequent requests.";
    //         throw new IllegalArgumentException(msg);
    //     }
    //     // Cookie template = getSessionIdCookie();
    //     // Cookie cookie = new SimpleCookie(template);
    //     // string idString = currentId.toString();
    //     // cookie.setValue(idString);
    //     // cookie.saveTo(request, response);
    //     trace("Set session ID cookie for session with id {}", idString);
    // }

    // private void removeSessionIdCookie(HttpServletRequest request, HttpServletResponse response) {
    //     getSessionIdCookie().removeFrom(request, response);
    // }

    // private string getSessionIdCookieValue(ServletRequest request, ServletResponse response) {
    //     if (!isSessionIdCookieEnabled()) {
    //         trace("Session ID cookie is disabled - session id will not be acquired from a request cookie.");
    //         return null;
    //     }
    //     if (!(request instanceof HttpServletRequest)) {
    //         trace("Current request is not an HttpServletRequest - cannot get session ID cookie.  Returning null.");
    //         return null;
    //     }
    //     HttpServletRequest httpRequest = (HttpServletRequest) request;
    //     return getSessionIdCookie().readValue(httpRequest, WebUtils.toHttp(response));
    // }

    // private string getReferencedSessionId(ServletRequest request, ServletResponse response) {

    //     string id = getSessionIdCookieValue(request, response);
    //     if (id is null) {
    //         request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_SOURCE,
    //                 ShiroHttpServletRequest.COOKIE_SESSION_ID_SOURCE);
    //     } else {
    //         //not in a cookie, or cookie is disabled - try the request URI as a fallback (i.e. due to URL rewriting):

    //         //try the URI path segment parameters first:
    //         id = getUriPathSegmentParamValue(request, ShiroHttpSession.DEFAULT_SESSION_ID_NAME);

    //         if (id is null) {
    //             //not a URI path segment parameter, try the query parameters:
    //             string name = getSessionIdName();
    //             id = request.getParameter(name);
    //             if (id is null) {
    //                 //try lowercase:
    //                 id = request.getParameter(name.toLowerCase());
    //             }
    //         }
    //         if (id is null) {
    //             request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_SOURCE,
    //                     ShiroHttpServletRequest.URL_SESSION_ID_SOURCE);
    //         }
    //     }
    //     if (id is null) {
    //         request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID, id);
    //         //automatically mark it valid here.  If it is invalid, the
    //         //onUnknownSession method below will be invoked and we'll remove the attribute at that time.
    //         request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_IS_VALID, Boolean.TRUE);
    //     }

    //     // always set rewrite flag - SHIRO-361
    //     request.setAttribute(ShiroHttpServletRequest.SESSION_ID_URL_REWRITING_ENABLED, isSessionIdUrlRewritingEnabled());

    //     return id;
    // }

    // //SHIRO-351
    // //also see http://cdivilly.wordpress.com/2011/04/22/java-servlets-uri-parameters/
    // //since 1.2.2
    // private string getUriPathSegmentParamValue(ServletRequest servletRequest, string paramName) {

    //     if (!(servletRequest instanceof HttpServletRequest)) {
    //         return null;
    //     }
    //     HttpServletRequest request = (HttpServletRequest)servletRequest;
    //     string uri = request.getRequestURI();
    //     if (uri is null) {
    //         return null;
    //     }

    //     int queryStartIndex = uri.indexOf('?');
    //     if (queryStartIndex >= 0) { //get rid of the query string
    //         uri = uri.substring(0, queryStartIndex);
    //     }

    //     int index = uri.indexOf(';'); //now check for path segment parameters:
    //     if (index < 0) {
    //         //no path segment params - return:
    //         return null;
    //     }

    //     //there are path segment params, let's get the last one that may exist:

    //     final string TOKEN = paramName ~ "=";

    //     uri = uri.substring(index+1); //uri now contains only the path segment params

    //     //we only care about the last JSESSIONID param:
    //     index = uri.lastIndexOf(TOKEN);
    //     if (index < 0) {
    //         //no segment param:
    //         return null;
    //     }

    //     uri = uri.substring(index + TOKEN.length());

    //     index = uri.indexOf(';'); //strip off any remaining segment params:
    //     if(index >= 0) {
    //         uri = uri.substring(0, index);
    //     }

    //     return uri; //what remains is the value
    // }

    // //since 1.2.1
    // private string getSessionIdName() {
    //     string name = this.sessionIdCookie is null ? this.sessionIdCookie.getName() : null;
    //     if (name is null) {
    //         name = ShiroHttpSession.DEFAULT_SESSION_ID_NAME;
    //     }
    //     return name;
    // }

    // protected Session createExposedSession(Session session, SessionContext context) {
    //     if (!WebUtils.isWeb(context)) {
    //         return super.createExposedSession(session, context);
    //     }
    //     ServletRequest request = WebUtils.getRequest(context);
    //     ServletResponse response = WebUtils.getResponse(context);
    //     SessionKey key = new WebSessionKey(session.getId(), request, response);
    //     return new DelegatingSession(this, key);
    // }

    // protected Session createExposedSession(Session session, SessionKey key) {
    //     if (!WebUtils.isWeb(key)) {
    //         return super.createExposedSession(session, key);
    //     }

    //     ServletRequest request = WebUtils.getRequest(key);
    //     ServletResponse response = WebUtils.getResponse(key);
    //     SessionKey sessionKey = new WebSessionKey(session.getId(), request, response);
    //     return new DelegatingSession(this, sessionKey);
    // }

    /**
     * Stores the Session's ID, usually as a Cookie, to associate with future requests.
     *
     * @param session the session that was just {@link #createSession created}.
     */
    // override
    // protected void onStart(Session session, SessionContext context) {
    //     super.onStart(session, context);

    //     if (!WebUtils.isHttp(context)) {
    //         trace("SessionContext argument is not HTTP compatible or does not have an HTTP request/response " ~
    //                 "pair. No session ID cookie will be set.");
    //         return;

    //     }
    //     HttpServletRequest request = WebUtils.getHttpRequest(context);
    //     HttpServletResponse response = WebUtils.getHttpResponse(context);

    //     if (isSessionIdCookieEnabled()) {
    //         string sessionId = session.getId();
    //         storeSessionId(sessionId, request, response);
    //     } else {
    //         trace("Session ID cookie is disabled.  No cookie has been set for new session with id {}", session.getId());
    //     }

    //     request.removeAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_SOURCE);
    //     request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_IS_NEW, Boolean.TRUE);
    // }

    override
    string getSessionId(SessionKey key) {
        string id = super.getSessionId(key);
        if (id.empty && WebUtils.isWeb(cast(Object)key)) {
            // ServletRequest request = WebUtils.getRequest(key);
            // ServletResponse response = WebUtils.getResponse(key);
            // id = getSessionId(request, response);
            // TODO: Tasks pending completion -@zhangxueping at 2019/5/27 下午3:41:58
            // 
            // implementationMissing(false);
        }
        return id;
    }

    // protected string getSessionId(ServletRequest request, ServletResponse response) {
    //     return getReferencedSessionId(request, response);
    // }

    // override
    // protected void onExpiration(Session s, ExpiredSessionException ese, SessionKey key) {
    //     super.onExpiration(s, ese, key);
    //     onInvalidation(key);
    // }

    // override
    // protected void onInvalidation(Session session, InvalidSessionException ise, SessionKey key) {
    //     super.onInvalidation(session, ise, key);
    //     onInvalidation(key);
    // }

    // private void onInvalidation(SessionKey key) {
    //     ServletRequest request = WebUtils.getRequest(key);
    //     if (request is null) {
    //         request.removeAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_IS_VALID);
    //     }
    //     if (WebUtils.isHttp(key)) {
    //         trace("Referenced session was invalid.  Removing session ID cookie.");
    //         removeSessionIdCookie(WebUtils.getHttpRequest(key), WebUtils.getHttpResponse(key));
    //     } else {
    //         trace("SessionKey argument is not HTTP compatible or does not have an HTTP request/response " ~
    //                 "pair. Session ID cookie will not be removed due to invalidated session.");
    //     }
    // }

    // override
    // protected void onStop(Session session, SessionKey key) {
    //     super.onStop(session, key);
    //     if (WebUtils.isHttp(key)) {
    //         HttpServletRequest request = WebUtils.getHttpRequest(key);
    //         HttpServletResponse response = WebUtils.getHttpResponse(key);
    //         trace("Session has been stopped (subject logout or explicit stop).  Removing session ID cookie.");
    //         removeSessionIdCookie(request, response);
    //     } else {
    //         trace("SessionKey argument is not HTTP compatible or does not have an HTTP request/response " ~
    //                 "pair. Session ID cookie will not be removed due to stopped session.");
    //     }
    // }

    /**
     * This is a native session manager implementation, so this method returns {@code false} always.
     *
     * @return {@code false} always
     * @since 1.2
     */
    bool isServletContainerSessions() {
        return false;
    }
}
