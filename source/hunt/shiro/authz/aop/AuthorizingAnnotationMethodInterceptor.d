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
module hunt.shiro.authz.aop.AuthorizingAnnotationMethodInterceptor;

import hunt.shiro.aop.AnnotationMethodInterceptor;
import hunt.shiro.aop.AnnotationResolver;
import hunt.shiro.aop.MethodInvocation;
import hunt.shiro.authz.AuthorizationException;


/**
 * An <tt>AnnotationMethodInterceptor</tt> that asserts the calling code is authorized to execute the method
 * before allowing the invocation to continue by inspecting code annotations to perform an access control check.
 *
 */
abstract class AuthorizingAnnotationMethodInterceptor : AnnotationMethodInterceptor
{
    
    /**
     * Constructor that ensures the internal <code>handler</code> is set which will be used to perform the
     * authorization assertion checks when a supported annotation is encountered.
     * @param handler the internal <code>handler</code> used to perform authorization assertion checks when a 
     * supported annotation is encountered.
     */
     this( AuthorizingAnnotationHandler handler ) {
        super(handler);
    }

    /**
     *
     * @param handler
     * @param resolver
     */
     this( AuthorizingAnnotationHandler handler,
                                                   AnnotationResolver resolver) {
        super(handler, resolver);
    }

    /**
     * Ensures the <code>methodInvocation</code> is allowed to execute first before proceeding by calling the
     * {@link #assertAuthorized(hunt.shiro.aop.MethodInvocation) assertAuthorized} method first.
     *
     * @param methodInvocation the method invocation to check for authorization prior to allowing it to proceed/execute.
     * @return the return value from the method invocation (the value of {@link hunt.shiro.aop.MethodInvocation#proceed() MethodInvocation.proceed()}).
     * @throws hunt.shiro.authz.AuthorizationException if the <code>MethodInvocation</code> is not allowed to proceed.
     * @throws Throwable if any other error occurs.
     */
     Object invoke(MethodInvocation methodInvocation){
        assertAuthorized(methodInvocation);
        return methodInvocation.proceed();
    }

    /**
     * Ensures the calling Subject is authorized to execute the specified <code>MethodInvocation</code>.
     * <p/>
     * As this is an AnnotationMethodInterceptor, this implementation merely delegates to the internal
     * {@link AuthorizingAnnotationHandler AuthorizingAnnotationHandler} by first acquiring the annotation by
     * calling {@link #getAnnotation(MethodInvocation) getAnnotation(methodInvocation)} and then calls
     * {@link AuthorizingAnnotationHandler#assertAuthorized(java.lang.annotation.Annotation) handler.assertAuthorized(annotation)}.
     *
     * @param mi the <code>MethodInvocation</code> to check to see if it is allowed to proceed/execute.
     * @throws AuthorizationException if the method invocation is not allowed to continue/execute.
     */
     void assertAuthorized(MethodInvocation mi){
        try {
            (cast(AuthorizingAnnotationHandler)getHandler()).assertAuthorized(getAnnotation(mi));
        }
        catch(AuthorizationException ae) {
            // Annotation handler doesn't know why it was called, so add the information here if possible. 
            // Don't wrap the exception here since we don't want to mask the specific exception, such as 
            // UnauthenticatedException etc. 
            if (ae.getCause()  is null) ae.initCause(new AuthorizationException("Not authorized to invoke method: " ~ mi.getMethod()));
            throw ae;
        }         
    }
}
