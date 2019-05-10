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
module hunt.shiro.authz.SimpleRole;

import hunt.shiro.authz.Permission;

import hunt.util.Common;
import hunt.collection;

/**
 * A simple representation of a security role that has a name and a collection of permissions.  This object can be
 * used internally by Realms to maintain authorization state.
 *
 */
class SimpleRole {

    protected string name = null;
    protected Set!(Permission) permissions;

    this() {
    }

     this(string name) {
        setName(name);
    }

     this(string name, Set!(Permission) permissions) {
        setName(name);
        setPermissions(permissions);
    }

    string getName() @trusted nothrow {
        return name;
    }

    void setName(string name) @trusted nothrow {
        this.name = name;
    }

    Set!(Permission) getPermissions() {
        return permissions;
    }

     void setPermissions(Set!(Permission) permissions) {
        this.permissions = permissions;
    }

     void add(Permission permission) {
        Set!(Permission) permissions = getPermissions();
        if (permissions  is null) {
            permissions = new LinkedHashSet!(Permission)();
            setPermissions(permissions);
        }
        permissions.add(permission);
    }

     void addAll(Collection!(Permission) perms) {
        if (perms !is null && !perms.isEmpty()) {
            Set!(Permission) permissions = getPermissions();
            if (permissions  is null) {
                permissions = new LinkedHashSet!(Permission)(perms.size());
                setPermissions(permissions);
            }
            permissions.addAll(perms);
        }
    }

     bool isPermitted(Permission p) {
        Collection!(Permission) perms = getPermissions();
        if (perms !is null && !perms.isEmpty()) {
            foreach(Permission perm ; perms) {
                if (perm.implies(p)) {
                    return true;
                }
            }
        }
        return false;
    }

    override size_t toHash() @trusted nothrow {
        return (getName() !is null ? getName().hashOf() : 0);
    }

    override bool opEquals(Object o) {
        if (o == this) {
            return true;
        }
        auto oCast = cast(SimpleRole)o;
        if (oCast !is null) {
            SimpleRole sr = oCast;
            //only check name, since role names should be unique across an entire application:
            return (getName() !is null ? getName()== sr.getName() : sr.getName()  is null);
        }
        return false;
    }

    override string toString() {
        return getName();
    }
}
