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
module hunt.shiro.authc.pam.AbstractAuthenticationStrategy;

import hunt.shiro.authc.pam.AuthenticationStrategy;

// import hunt.shiro.authc;
import hunt.shiro.realm.Realm;

import hunt.collection;


/**
 * Abstract base implementation for Shiro's concrete <code>AuthenticationStrategy</code>
 * implementations.
 *
 */
abstract class AbstractAuthenticationStrategy : AuthenticationStrategy {

    /**
     * Simply returns <code>new {@link hunt.shiro.authc.SimpleAuthenticationInfo SimpleAuthenticationInfo}();</code>, which supports
     * aggregating account data across realms.
     */
     AuthenticationInfo beforeAllAttempts(Collection!Realm realms, AuthenticationToken token){
        return new SimpleAuthenticationInfo();
    }

    /**
     * Simply returns the <code>aggregate</code> method argument, without modification.
     */
     AuthenticationInfo beforeAttempt(Realm realm, AuthenticationToken token, AuthenticationInfo aggregate){
        return aggregate;
    }

    /**
     * Base implementation that will aggregate the specified <code>singleRealmInfo</code> into the
     * <code>aggregateInfo</code> and then returns the aggregate.  Can be overridden by subclasses for custom behavior.
     */
     AuthenticationInfo afterAttempt(Realm realm, AuthenticationToken token, AuthenticationInfo singleRealmInfo, AuthenticationInfo aggregateInfo, Throwable t){
        AuthenticationInfo info;
        if (singleRealmInfo  is null) {
            info = aggregateInfo;
        } else {
            if (aggregateInfo  is null) {
                info = singleRealmInfo;
            } else {
                info = merge(singleRealmInfo, aggregateInfo);
            }
        }

        return info;
    }

    /**
     * Merges the specified <code>info</code> argument into the <code>aggregate</code> argument and then returns an
     * aggregate for continued use throughout the login process.
     * <p/>
     * This implementation merely checks to see if the specified <code>aggregate</code> argument is an instance of
     * {@link hunt.shiro.authc.MergableAuthenticationInfo MergableAuthenticationInfo}, and if so, calls
     * <code>aggregate.merge(info)</code>  If it is <em>not</em> an instance of
     * <code>MergableAuthenticationInfo</code>, an {@link IllegalArgumentException IllegalArgumentException} is thrown.
     * Can be overridden by subclasses for custom merging behavior if implementing the
     * {@link hunt.shiro.authc.MergableAuthenticationInfo MergableAuthenticationInfo} is not desired for some reason.
     */
    protected AuthenticationInfo merge(AuthenticationInfo info, AuthenticationInfo aggregate) {
        auto aggregateCast = cast(MergableAuthenticationInfo)aggregate;
        if( aggregateCast !is null ) {
            aggregateCast.merge(info);
            return aggregate;
        } else {
            throw new IllegalArgumentException( "Attempt to merge authentication info from multiple realms, but aggregate " ~
                      "AuthenticationInfo is not of type MergableAuthenticationInfo." );
        }
    }

    /**
     * Simply returns the <code>aggregate</code> argument without modification.  Can be overridden for custom behavior.
     */
     AuthenticationInfo afterAllAttempts(AuthenticationToken token, AuthenticationInfo aggregate){
        return aggregate;
    }
}
