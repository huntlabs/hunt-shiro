module hunt.shiro.web.RequestPairSource;

alias ServletRequest = Object;
alias ServletResponse = Object;


/**
 * A {@code RequestPairSource} is a component that can supply a {@link ServletRequest ServletRequest} and
 * {@link ServletResponse ServletResponse} pair associated with a currently executing request.  This is used for
 * framework development support and is rarely used by end-users.
 *
 * @since 1.0
 */
interface RequestPairSource {

    /**
     * Returns the incoming {@link ServletRequest ServletRequest} associated with the component.
     *
     * @return the incoming {@link ServletRequest ServletRequest} associated with the component.
     */
    ServletRequest getServletRequest();

    /**
     * Returns the outgoing {@link ServletResponse ServletResponse} paired with the incoming
     * {@link #getServletRequest() servletRequest}.
     *
     * @return the outgoing {@link ServletResponse ServletResponse} paired with the incoming
     *         {@link #getServletRequest() servletRequest}.
     */
    ServletResponse getServletResponse();
}
