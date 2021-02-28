#!/usr/bin/php
<?php

$running = true;
declare(ticks=1);
function signalHandler($signo)
{
    global $running;
    $running = false;
}
pcntl_signal(SIGINT, 'signalHandler');

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");

while ($running) {
    $arr = array('openwrt', 'debian', 'nibe', 'tv', 'pvr', 'cam-1', 'cam-2', 'cam-3', 'epaper75');
    $value = "";
    foreach ($arr as &$name) {
        exec("ping -q -w 1 -c 1 " . $name . " > /dev/null 2> /dev/null", $output, $result);
        $value = $value . strval($result);
    }

    $stmt = $db->prepare("UPDATE state SET dt = current_timestamp, val = :online WHERE what = 102");
    $stmt->bindValue(':online', $value);
    $stmt->execute();

    sleep(10);
}

$db = null;

?>
