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
module hunt.shiro.mgt.AuthenticatingSecurityManager;

import hunt.shiro.authc.AuthenticationException;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.Authenticator;
import hunt.shiro.authc.pam.ModularRealmAuthenticator;
import hunt.shiro.util.LifecycleUtils;


/**
 * Shiro support of a {@link SecurityManager} class hierarchy that delegates all
 * authentication operations to a wrapped {@link Authenticator Authenticator} instance.  That is, this class
 * implements all the <tt>Authenticator</tt> methods in the {@link SecurityManager SecurityManager}
 * interface, but in reality, those methods are merely passthrough calls to the underlying 'real'
 * <tt>Authenticator</tt> instance.
 *
 * <p>All other <tt>SecurityManager</tt> (authorization, session, etc) methods are left to be implemented by subclasses.
 *
 * <p>In keeping with the other classes in this hierarchy and Shiro's desire to minimize configuration whenever
 * possible, suitable default instances for all dependencies are created upon instantiation.
 *
 */
abstract class AuthenticatingSecurityManager : RealmSecurityManager {

    /**
     * The internal <code>Authenticator</code> delegate instance that this SecurityManager instance will use
     * to perform all authentication operations.
     */
    private Authenticator authenticator;

    /**
     * Default no-arg constructor that initializes its internal
     * <code>authenticator</code> instance to a
     * {@link hunt.shiro.authc.pam.ModularRealmAuthenticator ModularRealmAuthenticator}.
     */
     this() {
        super();
        this.authenticator = new ModularRealmAuthenticator();
    }

    /**
     * Returns the delegate <code>Authenticator</code> instance that this SecurityManager uses to perform all
     * authentication operations.  Unless overridden by the
     * {@link #setAuthenticator(hunt.shiro.authc.Authenticator) setAuthenticator}, the default instance is a
     * {@link hunt.shiro.authc.pam.ModularRealmAuthenticator ModularRealmAuthenticator}.
     *
     * @return the delegate <code>Authenticator</code> instance that this SecurityManager uses to perform all
     *         authentication operations.
     */
     Authenticator getAuthenticator() {
        return authenticator;
    }

    /**
     * Sets the delegate <code>Authenticator</code> instance that this SecurityManager uses to perform all
     * authentication operations.  Unless overridden by this method, the default instance is a
     * {@link hunt.shiro.authc.pam.ModularRealmAuthenticator ModularRealmAuthenticator}.
     *
     * @param authenticator the delegate <code>Authenticator</code> instance that this SecurityManager will use to
     *                      perform all authentication operations.
     * @throws IllegalArgumentException if the argument is <code>null</code>.
     */
     void setAuthenticator(Authenticator authenticator){
        if (authenticator  is null) {
            string msg = "Authenticator argument cannot be null.";
            throw new IllegalArgumentException(msg);
        }
        this.authenticator = authenticator;
    }

    /**
     * Passes on the {@link #getRealms() realms} to the internal delegate <code>Authenticator</code> instance so
     * that it may use them during authentication attempts.
     */
    protected void afterRealmsSet() {
        super.afterRealmsSet();
        auto authenticatorCast = cast(ModularRealmAuthenticator) this.authenticator;
        if (authenticatorCast !is null) {
            authenticatorCast.setRealms(getRealms());
        }
    }

    /**
     * Delegates to the wrapped {@link hunt.shiro.authc.Authenticator Authenticator} for authentication.
     */
     AuthenticationInfo authenticate(AuthenticationToken token){
        return this.authenticator.authenticate(token);
    }

     void destroy() {
        LifecycleUtils.destroy(getAuthenticator());
        this.authenticator = null;
        super.destroy();
    }
}
