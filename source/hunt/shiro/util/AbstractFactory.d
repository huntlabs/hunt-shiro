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

import hunt.Exceptions;

/**
 * Generics-aware interface supporting the
 * <a href="http://en.wikipedia.org/wiki/Factory_method_pattern">Factory Method</a> design pattern.
 *
 * @param <T> The type of the instance returned by the Factory implementation.
 * @since 1.0
 */
interface Factory(T) {

    /**
     * Returns an instance of the required type.  The implementation determines whether or not a new or cached
     * instance is created every time this method is called.
     *
     * @return an instance of the required type.
     */
    T getInstance();
}


/**
 * TODO - Class JavaDoc
 *
 */
abstract class AbstractFactory(T) : Factory!(T) {

    private bool singleton;
    private T singletonInstance;

    this() {
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
