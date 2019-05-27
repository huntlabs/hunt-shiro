module hunt.shiro.web.WebUtils;

import hunt.shiro.web.RequestPairSource;

/**
 * Simple utility class for operations used across multiple class hierarchies in the web framework code.
 * <p/>
 * Some methods in this class were copied from the Spring Framework so we didn't have to re-invent the wheel,
 * and in these cases, we have retained all license, copyright and author information.
 *
 * @since 0.9
 */
class WebUtils {
    /*
     * Returns {@code true} IFF the specified {@code SubjectContext}:
     * <ol>
     * <li>A {@link WebSubjectContext} instance</li>
     * <li>The {@code WebSubjectContext}'s request/response pair are not null</li>
     * <li>The request is an {@link HttpServletRequest} instance</li>
     * <li>The response is an {@link HttpServletResponse} instance</li>
     * </ol>
     *
     * @param context the SubjectContext to check to see if it is HTTP compatible.
     * @return {@code true} IFF the specified context has HTTP request/response objects, {@code false} otherwise.
     * @since 1.0
     */

    static bool isWeb(Object requestPairSource) {
        RequestPairSource rp = cast(RequestPairSource)requestPairSource;
        return rp !is null; // && isWeb((RequestPairSource) requestPairSource);
    }

    static bool isWeb(RequestPairSource source) {
        ServletRequest request = source.getServletRequest();
        ServletResponse response = source.getServletResponse();
        // return request !is null && response !is null;
        return true;
    }

    /**
     * Returns {@code true} if a session is allowed to be created for a subject-associated request, {@code false}
     * otherwise.
     * <p/>
     * <b>This method exists for Shiro's internal framework needs and should never be called by Shiro end-users.  It
     * could be changed/removed at any time.</b>
     *
     * @param requestPairSource a {@link RequestPairSource} instance, almost always a
     *                          {@link org.apache.shiro.web.subject.WebSubject WebSubject} instance.
     * @return {@code true} if a session is allowed to be created for a subject-associated request, {@code false}
     *         otherwise.
     */
    static bool _isSessionCreationEnabled(Object requestPairSource) {
        // RequestPairSource source = cast(RequestPairSource) requestPairSource;
        // if (source !is null) {
        //     return _isSessionCreationEnabled(source.getServletRequest());
        // }
        return true; //by default
    }


    /**
     * Returns {@code true} if a session is allowed to be created for a subject-associated request, {@code false}
     * otherwise.
     * <p/>
     * <b>This method exists for Shiro's internal framework needs and should never be called by Shiro end-users.  It
     * could be changed/removed at any time.</b>
     *
     * @param request incoming servlet request.
     * @return {@code true} if a session is allowed to be created for a subject-associated request, {@code false}
     *         otherwise.
     */
    // static bool _isSessionCreationEnabled(ServletRequest request) {
    //     // if (request !is null) {
    //     //     Object val = request.getAttribute(DefaultSubjectContext.SESSION_CREATION_ENABLED);
    //     //     if (val != null && val instanceof Boolean) {
    //     //         return (Boolean) val;
    //     //     }
    //     // }
    //     return true; //by default
    // }

}