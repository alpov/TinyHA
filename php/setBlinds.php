<?php

require 'inc/busComm.php';

$dev = intval($_GET['dev']);

if ($_GET['action'] == 'close') {
    $cmd = 20;
    $val = 1200;
} else if ($_GET['action'] == 'open') {
    $cmd = 10;
    $val = 1200;
} else if ($_GET['action'] == 'down') {
    $cmd = 21;
    $val = 0;
} else if ($_GET['action'] == 'up') {
    $cmd = 11;
    $val = 0;
} else {
    die("wrong parameters");
}

$fd = busOpen();
busComm($fd, $dev, $cmd, $val);
busClose($fd);

echo "OK";

?>
