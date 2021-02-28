<?php

require_once('class.nibeAPI.php');
require_once('class.nibeGateway.php');
require_once('auth.php');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$nibeAPI = new NibeAPI($CLIENT_ID, $CLIENT_SECRET, $REDIRECT_URL);
$nibeGateway = new NibeGateway($nibeAPI);

$nibeGateway->main();

?>
