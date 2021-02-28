<?php

if (isset($_GET['temp']) && isset($_GET['hum']) && isset($_GET['co2'])) {
    $t = $_GET['temp'] ?? 'U';
    $co2 = $_GET['co2'] ?? 'U';
    $hum = $_GET['hum'] ?? 'U';
    rrd_update('/opt/tinyha/db/sht30.rrd', array("N:$t:$co2:$hum"));
} else {
    echo "NO DATA";
}

?>
