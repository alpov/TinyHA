<?php

$auth = intval($_GET['auth']);
$on = $_GET['on'];

if ($auth == "383")
    $filename = '/opt/tinyha/gpio/X3'; // zebrik koupelna nahore
elseif ($auth == "384")
    $filename = '/opt/tinyha/gpio/X4'; // zebrik koupelna dole
elseif ($auth == "964")
    $filename = '/opt/tinyha/gpio/X2'; // cerpadlo v garazi
elseif ($auth == "629")
    $filename = '/opt/tinyha/gpio/X6'; // blokovani TUV
else
    die("ERROR");

if ($on != "0" && $on != "1") die("ERROR");

$fd = fopen($filename, "w") or die("ERROR");
fwrite($fd, $on);
fclose($fd);

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");

if ($on == "1" && isset($_GET['minutes'])) {
    $timelen = $_GET['minutes'];

    $stmt = $db->prepare("delete from output where filename=:filename and filevalue='0' and dt<datetime('now', :timelen)");
    $stmt->bindValue(':timelen', $timelen.' minutes');
    $stmt->bindValue(':filename', $filename);
    $stmt->execute();

    $stmt = $db->prepare("insert into output (dt, filename, filevalue) values (datetime('now', :timelen), :filename, '0')");
    $stmt->bindValue(':timelen', $timelen.' minutes');
    $stmt->bindValue(':filename', $filename);
    $stmt->execute();
}

$db = null;

echo "OK";

?>
