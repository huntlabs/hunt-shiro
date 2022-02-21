import std.stdio;

import hunt.shiro.authc.UsernamePasswordToken;
import hunt.shiro.authz.AuthorizationInfo;
import hunt.shiro.cache.MemoryConstrainedCacheManager;
import hunt.shiro.config.Ini;
import hunt.shiro.config.IniFactorySupport;
import hunt.shiro.config.IniSecurityManagerFactory;
import hunt.shiro.Exceptions;
import hunt.shiro.mgt.CachingSecurityManager;
import hunt.shiro.mgt.DefaultSecurityManager;
import hunt.shiro.mgt.RealmSecurityManager;
import hunt.shiro.mgt.SecurityManager;
import hunt.shiro.SecurityUtils;
import hunt.shiro.session.Session;
import hunt.shiro.session.mgt.DefaultSessionContext;
import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.SimplePrincipalCollection;
import hunt.shiro.subject.support.DelegatingSubject;
import hunt.shiro.subject.Subject;
import hunt.shiro.util.AbstractFactory;
import hunt.shiro.util.LifecycleUtils;
import hunt.shiro.util.ThreadContext;

import hunt.shiro.realm.CachingRealm;
import hunt.shiro.realm.Realm;

import hunt.Exceptions;
import hunt.logging.Logger;
import hunt.String;

void main()
{
	// The easiest way to create a Shiro SecurityManager with configured
	// realms, users, roles and permissions is to use the simple INI config.
	// We'll do that by using a factory that can ingest a .ini file and
	// return a SecurityManager instance:

	// Use the shiro.ini file at the root of the classpath
	// (file: and url: prefixes load from files and urls respectively):
	Factory!SecurityManager factory = new IniSecurityManagerFactory("resources/shiro.ini");
	SecurityManager securityManager = factory.getInstance();

	CachingSecurityManager csm = cast(CachingSecurityManager)securityManager;
	auto cm = new MemoryConstrainedCacheManager!(Object, AuthorizationInfo)();
	csm.setCacheManager(cm);


    RealmSecurityManager rsm = cast(RealmSecurityManager)securityManager;
	Realm rm = rsm.getRealms().toArray()[0];
	CachingRealm cr = cast(CachingRealm)rm;
	cr.setCachingEnabled(true);
	

	string HOST = typeid(DefaultSessionContext).name ~ ".HOST";

	// for this simple example quickstart, make the SecurityManager
	// accessible as a JVM singleton.  Most applications wouldn't do this
	// and instead rely on their container configuration or web.xml for
	// webapps.  That is outside the scope of this simple quickstart, so
	// we'll just do the bare minimum so you can continue to get a feel
	// for things.
	SecurityUtils.setSecurityManager(securityManager);

	// Now that a simple Shiro environment is set up, let's see what you can do:

	// get the currently executing user:
	Subject currentUser = SecurityUtils.getSubject();

	// Do some stuff with a Session (no need for a web or EJB container!!!)
	Session session = currentUser.getSession();
	session.setAttribute("someKey", "aValue");
	string value = (cast(String) session.getAttribute("someKey")).value;
	if (value == "aValue") {
		info("Retrieved the correct value! [" ~ value ~ "]");
	}

	// let's login the current user so we can check against roles and permissions:
	if (!currentUser.isAuthenticated()) {
		UsernamePasswordToken token = new UsernamePasswordToken("lonestarr", "vespa");
		token.setRememberMe(true);
		try {
			currentUser.login(token);
		} catch (UnknownAccountException uae) {
			info("There is no user with username of " ~ token.getPrincipal());
		} catch (IncorrectCredentialsException ice) {
			info("Password for account " ~ token.getPrincipal() ~ " was incorrect!");
		} catch (LockedAccountException lae) {
			info("The account for username " ~ token.getPrincipal() ~ " is locked.  " ~
					"Please contact your administrator to unlock it.");
		}
		// ... catch more exceptions here (maybe custom ones specific to your application?
		catch (AuthenticationException ae) {
			//unexpected condition?  error?
			warning(ae);
		}
	}

	//say who they are:
	//print their identifying principal (in this case, a username):
	info("User [" ~ currentUser.getPrincipal().toString() ~ "] logged in successfully.");

	//test a role:
	if (currentUser.hasRole("schwartz")) {
		info("May the Schwartz be with you!");
	} else {
		info("Hello, mere mortal.");
	}

	//test a typed permission (not instance-level)
	if (currentUser.isPermitted("lightsaber:wield")) {
		info("You may use a lightsaber ring.  Use it wisely.");
	} else {
		info("Sorry, lightsaber rings are for schwartz masters only.");
	}

	//a (very powerful) Instance Level permission:
	if (currentUser.isPermitted("winnebago:drive:eagle5")) {
		info("You are permitted to 'drive' the winnebago with license plate (id) 'eagle5'.  " ~
				"Here are the keys - have fun!");
	} else {
		info("Sorry, you aren't allowed to drive the 'eagle5' winnebago!");
	}

	//all done - log out!
	currentUser.logout();
}
