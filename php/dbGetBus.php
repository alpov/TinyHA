<?php

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");

$stmt = $db->query(
    "SELECT val FROM state WHERE what = 101 and dt > datetime('now', '-30 second') LIMIT 1");
if (!($reed = $stmt->fetch(PDO::FETCH_NUM))) {
    $reed = array(0=>'XXXXXXXX-XXXXXX-XXXXXXXXX');
}

$data = rrd_lastupdate('/opt/tinyha/db/tank2.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $tank = array(0=>'Chyba', 1=>'Chyba');
} else {
    $tank = array(
        0 => sprintf('%dl', $data['data'][0]),
        1 => sprintf('%dl', $data['data'][1]));
}

$stmt = $db->query(
    "SELECT val FROM state WHERE what = 102 and dt > datetime('now', '-1 minute') LIMIT 1");
if (!($online = $stmt->fetch(PDO::FETCH_NUM))) {
    $online = array(0=>'22222222222222222222');
}

$data = rrd_lastupdate('/opt/tinyha/db/power.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $power = array(0=>'Chyba', 1=>'Chyba', 2=>'Chyba', 3=>'Chyba');
} else {
    $power = array(
        0 => sprintf('%.2fA', $data['data'][0]),
        1 => sprintf('%.2fA', $data['data'][1]),
        2 => sprintf('%.1fV', $data['data'][2]),
        3 => sprintf('%.1fW', $data['data'][3]));
}

echo $reed[0] . "," . implode(",", $tank) . "," . $online[0] . "," . implode(",", $power);

$db = null;

?>
