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
module test.shiro.mgt.SingletonDefaultSecurityManagerTest;

import hunt.shiro.SecurityUtils;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.UsernamePasswordToken;
import hunt.shiro.config.Ini;
import hunt.shiro.mgt.DefaultSecurityManager;
import hunt.shiro.realm.text.IniRealm;
import hunt.shiro.subject.Subject;
import hunt.shiro.util.ThreadContext;

import hunt.Assert;
import hunt.logging.Logger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.String;

/**
 * @since May 8, 2008 12:26:23 AM
 */
class SingletonDefaultSecurityManagerTest {

    @Before
    void setUp() {
        ThreadContext.remove();
    }

    @After
    void tearDown() {
        ThreadContext.remove();
    }

    @Test
    void testVMSingleton() {
        DefaultSecurityManager sm = new DefaultSecurityManager();
        Ini ini = new Ini();
        IniSection section = ini.addSection(IniRealm.USERS_SECTION_NAME);
        section.put("guest", "guest");
        sm.setRealm(new IniRealm(ini));
        SecurityUtils.setSecurityManager(sm);

        try {
            Subject subject = SecurityUtils.getSubject();

            AuthenticationToken token = new UsernamePasswordToken("guest", "guest");
            subject.login(token);
            subject.getSession().setAttribute("key", "value");
            String a = cast(String)subject.getSession().getAttribute("key");
            assertTrue(a.value == "value");

            subject = SecurityUtils.getSubject();

            assertTrue(subject.isAuthenticated());
            a = cast(String)subject.getSession().getAttribute("key");
            assertTrue(a.value == "value");
        } finally {
            sm.destroy();
            //SHIRO-270:
            SecurityUtils.setSecurityManager(null);
        }
    }
}
