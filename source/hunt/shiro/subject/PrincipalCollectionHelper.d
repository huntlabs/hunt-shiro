module hunt.shiro.subject.PrincipalCollectionHelper;

import hunt.shiro.subject.PrincipalCollection;
import hunt.shiro.subject.SimplePrincipalCollection;
import hunt.shiro.subject.SimplePrincipalMap;

import hunt.Exceptions;

struct PrincipalCollectionHelper {

    static T oneByType(T)(PrincipalCollection pc) if(is(T == class) || is(T == interface)) {
        SimplePrincipalCollection spc = cast(SimplePrincipalCollection)pc;
        if(spc !is null) {
            return spc.oneByType!T();
        } 
        
        SimplePrincipalMap spm = cast(SimplePrincipalMap)pc;
        if(spm !is null) {
            return spm.oneByType!T();
        }

        throw new InvalidClassException(typeid(cast(Object)pc).name);
    }


    static T byType(T)(PrincipalCollection pc) if(is(T == class) || is(T == interface)) {
        SimplePrincipalCollection spc = cast(SimplePrincipalCollection)pc;
        if(spc !is null) {
            return spc.byType!T();
        } 
        
        SimplePrincipalMap spm = cast(SimplePrincipalMap)pc;
        if(spm !is null) {
            return spm.byType!T();
        }

        throw new InvalidClassException(typeid(cast(Object)pc).name);
    }
}

alias oneByType = PrincipalCollectionHelper.oneByType;
alias byType = PrincipalCollectionHelper.byType;