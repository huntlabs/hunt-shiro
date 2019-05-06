module hunt.shiro.Exceptions;

import hunt.Exceptions;


class ShiroException : Exception {
    mixin BasicExceptionCtors;
}


class UnavailableSecurityManagerException : ShiroException {
    mixin BasicExceptionCtors;
}