<?php

function busOpen()
{
    $fb = dio_open('/dev/ttyS0', O_RDWR | O_NOCTTY | O_NONBLOCK) or die("cannot open RS485");

    dio_tcsetattr($fb, array(
        'baud' => 19200,
        'bits' => 8,
        'stop' => 1,
        'parity' => 0
    ));

    return $fb;
}

function busClose($fb)
{
    dio_close($fb);
}

function busComm($fb, $dev, $cmd, $val = 1, $debug = false)
{
//    $sem = sem_get(8000, 1, 0666, false);

    $xor = $dev ^ $cmd ^ ($val >> 8) ^ ($val & 0xFF);
    $request = pack("CCnC", $dev, $cmd, $val, $xor);

//    sem_acquire($sem);
    dio_write($fb, $request, 5);
    if ($debug) echo "Sent to #" . $dev . ", command: " . array_shift(unpack("H*", $request)) . "\n\n";
    usleep(10000); // 7000
    $response = dio_read($fb, 5);
    if ($debug) echo "Response: " . array_shift(unpack("H*", $response)) . "\n";
//    sem_release($sem);

    if (strlen($response) != 5) return false;

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

?>
