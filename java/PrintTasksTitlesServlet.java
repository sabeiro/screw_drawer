package com.google.oauthsample;

import ...

/**
 * Simple sample Servlet which will display the tasks in the default task list of the user.
 */
@SuppressWarnings("serial")
public class PrintTasksTitlesServlet extends HttpServlet {

  /**
   * The OAuth Token DAO implementation, used to persist the OAuth refresh token.
   * Consider injecting it instead of using a static initialization. Also we are
   * using a simple memory implementation as a mock. Change the implementation to
   * using your database system.
   */
  public static OAuthTokenDao oauthTokenDao = new OAuthTokenDaoMemoryImpl();

  public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    // Getting the current user
    // This is using App Engine's User Service but you should replace this to
    // your own user/login implementation
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();

    // If the user is not logged-in it is redirected to the login service, then back to this page
    if (user == null) {
      resp.sendRedirect(userService.createLoginURL(getFullRequestUrl(req)));
      return;
    }

    // Checking if we already have tokens for this user in store
    AccessTokenResponse accessTokenResponse = oauthTokenDao.getKeys(user.getEmail());

    // If we don't have tokens for this user
    if (accessTokenResponse == null) {
      OAuthProperties oauthProperties = new OAuthProperties();
      // Redirect to the Google OAuth 2.0 authorization endpoint
      resp.sendRedirect(new GoogleAuthorizationRequestUrl(oauthProperties.getClientId(),
          OAuthCodeCallbackHandlerServlet.getOAuthCodeCallbackHandlerUrl(req), oauthProperties
              .getScopesAsString()).build());
      return;
    }


    // Printing the user's task lists titles in the response
    resp.setContentType("text/plain");
    resp.getWriter().append("Task Lists titles for user " + user.getEmail() + ":\n\n");
    printTasksTitles(accessTokenResponse, resp.getWriter());

  }

  /**
   * Construct the request's URL without the parameter part.
   *
   * @param req the HttpRequest object
   * @return The constructed request's URL
   */
  public static String getFullRequestUrl(HttpServletRequest req) {
    String scheme = req.getScheme() + "://";
    String serverName = req.getServerName();
    String serverPort = (req.getServerPort() == 80) ? "" : ":" + req.getServerPort();
    String contextPath = req.getContextPath();
    String servletPath = req.getServletPath();
    String pathInfo = (req.getPathInfo() == null) ? "" : req.getPathInfo();
    String queryString = (req.getQueryString() == null) ? "" : "?" + req.getQueryString();
    return scheme + serverName + serverPort + contextPath + servletPath + pathInfo + queryString;
  }


  /**
   * Uses the Google Tasks API to retrieve a list of the users's tasks in the default
   * tasks list.
   *
   * @param accessTokenResponse The OAuth 2.0 AccessTokenResponse object
   *          containing the access token and a refresh token.
   * @param output the output stream writer where to rite the tasks lists titles
   * @return A list of the users's tasks titles in the default task list.
   * @throws IOException
   */
  public void printTasksTitles(AccessTokenResponse accessTokenResponse, Writer output) throws IOException {

    // Initializing the Tasks service
    HttpTransport transport = new NetHttpTransport();
    JsonFactory jsonFactory = new JacksonFactory();
    OAuthProperties oauthProperties = new OAuthProperties();

    GoogleAccessProtectedResource accessProtectedResource = new GoogleAccessProtectedResource(
        accessTokenResponse.accessToken, transport, jsonFactory, oauthProperties.getClientId(),
        oauthProperties.getClientSecret(), accessTokenResponse.refreshToken);

    Tasks service = new Tasks(transport, accessProtectedResource, jsonFactory);

    // Using the initialized Tasks API service to query the list of tasks lists
    com.google.api.services.tasks.model.Tasks tasks = service.tasks.list("@default").execute();

    for (Task task : tasks.items) {
      output.append(task.title + "\n");
    }
  }
}
