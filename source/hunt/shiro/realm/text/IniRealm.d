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
module hunt.shiro.realm.text.IniRealm;

import hunt.shiro.realm.text.TextConfigurationRealm;

import hunt.shiro.config.Ini;
import hunt.shiro.util.CollectionUtils;
// import hunt.shiro.util.StringUtils;
import hunt.logging.ConsoleLogger;
import hunt.util.Configuration;

import hunt.Exceptions;
import std.array;

/**
 * A {@link hunt.shiro.realm.Realm Realm} implementation that creates
 * {@link hunt.shiro.authc.SimpleAccount SimpleAccount} instances based on
 * {@link Ini} configuration.
 * <p/>
 * This implementation looks for two {@link Ini.Section sections} in the {@code Ini} configuration:
 * <pre>
 * [users]
 * # One or more {@link hunt.shiro.realm.text.TextConfigurationRealm#setUserDefinitions(string) user definitions}
 * ...
 * [roles]
 * # One or more {@link hunt.shiro.realm.text.TextConfigurationRealm#setRoleDefinitions(string) role definitions}</pre>
 * <p/>
 * This class also supports setting the {@link #setResourcePath(string) resourcePath} property to create account
 * data from an .ini resource.  This will only be used if there isn't already account data in the Realm.
 *
 */
class IniRealm : TextConfigurationRealm {

    enum string USERS_SECTION_NAME = "users";
    enum string ROLES_SECTION_NAME = "roles";


    private string resourcePath;
    private Ini ini; //reference added in 1.2 for SHIRO-322

    this() {
        super();
    }

    /**
     * This constructor will immediately process the definitions in the {@code Ini} argument.  If you need to perform
     * additional configuration before processing (e.g. setting a permissionResolver, etc), do not call this
     * constructor.  Instead, do the following:
     * <ol>
     * <li>Call the default no-arg constructor</li>
     * <li>Set the Ini instance you wish to use via {@code #setIni}</li>
     * <li>Set any other configuration properties</li>
     * <li>Call {@link #init()}</li>
     * </ol>
     *
     * @param ini the Ini instance which will be inspected to create accounts, groups and permissions for this realm.
     */
     this(Ini ini) {
        this();
        processDefinitions(ini);
    }

    /**
     * This constructor will immediately process the definitions in the {@code Ini} resolved from the specified
     * {@code resourcePath}.  If you need to perform additional configuration before processing (e.g. setting a
     * permissionResolver, etc), do not call this constructor.  Instead, do the following:
     * <ol>
     * <li>Call the default no-arg constructor</li>
     * <li>Set the Ini instance you wish to use via {@code #setIni}</li>
     * <li>Set any other configuration properties</li>
     * <li>Call {@link #init()}</li>
     * </ol>
     *
     * @param resourcePath the resource path of the Ini config which will be inspected to create accounts, groups and
     *                     permissions for this realm.
     */
     this(string resourcePath) {
        this();
        Ini ini = Ini.fromResourcePath(resourcePath);
        this.ini = ini;
        this.resourcePath = resourcePath;
        processDefinitions(ini);
    }

     string getResourcePath() {
        return resourcePath;
    }

     void setResourcePath(string resourcePath) {
        this.resourcePath = resourcePath;
    }

    /**
     * Returns the Ini instance used to configure this realm.  Provided for JavaBeans-style configuration of this
     * realm, particularly useful in Dependency Injection environments.
     * 
     * @return the Ini instance which will be inspected to create accounts, groups and permissions for this realm.
     */
     Ini getIni() {
        return ini;
    }

    /**
     * Sets the Ini instance used to configure this realm.  Provided for JavaBeans-style configuration of this
     * realm, particularly useful in Dependency Injection environments.
     * 
     * @param ini the Ini instance which will be inspected to create accounts, groups and permissions for this realm.
     */
     void setIni(Ini ini) {
        this.ini = ini;
    }

    override
    protected void onInit() {
        super.onInit();

        // This is an in-memory realm only - no need for an additional cache when we're already
        // as memory-efficient as we can be.
        
        Ini ini = getIni();
        string resourcePath = getResourcePath();
                
        if (!CollectionUtils.isEmpty(this.users) || !CollectionUtils.isEmpty(this.roles)) {
            if (ini !is null && !ini.isEmpty()) {
                warning("Users or Roles are already populated.  Configured Ini instance will be ignored.");
            }
            if (!resourcePath.empty()) {
                warning("Users or Roles are already populated.  resourcePath '%s' will be ignored.", resourcePath);
            }
            
            tracef("Instance is already populated with users or roles.  No additional user/role population " ~
                    "will be performed.");
            return;
        }
        
        if (ini is null || ini.isEmpty()) {
            tracef("No INI instance configuration present.  Checking resourcePath...");
            
            if (!resourcePath.empty()) {
                tracef("Resource path %s defined.  Creating INI instance.", resourcePath);
                ini = Ini.fromResourcePath(resourcePath);
                if (ini !is null && !ini.isEmpty()) {
                    setIni(ini);
                }
            }
        }
        
        if (ini is null || ini.isEmpty()) {
            string msg = "Ini instance and/or resourcePath resulted in null or empty Ini configuration.  Cannot " ~
                    "load account data.";
            throw new IllegalStateException(msg);
        }

        processDefinitions(ini);
    }

    private void processDefinitions(Ini ini) {

        implementationMissing(false);
        
        // if (CollectionUtils.isEmpty(ini)) {
        //     warning("%s defined, but the ini instance is null or empty.", getClass().getSimpleName());
        //     return;
        // }

        // Ini.Section rolesSection = ini.getSection(ROLES_SECTION_NAME);
        // if (!CollectionUtils.isEmpty(rolesSection)) {
        //     tracef("Discovered the [%s] section.  Processing...", ROLES_SECTION_NAME);
        //     processRoleDefinitions(rolesSection);
        // }

        // Ini.Section usersSection = ini.getSection(USERS_SECTION_NAME);
        // if (!CollectionUtils.isEmpty(usersSection)) {
        //     tracef("Discovered the [%s] section.  Processing...", USERS_SECTION_NAME);
        //     processUserDefinitions(usersSection);
        // } else {
        //     info("%s defined, but there is no [%s] section defined.  This realm will not be populated with any " ~
        //             "users and it is assumed that they will be populated programatically.  Users must be defined " ~
        //             "for this Realm instance to be useful.", getClass().getSimpleName(), USERS_SECTION_NAME);
        // }
    }
}
