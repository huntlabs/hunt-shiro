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
module hunt.shiro.util.PermissionUtils;

import hunt.shiro.authz.Permission;
import hunt.shiro.authz.permission.PermissionResolver;

import hunt.collection;
import hunt.Exceptions;
import hunt.text.StringUtils;
import hunt.util.ArrayHelper;

import std.array;

/**
 * Utility class to help with string-to-Permission object resolution.
 *
 */
class PermissionUtils {

    static Set!(Permission) resolveDelimitedPermissions(string s, PermissionResolver permissionResolver) {
        Set!(string) permStrings = toPermissionStrings(s);
        return resolvePermissions(permStrings, permissionResolver);
    }

    static Set!(string) toPermissionStrings(string permissionsString) {
        string[] tokens = StringUtils.split(permissionsString);
        if (!tokens.empty()) {
            return new LinkedHashSet!(string)(tokens);
        }
        return null;
    }

    static Set!(Permission) resolvePermissions(Collection!(string) permissionStrings, 
        PermissionResolver permissionResolver) {
        Set!(Permission) permissions = new LinkedHashSet!(Permission)(permissionStrings.size());
        foreach(string permissionString ; permissionStrings) {
            permissions.add(permissionResolver.resolvePermission(permissionString));
        }
        return permissions;
    }
}
