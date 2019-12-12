package com.google.oauthsample;

import com.google.api.client.auth.oauth2.draft10.AccessTokenResponse;

/**
 * Allows easy storage and access of authorization tokens.
 */
public interface OAuthTokenDao {

  /**
   * Stores the given AccessTokenResponse using the {@code username}, the OAuth
   * {@code clientID} and the tokens scopes as keys.
   *
   * @param tokens The AccessTokenResponse to store
   * @param userName The userName associated wit the token
   */
  public void saveKeys(AccessTokenResponse tokens, String userName);

  /**
   * Returns the AccessTokenResponse stored for the given username, clientId and
   * scopes. Returns {@code null} if there is no AccessTokenResponse for this
   * user and scopes.
   *
   * @param userName The username of which to get the stored AccessTokenResponse
   * @return The AccessTokenResponse of the given username
   */
  public AccessTokenResponse getKeys(String userName);
}
