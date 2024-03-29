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
module test.shiro.subject.DelegatingSubjectTest;

import hunt.shiro.authc.UsernamePasswordToken;
import hunt.shiro.config.Ini;
import hunt.shiro.config.IniFactorySupport;
import hunt.shiro.config.IniSecurityManagerFactory;
import hunt.shiro.mgt.DefaultSecurityManager;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.session.Session;
import hunt.shiro.SecurityUtils;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.SimplePrincipalCollection;
import hunt.shiro.subject.support.DelegatingSubject;
import hunt.shiro.subject.Subject;
// import hunt.shiro.util.CollectionUtils;
import hunt.shiro.util.LifecycleUtils;
import hunt.shiro.util.ThreadContext;

import hunt.Assert;
import hunt.logging.Logger;
import hunt.String;
import hunt.util.Common;
import hunt.util.UnitTest;


/**
 * @since Aug 1, 2008 2:11:17 PM
 */
class DelegatingSubjectTest {

    @Before
    void setup() {
        ThreadContext.remove();
    }

    @After
    void tearDown() {
        ThreadContext.remove();
    }

    @Test
    void testSessionStopThenStart() {
        // string key = "testKey";
        // string value = "testValue";

        
        String key = new String("testKey");
        String value = new String("testValue");
        DefaultSecurityManager sm = new DefaultSecurityManager();

        DelegatingSubject subject = new DelegatingSubject(sm);

        Session session = subject.getSession();
        session.setAttribute(key, value);
        assertTrue(session.getAttribute(key) == value);
        string firstSessionId = session.getId();
        assertNotNull(firstSessionId);

        session.stop();

        session = subject.getSession();
        assertNotNull(session);
        assertNull(session.getAttribute(key));
        string secondSessionId = session.getId();
        assertNotNull(secondSessionId);
        assertFalse(firstSessionId == secondSessionId);

        subject.logout();

        sm.destroy();
    }

    @Test
    void testExecuteCallable() {

        string username = "jsmith";

        SecurityManager securityManager = new DefaultSecurityManager();
        PrincipalCollection identity = new SimplePrincipalCollection(username, "testRealm");
        DelegatingSubject sourceSubject = new DelegatingSubject(identity, true, null, null, securityManager);

        assertNull(ThreadContext.getSubject());
        assertNull(ThreadContext.getSecurityManager());

        Callable!string callable = new class Callable!string {
            string call() {
                Subject callingSubject = SecurityUtils.getSubject();
                assertNotNull(callingSubject);
                assertNotNull(SecurityUtils.getSecurityManager());
                assertEquals(callingSubject, sourceSubject);
                return "Hello " ~ callingSubject.getPrincipal().toString();
            }
        };
        string response = sourceSubject.execute(callable);

        assertNotNull(response);
        assertEquals("Hello " ~ username, response);

        assertNull(ThreadContext.getSubject());
        assertNull(ThreadContext.getSecurityManager());
    }

    @Test
    void testExecuteRunnable() {

        string username = "jsmith";

        SecurityManager securityManager = new DefaultSecurityManager();
        PrincipalCollection identity = new SimplePrincipalCollection(username, "testRealm");
        Subject sourceSubject = new DelegatingSubject(identity, true, null, null, securityManager);

        assertNull(ThreadContext.getSubject());
        assertNull(ThreadContext.getSecurityManager());

        Runnable runnable = new class Runnable {
            void run() {
                Subject callingSubject = SecurityUtils.getSubject();
                assertNotNull(callingSubject);
                assertNotNull(SecurityUtils.getSecurityManager());
                assertEquals(callingSubject, sourceSubject);
            }
        };
        sourceSubject.execute(runnable);

        assertNull(ThreadContext.getSubject());
        assertNull(ThreadContext.getSecurityManager());
    }


    @Test
    void testRunAs() {

        Ini ini = new Ini();
        IniSection users = ini.addSection("users");
        users.put("user1", "user1,role1");
        users.put("user2", "user2,role2");
        users.put("user3", "user3,role3");
        IniSecurityManagerFactory factory = new IniSecurityManagerFactory(ini);
        SecurityManager sm = factory.getInstance();

        //login as user1
        Subject subject = new SubjectBuilder(sm).buildSubject();
        subject.login(new UsernamePasswordToken("user1", "user1"));

        assertFalse(subject.isRunAs());
        assertEquals(new String("user1"), subject.getPrincipal());
        assertTrue(subject.hasRole("role1"));
        assertFalse(subject.hasRole("role2"));
        assertFalse(subject.hasRole("role3"));
        assertNull(subject.getPreviousPrincipals()); //no previous principals since we haven't called runAs yet

        //runAs user2:
        subject.runAs(new SimplePrincipalCollection("user2", IniSecurityManagerFactory.INI_REALM_NAME));
        assertTrue(subject.isRunAs());
        assertEquals(new String("user2"), subject.getPrincipal());
        assertTrue(subject.hasRole("role2"));
        assertFalse(subject.hasRole("role1"));
        assertFalse(subject.hasRole("role3"));

        //assert we still have the previous (user1) principals:
        PrincipalCollection previous = subject.getPreviousPrincipals();
        assertFalse(previous is null || previous.isEmpty());
        assertTrue(previous.getPrimaryPrincipal() == new String("user1"));

        trace("==================");

        //test the stack functionality:  While as user2, run as user3:
        subject.runAs(new SimplePrincipalCollection("user3", IniSecurityManagerFactory.INI_REALM_NAME));
        assertTrue(subject.isRunAs());
        Object pri = subject.getPrincipal();

        assertEquals(new String("user3"), subject.getPrincipal());
        assertTrue(subject.hasRole("role3"));
        assertFalse(subject.hasRole("role1"));
        assertFalse(subject.hasRole("role2"));

        //assert we still have the previous (user2) principals in the stack:
        previous = subject.getPreviousPrincipals();
        assertFalse(previous is null || previous.isEmpty());
        assertTrue(previous.getPrimaryPrincipal() == new String("user2"));

        //drop down to user2:
        subject.releaseRunAs();

        //assert still run as:
        assertTrue(subject.isRunAs());
        assertEquals(new String("user2"), subject.getPrincipal());
        assertTrue(subject.hasRole("role2"));
        assertFalse(subject.hasRole("role1"));
        assertFalse(subject.hasRole("role3"));

        //assert we still have the previous (user1) principals:
        previous = subject.getPreviousPrincipals();
        assertFalse(previous is null || previous.isEmpty());
        assertTrue(previous.getPrimaryPrincipal()  == new String("user1"));

        //drop down to original user1:
        subject.releaseRunAs();

        //assert we're no longer runAs:
        assertFalse(subject.isRunAs());
        assertEquals(new String("user1"), subject.getPrincipal());
        assertTrue(subject.hasRole("role1"));
        assertFalse(subject.hasRole("role2"));
        assertFalse(subject.hasRole("role3"));
        assertNull(subject.getPreviousPrincipals()); //no previous principals in orig state

        subject.logout();

        LifecycleUtils.destroy(cast(Object)sm);
    }
}
