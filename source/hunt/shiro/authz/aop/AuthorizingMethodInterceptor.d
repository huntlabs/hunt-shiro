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
module hunt.shiro.authz.aop.AuthorizingMethodInterceptor;

import hunt.shiro.aop.MethodInterceptorSupport;
import hunt.shiro.aop.MethodInvocation;
import hunt.shiro.authz.AuthorizationException;

/**
 * Basic abstract class to support intercepting methods that perform authorization (access control) checks.
 *
 */
abstract class AuthorizingMethodInterceptor : MethodInterceptorSupport {

    /**
     * Invokes the specified method (<code>methodInvocation.{@link hunt.shiro.aop.MethodInvocation#proceed proceed}()</code>
     * if authorization is allowed by first
     * calling {@link #assertAuthorized(hunt.shiro.aop.MethodInvocation) assertAuthorized}.
     */
     Object invoke(MethodInvocation methodInvocation){
        assertAuthorized(methodInvocation);
        return methodInvocation.proceed();
    }

    /**
     * Asserts that the specified MethodInvocation is allowed to continue by performing any necessary authorization
     * (access control) checks first.
     * @param methodInvocation the <code>MethodInvocation</code> to invoke.
     * @throws AuthorizationException if the <code>methodInvocation</code> should not be allowed to continue/execute.
     */
    protected abstract void assertAuthorized(MethodInvocation methodInvocation);

}
