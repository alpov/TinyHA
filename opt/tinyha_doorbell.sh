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

while ($running) {
    exec('gpio wfi 21 falling'); // wait for doorbell press
    if (!$running) break;
    $db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");
    $stmt = $db->prepare("INSERT INTO log (what) VALUES (202)");
    $stmt->execute();
    $db = null;
    sleep(1);
}

?>
