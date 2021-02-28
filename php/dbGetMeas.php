<?php

$data = rrd_lastupdate('/opt/tinyha/db/ds18b20.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $ds18b20 = array(0=>'Chyba', 1=>'Chyba', 2=>'Chyba', 3=>'Chyba', 4=>'Chyba');
} else {
    $ds18b20 = array(
        sprintf('%.1f°C', $data['data'][0]),
        sprintf('%.1f°C', $data['data'][1]),
        sprintf('%.1f°C', $data['data'][2]),
        sprintf('%.1f°C', $data['data'][3]),
        sprintf('%.1f°C', $data['data'][4]));
}

$data = rrd_lastupdate('/opt/tinyha/db/sht30.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $sht30 = array(0=>'Chyba', 1=>'Chyba', 2=>'Chyba');
} else {
    $sht30 = array(
        sprintf('%.1f°C', $data['data'][0]),
        sprintf('%d ppm', $data['data'][1]),
        sprintf('%d%%', $data['data'][2]));
}

echo implode(",", $ds18b20) . "," . implode(",", $sht30);

?>
