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


  /** The URL to redirect the user to after handling the callback. Consider
   * saving this in a cookie before redirecting users to the Google
   * authorization URL if you have multiple possible URL to redirect people to. */
  public static final String REDIRECT_URL = "/";

  /** The OAuth Token DAO implementation. Consider injecting it instead of using
   * a static initialization. Also we are using a simple memory implementation
   * as a mock. Change the implementation to using your database system. */
  public static OAuthTokenDao oauthTokenDao = new OAuthTokenDaoMemoryImpl();

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


    // Construct incoming request URL
    String requestUrl = getOAuthCodeCallbackHandlerUrl(req);

    // Exchange the code for OAuth tokens
    AccessTokenResponse accessTokenResponse = exchangeCodeForAccessAndRefreshTokens(code[0],
        requestUrl);

    // Getting the current user
    // This is using App Engine's User Service but you should replace this to
    // your own user/login implementation
    UserService userService = UserServiceFactory.getUserService();
    String email = userService.getCurrentUser().getEmail();

    // Save the tokens
    oauthTokenDao.saveKeys(accessTokenResponse, email);

    resp.sendRedirect(REDIRECT_URL);
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


  /**
   * Exchanges the given code for an exchange and a refresh token.
   *
   * @param code The code gotten back from the authorization service
   * @param currentUrl The URL of the callback
   * @param oauthProperties The object containing the OAuth configuration
   * @return The object containing both an access and refresh token
   * @throws IOException
   */
  public AccessTokenResponse exchangeCodeForAccessAndRefreshTokens(String code, String currentUrl)
      throws IOException {

    HttpTransport httpTransport = new NetHttpTransport();
    JacksonFactory jsonFactory = new JacksonFactory();

    // Loading the oauth config file
    OAuthProperties oauthProperties = new OAuthProperties();

    return new GoogleAuthorizationCodeGrant(httpTransport, jsonFactory, oauthProperties
        .getClientId(), oauthProperties.getClientSecret(), code, currentUrl).execute();
  }
}
