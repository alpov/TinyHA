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
    $t1 = "U"; $t2 = "U"; $t3 = "U"; $t4 = "U"; $t5 = "U"; 

    // spajz hlavni
    $data = file("/sys/bus/w1/devices/28-00000aa49942/w1_slave")/* or die("Chyba")*/;
    strtok($data[1], "=");
    $value = floatval(strtok("=")) / 1000;
    if (strpos($data[0], "YES") === false || $value == 85) ;
    else $t1 = $value;

    // spajz 2
    $data = file("/sys/bus/w1/devices/28-00000aa3a7d2/w1_slave")/* or die("Chyba")*/;
    strtok($data[1], "=");
    $value = floatval(strtok("=")) / 1000;
    if (strpos($data[0], "YES") === false || $value == 85) ;
    else $t2 = $value;

    // garaz
    $data = file("/sys/bus/w1/devices/28-00000aa37447/w1_slave")/* or die("Chyba")*/;
    strtok($data[1], "=");
    $value = floatval(strtok("=")) / 1000;
    if (strpos($data[0], "YES") === false || $value == 85) ;
    else $t3 = $value;

    // spajz 3 - odstraneny

    // venkovni
    $data = file("/sys/bus/w1/devices/28-00000aa4b51f/w1_slave")/* or die("Chyba")*/;
    strtok($data[1], "=");
    $value = floatval(strtok("=")) / 1000;
    if (strpos($data[0], "YES") === false || $value == 85) ;
    else $t5 = $value;

    rrd_update('/opt/tinyha/db/ds18b20.rrd', array("N:$t1:$t2:$t3:$t4:$t5"));

    sleep(10);
}

?>
