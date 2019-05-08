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
module hunt.shiro.config.IniFactorySupport;

// import hunt.shiro.io.ResourceUtils;
// import hunt.shiro.util.AbstractFactory;
// import hunt.shiro.util.CollectionUtils;
// import hunt.shiro.util.Factory;
// import hunt.logging;
// import hunt.loggerFactory;

// import hunt.collection.HashMap;
// import hunt.collection.Map;

// /**
//  * Base support class for {@link Factory} implementations that generate their instance(s) based on
//  * {@link Ini} configuration.
//  *
//  * @since 1.0
//  * deprecated("") use Shiro's {@code Environment} mechanisms instead.
//  */
// deprecated("")
// abstract class IniFactorySupport(T) : AbstractFactory!(T) {

//      enum string DEFAULT_INI_RESOURCE_PATH = "classpath:shiro.ini";



//     private Ini ini;

//     private Map!(string, T) defaultBeans;

//     protected this() {
//     }

//     protected this(Ini ini) {
//         this.ini = ini;
//     }

//      Ini getIni() {
//         return ini;
//     }

//      void setIni(Ini ini) {
//         this.ini = ini;
//     }

//     /**
//      * Returns a mapping of string to bean representing the default set of object used by the factory.
//      * These beans can be used by this factory in conjunction with objects parsed from the INI configuration.
//      * @return A Map of default objects, or <code>null</code>.
//      * @since 1.4
//      */
//     protected Map<string, ?> getDefaults() {
//         return defaultBeans;
//     }

//     /**
//      * Sets the default objects used by this factory. These defaults may be used in conjunction with the INI
//      * configuration.
//      * @param defaultBeans string to object mapping used for default configuration in this factory.
//      * @since 1.4
//      */
//      void setDefaults(Map<string, ?> defaultBeans) {
//         this.defaultBeans = defaultBeans;
//     }

//     /**
//      * Returns a new Ini instance created from the default {@code classpath:shiro.ini} file, or {@code null} if
//      * the file does not exist.
//      *
//      * @return a new Ini instance created from the default {@code classpath:shiro.ini} file, or {@code null} if
//      *         the file does not exist.
//      */
//      static Ini loadDefaultClassPathIni() {
//         Ini ini = null;
//         if (ResourceUtils.resourceExists(DEFAULT_INI_RESOURCE_PATH)) {
//             tracef("Found shiro.ini at the root of the classpath.");
//             ini = new Ini();
//             ini.loadFromPath(DEFAULT_INI_RESOURCE_PATH);
//             if (CollectionUtils.isEmpty(ini)) {
//                 warning("shiro.ini found at the root of the classpath, but it did not contain any data.");
//             }
//         }
//         return ini;
//     }

//     /**
//      * Tries to resolve the Ini instance to use for configuration.  This implementation functions as follows:
//      * <ol>
//      * <li>The {@code Ini} instance returned from {@link #getIni()} will be returned if it is not null or empty.</li>
//      * <li>If {@link #getIni()} is {@code null} or empty, this implementation will attempt to find and load the
//      * {@link #loadDefaultClassPathIni() default class path Ini}.</li>
//      * <li>If neither of the two attempts above returns an instance, {@code null} is returned</li>
//      * </ol>
//      *
//      * @return the Ini instance to use for configuration.
//      */
//     protected Ini resolveIni() {
//         Ini ini = getIni();
//         if (CollectionUtils.isEmpty(ini)) {
//             tracef("Null or empty Ini instance.  Falling back to the default %s file.", DEFAULT_INI_RESOURCE_PATH);
//             ini = loadDefaultClassPathIni();
//         }
//         return ini;
//     }

//     /**
//      * Creates a new object instance by using a configured INI source.  This implementation functions as follows:
//      * <ol>
//      * <li>{@link #resolveIni() Resolve} the {@code Ini} source to use for configuration.</li>
//      * <li>If there was no resolved Ini source, create and return a simple default instance via the
//      * {@link #createDefaultInstance()} method.</li>
//      * </ol>
//      *
//      * @return a new {@code SecurityManager} instance by using a configured INI source.
//      */
//      T createInstance() {
//         Ini ini = resolveIni();

//         T instance;

//         if (CollectionUtils.isEmpty(ini)) {
//             tracef("No populated Ini available.  Creating a default instance.");
//             instance = createDefaultInstance();
//             if (instance  is null) {
//                 string msg = typeid(this).name ~ " implementation did not return a default instance in " ~
//                         "the event of a null/empty Ini configuration.  This is required to support the " ~
//                         "Factory interface.  Please check your implementation.";
//                 throw new IllegalStateException(msg);
//             }
//         } else {
//             tracef("Creating instance from Ini [" ~ ini ~ "]");
//             instance = createInstance(ini);
//             if (instance  is null) {
//                 string msg = typeid(this).name ~ " implementation did not return a constructed instance from " ~
//                         "the createInstance(Ini) method implementation.";
//                 throw new IllegalStateException(msg);
//             }
//         }

//         return instance;
//     }

//     protected abstract T createInstance(Ini ini);

//     protected abstract T createDefaultInstance();
// }
