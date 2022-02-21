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
module hunt.shiro.event.support.EventClassComparator;

import hunt.shiro.event.support.SingleArgumentMethodEventListener;
import hunt.util.Comparator;

import hunt.Exceptions;
import hunt.logging.Logger;

/**
 * Compares two event classes based on their position in a class hierarchy.  Classes higher up in a hierarchy are
 * 'greater than' (ordered later) than classes lower in a hierarchy (ordered earlier).  Classes in unrelated
 * hierarchies have the same order priority.
 * <p/>
 * Event bus implementations use this comparator to determine which event listener method to invoke when polymorphic
 * listener methods are defined:
 * <p/>
 * If two event classes exist A and B, where A is the parent class of B (and B is a subclass of A) and an event
 * subscriber listens to both events:
 * <pre>
 * &#64;Subscribe
 * void onEvent(A a) { ... }
 *
 * &#64;Subscribe
 * void onEvent(B b) { ... }
 * </pre>
 *
 * The {@code onEvent(B b)} method will be invoked on the subscriber and the
 * {@code onEvent(A a)} method will <em>not</em> be invoked.  This is to prevent multiple dispatching of a single event
 * to the same consumer.
 * <p/>
 * The EventClassComparator is used to order listener method priority based on their event argument class - methods
 * handling event subclasses have higher precedence than superclasses.
 *
 * @since 1.3
 */
class EventClassComparator : Comparator!TypeInfo_Class {

    int compare(TypeInfo_Class a, TypeInfo_Class b) {
        try {
            if (a is null) {
                if (b is null) {
                    return 0;
                } else {
                    return -1;
                }
            } else if (b is null) {
                return 1;
            } else if (a is b || a.opEquals(b)) {
                return 0;
            } else {
                implementationMissing(false);
                return 0;
                // if (a.isAssignableFrom(b)) {
                //     return 1;
                // } else if (b.isAssignableFrom(a)) {
                //     return -1;
                // } else {
                //     return 0;
                // }
            }
        }
      catch(Exception ex)   {
          warning(ex.msg);
          return 0;
      }
    } 
}
