import std.stdio;

import test.shiro.authz.permission.AllPermissionTest;
import test.shiro.authz.permission.WildcardPermissionTest;
import test.shiro.subject.SimplePrincipalCollectionTest;
import test.shiro.subject.DelegatingSubjectTest;
import test.shiro.config.IniTest;


import hunt.util.UnitTest;

void main()
{
	// authz.permission
	// testUnits!(AllPermissionTest);
	testUnits!(WildcardPermissionTest);

	// testUnits!(DelegatingSubjectTest);
	// testUnits!(IniTest);
	// testUnits!(SimplePrincipalCollectionTest);
}
