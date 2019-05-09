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
module hunt.shiro.session.mgt.ExecutorServiceSessionValidationScheduler;

import hunt.shiro.session.mgt.DefaultSessionManager;
import hunt.shiro.session.mgt.SessionValidationScheduler;
import hunt.shiro.session.mgt.ValidatingSessionManager;

import hunt.concurrency.atomic;
import hunt.concurrency.thread;

import hunt.concurrency.Executors;
import hunt.concurrency.ScheduledExecutorService;
import hunt.concurrency.ThreadFactory;
import hunt.util.DateTime;
import hunt.util.Common;

import hunt.logging;

import std.conv;

/**
 * SessionValidationScheduler implementation that uses a
 * {@link ScheduledExecutorService} to call {@link ValidatingSessionManager#validateSessions()} every
 * <em>{@link #getInterval interval}</em> milliseconds.
 *
 */
class ExecutorServiceSessionValidationScheduler : SessionValidationScheduler, Runnable {

    /** Private internal log instance. */


    ValidatingSessionManager sessionManager;
    private ScheduledExecutorService service;
    private long interval = DefaultSessionManager.DEFAULT_SESSION_VALIDATION_INTERVAL;
    private bool enabled = false;
    private string threadNamePrefix = "SessionValidationThread-";

    this() {
        super();
    }

    this(ValidatingSessionManager sessionManager) {
        this.sessionManager = sessionManager;
    }

     ValidatingSessionManager getSessionManager() {
        return sessionManager;
    }

     void setSessionManager(ValidatingSessionManager sessionManager) {
        this.sessionManager = sessionManager;
    }

     long getInterval() {
        return interval;
    }

     void setInterval(long interval) {
        this.interval = interval;
    }

     bool isEnabled() {
        return this.enabled;
    }

     void setThreadNamePrefix(string threadNamePrefix) {
        this.threadNamePrefix = threadNamePrefix;
    }

     string getThreadNamePrefix() {
        return this.threadNamePrefix;
    }

    /**
     * Creates a single thread {@link ScheduledExecutorService} to validate sessions at fixed intervals 
     * and enables this scheduler. The executor is created as a daemon thread to allow JVM to shut down
     */
    //TODO Implement an integration test to test for jvm exit as part of the standalone example
    // (so we don't have to change the unit test execution model for the core module)
     void enableSessionValidation() {
        if (this.interval > 0) {
            this.service = Executors.newSingleThreadScheduledExecutor(new class ThreadFactory {  
	            private shared int count = 0;

	             ThreadEx newThread(Runnable r) {
                    int c = AtomicHelper.increment(count);
	                ThreadEx thread = new ThreadEx(r);  
	                thread.isDaemon = true;
	                thread.name = threadNamePrefix ~ c.to!string();
	                return thread;  
	            }  
            });                  
            this.service.scheduleAtFixedRate(this, interval, interval, TimeUnit.MILLISECONDS);
        }
        this.enabled = true;
    }

     void run() {
        version(HUNT_DEBUG) {
            tracef("Executing session validation...");
        }
        long startTime = DateTimeHelper.currentTimeMillis();
        this.sessionManager.validateSessions();
        long stopTime = DateTimeHelper.currentTimeMillis();
        version(HUNT_DEBUG) {
            tracef("Session validation completed successfully in " 
                ~ to!string(stopTime - startTime) ~ " milliseconds.");
        }
    }

     void disableSessionValidation() {
        if (this.service !is null) {
            this.service.shutdownNow();
        }
        this.enabled = false;
    }
}
