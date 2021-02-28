<?php

putenv('GDFONTPATH=' . realpath('./inc'));
$dbpath = '/opt/tinyha/db/';

function imagebw($im)
{
    $pbm = "";
    $pix = 0;
    for ($y = 0; $y < imagesy($im); $y++) {
        for ($x = 0; $x < imagesx($im); $x++) {
            $rgb = imagecolorat($im, $x, $y);
            $r = ($rgb >> 16) & 0xFF;
            $g = ($rgb >> 8 ) & 0xFF;
            $b = $rgb & 0xFF;
            $gray = ($r + $g + $b) / 3;
            $idx = $y*imagesx($im)+$x;

            $pix = $pix << 1;
            $pix = $pix | (($gray < 160) ? 0 : 1);
            if ($idx%8 == 7) {
                $pbm = $pbm . chr($pix);
                $pix = 0;
            }
            imagesetpixel($im, $x, $y, ($gray < 160) ? 0x000000 : 0xFFFFFF);
        }
    }
    return "P4 296 128\n" . $pbm;
}

function imagettfcenter($image, $size, $x, $y, $color, $fontfile, $text)
{
    list($left, , $right, , , ) = imageftbbox($size, 0, $fontfile, $text);
    $left_offset = ($right - $left) / 2;
    $x = $x - $left_offset;
    imagettftext($image, $size, 0, $x, $y, $color, $fontfile, $text);
}

function imagettfright($image, $size, $x, $y, $color, $fontfile, $text)
{
    list($left, , $right, , , ) = imageftbbox($size, 0, $fontfile, $text);
    $left_offset = ($right - $left);
    $x = $x - $left_offset;
    imagettftext($image, $size, 0, $x, $y, $color, $fontfile, $text);
}

$db = new PDO('sqlite:'.$dbpath.'tinyha.db') or die("cannot open database");

$im = imagecreatefrompng("inc/tinyha_empty.png");

$background_color = imagecolorallocate($im, 255, 255, 255);
$black = imagecolorallocate($im, 0, 0, 0);
$font = "arial";

$data = rrd_lastupdate($dbpath.'sht30.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $sht30 = array('t'=>'-', 'co2'=>'-', 'hum'=>'-');
} else {
    $sht30 = array(
        't'   => sprintf('%.1f°C', $data['data'][0]),
        'co2' => sprintf('%d', $data['data'][1]),
        'hum' => sprintf('%d%%', $data['data'][2]));
}

$data = rrd_lastupdate($dbpath.'ds18b20.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $ds18b20 = array('t1'=>'-', 't2'=>'-', 't3'=>'-', 't4'=>'-', 't5'=>'-');
} else {
    $ds18b20 = array(
        't1' => sprintf('%.1f°C', $data['data'][0]),
        't2' => sprintf('%.1f°C', $data['data'][1]),
        't3' => sprintf('%.1f°C', $data['data'][2]),
        't4' => sprintf('%.1f°C', $data['data'][3]),
        't5' => sprintf('%.1f°C', $data['data'][4]));
}

$stmt = $db->query(
    "select reed from reed where dt > datetime('now', '-10 second') order by id desc limit 1");
if (!($reed = $stmt->fetch(PDO::FETCH_NUM))) {
    $reed = array(0=>'XXXXXXXXXX');
}

$data = rrd_lastupdate($dbpath.'tank.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $tank = array(0=>'-', 1=>'-');
} else {
    $tank = array(
        0 => sprintf('%dl', $data['data'][0]),
        1 => sprintf('%dmm', $data['data'][1]));
}

imagettfcenter($im, 14,  43, 33, $black, $font, $ds18b20['t5']);
imagettfcenter($im, 14, 127, 33, $black, $font, $sht30['t']);
imagettfcenter($im, 14, 198, 33, $black, $font, $sht30['hum']);
imagettfcenter($im, 14, 261, 33, $black, $font, $sht30['co2']);

imagettfcenter($im, 9,  206, 68, $black, $font, $reed[0][8] == 'C' ? "zavřena" : "otevřena");
imagettfcenter($im, 11, 204, 84, $black, $font, $ds18b20['t3']);
imagettfcenter($im, 10, 206, 104, $black, $font, $tank[0]);

imagettfcenter($im, 11, 265, 58, $black, $font, "Špajz");
imagettfcenter($im, 11, 265, 78, $black, $font, $ds18b20['t1']);
imagettfcenter($im, 10, 265, 104, $black, $font, $tank[1]);
//imagettfcenter($im, 11, 265, 80, $black, $font, "N/A");
//imagettfcenter($im, 11, 265, 70, $black, $font, "vše");
//imagettfcenter($im, 11, 265, 87, $black, $font, "zavřeno");

$dow = array("ne", "po", "út", "st", "čt", "pá", "so");
imagettfcenter($im, 10,  27, 125, $black, $font, date("H:i"));
imagettfcenter($im, 10, 265, 125, $black, $font, $dow[date("w")] . date(" j.n."));

/*
if (isset($_GET['debug'])) {
$stmt = $db->query(
    "select avg(t5) from ds18b20".
    " where dt > datetime('now', '-3 day')".
    " group by strftime('%s', dt)/(3*86400/(150-1))".
    " order by dt asc");
$grval = $stmt->fetchAll(PDO::FETCH_COLUMN,0);
print_r($grval);
$grmin = floor(min($grval)/5)*5;
$grmax = ceil(max($grval)/5)*5;
echo $grmin;
echo $grmax;
foreach ($grval as &$val) $val = round(($val - $grmin) * 50 / ($grmax - $grmin));
print_r($grval);

return;
}
*/

session_id("def");
session_start();

if (isset($_GET['btn']) && $_GET['btn'] == '1') {
    if (!isset($_SESSION['graph']) || $_SESSION['graph'] >= 3) $_SESSION['graph'] = 0;
    else $_SESSION['graph']++;
}

switch ($_SESSION['graph']) {
    case 0:
    default:
        $data = rrd_fetch($dbpath.'ds18b20.rrd', array('AVERAGE', '-s', '-3d', '-e', 'now'));
        $inp = $data['data']['t5'];
        $round = 5;
        break;
    case 1:
        $data = rrd_fetch($dbpath.'sht30.rrd', array('AVERAGE', '-s', '-3d', '-e', 'now'));
        $inp = $data['data']['hum'];
        $round = 10;
        break;
    case 2:
        $data = rrd_fetch($dbpath.'sht30.rrd', array('AVERAGE', '-s', '-3d', '-e', 'now'));
        $inp = $data['data']['t'];
        $round = 1;
        break;
    case 3:
        $data = rrd_fetch($dbpath.'sht30.rrd', array('AVERAGE', '-s', '-3d', '-e', 'now'));
        $inp = $data['data']['co2'];
        $round = 100;
        break;
}

// fixme: update code from screen75.php
$xlim = 150;
$ylim = 50;

$grval = array();
$len = floor((count($inp) / $xlim) - 1);
for ($x = 0; $x < $xlim; $x++) {
    $idx = floor($x * (count($inp) / $xlim));
    $grval[] = array_sum(array_slice($inp, $idx, $len)) / $len;
}

$grnum = array_filter($grval, function($k) { return !is_nan($k); });
$grmin = floor(min($grnum)/$round)*$round;
$grmax = ceil(max($grnum)/$round)*$round;
foreach ($grval as &$val) $val = intval(round(($val - $grmin) * $ylim / ($grmax - $grmin)));

for ($i = -3; $i <= 0; $i++) imagettfcenter($im, 7, 170+$i*50, 107, $black, $font, $i."d");
imagettfright($im, 7, 18, 100, $black, $font, round($grmin));
imagettfright($im, 7, 18, 75, $black, $font, round(($grmin+$grmax)/2));
imagettfright($im, 7, 18, 50, $black, $font, round($grmax));
for ($x = 1; $x < count($grval); $x++) imageline($im, 19+$x-1, 96-$grval[$x-1], 19+$x, 96-$grval[$x], $black);

$db = null;

$pbm = imagebw($im);

if (isset($_GET['png'])) {
    header("Content-type: image/png");
    imagepng($im);
} else {
    $old_time = $_SESSION['time'];
    $new_time = time();
    $old_values = $_SESSION['values'];
    $new_values = array($ds18b20['t5'], $sht30['t'], $sht30['hum'], $sht30['co2']);

    $refresh = ($new_time-$old_time > 10*60) ||
        (abs($old_values[0]-$new_values[0]) > 0.4) ||
        (abs($old_values[1]-$new_values[1]) > 0.2) ||
        (abs($old_values[2]-$new_values[2]) > 3) ||
        (abs($old_values[3]-$new_values[3]) > 20);

    if (($refresh && ($new_time-$old_time > 1*60)) || isset($_GET['reset']) || isset($_GET['btn'])) {
        $_SESSION['time'] = $new_time;
        $_SESSION['values'] = $new_values;
        //header("X-Beep: 1");
        header("Content-type: image/x-portable-bitmap");
        echo $pbm;
    } else {
        header("HTTP/1.1 304 Not Modified");
        header("Connection: close");
    }
}

imagedestroy($im);

?>
