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
module hunt.shiro.realm.jdbc.JdbcRealm;

// import hunt.shiro.authc.AccountException;
// import hunt.shiro.Exceptions;
// import hunt.shiro.authc.AuthenticationInfo;
// import hunt.shiro.authc.AuthenticationToken;
// import hunt.shiro.authc.SimpleAuthenticationInfo;
// import hunt.shiro.Exceptions;
// import hunt.shiro.authc.UsernamePasswordToken;
// import hunt.shiro.Exceptions;
// import hunt.shiro.authz.AuthorizationInfo;
// import hunt.shiro.authz.SimpleAuthorizationInfo;
// import hunt.shiro.Exceptions;
// import hunt.shiro.realm.AuthorizingRealm;
// import hunt.shiro.subject.PrincipalCollection;
// import hunt.shiro.util.ByteSource;
// import hunt.shiro.util.JdbcUtils;
// import hunt.logging;

// import javax.sql.DataSource;
// import java.sql.Connection;
// import java.sql.PreparedStatement;
// import java.sql.ResultSet;
// import java.sql.SQLException;
// import hunt.collection;
// import java.util.LinkedHashSet;
// import hunt.collection.Set;


// /**
//  * Realm that allows authentication and authorization via JDBC calls.  The default queries suggest a potential schema
//  * for retrieving the user's password for authentication, and querying for a user's roles and permissions.  The
//  * default queries can be overridden by setting the query properties of the realm.
//  * <p/>
//  * If the default implementation
//  * of authentication and authorization cannot handle your schema, this class can be subclassed and the
//  * appropriate methods overridden. (usually {@link #doGetAuthenticationInfo(hunt.shiro.authc.AuthenticationToken)},
//  * {@link #getRoleNamesForUser(java.sql.Connection,string)}, and/or {@link #getPermissions(java.sql.Connection,string,java.util.Collection)}
//  * <p/>
//  * This realm supports caching by extending from {@link hunt.shiro.realm.AuthorizingRealm}.
//  *
//  */
// class JdbcRealm : AuthorizingRealm {

//     //TODO - complete JavaDoc

//     /*--------------------------------------------
//     |             C O N S T A N T S             |
//     ============================================*/
//     /**
//      * The default query used to retrieve account data for the user.
//      */
//     protected enum string DEFAULT_AUTHENTICATION_QUERY = "select password from users where username = ?";
    
//     /**
//      * The default query used to retrieve account data for the user when {@link #saltStyle} is COLUMN.
//      */
//     protected enum string DEFAULT_SALTED_AUTHENTICATION_QUERY = "select password, password_salt from users where username = ?";

//     /**
//      * The default query used to retrieve the roles that apply to a user.
//      */
//     protected enum string DEFAULT_USER_ROLES_QUERY = "select role_name from user_roles where username = ?";

//     /**
//      * The default query used to retrieve permissions that apply to a particular role.
//      */
//     protected enum string DEFAULT_PERMISSIONS_QUERY = "select permission from roles_permissions where role_name = ?";


    
//     /**
//      * Password hash salt configuration. <ul>
//      *   <li>NO_SALT - password hashes are not salted.</li>
//      *   <li>CRYPT - password hashes are stored in unix crypt format.</li>
//      *   <li>COLUMN - salt is in a separate column in the database.</li> 
//      *   <li>EXTERNAL - salt is not stored in the database. {@link #getSaltForUser(string)} will be called
//      *       to get the salt</li></ul>
//      */
//      enum SaltStyle {NO_SALT, CRYPT, COLUMN, EXTERNAL};

//     /*--------------------------------------------
//     |    I N S T A N C E   V A R I A B L E S    |
//     ============================================*/
//     protected DataSource dataSource;

//     protected string authenticationQuery = DEFAULT_AUTHENTICATION_QUERY;

//     protected string userRolesQuery = DEFAULT_USER_ROLES_QUERY;

//     protected string permissionsQuery = DEFAULT_PERMISSIONS_QUERY;

//     protected bool permissionsLookupEnabled = false;
    
//     protected SaltStyle saltStyle = SaltStyle.NO_SALT;

//     /*--------------------------------------------
//     |         C O N S T R U C T O R S           |
//     ============================================*/

//     /*--------------------------------------------
//     |  A C C E S S O R S / M O D I F I E R S    |
//     ============================================*/
    
//     /**
//      * Sets the datasource that should be used to retrieve connections used by this realm.
//      *
//      * @param dataSource the SQL data source.
//      */
//      void setDataSource(DataSource dataSource) {
//         this.dataSource = dataSource;
//     }

//     /**
//      * Overrides the default query used to retrieve a user's password during authentication.  When using the default
//      * implementation, this query must take the user's username as a single parameter and return a single result
//      * with the user's password as the first column.  If you require a solution that does not match this query
//      * structure, you can override {@link #doGetAuthenticationInfo(hunt.shiro.authc.AuthenticationToken)} or
//      * just {@link #getPasswordForUser(java.sql.Connection,string)}
//      *
//      * @param authenticationQuery the query to use for authentication.
//      * @see #DEFAULT_AUTHENTICATION_QUERY
//      */
//      void setAuthenticationQuery(string authenticationQuery) {
//         this.authenticationQuery = authenticationQuery;
//     }

//     /**
//      * Overrides the default query used to retrieve a user's roles during authorization.  When using the default
//      * implementation, this query must take the user's username as a single parameter and return a row
//      * per role with a single column containing the role name.  If you require a solution that does not match this query
//      * structure, you can override {@link #doGetAuthorizationInfo(PrincipalCollection)} or just
//      * {@link #getRoleNamesForUser(java.sql.Connection,string)}
//      *
//      * @param userRolesQuery the query to use for retrieving a user's roles.
//      * @see #DEFAULT_USER_ROLES_QUERY
//      */
//      void setUserRolesQuery(string userRolesQuery) {
//         this.userRolesQuery = userRolesQuery;
//     }

//     /**
//      * Overrides the default query used to retrieve a user's permissions during authorization.  When using the default
//      * implementation, this query must take a role name as the single parameter and return a row
//      * per permission with three columns containing the fully qualified name of the permission class, the permission
//      * name, and the permission actions (in that order).  If you require a solution that does not match this query
//      * structure, you can override {@link #doGetAuthorizationInfo(hunt.shiro.subject.PrincipalCollection)} or just
//      * {@link #getPermissions(java.sql.Connection,string,java.util.Collection)}</p>
//      * <p/>
//      * <b>Permissions are only retrieved if you set {@link #permissionsLookupEnabled} to true.  Otherwise,
//      * this query is ignored.</b>
//      *
//      * @param permissionsQuery the query to use for retrieving permissions for a role.
//      * @see #DEFAULT_PERMISSIONS_QUERY
//      * @see #setPermissionsLookupEnabled(bool)
//      */
//      void setPermissionsQuery(string permissionsQuery) {
//         this.permissionsQuery = permissionsQuery;
//     }

//     /**
//      * Enables lookup of permissions during authorization.  The default is "false" - meaning that only roles
//      * are associated with a user.  Set this to true in order to lookup roles <b>and</b> permissions.
//      *
//      * @param permissionsLookupEnabled true if permissions should be looked up during authorization, or false if only
//      *                                 roles should be looked up.
//      */
//      void setPermissionsLookupEnabled(bool permissionsLookupEnabled) {
//         this.permissionsLookupEnabled = permissionsLookupEnabled;
//     }
    
//     /**
//      * Sets the salt style.  See {@link #saltStyle}.
//      * 
//      * @param saltStyle new SaltStyle to set.
//      */
//      void setSaltStyle(SaltStyle saltStyle) {
//         this.saltStyle = saltStyle;
//         if (saltStyle == SaltStyle.COLUMN && authenticationQuery== DEFAULT_AUTHENTICATION_QUERY) {
//             authenticationQuery = DEFAULT_SALTED_AUTHENTICATION_QUERY;
//         }
//     }

//     /*--------------------------------------------
//     |               M E T H O D S               |
//     ============================================*/

//     protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token){

//         UsernamePasswordToken upToken = cast(UsernamePasswordToken) token;
//         string username = upToken.getUsername();

//         // Null username is invalid
//         if (username  is null) {
//             throw new AccountException("Null usernames are not allowed by this realm.");
//         }

//         Connection conn = null;
//         SimpleAuthenticationInfo info = null;
//         try {
//             conn = dataSource.getConnection();

//             string password = null;
//             string salt = null;
//             switch (saltStyle) {
//             case NO_SALT:
//                 password = getPasswordForUser(conn, username)[0];
//                 break;
//             case CRYPT:
//                 // TODO: separate password and hash from getPasswordForUser[0]
//                 throw new ConfigurationException("Not implemented yet");
//                 //break;
//             case COLUMN:
//                 string[] queryResults = getPasswordForUser(conn, username);
//                 password = queryResults[0];
//                 salt = queryResults[1];
//                 break;
//             case EXTERNAL:
//                 password = getPasswordForUser(conn, username)[0];
//                 salt = getSaltForUser(username);
//             }

//             if (password  is null) {
//                 throw new UnknownAccountException("No account found for user [" ~ username ~ "]");
//             }

//             info = new SimpleAuthenticationInfo(username, password.toCharArray(), getName());
            
//             if (salt !is null) {
//                 info.setCredentialsSalt(ByteSource.Util.bytes(salt));
//             }

//         } catch (SQLException e) {
//             final string message = "There was a SQL error while authenticating user [" ~ username ~ "]";
//             version(HUNT_DEBUG) {
//                 log.error(message, e);
//             }

//             // Rethrow any SQL errors as an authentication exception
//             throw new AuthenticationException(message, e);
//         } finally {
//             JdbcUtils.closeConnection(conn);
//         }

//         return info;
//     }

//     private string[] getPasswordForUser(Connection conn, string username){

//         string[] result;
//         bool returningSeparatedSalt = false;
//         switch (saltStyle) {
//         case NO_SALT:
//         case CRYPT:
//         case EXTERNAL:
//             result = new string[1];
//             break;
//         default:
//             result = new string[2];
//             returningSeparatedSalt = true;
//         }
        
//         PreparedStatement ps = null;
//         ResultSet rs = null;
//         try {
//             ps = conn.prepareStatement(authenticationQuery);
//             ps.setString(1, username);

//             // Execute query
//             rs = ps.executeQuery();

//             // Loop over results - although we are only expecting one result, since usernames should be unique
//             bool foundResult = false;
//             while (rs.next()) {

//                 // Check to ensure only one row is processed
//                 if (foundResult) {
//                     throw new AuthenticationException("More than one user row found for user [" ~ username ~ "]. Usernames must be unique.");
//                 }

//                 result[0] = rs.getString(1);
//                 if (returningSeparatedSalt) {
//                     result[1] = rs.getString(2);
//                 }

//                 foundResult = true;
//             }
//         } finally {
//             JdbcUtils.closeResultSet(rs);
//             JdbcUtils.closeStatement(ps);
//         }

//         return result;
//     }

//     /**
//      * This implementation of the interface expects the principals collection to return a string username keyed off of
//      * this realm's {@link #getName() name}
//      *
//      * @see #getAuthorizationInfo(hunt.shiro.subject.PrincipalCollection)
//      */
//     override
//     protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {

//         //null usernames are invalid
//         if (principals  is null) {
//             throw new AuthorizationException("PrincipalCollection method argument cannot be null.");
//         }

//         string username = cast(string) getAvailablePrincipal(principals);

//         Connection conn = null;
//         Set!(string) roleNames = null;
//         Set!(string) permissions = null;
//         try {
//             conn = dataSource.getConnection();

//             // Retrieve roles and permissions from database
//             roleNames = getRoleNamesForUser(conn, username);
//             if (permissionsLookupEnabled) {
//                 permissions = getPermissions(conn, username, roleNames);
//             }

//         } catch (SQLException e) {
//             final string message = "There was a SQL error while authorizing user [" ~ username ~ "]";
//             version(HUNT_DEBUG) {
//                 log.error(message, e);
//             }

//             // Rethrow any SQL errors as an authorization exception
//             throw new AuthorizationException(message, e);
//         } finally {
//             JdbcUtils.closeConnection(conn);
//         }

//         SimpleAuthorizationInfo info = new SimpleAuthorizationInfo(roleNames);
//         info.setStringPermissions(permissions);
//         return info;

//     }

//     protected Set!(string) getRoleNamesForUser(Connection conn, string username){
//         PreparedStatement ps = null;
//         ResultSet rs = null;
//         Set!(string) roleNames = new LinkedHashSet!(string)();
//         try {
//             ps = conn.prepareStatement(userRolesQuery);
//             ps.setString(1, username);

//             // Execute query
//             rs = ps.executeQuery();

//             // Loop over results and add each returned role to a set
//             while (rs.next()) {

//                 string roleName = rs.getString(1);

//                 // Add the role to the list of names if it isn't null
//                 if (roleName !is null) {
//                     roleNames.add(roleName);
//                 } else {
//                     version(HUNT_DEBUG) {
//                         warning("Null role name found while retrieving role names for user [" ~ username ~ "]");
//                     }
//                 }
//             }
//         } finally {
//             JdbcUtils.closeResultSet(rs);
//             JdbcUtils.closeStatement(ps);
//         }
//         return roleNames;
//     }

//     protected Set!(string) getPermissions(Connection conn, string username, Collection!(string) roleNames){
//         PreparedStatement ps = null;
//         Set!(string) permissions = new LinkedHashSet!(string)();
//         try {
//             ps = conn.prepareStatement(permissionsQuery);
//             foreach(string roleName ; roleNames) {

//                 ps.setString(1, roleName);

//                 ResultSet rs = null;

//                 try {
//                     // Execute query
//                     rs = ps.executeQuery();

//                     // Loop over results and add each returned role to a set
//                     while (rs.next()) {

//                         string permissionString = rs.getString(1);

//                         // Add the permission to the set of permissions
//                         permissions.add(permissionString);
//                     }
//                 } finally {
//                     JdbcUtils.closeResultSet(rs);
//                 }

//             }
//         } finally {
//             JdbcUtils.closeStatement(ps);
//         }

//         return permissions;
//     }
    
//     protected string getSaltForUser(string username) {
//         return username;
//     }

// }
