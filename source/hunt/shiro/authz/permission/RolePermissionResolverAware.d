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
module hunt.shiro.authz.permission.RolePermissionResolverAware;

import hunt.shiro.authz.permission.RolePermissionResolver;

/**
 * Interface implemented by a component that wishes to use any application-configured <tt>RolePermissionResolver</tt> that
 * might already exist instead of potentially creating one itself.
 *
 * <p>This is mostly implemented by {@link hunt.shiro.authz.Authorizer Authorizer} and
 * {@link hunt.shiro.realm.Realm Realm} implementations since they
 * are the ones performing permission checks and need to know how to resolve Strings into
 * {@link hunt.shiro.authz.Permission Permission} instances.
 *
 */
interface RolePermissionResolverAware {

    /**
     * Sets the specified <tt>RolePermissionResolver</tt> on this instance.
     *
     * @param rpr the <tt>RolePermissionResolver</tt> being set.
     */
     void setRolePermissionResolver(RolePermissionResolver rpr);
}
