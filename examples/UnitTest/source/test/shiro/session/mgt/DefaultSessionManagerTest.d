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
module test.shiro.session.mgt.DefaultSessionManagerTest;

import hunt.shiro.Exceptions;
import hunt.shiro.session.Session;
import hunt.shiro.session.SessionListener;
import hunt.shiro.session.SessionListenerAdapter;
import hunt.shiro.session.mgt.DefaultSessionManager;
import hunt.shiro.session.mgt.DefaultSessionKey;
import hunt.shiro.session.mgt.eis.SessionDAO;
import hunt.shiro.util.ThreadContext;
// import org.easymock.EasyMock;
// import org.easymock.IArgumentMatcher;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.String;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.thread;
import core.time;

/**
 * Unit test for the {@link DefaultSessionManager DefaultSessionManager} implementation.
 */
class DefaultSessionManagerTest {

    DefaultSessionManager sm = null;

    @Before
    void setup() {
        ThreadContext.remove();
        sm = new DefaultSessionManager();
    }

    @After
    void tearDown() {
        sm.destroy();
        ThreadContext.remove();
    }

    void sleep(long millis) {
        try {
            Thread.sleep(millis.msecs);
        } catch (InterruptedException e) {
            throw new IllegalStateException(e);
        }
    }

    @Test
    void testGlobalTimeout() {
        long timeout = 1000;
        sm.setGlobalSessionTimeout(timeout);
        Session session = sm.start(null);
        assertNotNull(session);
        assertNotNull(session.getId());
        assertEquals(session.getTimeout(), timeout);
    }

    @Test
    void testSessionListenerStartNotification() {
        bool[] started = new bool[1];
        SessionListener listener = new class SessionListenerAdapter {
            override void onStart(Session session) {
                started[0] = true;
            }
        };
        sm.getSessionListeners().add(listener);
        sm.start(null);
        assertTrue(started[0]);
    }

    @Test
    void testSessionListenerStopNotification() {
        bool[] stopped = new bool[1];
        SessionListener listener = new class SessionListenerAdapter {
            override void onStop(Session session) {
                stopped[0] = true;
            }
        };
        sm.getSessionListeners().add(listener);
        Session session = sm.start(null);
        sm.stop(new DefaultSessionKey(session.getId()));
        assertTrue(stopped[0]);
    }

    // asserts fix for SHIRO-388:
    // Ensures that a session attribute can be accessed in the listener without
    // causing a stack overflow exception.
    @Test
    void testSessionListenerStopNotificationWithReadAttribute() {
        bool[] stopped = new bool[1];
        String[] value = new String[1];
        SessionListener listener = new class SessionListenerAdapter {
            override void onStop(Session session) {
                stopped[0] = true;
                value[0] = cast(String)session.getAttribute("foo");
            }
        };
        sm.getSessionListeners().add(listener);
        Session session = sm.start(null);
        session.setAttribute("foo", "bar");

        sm.stop(new DefaultSessionKey(session.getId()));

        assertTrue(stopped[0]);
        assertEquals("bar", value[0].value);
    }

    @Test
    void testSessionListenerExpiredNotification() {
        bool[] expired = new bool[1];
        SessionListener listener = new class SessionListenerAdapter {
            override void onExpiration(Session session) {
                expired[0] = true;
            }
        };
        sm.getSessionListeners().add(listener);
        sm.setGlobalSessionTimeout(100);
        Session session = sm.start(null);
        sleep(150);
        try {
            sm.checkValid(new DefaultSessionKey(session.getId()));
            fail("check should have thrown an exception.");
        } catch (InvalidSessionException expected) {
            //do nothing - expected.
        }
        assertTrue(expired[0]);
    }

    // @Test
    // void testSessionDeleteOnExpiration() {
    //     sm.setGlobalSessionTimeout(100);

    //     SessionDAO sessionDAO = createMock(SessionDAO.class);
    //     sm.setSessionDAO(sessionDAO);

    //     String sessionId1 = UUID.randomUUID().toString();
    //     SimpleSession session1 = new SimpleSession();
    //     session1.setId(sessionId1);

    //     Session[] activeSession = [session1];
    //     sm.setSessionFactory(new class SessionFactory {
    //         Session createSession(SessionContext initData) {
    //             return activeSession[0];
    //         }
    //     });

    //     expect(sessionDAO.create(eq(session1))).andReturn(sessionId1);
    //     sessionDAO.update(eq(session1));
    //     expectLastCall().anyTimes();
    //     replay(sessionDAO);
    //     Session session = sm.start(null);
    //     assertNotNull(session);
    //     verify(sessionDAO);
    //     reset(sessionDAO);

    //     expect(sessionDAO.readSession(sessionId1)).andReturn(session1).anyTimes();
    //     sessionDAO.update(eq(session1));
    //     replay(sessionDAO);
    //     sm.setTimeout(new DefaultSessionKey(sessionId1), 1);
    //     verify(sessionDAO);
    //     reset(sessionDAO);

    //     sleep(20);

    //     expect(sessionDAO.readSession(sessionId1)).andReturn(session1);
    //     sessionDAO.update(eq(session1)); //update's the stop timestamp
    //     sessionDAO.delete(session1);
    //     replay(sessionDAO);

    //     //Try to access the same session, but it should throw an UnknownSessionException due to timeout:
    //     try {
    //         sm.getTimeout(new DefaultSessionKey(sessionId1));
    //         fail("Session with id [" ~ sessionId1 + "] should have expired due to timeout.");
    //     } catch (ExpiredSessionException expected) {
    //         //expected
    //     }

    //     verify(sessionDAO); //verify that the delete call was actually made on the DAO
    // }

    // /**
    //  * Tests a bug introduced by SHIRO-443, where a custom sessionValidationScheduler would not be started.
    //  */
    // @Test
    // void testEnablingOfCustomSessionValidationScheduler() {

    //     // using the default impl of sessionValidationScheduler, as the but effects any scheduler we set directly via
    //     // sessionManager.setSessionValidationScheduler(), commonly used in INI configuration.
    //     ExecutorServiceSessionValidationScheduler sessionValidationScheduler = new ExecutorServiceSessionValidationScheduler();
    //     DefaultSessionManager sessionManager = new DefaultSessionManager();
    //     sessionManager.setSessionValidationScheduler(sessionValidationScheduler);

    //     // starting a session will trigger the starting of the validator
    //     try {
    //         Session session = sessionManager.start(null);

    //         // now sessionValidationScheduler should be enabled
    //         assertTrue("sessionValidationScheduler was not enabled", sessionValidationScheduler.isEnabled());
    //     }
    //     finally {
    //         // cleanup after test
    //         sessionManager.destroy();
    //     }
    // }

    // static <T extends Session> T eqSessionTimeout(long timeout) {
    //     EasyMock.reportMatcher(new SessionTimeoutMatcher(timeout));
    //     return null;
    // }

    // private static class SessionTimeoutMatcher : IArgumentMatcher {

    //     private long timeout;

    //     this(long timeout) {
    //         this.timeout = timeout;
    //     }

    //     void appendTo(StringBuffer buffer) {
    //         buffer.append("eqSession(timeout=").append(this.timeout).append(")");
    //     }

    //     bool matches(Object o) {
    //         return o instanceof Session && ((Session) o).getTimeout() == this.timeout;
    //     }
    // }
}
