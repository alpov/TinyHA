<!DOCTYPE html>
<html>
    <head>
        <title>TinyHA</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="bootstrap/bootstrap-theme.min.css">
        <link rel="stylesheet" href="bootstrap/bootstrap.min.css">
    </head>
    <body>

    <div class="container">
        <h3>Vstupní dveře <span class="badge" id="blinds-01-state"></span>
                          <span class="badge btn-warning" id="temp-T5"></span>
                          <span class="badge" id="outside-light"></span></h3>

        <h3>Kamery <a href="camHi.m3u" class="badge btn-primary">M3U highQ</a>
                   <a href="camLo.m3u" class="badge btn-primary">M3U lowQ</a>
                   <span class="badge" id="main-power"></span></h3>
        <a href="cam.php?cam=1" class="btn btn-success">Branka</a>
        <a href="cam.php?cam=2" class="btn btn-success">Zahrada</a>
        <a href="cam.php?cam=3" class="btn btn-success">Garáž</a>
        <a href="graphs/" class="btn btn-primary">RRD grafy</a>

        <h3>Napájení <span class="badge btn-danger" id="power-i-batt"></span>
                     <span class="badge btn-success" id="power-i-out"></span>
                     <span class="badge btn-success" id="power-u-batt"></span>
                     <span class="badge btn-info" id="power-pwr-out"></span></h3>

        <h3>Garáž <span class="badge" id="garage-state"></span>
                  <span class="badge btn-warning" id="temp-T3"></span>
                  <button type="button" class="btn btn-danger" id="garage-updn" href="#">Vrata garáže</button></h3>

        <h3>Čerpadlo <span class="badge" id="pump-pwr"></span>
                     <span class="badge btn-warning" id="pump-litres"></span>
                     <span class="badge btn-info" id="pump-dist"></span>
                  <button type="button" class="btn btn-danger" id="pump-on-off" href="#">Čerpadlo</button></h3>

        <h3>Ohřev TUV <span class="badge" id="water-block"></span>
                  <button type="button" class="btn btn-danger" id="water-block-on" href="#">Zablokovat</button>
                  <button type="button" class="btn btn-danger" id="water-block-off" href="#">Odblokovat</button></h3>

        <h3>Koupelna nahoře <span class="badge" id="wash3-state"></span>
                  <button type="button" class="btn btn-danger" id="wash3-on-off" href="#">Topení 30min</button></h3>

        <h3>Koupelna dole <span class="badge" id="wash4-state"></span>
                  <button type="button" class="btn btn-danger" id="wash4-on-off" href="#">Topení 30min</button></h3>

        <h3>Špajz <span class="badge btn-warning" id="temp-T1"></span>
                  <span class="badge btn-warning" id="temp-T2"></span></h3>

        <h3>LAN   <span class="badge btn-warning" id="ping-openwrt">Router</span>
                  <span class="badge btn-warning" id="ping-nsa325">Debian</span>
                  <span class="badge btn-warning" id="ping-epaper">ePaper</span>
                  <span class="badge btn-warning" id="ping-nibe">Nibe</span>
                  <span class="badge btn-warning" id="ping-tv">Kodi</span></h3>
        <h3>CAM   <span class="badge btn-warning" id="ping-pvr">PVR</span>
                  <span class="badge btn-warning" id="ping-cam-1">CAM-1</span>
                  <span class="badge btn-warning" id="ping-cam-2">CAM-2</span>
                  <span class="badge btn-warning" id="ping-cam-3">CAM-3</span></h3>

        <h3>Pracovna <span class="badge" id="blinds-02-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=2&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=2&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=2&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=2&action=up');">Vytáhnout</button>

        <h3>Dveře u jídelny <span class="badge" id="blinds-03-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=3&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=3&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=3&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=3&action=up');">Vytáhnout</button>

        <h3>Rohové okno levé</h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=4&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=4&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=4&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=4&action=up');">Vytáhnout</button>

        <h3>Rohové okno zadní</h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=5&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=5&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=5&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=5&action=up');">Vytáhnout</button>

        <h3>Dveře na terasu <span class="badge" id="blinds-06-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=6&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=6&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=6&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=6&action=up');">Vytáhnout</button>

        <h3>Kuchyň <span class="badge" id="blinds-07-state"></span>
                   <span class="badge btn-warning" id="sht-t"></span>
                   <span class="badge btn-info" id="sht-co2"></span>
                   <span class="badge btn-info" id="sht-hum"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=7&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=7&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=7&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=7&action=up');">Vytáhnout</button>

        <h3>Patro velká terasa <span class="badge" id="blinds-08-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=8&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=8&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=8&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=8&action=up');">Vytáhnout</button>

        <h3>Patro malá terasa <span class="badge" id="blinds-09-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=9&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=9&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=9&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=9&action=up');">Vytáhnout</button>

        <h3>Patro pokoj sever <span class="badge" id="blinds-10-state"></span></h3>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=10&action=close');">Zavřít</button>
        <button type="button" class="btn btn-primary" onClick="$.ajax('setBlinds.php?dev=10&action=open');">Otevřít</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=10&action=down');">Spustit</button>
        <button type="button" class="btn btn-info" onClick="$.ajax('setBlinds.php?dev=10&action=up');">Vytáhnout</button>

        <h3>Zvonek poslední týden</h3>
	<pre>
<?php

$db = new PDO('sqlite:/opt/tinyha/db/tinyha.db') or die("cannot open database");

$stmt = $db->query(
    "select strftime('%d.%m. %H:%M', dt, 'localtime') from log".
    " where what = 202 and dt > datetime('now', '-7 days')".
    " order by id desc");

$doorbell = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);

echo empty($doorbell) ? "N/A" : implode("<br>", $doorbell);

?>
	</pre>

        <h3>Záznam událostí za poslední den</h3>
	<pre>
<?php

$stmt = $db->query(
    "select strftime('%d.%m. %H:%M:%S', dt, 'localtime') || ' -> ' || val from log".
    " where what = 201 and dt > datetime('now', '-1 days')".
    " order by id asc");

$reed = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);

echo empty($reed) ? "N/A" : implode("<br>", $reed);

$db = null;

?>
	</pre>

        <p></p>
    </div> <!-- /container -->

    <div class="modal" id="confirm-open" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">Potvrzení</h4>
                </div>

                <div class="modal-body">
                    <p>Vrata garáže jsou nyní uzavřena. Potvrďte otevření!</p>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Zrušit</button>
                    <button type="button" class="btn btn-danger" data-dismiss="modal" onclick="garageOpen();">Otevřít</a>
                </div>
            </div>
        </div>
    </div>

    <div class="modal" id="confirm-pump" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">Potvrzení</h4>
                </div>

                <div class="modal-body">
                    <p>Zapnout čerpadlo?</p>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Zrušit</button>
                    <button type="button" class="btn btn-danger" data-dismiss="modal" onclick="pumpOnOff(1);">Zapnout</a>
                </div>
            </div>
        </div>
    </div>


    <script src="bootstrap/jquery-3.3.1.min.js"></script>
    <script src="bootstrap/bootstrap.min.js"></script>

    <script type="text/javascript">

        function setBadge(name, mode) {
            if (mode == 'C') {
                document.getElementById(name).innerHTML = "Zavřeno";
                document.getElementById(name).className = "badge btn-success";
            }
            else if (mode == '0') {
                document.getElementById(name).innerHTML = "Vypnuto";
                document.getElementById(name).className = "badge btn-success";
            }
            else if (mode == 'O') {
                document.getElementById(name).innerHTML = "Otevřeno";
                document.getElementById(name).className = "badge btn-danger";
            }
            else if (mode == '1') {
                document.getElementById(name).innerHTML = "Zapnuto";
                document.getElementById(name).className = "badge btn-danger";
            }
            else {
                document.getElementById(name).innerHTML = "Chyba";
                document.getElementById(name).className = "badge btn-warning";
            }
        }

        function setBadge2(name, mode) {
            if (mode == '0') {
                document.getElementById(name).className = "badge btn-success";
            }
            else if (mode == '1') {
                document.getElementById(name).className = "badge btn-danger";
            }
            else {
                document.getElementById(name).className = "badge btn-warning";
            }
        }

        function setBadgesByBus(data) {
            var badges = ["blinds-01-state", "blinds-02-state", "blinds-03-state", "blinds-06-state",
                          "blinds-07-state", "blinds-08-state", "blinds-09-state", "blinds-10-state",
                          "", // ---
                          "garage-state", "", "main-power", "", "", "",
                          "", // ---
                          "", "pump-pwr", "wash3-state", "wash4-state", "outside-light", "water-block", "", "", ""];
            var badges2= ["ping-openwrt", "ping-nsa325", "ping-nibe", "ping-tv", "ping-pvr",
                          "ping-cam-1", "ping-cam-2", "ping-cam-3", "ping-epaper"];

            val = data.split(",");
            for (i = 0; i < badges.length; i++) {
                if (badges[i] != "") setBadge(badges[i], val[0][i]);
            }
            document.getElementById("pump-litres").innerHTML = val[1];
            document.getElementById("pump-dist").innerHTML = val[2];
            for (i = 0; i < badges2.length; i++) {
                setBadge2(badges2[i], val[3][i]);
            }
            document.getElementById("power-i-batt").innerHTML = val[4];
            document.getElementById("power-i-out").innerHTML = val[5];
            document.getElementById("power-u-batt").innerHTML = val[6];
            document.getElementById("power-pwr-out").innerHTML = val[7];
        }

        function updateInputs() {
            $.get("dbGetBus.php", function(data, status) {
                if (status != "success") data = "XXXXXXXXXXXXXXXXXXXX,Chyba,Chyba,22222222222222222222";
                setBadgesByBus(data);
                setTimeout(updateInputs, 2000);
            }).fail(function(data, textStatus, xhr) {
                setBadgesByBus("XXXXXXXXXXXXXXXXXXXX,Chyba,Chyba,22222222222222222222");
                setTimeout(updateInputs, 2000);
            });
        }

        function updateTemps() {
            $.get("dbGetMeas.php", function(data, status) {
                if (status != "success") data = "Chyba,Chyba,Chyba,Chyba,Chyba,Chyba,Chyba,Chyba";
                val = data.split(",");
                document.getElementById("temp-T1").innerHTML = val[0];
                document.getElementById("temp-T2").innerHTML = val[1];
                document.getElementById("temp-T3").innerHTML = val[2];
                document.getElementById("temp-T5").innerHTML = val[4];
                document.getElementById("sht-t").innerHTML = val[5];
                document.getElementById("sht-co2").innerHTML = val[6];
                document.getElementById("sht-hum").innerHTML = val[7];
            }).fail(function(data, textStatus, xhr) {
                document.getElementById("temp-T1").innerHTML = "Chyba";
                document.getElementById("temp-T2").innerHTML = "Chyba";
                document.getElementById("temp-T3").innerHTML = "Chyba";
                document.getElementById("temp-T5").innerHTML = "Chyba";
                document.getElementById("sht-t").innerHTML = "Chyba";
                document.getElementById("sht-co2").innerHTML = "Chyba";
                document.getElementById("sht-hum").innerHTML = "Chyba";
            });
            setTimeout(updateTemps, 10000);
        }

        function garageOpen() {
            $.ajax('setGarageOpen.php?auth=963');
        }

        function pumpOnOff(onOff) {
            $.ajax('setOutput.php?auth=964&on=' + onOff + '&minutes=90');
        }

        function waterBlock(onOff) {
            $.ajax('setOutput.php?auth=629&on=' + onOff);
        }

        $.ajaxSetup({timeout: 2000});
        $(document).ready(updateInputs);
        $(document).ready(updateTemps);

        $("#garage-updn").click(function() {
            if (document.getElementById("garage-state").innerHTML == "Zavřeno") {
                $("#confirm-open").modal();
            } else {
                garageOpen();
            }
        });

        $("#pump-on-off").click(function() {
            if (document.getElementById("pump-pwr").innerHTML == "Vypnuto") {
                $("#confirm-pump").modal();
            } else {
                pumpOnOff(0);
            }
        });

        $("#water-block-on").click(function() {
            waterBlock(1);
        });

        $("#water-block-off").click(function() {
            waterBlock(0);
        });

        $("#wash3-on-off").click(function() {
            if (document.getElementById("wash3-state").innerHTML == "Vypnuto") {
                $.ajax('setOutput.php?auth=383&on=1&minutes=30');
            } else {
                $.ajax('setOutput.php?auth=383&on=0');
            }
        });

        $("#wash4-on-off").click(function() {
            if (document.getElementById("wash4-state").innerHTML == "Vypnuto") {
                $.ajax('setOutput.php?auth=384&on=1&minutes=30');
            } else {
                $.ajax('setOutput.php?auth=384&on=0');
            }
        });

    </script>

  </body>
</html>
