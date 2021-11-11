-- tinyha_onewire.sh: 1wire cidla po 10sec
-- tinyha__clean_db.sh: denne mazany zaznamy stari nez 3 dny
-- REQ: posledni zaznam
-- REQ: t5 udaje za posledni 3 dny, 274/150 bodu
rrdtool create ds18b20.rrd --step 1m \
    DS:t1:GAUGE:5m:-40:80 \
    DS:t2:GAUGE:5m:-40:80 \
    DS:t3:GAUGE:5m:-40:80 \
    DS:t4:GAUGE:5m:-40:80 \
    DS:t5:GAUGE:5m:-40:80 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

-- meas.php: vzduch po 10sec
-- tinyha__clean_db.sh: denne mazany zaznamy stari nez 3 dny
-- REQ: posledni zaznam
-- REQ: hum, t, co2 udaje za posledni 3 dny, 274/150 bodu
rrdtool create sht30.rrd --step 1m \
    DS:t:GAUGE:5m:-40:80 \
    DS:co2:GAUGE:5m:0:5000 \
    DS:hum:GAUGE:5m:0:100 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

-- tinyha_reed.sh: mereni retencky po 20sec
-- tinyha__clean_db.sh: denne mazany zaznamy stari nez 10 dnu
-- tinyha__clean_db.sh: denne ulozeny 1 zaznam
-- REQ: posledni zaznam
rrdtool create tank.rrd --step 1m \
    DS:litres:GAUGE:5m:0:5000 \
    DS:dist:GAUGE:5m:0:5000 \
    DS:err:GAUGE:5m:0:100 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y RRA:MAX:0.5:1d:1y
rrdtool create tank2.rrd --step 1m \
    DS:litres:GAUGE:5m:0:5000 \
    DS:tank:GAUGE:5m:0:5000 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y RRA:MAX:0.5:1d:1y

-- mereni napajeciho zdroje
rrdtool create power.rrd --step 1m \
    DS:i_batt:GAUGE:5m:-10:10 \
    DS:i_out:GAUGE:5m:-10:10 \
    DS:u_batt:GAUGE:5m:0:20 \
    DS:pwr_out:GAUGE:5m:0:100 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

rrdtool create nibe.rrd --step 1m \
    DS:BT6:GAUGE:5m:-40:100 \
    DS:BT7:GAUGE:5m:-40:100 \
    DS:BT1:GAUGE:5m:-40:100 \
    DS:DM:GAUGE:5m:-500:500 \
    DS:S1:GAUGE:5m:-40:100 \
    DS:BT25:GAUGE:5m:-40:100 \
    DS:BT71:GAUGE:5m:-40:100 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

rrdtool create nibe2.rrd --step 1m \
    DS:Tadd:GAUGE:5m:0:1000000 \
    DS:Tcomp:GAUGE:5m:0:1000000 \
    DS:Thot:GAUGE:5m:0:1000000 \
    DS:Tcool:GAUGE:5m:0:1000000 \
    DS:Nstart:GAUGE:5m:0:1000000 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

rrdtool create nibe3.rrd --step 1m \
    DS:BT14:GAUGE:5m:-40:100 \
    DS:BT15:GAUGE:5m:-40:100 \
    DS:BT17:GAUGE:5m:-40:100 \
    DS:BT3:GAUGE:5m:-40:100 \
    DS:BT16:GAUGE:5m:-40:100 \
    DS:BT12:GAUGE:5m:-40:100 \
    DS:BT63:GAUGE:5m:-40:100 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y

rrdtool create optomeas.rrd --step 1m \
    DS:water:GAUGE:5m:0:1000000 \
    DS:power:GAUGE:5m:0:1000000 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y RRA:MAX:0.5:1d:1y

rrdtool create optomeas2.rrd --step 1m \
    DS:water:GAUGE:5m:0:1000000 \
    DS:power:GAUGE:5m:0:1000000 \
    RRA:AVERAGE:0.5:1m:5d RRA:AVERAGE:0.5:1h:1y RRA:MAX:0.5:1d:1y


-- NOVA VERZE

CREATE TABLE state (
    what integer primary key,
    dt datetime not null default current_timestamp,
    val varchar(30)
);
INSERT INTO state (what) VALUES (101), (102), (103);
-- 101...reed
-- 102...online
-- 103...armed

CREATE TABLE log (
    id integer primary key autoincrement,
    what integer not null,
    dt datetime not null default current_timestamp,
    val varchar(30)
);
-- 201...reed
-- 202...doorbell
DROP TRIGGER IF EXISTS log_reed;
CREATE TRIGGER log_reed AFTER UPDATE ON state
WHEN new.what = 101 and
    (substr(new.val, 1, 10) || '-' || substr(new.val, 12, 1)) <>
    (SELECT val FROM log WHERE what = 201 ORDER BY id DESC LIMIT 1)
BEGIN
    INSERT INTO log (what, val) VALUES (201, substr(new.val, 1, 10) || '-' || substr(new.val, 12, 1));
END;
INSERT INTO log (what, val) VALUES (201, 'init');

CREATE TABLE output (
    id integer primary key autoincrement,
    dt datetime not null,
    filename varchar(50),
    filevalue varchar(20)
);
-- ponechat puvodni
-- pokud filename==sqlite, tak filevalue bude sql prikaz
