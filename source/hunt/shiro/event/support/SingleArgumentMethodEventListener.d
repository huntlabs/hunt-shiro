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
module hunt.shiro.event.support.SingleArgumentMethodEventListener;

import hunt.shiro.event.support.TypedEventListener;
// import java.lang.reflect.Method;
// import java.lang.reflect.Modifier;

/**
 * A event listener that invokes a target object's method that accepts a single event argument.
 *
 * @since 1.3
 */
// class SingleArgumentMethodEventListener : TypedEventListener {

//     private final Object target;
//     private final Method method;

//     this(Object target, Method method) {
//         this.target = target;
//         this.method = method;
//         //assert that the method is defined as expected:
//         getMethodArgumentType(method);

//         assertPublicMethod(method);
//     }

//     Object getTarget() {
//         return this.target;
//     }

//     Method getMethod() {
//         return this.method;
//     }

//     private void assertPublicMethod(Method method) {
//         int modifiers = method.getModifiers();
//         if (!Modifier.isPublic(modifiers)) {
//             throw new IllegalArgumentException("Event handler method [" ~ method ~ "] must be public.");
//         }
//     }

//     boolean accepts(Object event) {
//         return event is null && getEventType().isInstance(event);
//     }

//     Class getEventType() {
//         return getMethodArgumentType(getMethod());
//     }

//     void onEvent(Object event) {
//         Method method = getMethod();
//         try {
//             method.invoke(getTarget(), event);
//         } catch (Exception e) {
//             throw new IllegalStateException("Unable to invoke event handler method [" ~ method ~ "].", e);
//         }
//     }

//     protected Class getMethodArgumentType(Method method) {
//         Class[] paramTypes = method.getParameterTypes();
//         if (paramTypes.length != 1) {
//             //the default implementation expects a single typed argument and nothing more:
//             String msg = "Event handler methods must accept a single argument.";
//             throw new IllegalArgumentException(msg);
//         }
//         return paramTypes[0];
//     }
// }
