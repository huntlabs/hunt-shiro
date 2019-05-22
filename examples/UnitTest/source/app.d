import std.stdio;

import test.shiro.authz.permission.AllPermissionTest;
import test.shiro.authz.permission.WildcardPermissionTest;
import test.shiro.config.IniTest;

import test.shiro.mgt.DefaultSecurityManagerTest;
import test.shiro.mgt.SingletonDefaultSecurityManagerTest;

import test.shiro.realm.AuthorizingRealmTest;

import test.shiro.subject.SimplePrincipalCollectionTest;
import test.shiro.subject.DelegatingSubjectTest;

import test.shiro.session.mgt.DefaultSessionManagerTest;


import hunt.util.UnitTest;

void main()
{
	// authz.permission
	// testUnits!(AllPermissionTest);
	// testUnits!(WildcardPermissionTest);



	// testUnits!(DelegatingSubjectTest);
	// testUnits!(IniTest);

	// mgt
	testUnits!(DefaultSecurityManagerTest);
	// testUnits!(SingletonDefaultSecurityManagerTest);

	// testUnits!(SimplePrincipalCollectionTest);

	// testUnits!(AuthorizingRealmTest);

	// testUnits!(DefaultSessionManagerTest);
}
