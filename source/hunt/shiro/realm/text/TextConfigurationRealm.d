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
module hunt.shiro.realm.text.TextConfigurationRealm;


import hunt.shiro.authc.SimpleAccount;
import hunt.shiro.authz.permission.Permission;
import hunt.shiro.authz.SimpleRole;
import hunt.shiro.Exceptions;
import hunt.shiro.realm.SimpleAccountRealm;
import hunt.shiro.util.PermissionUtils;
import hunt.text.StringUtils;

// import java.text.ParseException;

import hunt.Exceptions;
import hunt.collection;
import hunt.logging;
import hunt.String;

import std.string;
// import java.util.Scanner;


/**
 * A SimpleAccountRealm that enables text-based configuration of the initial User, Role, and Permission objects
 * created at startup.
 * <p/>
 * Each User account definition specifies the username, password, and roles for a user.  Each Role definition
 * specifies a name and an optional collection of assigned Permissions.  Users can be assigned Roles, and Roles can be
 * assigned Permissions.  By transitive association, each User 'has' all of their Role's Permissions.
 * <p/>
 * User and user-to-role definitions are specified via the {@link #setUserDefinitions} method and
 * Role-to-permission definitions are specified via the {@link #setRoleDefinitions} method.
 *
 */
class TextConfigurationRealm : SimpleAccountRealm {

    //TODO - complete JavaDoc

    private string userDefinitions;
    private string roleDefinitions;

    this() {
        super();
    }

    /**
     * Will call 'processDefinitions' on startup.
     *
     * @see <a href="https://issues.apache.org/jira/browse/SHIRO-223">SHIRO-223</a>
     */
    override
    protected void onInit() {
        super.onInit();
        processDefinitions();
    }

     string getUserDefinitions() {
        return userDefinitions;
    }

    /**
     * <p>Sets a newline (\n) delimited string that defines user-to-password-and-role(s) key/value pairs according
     * to the following format:
     * <p/>
     * <p><code><em>username</em> = <em>password</em>, role1, role2,...</code></p>
     * <p/>
     * <p>Here are some examples of what these lines might look like:</p>
     * <p/>
     * <p><code>root = <em>reallyHardToGuessPassword</em>, administrator<br/>
     * jsmith = <em>jsmithsPassword</em>, manager, engineer, employee<br/>
     * abrown = <em>abrownsPassword</em>, qa, employee<br/>
     * djones = <em>djonesPassword</em>, qa, contractor<br/>
     * guest = <em>guestPassword</em></code></p>
     *
     * @param userDefinitions the user definitions to be parsed and converted to Map.Entry elements
     */
     void setUserDefinitions(string userDefinitions) {
        this.userDefinitions = userDefinitions;
    }

     string getRoleDefinitions() {
        return roleDefinitions;
    }

    /**
     * Sets a newline (\n) delimited string that defines role-to-permission definitions.
     * <p/>
     * <p>Each line within the string must define a role-to-permission(s) key/value mapping with the
     * equals character signifies the key/value separation, like so:</p>
     * <p/>
     * <p><code><em>rolename</em> = <em>permissionDefinition1</em>, <em>permissionDefinition2</em>, ...</code></p>
     * <p/>
     * <p>where <em>permissionDefinition</em> is an arbitrary string, but must people will want to use
     * Strings that conform to the {@link hunt.shiro.authz.permission.WildcardPermission WildcardPermission}
     * format for ease of use and flexibility.  Note that if an individual <em>permissionDefinition</em> needs to
     * be internally comma-delimited (e.g. <code>printer:5thFloor:print,info</code>), you will need to surround that
     * definition with double quotes (&quot;) to avoid parsing errors (e.g.
     * <code>&quot;printer:5thFloor:print,info&quot;</code>).
     * <p/>
     * <p><b>NOTE:</b> if you have roles that don't require permission associations, don't include them in this
     * definition - just defining the role name in the {@link #setUserDefinitions(string) userDefinitions} is
     * enough to create the role if it does not yet exist.  This property is really only for configuring realms that
     * have one or more assigned Permission.
     *
     * @param roleDefinitions the role definitions to be parsed at initialization
     */
     void setRoleDefinitions(string roleDefinitions) {
        this.roleDefinitions = roleDefinitions;
    }

    protected void processDefinitions() {
        try {
            processRoleDefinitions();
            processUserDefinitions();
        } catch (ParseException e) {
            string msg = "Unable to parse user and/or role definitions.";
            throw new ConfigurationException(msg, e);
        }
    }

    protected void processRoleDefinitions(){
        string roleDefinitions = getRoleDefinitions();
        if (roleDefinitions  is null) {
            return;
        }
        Map!(string, string) roleDefs = toMap(toLines(roleDefinitions));
        processRoleDefinitions(roleDefs);
    }

    protected void processRoleDefinitions(Map!(string, string) roleDefs) {
        if (roleDefs  is null || roleDefs.isEmpty()) {
            return;
        }
        foreach(string rolename ; roleDefs.byKey()) {
            string value = roleDefs.get(rolename);

            SimpleRole role = getRole(rolename);
            if (role  is null) {
                role = new SimpleRole(rolename);
                add(role);
            }

            Set!(Permission) permissions = PermissionUtils.resolveDelimitedPermissions(value, getPermissionResolver());
            role.setPermissions(permissions);
        }
    }

    protected void processUserDefinitions(){
        string userDefinitions = getUserDefinitions();
        if (userDefinitions  is null) {
            return;
        }

        Map!(string, string) userDefs = toMap(toLines(userDefinitions));

        processUserDefinitions(userDefs);
    }

    protected void processUserDefinitions(Map!(string, string) userDefs) {
        if (userDefs  is null || userDefs.isEmpty()) {
            return;
        }
        foreach(string username ; userDefs.byKey()) {

            string value = userDefs.get(username);
            // infof("username=%s, value=%s", username, value);

            string[] passwordAndRolesArray = split(value, ","); 
            string password = passwordAndRolesArray[0];

            SimpleAccount account = getUser(username);
            if (account is null) {
                account = new SimpleAccount(new String(username), new String(password), getName());
                add(account);
            }
            account.setCredentials(new String(password));

            if (passwordAndRolesArray.length > 1) {
                for (int i = 1; i < passwordAndRolesArray.length; i++) {
                    string rolename = passwordAndRolesArray[i].strip();
                    account.addRole(rolename);

                    // tracef("username=%s, rolename=%s", username, rolename);

                    SimpleRole role = getRole(rolename);
                    if (role !is null) {
                        account.addObjectPermissions(role.getPermissions());
                    }
                }
            } else {
                account.setRoles(null);
            }
        }
    }

    protected static Set!(string) toLines(string s) {
        LinkedHashSet!(string) set = new LinkedHashSet!(string)();
        // Scanner scanner = new Scanner(s);
        // while (scanner.hasNextLine()) {
        //     set.add(scanner.nextLine());
        // }
        implementationMissing(false);
        return set;
    }

    protected static Map!(string, string) toMap(Collection!(string) keyValuePairs){
        if (keyValuePairs  is null || keyValuePairs.isEmpty()) {
            return null;
        }

        Map!(string, string) pairs = new HashMap!(string, string)();
        foreach(string pairString ; keyValuePairs) {
            // string[] pair = StringUtils.splitKeyValue(pairString);
            // if (pair !is null) {
            //     pairs.put(pair[0].strip(), pair[1].strip());
            // }
        }

            implementationMissing(false);
        return pairs;
    }
}
