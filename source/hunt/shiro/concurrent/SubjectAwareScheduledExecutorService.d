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
module hunt.shiro.concurrent.SubjectAwareScheduledExecutorService;

// import hunt.concurrency;

/**
 * Same concept as the {@link SubjectAwareExecutorService} but additionally supports the
 * {@link ScheduledExecutorService} interface.
 */
// class SubjectAwareScheduledExecutorService : SubjectAwareExecutorService, ScheduledExecutorService {

//     private ScheduledExecutorService targetScheduledExecutorService;

//      this() {
//     }

//      this(ScheduledExecutorService target) {
//         setTargetScheduledExecutorService(target);
//     }

//      ScheduledExecutorService getTargetScheduledExecutorService() {
//         return targetScheduledExecutorService;
//     }

//      void setTargetScheduledExecutorService(ScheduledExecutorService targetScheduledExecutorService) {
//         super.setTargetExecutorService(targetScheduledExecutorService);
//         this.targetScheduledExecutorService = targetScheduledExecutorService;
//     }

//     override
//      void setTargetExecutor(Executor targetExecutor) {
//         auto targetExecutorCast = cast(ScheduledExecutorService)targetExecutor;
//         if (targetExecutorCast is null) {
//             string msg = "The SubjectAwareScheduledExecutorService implementation only accepts " ~
//                          "ScheduledExecutorService target instances.";
//             throw new IllegalArgumentException(msg);
//         }
//         super.setTargetExecutorService(targetExecutorCast);
//     }

//     override
//      void setTargetExecutorService(ExecutorService targetExecutorService) {
//         auto targetExecutorServiceCast = cast(ScheduledExecutorService)targetExecutorService;
//         if (targetExecutorServiceCast is null) {
//             string msg = "The SubjectAwareScheduledExecutorService implementation only accepts " ~
//                          "ScheduledExecutorService target instances.";
//             throw new IllegalArgumentException(msg);
//         }
//         super.setTargetExecutorService(targetExecutorService);
//     }

//      ScheduledFuture<?> schedule(Runnable command, long delay, TimeUnit unit) {
//         Runnable work = associateWithSubject(command);
//         return this.targetScheduledExecutorService.schedule(work, delay, unit);
//     }

//      <V> ScheduledFuture!(V) schedule(Callable!(V) callable, long delay, TimeUnit unit) {
//         Callable!(V) work = associateWithSubject(callable);
//         return this.targetScheduledExecutorService.schedule(work, delay, unit);
//     }

//      ScheduledFuture<?> scheduleAtFixedRate(Runnable command, long initialDelay, long period, TimeUnit unit) {
//         Runnable work = associateWithSubject(command);
//         return this.targetScheduledExecutorService.scheduleAtFixedRate(work, initialDelay, period, unit);
//     }

//      ScheduledFuture<?> scheduleWithFixedDelay(Runnable command, long initialDelay, long delay, TimeUnit unit) {
//         Runnable work = associateWithSubject(command);
//         return this.targetScheduledExecutorService.scheduleWithFixedDelay(work, initialDelay, delay, unit);
//     }
// }
