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
module hunt.shiro.util.AbstractFactory;

/**
 * TODO - Class JavaDoc
 *
 * @since 1.0
 */
abstract class AbstractFactory!(T) implements Factory!(T) {

    private bool singleton;
    private T singletonInstance;

     AbstractFactory() {
        this.singleton = true;
    }

     bool isSingleton() {
        return singleton;
    }

     void setSingleton(bool singleton) {
        this.singleton = singleton;
    }

     T getInstance() {
        T instance;
        if (isSingleton()) {
            if (this.singletonInstance  is null) {
                this.singletonInstance = createInstance();
            }
            instance = this.singletonInstance;
        } else {
            instance = createInstance();
        }
        if (instance  is null) {
            string msg = "Factory 'createInstance' implementation returned a null object.";
            throw new IllegalStateException(msg);
        }
        return instance;
    }

    protected abstract T createInstance();
}
