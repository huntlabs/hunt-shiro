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
module hunt.shiro.cache.MapCache;

import hunt.shiro.cache.Cache;

// import java.util.Collection;
// import java.util.Collections;
// import java.util.Map;
// import java.util.Set;

import hunt.text.StringBuilder;

import std.array;

/**
 * A <code>MapCache</code> is a {@link Cache Cache} implementation that uses a backing {@link Map} instance to store
 * and retrieve cached data.
 *
 * @since 1.0
 */
class MapCache(K, V) : Cache!(K, V) {

    /**
     * Backing instance.
     */
    private V[K] map;

    /**
     * The name of this cache.
     */
    private final string name;

    this(string name, V[K] backingMap) {
        if (name.empty) {
            throw new IllegalArgumentException("Cache name cannot be null.");
        }
        if (backingMap is null) {
            throw new IllegalArgumentException("Backing map cannot be null.");
        }
        this.name = name;
        this.map = backingMap;
    }

    V get(K key) {
        return map[key];
    }

    V put(K key, V value) {
        return map[key] = value;
    }

    V remove(K key) {
        return map.remove(key);
    }

    void clear() {
        map.clear();
    }

    int size() {
        return cast(int)map.length;
    }

    K[] keys() {
        return map.keys;
    }

    V[] values() {
        return map.values;
    }

    override string toString() {
        return new StringBuilder("MapCache '")
                .append(name).append("' (")
                .append(map.length)
                .append(" entries)")
                .toString();
    }
}
