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

import java.io.Serializable;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * A simple representation of a security role that has a name and a collection of permissions.  This object can be
 * used internally by Realms to maintain authorization state.
 *
 * @since 0.2
 */
class SimpleRole : Serializable {

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

     string getName() {
        return name;
    }

     void setName(string name) {
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
        if (perms != null && !perms.isEmpty()) {
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
        if (perms != null && !perms.isEmpty()) {
            foreach(Permission perm ; perms) {
                if (perm.implies(p)) {
                    return true;
                }
            }
        }
        return false;
    }

     size_t toHash() @trusted nothrow {
        return (getName() != null ? getName().hashCode() : 0);
    }

     bool opEquals(Object o) {
        if (o == this) {
            return true;
        }
        auto oCast = cast(SimpleRole)o;
        if (oCast !is null) {
            SimpleRole sr = oCast;
            //only check name, since role names should be unique across an entire application:
            return (getName() != null ? getName()== sr.getName() : sr.getName()  is null);
        }
        return false;
    }

     string toString() {
        return getName();
    }
}
