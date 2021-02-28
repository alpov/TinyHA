#!/usr/bin/php
<?php

chdir('/var/www/html/inc/nibe');
require 'class.nibeAPI.php';
require 'auth.php';

$running = true;
declare(ticks=1);
function signalHandler($signo)
{
    global $running;
    $running = false;
}
pcntl_signal(SIGINT, 'signalHandler');

$nibeAPI = new NibeAPI($CLIENT_ID, $CLIENT_SECRET, $REDIRECT_URL);

while ($running) {
    $token = $nibeAPI->checkToken();
    if ($token === false) die("Nibe API authorization error");

    $BT6 = 'U'; $BT7 = 'U'; $BT1 = 'U'; $DM = 'U'; $S1 = 'U'; $BT25 = 'U'; $BT71 = 'U';
    $response = $nibeAPI->readAPI("systems/" . $config['nibe_system_id'] . "/serviceinfo/categories?parameters=true", $token, $success);
    if (!$success) continue;
    foreach ($response as $category) {
        foreach ($category->parameters as $obj) {
            if ($obj->parameterId == 40014) $BT6 = $obj->rawValue / 10;
            else if ($obj->parameterId == 40013) $BT7 = $obj->rawValue / 10;
            else if ($obj->parameterId == 40004) $BT1 = $obj->rawValue / 10;
            else if ($obj->parameterId == 43005) $DM = $obj->rawValue / 10;
            else if ($obj->parameterId == 43009) $S1 = $obj->rawValue / 10;
            else if ($obj->parameterId == 40071) $BT25 = $obj->rawValue / 10;
            else if ($obj->parameterId == 40152) $BT71 = $obj->rawValue / 10;
        }
    }
    rrd_update('/opt/tinyha/db/nibe.rrd', array("N:$BT6:$BT7:$BT1:$DM:$S1:$BT25:$BT71"));

    $Tadd = 'U'; $Tcomp = 'U'; $Thot = 'U'; $Tcool = 'U'; $Nstart = 'U';
    $BT14 = 'U'; $BT15 = 'U'; $BT17 = 'U'; $BT3 = 'U'; $BT16 = 'U'; $BT12 = 'U'; $BT63 = 'U';
    $response = $nibeAPI->readAPI("systems/" . $config['nibe_system_id'] . "/parameters/?parameterIds=43081&parameterIds=44071&".
        "parameterIds=44073&parameterIds=40737&parameterIds=44069&parameterIds=44059&parameterIds=44060&".
        "parameterIds=44061&parameterIds=44055&parameterIds=44363&parameterIds=44058&parameterIds=40121", $token, $success);
    if (!$success) continue;
    foreach ($response as $obj) {
        if ($obj->parameterId == 43081) $Tadd = $obj->rawValue / 10;
        else if ($obj->parameterId == 44071) $Tcomp = $obj->rawValue;
        else if ($obj->parameterId == 44073) $Thot = $obj->rawValue;
        else if ($obj->parameterId == 40737) $Tcool = $obj->rawValue;
        else if ($obj->parameterId == 44069) $Nstart = $obj->rawValue;
        else if ($obj->parameterId == 44059) $BT14 = $obj->rawValue / 10;
        else if ($obj->parameterId == 44060) $BT15 = $obj->rawValue / 10;
        else if ($obj->parameterId == 44061) $BT17 = $obj->rawValue / 10;
        else if ($obj->parameterId == 44055) $BT3 = $obj->rawValue / 10;
        else if ($obj->parameterId == 44363) $BT16 = $obj->rawValue / 10;
        else if ($obj->parameterId == 44058) $BT12 = $obj->rawValue / 10;
        else if ($obj->parameterId == 40121) $BT63 = $obj->rawValue / 10;
    }
    rrd_update('/opt/tinyha/db/nibe2.rrd', array("N:$Tadd:$Tcomp:$Thot:$Tcool:$Nstart"));
    rrd_update('/opt/tinyha/db/nibe3.rrd', array("N:$BT14:$BT15:$BT17:$BT3:$BT16:$BT12:$BT63"));

    sleep(120);
}

?>
