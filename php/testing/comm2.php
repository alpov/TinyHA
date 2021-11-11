<PRE>

<?php

require '../inc/busComm2.php';

$dev = intval($_GET['dev']);
$cmd = intval($_GET['cmd']);
$val = intval($_GET['val']);

$fd = busOpen();
busComm($fd, $dev, $cmd, $val, true);
busClose($fd);

?>

</PRE>
