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
module hunt.shiro.jndi.JndiLocator;

import java.util.Properties;
import javax.naming.NamingException;

import hunt.logger;
import hunt.loggerFactory;

/**
 * Convenient superclass for JNDI accessors, providing "jndiTemplate"
 * and "jndiEnvironment" bean properties.
 *
 * <p>Note that this implementation is an almost exact combined copy of the Spring Framework's 'JndiAccessor' and
 * 'JndiLocatorSupport' classes from their 2.5.4 distribution - we didn't want to re-invent the wheel, but not require
 * a full dependency on the Spring framework, nor does Spring make available only its JNDI classes in a small jar, or
 * we would have used that. Since Shiro is also Apache 2.0 licensed, all regular licenses and conditions and
 * authors have remained in tact.
 *
 * @see #setJndiTemplate
 * @see #setJndiEnvironment
 * @see #setResourceRef
 * @since 1.1
 */
class JndiLocator {

    /**
     * Private class log.
     */


    /**
     * JNDI prefix used in a J2EE container
     */
     enum string CONTAINER_PREFIX = "java:comp/env/";

    private bool resourceRef = false;

    private JndiTemplate jndiTemplate = new JndiTemplate();


    /**
     * Set the JNDI template to use for JNDI lookups.
     * <p>You can also specify JNDI environment settings via "jndiEnvironment".
     *
     * @see #setJndiEnvironment
     */
     void setJndiTemplate(JndiTemplate jndiTemplate) {
        this.jndiTemplate = (jndiTemplate != null ? jndiTemplate : new JndiTemplate());
    }

    /**
     * Return the JNDI template to use for JNDI lookups.
     */
     JndiTemplate getJndiTemplate() {
        return this.jndiTemplate;
    }

    /**
     * Set the JNDI environment to use for JNDI lookups.
     * <p>Creates a JndiTemplate with the given environment settings.
     *
     * @see #setJndiTemplate
     */
     void setJndiEnvironment(Properties jndiEnvironment) {
        this.jndiTemplate = new JndiTemplate(jndiEnvironment);
    }

    /**
     * Return the JNDI environment to use for JNDI lookups.
     */
     Properties getJndiEnvironment() {
        return this.jndiTemplate.getEnvironment();
    }

    /**
     * Set whether the lookup occurs in a J2EE container, i.e. if the prefix
     * "java:comp/env/" needs to be added if the JNDI name doesn't already
     * contain it. Default is "false".
     * <p>Note: Will only get applied if no other scheme (e.g. "java:") is given.
     */
     void setResourceRef(bool resourceRef) {
        this.resourceRef = resourceRef;
    }

    /**
     * Return whether the lookup occurs in a J2EE container.
     */
     bool isResourceRef() {
        return this.resourceRef;
    }


    /**
     * Perform an actual JNDI lookup for the given name via the JndiTemplate.
     * <p>If the name doesn't begin with "java:comp/env/", this prefix is added
     * if "resourceRef" is set to "true".
     *
     * @param jndiName the JNDI name to look up
     * @return the obtained object
     * @throws javax.naming.NamingException if the JNDI lookup failed
     * @see #setResourceRef
     */
    protected Object lookup(string jndiName){
        return lookup(jndiName, null);
    }

    /**
     * Perform an actual JNDI lookup for the given name via the JndiTemplate.
     * <p>If the name doesn't begin with "java:comp/env/", this prefix is added
     * if "resourceRef" is set to "true".
     *
     * @param jndiName     the JNDI name to look up
     * @param requiredType the required type of the object
     * @return the obtained object
     * @throws NamingException if the JNDI lookup failed
     * @see #setResourceRef
     */
    protected Object lookup(string jndiName, Class requiredType){
        if (jndiName  is null) {
            throw new IllegalArgumentException("jndiName argument must not be null");
        }
        string convertedName = convertJndiName(jndiName);
        Object jndiObject;
        try {
            jndiObject = getJndiTemplate().lookup(convertedName, requiredType);
        }
        catch (NamingException ex) {
            if (!convertedName== jndiName) {
                // Try fallback to originally specified name...
                if (log.isDebugEnabled()) {
                    tracef("Converted JNDI name [" ~ convertedName +
                            "] not found - trying original name [" ~ jndiName ~ "]. " ~ ex);
                }
                jndiObject = getJndiTemplate().lookup(jndiName, requiredType);
            } else {
                throw ex;
            }
        }
        tracef("Located object with JNDI name '{}'", convertedName);
        return jndiObject;
    }

    /**
     * Convert the given JNDI name into the actual JNDI name to use.
     * <p>The default implementation applies the "java:comp/env/" prefix if
     * "resourceRef" is "true" and no other scheme (e.g. "java:") is given.
     *
     * @param jndiName the original JNDI name
     * @return the JNDI name to use
     * @see #CONTAINER_PREFIX
     * @see #setResourceRef
     */
    protected string convertJndiName(string jndiName) {
        // Prepend container prefix if not already specified and no other scheme given.
        if (isResourceRef() && !jndiName.startsWith(CONTAINER_PREFIX) && jndiName.indexOf(':') == -1) {
            jndiName = CONTAINER_PREFIX + jndiName;
        }
        return jndiName;
    }

}
