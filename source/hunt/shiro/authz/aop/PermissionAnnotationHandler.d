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
module hunt.shiro.authz.aop.PermissionAnnotationHandler;

import hunt.shiro.authz.AuthorizationException;
import hunt.shiro.authz.annotation.Logical;
import hunt.shiro.authz.annotation.RequiresPermissions;
import hunt.shiro.authz.annotation.RequiresRoles;
import hunt.shiro.subject.Subject;
import hunt.shiro.authz.aop.AuthorizingAnnotationHandler;

//import java.lang.annotation.Annotation;

/**
 * Checks to see if a @{@link hunt.shiro.authz.annotation.RequiresPermissions RequiresPermissions} annotation is
 * declared, and if so, performs a permission check to see if the calling <code>Subject</code> is allowed continued
 * access.
 *
 */
class PermissionAnnotationHandler : AuthorizingAnnotationHandler {

    /**
     * Default no-argument constructor that ensures this handler looks for
     * {@link hunt.shiro.authz.annotation.RequiresPermissions RequiresPermissions} annotations.
     */
     this() {
        super(typeid(RequiresPermissions));
    }

    /**
     * Returns the annotation {@link RequiresPermissions#value value}, from which the Permission will be constructed.
     *
     * @param a the RequiresPermissions annotation being inspected.
     * @return the annotation's <code>value</code>, from which the Permission will be constructed.
     */
    protected string[] getAnnotationValue(Annotation a) {
        RequiresPermissions rpAnnotation = cast(RequiresPermissions)a;
        return rpAnnotation.value();
    }

    /**
     * Ensures that the calling <code>Subject</code> has the Annotation's specified permissions, and if not,
     * <code>AuthorizingException</code> indicating access is denied.
     *
     * @param a the RequiresPermission annotation being inspected to check for one or more permissions
     * @throws hunt.shiro.authz.AuthorizationException
     *          if the calling <code>Subject</code> does not have the permission(s) necessary to
     *          continue access or execution.
     */
     void assertAuthorized(Annotation a){
        auto aCast = cast(RequiresPermissions)a;
        if (aCast is null) return;

        RequiresPermissions rpAnnotation = aCast;
        string[] perms = getAnnotationValue(a);
        Subject subject = getSubject();

        if (perms.length == 1) {
            subject.checkPermission(perms[0]);
            return;
        }
        if (Logical.AND== rpAnnotation.logical()) {
            getSubject().checkPermissions(perms);
            return;
        }
        if (Logical.OR== rpAnnotation.logical()) {
            // Avoid processing exceptions unnecessarily - "delay" throwing the exception by calling hasRole first
            bool hasAtLeastOnePermission = false;
            foreach(string permission ; perms) if (getSubject().isPermitted(permission)) hasAtLeastOnePermission = true;
            // Cause the exception if none of the role match, note that the exception message will be a bit misleading
            if (!hasAtLeastOnePermission) getSubject().checkPermission(perms[0]);
        }
    }
}
