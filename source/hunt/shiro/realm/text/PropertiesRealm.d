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
module hunt.shiro.realm.text.PropertiesRealm;

import hunt.shiro.ShiroException;
import hunt.shiro.io.ResourceUtils;
import hunt.shiro.util.Destroyable;
import hunt.logger;
import hunt.loggerFactory;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * A {@link TextConfigurationRealm} that defers all logic to the parent class, but just enables
 * {@link java.util.Properties Properties} based configuration in addition to the parent class's string configuration.
 * <p/>
 * This class allows processing of a single .properties file for user, role, and
 * permission configuration.
 * <p/>
 * The {@link #setResourcePath resourcePath} <em>MUST</em> be set before this realm can be initialized.  You
 * can specify any resource path supported by
 * {@link ResourceUtils#getInputStreamForPath(string) ResourceUtils.getInputStreamForPath} method.
 * <p/>
 * The Properties format understood by this implementation must be written as follows:
 * <p/>
 * Each line's key/value pair represents either a user-to-role(s) mapping <em>or</em> a role-to-permission(s)
 * mapping.
 * <p/>
 * The user-to-role(s) lines have this format:</p>
 * <p/>
 * <code><b>user.</b><em>username</em> = <em>password</em>,role1,role2,...</code></p>
 * <p/>
 * Note that each key is prefixed with the token <b>{@code user.}</b>  Each value must adhere to the
 * the {@link #setUserDefinitions(string) setUserDefinitions(string)} JavaDoc.
 * <p/>
 * The role-to-permission(s) lines have this format:</p>
 * <p/>
 * <code><b>role.</b><em>rolename</em> = <em>permissionDefinition1</em>, <em>permissionDefinition2</em>, ...</code>
 * <p/>
 * where each key is prefixed with the token <b>{@code role.}</b> and the value adheres to the format specified in
 * the {@link #setRoleDefinitions(string) setRoleDefinitions(string)} JavaDoc.
 * <p/>
 * Here is an example of a very simple properties definition that conforms to the above format rules and corresponding
 * method JavaDocs:
 * <p/>
 * <code>user.root = <em>rootPassword</em>,administrator<br/>
 * user.jsmith = <em>jsmithPassword</em>,manager,engineer,employee<br/>
 * user.abrown = <em>abrownPassword</em>,qa,employee<br/>
 * user.djones = <em>djonesPassword</em>,qa,contractor<br/>
 * <br/>
 * role.administrator = *<br/>
 * role.manager = &quot;user:read,write&quot;, file:execute:/usr/local/emailManagers.sh<br/>
 * role.engineer = &quot;file:read,execute:/usr/local/tomcat/bin/startup.sh&quot;<br/>
 * role.employee = application:use:wiki<br/>
 * role.qa = &quot;server:view,start,shutdown,restart:someQaServer&quot;, server:view:someProductionServer<br/>
 * role.contractor = application:use:timesheet</code>
 *
 * @since 0.2
 */
class PropertiesRealm : TextConfigurationRealm implements Destroyable, Runnable {

    //TODO - complete JavaDoc

    /*-------------------------------------------
    |             C O N S T A N T S             |
    ============================================*/
    private enum int DEFAULT_RELOAD_INTERVAL_SECONDS = 10;
    private enum string USERNAME_PREFIX = "user.";
    private enum string ROLENAME_PREFIX = "role.";
    private enum string DEFAULT_RESOURCE_PATH = "classpath:shiro-users.properties";

    /*-------------------------------------------
    |    I N S T A N C E   V A R I A B L E S    |
    ============================================*/


    protected ExecutorService scheduler = null;
    protected bool useXmlFormat = false;
    protected string resourcePath = DEFAULT_RESOURCE_PATH;
    protected long fileLastModified;
    protected int reloadIntervalSeconds = DEFAULT_RELOAD_INTERVAL_SECONDS;

     PropertiesRealm() {
        super();
    }

    /*--------------------------------------------
    |  A C C E S S O R S / M O D I F I E R S    |
    ============================================*/

    /**
     * Determines whether or not the properties XML format should be used.  For more information, see
     * {@link Properties#loadFromXML(java.io.InputStream)}
     *
     * @param useXmlFormat true to use XML or false to use the normal format.  Defaults to false.
     */
     void setUseXmlFormat(bool useXmlFormat) {
        this.useXmlFormat = useXmlFormat;
    }

    /**
     * Sets the path of the properties file to load user, role, and permission information from.  The properties
     * file will be loaded using {@link ResourceUtils#getInputStreamForPath(string)} so any convention recognized
     * by that method is accepted here.  For example, to load a file from the classpath use
     * {@code classpath:myfile.properties}; to load a file from disk simply specify the full path; to load
     * a file from a URL use {@code url:www.mysite.com/myfile.properties}.
     *
     * @param resourcePath the path to load the properties file from.  This is a required property.
     */
     void setResourcePath(string resourcePath) {
        this.resourcePath = resourcePath;
    }

    /**
     * Sets the interval in seconds at which the property file will be checked for changes and reloaded.  If this is
     * set to zero or less, property file reloading will be disabled.  If it is set to 1 or greater, then a
     * separate thread will be created to monitor the property file for changes and reload the file if it is updated.
     *
     * @param reloadIntervalSeconds the interval in seconds at which the property file should be examined for changes.
     *                              If set to zero or less, reloading is disabled.
     */
     void setReloadIntervalSeconds(int reloadIntervalSeconds) {
        this.reloadIntervalSeconds = reloadIntervalSeconds;
    }

    /*--------------------------------------------
    |               M E T H O D S               |
    ============================================*/

    override
     void onInit() {
        super.onInit();
        //TODO - cleanup - this method shouldn't be necessary
        afterRoleCacheSet();
    }

    protected void afterRoleCacheSet() {
        loadProperties();
        //we can only determine if files have been modified at runtime (not classpath entries or urls), so only
        //start the thread in this case:
        if (this.resourcePath.startsWith(ResourceUtils.FILE_PREFIX) && scheduler  is null) {
            startReloadThread();
        }
    }

    /**
     * Destroy reload scheduler if one exists.
     */
     void destroy() {
        try {
            if (scheduler != null) {
                scheduler.shutdown();
            }
        } catch (Exception e) {
            if (log.isInfoEnabled()) {
                info("Unable to cleanly shutdown Scheduler.  Ignoring (shutting down)...", e);
            }
        } finally {
            scheduler = null;
        }
    }

    protected void startReloadThread() {
        if (this.reloadIntervalSeconds > 0) {
            this.scheduler = Executors.newSingleThreadScheduledExecutor();
            ((ScheduledExecutorService) this.scheduler).scheduleAtFixedRate(this, reloadIntervalSeconds, reloadIntervalSeconds, TimeUnit.SECONDS);
        }
    }

     void run() {
        try {
            reloadPropertiesIfNecessary();
        } catch (Exception e) {
            if (log.isErrorEnabled()) {
                log.error("Error while reloading property files for realm.", e);
            }
        }
    }

    private void loadProperties() {
        if (resourcePath  is null || resourcePath.length() == 0) {
            throw new IllegalStateException("The resourcePath property is not set.  " ~
                    "It must be set prior to this realm being initialized.");
        }

        if (log.isDebugEnabled()) {
            tracef("Loading user security information from file [" ~ resourcePath ~ "]...");
        }

        Properties properties = loadProperties(resourcePath);
        createRealmEntitiesFromProperties(properties);
    }

    private Properties loadProperties(string resourcePath) {
        Properties props = new Properties();

        InputStream is = null;
        try {

            if (log.isDebugEnabled()) {
                tracef("Opening input stream for path [" ~ resourcePath ~ "]...");
            }

            is = ResourceUtils.getInputStreamForPath(resourcePath);
            if (useXmlFormat) {

                if (log.isDebugEnabled()) {
                    tracef("Loading properties from path [" ~ resourcePath ~ "] in XML format...");
                }

                props.loadFromXML(is);
            } else {

                if (log.isDebugEnabled()) {
                    tracef("Loading properties from path [" ~ resourcePath ~ "]...");
                }

                props.load(is);
            }

        } catch (IOException e) {
            throw new ShiroException("Error reading properties path [" ~ resourcePath ~ "].  " ~
                    "Initializing of the realm from this file failed.", e);
        } finally {
            ResourceUtils.close(is);
        }

        return props;
    }


    private void reloadPropertiesIfNecessary() {
        if (isSourceModified()) {
            restart();
        }
    }

    private bool isSourceModified() {
        //we can only check last modified times on files - classpath and URL entries can't tell us modification times
        return this.resourcePath.startsWith(ResourceUtils.FILE_PREFIX) && isFileModified();
    }

    private bool isFileModified() {
        //SHIRO-394: strip file prefix before constructing the File instance:
        string fileNameWithoutPrefix = this.resourcePath.substring(this.resourcePath.indexOf(":") + 1);
        File propertyFile = new File(fileNameWithoutPrefix);
        long currentLastModified = propertyFile.lastModified();
        if (currentLastModified > this.fileLastModified) {
            this.fileLastModified = currentLastModified;
            return true;
        } else {
            return false;
        }
    }


    private void restart() {
        if (resourcePath  is null || resourcePath.length() == 0) {
            throw new IllegalStateException("The resourcePath property is not set.  " ~
                    "It must be set prior to this realm being initialized.");
        }

        if (log.isDebugEnabled()) {
            tracef("Loading user security information from file [" ~ resourcePath ~ "]...");
        }

        try {
            destroy();
        } catch (Exception e) {
            //ignored
        }
        init();
    }


    private void createRealmEntitiesFromProperties(Properties properties) {

        StringBuilder userDefs = new StringBuilder();
        StringBuilder roleDefs = new StringBuilder();

        Enumeration!(string) propNames = (Enumeration!(string)) properties.propertyNames();

        while (propNames.hasMoreElements()) {

            string key = propNames.nextElement().trim();
            string value = properties.getProperty(key).trim();
            if (log.isTraceEnabled()) {
                log.trace("Processing properties line - key: [" ~ key ~ "], value: [" ~ value ~ "].");
            }

            if (isUsername(key)) {
                string username = getUsername(key);
                userDefs.append(username).append(" = ").append(value).append("\n");
            } else if (isRolename(key)) {
                string rolename = getRolename(key);
                roleDefs.append(rolename).append(" = ").append(value).append("\n");
            } else {
                string msg = "Encountered unexpected key/value pair.  All keys must be prefixed with either '" ~
                        USERNAME_PREFIX ~ "' or '" ~ ROLENAME_PREFIX ~ "'.";
                throw new IllegalStateException(msg);
            }
        }

        setUserDefinitions(userDefs.toString());
        setRoleDefinitions(roleDefs.toString());
        processDefinitions();
    }

    protected string getName(string key, string prefix) {
        return key.substring(prefix.length(), key.length());
    }

    protected bool isUsername(string key) {
        return key != null && key.startsWith(USERNAME_PREFIX);
    }

    protected bool isRolename(string key) {
        return key != null && key.startsWith(ROLENAME_PREFIX);
    }

    protected string getUsername(string key) {
        return getName(key, USERNAME_PREFIX);
    }

    protected string getRolename(string key) {
        return getName(key, ROLENAME_PREFIX);
    }
}
