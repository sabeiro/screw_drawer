package com.google.oauthsample;

import ...

/**
 * Servlet handling the OAuth callback from the authentication service. We are
 * retrieving the OAuth code, then exchanging it for a refresh and an access
 * token and saving it.
 */
@SuppressWarnings("serial")
public class OAuthCodeCallbackHandlerServlet extends HttpServlet {

  /** The name of the Oauth code URL parameter */
  public static final String CODE_URL_PARAM_NAME = "code";

  /** The name of the OAuth error URL parameter */
  public static final String ERROR_URL_PARAM_NAME = "error";

  /** The URL suffix of the servlet */
  public static final String URL_MAPPING = "/oauth2callback";

  public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    // Getting the "error" URL parameter
    String[] error = req.getParameterValues(ERROR_URL_PARAM_NAME);

    // Checking if there was an error such as the user denied access
    if (error != null && error.length > 0) {
      resp.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE, "There was an error: \""+error[0]+"\".");
      return;
    }
    // Getting the "code" URL parameter
    String[] code = req.getParameterValues(CODE_URL_PARAM_NAME);

    // Checking conditions on the "code" URL parameter
    if (code == null || code.length == 0) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "The \"code\" URL parameter is missing");
      return;
    }
  }

  /**
   * Construct the OAuth code callback handler URL.
   *
   * @param req the HttpRequest object
   * @return The constructed request's URL
   */
  public static String getOAuthCodeCallbackHandlerUrl(HttpServletRequest req) {
    String scheme = req.getScheme() + "://";
    String serverName = req.getServerName();
    String serverPort = (req.getServerPort() == 80) ? "" : ":" + req.getServerPort();
    String contextPath = req.getContextPath();
    String servletPath = URL_MAPPING;
    String pathInfo = (req.getPathInfo() == null) ? "" : req.getPathInfo();
    return scheme + serverName + serverPort + contextPath + servletPath + pathInfo;
  }
}
