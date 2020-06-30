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
module hunt.shiro.web.mgt.DefaultWebSubjectFactory;

// import hunt.shiro.mgt.DefaultSubjectFactory;
// import hunt.shiro.mgt.SecurityManager;
// import hunt.shiro.session.Session;
// import hunt.shiro.subject.PrincipalCollection;
// import hunt.shiro.subject.Subject;
// import hunt.shiro.subject.SubjectContext;
// import hunt.shiro.web.subject.WebSubjectContext;
// import hunt.shiro.web.subject.support.WebDelegatingSubject;

// // import javax.servlet.ServletRequest;
// // import javax.servlet.ServletResponse;

// import hunt.shiro.web.RequestPairSource;

// /**
//  * A {@code SubjectFactory} implementation that creates {@link WebDelegatingSubject} instances.
//  * <p/>
//  * {@code WebDelegatingSubject} instances are required if Request/Response objects are to be maintained across
//  * threads when using the {@code Subject} {@link Subject#associateWith(java.util.concurrent.Callable) createCallable}
//  * and {@link Subject#associateWith(Runnable) createRunnable} methods.
//  *
//  * @since 1.0
//  */
// class DefaultWebSubjectFactory : DefaultSubjectFactory {

//     this() {
//         super();
//     }

//     override Subject createSubject(SubjectContext context) {
//         WebSubjectContext wsc = cast(WebSubjectContext) context;
//         if (wsc is null) {
//             return super.createSubject(context);
//         }
//         SecurityManager securityManager = wsc.resolveSecurityManager();
//         Session session = wsc.resolveSession();
//         bool sessionEnabled = wsc.isSessionCreationEnabled();
//         PrincipalCollection principals = wsc.resolvePrincipals();
//         bool authenticated = wsc.resolveAuthenticated();
//         string host = wsc.resolveHost();
//         ServletRequest request = wsc.resolveServletRequest();
//         ServletResponse response = wsc.resolveServletResponse();

//         return new WebDelegatingSubject(principals, authenticated, host, session, sessionEnabled,
//                 request, response, securityManager);
//     }

//     /**
//      * @deprecated since 1.2 - override {@link #createSubject(hunt.shiro.subject.SubjectContext)} directly if you
//      *             need to instantiate a custom {@link Subject} class.
//      */
//     protected Subject newSubjectInstance(PrincipalCollection principals, bool authenticated,
//                                          string host, Session session,
//                                          ServletRequest request, ServletResponse response,
//                                          SecurityManager securityManager) {
//         return new WebDelegatingSubject(principals, authenticated, host, session, true,
//                 request, response, securityManager);
//     }
// }
