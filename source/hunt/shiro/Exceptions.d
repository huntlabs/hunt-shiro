module hunt.shiro.Exceptions;

import hunt.Exceptions;


class ShiroException : Exception {
    mixin BasicExceptionCtors;
}

class AuthenticationException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Exception thrown if there is a problem during authorization (access control check).
 */
class AuthorizationException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Root exception related to issues during encoding or decoding.
 *
 * @since 0.9
 */
class CodecException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Root exception indicating there was a problem parsing or processing the Shiro configuration.
 *
 * @since 0.9
 */
class ConfigurationException : ShiroException{
    mixin BasicExceptionCtors;
}

/**
 * Base Shiro exception for problems encountered during cryptographic operations.
 *
 * @since 1.0
 */
class CryptoException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Generic exception representing a problem when attempting to access data.
 * <p/>
 * The idea was borrowed from the Spring Framework, which has a nice model for a generic DAO exception hierarchy.
 * Unfortunately we can't use it as we can't force a Spring API usage on all Shiro end-users.
 */
class DataAccessException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Exception thrown for errors related to {@link Environment} instances or configuration.
 */
class EnvironmentException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Exception wrapping any potential checked exception thrown when a {@code Subject} executes a
 * {@link java.util.concurrent.Callable}.  This is a nicer alternative than forcing calling code to catch
 * a normal checked {@code Exception} when it may not be necessary.
 * <p/>
 * If thrown, the causing exception will always be accessible via the {@link #getCause() getCause()} method.
 *
 */
class ExecutionException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * Thrown by {@link PermissionResolver#resolvePermission(string)} when the string being parsed is not
 * valid for that resolver.
 */
class InvalidPermissionStringException : ShiroException {
    mixin BasicExceptionCtors;
}

/**
 * General security exception attributed to problems during interaction with the system during
 * a session.
 *
 */
class SessionException : ShiroException {
    mixin BasicExceptionCtors;
}

class UnavailableSecurityManagerException : ShiroException {
    mixin BasicExceptionCtors;
}


/**
 * Exception thrown when attempting to acquire an object of a required type and that object does not equal, extend, or
 * implement a specified {@code Class}.
 */
class RequiredTypeException : EnvironmentException {
    mixin BasicExceptionCtors;
}

class AccountException : AuthenticationException {
    mixin BasicExceptionCtors;
}

class CredentialsException : AuthenticationException {
    mixin BasicExceptionCtors;
}

/**
 * Exception thrown during the authentication process when an
 * {@link hunt.shiro.authc.AuthenticationToken AuthenticationToken} implementation is encountered that is not
 * supported by one or more configured {@link hunt.shiro.realm.Realm Realm}s.
 *
 * @see hunt.shiro.authc.pam.AuthenticationStrategy
 */
class UnsupportedTokenException : AuthenticationException {
    mixin BasicExceptionCtors;
}


class ConcurrentAccessException : AccountException {
    mixin BasicExceptionCtors;
}


class DisabledAccountException : AccountException {
    mixin BasicExceptionCtors;
}

class ExcessiveAttemptsException : AccountException {
    mixin BasicExceptionCtors;
}

/**
 * Thrown during the authentication process when the system determines the submitted credential(s)
 * has expired and will not allow login.
 *
 * <p>This is most often used to alert a user that their credentials (e.g. password or
 * cryptography key) has expired and they should change the value.  In such systems, the component
 * invoking the authentication might catch this exception and redirect the user to an appropriate
 * view to allow them to update their password or other credentials mechanism.
 *
 */
class ExpiredCredentialsException : CredentialsException {
    mixin BasicExceptionCtors;
}

/**
 * Thrown when attempting to authenticate with credential(s) that do not match the actual
 * credentials associated with the account principal.
 *
 * <p>For example, this exception might be thrown if a user's password is &quot;secret&quot; and
 * &quot;secrets&quot; was entered by mistake.
 *
 * <p>Whether or not an application wishes to let
 * the user know if they entered incorrect credentials is at the discretion of those
 * responsible for defining the view and what happens when this exception occurs.
 *
 */
class IncorrectCredentialsException : CredentialsException {
    mixin BasicExceptionCtors;
}

/**
 * A special kind of <tt>DisabledAccountException</tt>, this exception is thrown when attempting
 * to authenticate and the corresponding account has been disabled explicitly due to being locked.
 *
 * <p>For example, an account can be locked if an administrator explicitly locks an account or
 * perhaps an account can be locked automatically by the system if too many unsuccessful
 * authentication attempts take place during a specific period of time (perhaps indicating a
 * hacking attempt).
 *
 */
class LockedAccountException : DisabledAccountException {
    mixin BasicExceptionCtors;
}


/**
 * Exception thrown if attempting to create a new {@code Subject}
 * {@link hunt.shiro.subject.Subject#getSession() session}, but that {@code Subject}'s sessions are disabled.
 * <p/>
 * Note that this exception represents an invalid API usage scenario - where Shiro has been configured to disable
 * sessions for a particular subject, but a developer is attempting to use that Subject's session.
 * <p/>
 * In other words, if this exception is encountered, it should be resolved by a configuration change for Shiro and
 * <em>not</em> by checking every Subject to see if they are enabled or not (which would likely introduce very
 * ugly/paranoid code checks everywhere a session is needed). This is why there is no
 * {@code subject.isSessionEnabled()} method.
 */
class DisabledSessionException : SessionException {
    mixin BasicExceptionCtors;
}

/**
 * A special case of a StoppedSessionException.  An expired session is a session that has
 * stopped explicitly due to inactivity (i.e. time-out), as opposed to stopping due to log-out or
 * other reason.
 *
 */
class ExpiredSessionException : StoppedSessionException {
    mixin BasicExceptionCtors;
}


/**
 * Exception thrown when attempting to interact with the system under the pretense of a
 * particular session (e.g. under a specific session id), and that session does not exist in
 * the system.
 */
class UnknownSessionException : InvalidSessionException {
    mixin BasicExceptionCtors;
}

/**
 * Exception thrown when attempting to interact with the system under a session that has been
 * stopped.  A session may be stopped in any number of ways, most commonly due to explicit
 * stopping (e.g. from logging out), or due to expiration.
 */
class StoppedSessionException : InvalidSessionException {
    mixin BasicExceptionCtors;
}

/**
 * Exception thrown when attempting to interact with the system under an established session
 * when that session is considered invalid.  The meaning of the term 'invalid' is based on
 * application behavior.  For example, a Session is considered invalid if it has been explicitly
 * stopped (e.g. when a user logs-out or when explicitly
 * {@link Session#stop() stopped} programmatically.  A Session can also be
 * considered invalid if it has expired.
 *
 * @see StoppedSessionException
 * @see ExpiredSessionException
 * @see UnknownSessionException
 */
class InvalidSessionException : SessionException {
    mixin BasicExceptionCtors;
}


/**
 * Root exception indicating invalid or incorrect usage of a data access resource.  This is thrown
 * typically when incorrectly using the resource or its API.
 */
class InvalidResourceUsageException : DataAccessException {
    mixin BasicExceptionCtors;
}


/**
 * Exception thrown when attempting to execute an authorization action when a successful
 * authentication hasn't yet occurred.
 *
 * <p>Authorizations can only be performed after a successful
 * authentication because authorization data (roles, permissions, etc) must always be associated
 * with a known identity.  Such a known identity can only be obtained upon a successful log-in.
 */
class UnauthenticatedException : AuthorizationException {
    mixin BasicExceptionCtors;
}

/**
 * Thrown to indicate a requested operation or access to a requested resource is not allowed.
 */
class UnauthorizedException : AuthorizationException {
    mixin BasicExceptionCtors;
}

/**
 * Thrown when a particular client (that is, host address) has not been enabled to access the system
 * or if the client has been enabled access but is not permitted to perform a particular operation
 * or access a particular resource.
 *
 */
class HostUnauthorizedException : UnauthorizedException {
    mixin BasicExceptionCtors;
}


/**
 * Exception thrown when attempting to lookup or use a cryptographic algorithm that does not exist in the current
 * JVM environment.
 *
 * @since 1.2
 */
public class UnknownAlgorithmException : CryptoException {
    mixin BasicExceptionCtors;
}