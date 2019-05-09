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

import hunt.shiro.session.mgt.SessionContext;

import hunt.shiro.util.MapContext;
// import hunt.shiro.util.StringUtils;

import hunt.String;
import hunt.util.Common;
import hunt.collection.Map;

import std.array;
import std.traits;

/**
 * Default implementation of the {@link SessionContext} interface which provides getters and setters that
 * wrap interaction with the underlying backing context map.
 *
 */
class DefaultSessionContext : MapContext, SessionContext {


    private enum string HOST = fullyQualifiedName!(DefaultSessionContext) ~ ".HOST";
    private enum string SESSION_ID = fullyQualifiedName!(DefaultSessionContext) ~ ".SESSION_ID";

    this() {
        super();
    }

    this(Map!(string, Object) map) {
        super(map);
    }

    string getHost() {
        String str = getTypedValue!String(HOST);
        return str.value;
    }

     void setHost(string host) {
        if (!host.empty()) {
            put(HOST, new String(host));
        }
    }

    Serializable getSessionId() {
        return getTypedValue!Serializable(SESSION_ID);
    }

     void setSessionId(Serializable sessionId) {
        nullSafePut(SESSION_ID, cast(Object)sessionId);
    }
}
