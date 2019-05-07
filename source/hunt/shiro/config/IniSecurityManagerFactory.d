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
module hunt.shiro.config.IniSecurityManagerFactory;

// import hunt.shiro.mgt.DefaultSecurityManager;
// import hunt.shiro.mgt.RealmSecurityManager;
// import hunt.shiro.mgt.SecurityManager;
// import hunt.shiro.realm.Realm;
// import hunt.shiro.realm.RealmFactory;
// import hunt.shiro.realm.text.IniRealm;
// import hunt.shiro.util.CollectionUtils;
// import hunt.shiro.util.Factory;
// import hunt.shiro.util.LifecycleUtils;
// import hunt.shiro.util.Nameable;
// import hunt.logger;
// import hunt.loggerFactory;

// import hunt.collection;

// /**
//  * A {@link Factory} that creates {@link SecurityManager} instances based on {@link Ini} configuration.
//  *
//  * @since 1.0
//  * deprecated("") use Shiro's {@code Environment} mechanisms instead.
//  */
// deprecated("")
// class IniSecurityManagerFactory : IniFactorySupport!(SecurityManager) {

//      enum string MAIN_SECTION_NAME = "main";

//      enum string SECURITY_MANAGER_NAME = "securityManager";
//      enum string INI_REALM_NAME = "iniRealm";



//     private ReflectionBuilder builder;

//     /**
//      * Creates a new instance.  See the {@link #getInstance()} JavaDoc for detailed explanation of how an INI
//      * source will be resolved to use to build the instance.
//      */
//      this() {
//         this.builder = new ReflectionBuilder();
//     }

//      this(Ini config) {
//         this();
//         setIni(config);
//     }

//      this(string iniResourcePath) {
//         this(Ini.fromResourcePath(iniResourcePath));
//     }

//      Map!(string, T) getBeans() {
//         return this.builder !is null ? Collections.unmodifiableMap(builder.getObjects()) : null;
//     }

//      void destroy() {
//         if(getReflectionBuilder() !is null) {
//             getReflectionBuilder().destroy();
//         }
//     }

//     private SecurityManager getSecurityManagerBean() {
//         return getReflectionBuilder().getBean(SECURITY_MANAGER_NAME, typeid(SecurityManager));
//     }

//     protected SecurityManager createDefaultInstance() {
//         return new DefaultSecurityManager();
//     }

//     protected SecurityManager createInstance(Ini ini) {
//         if (CollectionUtils.isEmpty(ini)) {
//             throw new NullPointerException("Ini argument cannot be null or empty.");
//         }
//         SecurityManager securityManager = createSecurityManager(ini);
//         if (securityManager  is null) {
//             string msg = "SecurityManager instance cannot be null.";
//             throw new ConfigurationException(msg);
//         }
//         return securityManager;
//     }

//     private SecurityManager createSecurityManager(Ini ini) {
//         return createSecurityManager(ini, getConfigSection(ini));
//     }

//     private Ini.Section getConfigSection(Ini ini) {

//         Ini.Section mainSection = ini.getSection(MAIN_SECTION_NAME);
//         if (CollectionUtils.isEmpty(mainSection)) {
//             //try the default:
//             mainSection = ini.getSection(Ini.DEFAULT_SECTION_NAME);
//         }
//         return mainSection;
//     }

//     protected bool isAutoApplyRealms(SecurityManager securityManager) {
//         bool autoApply = true;
//         auto securityManagerCast = cast(RealmSecurityManager)securityManager;
//         if (securityManagerCast !is null) {
//             //only apply realms if they haven't been explicitly set by the user:
//             RealmSecurityManager realmSecurityManager = securityManagerCast;
//             Collection!(Realm) realms = realmSecurityManager.getRealms();
//             if (!CollectionUtils.isEmpty(realms)) {
//                 info("Realms have been explicitly set on the SecurityManager instance - auto-setting of " ~
//                         "realms will not occur.");
//                 autoApply = false;
//             }
//         }
//         return autoApply;
//     }

//     //@SuppressWarnings({"unchecked"})
//     private SecurityManager createSecurityManager(Ini ini, Ini.Section mainSection) {

//         getReflectionBuilder().setObjects(createDefaults(ini, mainSection));
//         Map!(string, T) objects = buildInstances(mainSection);

//         SecurityManager securityManager = getSecurityManagerBean();

//         bool autoApplyRealms = isAutoApplyRealms(securityManager);

//         if (autoApplyRealms) {
//             //realms and realm factory might have been created - pull them out first so we can
//             //initialize the securityManager:
//             Collection!(Realm) realms = getRealms(objects);
//             //set them on the SecurityManager
//             if (!CollectionUtils.isEmpty(realms)) {
//                 applyRealmsToSecurityManager(realms, securityManager);
//             }
//         }

//         return securityManager;
//     }

//     protected Map<string, ?> createDefaults(Ini ini, Ini.Section mainSection) {
//         Map!(string, Object) defaults = new LinkedHashMap!(string, Object)();

//         SecurityManager securityManager = createDefaultInstance();
//         defaults.put(SECURITY_MANAGER_NAME, securityManager);

//         if (shouldImplicitlyCreateRealm(ini)) {
//             Realm realm = createRealm(ini);
//             if (realm !is null) {
//                 defaults.put(INI_REALM_NAME, realm);
//             }
//         }

//         // The values from 'getDefaults()' will override the above.
//         Map<string, ?> defaultBeans = getDefaults();
//         if (!CollectionUtils.isEmpty(defaultBeans)) {
//             defaults.putAll(defaultBeans);
//         }

//         return defaults;
//     }

//     private Map<string, ?> buildInstances(Ini.Section section) {
//         return getReflectionBuilder().buildObjects(section);
//     }

//     private void addToRealms(Collection!(Realm) realms, RealmFactory factory) {
//         LifecycleUtils.init(factory);
//         Collection!(Realm) factoryRealms = factory.getRealms();
//         //SHIRO-238: check factoryRealms (was 'realms'):
//         if (!CollectionUtils.isEmpty(factoryRealms)) {
//             realms.addAll(factoryRealms);
//         }
//     }

//     private Collection!(Realm) getRealms(Map<string, ?> instances) {

//         //realms and realm factory might have been created - pull them out first so we can
//         //initialize the securityManager:
//         List!(Realm) realms = new ArrayList!(Realm)();

//         //iterate over the map entries to pull out the realm factory(s):
//         for (Map.Entry<string, ?> entry : instances.entrySet()) {

//             string name = entry.getKey();
//             Object value = entry.getValue();

//             if (value instanceof RealmFactory) {
//                 addToRealms(realms, (RealmFactory) value);
//             } else if (value instanceof Realm) {
//                 Realm realm = (Realm) value;
//                 //set the name if null:
//                 string existingName = realm.getName();
//                 if (existingName  is null || existingName.startsWith(typeid(realm).name)) {
//                     if (realm instanceof Nameable) {
//                         ((Nameable) realm).setName(name);
//                         tracef("Applied name '%s' to Nameable realm instance %s", name, realm);
//                     } else {
//                         info("Realm does not implement the %s interface.  Configured name will not be applied.",
//                                 typeid(Nameable).name);
//                     }
//                 }
//                 realms.add(realm);
//             }
//         }

//         return realms;
//     }

//     private void assertRealmSecurityManager(SecurityManager securityManager) {
//         if (securityManager  is null) {
//             throw new NullPointerException("securityManager instance cannot be null");
//         }
//         if (!(securityManager instanceof RealmSecurityManager)) {
//             string msg = "securityManager instance is not a " ~ typeid(RealmSecurityManager).name +
//                     " instance.  This is required to access or configure realms on the instance.";
//             throw new ConfigurationException(msg);
//         }
//     }

//     protected void applyRealmsToSecurityManager(Collection!(Realm) realms, SecurityManager securityManager) {
//         assertRealmSecurityManager(securityManager);
//         ((RealmSecurityManager) securityManager).setRealms(realms);
//     }

//     /**
//      * Returns {@code true} if the Ini contains account data and a {@code Realm} should be implicitly
//      * {@link #createRealm(Ini) created} to reflect the account data, {@code false} if no realm should be implicitly
//      * created.
//      *
//      * @param ini the Ini instance to inspect for account data resulting in an implicitly created realm.
//      * @return {@code true} if the Ini contains account data and a {@code Realm} should be implicitly
//      *         {@link #createRealm(Ini) created} to reflect the account data, {@code false} if no realm should be
//      *         implicitly created.
//      */
//     protected bool shouldImplicitlyCreateRealm(Ini ini) {
//         return !CollectionUtils.isEmpty(ini) &&
//                 (!CollectionUtils.isEmpty(ini.getSection(IniRealm.ROLES_SECTION_NAME)) ||
//                         !CollectionUtils.isEmpty(ini.getSection(IniRealm.USERS_SECTION_NAME)));
//     }

//     /**
//      * Creates a {@code Realm} from the Ini instance containing account data.
//      *
//      * @param ini the Ini instance from which to acquire the account data.
//      * @return a new Realm instance reflecting the account data discovered in the {@code Ini}.
//      */
//     protected Realm createRealm(Ini ini) {
//         //IniRealm realm = new IniRealm(ini); changed to support SHIRO-322
//         IniRealm realm = new IniRealm();
//         realm.setName(INI_REALM_NAME);
//         realm.setIni(ini); //added for SHIRO-322
//         return realm;
//     }

//     /**
//      * Returns the ReflectionBuilder instance used to create SecurityManagers object graph.
//      * @return ReflectionBuilder instance used to create SecurityManagers object graph.
//      * @since 1.4
//      */
//      ReflectionBuilder getReflectionBuilder() {
//         return builder;
//     }

//     /**
//      * Sets the ReflectionBuilder that will be used to create the SecurityManager based on the contents of
//      * the Ini configuration.
//      * @param builder The ReflectionBuilder used to parse the Ini configuration.
//      * @since 1.4
//      */

//      void setReflectionBuilder(ReflectionBuilder builder) {
//         this.builder = builder;
//     }
// }