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
module hunt.shiro.session.mgt.DefaultSessionContext;

import hunt.shiro.util.MapContext;
import hunt.shiro.util.StringUtils;

import java.io.Serializable;
import java.util.Map;

/**
 * Default implementation of the {@link SessionContext} interface which provides getters and setters that
 * wrap interaction with the underlying backing context map.
 *
 * @since 1.0
 */
class DefaultSessionContext : MapContext implements SessionContext {


    private enum string HOST = DefaultSessionContext.class.getName() ~ ".HOST";
    private enum string SESSION_ID = DefaultSessionContext.class.getName() ~ ".SESSION_ID";

     DefaultSessionContext() {
        super();
    }

     DefaultSessionContext(Map!(string, Object) map) {
        super(map);
    }

     string getHost() {
        return getTypedValue(HOST, string.class);
    }

     void setHost(string host) {
        if (StringUtils.hasText(host)) {
            put(HOST, host);
        }
    }

     Serializable getSessionId() {
        return getTypedValue(SESSION_ID, Serializable.class);
    }

     void setSessionId(Serializable sessionId) {
        nullSafePut(SESSION_ID, sessionId);
    }
}
