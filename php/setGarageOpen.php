<?php

$auth = intval($_GET['auth']);

if ($auth == "963") {
    $fd = fopen("/opt/tinyha/gpio/X1", "w") or die("ERROR");
    fwrite($fd, '1');
    usleep(250000);
    fwrite($fd, '0');
    fclose($fd);
    echo "OK";
}

?>
