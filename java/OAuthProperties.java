package com.google.oauthsample;

import ...

/**
 * Object representation of an OAuth properties file.
 */
public class OAuthProperties {

  public static final String DEFAULT_OAUTH_PROPERTIES_FILE_NAME = "oauth.properties";

  /** The OAuth 2.0 Client ID */
  private String clientId;

  /** The OAuth 2.0 Client Secret */
  private String clientSecret;

  /** The Google APIs scopes to access */
  private String scopes;

  /**
   * Instantiates a new OauthProperties object reading its values from the
   * {@code OAUTH_PROPERTIES_FILE_NAME} properties file.
   *
   * @throws IOException IF there is an issue reading the {@code propertiesFile}
   * @throws OauthPropertiesFormatException If the given {@code propertiesFile}
   *           is not of the right format (does not contains the keys {@code
   *           clientId}, {@code clientSecret} and {@code scopes})
   */
  public OAuthProperties() throws IOException {
    this(OAuthProperties.class.getResourceAsStream(DEFAULT_OAUTH_PROPERTIES_FILE_NAME));
  }

  /**
   * Instantiates a new OauthProperties object reading its values from the given
   * properties file.
   *
   * @param propertiesFile the InputStream to read an OAuth Properties file. The
   *          file should contain the keys {@code clientId}, {@code
   *          clientSecret} and {@code scopes}
   * @throws IOException IF there is an issue reading the {@code propertiesFile}
   * @throws OAuthPropertiesFormatException If the given {@code propertiesFile}
   *           is not of the right format (does not contains the keys {@code
   *           clientId}, {@code clientSecret} and {@code scopes})
   */
  public OAuthProperties(InputStream propertiesFile) throws IOException {
    Properties oauthProperties = new Properties();
    oauthProperties.load(propertiesFile);
    clientId = oauthProperties.getProperty("clientId");
    clientSecret = oauthProperties.getProperty("clientSecret");
    scopes = oauthProperties.getProperty("scopes");
    if ((clientId == null) || (clientSecret == null) || (scopes == null)) {
      throw new OAuthPropertiesFormatException();
    }
  }

  /**
   * @return the clientId
   */
  public String getClientId() {
    return clientId;
  }

  /**
   * @return the clientSecret
   */
  public String getClientSecret() {
    return clientSecret;
  }

  /**
   * @return the scopes
   */
  public String getScopesAsString() {
    return scopes;
  }

  /**
   * Thrown when the OAuth properties file was not at the right format, i.e not
   * having the right properties names.
   */
  @SuppressWarnings("serial")
  public class OAuthPropertiesFormatException extends RuntimeException {
  }
}
