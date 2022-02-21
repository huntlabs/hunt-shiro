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
module test.shiro.realm.AuthorizingRealmTest;

import test.shiro.realm.UsernamePrincipal;
import test.shiro.realm.UserIdPrincipal;

import hunt.shiro.authc;
import hunt.shiro.authc.credential.AllowAllCredentialsMatcher;
import hunt.shiro.authz.AuthorizationInfo;
import hunt.shiro.authz.permission.Permission;
import hunt.shiro.authz.SimpleAuthorizationInfo;
import hunt.shiro.authz.permission.RolePermissionResolver;
import hunt.shiro.authz.permission.WildcardPermission;
import hunt.shiro.Exceptions;
import hunt.shiro.realm.AuthorizingRealm;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.PrincipalCollectionHelper;
import hunt.shiro.subject.SimplePrincipalCollection;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.Logger;
import hunt.String;
import hunt.Byte;
import hunt.security.Principal;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.thread;
import core.time;
import std.conv;


private enum string USERNAME = "testuser";
private enum string PASSWORD = "password";
private enum int USER_ID = 12345;
private enum string ROLE = "admin";
private string localhost = "localhost";

/**
 * Simple test case for AuthorizingRealm.
 * <p/>
 * TODO - this could/should be expanded to be more robust end to end test for the AuthorizingRealm
 */
class AuthorizingRealmTest {

    AuthorizingRealm realm;

    @Before
    void setup() {
        realm = new AllowAllRealm();
    }

    @After
    void tearDown() {
        realm = null;
    }

    @Test
    void testDefaultConfig() {
        AuthenticationInfo info = realm.getAuthenticationInfo(new UsernamePasswordToken(USERNAME, PASSWORD, localhost));

        assertNotNull(info);
        assertTrue(realm.hasRole(info.getPrincipals(), ROLE));

        Object principal = info.getPrincipals().getPrimaryPrincipal();
        UserIdPrincipal up = cast(UserIdPrincipal)principal; 
        assertTrue(up !is null);

        PrincipalCollection pc = info.getPrincipals();
        SimplePrincipalCollection spc = cast(SimplePrincipalCollection)pc;

        UsernamePrincipal usernamePrincipal = spc.oneByType!(UsernamePrincipal)();
        assertTrue(usernamePrincipal.getUsername() == USERNAME);

        usernamePrincipal = PrincipalCollectionHelper.oneByType!(UsernamePrincipal)(pc);
        assertTrue(usernamePrincipal.getUsername() == USERNAME);

        UserIdPrincipal userIdPrincipal = spc.oneByType!(UserIdPrincipal)();
        assertTrue(userIdPrincipal.getUserId() == USER_ID);

        userIdPrincipal = pc.oneByType!(UserIdPrincipal)();
        assertTrue(userIdPrincipal.getUserId() == USER_ID);

        String stringPrincipal = spc.oneByType!(String)();
        assertTrue(stringPrincipal.value == USER_ID.to!string() ~ USERNAME);
    }

    @Test
    void testCreateAccountOverride() {

        AuthorizingRealm realm = new class AllowAllRealm {
            override 
            protected AuthenticationInfo buildAuthenticationInfo(string principal, char[] credentials) {
                string username = principal;
                UsernamePrincipal customPrincipal = new UsernamePrincipal(username);
                Bytes bs = new Bytes(cast(byte[])credentials);
                return new SimpleAccount(customPrincipal, bs, getName());
            }
        };

        AuthenticationInfo info = realm.getAuthenticationInfo(new UsernamePasswordToken(USERNAME, PASSWORD, localhost));
        assertNotNull(info);
        assertTrue(realm.hasRole(info.getPrincipals(), ROLE));
        Object principal = info.getPrincipals().getPrimaryPrincipal();
        UsernamePrincipal up = cast(UsernamePrincipal)principal;
        assertTrue(up !is null);
        assertEquals(USERNAME, up.getUsername());
    }

    @Test
    void testNullAuthzInfo() {
	        AuthorizingRealm realm = new class AuthorizingRealm {
            override protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
                return null;
            }

            override protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) {
                return null;
            }
        };

        Principal principal = new UsernamePrincipal("blah");
        PrincipalCollection pCollection = new SimplePrincipalCollection(cast(Object)principal, "nullAuthzRealm");
        List!(Permission) permList = new ArrayList!(Permission)();
        permList.add(new WildcardPermission("stringPerm1"));
        permList.add(new WildcardPermission("stringPerm2"));
        List!(string) roleList = new ArrayList!(string)();
        roleList.add("role1");
        roleList.add("role2");

        bool thrown = false;
        try {
            realm.checkPermission(pCollection, "stringPermission");
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);
        thrown = false;

        try {
            realm.checkPermission(pCollection, new WildcardPermission("stringPermission"));
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);
        thrown = false;

        try {
            realm.checkPermissions(pCollection, "stringPerm1", "stringPerm2");
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);
        thrown = false;

        try {
            realm.checkPermissions(pCollection, permList);
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);
        thrown = false;

        try {
            realm.checkRole(pCollection, "role1");
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);
        thrown = false;

        try {
            realm.checkRoles(pCollection, roleList);
        } catch (UnauthorizedException e) {
            thrown = true;
        }
        assertTrue(thrown);

        assertFalse(realm.hasAllRoles(pCollection, roleList));
        assertFalse(realm.hasRole(pCollection, "role1"));
        assertArrayEquals([false, false], realm.hasRoles(pCollection, roleList));
        assertFalse(realm.isPermitted(pCollection, "perm1"));
        assertFalse(realm.isPermitted(pCollection, new WildcardPermission("perm1")));
        assertArrayEquals([false, false], realm.isPermitted(pCollection, "perm1", "perm2"));
        assertArrayEquals([false, false], realm.isPermitted(pCollection, permList));
        assertFalse(realm.isPermittedAll(pCollection, "perm1", "perm2"));
        assertFalse(realm.isPermittedAll(pCollection, permList));
    }
    
    @Test
    void testRealmWithRolePermissionResolver()
    {   
        Principal principal = new UsernamePrincipal("rolePermResolver");
        PrincipalCollection pCollection = new SimplePrincipalCollection(cast(Object) principal, 
            "testRealmWithRolePermissionResolver");
        
        AuthorizingRealm realm = new AllowAllRealm();
        realm.setRolePermissionResolver( new class RolePermissionResolver { 

            Collection!(Permission) resolvePermissionsInRole(string roleString )
            {
                Collection!(Permission) permissions = new HashSet!(Permission)();
                if( roleString ==  ROLE)
                {
                    permissions.add( new WildcardPermission( ROLE ~ ":perm1" ) );
                    permissions.add( new WildcardPermission( ROLE ~ ":perm2" ) );
                    permissions.add( new WildcardPermission( "other:*:foo" ) );
                }
                return permissions;
            }
        });
        
        assertTrue( realm.hasRole( pCollection, ROLE ) );
        assertTrue( realm.isPermitted( pCollection, ROLE ~ ":perm1" ) );
        assertTrue( realm.isPermitted( pCollection, ROLE ~ ":perm2" ) );
        assertFalse( realm.isPermitted( pCollection, ROLE ~ ":perm3" ) );
        assertTrue( realm.isPermitted( pCollection, "other:bar:foo" ) );
    }

    // private void assertArrayEquals(bool[] expected, bool[] actual) {
    //     if (expected.length != actual.length) {
    //         fail("Expected array of length [" ~ expected.length ~ "] but received array of length [" ~ actual.length ~ "]");
    //     }
    //     for (int i = 0; i < expected.length; i++) {
    //         if (expected[i] != actual[i]) {
    //             fail("Expected index [" ~ i ~ "] to be [" ~ expected[i] ~ "] but was [" ~ actual[i] ~ "]");
    //         }
    //     }
    // }

}


class AllowAllRealm : AuthorizingRealm {

    this() {
        super();
        setCredentialsMatcher(new AllowAllCredentialsMatcher());
    }

    override protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) {
        return buildAuthenticationInfo(token.getPrincipal(), token.getCredentials());
    }

    override protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        Set!(string) roles = new HashSet!(string)();
        roles.add(ROLE);
        return new SimpleAuthorizationInfo(roles);
    }

    protected AuthenticationInfo buildAuthenticationInfo(string principal, char[] credentials) {
        Collection!(Object) principals = new ArrayList!(Object)(3);
        principals.add(new UserIdPrincipal(USER_ID));
        principals.add(new UsernamePrincipal(USERNAME));
        principals.add(new String(USER_ID.to!string() ~ USERNAME));
        return new SimpleAuthenticationInfo(cast(Object)principals, new String(PASSWORD), getName());
    }

}