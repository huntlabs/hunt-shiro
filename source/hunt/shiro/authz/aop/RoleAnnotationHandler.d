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
module hunt.shiro.authz.aop.RoleAnnotationHandler;

import hunt.shiro.authz.AuthorizationException;
import hunt.shiro.authz.annotation.Logical;
import hunt.shiro.authz.annotation.RequiresRoles;
import hunt.shiro.authz.aop.AuthorizingAnnotationHandler;

// import java.lang.annotation.Annotation;
import hunt.util.ArrayHelper;

/**
 * Checks to see if a @{@link hunt.shiro.authz.annotation.RequiresRoles RequiresRoles} annotation is declared, and if so, performs
 * a role check to see if the calling <code>Subject</code> is allowed to proceed.
 *
 * @since 0.9.0
 */
class RoleAnnotationHandler : AuthorizingAnnotationHandler {

    /**
     * Default no-argument constructor that ensures this handler looks for
     * {@link hunt.shiro.authz.annotation.RequiresRoles RequiresRoles} annotations.
     */
     this() {
        super(typeid(RequiresRoles));
    }

    /**
     * Ensures that the calling <code>Subject</code> has the Annotation's specified roles, and if not,
     * <code>AuthorizingException</code> indicating that access is denied.
     *
     * @param a the RequiresRoles annotation to use to check for one or more roles
     * @throws hunt.shiro.authz.AuthorizationException
     *          if the calling <code>Subject</code> does not have the role(s) necessary to
     *          proceed.
     */
     void assertAuthorized(Annotation a){
        auto aCast = cast(RequiresRoles)a;
        if (aCast is null) return;

        RequiresRoles rrAnnotation = aCast;
        string[] roles = rrAnnotation.value();

        if (roles.length == 1) {
            getSubject().checkRole(roles[0]);
            return;
        }
        if (Logical.AND== rrAnnotation.logical()) {
            getSubject().checkRoles(ArrayHelper.asList(roles));
            return;
        }
        if (Logical.OR== rrAnnotation.logical()) {
            // Avoid processing exceptions unnecessarily - "delay" throwing the exception by calling hasRole first
            bool hasAtLeastOneRole = false;
            foreach(string role ; roles) if (getSubject().hasRole(role)) hasAtLeastOneRole = true;
            // Cause the exception if none of the role match, note that the exception message will be a bit misleading
            if (!hasAtLeastOneRole) getSubject().checkRole(roles[0]);
        }
    }

}
