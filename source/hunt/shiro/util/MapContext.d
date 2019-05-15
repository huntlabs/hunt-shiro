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
module hunt.shiro.util.MapContext;

import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.Common;

import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.Object;
import hunt.util.Common;
import hunt.util.ObjectUtils;

import std.array;
import std.range;


/**
 * A {@code MapContext} provides a common base for context-based data storage in a {@link Map}.  Type-safe attribute
 * retrieval is provided for subclasses with the {@link #getTypedValue(string, Class)} method.
 *
 * @see hunt.shiro.subject.SubjectContext SubjectContext
 * @see hunt.shiro.session.mgt.SessionContext SessionContext
 */
class MapContext : Map!(string, Object) {

    private Map!(string, Object) backingMap;

    this() {
        this.backingMap = new HashMap!(string, Object)();
    }

    this(Map!(string, Object) map) {
        this();
        if (!CollectionUtils.isEmpty(map)) {
            this.backingMap.putAll(map);
        }
    }

    /**
     * Performs a {@link #get get} operation but additionally ensures that the value returned is of the specified
     * {@code type}.  If there is no value, {@code null} is returned.
     *
     * @param key  the attribute key to look up a value
     * @param type the expected type of the value
     * @param <E>  the expected type of the value
     * @return the typed value or {@code null} if the attribute does not exist.
     */
    //@SuppressWarnings({"unchecked"})
    protected E getTypedValue(E)(string key) {
        E found = null;
        Object o = backingMap.get(key);
        if (o !is null) {
            found = cast(E) o;
            if (found is null) {
                string msg = "Invalid object found in SubjectContext Map under key [" ~ key ~ "].  Expected type " ~
                        "was [" ~ typeid(E).toString() ~ "], but the object under that key is of type " ~
                        "[" ~ typeid(o).name ~ "].";
                throw new IllegalArgumentException(msg);
            }
        }
        return found;
    }

    /**
     * Places a value in this context map under the given key only if the given {@code value} argument is not null.
     *
     * @param key   the attribute key under which the non-null value will be stored
     * @param value the non-null value to store.  If {@code null}, this method does nothing and returns immediately.
     */
    protected void nullSafePut(string key, Object value) {
        if (value !is null) {
            put(key, value);
        }
    }

    int size() {
        return backingMap.size();
    }

    bool isEmpty() {
        return backingMap.isEmpty();
    }

    bool containsKey(string o) {
        return backingMap.containsKey(o);
    }

     bool containsValue(Object o) {
        return backingMap.containsValue(o);
    }

    Object get(string o) {
        return backingMap.get(o);
    }

    Object put(string s, Object o) {
        return backingMap.put(s, o);
    }

    Object remove(string o) {
        return backingMap.remove(o);
    }

    bool remove(string key, Object value) {
        Object curValue = get(key);
        if (curValue != value || !containsKey(key))
            return false;
        remove(key);
        return true;
    }

    void putAll(Map!(string, Object) map) {
        backingMap.putAll(map);
    }

    void clear() {
        backingMap.clear();
    }

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

    int opApply(scope int delegate(ref string, ref Object) dg) {
        int result = 0;

        foreach(string key, Object value; backingMap) {
            result = dg(key, value);
        }

        return result;
    }

    int opApply(scope int delegate(MapEntry!(string, Object) entry) dg) {
        int result = 0;

        foreach(MapEntry!(string, Object) entry; backingMap) {
            result = dg(entry);
        }

        return result;
    }

    InputRange!string byKey() {
        return backingMap.byKey();
    }

    InputRange!Object byValue() {
        return backingMap.byValue();
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
