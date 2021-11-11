#!/usr/bin/php
<?php

require '/var/www/html/inc/busComm.php';
$config = include('/var/www/html/inc/config.php');

$fd = busOpen();
busComm($fd, 20, 13); // RESET_FLOW
busComm($fd, 21, 33); // RESET_VALUE/water
busComm($fd, 22, 33); // RESET_VALUE/kwh
busClose($fd);

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");
$stmt = $db->prepare("insert into output (dt, filename, filevalue) values (datetime(date('now'), :time, 'utc'), :filename, :filevalue)");

// venkovni osvetleni
$stmt->bindValue(':filename', '/opt/tinyha/gpio/X5');
$stmt->bindValue(':time', date("H:i", date_sunset(time(), SUNFUNCS_RET_TIMESTAMP,
    $config['sunset_latitude'], $config['sunset_longitude'], 96) + $config['sunset_shift']*60));
$stmt->bindValue(':filevalue', '1');
$stmt->execute();
$stmt->bindValue(':time', '23:00');
$stmt->bindValue(':filevalue', '0');
$stmt->execute();

// horni topny zebrik
$stmt->bindValue(':filename', '/opt/tinyha/gpio/X3');
$stmt->bindValue(':time', '19:00');
$stmt->bindValue(':filevalue', '1');
if (date('m') >= 10 || date('m') <= 5) $stmt->execute(); // listopad az kveten
$stmt->bindValue(':time', '19:40');
$stmt->bindValue(':filevalue', '0');
$stmt->execute();

$db = null;

?>
