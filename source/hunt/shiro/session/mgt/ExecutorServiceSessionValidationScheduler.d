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

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import hunt.logger;


/**
 * SessionValidationScheduler implementation that uses a
 * {@link ScheduledExecutorService} to call {@link ValidatingSessionManager#validateSessions()} every
 * <em>{@link #getInterval interval}</em> milliseconds.
 *
 * @since 0.9
 */
class ExecutorServiceSessionValidationScheduler : SessionValidationScheduler, Runnable {

    //TODO - complete JavaDoc

    /** Private internal log instance. */


    ValidatingSessionManager sessionManager;
    private ScheduledExecutorService service;
    private long interval = DefaultSessionManager.DEFAULT_SESSION_VALIDATION_INTERVAL;
    private bool enabled = false;
    private string threadNamePrefix = "SessionValidationThread-";

     ExecutorServiceSessionValidationScheduler() {
        super();
    }

     ExecutorServiceSessionValidationScheduler(ValidatingSessionManager sessionManager) {
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
        if (this.interval > 0l) {
            this.service = Executors.newSingleThreadScheduledExecutor(new ThreadFactory() {  
	            private final AtomicInteger count = new AtomicInteger(1);

	             Thread newThread(Runnable r) {
	                Thread thread = new Thread(r);  
	                thread.setDaemon(true);  
	                thread.setName(threadNamePrefix + count.getAndIncrement());
	                return thread;  
	            }  
            });                  
            this.service.scheduleAtFixedRate(this, interval, interval, TimeUnit.MILLISECONDS);
        }
        this.enabled = true;
    }

     void run() {
        if (log.isDebugEnabled()) {
            tracef("Executing session validation...");
        }
        long startTime = DateTimeHelper.currentTimeMillis()();
        this.sessionManager.validateSessions();
        long stopTime = DateTimeHelper.currentTimeMillis()();
        if (log.isDebugEnabled()) {
            tracef("Session validation completed successfully in " ~ (stopTime - startTime) ~ " milliseconds.");
        }
    }

     void disableSessionValidation() {
        if (this.service != null) {
            this.service.shutdownNow();
        }
        this.enabled = false;
    }
}
