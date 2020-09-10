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
module hunt.shiro.mgt.DefaultSecurityManager;

import hunt.shiro.mgt.DefaultSubjectFactory;
import hunt.shiro.mgt.DefaultSubjectDAO;
import hunt.shiro.mgt.RememberMeManager;
import hunt.shiro.mgt.SessionsSecurityManager;
import hunt.shiro.mgt.SubjectFactory;
import hunt.shiro.mgt.SubjectDAO;

import hunt.shiro.Exceptions;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.Authenticator;
import hunt.shiro.authc.LogoutAware;
import hunt.shiro.authz.Authorizer;
import hunt.shiro.realm.Realm;
import hunt.shiro.session.Session;
import hunt.shiro.session.mgt.DefaultSessionContext;
import hunt.shiro.session.mgt.DefaultSessionKey;
import hunt.shiro.session.mgt.SessionContext;
import hunt.shiro.session.mgt.SessionKey;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.SubjectContext;
import hunt.shiro.subject.support.DefaultSubjectContext;
import hunt.shiro.util.CollectionUtils;
import hunt.logging.ConsoleLogger;

import hunt.Exceptions;
import hunt.collection;
import hunt.util.Common;

import std.conv;



/**
 * The Shiro framework's default concrete implementation of the {@link SecurityManager} interface,
 * based around a collection of {@link hunt.shiro.realm.Realm}s.  This implementation delegates its
 * authentication, authorization, and session operations to wrapped {@link Authenticator}, {@link Authorizer}, and
 * {@link hunt.shiro.session.mgt.SessionManager SessionManager} instances respectively via superclass
 * implementation.
 * <p/>
 * To greatly reduce and simplify configuration, this implementation (and its superclasses) will
 * create suitable defaults for all of its required dependencies, <em>except</em> the required one or more
 * {@link Realm Realm}s.  Because {@code Realm} implementations usually interact with an application's data model,
 * they are almost always application specific;  you will want to specify at least one custom
 * {@code Realm} implementation that 'knows' about your application's data/security model
 * (via {@link #setRealm} or one of the overloaded constructors).  All other attributes in this class hierarchy
 * will have suitable defaults for most enterprise applications.
 * <p/>
 * <b>RememberMe notice</b>: This class supports the ability to configure a
 * {@link #setRememberMeManager RememberMeManager}
 * for {@code RememberMe} identity services for login/logout, BUT, a default instance <em>will not</em> be created
 * for this attribute at startup.
 * <p/>
 * Because RememberMe services are inherently client tier-specific and
 * therefore aplication-dependent, if you want {@code RememberMe} services enabled, you will have to specify an
 * instance yourself via the {@link #setRememberMeManager(RememberMeManager) setRememberMeManager}
 * mutator.  However if you're reading this JavaDoc with the
 * expectation of operating in a Web environment, take a look at the
 * {@code hunt.shiro.web.DefaultWebSecurityManager} implementation, which
 * <em>does</em> support {@code RememberMe} services by default at startup.
 *
 */
class DefaultSecurityManager : SessionsSecurityManager {

    protected RememberMeManager rememberMeManager;
    protected SubjectDAO subjectDAO;
    protected SubjectFactory subjectFactory;

    /**
     * Default no-arg constructor.
     */
    this() {
        super();
        this.subjectFactory = new DefaultSubjectFactory();
        this.subjectDAO = new DefaultSubjectDAO();
    }

    /**
     * Supporting constructor for a single-realm application.
     *
     * @param singleRealm the single realm used by this SecurityManager.
     */
    this(Realm singleRealm) {
        this();
        setRealm(singleRealm);
    }

    /**
     * Supporting constructor for multiple {@link #setRealms realms}.
     *
     * @param realms the realm instances backing this SecurityManager.
     */
    this(Realm[] realms) {
        this();
        setRealms(realms);
    }

    /**
     * Returns the {@code SubjectFactory} responsible for creating {@link Subject} instances exposed to the application.
     *
     * @return the {@code SubjectFactory} responsible for creating {@link Subject} instances exposed to the application.
     */
    SubjectFactory getSubjectFactory() {
        return subjectFactory;
    }

    /**
     * Sets the {@code SubjectFactory} responsible for creating {@link Subject} instances exposed to the application.
     *
     * @param subjectFactory the {@code SubjectFactory} responsible for creating {@link Subject} instances exposed to the application.
     */
    void setSubjectFactory(SubjectFactory subjectFactory) {
        this.subjectFactory = subjectFactory;
    }

    /**
     * Returns the {@code SubjectDAO} responsible for persisting Subject state, typically used after login or when an
     * Subject identity is discovered (eg after RememberMe services).  Unless configured otherwise, the default
     * implementation is a {@link DefaultSubjectDAO}.
     *
     * @return the {@code SubjectDAO} responsible for persisting Subject state, typically used after login or when an
     *         Subject identity is discovered (eg after RememberMe services).
     * @see DefaultSubjectDAO
     */
    SubjectDAO getSubjectDAO() {
        return subjectDAO;
    }

    /**
     * Sets the {@code SubjectDAO} responsible for persisting Subject state, typically used after login or when an
     * Subject identity is discovered (eg after RememberMe services). Unless configured otherwise, the default
     * implementation is a {@link DefaultSubjectDAO}.
     *
     * @param subjectDAO the {@code SubjectDAO} responsible for persisting Subject state, typically used after login or when an
     *                   Subject identity is discovered (eg after RememberMe services).
     * @see DefaultSubjectDAO
     */
    void setSubjectDAO(SubjectDAO subjectDAO) {
        this.subjectDAO = subjectDAO;
    }

    RememberMeManager getRememberMeManager() {
        return rememberMeManager;
    }

    void setRememberMeManager(RememberMeManager rememberMeManager) {
        this.rememberMeManager = rememberMeManager;
    }

    protected SubjectContext createSubjectContext() {
        return new DefaultSubjectContext();
    }

    /**
     * Creates a {@code Subject} instance for the user represented by the given method arguments.
     *
     * @param token    the {@code AuthenticationToken} submitted for the successful authentication.
     * @param info     the {@code AuthenticationInfo} of a newly authenticated user.
     * @param existing the existing {@code Subject} instance that initiated the authentication attempt
     * @return the {@code Subject} instance that represents the context and session data for the newly
     *         authenticated subject.
     */
    protected Subject createSubject(AuthenticationToken token,
            AuthenticationInfo info, Subject existing) {
        SubjectContext context = createSubjectContext();
        context.setAuthenticated(true);
        context.setAuthenticationToken(token);
        context.setAuthenticationInfo(info);
        if (existing !is null) {
            context.setSubject(existing);
        }
        return createSubject(context);
    }

    /**
     * Binds a {@code Subject} instance created after authentication to the application for later use.
     * <p/>
     * As of Shiro 1.2, this method has been deprecated in favor of {@link #save(hunt.shiro.subject.Subject)},
     * which this implementation now calls.
     *
     * @param subject the {@code Subject} instance created after authentication to be bound to the application
     *                for later use.
     * @see #save(hunt.shiro.subject.Subject)
     * deprecated("") in favor of {@link #save(hunt.shiro.subject.Subject) save(subject)}.
     */
    deprecated("") protected void bind(Subject subject) {
        save(subject);
    }

    protected void rememberMeSuccessfulLogin(AuthenticationToken token,
            AuthenticationInfo info, Subject subject) {
        RememberMeManager rmm = getRememberMeManager();
        if (rmm !is null) {
            try {
                rmm.onSuccessfulLogin(subject, token, info);
            } catch (Exception e) {
                version (HUNT_SHIRO_DEBUG) {
                    string msg = "Delegate RememberMeManager instance of type [" ~ typeid(cast(Object) rmm)
                        .name ~ "] threw an exception during onSuccessfulLogin.  RememberMe services will not be "
                        ~ "performed for account [" ~ typeid(cast(Object) info).name ~ "].";
                    warning(msg, e);
                }
            }
        } else {
            version (HUNT_SHIRO_DEBUG) {
                tracef("This " ~ typeid(this)
                        .name ~ " instance does not have a " ~ "[" ~ typeid(RememberMeManager)
                        .toString() ~ "] instance configured.  RememberMe services " ~ "will not be performed for account [" ~ (
                            cast(Object) info).toString() ~ "].");
            }
        }
    }

    protected void rememberMeFailedLogin(AuthenticationToken token,
            AuthenticationException ex, Subject subject) {
        RememberMeManager rmm = getRememberMeManager();
        if (rmm !is null) {
            try {
                rmm.onFailedLogin(subject, token, ex);
            } catch (Exception e) {
                version (HUNT_SHIRO_DEBUG) {
                    string msg = "Delegate RememberMeManager instance of type [" ~ typeid(cast(Object) rmm)
                        .name ~ "] threw an exception during onFailedLogin for AuthenticationToken [" ~ typeid(
                                cast(Object) token).name ~ "].";
                    warning(msg, e);
                }
            }
        }
    }

    protected void rememberMeLogout(Subject subject) {
        RememberMeManager rmm = getRememberMeManager();
        if (rmm !is null) {
            try {
                rmm.onLogout(subject);
            } catch (Exception e) {
                version (HUNT_SHIRO_DEBUG) {
                    PrincipalCollection pc = (subject !is null ? subject.getPrincipals() : null);
                    string msg = "Delegate RememberMeManager instance of type [" ~ typeid(rmm).toString()
                        ~ "] threw an exception during onLogout for subject with principals [" ~ pc.to!string()
                        ~ "]";
                    warning(msg, e);
                }
            }
        }
    }

    /**
     * First authenticates the {@code AuthenticationToken} argument, and if successful, constructs a
     * {@code Subject} instance representing the authenticated account's identity.
     * <p/>
     * Once constructed, the {@code Subject} instance is then {@link #bind bound} to the application for
     * subsequent access before being returned to the caller.
     *
     * @param token the authenticationToken to process for the login attempt.
     * @return a Subject representing the authenticated user.
     * @throws AuthenticationException if there is a problem authenticating the specified {@code token}.
     */
    Subject login(Subject subject, AuthenticationToken token) {
        AuthenticationInfo info;
        try {
            info = authenticate(token);
        } catch (AuthenticationException ae) {
            try {
                onFailedLogin(token, ae, subject);
            } catch (Exception e) {
                version (HUNT_SHIRO_DEBUG) {
                    infof("onFailedLogin method threw an "
                            ~ "exception.  Logging and propagating original AuthenticationException.",
                            e);
                }
            }
            throw ae; //propagate
        }

        Subject loggedIn = createSubject(token, info, subject);
        // Always create a new subject whithout refering to the existing one.
        // Subject loggedIn = createSubject(token, info, null);

        onSuccessfulLogin(token, info, loggedIn);

        return loggedIn;
    }

    protected void onSuccessfulLogin(AuthenticationToken token,
            AuthenticationInfo info, Subject subject) {
        rememberMeSuccessfulLogin(token, info, subject);
    }

    protected void onFailedLogin(AuthenticationToken token,
            AuthenticationException ae, Subject subject) {
        rememberMeFailedLogin(token, ae, subject);
    }

    protected void beforeLogout(Subject subject) {
        rememberMeLogout(subject);
    }

    protected SubjectContext copy(SubjectContext subjectContext) {
        // warning((cast(Object)subjectContext).toString());
        return new DefaultSubjectContext(subjectContext);
    }

    /**
     * This implementation functions as follows:
     * <p/>
     * <ol>
     * <li>Ensures the {@code SubjectContext} is as populated as it can be, using heuristics to acquire
     * data that may not have already been available to it (such as a referenced session or remembered principals).</li>
     * <li>Calls {@link #doCreateSubject(hunt.shiro.subject.SubjectContext)} to actually perform the
     * {@code Subject} instance creation.</li>
     * <li>calls {@link #save(hunt.shiro.subject.Subject) save(subject)} to ensure the constructed
     * {@code Subject}'s state is accessible for future requests/invocations if necessary.</li>
     * <li>returns the constructed {@code Subject} instance.</li>
     * </ol>
     *
     * @param subjectContext any data needed to direct how the Subject should be constructed.
     * @return the {@code Subject} instance reflecting the specified contextual data.
     * @see #ensureSecurityManager(hunt.shiro.subject.SubjectContext)
     * @see #resolveSession(hunt.shiro.subject.SubjectContext)
     * @see #resolvePrincipals(hunt.shiro.subject.SubjectContext)
     * @see #doCreateSubject(hunt.shiro.subject.SubjectContext)
     * @see #save(hunt.shiro.subject.Subject)
     */
    Subject createSubject(SubjectContext subjectContext) {
        //create a copy so we don't modify the argument's backing map:
        SubjectContext context = copy(subjectContext);

        //ensure that the context has a SecurityManager instance, and if not, add one:
        context = ensureSecurityManager(context);

        //Resolve an associated Session (usually based on a referenced session ID), and place it in the context before
        //sending to the SubjectFactory.  The SubjectFactory should not need to know how to acquire sessions as the
        //process is often environment specific - better to shield the SF from these details:
        context = resolveSession(context);

        //Similarly, the SubjectFactory should not require any concept of RememberMe - translate that here first
        //if possible before handing off to the SubjectFactory:
        context = resolvePrincipals(context);

        Subject subject = doCreateSubject(context);

        //save this subject for future reference if necessary:
        //(this is needed here in case rememberMe principals were resolved and they need to be stored in the
        //session, so we don't constantly rehydrate the rememberMe PrincipalCollection on every operation).
        //Added in 1.2:
        save(subject);

        return subject;
    }

    /**
     * Actually creates a {@code Subject} instance by delegating to the internal
     * {@link #getSubjectFactory() subjectFactory}.  By the time this method is invoked, all possible
     * {@code SubjectContext} data (session, principals, et. al.) has been made accessible using all known heuristics
     * and will be accessible to the {@code subjectFactory} via the {@code subjectContext.resolve*} methods.
     *
     * @param context the populated context (data map) to be used by the {@code SubjectFactory} when creating a
     *                {@code Subject} instance.
     * @return a {@code Subject} instance reflecting the data in the specified {@code SubjectContext} data map.
     * @see #getSubjectFactory()
     * @see SubjectFactory#createSubject(hunt.shiro.subject.SubjectContext)
     */
    protected Subject doCreateSubject(SubjectContext context) {
        return getSubjectFactory().createSubject(context);
    }

    /**
     * Saves the subject's state to a persistent location for future reference if necessary.
     * <p/>
     * This implementation merely delegates to the internal {@link #setSubjectDAO(SubjectDAO) subjectDAO} and calls
     * {@link SubjectDAO#save(hunt.shiro.subject.Subject) subjectDAO.save(subject)}.
     *
     * @param subject the subject for which state will potentially be persisted
     * @see SubjectDAO#save(hunt.shiro.subject.Subject)
     */
    protected void save(Subject subject) {
        this.subjectDAO.save(subject);
    }

    /**
     * Removes (or 'unbinds') the Subject's state from the application, typically called during {@link #logout}..
     * <p/>
     * This implementation merely delegates to the internal {@link #setSubjectDAO(SubjectDAO) subjectDAO} and calls
     * {@link SubjectDAO#remove(hunt.shiro.subject.Subject) remove(subject)}.
     *
     * @param subject the subject for which state will be removed
     * @see SubjectDAO#remove(hunt.shiro.subject.Subject)
     */
    protected void remove(Subject subject) {
        this.subjectDAO.remove(subject);
    }

    /**
     * Determines if there is a {@code SecurityManager} instance in the context, and if not, adds 'this' to the
     * context.  This ensures the SubjectFactory instance will have access to a SecurityManager during Subject
     * construction if necessary.
     *
     * @param context the subject context data that may contain a SecurityManager instance.
     * @return The SubjectContext to use to pass to a {@link SubjectFactory} for subject creation.
     */
    //@SuppressWarnings({"unchecked"})
    protected SubjectContext ensureSecurityManager(SubjectContext context) {
        if (context.resolveSecurityManager() !is null) {
            version (HUNT_SHIRO_DEBUG) {
                tracef("Context already contains a SecurityManager instance.  Returning.");
            }
            return context;
        }
        version (HUNT_SHIRO_DEBUG) {
            warning("No SecurityManager found in context.  Adding self reference.");
        }
        context.setSecurityManager(this);
        return context;
    }

    /**
     * Attempts to resolve any associated session based on the context and returns a
     * context that represents this resolved {@code Session} to ensure it may be referenced if necessary by the
     * invoked {@link SubjectFactory} that performs actual {@link Subject} construction.
     * <p/>
     * If there is a {@code Session} already in the context because that is what the caller wants to be used for
     * {@code Subject} construction, or if no session is resolved, this method effectively does nothing
     * returns the context method argument unaltered.
     *
     * @param context the subject context data that may resolve a Session instance.
     * @return The context to use to pass to a {@link SubjectFactory} for subject creation.
     */
    //@SuppressWarnings({"unchecked"})
    protected SubjectContext resolveSession(SubjectContext context) {
        if (context.resolveSession() !is null) {
            version (HUNT_SHIRO_DEBUG)
                tracef("Context already contains a session.  Returning.");
            return context;
        }
        try {
            //Context couldn't resolve it directly, let's see if we can since we have direct access to 
            //the session manager:
            Session session = resolveContextSession(context);
            if (session !is null) {
                context.setSession(session);
            }
        } catch (InvalidSessionException e) {
            warningf("Resolved SubjectContext context session is invalid.  Ignoring and creating an anonymous "
                    ~ "(session-less) Subject instance.", e);
        }
        return context;
    }

    protected Session resolveContextSession(SubjectContext context) {
        SessionKey key = getSessionKey(context);
        if (key !is null) {
            return getSession(key);
        }
        return null;
    }

    protected SessionKey getSessionKey(SubjectContext context) {
        string sessionId = context.getSessionId();
        if (sessionId !is null) {
            return new DefaultSessionKey(sessionId);
        }
        return null;
    }

    private static bool isEmpty(PrincipalCollection pc) {
        return pc is null || pc.isEmpty();
    }

    /**
     * Attempts to resolve an identity (a {@link PrincipalCollection}) for the context using heuristics.  This
     * implementation functions as follows:
     * <ol>
     * <li>Check the context to see if it can already {@link SubjectContext#resolvePrincipals resolve an identity}.  If
     * so, this method does nothing and returns the method argument unaltered.</li>
     * <li>Check for a RememberMe identity by calling {@link #getRememberedIdentity}.  If that method returns a
     * non-null value, place the remembered {@link PrincipalCollection} in the context.</li>
     * </ol>
     *
     * @param context the subject context data that may provide (directly or indirectly through one of its values) a
     *                {@link PrincipalCollection} identity.
     * @return The Subject context to use to pass to a {@link SubjectFactory} for subject creation.
     */
    //@SuppressWarnings({"unchecked"})
    protected SubjectContext resolvePrincipals(SubjectContext context) {

        PrincipalCollection principals = context.resolvePrincipals();

        if (isEmpty(principals)) {
            version (HUNT_SHIRO_DEBUG)
                tracef("No identity (PrincipalCollection) found in the context.  Looking for a remembered identity.");

            principals = getRememberedIdentity(context);

            if (!isEmpty(principals)) {
                version (HUNT_SHIRO_DEBUG)
                    tracef("Found remembered PrincipalCollection.  Adding to the context to be used "
                            ~ "for subject construction by the SubjectFactory.");

                context.setPrincipals(principals);

                // The following call was removed (commented out) in Shiro 1.2 because it uses the session as an
                // implementation strategy.  Session use for Shiro's own needs should be controlled in a single place
                // to be more manageable for end-users: there are a number of stateless (e.g. REST) applications that
                // use Shiro that need to ensure that sessions are only used when desirable.  If Shiro's internal
                // implementations used Subject sessions (setting attributes) whenever we wanted, it would be much
                // harder for end-users to control when/where that occurs.
                //
                // Because of this, the SubjectDAO was created as the single point of control, and session state logic
                // has been moved to the DefaultSubjectDAO implementation.

                // Removed in Shiro 1.2.  SHIRO-157 is still satisfied by the new DefaultSubjectDAO implementation
                // introduced in 1.2
                // Satisfies SHIRO-157:
                // bindPrincipalsToSession(principals, context);

            } else {
                version (HUNT_SHIRO_DEBUG)
                    tracef("No remembered identity found.  Returning original context.");
            }
        }

        return context;
    }

    protected SessionContext createSessionContext(SubjectContext subjectContext) {
        Map!(string, Object) contextMap = cast(Map!(string, Object)) subjectContext;
        DefaultSessionContext sessionContext = new DefaultSessionContext();
        if (!CollectionUtils.isEmpty(contextMap)) {
            sessionContext.putAll(contextMap);
        }
        string sessionId = subjectContext.getSessionId();
        if (sessionId !is null) {
            sessionContext.setSessionId(sessionId);
        }
        string host = subjectContext.resolveHost();
        if (host !is null) {
            sessionContext.setHost(host);
        }
        return sessionContext;
    }

    void logout(Subject subject) {

        if (subject is null) {
            throw new IllegalArgumentException("Subject method argument cannot be null.");
        }

        beforeLogout(subject);

        PrincipalCollection principals = subject.getPrincipals();
        if (principals !is null && !principals.isEmpty()) {
            version (HUNT_SHIRO_DEBUG) {
                tracef("Logging out subject with primary principal %s",
                        principals.getPrimaryPrincipal());
            }
            Authenticator authc = getAuthenticator();
            LogoutAware la = cast(LogoutAware) authc;
            if (la !is null) {
                la.onLogout(principals);
            }
        }

        try {
            remove(subject);
        } catch (Exception e) {
            string msg = "Unable to cleanly unbind Subject.  Ignoring (logging out).";
            warning(msg);
            version (HUNT_SHIRO_DEBUG) {
                warning(e);
            }
        }

        try {
            stopSession(subject);
        } catch (Exception e) {
            version (HUNT_SHIRO_DEBUG) {
                string msg = "Unable to cleanly stop Session for Subject [" ~ subject.getPrincipal()
                    .toString() ~ "] " ~ "Ignoring (logging out).";
                tracef(msg, e);
            }
        }
    }

    protected void stopSession(Subject subject) {
        Session s = subject.getSession(false);
        if (s !is null) {
            s.stop();
        }
    }

    /**
     * Unbinds or removes the Subject's state from the application, typically called during {@link #logout}.
     * <p/>
     * This has been deprecated in Shiro 1.2 in favor of the {@link #remove(hunt.shiro.subject.Subject) remove}
     * method.  The implementation has been updated to invoke that method.
     *
     * @param subject the subject to unbind from the application as it will no longer be used.
     * deprecated("") in Shiro 1.2 in favor of {@link #remove(hunt.shiro.subject.Subject)}
     */
    deprecated("") //@SuppressWarnings({"UnusedDeclaration"})
    protected void unbind(Subject subject) {
        remove(subject);
    }

    protected PrincipalCollection getRememberedIdentity(SubjectContext subjectContext) {
        RememberMeManager rmm = getRememberMeManager();
        if (rmm !is null) {
            try {
                return rmm.getRememberedPrincipals(subjectContext);
            } catch (Exception e) {
                version (HUNT_SHIRO_DEBUG) {
                    string msg = "Delegate RememberMeManager instance of type [" ~ typeid(cast(Object) rmm)
                        .name ~ "] threw an exception during getRememberedPrincipals().";
                    warning(msg, e);
                }
            }
        }
        return null;
    }
}
