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
module hunt.shiro.cache.AbstractCacheManager;

import hunt.shiro.cache.Cache;
import hunt.shiro.cache.CacheManager;

import hunt.shiro.util.Common;
import hunt.shiro.util.LifecycleUtils;
// import hunt.shiro.util.StringUtils;

import hunt.Exceptions;
import hunt.util.StringBuilder;

import std.array;

// import java.util.Collection;
// import java.util.concurrent.ConcurrentHashMap;
// import java.util.concurrent.ConcurrentMap;

/**
 * Very simple abstract {@code CacheManager} implementation that retains all created {@link Cache Cache} instances in
 * an in-memory {@link ConcurrentMap ConcurrentMap}.  {@code Cache} instance creation is left to subclasses via
 * the {@link #createCache createCache} method implementation.
 *
 * @since 1.0
 */
abstract class AbstractCacheManager(K, V) : CacheManager, Destroyable {

    /**
     * Retains all Cache objects maintained by this cache manager.
     */
    private Cache!(K, V)[string] caches;

    /**
     * Default no-arg constructor that instantiates an internal name-to-cache {@code ConcurrentMap}.
     */
    this() {
        // this.caches = new ConcurrentHashMap<string, Cache>();
    }

    /**
     * Returns the cache with the specified {@code name}.  If the cache instance does not yet exist, it will be lazily
     * created, retained for further access, and then returned.
     *
     * @param name the name of the cache to acquire.
     * @return the cache with the specified {@code name}.
     * @throws IllegalArgumentException if the {@code name} argument is {@code null} or does not contain text.
     * @throws CacheException           if there is a problem lazily creating a {@code Cache} instance.
     */
    Cache!(K, V) getCache(string name) {
        if (name.empty()) {
            throw new IllegalArgumentException("Cache name cannot be null or empty.");
        }
        Cache!(K, V) cache = caches.get(name, null);
        if (cache is null) {
            cache = createCache(name);
            caches[name] = cache;
        }

        //noinspection unchecked
        return cache;
    }

    /**
     * Creates a new {@code Cache} instance associated with the specified {@code name}.
     *
     * @param name the name of the cache to create
     * @return a new {@code Cache} instance associated with the specified {@code name}.
     * @throws CacheException if the {@code Cache} instance cannot be created.
     */
    protected abstract Cache!(K, V) createCache(string name);

    /**
     * Cleanup method that first {@link LifecycleUtils#destroy destroys} all of it's managed caches and then
     * {@link java.util.Map#clear clears} out the internally referenced cache map.
     *
     * @throws Exception if any of the managed caches can't destroy properly.
     */
    void destroy() {
        while (caches !is null) {
            foreach (Cache!(K, V) cache; caches.byValue) {
                LifecycleUtils.destroy(cast(Object)cache);
            }
            caches.clear();
        }
    }

    override string toString() {
        
        StringBuilder sb = new StringBuilder(typeof(this).stringof)
                .append(" with ")
                .append(caches.length)
                .append(" cache(s)): [");
        int i = 0;
        foreach (Cache!(K, V) cache ; caches.byValue) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append((cast(Object)cache).toString());
            i++;
        }
        sb.append("]");
        return sb.toString();
    }
}
