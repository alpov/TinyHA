<?php

// CONFIG (set up your own application on https://api.nibeuplink.com to get these things)
//==========

$config = include('../config.php');

$CLIENT_ID = $config['nibe_client_id']; // Nibe Uplink API Application Identifier
$CLIENT_SECRET = $config['nibe_client_secret']; // Nibe Uplink API Application Secret
$REDIRECT_URL = "http://tinyha.lan/inc/nibe/"; // the URL on your raspberryPi to the folder containing this script (this can and should only be accessible from your LAN for security reasons!)

?>
