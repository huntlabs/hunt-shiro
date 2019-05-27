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
module hunt.shiro.web.mgt.DefaultWebSecurityManager;

import hunt.shiro.web.mgt.DefaultWebSessionStorageEvaluator;
import hunt.shiro.web.mgt.DefaultWebSubjectFactory;
import hunt.shiro.web.mgt.WebSecurityManager;

import hunt.shiro.mgt.DefaultSecurityManager;
import hunt.shiro.mgt.DefaultSubjectDAO;
import hunt.shiro.mgt.SessionStorageEvaluator;
import hunt.shiro.mgt.SubjectDAO;
import hunt.shiro.realm.Realm;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.session.mgt.SessionKey;
import hunt.shiro.session.mgt.SessionManager;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;
import hunt.shiro.util.LifecycleUtils;

// import hunt.shiro.web.servlet.ShiroHttpServletRequest;
import hunt.shiro.web.session.mgt;
import hunt.shiro.web.subject.WebSubject;
import hunt.shiro.web.subject.WebSubjectContext;
import hunt.shiro.web.subject.support.DefaultWebSubjectContext;
import hunt.shiro.web.RequestPairSource;
import hunt.shiro.web.WebUtils;

import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

// import javax.servlet.ServletRequest;
// import javax.servlet.ServletResponse;
import hunt.collection.Collection;

import std.array;
import std.traits;
import std.string;


/**
 * Default {@link WebSecurityManager WebSecurityManager} implementation used in web-based applications or any
 * application that requires HTTP connectivity (SOAP, http remoting, etc).
 *
 * @since 0.2
 */
class DefaultWebSecurityManager : DefaultSecurityManager, WebSecurityManager {

    //TODO - complete JavaDoc

    enum string HTTP_SESSION_MODE = "http";
    enum string NATIVE_SESSION_MODE = "native";

    /**
     * @deprecated as of 1.2.  This should NOT be used for anything other than determining if the sessionMode has changed.
     */
    private string sessionMode;

    this() {
        super();
        (cast(DefaultSubjectDAO) this.subjectDAO).setSessionStorageEvaluator(new DefaultWebSessionStorageEvaluator());
        this.sessionMode = HTTP_SESSION_MODE;
        setSubjectFactory(new DefaultWebSubjectFactory());
        // setRememberMeManager(new CookieRememberMeManager());
        // setSessionManager(new ServletContainerSessionManager());
    }

    
    this(Realm singleRealm) {
        this();
        setRealm(singleRealm);
    }

    
    this(Collection!Realm realms) {
        this();
        setRealms(realms);
    }

    override
    protected SubjectContext createSubjectContext() {
        return new DefaultWebSubjectContext();
    }

    override
    //since 1.2.1 for fixing SHIRO-350
    void setSubjectDAO(SubjectDAO subjectDAO) {
        super.setSubjectDAO(subjectDAO);
        applySessionManagerToSessionStorageEvaluatorIfPossible();
    }

    //since 1.2.1 for fixing SHIRO-350
    override
    protected void afterSessionManagerSet() {
        super.afterSessionManagerSet();
        applySessionManagerToSessionStorageEvaluatorIfPossible();
    }

    //since 1.2.1 for fixing SHIRO-350:
    private void applySessionManagerToSessionStorageEvaluatorIfPossible() {
        SubjectDAO subjectDAO = getSubjectDAO();
        DefaultSubjectDAO dsd = cast(DefaultSubjectDAO)subjectDAO;
        if (dsd !is null) {
            SessionStorageEvaluator evaluator = dsd.getSessionStorageEvaluator();
            DefaultWebSessionStorageEvaluator dwse = cast(DefaultWebSessionStorageEvaluator)evaluator;
            if (dwse !is null) {
                dwse.setSessionManager(getSessionManager());
            }
        }
    }

    override
    protected SubjectContext copy(SubjectContext subjectContext) {
        WebSubjectContext wsc = cast(WebSubjectContext) subjectContext;
        if (wsc !is null) {
            return new DefaultWebSubjectContext(wsc);
        }
        return super.copy(subjectContext);
    }

    
    string getSessionMode() {
        return sessionMode;
    }

    /**
     * @param sessionMode
     * @deprecated since 1.2
     */
    void setSessionMode(string sessionMode) {
        // log.warn("The 'sessionMode' property has been deprecated.  Please configure an appropriate WebSessionManager " ~
        //         "instance instead of using this property.  This property/method will be removed in a later version.");
        string mode = sessionMode;
        if (mode.empty()) {
            throw new IllegalArgumentException("sessionMode argument cannot be null.");
        }
        mode = sessionMode.toLower();
        if (HTTP_SESSION_MODE !=  mode && NATIVE_SESSION_MODE != mode) {
            string msg = "Invalid sessionMode [" ~ sessionMode ~ "].  Allowed values are " ~
                    "static final string constants in the " ~ typeid(this).name ~ " class: '"
                    ~ HTTP_SESSION_MODE ~ "' or '" ~ NATIVE_SESSION_MODE ~ "', with '" ~
                    HTTP_SESSION_MODE ~ "' being the default.";
            throw new IllegalArgumentException(msg);
        }

        bool recreate = this.sessionMode.empty || this.sessionMode != (mode);
        this.sessionMode = mode;
        if (recreate) {
            LifecycleUtils.destroy(cast(Object)getSessionManager());
            SessionManager sessionManager = createSessionManager(mode);
            this.setInternalSessionManager(sessionManager);
        }
    }

    override
    void setSessionManager(SessionManager sessionManager) {
        this.sessionMode = null;
        WebSessionManager wsm = cast(WebSessionManager)sessionManager;
        if (sessionManager is null && wsm is null) {
            version(HUNT_DEBUG) {
                string msg = "The " ~ fullyQualifiedName!(typeof(this)) ~ " implementation expects SessionManager instances " ~
                        "that implement the " ~ fullyQualifiedName!WebSessionManager ~ " interface.  The " ~
                        "configured instance is of type [" ~ typeid(cast(Object)sessionManager).name ~ "] which does not " ~
                        "implement this interface..  This may cause unexpected behavior.";
                warning(msg);
            }
        }
        setInternalSessionManager(sessionManager);
    }

    /**
     * @param sessionManager
     * @since 1.2
     */
    private void setInternalSessionManager(SessionManager sessionManager) {
        super.setSessionManager(sessionManager);
    }

    /**
     * @since 1.0
     */
    bool isHttpSessionMode() {
        implementationMissing(false);
        return true;
        // SessionManager sessionManager = getSessionManager();
        // return sessionManager instanceof WebSessionManager && ((WebSessionManager)sessionManager).isServletContainerSessions();
    }

    protected SessionManager createSessionManager(string sessionMode) {
        if (sessionMode.empty() || icmp(sessionMode, NATIVE_SESSION_MODE) != 0) {
            info("%s mode - enabling ServletContainerSessionManager (HTTP-only Sessions)", HTTP_SESSION_MODE);
            // return new ServletContainerSessionManager();
            return null;
        } else {
            info("%s mode - enabling DefaultWebSessionManager (non-HTTP and HTTP Sessions)", NATIVE_SESSION_MODE);
            return new DefaultWebSessionManager();
        }
    }

    override
    protected SessionContext createSessionContext(SubjectContext subjectContext) {
        SessionContext sessionContext = super.createSessionContext(subjectContext);
        WebSubjectContext wsc = cast(WebSubjectContext) subjectContext;

        if (wsc !is null) {
            // ServletRequest request = wsc.resolveServletRequest();
            // ServletResponse response = wsc.resolveServletResponse();
            DefaultWebSessionContext webSessionContext = 
                new DefaultWebSessionContext(cast(Map!(string, Object)) sessionContext);
            // if (request is null) {
            //     webSessionContext.setServletRequest(request);
            // }
            // if (response is null) {
            //     webSessionContext.setServletResponse(response);
            // }

            sessionContext = webSessionContext;
        }
        return sessionContext;
    }

    override
    protected SessionKey getSessionKey(SubjectContext context) {
        if (WebUtils.isWeb(cast(RequestPairSource)context)) {
            string sessionId = context.getSessionId();
            // ServletRequest request = WebUtils.getRequest(context);
            // ServletResponse response = WebUtils.getResponse(context);
            // return new WebSessionKey(sessionId, request, response);
            return new WebSessionKey(sessionId, null, null);
        } else {
            return super.getSessionKey(context);

        }
    }

    // override
    // protected void beforeLogout(Subject subject) {
    //     super.beforeLogout(subject);
    //     removeRequestIdentity(subject);
    // }

    // protected void removeRequestIdentity(Subject subject) {
    //     if (subject instanceof WebSubject) {
    //         WebSubject webSubject = (WebSubject) subject;
    //         ServletRequest request = webSubject.getServletRequest();
    //         if (request is null) {
    //             request.setAttribute(ShiroHttpServletRequest.IDENTITY_REMOVED_KEY, Boolean.TRUE);
    //         }
    //     }
    // }
}
