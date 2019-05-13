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
module hunt.shiro.subject.SimplePrincipalCollection;

import hunt.shiro.subject.PrincipalCollection;

import hunt.shiro.util.CollectionUtils;
// import hunt.shiro.util.StringUtils;
import hunt.shiro.subject.MutablePrincipalCollection;

import hunt.collection;
import hunt.logging.ConsoleLogger;
import hunt.Exceptions;
import hunt.String;
import hunt.text.StringUtils;

import std.array;
import std.range;
// import java.io.IOException;
// import java.io.ObjectInputStream;
// import java.io.ObjectOutputStream;


/**
 * A simple implementation of the {@link MutablePrincipalCollection} interface that tracks principals internally
 * by storing them in a {@link LinkedHashMap}.
 *
 */
class SimplePrincipalCollection : MutablePrincipalCollection {

    // Serialization reminder:
    // You _MUST_ change this number if you introduce a change to this class
    // that is NOT serialization backwards compatible.  Serialization-compatible
    // changes do not require a change to this number.  If you need to generate
    // a new number in this case, use the JDK's 'serialver' program to generate it.


    private Map!(string, Set!Object) realmPrincipals;

    private string cachedToString; //cached toString() result, as this can be printed many times in logging

    this() {
    }

    this(Object principal, string realmName) {
        Collection!Object c = cast(Collection!Object) principal;
        if (c !is null) {
            addAll(c, realmName);
        } else {
            add(principal, realmName);
        }
    }

    this(Collection!Object principals, string realmName) {
        addAll(principals, realmName);
    }

    this(PrincipalCollection principals) {
        addAll(principals);
    }

    protected Collection!Object getPrincipalsLazy(string realmName) {
        if (realmPrincipals is null) {
            realmPrincipals = new LinkedHashMap!(string, Set!Object)();
        }
        Set!Object principals = realmPrincipals.get(realmName);
        if (principals is null) {
            principals = new LinkedHashSet!Object();
            realmPrincipals.put(realmName, principals);
        }
        return principals;
    }

    /**
     * Returns the first available principal from any of the {@code Realm} principals, or {@code null} if there are
     * no principals yet.
     * <p/>
     * The 'first available principal' is interpreted as the principal that would be returned by
     * <code>{@link #iterator() iterator()}.{@link java.util.Iterator#next() next()}.</code>
     *
     * @inheritDoc
     */
    Object getPrimaryPrincipal() {
        if (isEmpty()) {
            return null;
        }
        return asSet().toArray()[0];
    }
    
    void add(string principal, string realmName) {
        add(new String(principal), realmName);
    }

    void add(Object principal, string realmName) {
        if (realmName is null) {
            throw new IllegalArgumentException("realmName argument cannot be null.");
        }
        if (principal is null) {
            throw new IllegalArgumentException("principal argument cannot be null.");
        }
        this.cachedToString = null;
        getPrincipalsLazy(realmName).add(principal);
    }

     void addAll(Collection!Object principals, string realmName) {
        if (realmName is null) {
            throw new IllegalArgumentException("realmName argument cannot be null.");
        }
        if (principals is null) {
            throw new IllegalArgumentException("principals argument cannot be null.");
        }
        if (principals.isEmpty()) {
            throw new IllegalArgumentException("principals argument cannot be an empty collection.");
        }
        this.cachedToString = null;
        getPrincipalsLazy(realmName).addAll(principals);
    }

     void addAll(PrincipalCollection principals) {
        if (principals.getRealmNames() !is null) {
            foreach(string realmName ; principals.getRealmNames()) {
                foreach(Object principal ; principals.fromRealm(realmName)) {
                    add(principal, realmName);
                }
            }
        }
    }

    // T oneByType(T)(TypeInfo_Class type) {
    //     if (realmPrincipals is null || realmPrincipals.isEmpty()) {
    //         return null;
    //     }
    //     Collection!(Set) values = realmPrincipals.values();
    //     foreach(Set set ; values) {
    //         foreach(Object o ; set) {
    //             if (type.isAssignableFrom(o.getClass())) {
    //                 return cast(T) o;
    //             }
    //         }
    //     }
    //     return null;
    // }

    // Collection!(T) byType(T)(TypeInfo_Class type) {
    //     if (realmPrincipals is null || realmPrincipals.isEmpty()) {
    //         return Collections.EMPTY_SET;
    //     }
    //     Set!(T) typed = new LinkedHashSet!(T)();
    //     Collection!(Set) values = realmPrincipals.values();
    //     foreach(Set set ; values) {
    //         foreach(Object o ; set) {
    //             if (type.isAssignableFrom(o.getClass())) {
    //                 typed.add(cast(T) o);
    //             }
    //         }
    //     }
    //     if (typed.isEmpty()) {
    //         return Collections.EMPTY_SET;
    //     }
    //     return Collections.unmodifiableSet(typed);
    // }

    List!Object asList() {
        Set!Object all = asSet();
        if (all.isEmpty()) {
            return Collections.emptyList!Object();
        }
        return new ArrayList!Object(all);
    }

    Set!Object asSet() {
        if (realmPrincipals is null || realmPrincipals.isEmpty()) {
            return Collections.emptySet!(Object)();
        }

        Set!Object aggregated = new LinkedHashSet!Object();
        foreach(Set!(Object) set ; realmPrincipals.values()) {
            aggregated.addAll(set);
        }
        if (aggregated.isEmpty()) {
            return Collections.emptySet!(Object)();
        }
        return aggregated; 
    }

    Object[] fromRealm(string realmName) {
        if (realmPrincipals is null || realmPrincipals.isEmpty()) {
            return null;
        }
        Set!Object principals = realmPrincipals.get(realmName);
        if (principals is null || principals.isEmpty()) {
            return null;
        } else {
            return principals.toArray();
        }
    }

    string[] getRealmNames() {
        if (realmPrincipals is null) {
            return null;
        } else {
            return realmPrincipals.byKey.array();
        }
    }

     bool isEmpty() {
        return realmPrincipals is null || realmPrincipals.isEmpty();
    }

     void clear() {
        this.cachedToString = null;
        if (realmPrincipals !is null) {
            realmPrincipals.clear();
            realmPrincipals = null;
        }
    }

    //  Iterator iterator() {
    //     return asSet().iterator();
    // }

    override bool opEquals(Object o) {
        if (o == this) {
            return true;
        }
        
        SimplePrincipalCollection other = cast(SimplePrincipalCollection) o;
        if (other !is null) {
            return this.realmPrincipals !is null ? 
                this.realmPrincipals == other.realmPrincipals :
                other.realmPrincipals is null;
        }
        return false;
    }

    override size_t toHash() @trusted nothrow {
        try {
            if (this.realmPrincipals !is null && !realmPrincipals.isEmpty()) {
                return realmPrincipals.toHash();
            }
        } catch(Exception ex) {
            warning(ex.msg);
        }
        return super.toHash();
    }

    /**
     * Returns a simple string representation suitable for printing.
     *
     * @return a simple string representation suitable for printing.
     */
    override string toString() {
        if (this.cachedToString is null) {
            Set!(Object) principals = asSet();
            if (!CollectionUtils.isEmpty(principals)) {
                this.cachedToString = StringUtils.toCommaDelimitedString(principals.toArray());
            } else {
                this.cachedToString = "empty";
            }
        }
        return this.cachedToString;
    }


    /**
     * Serialization write support.
     * <p/>
     * NOTE: Don't forget to change the serialVersionUID constant at the top of this class
     * if you make any backwards-incompatible serialization changes!!!
     * (use the JDK 'serialver' program for this)
     *
     * @param out output stream provided by Java serialization
     * @throws IOException if there is a stream error
     */
    // private void writeObject(ObjectOutputStream out){
    //     out.defaultWriteObject();
    //     bool principalsExist = !CollectionUtils.isEmpty(realmPrincipals);
    //     out.writebool(principalsExist);
    //     if (principalsExist) {
    //         out.writeObject(realmPrincipals);
    //     }
    // }

    /**
     * Serialization read support - reads in the Map principals collection if it exists in the
     * input stream.
     * <p/>
     * NOTE: Don't forget to change the serialVersionUID constant at the top of this class
     * if you make any backwards-incompatible serialization changes!!!
     * (use the JDK 'serialver' program for this)
     *
     * @param in input stream provided by
     * @throws IOException            if there is an input/output problem
     * @throws ClassNotFoundException if the underlying Map implementation class is not available to the classloader.
     */
    // private void readObject(ObjectInputStream in){
    //     in.defaultReadObject();
    //     bool principalsExist = in.readbool();
    //     if (principalsExist) {
    //         this.realmPrincipals = (Map!(string, Set)) in.readObject();
    //     }
    // }


    int opApply(scope int delegate(ref Object) dg) {
        throw new NotImplementedException();
        // return 0;
    }
}
