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
module test.shiro.mgt.DefaultSecurityManagerTest;

import test.shiro.mgt.AbstractSecurityManagerTest;

import hunt.shiro.Exceptions;
import hunt.shiro.SecurityUtils;
import hunt.shiro.authc.AuthenticationToken;
import hunt.shiro.authc.UsernamePasswordToken;
import hunt.shiro.config.Ini;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.mgt.DefaultSecurityManager;
import hunt.shiro.realm.text.IniRealm;
import hunt.shiro.session.Session;
import hunt.shiro.session.mgt.AbstractValidatingSessionManager;
import hunt.shiro.subject.Subject;


import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.Logger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.String;

import core.thread;
import core.time;

/**
 * @since 0.2
 */
class DefaultSecurityManagerTest : AbstractSecurityManagerTest {

    DefaultSecurityManager sm = null;

    @Before
    void setup() {
        sm = new DefaultSecurityManager();
        Ini ini = new Ini();
        IniSection section = ini.addSection(IniRealm.USERS_SECTION_NAME);
        section.put("guest", "guest, guest");
        section.put("lonestarr", "vespa, goodguy");
        sm.setRealm(new IniRealm(ini));
        SecurityUtils.setSecurityManager(sm);
    }

    @After
    override void tearDown() {
        SecurityUtils.setSecurityManager(null);
        sm.destroy();
        super.tearDown();
    }

    @Test
    void testDefaultConfig() {
        Subject subject = SecurityUtils.getSubject();

        AuthenticationToken token = new UsernamePasswordToken("guest", "guest");
        subject.login(token);
        assertTrue(subject.isAuthenticated());
        String p = cast(String)subject.getPrincipal();
        assertTrue("guest" == p.value);
        assertTrue(subject.hasRole("guest"));

        Session session = subject.getSession();
        session.setAttribute("key", "value");
        String a = cast(String)session.getAttribute("key");
        assertEquals(a.value, "value");

        subject.logout();

        assertNull(subject.getSession(false));
        assertNull(subject.getPrincipal());
        assertNull(subject.getPrincipals());
    }

    /**
     * Test that validates functionality for issue
     * <a href="https://issues.apache.org/jira/browse/JSEC-46">JSEC-46</a>
     */
    @Test
    void testAutoCreateSessionAfterInvalidation() {
        Subject subject = SecurityUtils.getSubject();
        Session session = subject.getSession();
        string origSessionId = session.getId();

        string key = "foo";
        string value1 = "bar";
        session.setAttribute(key, value1);
        String v = cast(String)session.getAttribute(key);
        assertEquals(value1, v.value);

        //now test auto creation:
        session.setTimeout(50);
        try {
            Thread.sleep(150.msecs);
        } catch (InterruptedException e) {
            //ignored
        }
        try {
            session.setTimeout(AbstractValidatingSessionManager.DEFAULT_GLOBAL_SESSION_TIMEOUT);
            fail("Session should have expired.");
        } catch (ExpiredSessionException expected) {
        }
    }

    /**
     * Test that validates functionality for issue
     * <a href="https://issues.apache.org/jira/browse/JSEC-22">JSEC-22</a>
     */
    @Test
    void testSubjectReuseAfterLogout() {

        Subject subject = SecurityUtils.getSubject();

        AuthenticationToken token = new UsernamePasswordToken("guest", "guest");
        subject.login(token);
        assertTrue(subject.isAuthenticated());

        String p = cast(String)subject.getPrincipal();
        assertTrue("guest" == p.value);
        assertTrue(subject.hasRole("guest"));

        Session session = subject.getSession();
        string firstSessionId = session.getId();

        session.setAttribute("key", "value");
        p = cast(String)session.getAttribute("key");
        assertEquals(p.value, "value");

        subject.logout();

        assertNull(subject.getSession(false));
        assertNull(subject.getPrincipal());
        assertNull(subject.getPrincipals());

        subject.login(new UsernamePasswordToken("lonestarr", "vespa"));
        assertTrue(subject.isAuthenticated());
        
        p = cast(String)subject.getPrincipal();
        assertTrue("lonestarr" == p.value);

        assertTrue(subject.hasRole("goodguy"));

        assertNotNull(subject.getSession());
        assertFalse(firstSessionId == subject.getSession().getId());

        subject.logout();

        assertNull(subject.getSession(false));
        assertNull(subject.getPrincipal());
        assertNull(subject.getPrincipals());

    }
}
