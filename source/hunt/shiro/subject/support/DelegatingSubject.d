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
module hunt.shiro.subject.support.DelegatingSubject;

import hunt.shiro.authc.AuthenticationException;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.HostAuthenticationToken;
import hunt.shiro.authz.AuthorizationException;
import hunt.shiro.authz.Permission;
import hunt.shiro.authz.UnauthenticatedException;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.session.InvalidSessionException;
import hunt.shiro.session.ProxiedSession;
import hunt.shiro.session.Session;
import hunt.shiro.session.SessionException;
import hunt.shiro.session.mgt.DefaultSessionContext;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.subject.ExecutionException;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.util.CollectionUtils;
// import hunt.shiro.util.StringUtils;
import hunt.logging;

import hunt.collection;

import java.util.concurrent.Callable;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Implementation of the {@code Subject} interface that delegates
 * method calls to an underlying {@link hunt.shiro.mgt.SecurityManager SecurityManager} instance for security checks.
 * It is essentially a {@code SecurityManager} proxy.
 * <p/>
 * This implementation does not maintain state such as roles and permissions (only {@code Subject}
 * {@link #getPrincipals() principals}, such as usernames or user primary keys) for better performance in a stateless
 * architecture.  It instead asks the underlying {@code SecurityManager} every time to perform
 * the authorization check.
 * <p/>
 * A common misconception in using this implementation is that an EIS resource (RDBMS, etc) would
 * be &quot;hit&quot; every time a method is called.  This is not necessarily the case and is
 * up to the implementation of the underlying {@code SecurityManager} instance.  If caching of authorization
 * data is desired (to eliminate EIS round trips and therefore improve database performance), it is considered
 * much more elegant to let the underlying {@code SecurityManager} implementation or its delegate components
 * manage caching, not this class.  A {@code SecurityManager} is considered a business-tier component,
 * where caching strategies are better managed.
 * <p/>
 * Applications from large and clustered to simple and JVM-local all benefit from
 * stateless architectures.  This implementation plays a part in the stateless programming
 * paradigm and should be used whenever possible.
 *
 */
class DelegatingSubject : Subject {



    private enum string RUN_AS_PRINCIPALS_SESSION_KEY =
            typeid(DelegatingSubject).name ~ ".RUN_AS_PRINCIPALS_SESSION_KEY";

    protected PrincipalCollection principals;
    protected bool authenticated;
    protected string host;
    protected Session session;
    /**
     */
    protected bool sessionCreationEnabled;

    protected  SecurityManager securityManager;

    this(SecurityManager securityManager) {
        this(null, false, null, null, securityManager);
    }

    this(PrincipalCollection principals, bool authenticated, string host,
                             Session session, SecurityManager securityManager) {
        this(principals, authenticated, host, session, true, securityManager);
    }

    //since 1.2
    this(PrincipalCollection principals, bool authenticated, string host,
                             Session session, bool sessionCreationEnabled, 
                             SecurityManager securityManager) {
        if (securityManager  is null) {
            throw new IllegalArgumentException("SecurityManager argument cannot be null.");
        }
        this.securityManager = securityManager;
        this.principals = principals;
        this.authenticated = authenticated;
        this.host = host;
        if (session !is null) {
            this.session = decorate(session);
        }
        this.sessionCreationEnabled = sessionCreationEnabled;
    }

    protected Session decorate(Session session) {
        if (session  is null) {
            throw new IllegalArgumentException("session cannot be null");
        }
        return new StoppingAwareProxiedSession(session, this);
    }

     SecurityManager getSecurityManager() {
        return securityManager;
    }

    private static bool isEmpty(PrincipalCollection pc) {
        return pc  is null || pc.isEmpty();
    }

    protected bool hasPrincipals() {
        return !isEmpty(getPrincipals());
    }

    /**
     * Returns the host name or IP associated with the client who created/is interacting with this Subject.
     *
     * @return the host name or IP associated with the client who created/is interacting with this Subject.
     */
     string getHost() {
        return this.host;
    }

    private Object getPrimaryPrincipal(PrincipalCollection principals) {
        if (!isEmpty(principals)) {
            return principals.getPrimaryPrincipal();
        }
        return null;
    }

    /**
     * @see Subject#getPrincipal()
     */
     Object getPrincipal() {
        return getPrimaryPrincipal(getPrincipals());
    }

     PrincipalCollection getPrincipals() {
        List!(PrincipalCollection) runAsPrincipals = getRunAsPrincipalsStack();
        return CollectionUtils.isEmpty(runAsPrincipals) ? this.principals : runAsPrincipals.get(0);
    }

     bool isPermitted(string permission) {
        return hasPrincipals() && securityManager.isPermitted(getPrincipals(), permission);
    }

     bool isPermitted(Permission permission) {
        return hasPrincipals() && securityManager.isPermitted(getPrincipals(), permission);
    }

     bool[] isPermitted(string[] permissions...) {
        if (hasPrincipals()) {
            return securityManager.isPermitted(getPrincipals(), permissions);
        } else {
            return new bool[permissions.length];
        }
    }

     bool[] isPermitted(List!(Permission) permissions) {
        if (hasPrincipals()) {
            return securityManager.isPermitted(getPrincipals(), permissions);
        } else {
            return new bool[permissions.size()];
        }
    }

     bool isPermittedAll(string[] permissions...) {
        return hasPrincipals() && securityManager.isPermittedAll(getPrincipals(), permissions);
    }

     bool isPermittedAll(Collection!(Permission) permissions) {
        return hasPrincipals() && securityManager.isPermittedAll(getPrincipals(), permissions);
    }

    protected void assertAuthzCheckPossible(){
        if (!hasPrincipals()) {
            string msg = "This subject is anonymous - it does not have any identifying principals and " ~
                    "authorization operations require an identity to check against.  A Subject instance will " ~
                    "acquire these identifying principals automatically after a successful login is performed " ~
                    "be executing " ~ typeid(Subject).name ~ ".login(AuthenticationToken) or when 'Remember Me' " ~
                    "functionality is enabled by the SecurityManager.  This exception can also occur when a " ~
                    "previously logged-in Subject has logged out which " ~
                    "makes it anonymous again.  Because an identity is currently not known due to any of these " ~
                    "conditions, authorization is denied.";
            throw new UnauthenticatedException(msg);
        }
    }

     void checkPermission(string permission){
        assertAuthzCheckPossible();
        securityManager.checkPermission(getPrincipals(), permission);
    }

     void checkPermission(Permission permission){
        assertAuthzCheckPossible();
        securityManager.checkPermission(getPrincipals(), permission);
    }

     void checkPermissions(string[] permissions...){
        assertAuthzCheckPossible();
        securityManager.checkPermissions(getPrincipals(), permissions);
    }

     void checkPermissions(Collection!(Permission) permissions){
        assertAuthzCheckPossible();
        securityManager.checkPermissions(getPrincipals(), permissions);
    }

     bool hasRole(string roleIdentifier) {
        return hasPrincipals() && securityManager.hasRole(getPrincipals(), roleIdentifier);
    }

     bool[] hasRoles(List!(string) roleIdentifiers) {
        if (hasPrincipals()) {
            return securityManager.hasRoles(getPrincipals(), roleIdentifiers);
        } else {
            return new bool[roleIdentifiers.size()];
        }
    }

     bool hasAllRoles(Collection!(string) roleIdentifiers) {
        return hasPrincipals() && securityManager.hasAllRoles(getPrincipals(), roleIdentifiers);
    }

     void checkRole(string role){
        assertAuthzCheckPossible();
        securityManager.checkRole(getPrincipals(), role);
    }

     void checkRoles(string[] roleIdentifiers...){
        assertAuthzCheckPossible();
        securityManager.checkRoles(getPrincipals(), roleIdentifiers);
    }

     void checkRoles(Collection!(string) roles){
        assertAuthzCheckPossible();
        securityManager.checkRoles(getPrincipals(), roles);
    }

     void login(AuthenticationToken token){
        clearRunAsIdentitiesInternal();
        Subject subject = securityManager.login(this, token);

        PrincipalCollection principals;

        string host = null;

        DelegatingSubject delegating = cast(DelegatingSubject) subject;
        if (delegating !is null) {
            //we have to do this in case there are assumed identities - we don't want to lose the 'real' principals:
            principals = delegating.principals;
            host = delegating.host;
        } else {
            principals = subject.getPrincipals();
        }

        if (principals  is null || principals.isEmpty()) {
            string msg = "Principals returned from securityManager.login( token ) returned a null or " ~
                    "empty value.  This value must be non null and populated with one or more elements.";
            throw new IllegalStateException(msg);
        }
        this.principals = principals;
        this.authenticated = true;
        HostAuthenticationToken hat = cast(HostAuthenticationToken) token;
        if (hat !is null) {
            host = hat.getHost();
        }
        if (host !is null) {
            this.host = host;
        }
        Session session = subject.getSession(false);
        if (session !is null) {
            this.session = decorate(session);
        } else {
            this.session = null;
        }
    }

     bool isAuthenticated() {
        return authenticated;
    }

     bool isRemembered() {
        PrincipalCollection principals = getPrincipals();
        return principals !is null && !principals.isEmpty() && !isAuthenticated();
    }

    /**
     * Returns {@code true} if this Subject is allowed to create sessions, {@code false} otherwise.
     *
     * @return {@code true} if this Subject is allowed to create sessions, {@code false} otherwise.
     */
    protected bool isSessionCreationEnabled() {
        return this.sessionCreationEnabled;
    }

     Session getSession() {
        return getSession(true);
    }

     Session getSession(bool create) {
        version(HUNT_DEBUG) {
            tracef("attempting to get session; create = " ~ create +
                    "; session is null = " ~ (this.session  is null) +
                    "; session has id = " ~ (this.session !is null && session.getId() !is null));
        }

        if (this.session  is null && create) {

            //added in 1.2:
            if (!isSessionCreationEnabled()) {
                string msg = "Session creation has been disabled for the current subject.  This exception indicates " ~
                        "that there is either a programming error (using a session when it should never be " ~
                        "used) or that Shiro's configuration needs to be adjusted to allow Sessions to be created " ~
                        "for the current Subject.  See the " ~ typeid(DisabledSessionException).name ~ " JavaDoc " ~
                        "for more.";
                throw new DisabledSessionException(msg);
            }

            tracef("Starting session for host %s", getHost());
            SessionContext sessionContext = createSessionContext();
            Session session = this.securityManager.start(sessionContext);
            this.session = decorate(session);
        }
        return this.session;
    }

    protected SessionContext createSessionContext() {
        SessionContext sessionContext = new DefaultSessionContext();
        if (StringUtils.hasText(host)) {
            sessionContext.setHost(host);
        }
        return sessionContext;
    }

    private void clearRunAsIdentitiesInternal() {
        //try/catch added for SHIRO-298
        try {
            clearRunAsIdentities();
        } catch (SessionException se) {
            tracef("Encountered session exception trying to clear 'runAs' identities during logout.  This " ~
                    "can generally safely be ignored.", se);
        }
    }

     void logout() {
        try {
            clearRunAsIdentitiesInternal();
            this.securityManager.logout(this);
        } finally {
            this.session = null;
            this.principals = null;
            this.authenticated = false;
            //Don't set securityManager to null here - the Subject can still be
            //used, it is just considered anonymous at this point.  The SecurityManager instance is
            //necessary if the subject would log in again or acquire a new session.  This is in response to
            //https://issues.apache.org/jira/browse/JSEC-22
            //this.securityManager = null;
        }
    }

    private void sessionStopped() {
        this.session = null;
    }

    V execute(V)(Callable!(V) callable) {
        Callable!(V) associated = associateWith(callable);
        try {
            return associated.call();
        } catch (Throwable t) {
            throw new ExecutionException(t);
        }
    }

    void execute(Runnable runnable) {
        Runnable associated = associateWith(runnable);
        associated.run();
    }

    Callable!(V) associateWith(V)(Callable!(V) callable) {
        return new SubjectCallable!(V)(this, callable);
    }

    Runnable associateWith(Runnable runnable) {
        ThreadEx tx = cast(ThreadEx) runnable;
        if (tx !is null) {
            string msg = "This implementation does not support Thread arguments because of JDK ThreadLocal " ~
                    "inheritance mechanisms required by Shiro.  Instead, the method argument should be a non-Thread " ~
                    "Runnable and the return value from this method can then be given to an ExecutorService or " ~
                    "another Thread.";
            throw new UnsupportedOperationException(msg);
        }
        return new SubjectRunnable(this, runnable);
    }

    private class StoppingAwareProxiedSession : ProxiedSession {

        private final DelegatingSubject owner;

        private this(Session target, DelegatingSubject owningSubject) {
            super(target);
            owner = owningSubject;
        }

         void stop(){
            super.stop();
            owner.sessionStopped();
        }
    }


    // ======================================
    // 'Run As' support implementations
    // ======================================

     void runAs(PrincipalCollection principals) {
        if (!hasPrincipals()) {
            string msg = "This subject does not yet have an identity.  Assuming the identity of another " ~
                    "Subject is only allowed for Subjects with an existing identity.  Try logging this subject in " ~
                    "first, or using the " ~ typeid(Builder).name ~ " to build ad hoc Subject instances " ~
                    "with identities as necessary.";
            throw new IllegalStateException(msg);
        }
        pushIdentity(principals);
    }

     bool isRunAs() {
        List!(PrincipalCollection) stack = getRunAsPrincipalsStack();
        return !CollectionUtils.isEmpty(stack);
    }

    PrincipalCollection getPreviousPrincipals() {
        PrincipalCollection previousPrincipals = null;
        List!(PrincipalCollection) stack = getRunAsPrincipalsStack();
        int stackSize = stack !is null ? stack.size() : 0;
        if (stackSize > 0) {
            if (stackSize == 1) {
                previousPrincipals = this.principals;
            } else {
                //always get the one behind the current:
                assert (stack !is null);
                previousPrincipals = stack.get(1);
            }
        }
        return previousPrincipals;
    }

    PrincipalCollection releaseRunAs() {
        return popIdentity();
    }


    private List!(PrincipalCollection) getRunAsPrincipalsStack() {
        Session session = getSession(false);
        if (session !is null) {
            return cast(List!(PrincipalCollection)) session.getAttribute(RUN_AS_PRINCIPALS_SESSION_KEY);
        }
        return null;
    }

    private void clearRunAsIdentities() {
        Session session = getSession(false);
        if (session !is null) {
            session.removeAttribute(RUN_AS_PRINCIPALS_SESSION_KEY);
        }
    }

    private void pushIdentity(PrincipalCollection principals){
        if (isEmpty(principals)) {
            string msg = "Specified Subject principals cannot be null or empty for 'run as' functionality.";
            throw new NullPointerException(msg);
        }
        List!(PrincipalCollection) stack = getRunAsPrincipalsStack();
        if (stack  is null) {
            stack = new CopyOnWriteArrayList!(PrincipalCollection)();
        }
        stack.add(0, principals);
        Session session = getSession();
        session.setAttribute(RUN_AS_PRINCIPALS_SESSION_KEY, stack);
    }

    private PrincipalCollection popIdentity() {
        PrincipalCollection popped = null;

        List!(PrincipalCollection) stack = getRunAsPrincipalsStack();
        if (!CollectionUtils.isEmpty(stack)) {
            popped = stack.remove(0);
            Session session;
            if (!CollectionUtils.isEmpty(stack)) {
                //persist the changed stack to the session
                session = getSession();
                session.setAttribute(RUN_AS_PRINCIPALS_SESSION_KEY, stack);
            } else {
                //stack is empty, remove it from the session:
                clearRunAsIdentities();
            }
        }

        return popped;
    }
}
