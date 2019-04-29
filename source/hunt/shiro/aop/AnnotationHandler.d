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
module hunt.shiro.aop.AnnotationHandler;

import java.lang.annotation.Annotation;

import hunt.shiro.SecurityUtils;
import hunt.shiro.subject.Subject;


/**
* Base support class for implementations that reads and processes JSR-175 annotations.
*
* @since 0.9.0
*/
abstract class AnnotationHandler {

   /**
    * The type of annotation this handler will process.
    */
   protected TypeInfo annotationClass;

   /**
    * Constructs an <code>AnnotationHandler</code> who processes annotations of the
    * specified type.  Immediately calls {@link #setAnnotationClass(Class)}.
    *
    * @param annotationClass the type of annotation this handler will process.
    */
    this(TypeInfo annotationClass) {
       setAnnotationClass(annotationClass);
   }

   /**
    * Returns the {@link hunt.shiro.subject.Subject Subject} associated with the currently-executing code.
    * <p/>
    * This default implementation merely calls <code>{@link hunt.shiro.SecurityUtils#getSubject SecurityUtils.getSubject()}</code>.
    *
    * @return the {@link hunt.shiro.subject.Subject Subject} associated with the currently-executing code.
    */
   protected Subject getSubject() {
       return SecurityUtils.getSubject();
   }

   /**
    * Sets the type of annotation this handler will inspect and process.
    *
    * @param annotationClass the type of annotation this handler will process.
    * @throws IllegalArgumentException if the argument is <code>null</code>.
    */
   protected void setAnnotationClass(TypeInfo annotationClass){
       if (annotationClass  is null) {
           string msg = "annotationClass argument cannot be null";
           throw new IllegalArgumentException(msg);
       }
       this.annotationClass = annotationClass;
   }

   /**
    * Returns the type of annotation this handler inspects and processes.
    *
    * @return the type of annotation this handler inspects and processes.
    */
    TypeInfo getAnnotationClass() {
       return this.annotationClass;
   }

}
