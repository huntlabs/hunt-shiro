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
module hunt.shiro.crypto.hash.format.Base64Format;

import hunt.shiro.crypto.hash.format.HashFormat;

import hunt.shiro.crypto.hash.Hash;

/**
 * {@code HashFormat} that outputs <em>only</em> the hash's digest bytes in Base64 format.  It does not print out
 * anything else (salt, iterations, etc).  This implementation is mostly provided as a convenience for
 * command-line hashing.
 *
 */
class Base64Format : HashFormat {

    /**
     * Returns {@code hash !is null ? hash.toBase64() : null}.
     *
     * @param hash the hash instance to format into a string.
     * @return {@code hash !is null ? hash.toBase64() : null}.
     */
    string format(Hash hash) {
        return hash !is null ? hash.toBase64() : null;
    }
}
