/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
module hunt.shiro.subject.SimplePrincipalMap;

import hunt.shiro.util.CollectionUtils;

import java.util.*;

/**
 * Default implementation of the {@link PrincipalMap} interface.
 *
 * *EXPERIMENTAL for Shiro 1.2 - DO NOT USE YET*
 *
 * @author Les Hazlewood
 */
class SimplePrincipalMap : PrincipalMap {

    //Key: realm name, Value: map of principals specific to that realm
    //                        internal map - key: principal name, value: principal
    private Map!(string, Map!(string, Object)) realmPrincipals;

    //maintains the principals from all realms plus any that are modified via the Map modification methods
    //this ensures a fast lookup of any named principal instead of needing to iterate over
    //the realmPrincipals for each lookup.
    private Map!(string, Object) combinedPrincipals;

     SimplePrincipalMap() {
        this(null);
    }

     SimplePrincipalMap(Map!(string, Map!(string, Object)) backingMap) {
        if (!CollectionUtils.isEmpty(backingMap)) {
            this.realmPrincipals = backingMap;
            for (Map!(string, Object) principals : this.realmPrincipals.values()) {
                if (!CollectionUtils.isEmpty(principals) ) {
                    ensureCombinedPrincipals().putAll(principals);
                }
            }
        }
    }

     int size() {
        return CollectionUtils.size(this.combinedPrincipals);
    }

    protected Map!(string, Object) ensureCombinedPrincipals() {
        if (this.combinedPrincipals  is null) {
            this.combinedPrincipals = new HashMap!(string, Object)();
        }
        return this.combinedPrincipals;
    }

     bool containsKey(Object o) {
        return this.combinedPrincipals !is null && this.combinedPrincipals.containsKey(o);
    }

     bool containsValue(Object o) {
        return this.combinedPrincipals !is null && this.combinedPrincipals.containsKey(o);
    }

     Object get(Object o) {
        return this.combinedPrincipals !is null && this.combinedPrincipals.containsKey(o);
    }

     Object put(string s, Object o) {
        return ensureCombinedPrincipals().put(s, o);
    }

     Object remove(Object o) {
        return this.combinedPrincipals !is null ? this.combinedPrincipals.remove(o) : null;
    }

     void putAll(Map<? extends string, ?> map) {
        if (!CollectionUtils.isEmpty(map)) {
            ensureCombinedPrincipals().putAll(map);
        }
    }

     Set!(string) keySet() {
        return CollectionUtils.isEmpty(this.combinedPrincipals) ?
                Collections.<string>emptySet() :
                Collections.unmodifiableSet(this.combinedPrincipals.keySet());
    }

     Collection!(Object) values() {
        return CollectionUtils.isEmpty(this.combinedPrincipals) ?
                Collections.emptySet() :
                Collections.unmodifiableCollection(this.combinedPrincipals.values());
    }

     Set!(Entry!(string, Object)) entrySet() {
        return CollectionUtils.isEmpty(this.combinedPrincipals) ?
                Collections.<Entry!(string,Object)>emptySet() :
                Collections.unmodifiableSet(this.combinedPrincipals.entrySet());
    }

     void clear() {
        this.realmPrincipals = null;
        this.combinedPrincipals = null;
    }

     Object getPrimaryPrincipal() {
        //heuristic - just use the first one we come across:
        return !CollectionUtils.isEmpty(this.combinedPrincipals) ?
                this.combinedPrincipals.values().iterator().next() :
                null;
    }

     <T> T oneByType(Class!(T) type) {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return null;
        }
        foreach( Object value ; this.combinedPrincipals.values()) {
            if (type.isInstance(value) ) {
                return type.cast(value);
            }
        }
        return null;
    }

     <T> Collection!(T) byType(Class!(T) type) {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptySet();
        }
        Collection!(T) instances = null;
        foreach( Object value ; this.combinedPrincipals.values()) {
            if (type.isInstance(value) ) {
                if (instances  is null) {
                    instances = new ArrayList!(T)();
                }
                instances.add(type.cast(value));
            }
        }
        return instances !is null ? instances : Collections.<T>emptyList();
    }

     List asList() {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptyList();
        }
        List!(Object) list = new ArrayList!(Object)(this.combinedPrincipals.size());
        list.addAll(this.combinedPrincipals.values());
        return list;
    }

     Set asSet() {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptySet();
        }
        Set!(Object) set = new HashSet!(Object)(this.combinedPrincipals.size());
        set.addAll(this.combinedPrincipals.values());
        return set;
    }

     Collection fromRealm(string realmName) {
        if (CollectionUtils.isEmpty(this.realmPrincipals)) {
            return Collections.emptySet();
        }
        Map!(string,Object) principals = this.realmPrincipals.get(realmName);
        if (CollectionUtils.isEmpty(principals)) {
            return Collections.emptySet();
        }
        return Collections.unmodifiableCollection(principals.values());
    }

     Set!(string) getRealmNames() {
        if (CollectionUtils.isEmpty(this.realmPrincipals)) {
            return Collections.emptySet();
        }
        return Collections.unmodifiableSet(this.realmPrincipals.keySet());
    }

     bool isEmpty() {
        return CollectionUtils.isEmpty(this.combinedPrincipals);
    }

     Iterator iterator() {
        return asList().iterator();
    }

     Map!(string, Object) getRealmPrincipals(string name) {
        if (this.realmPrincipals  is null) {
            return null;
        }
        Map!(string,Object) principals = this.realmPrincipals.get(name);
        if (principals  is null) {
            return null;
        }
        return Collections.unmodifiableMap(principals);
    }

     Map!(string,Object) setRealmPrincipals(string realmName, Map!(string, Object) principals) {
        if (realmName  is null) {
            throw new NullPointerException("realmName argument cannot be null.");
        }
        if (this.realmPrincipals  is null) {
            if (!CollectionUtils.isEmpty(principals)) {
                this.realmPrincipals = new HashMap!(string,Map!(string,Object))();
                return this.realmPrincipals.put(realmName, new HashMap!(string,Object)(principals));
            } else {
                return null;
            }
        } else {
            Map!(string,Object) existingPrincipals = this.realmPrincipals.remove(realmName);
            if (!CollectionUtils.isEmpty(principals)) {
                this.realmPrincipals.put(realmName, new HashMap!(string,Object)(principals));
            }
            return existingPrincipals;
        }
    }

     Object setRealmPrincipal(string realmName, string principalName, Object principal) {
        if (realmName  is null) {
            throw new NullPointerException("realmName argument cannot be null.");
        }
        if (principalName  is null) {
            throw new NullPointerException(("principalName argument cannot be null."));
        }
        if (principal  is null) {
            return removeRealmPrincipal(realmName, principalName);
        }
        if (this.realmPrincipals  is null) {
            this.realmPrincipals = new HashMap!(string,Map!(string,Object))();
        }
        Map!(string,Object) principals = this.realmPrincipals.get(realmName);
        if (principals  is null) {
            principals = new HashMap!(string,Object)();
            this.realmPrincipals.put(realmName, principals);
        }
        return principals.put(principalName, principal);
    }

     Object getRealmPrincipal(string realmName, string principalName) {
        if (realmName  is null) {
            throw new NullPointerException("realmName argument cannot be null.");
        }
        if (principalName  is null) {
            throw new NullPointerException(("principalName argument cannot be null."));
        }
        if (this.realmPrincipals  is null) {
            return null;
        }
        Map!(string,Object) principals = this.realmPrincipals.get(realmName);
        if (principals !is null) {
            return principals.get(principalName);
        }
        return null;
    }

     Object removeRealmPrincipal(string realmName, string principalName) {
        if (realmName  is null) {
            throw new NullPointerException("realmName argument cannot be null.");
        }
        if (principalName  is null) {
            throw new NullPointerException(("principalName argument cannot be null."));
        }
        if (this.realmPrincipals  is null) {
            return null;
        }
        Map!(string,Object) principals = this.realmPrincipals.get(realmName);
        if (principals !is null) {
            return principals.remove(principalName);
        }
        return null;
    }
}
