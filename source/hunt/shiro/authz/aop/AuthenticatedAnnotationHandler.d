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
module hunt.shiro.authz.aop.AuthenticatedAnnotationHandler;

// import java.lang.annotation.Annotation;
import hunt.shiro.authz.aop.AuthorizingAnnotationHandler;
import hunt.shiro.authz.UnauthenticatedException;
import hunt.shiro.authz.annotation.RequiresAuthentication;


/**
 * Handles {@link RequiresAuthentication RequiresAuthentication} annotations and ensures the calling subject is
 * authenticated before allowing access.
 *
 */
class AuthenticatedAnnotationHandler : AuthorizingAnnotationHandler {

    /**
     * Default no-argument constructor that ensures this handler to process
     * {@link hunt.shiro.authz.annotation.RequiresAuthentication RequiresAuthentication} annotations.
     */
     this() {
        super(typeid(RequiresAuthentication));
    }

    /**
     * Ensures that the calling <code>Subject</code> is authenticated, and if not,
     * {@link hunt.shiro.authz.UnauthenticatedException UnauthenticatedException} indicating the method is not allowed to be executed.
     *
     * @param a the annotation to inspect
     * @throws hunt.shiro.authz.UnauthenticatedException if the calling <code>Subject</code> has not yet
     * authenticated.
     */
     void assertAuthorized(Annotation a){
        auto aCast = cast(RequiresAuthentication)a;
        if (aCast !is null && !getSubject().isAuthenticated() ) {
            throw new UnauthenticatedException( "The current Subject is not authenticated.  Access denied." );
        }
    }
}
