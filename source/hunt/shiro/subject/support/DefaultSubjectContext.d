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
module hunt.shiro.subject.support.DefaultSubjectContext;

import hunt.shiro.SecurityUtils;
import hunt.shiro.UnavailableSecurityManagerException;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.HostAuthenticationToken;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.session.Session;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;
import hunt.shiro.util.MapContext;
import hunt.shiro.util.StringUtils;
import hunt.logger;

import java.io.Serializable;

/**
 * Default implementation of the {@link SubjectContext} interface.  Note that the getters and setters are not
 * simple pass-through methods to an underlying attribute;  the getters will employ numerous heuristics to acquire
 * their data attribute as best as possible (for example, if {@link #getPrincipals} is invoked, if the principals aren't
 * in the backing map, it might check to see if there is a subject or session in the map and attempt to acquire the
 * principals from those objects).
 *
 * @since 1.0
 */
class DefaultSubjectContext : MapContext implements SubjectContext {

    private enum string SECURITY_MANAGER = DefaultSubjectContext.class.getName() ~ ".SECURITY_MANAGER";

    private enum string SESSION_ID = DefaultSubjectContext.class.getName() ~ ".SESSION_ID";

    private enum string AUTHENTICATION_TOKEN = DefaultSubjectContext.class.getName() ~ ".AUTHENTICATION_TOKEN";

    private enum string AUTHENTICATION_INFO = DefaultSubjectContext.class.getName() ~ ".AUTHENTICATION_INFO";

    private enum string SUBJECT = DefaultSubjectContext.class.getName() ~ ".SUBJECT";

    private enum string PRINCIPALS = DefaultSubjectContext.class.getName() ~ ".PRINCIPALS";

    private enum string SESSION = DefaultSubjectContext.class.getName() ~ ".SESSION";

    private enum string AUTHENTICATED = DefaultSubjectContext.class.getName() ~ ".AUTHENTICATED";

    private enum string HOST = DefaultSubjectContext.class.getName() ~ ".HOST";

     enum string SESSION_CREATION_ENABLED = DefaultSubjectContext.class.getName() ~ ".SESSION_CREATION_ENABLED";

    /**
     * The session key that is used to store subject principals.
     */
     enum string PRINCIPALS_SESSION_KEY = DefaultSubjectContext.class.getName() ~ "_PRINCIPALS_SESSION_KEY";

    /**
     * The session key that is used to store whether or not the user is authenticated.
     */
     enum string AUTHENTICATED_SESSION_KEY = DefaultSubjectContext.class.getName() ~ "_AUTHENTICATED_SESSION_KEY";



     DefaultSubjectContext() {
        super();
    }

     DefaultSubjectContext(SubjectContext ctx) {
        super(ctx);
    }

     SecurityManager getSecurityManager() {
        return getTypedValue(SECURITY_MANAGER, SecurityManager.class);
    }

     void setSecurityManager(SecurityManager securityManager) {
        nullSafePut(SECURITY_MANAGER, securityManager);
    }

     SecurityManager resolveSecurityManager() {
        SecurityManager securityManager = getSecurityManager();
        if (securityManager  is null) {
            if (log.isDebugEnabled()) {
                tracef("No SecurityManager available in subject context map.  " ~
                        "Falling back to SecurityUtils.getSecurityManager() lookup.");
            }
            try {
                securityManager = SecurityUtils.getSecurityManager();
            } catch (UnavailableSecurityManagerException e) {
                if (log.isDebugEnabled()) {
                    tracef("No SecurityManager available via SecurityUtils.  Heuristics exhausted.", e);
                }
            }
        }
        return securityManager;
    }

     Serializable getSessionId() {
        return getTypedValue(SESSION_ID, Serializable.class);
    }

     void setSessionId(Serializable sessionId) {
        nullSafePut(SESSION_ID, sessionId);
    }

     Subject getSubject() {
        return getTypedValue(SUBJECT, Subject.class);
    }

     void setSubject(Subject subject) {
        nullSafePut(SUBJECT, subject);
    }

     PrincipalCollection getPrincipals() {
        return getTypedValue(PRINCIPALS, PrincipalCollection.class);
    }

    private static bool isEmpty(PrincipalCollection pc) {
        return pc  is null || pc.isEmpty();
    }

     void setPrincipals(PrincipalCollection principals) {
        if (!isEmpty(principals)) {
            put(PRINCIPALS, principals);
        }
    }

     PrincipalCollection resolvePrincipals() {
        PrincipalCollection principals = getPrincipals();

        if (isEmpty(principals)) {
            //check to see if they were just authenticated:
            AuthenticationInfo info = getAuthenticationInfo();
            if (info != null) {
                principals = info.getPrincipals();
            }
        }

        if (isEmpty(principals)) {
            Subject subject = getSubject();
            if (subject != null) {
                principals = subject.getPrincipals();
            }
        }

        if (isEmpty(principals)) {
            //try the session:
            Session session = resolveSession();
            if (session != null) {
                principals = (PrincipalCollection) session.getAttribute(PRINCIPALS_SESSION_KEY);
            }
        }

        return principals;
    }


     Session getSession() {
        return getTypedValue(SESSION, Session.class);
    }

     void setSession(Session session) {
        nullSafePut(SESSION, session);
    }

     Session resolveSession() {
        Session session = getSession();
        if (session  is null) {
            //try the Subject if it exists:
            Subject existingSubject = getSubject();
            if (existingSubject != null) {
                session = existingSubject.getSession(false);
            }
        }
        return session;
    }

     bool isSessionCreationEnabled() {
        bool val = getTypedValue(SESSION_CREATION_ENABLED, bool.class);
        return val  is null || val;
    }

     void setSessionCreationEnabled(bool enabled) {
        nullSafePut(SESSION_CREATION_ENABLED, enabled);
    }

     bool isAuthenticated() {
        bool authc = getTypedValue(AUTHENTICATED, bool.class);
        return authc != null && authc;
    }

     void setAuthenticated(bool authc) {
        put(AUTHENTICATED, authc);
    }

     bool resolveAuthenticated() {
        bool authc = getTypedValue(AUTHENTICATED, bool.class);
        if (authc  is null) {
            //see if there is an AuthenticationInfo object.  If so, the very presence of one indicates a successful
            //authentication attempt:
            AuthenticationInfo info = getAuthenticationInfo();
            authc = info != null;
        }
        if (!authc) {
            //fall back to a session check:
            Session session = resolveSession();
            if (session != null) {
                bool sessionAuthc = (bool) session.getAttribute(AUTHENTICATED_SESSION_KEY);
                authc = sessionAuthc != null && sessionAuthc;
            }
        }

        return authc;
    }

     AuthenticationInfo getAuthenticationInfo() {
        return getTypedValue(AUTHENTICATION_INFO, AuthenticationInfo.class);
    }

     void setAuthenticationInfo(AuthenticationInfo info) {
        nullSafePut(AUTHENTICATION_INFO, info);
    }

     AuthenticationToken getAuthenticationToken() {
        return getTypedValue(AUTHENTICATION_TOKEN, AuthenticationToken.class);
    }

     void setAuthenticationToken(AuthenticationToken token) {
        nullSafePut(AUTHENTICATION_TOKEN, token);
    }

     string getHost() {
        return getTypedValue(HOST, string.class);
    }

     void setHost(string host) {
        if (StringUtils.hasText(host)) {
            put(HOST, host);
        }
    }

     string resolveHost() {
        string host = getHost();

        if (host  is null) {
            //check to see if there is an AuthenticationToken from which to retrieve it:
            AuthenticationToken token = getAuthenticationToken();
            if (token instanceof HostAuthenticationToken) {
                host = ((HostAuthenticationToken) token).getHost();
            }
        }

        if (host  is null) {
            Session session = resolveSession();
            if (session != null) {
                host = session.getHost();
            }
        }

        return host;
    }
}
