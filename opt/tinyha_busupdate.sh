#!/usr/bin/php
<?php

require '/var/www/html/inc/busComm.php';

$running = true;
declare(ticks=1);
function signalHandler($signo)
{
    global $running;
    $running = false;
}
pcntl_signal(SIGINT, 'signalHandler');

function getState($filename, $on = "0", $off = "1")
{
    $fd = fopen($filename, "r");
    if (!$fd) {
        $value = "X";
    } else {
        $value = ((fgetc($fd) == '0') ? $on : $off);
        fclose($fd);
    }
    return $value;
}

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");
$cnt = 0;

while ($running) {
    $fb = busOpen();

    $value = "";

    foreach (array(1, 2, 3, 6, 7, 8, 9, 10) as &$dev) {
        $result = busComm($fb, $dev, 50); // GET_STATE
        if ($result === false) goto next_try; // $value = $value . "X";
        else $value = $value . (($result & 0x0001) ? "C" : "O");
    }
    $value = $value . "-";

    $value = $value . getState("/opt/tinyha/gpio/I1", "C", "O"); // senzor vrat od garaze
    $value = $value . getState("/opt/tinyha/gpio/I2", "1", "0"); // zvonek - dummy, resen pres interrupt
    $value = $value . getState("/opt/tinyha/gpio/I3", "1", "0"); // externi napajeni - dostupnost 230V
    $value = $value . getState("/opt/tinyha/gpio/I4", "1", "0");
    $value = $value . getState("/opt/tinyha/gpio/I5", "1", "0");
    $value = $value . getState("/opt/tinyha/gpio/I6", "1", "0");
    $value = $value . "-";

    $value = $value . getState("/opt/tinyha/gpio/X1"); // spinac otevirani vrat
    $value = $value . getState("/opt/tinyha/gpio/X2"); // cerpadlo v garazi
    $value = $value . getState("/opt/tinyha/gpio/X3"); // zebrik koupelna nahore
    $value = $value . getState("/opt/tinyha/gpio/X4"); // zebrik koupelna dole
    $value = $value . getState("/opt/tinyha/gpio/X5"); // venkovni osvetleni
    $value = $value . getState("/opt/tinyha/gpio/X6"); // blokovani TUV
    $value = $value . getState("/opt/tinyha/gpio/X7");
    $value = $value . getState("/opt/tinyha/gpio/O1");
    $value = $value . getState("/opt/tinyha/gpio/O2");

    $stmt = $db->prepare("UPDATE state SET dt = current_timestamp, val = :reed WHERE what = 101");
    $stmt->bindValue(':reed', $value);
    $stmt->execute();

    $stmt = $db->query("SELECT id, filename, filevalue FROM output WHERE dt < datetime('now') ORDER BY dt LIMIT 1");
    if (($output = $stmt->fetch())) {
        if (($fd = fopen($output['filename'], "w"))) {
            fwrite($fd, $output['filevalue']);
            fclose($fd);

            $stmt = $db->prepare("delete from output where id=:id");
            $stmt->bindValue(':id', $output['id']);
            $stmt->execute();
        }
    }

    if ($cnt == 0) {
        $litres = busComm($fb, 20, 12); // GET_LITRES
        $tank = busComm($fb, 20, 21); // GET_OCCUP
        $water = busComm($fb, 21, 31); // GET_PULSES/water
        $water_period = busComm($fb, 21, 32); // GET_PPERIOD/water
        $power = busComm($fb, 22, 31); // GET_PULSES/kwh
        $power_period = busComm($fb, 22, 32); // GET_PPERIOD/kwh
        $i_u_batt = busComm($fb, 30, 11); // GET_I_U_BATT
        $i_out_state = busComm($fb, 30, 12); // GET_I_OUT_STATE

        if ($litres !== false && $tank !== false && $water !== false && $power !== false &&
            $i_u_batt !== false && $i_out_state !== false)
        {
            $cnt = 10;
        }

        if ($litres !== false && $tank !== false) {
            rrd_update('/opt/tinyha/db/tank2.rrd', array("N:$litres:$tank"));

            // vypnout cerpadlo, pokud retencka poklesne pod 50 litru
            if ($tank < 50) {
                $fd = fopen("/opt/tinyha/gpio/X2", "w");
                fwrite($fd, "0");
                fclose($fd);
            }
        }

        if ($water !== false && $power !== false) {
            $power = $power * 2; // 500 imp/kWh = 2 Wh/imp
            rrd_update('/opt/tinyha/db/optomeas.rrd', array("N:$water:$power"));
        }

        if ($water_period !== false && $power_period !== false) {
            $water2 = ($water_period == 65535) ? 0 : (60000.0 / $water_period); // 1 ms per 1 liter => l/min
            $power2 = ($power_period == 65535) ? 0 : (7200000.0 / $power_period); // 1 ms per 2 Wh => W
            rrd_update('/opt/tinyha/db/optomeas2.rrd', array("N:$water2:$power2"));
        }

        if ($i_u_batt !== false && $i_out_state !== false) {
            $i_batt = intdiv($i_u_batt, 256);
            if ($i_batt >= 128) $i_batt = $i_batt - 256;
            $i_batt = $i_batt * 0.05;
            $u_batt = ($i_u_batt % 256) * 0.1;

            $i_out = intdiv($i_out_state, 256);
            if ($i_out >= 128) $i_out = $i_out - 256;
            $i_out = $i_out * 0.05;
            $pwr_out = $u_batt * $i_out;

            //echo $i_u_batt."\t".$i_out_state."\n";
            //echo $i_batt."\t".$u_batt."\t".$i_out."\t".$pwr_out."\n";

            rrd_update('/opt/tinyha/db/power.rrd', array("N:$i_batt:$i_out:$u_batt:$pwr_out"));
        }
    } else {
        $cnt--;
    }

next_try:
    busClose($fb);
    sleep(2);
}

$db = null;

?>
