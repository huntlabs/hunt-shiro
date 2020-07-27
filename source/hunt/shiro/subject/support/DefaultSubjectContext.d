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

import hunt.shiro.Exceptions;
import hunt.shiro.SecurityUtils;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.HostAuthenticationToken;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.session.Session;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;
import hunt.shiro.util.MapContext;
// // import hunt.shiro.util.StringUtils;
import hunt.logging.ConsoleLogger;

import hunt.Boolean;
import hunt.collection.Map;
import hunt.String;
import hunt.util.Common;

import std.array;
import std.traits;

/**
 * Default implementation of the {@link SubjectContext} interface.  Note that the getters and setters are not
 * simple pass-through methods to an underlying attribute;  the getters will employ numerous heuristics to acquire
 * their data attribute as best as possible (for example, if {@link #getPrincipals} is invoked, if the principals aren't
 * in the backing map, it might check to see if there is a subject or session in the map and attempt to acquire the
 * principals from those objects).
 *
 */
class DefaultSubjectContext : MapContext, SubjectContext {

    

    private enum string SECURITY_MANAGER = fullyQualifiedName!(DefaultSubjectContext) ~ ".SECURITY_MANAGER";

    private enum string SESSION_ID = fullyQualifiedName!(DefaultSubjectContext) ~ ".SESSION_ID";

    private enum string AUTHENTICATION_TOKEN = fullyQualifiedName!(DefaultSubjectContext) ~ ".AUTHENTICATION_TOKEN";

    private enum string AUTHENTICATION_INFO = fullyQualifiedName!(DefaultSubjectContext) ~ ".AUTHENTICATION_INFO";

    private enum string SUBJECT = fullyQualifiedName!(DefaultSubjectContext) ~ ".SUBJECT";

    private enum string PRINCIPALS = fullyQualifiedName!(DefaultSubjectContext) ~ ".PRINCIPALS";

    private enum string SESSION = fullyQualifiedName!(DefaultSubjectContext) ~ ".SESSION";

    private enum string AUTHENTICATED = fullyQualifiedName!(DefaultSubjectContext) ~ ".AUTHENTICATED";

    private enum string HOST = fullyQualifiedName!(DefaultSubjectContext) ~ ".HOST";

    enum string SESSION_CREATION_ENABLED = fullyQualifiedName!(DefaultSubjectContext) ~ ".SESSION_CREATION_ENABLED";

    /**
     * The session key that is used to store subject principals.
     */
    enum string PRINCIPALS_SESSION_KEY = fullyQualifiedName!(DefaultSubjectContext) ~ "_PRINCIPALS_SESSION_KEY";

    /**
     * The session key that is used to store whether or not the user is authenticated.
     */
    enum string AUTHENTICATED_SESSION_KEY = fullyQualifiedName!(DefaultSubjectContext) ~ "_AUTHENTICATED_SESSION_KEY";



    this() {
        super();
    }

    this(SubjectContext ctx) {
        super(cast(Map!(string, Object))ctx);
    }

    SecurityManager getSecurityManager() {
        return getTypedValue!SecurityManager(SECURITY_MANAGER);
    }

    void setSecurityManager(SecurityManager securityManager) {
        nullSafePut(SECURITY_MANAGER, cast(Object)securityManager);
    }

    SecurityManager resolveSecurityManager() {
        SecurityManager securityManager = getSecurityManager();
        if (securityManager  is null) {
            version(HUNT_SHIRO_DEBUG) {
                warningf("No SecurityManager available in subject context map.  " ~
                        "Falling back to SecurityUtils.getSecurityManager() lookup.");
            }
            try {
                securityManager = SecurityUtils.getSecurityManager();
            } catch (UnavailableSecurityManagerException e) {
                version(HUNT_DEBUG) {
                    warningf("No SecurityManager available via SecurityUtils." ~ 
                        " Heuristics exhausted. The reason is: %s", e.msg);
                } 
                version(HUNT_SHIRO_DEBUG) {
                    warning(e);
                }
            }
        }
        return securityManager;
    }

    string getSessionId() {
        String s = getTypedValue!String(SESSION_ID);
        if(s !is null)
            return getTypedValue!String(SESSION_ID).value;
        else
            return null;
    }

    void setSessionId(string sessionId) {
        nullSafePut(SESSION_ID, new String(sessionId));
    }

    Subject getSubject() {
        return getTypedValue!Subject(SUBJECT);
    }

     void setSubject(Subject subject) {
        nullSafePut(SUBJECT, cast(Object)subject);
    }

     PrincipalCollection getPrincipals() {
        return getTypedValue!PrincipalCollection(PRINCIPALS);
    }

    private static bool isEmpty(PrincipalCollection pc) {
        return pc  is null || pc.isEmpty();
    }

    void setPrincipals(PrincipalCollection principals) {
        if (!isEmpty(principals)) {
            put(PRINCIPALS, cast(Object)principals);
        }
    }

    PrincipalCollection resolvePrincipals() {
        PrincipalCollection principals = getPrincipals();

        if (isEmpty(principals)) {
            //check to see if they were just authenticated:
            AuthenticationInfo info = getAuthenticationInfo();
            if (info !is null) {
                principals = info.getPrincipals();
            }
        }

        if (isEmpty(principals)) {
            Subject subject = getSubject();
            if (subject !is null) {
                principals = subject.getPrincipals();
            }
        }

        if (isEmpty(principals)) {
            //try the session:
            Session session = resolveSession();
            if (session !is null) {
                principals = cast(PrincipalCollection) session.getAttribute(new String(PRINCIPALS_SESSION_KEY));
            }
        }

        return principals;
    }


    Session getSession() {
        return getTypedValue!Session(SESSION);
    }

    void setSession(Session session) {
        nullSafePut(SESSION, cast(Object)session);
    }

     Session resolveSession() {
        Session session = getSession();
        if (session  is null) {
            //try the Subject if it exists:
            Subject existingSubject = getSubject();
            if (existingSubject !is null) {
                session = existingSubject.getSession(false);
            }
        }
        return session;
    }

    bool isSessionCreationEnabled() {
        Boolean val = getTypedValue!(Boolean)(SESSION_CREATION_ENABLED);
        return val is null || val.value;
    }

    void setSessionCreationEnabled(bool enabled) {
        nullSafePut(SESSION_CREATION_ENABLED, new Boolean(enabled));
    }

    bool isAuthenticated() {
        Boolean authc = getTypedValue!(Boolean)(AUTHENTICATED);
        return authc !is null && authc.value;
    }

    void setAuthenticated(bool authc) {
        put(AUTHENTICATED, new Boolean(authc));
    }

    bool resolveAuthenticated() {
        Boolean authc = getTypedValue!Boolean(AUTHENTICATED);
        if (authc is null) {
            //see if there is an AuthenticationInfo object.  If so, the very presence of one indicates a successful
            //authentication attempt:
            AuthenticationInfo info = getAuthenticationInfo();
            authc = new Boolean(info !is null);
        }

        if (!authc.value) {
            //fall back to a session check:
            Session session = resolveSession();
            if (session !is null) {
                Boolean sessionAuthc = cast(Boolean) session.getAttribute(new String(AUTHENTICATED_SESSION_KEY));
                return sessionAuthc !is null && sessionAuthc.value;
            }
        }

        return authc.value;
    }

    AuthenticationInfo getAuthenticationInfo() {
        return getTypedValue!AuthenticationInfo(AUTHENTICATION_INFO);
    }

    void setAuthenticationInfo(AuthenticationInfo info) {
        nullSafePut(AUTHENTICATION_INFO, cast(Object)info);
    }

    AuthenticationToken getAuthenticationToken() {
        return getTypedValue!AuthenticationToken(AUTHENTICATION_TOKEN);
    }

    void setAuthenticationToken(AuthenticationToken token) {
        nullSafePut(AUTHENTICATION_TOKEN, cast(Object)token);
    }

    string getHost() {
        String s = getTypedValue!String(HOST);
        if(s is null)
            return null;
        else
            return s.value;
    }

    void setHost(string host) {
        if (!host.empty()) {
            put(HOST, new String(host));
        }
    }

    string resolveHost() {
        string host = getHost();

        if (host  is null) {
            //check to see if there is an AuthenticationToken from which to retrieve it:
            AuthenticationToken token = getAuthenticationToken();
            HostAuthenticationToken hat = cast(HostAuthenticationToken) token;
            if (hat !is null) {
                host = hat.getHost();
            }
        }

        if (host is null) {
            Session session = resolveSession();
            if (session !is null) {
                host = session.getHost();
            }
        }

        return host;
    }

}
