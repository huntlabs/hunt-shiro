/*
 * Copyright 2008 Les Hazlewood
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.shiro.web.session.mgt.WebSessionKey;

import hunt.shiro.session.mgt.DefaultSessionKey;
import hunt.shiro.web.RequestPairSource;

// import javax.servlet.ServletRequest;
// import javax.servlet.ServletResponse;
// import java.io.Serializable;


/**
 * A {@link hunt.shiro.session.mgt.SessionKey SessionKey} implementation that also retains the
 * {@code ServletRequest} and {@code ServletResponse} associated with the web request that is performing the
 * session lookup.
 *
 * @since 1.0
 */
class WebSessionKey : DefaultSessionKey, RequestPairSource {  

    private ServletRequest servletRequest;
    private ServletResponse servletResponse;

    this(ServletRequest request, ServletResponse response) {
        // if (request is null) {
        //     throw new NullPointerException("request argument cannot be null.");
        // }
        // if (response is null) {
        //     throw new NullPointerException("response argument cannot be null.");
        // }
        this.servletRequest = request;
        this.servletResponse = response;
    }

    this(string sessionId, ServletRequest request, ServletResponse response) {
        this(request, response);
        setSessionId(sessionId);
    }

    ServletRequest getServletRequest() {
        return servletRequest;
    }

    ServletResponse getServletResponse() {
        return servletResponse;
    }
}
