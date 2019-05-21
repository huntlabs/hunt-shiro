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

import hunt.shiro.subject.PrincipalMap;
import hunt.shiro.util.CollectionUtils;

import hunt.collection;
import hunt.Exceptions;
import hunt.Object;

import std.array;
import std.range;

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

    this() {
        this(null);
    }

    this(Map!(string, Map!(string, Object)) backingMap) {
        if (!CollectionUtils.isEmpty(backingMap)) {
            this.realmPrincipals = backingMap;
            foreach (Map!(string, Object) principals; this.realmPrincipals.byValue()) {
                if (!CollectionUtils.isEmpty(principals) ) {
                    ensureCombinedPrincipals().putAll(principals);
                }
            }
        }
    }

    int size() {
        return CollectionUtils.size!(string, Object)(this.combinedPrincipals);
    }

    protected Map!(string, Object) ensureCombinedPrincipals() {
        if (this.combinedPrincipals  is null) {
            this.combinedPrincipals = new HashMap!(string, Object)();
        }
        return this.combinedPrincipals;
    }

    bool containsKey(string o) {
        return this.combinedPrincipals !is null && this.combinedPrincipals.containsKey(o);
    }

    bool containsValue(Object o) {
        return this.combinedPrincipals !is null && this.combinedPrincipals.containsValue(o);
    }

    Object get(string o) {
        implementationMissing(false);
        return null;
        // return this.combinedPrincipals !is null && this.combinedPrincipals.containsKey(o);
    }

    Object put(string s, Object o) {
        return ensureCombinedPrincipals().put(s, o);
    }

    Object remove(string o) {
        return this.combinedPrincipals !is null ? this.combinedPrincipals.remove(o) : null;
    }

    void putAll(Map!(string, Object) map) {
        if (!CollectionUtils.isEmpty(map)) {
            ensureCombinedPrincipals().putAll(map);
        }
    }

    // Set!(string) keySet() {
    //     return CollectionUtils.isEmpty(this.combinedPrincipals) ?
    //             Collections.emptySet!string() :
    //             Collections.unmodifiableSet(this.combinedPrincipals.keySet());
    // }

    // Collection!(Object) values() {
    //     return CollectionUtils.isEmpty(this.combinedPrincipals) ?
    //             Collections.emptySet() :
    //             Collections.unmodifiableCollection(this.combinedPrincipals.values());
    // }

    //  Set!(Entry!(string, Object)) entrySet() {
    //     return CollectionUtils.isEmpty(this.combinedPrincipals) ?
    //             Collections.<Entry!(string,Object)>emptySet() :
    //             Collections.unmodifiableSet(this.combinedPrincipals.entrySet());
    // }

    void clear() {
        this.realmPrincipals = null;
        this.combinedPrincipals = null;
    }

    Object getPrimaryPrincipal() {
        //heuristic - just use the first one we come across:
        if(CollectionUtils.isEmpty(this.combinedPrincipals))
            return null;
        else {
            return this.combinedPrincipals.values()[0];
        }
    }

    T oneByType(T)() if(is(T == class) || is(T == interface)) {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return null;
        }
        foreach(Object value; this.combinedPrincipals.values()) {
            T v = cast(T)value;
            if (value !is null && v !is null) {
                return v;
            }
        }
        return null;
    }

    Collection!(T) byType(T)() {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptySet!T();
        }
        Collection!(T) instances = new ArrayList!(T)();
        foreach(Object value; this.combinedPrincipals.values()) {
            T v = cast(T)value;
            if (value !is null && v !is null) {
                instances.add(v);
            }
        }
        return instances;
    }

    List!(Object) asList() {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptyList!Object();
        }
        List!(Object) list = new ArrayList!(Object)(this.combinedPrincipals.size());
        list.addAll(this.combinedPrincipals.values());
        return list;
    }

    Set!(Object) asSet() {
        if (CollectionUtils.isEmpty(this.combinedPrincipals)) {
            return Collections.emptySet!Object();
        }
        Set!(Object) set = new HashSet!(Object)(this.combinedPrincipals.size());
        set.addAll(this.combinedPrincipals.values());
        return set;
    }

    Object[] fromRealm(string realmName) {
        if (CollectionUtils.isEmpty(this.realmPrincipals)) {
            return null;
        }
        Map!(string,Object) principals = this.realmPrincipals.get(realmName);
        if (CollectionUtils.isEmpty(principals)) {
            return null;
        }
        return principals.values();
    }

    string[] getRealmNames() {
        if (CollectionUtils.isEmpty(this.realmPrincipals)) {
            return null;
        }
        return this.realmPrincipals.byKey.array();
    }

     bool isEmpty() {
        return CollectionUtils.isEmpty(this.combinedPrincipals);
    }

    //  Iterator iterator() {
    //     return asList().iterator();
    // }

     Map!(string, Object) getRealmPrincipals(string name) {
        if (this.realmPrincipals  is null) {
            return null;
        }
        Map!(string,Object) principals = this.realmPrincipals.get(name);
        if (principals  is null) {
            return null;
        }
        return principals;
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

    bool remove(string key, Object value) {
        Object curValue = get(key);
        if (curValue != value || !containsKey(key))
            return false;
        remove(key);
        return true;
    }

    // void putAll(Map!(string, Object) map) {
    //     realmPrincipals.putAll(map);
    // }

    // void clear() {
    //     realmPrincipals.clear();
    // }

    bool replace(string key, Object oldValue, Object newValue) {
        Object curValue = get(key);
        if (curValue != oldValue || !containsKey(key)) {
            return false;
        }
        put(key, newValue);
        return true;
    }

    Object replace(string key, Object value) {
        Object curValue = Object.init;
        if (containsKey(key)) {
            curValue = put(key, value);
        }
        return curValue;
    }

    override string toString() {
        if (isEmpty())
            return "{}";

        Appender!string sb;
        sb.put("{");
        bool isFirst = true;
        foreach (string key, Object value; this) {
            if (!isFirst) {
                sb.put(", ");
            }
            sb.put(key ~ "=" ~ value.toString());
            isFirst = false;
        }
        sb.put("}");

        return sb.data;
    }

    Object putIfAbsent(string key, Object value) {
        Object v = Object.init;

        if (!containsKey(key))
            v = put(key, value);

        return v;
    }

    Object[] values() {
        return byValue().array();
    }

    Object opIndex(string key) {
        return get(key);
    }

    
    int opApply(scope int delegate(ref Object) dg) {
        throw new NotImplementedException();
    }

    int opApply(scope int delegate(ref string, ref Object) dg) {
        throw new NotImplementedException();
    }

    int opApply(scope int delegate(MapEntry!(string, Object) entry) dg) {
        throw new NotImplementedException();
    }

    InputRange!string byKey() {
        throw new NotImplementedException();
    }

    InputRange!Object byValue() {
        throw new NotImplementedException();
    }

    override bool opEquals(Object o) {
        throw new UnsupportedOperationException();
    }

    bool opEquals(IObject o) {
        return opEquals(cast(Object) o);
    }

    override size_t toHash() @trusted nothrow {
        size_t h = 0;
        try {
            foreach (MapEntry!(string, Object) i; this) {
                h += i.toHash();
            }
        } catch (Exception ex) {
        }
        return h;
    } 
}
