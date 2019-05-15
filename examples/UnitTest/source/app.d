import std.stdio;

import test.shiro.subject.SimplePrincipalCollectionTest;
import test.shiro.subject.DelegatingSubjectTest;
import test.shiro.config.IniTest;


import hunt.util.UnitTest;

void main()
{

	testUnits!(DelegatingSubjectTest);
	// testUnits!(IniTest);
	// testUnits!(SimplePrincipalCollectionTest);
}
