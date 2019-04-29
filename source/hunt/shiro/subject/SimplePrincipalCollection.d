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

import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.StringUtils;
import hunt.shiro.subject.MutablePrincipalCollection;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.*;


/**
 * A simple implementation of the {@link MutablePrincipalCollection} interface that tracks principals internally
 * by storing them in a {@link LinkedHashMap}.
 *
 * @since 0.9
 */
//@SuppressWarnings({"unchecked"})
class SimplePrincipalCollection : MutablePrincipalCollection {

    // Serialization reminder:
    // You _MUST_ change this number if you introduce a change to this class
    // that is NOT serialization backwards compatible.  Serialization-compatible
    // changes do not require a change to this number.  If you need to generate
    // a new number in this case, use the JDK's 'serialver' program to generate it.

    //TODO - complete JavaDoc

    private Map!(string, Set) realmPrincipals;

    private  string cachedToString; //cached toString() result, as this can be printed many times in logging

    this() {
    }

    this(Object principal, string realmName) {
        if (principal instanceof Collection) {
            addAll((Collection) principal, realmName);
        } else {
            add(principal, realmName);
        }
    }

    this(Collection principals, string realmName) {
        addAll(principals, realmName);
    }

    this(PrincipalCollection principals) {
        addAll(principals);
    }

    protected Collection getPrincipalsLazy(string realmName) {
        if (realmPrincipals  is null) {
            realmPrincipals = new LinkedHashMap!(string, Set)();
        }
        Set principals = realmPrincipals.get(realmName);
        if (principals  is null) {
            principals = new LinkedHashSet();
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
        return iterator().next();
    }

     void add(Object principal, string realmName) {
        if (realmName  is null) {
            throw new IllegalArgumentException("realmName argument cannot be null.");
        }
        if (principal  is null) {
            throw new IllegalArgumentException("principal argument cannot be null.");
        }
        this.cachedToString = null;
        getPrincipalsLazy(realmName).add(principal);
    }

     void addAll(Collection principals, string realmName) {
        if (realmName  is null) {
            throw new IllegalArgumentException("realmName argument cannot be null.");
        }
        if (principals  is null) {
            throw new IllegalArgumentException("principals argument cannot be null.");
        }
        if (principals.isEmpty()) {
            throw new IllegalArgumentException("principals argument cannot be an empty collection.");
        }
        this.cachedToString = null;
        getPrincipalsLazy(realmName).addAll(principals);
    }

     void addAll(PrincipalCollection principals) {
        if (principals.getRealmNames() != null) {
            foreach(string realmName ; principals.getRealmNames()) {
                foreach(Object principal ; principals.fromRealm(realmName)) {
                    add(principal, realmName);
                }
            }
        }
    }

     <T> T oneByType(Class!(T) type) {
        if (realmPrincipals  is null || realmPrincipals.isEmpty()) {
            return null;
        }
        Collection!(Set) values = realmPrincipals.values();
        foreach(Set set ; values) {
            foreach(Object o ; set) {
                if (type.isAssignableFrom(o.getClass())) {
                    return (T) o;
                }
            }
        }
        return null;
    }

     <T> Collection!(T) byType(Class!(T) type) {
        if (realmPrincipals  is null || realmPrincipals.isEmpty()) {
            return Collections.EMPTY_SET;
        }
        Set!(T) typed = new LinkedHashSet!(T)();
        Collection!(Set) values = realmPrincipals.values();
        foreach(Set set ; values) {
            foreach(Object o ; set) {
                if (type.isAssignableFrom(o.getClass())) {
                    typed.add((T) o);
                }
            }
        }
        if (typed.isEmpty()) {
            return Collections.EMPTY_SET;
        }
        return Collections.unmodifiableSet(typed);
    }

     List asList() {
        Set all = asSet();
        if (all.isEmpty()) {
            return Collections.EMPTY_LIST;
        }
        return Collections.unmodifiableList(new ArrayList(all));
    }

     Set asSet() {
        if (realmPrincipals  is null || realmPrincipals.isEmpty()) {
            return Collections.EMPTY_SET;
        }
        Set aggregated = new LinkedHashSet();
        Collection!(Set) values = realmPrincipals.values();
        foreach(Set set ; values) {
            aggregated.addAll(set);
        }
        if (aggregated.isEmpty()) {
            return Collections.EMPTY_SET;
        }
        return Collections.unmodifiableSet(aggregated);
    }

     Collection fromRealm(string realmName) {
        if (realmPrincipals  is null || realmPrincipals.isEmpty()) {
            return Collections.EMPTY_SET;
        }
        Set principals = realmPrincipals.get(realmName);
        if (principals  is null || principals.isEmpty()) {
            principals = Collections.EMPTY_SET;
        }
        return Collections.unmodifiableSet(principals);
    }

     Set!(string) getRealmNames() {
        if (realmPrincipals  is null) {
            return null;
        } else {
            return realmPrincipals.keySet();
        }
    }

     bool isEmpty() {
        return realmPrincipals  is null || realmPrincipals.isEmpty();
    }

     void clear() {
        this.cachedToString = null;
        if (realmPrincipals != null) {
            realmPrincipals.clear();
            realmPrincipals = null;
        }
    }

     Iterator iterator() {
        return asSet().iterator();
    }

     bool opEquals(Object o) {
        if (o == this) {
            return true;
        }
        if (o instanceof SimplePrincipalCollection) {
            SimplePrincipalCollection other = (SimplePrincipalCollection) o;
            return this.realmPrincipals != null ? this.realmPrincipals== other.realmPrincipals : other.realmPrincipals  is null;
        }
        return false;
    }

     size_t toHash() @trusted nothrow {
        if (this.realmPrincipals != null && !realmPrincipals.isEmpty()) {
            return realmPrincipals.hashCode();
        }
        return super.hashCode();
    }

    /**
     * Returns a simple string representation suitable for printing.
     *
     * @return a simple string representation suitable for printing.
     * @since 1.0
     */
     string toString() {
        if (this.cachedToString  is null) {
            Set!(Object) principals = asSet();
            if (!CollectionUtils.isEmpty(principals)) {
                this.cachedToString = StringUtils.toString(principals.toArray());
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
    private void writeObject(ObjectOutputStream out){
        out.defaultWriteObject();
        bool principalsExist = !CollectionUtils.isEmpty(realmPrincipals);
        out.writebool(principalsExist);
        if (principalsExist) {
            out.writeObject(realmPrincipals);
        }
    }

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
    private void readObject(ObjectInputStream in){
        in.defaultReadObject();
        bool principalsExist = in.readbool();
        if (principalsExist) {
            this.realmPrincipals = (Map!(string, Set)) in.readObject();
        }
    }
}
