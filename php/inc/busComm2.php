<?php

//error_reporting(E_ALL);
include(ini_get('extension_dir') . '/wiringpi.php');

function busOpen()
{
    $fb = wiringpi::serialOpen('/dev/ttyS0', 19200);
    if ($fb == -1) die("cannot open RS485");
    return $fb;
}

function busClose($fb)
{
    wiringpi::serialClose($fb);
}

function busCommInternal($fb, $dev, $cmd, $val = 1, $debug = false)
{
    $xor = $dev ^ $cmd ^ ($val >> 8) ^ ($val & 0xFF);
    $request = pack("CCnC", $dev, $cmd, $val, $xor);

//    wiringPi::serialFlush($fb);
    for ($i = 0; $i < 5; $i++) wiringpi::serialPutchar($fb, $request[$i]);
    for ($i = 0; $i < 5; $i++) echo ord($request[$i]).",";
    if ($debug) echo "Sent to #" . $dev . ", command: " . array_shift(unpack("H*", $request)) . "\n\n";
    usleep(500000); // 7000
    if ($debug) echo "Data avail: " . wiringpi::serialDataAvail($fb) . "\n\n";
//    if (wiringpi::serialDataAvail($fb) != 5) return false;
    $response = "     ";
    for ($i = 0; $i < 5; $i++) $response[$i] = wiringpi::serialGetchar($fb);
    if ($debug) echo "Response: " . array_shift(unpack("H*", $response)) . "\n";

//    if (strlen($response) != 5) return false;

    $arr = unpack("C1dev/C1cmd/n1value/Ccrc", $response);
    $resp_dev = $arr['dev'];
    $resp_cmd = $arr['cmd'];
    $resp_val = $arr['value'];

    $valid_dev = ($resp_dev == 255);
    $valid_cmd = ($resp_cmd == $cmd);
    $valid_crc = ((($resp_dev) ^ ($resp_cmd) ^ ($resp_val >> 8) ^ ($resp_val & 0xFF)) == $arr['crc']);

    if ($debug) echo $valid_crc ? "CRC OK\n\n" : "CRC FAIL\n\n";
    if ($debug) echo "Response from #" . $resp_dev . ", command: " . $resp_cmd . "\n";
    if ($debug) echo "Value = " . $resp_val . " = 0x" . dechex($resp_val) . "\n";

    if ($valid_dev && $valid_cmd && $valid_crc) {
        return $resp_val;
    } else {
        return false;
    }
}

function busComm($fb, $dev, $cmd, $val = 1, $debug = false)
{
    return busCommInternal($fb, $dev, $cmd, $val, $debug);
/*

    $retry = 3;

    while ($retry != 0) {
        $result = busCommInternal($fb, $dev, $cmd, $val, $debug);
        if ($result !== false) return $result;

        usleep(10000);
        dio_read($fb, 32); // flush
        $retry = $retry - 1;
    }

    return false;
*/
}

?>
