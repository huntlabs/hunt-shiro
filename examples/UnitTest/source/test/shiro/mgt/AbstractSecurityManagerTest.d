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
module test.shiro.mgt.AbstractSecurityManagerTest;


import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.subject.Subject;
import hunt.shiro.subject.support.SubjectThreadState;
import hunt.shiro.util.ThreadContext;
import hunt.shiro.util.ThreadState;

import hunt.Assert;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

/**
 * @since 1.0
 */
abstract class AbstractSecurityManagerTest {

    protected ThreadState threadState;

    @After
    void tearDown() {
        ThreadContext.remove();
    }

    protected Subject newSubject(SecurityManager securityManager) {
        Subject subject = new SubjectBuilder(securityManager).buildSubject();
        threadState = new SubjectThreadState(subject);
        threadState.bind();
        return subject;
    }
}
