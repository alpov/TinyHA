<?php

$config = include('inc/config.php');

if ($_GET['cam'] == '1') $cam_ip = '192.168.1.11';
else if ($_GET['cam'] == '2') $cam_ip = '192.168.1.12';
else if ($_GET['cam'] == '3') $cam_ip = '192.168.1.13';
else die("Wrong camera ID");

$command = 'ffmpeg -skip_frame nokey -rtsp_transport tcp '.
'-i "rtsp://' . $cam_ip . ':554/user=' . $config['cam_user'] . '&password=' . $config['cam_password'] . '&channel=1&stream=0.sdp?" '.
'-q:v 2 -frames 1 -loglevel quiet -f image2pipe pipe:1';

$proc = popen($command, 'r');
header("Content-Type: image/jpeg");
fpassthru($proc);
pclose($proc);

?>
