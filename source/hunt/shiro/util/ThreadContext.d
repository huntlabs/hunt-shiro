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
module hunt.shiro.util.ThreadContext;

import hunt.shiro.util.CollectionUtils;

import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.subject.Subject;
import hunt.logging.Logger;

import hunt.collection.Collections;
import hunt.collection.HashMap;
import hunt.collection.Map;
import hunt.Exceptions;

import core.thread;
import std.traits;

/**
 * A ThreadContext provides a means of binding and unbinding objects to the
 * current thread based on key/value pairs.
 * <p/>
 * <p>An internal {@link java.util.HashMap} is used to maintain the key/value pairs
 * for each thread.</p>
 * <p/>
 * <p>If the desired behavior is to ensure that bound data is not shared across
 * threads in a pooled or reusable threaded environment, the application (or more likely a framework) must
 * bind and remove any necessary values at the beginning and end of stack
 * execution, respectively (i.e. individually explicitly or all via the <tt>clear</tt> method).</p>
 *
 * @see #remove()
 */
abstract class ThreadContext {

    /**
     * Private internal log instance.
     */


     enum string SECURITY_MANAGER_KEY = fullyQualifiedName!(ThreadContext) ~ "_SECURITY_MANAGER_KEY";
     enum string SUBJECT_KEY = fullyQualifiedName!(ThreadContext) ~ "_SUBJECT_KEY";

    private static Map!(string, Object) resources;


    /**
     * Default no-argument constructor.
     */
    protected this() {
    }

    /**
     * Returns the ThreadLocal Map. This Map is used internally to bind objects
     * to the current thread by storing each object under a unique key.
     *
     * @return the map of bound resources
     */
     static Map!(string, Object) getResources() {
        if (resources is null){
            return Collections.emptyMap!(string, Object)();
        } else {
            return new HashMap!(string, Object)(resources);
        }
    }

    /**
     * Allows a caller to explicitly set the entire resource map.  This operation overwrites everything that existed
     * previously in the ThreadContext - if you need to retain what was on the thread prior to calling this method,
     * call the {@link #getResources()} method, which will give you the existing state.
     *
     * @param newResources the resources to replace the existing {@link #getResources() resources}.
     */
     static void setResources(Map!(string, Object) newResources) {
        if (CollectionUtils.isEmpty!(string, Object)(newResources)) {
            return;
        }
        ensureResourcesInitialized();
        resources.clear();
        resources.putAll(newResources);
    }

    /**
     * Returns the value bound in the {@code ThreadContext} under the specified {@code key}, or {@code null} if there
     * is no value for that {@code key}.
     *
     * @param key the map key to use to lookup the value
     * @return the value bound in the {@code ThreadContext} under the specified {@code key}, or {@code null} if there
     *         is no value for that {@code key}.
     */
    private static Object getValue(string key) {
        Map!(string, Object) perThreadResources = resources;
        return perThreadResources !is null ? perThreadResources.get(key) : null;
    }

    private static void ensureResourcesInitialized(){
        if (resources  is null){
           resources = new HashMap!(string, Object)();
        }
    }

    /**
     * Returns the object for the specified <code>key</code> that is bound to
     * the current thread.
     *
     * @param key the key that identifies the value to return
     * @return the object keyed by <code>key</code> or <code>null</code> if
     *         no value exists for the specified <code>key</code>
     */
     static Object get(string key) {
        version(HUNT_SHIRO_DEBUG) {
            string msg = "get(%s) - in thread [" ~ Thread.getThis().name() ~ "]"; 
            tracef(msg, key);
        }

        Object value = getValue(key);
        version(HUNT_SHIRO_DEBUG) {
            if (value !is null) {
                msg = "Retrieved value of type [" ~ typeid(value).name ~ "] for key [" ~
                        key ~ "] " ~ "bound to thread [" ~ Thread.getThis().name() ~ "]";
                tracef(msg);
            }
        }
        return value;
    }

    /**
     * Binds <tt>value</tt> for the given <code>key</code> to the current thread.
     * <p/>
     * <p>A <tt>null</tt> <tt>value</tt> has the same effect as if <tt>remove</tt> was called for the given
     * <tt>key</tt>, i.e.:
     * <p/>
     * <pre>
     * if ( value  is null ) {
     *     remove( key );
     * }</pre>
     *
     * @param key   The key with which to identify the <code>value</code>.
     * @param value The value to bind to the thread.
     * @throws IllegalArgumentException if the <code>key</code> argument is <tt>null</tt>.
     */
     static void put(string key, Object value) {
        if (key  is null) {
            throw new IllegalArgumentException("key cannot be null");
        }

        if (value  is null) {
            remove(key);
            return;
        }

        ensureResourcesInitialized();
        resources.put(key, value);

        version(HUNT_SHIRO_DEBUG) {
            string msg = "Bound value of type [" ~ typeid(value).name ~ "] for key [" ~
                    key ~ "] to thread " ~ "[" ~ Thread.getThis().name() ~ "]";
            tracef(msg);
        }
    }

    /**
     * Unbinds the value for the given <code>key</code> from the current
     * thread.
     *
     * @param key The key identifying the value bound to the current thread.
     * @return the object unbound or <tt>null</tt> if there was nothing bound
     *         under the specified <tt>key</tt> name.
     */
     static Object remove(string key) {
        Map!(string, Object) perThreadResources = resources;
        Object value = perThreadResources !is null ? perThreadResources.remove(key) : null;

        version(HUNT_SHIRO_DEBUG) {
            if (value !is null) {
                string msg = "Removed value of type [" ~ typeid(cast(Object)value).name ~ "] for key [" ~
                        key ~ "]" ~ "from thread [" ~ Thread.getThis().name() ~ "]";
                tracef(msg);
            }
        }

        return value;
    }

    /**
     * {@link ThreadLocal#remove Remove}s the underlying {@link ThreadLocal ThreadLocal} from the thread.
     * <p/>
     * This method is meant to be the final 'clean up' operation that is called at the end of thread execution to
     * prevent thread corruption in pooled thread environments.
     *
     */
    static void remove() {
        resources = null;
    }

    /**
     * Convenience method that simplifies retrieval of the application's SecurityManager instance from the current
     * thread. If there is no SecurityManager bound to the thread (probably because framework code did not bind it
     * to the thread), this method returns <tt>null</tt>.
     * <p/>
     * It is merely a convenient wrapper for the following:
     * <p/>
     * <code>return (SecurityManager)get( SECURITY_MANAGER_KEY );</code>
     * <p/>
     * This method only returns the bound value if it exists - it does not remove it
     * from the thread.  To remove it, one must call {@link #unbindSecurityManager() unbindSecurityManager()} instead.
     *
     * @return the Subject object bound to the thread, or <tt>null</tt> if there isn't one bound.
     */
     static SecurityManager getSecurityManager() {
        return cast(SecurityManager) get(SECURITY_MANAGER_KEY);
    }


    /**
     * Convenience method that simplifies binding the application's SecurityManager instance to the ThreadContext.
     * <p/>
     * <p>The method's existence is to help reduce casting in code and to simplify remembering of
     * ThreadContext key names.  The implementation is simple in that, if the SecurityManager is not <tt>null</tt>,
     * it binds it to the thread, i.e.:
     * <p/>
     * <pre>
     * if (securityManager !is null) {
     *     put( SECURITY_MANAGER_KEY, securityManager);
     * }</pre>
     *
     * @param securityManager the application's SecurityManager instance to bind to the thread.  If the argument is
     *                        null, nothing will be done.
     */
    static void bind(SecurityManager securityManager) {
        if (securityManager !is null) {
            put(SECURITY_MANAGER_KEY, cast(Object)securityManager);
        }
    }

    /**
     * Convenience method that simplifies removal of the application's SecurityManager instance from the thread.
     * <p/>
     * The implementation just helps reduce casting and remembering of the ThreadContext key name, i.e it is
     * merely a convenient wrapper for the following:
     * <p/>
     * <code>return (SecurityManager)remove( SECURITY_MANAGER_KEY );</code>
     * <p/>
     * If you wish to just retrieve the object from the thread without removing it (so it can be retrieved later
     * during thread execution), use the {@link #getSecurityManager() getSecurityManager()} method instead.
     *
     * @return the application's SecurityManager instance previously bound to the thread, or <tt>null</tt> if there
     *         was none bound.
     */
     static SecurityManager unbindSecurityManager() {
        return cast(SecurityManager) remove(SECURITY_MANAGER_KEY);
    }

    /**
     * Convenience method that simplifies retrieval of a thread-bound Subject.  If there is no
     * Subject bound to the thread, this method returns <tt>null</tt>.  It is merely a convenient wrapper
     * for the following:
     * <p/>
     * <code>return (Subject)get( SUBJECT_KEY );</code>
     * <p/>
     * This method only returns the bound value if it exists - it does not remove it
     * from the thread.  To remove it, one must call {@link #unbindSubject() unbindSubject()} instead.
     *
     * @return the Subject object bound to the thread, or <tt>null</tt> if there isn't one bound.
     */
    static Subject getSubject() {
        return cast(Subject) get(SUBJECT_KEY);
    }

    static Subject getSubject(string name) {
        return cast(Subject) get(name ~ SUBJECT_KEY);
    }


    /**
     * Convenience method that simplifies binding a Subject to the ThreadContext.
     * <p/>
     * <p>The method's existence is to help reduce casting in your own code and to simplify remembering of
     * ThreadContext key names.  The implementation is simple in that, if the Subject is not <tt>null</tt>,
     * it binds it to the thread, i.e.:
     * <p/>
     * <pre>
     * if (subject !is null) {
     *     put( SUBJECT_KEY, subject );
     * }</pre>
     *
     * @param subject the Subject object to bind to the thread.  If the argument is null, nothing will be done.
     */
    static void bind(Subject subject) {
        if (subject !is null) {
            put(SUBJECT_KEY, cast(Object)subject);
        }
    }

    static void bind(string name, Subject subject) {
        if (subject !is null) {
            put(name ~ SUBJECT_KEY, cast(Object)subject);
        }
    }

    /**
     * Convenience method that simplifies removal of a thread-local Subject from the thread.
     * <p/>
     * The implementation just helps reduce casting and remembering of the ThreadContext key name, i.e it is
     * merely a convenient wrapper for the following:
     * <p/>
     * <code>return (Subject)remove( SUBJECT_KEY );</code>
     * <p/>
     * If you wish to just retrieve the object from the thread without removing it (so it can be retrieved later during
     * thread execution), you should use the {@link #getSubject() getSubject()} method for that purpose.
     *
     * @return the Subject object previously bound to the thread, or <tt>null</tt> if there was none bound.
     */
     static Subject unbindSubject() {
        return cast(Subject) remove(SUBJECT_KEY);
    }
    
}

