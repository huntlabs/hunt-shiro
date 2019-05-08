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
module hunt.shiro.env.DefaultEnvironment;

import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.util.Destroyable;
import hunt.shiro.util.LifecycleUtils;

import hunt.collection;

/**
 * Simple/default {@code Environment} implementation that stores Shiro objects as key-value pairs in a
 * {@link java.util.Map Map} instance.  The key is the object name, the value is the object itself.
 *
 */
class DefaultEnvironment : NamedObjectEnvironment, Destroyable {

    /**
     * The default name under which the application's {@code SecurityManager} instance may be acquired, equal to
     * {@code securityManager}.
     */
     enum string DEFAULT_SECURITY_MANAGER_KEY = "securityManager";

    protected final Map!(string, Object) objects;
    private string securityManagerName;

    /**
     * Creates a new instance with a thread-safe {@link ConcurrentHashMap} backing map.
     */
     this() {
        this(new ConcurrentHashMap!(string, Object)());
    }

    /**
     * Creates a new instance with the specified backing map.
     *
     * @param seed backing map to use to maintain Shiro objects.
     */
    //@SuppressWarnings({"unchecked"})
     this(Map!(string, T) seed) {
        this.securityManagerName = DEFAULT_SECURITY_MANAGER_KEY;
        if (seed  is null) {
            throw new IllegalArgumentException("Backing map cannot be null.");
        }
        this.objects = cast(Map!(string, Object)) seed;
    }

    /**
     * Returns the application's {@code SecurityManager} instance accessible in the backing map using the
     * {@link #getSecurityManagerName() securityManagerName} property as the lookup key.
     * <p/>
     * This implementation guarantees that a non-null instance is always returned, as this is expected for
     * Environment API end-users.  If subclasses have the need to perform the map lookup without this guarantee
     * (for example, during initialization when the instance may not have been added to the map yet), the
     * {@link #lookupSecurityManager()} method is provided as an alternative.
     *
     * @return the application's {@code SecurityManager} instance accessible in the backing map using the
     *         {@link #getSecurityManagerName() securityManagerName} property as the lookup key.
     */
     SecurityManager getSecurityManager(){
        SecurityManager securityManager = lookupSecurityManager();
        if (securityManager  is null) {
            throw new IllegalStateException("No SecurityManager found in Environment.  This is an invalid " ~
                    "environment state.");
        }
        return securityManager;
    }

     void setSecurityManager(SecurityManager securityManager) {
        if (securityManager  is null) {
            throw new IllegalArgumentException("Null SecurityManager instances are not allowed.");
        }
        string name = getSecurityManagerName();
        setObject(name, securityManager);
    }

    /**
     * Looks up the {@code SecurityManager} instance in the backing map without performing any non-null guarantees.
     *
     * @return the {@code SecurityManager} in the backing map, or {@code null} if it has not yet been populated.
     */
    protected SecurityManager lookupSecurityManager() {
        string name = getSecurityManagerName();
        return getObject(name, typeid(SecurityManager));
    }

    /**
     * Returns the name of the {@link SecurityManager} instance in the backing map.  Used as a key to lookup the
     * instance.  Unless set otherwise, the default is {@code securityManager}.
     *
     * @return the name of the {@link SecurityManager} instance in the backing map.  Used as a key to lookup the
     *         instance.
     */
     string getSecurityManagerName() {
        return securityManagerName;
    }

    /**
     * Sets the name of the {@link SecurityManager} instance in the backing map.  Used as a key to lookup the
     * instance.  Unless set otherwise, the default is {@code securityManager}.
     *
     * @param securityManagerName the name of the {@link SecurityManager} instance in the backing map.  Used as a key
     *                            to lookup the instance. 
     */
     void setSecurityManagerName(string securityManagerName) {
        this.securityManagerName = securityManagerName;
    }

    /**
     * Returns the live (modifiable) internal objects collection.
     *
     * @return the live (modifiable) internal objects collection.
     */
     Map!(string,Object) getObjects() {
        return this.objects;
    }

    //@SuppressWarnings({"unchecked"})
     T getObject(string name, Class!(T) requiredType){
        if (name  is null) {
            throw new NullPointerException("name parameter cannot be null.");
        }
        if (requiredType  is null) {
            throw new NullPointerException("requiredType parameter cannot be null.");
        }
        Object o = this.objects.get(name);
        if (o  is null) {
            return null;
        }
        if (!requiredType.isInstance(o)) {
            string msg = "Object named '" ~ name ~ "' is not of required type [" ~ requiredType.getName() ~ "].";
            throw new RequiredTypeException(msg);
        }
        return cast(T)o;
    }

     void setObject(string name, Object instance) {
        if (name  is null) {
            throw new NullPointerException("name parameter cannot be null.");
        }
        if (instance  is null) {
            this.objects.remove(name);
        } else {
            this.objects.put(name, instance);
        }
    }


     void destroy(){
        LifecycleUtils.destroy(this.objects.values());
    }
}
