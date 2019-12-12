$curl = curl_init( 'https://public-api.wordpress.com/oauth2/token' );
curl_setopt( $curl, CURLOPT_POST, true );
curl_setopt( $curl, CURLOPT_POSTFIELDS, array(
    'client_id' => your_client_id,
    'redirect_uri' => your_redirect_url,
    'client_secret' => your_client_secret_key,
    'code' => $_GET['code'], // The code from the previous request
    'grant_type' => 'authorization_code'
) );
curl_setopt( $curl, CURLOPT_RETURNTRANSFER, 1);
$auth = curl_exec( $curl );
$secret = json_decode($auth);
$access_key = $secret->access_token;

$curl = curl_init( 'https://public-api.wordpress.com/oauth2/token' );
curl_setopt( $curl, CURLOPT_POST, true );
curl_setopt( $curl, CURLOPT_POSTFIELDS, array(
    'client_id' => your_client_id,
    'client_secret' => your_client_secret_key,
    'grant_type' => 'password',
    'username' => your_wpcom_username,
    'password' => your_wpcom_password,
) );
curl_setopt( $curl, CURLOPT_RETURNTRANSFER, 1);
$auth = curl_exec( $curl );
$auth = json_decode($auth);
$access_key = $auth->access_token;


<!--?php
$access_key = 'YOUR_API_TOKEN';
$curl = curl_init( 'https://public-api.wordpress.com/rest/v1/me/' );
curl_setopt( $curl, CURLOPT_HTTPHEADER, array( 'Authorization: Bearer ' . $access_key ) );
curl_exec( $curl );
?-->