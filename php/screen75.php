<?php

putenv('GDFONTPATH=' . realpath('./inc'));
$config = include('inc/config.php');
$im = imagecreatefrompng("inc/tinyha_empty75.png");
$dbpath = '/opt/tinyha/db/';
$background_color = imagecolorallocate($im, 255, 255, 255);
$black = imagecolorallocate($im, 0, 0, 0);
$font = "arial";
$api_weather = $config['api_weather'];
$api_forecast = $config['api_forecast'];
$dow = array("ne", "po", "út", "st", "čt", "pá", "so");
$dow_full = array("neděle", "pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota");

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
    return "P4 640 384\n" . $pbm;
}

function imagebox($im, $x0, $y0, $xlim, $ylim)
{
    global $black;

    for ($w = 0; $w < 5; $w++) {
	imagerectangle($im, $x0+$w, $y0+$w, $xlim-$w, $ylim-$w, $black);
    }
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

function makegraph($im, $graph, $x0, $y0, $xlim, $ylim)
{
    global $black, $font, $dbpath;

    switch ($graph) {
        case 0:
        default:
            $data = rrd_fetch($dbpath.'ds18b20.rrd', array('AVERAGE', '-s', '-3d', '-e', 'now'));
            $inp = $data['data']['t5'];
            $round = 1;
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
            $round = 200;
            break;
    }

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

    $xcnt = 12;
    $ycnt = floor($ylim/20);
    for ($y = 0; $y < $ycnt; $y++) {
        imagettfright($im, 7, $x0-3, $y0+4-$y*$ylim/($ycnt-1), $black, $font, round($grmin+($grmax-$grmin)*$y/($ycnt-1), 1));
	imageline($im, $x0-2, $y0-$y*$ylim/($ycnt-1), $x0, $y0-$y*$ylim/($ycnt-1), $black);
	for ($x = 1; $x <= $xcnt; $x++) {
	    imagesetpixel($im, $x0+$x*($xlim/$xcnt), $y0-$y*($ylim/($ycnt-1)), $black);
	}
    }
    for ($x = 1; $x < count($grval); $x++) imageline($im, $x0+$x-1, $y0-$grval[$x-1], $x0+$x, $y0-$grval[$x], $black);
}

function searchForDT($dt, $array) {
   foreach ($array as $key) {
       if ($key['dt'] === $dt) return $key;
   }
   return null;
}

function makeall($im, $db, $ds18b20, $sht30, $reed, $tank, $doorbell)
{
    global $black, $font, $api_weather, $api_forecast, $dow, $dow_full;

    imagettfcenter($im, 14,  53,  41, $black, $font, $ds18b20['t5']);
    imagettfcenter($im, 14, 159,  41, $black, $font, $sht30['t']);
    imagettfcenter($im, 14, 241,  41, $black, $font, $sht30['hum']);
    imagettfcenter($im, 14, 322,  41, $black, $font, $sht30['co2']);
    imagettfcenter($im, 14, 427,  41, $black, $font, $ds18b20['t3']);
    imagettfcenter($im, 14, 530,  41, $black, $font, $ds18b20['t1']);
    if ($sht30['co2'] > 1200) imagebox($im, 277, 0, 366, 48); // co2
    
    imagettfcenter($im, 9,  440,  85, $black, $font, $reed[0][0] == 'C' ? "zavřeno" : "otevřeno");
    imagettfcenter($im, 9,  440, 124, $black, $font, ($reed[0][1] == 'C' && $reed[0][2] == 'C' && $reed[0][3] == 'C' && $reed[0][4] == 'C') ? "zavřeno" : "otevřeno");
    imagettfcenter($im, 9,  440, 167, $black, $font, ($reed[0][5] == 'C' && $reed[0][6] == 'C' && $reed[0][7] == 'C') ? "zavřeno" : "otevřeno");
    imagettfcenter($im, 9,  362, 167, $black, $font, $reed[0][9] == 'C' ? "zavřeno" : "otevřeno");
    imagettfcenter($im, 10, 360,  93, $black, $font, $tank[0]);
    imagettfcenter($im, 10, 360, 115, $black, $font, $tank[1]);
    if ($reed[0][0] != 'C') imagebox($im, 400, 52, 478, 94); // vst.dvere
    if ($reed[0][3] != 'C') imagebox($im, 400, 89, 478, 131); // terasa
    if ($reed[0][9] != 'C') imagebox($im, 322, 133, 397, 176); // garaz
    if ($reed[0][17] != '0') imagebox($im, 322, 52, 396, 129); // cerpadlo
    
    imagettfcenter($im, 10, 608,  20, $black, $font, $dow[date("w")] . date(" j.n."));
    imagettfcenter($im, 10, 608,  40, $black, $font, date("H:i"));

    if (!empty($doorbell)) {
        imagettfcenter($im, 10, 565,  174, $black, $font, "Zvonek @ ".$doorbell[0].(count($doorbell)>1?"+":""));
    }
    
    makegraph($im, 0, 29, 177, 274, 110);
    makegraph($im, 2, 29, 270, 274, 63);
    makegraph($im, 3, 29, 364, 274, 63);

    $ctx = stream_context_create(array('http'=>array('timeout'=>5)));
    $json = file_get_contents($api_weather, false, $ctx);
    $weather = json_decode($json, true);
    $json = file_get_contents($api_forecast, false, $ctx);
    $forecast = json_decode($json, true);
    
    $deg = ($weather['wind']['deg'] + 22.5) % 360;
    if (!array_key_exists('deg', $weather['wind'])) $wind = "";
    elseif ($deg <= 22.5) $wind = "S ";
    elseif ($deg <= 67.5) $wind = "SV ";
    elseif ($deg <= 112.5) $wind = "SV ";
    elseif ($deg <= 157.5) $wind = "V ";
    elseif ($deg <= 202.5) $wind = "JV ";
    elseif ($deg <= 247.5) $wind = "J ";
    elseif ($deg <= 292.5) $wind = "JZ ";
    elseif ($deg <= 337.5) $wind = "Z ";
    else $wind = "SZ ";
    
    if (array_key_exists('rain', $weather) && array_key_exists('snow', $weather)) $rain = strval($weather['rain']['1h'] + $weather['snow']['1h'])."mm";
    elseif (array_key_exists('rain', $weather)) $rain = $weather['rain']['1h']."mm";
    elseif (array_key_exists('snow', $weather)) $rain = $weather['snow']['1h']."mm";
    else $rain = "---";
    
    imagettftext($im, 10,0, 506, 199, $black, $font, round($weather['main']['temp'], 1).'°C');
    imagettftext($im, 10,0, 506, 218, $black, $font, $weather['main']['pressure'].'hpa');
    imagettftext($im, 10,0, 506, 237, $black, $font, $weather['main']['humidity'].'%');
    imagettftext($im, 10,0, 506, 256, $black, $font, $wind.round($weather['wind']['speed'], 0).'m/s');
    imagettftext($im, 10,0, 506, 275, $black, $font, $rain);
    imagettfcenter($im, 10, 608, 224, $black, $font, date("H:i", $weather['sys']['sunrise']));
    imagettfcenter($im, 10, 608, 276, $black, $font, date("H:i", $weather['sys']['sunset']));
    
    $icon = imagecreatefrompng("inc/".$weather['weather']['0']['icon'].".png");
    imagecopy($im, $icon, 353, 197, 0, 0, 60, 48);
    imagedestroy($icon);
    imagettfcenter($im, 11, 384, 260, $black, $font, $weather['weather']['0']['description'], 1);
    
    $dt = strtotime("tomorrow noon utc");
    for ($day = 0; $day < 4; $day++) {
        $fcday = searchForDT($dt + $day*86400, $forecast['list']);
        $fcnight = searchForDT($dt + $day*86400-6*3600, $forecast['list']);
    
        imagettfcenter($im, 9, 360+$day*80, 300, $black, $font, $dow_full[date("w", $fcday['dt'])]);
        $icon = imagecreatefrompng("inc/".$fcday['weather']['0']['icon'].".png");
        imagecopy($im, $icon, 330+$day*80, 302, 0, 0, 60, 48);
        imagedestroy($icon);
        imagettfcenter($im, 9, 360+$day*80, 360, $black, $font, $fcday['weather']['0']['description']);
        imagettfcenter($im, 10, 360+$day*80, 378, $black, $font, round($fcnight['main']['temp'], 0).' / '.round($fcday['main']['temp'], 0).'°C');
    }
}

$db = new PDO('sqlite:'.$dbpath.'tinyha.db') or die("cannot open database");

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
    "SELECT val FROM state WHERE what = 101 and dt > datetime('now', '-30 second') LIMIT 1");
if (!($reed = $stmt->fetch(PDO::FETCH_NUM))) {
    $reed = array(0=>'XXXXXXXX-XXXXXX-XXXXXXXXX');
}

$data = rrd_lastupdate($dbpath.'tank2.rrd');
if ($data === FALSE || time() - $data['last_update'] > 600) {
    $tank = array(0=>'-', 1=>'-');
} else {
    $tank = array(
        0 => sprintf('%dl', $data['data'][0]),
        1 => sprintf('%dl', $data['data'][1]));
}

$stmt = $db->query(
    "select strftime('%H:%M', dt, 'localtime') from log".
    " where what = 202 and dt > datetime('now', 'start of day')".
    " order by id desc limit 2");
$doorbell = $stmt->fetchAll(PDO::FETCH_COLUMN,0);

if (isset($_GET['png'])) {
    makeall($im, $db, $ds18b20, $sht30, $reed, $tank, $doorbell);
    header("Content-type: image/png");
    imagepng($im);
} else {
    session_id("def75");
    session_start();

    $old_time = $_SESSION['time'];
    $new_time = time();
    $old_values = $_SESSION['values'];
    $new_values = array($ds18b20['t5'], $sht30['t'], $sht30['hum'], $sht30['co2']);

    $refresh = ($new_time-$old_time > 10*60) ||
        (abs($old_values[0]-$new_values[0]) > 0.8) ||
        (abs($old_values[1]-$new_values[1]) > 0.4) ||
        (abs($old_values[2]-$new_values[2]) > 5) ||
        (abs($old_values[3]-$new_values[3]) > 50);

    if (($refresh && ($new_time-$old_time > 1*60)) || isset($_GET['reset'])) {
        $_SESSION['time'] = $new_time;
        $_SESSION['values'] = $new_values;
	makeall($im, $db, $ds18b20, $sht30, $reed, $tank, $doorbell);
        $pbm = imagebw($im);
        header("Content-type: image/x-portable-bitmap");
        echo $pbm;
    } else {
        header("HTTP/1.1 304 Not Modified");
        header("Connection: close");
    }
}

$db = null;
imagedestroy($im);

?>
