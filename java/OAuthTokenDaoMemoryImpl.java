package com.google.oauthsample;

import com.google.api.client.auth.oauth2.draft10.AccessTokenResponse;
...

/**
 * Quick and Dirty memory implementation of {@link OAuthTokenDao} based on
 * HashMaps.
 */
public class OAuthTokenDaoMemoryImpl implements OAuthTokenDao {

  /** Object where all the Tokens will be stored */
  private static Map tokenPersistance = new HashMap();

  public void saveKeys(AccessTokenResponse tokens, String userName) {
    tokenPersistance.put(userName, tokens);
  }

  public AccessTokenResponse getKeys(String userName) {
    return tokenPersistance.get(userName);
  }
}
