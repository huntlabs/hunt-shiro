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
module hunt.shiro.authc.pam.AtLeastOneSuccessfulStrategy;

import hunt.shiro.authc.pam.AbstractAuthenticationStrategy;

import hunt.shiro.Exceptions;
import hunt.shiro.authc.AuthenticationInfo;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.subject.PrincipalCollection;

/**
 * <tt>AuthenticationStrategy</tt> implementation that requires <em>at least one</em> configured realm to
 * successfully process the submitted <tt>AuthenticationToken</tt> during the log-in attempt.
 * <p/>
 * <p>This means any number of configured realms do not have to support the submitted log-in token, or they may
 * be unable to acquire <tt>AuthenticationInfo</tt> for the token, but as long as at least one can do both, this
 * Strategy implementation will allow the log-in process to be successful.
 * <p/>
 * <p>Note that this implementation will aggregate the account data from <em>all</em> successfully consulted
 * realms during the authentication attempt. If you want only the account data from the first successfully
 * consulted realm and want to ignore all subsequent realms, use the
 * {@link FirstSuccessfulStrategy FirstSuccessfulAuthenticationStrategy} instead.
 *
 * @see FirstSuccessfulStrategy FirstSuccessfulAuthenticationStrategy
 */
class AtLeastOneSuccessfulStrategy : AbstractAuthenticationStrategy {

    private static bool isEmpty(PrincipalCollection pc) {
        return pc  is null || pc.isEmpty();
    }

    /**
     * Ensures that the <code>aggregate</code> method argument is not <code>null</code> and
     * <code>aggregate.{@link hunt.shiro.authc.AuthenticationInfo#getPrincipals() getPrincipals()}</code>
     * is not <code>null</code>, and if either is <code>null</code>,
     * that none of the realms authenticated successfully.
     */
    override AuthenticationInfo afterAllAttempts(AuthenticationToken token, AuthenticationInfo aggregate){
        //we know if one or more were able to successfully authenticate if the aggregated account object does not
        //contain null or empty data:
        if (aggregate  is null || isEmpty(aggregate.getPrincipals())) {
            throw new AuthenticationException("Authentication token of type [" ~ token.getClass() ~ "] " ~
                    "could not be authenticated by any configured realms.  Please ensure that at least one realm can " ~
                    "authenticate these tokens.");
        }

        return aggregate;
    }
}
