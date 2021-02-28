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

-- tinyha_reed.sh: jediny zaznam, aktualni stav vstupu po 2sec
-- tinyha__clean_db.sh: mazani pro jistotu
-- REQ: posledni zaznam
CREATE TABLE reed (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    reed varchar(20)
);

-- tinyha_reed.sh: testovani dostupnosti po 20sec
-- tinyha__clean_db.sh: denne mazany zaznamy stari nez 3 dny
-- REQ: posledni zaznam
CREATE TABLE online (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    online varchar(20)
);

-- tinyha_reed.sh, setPumpOnOff.php, setHeater.php: automaticke vypinani/zapinani vystupu podle zaznamu
-- REQ: postupne jeden po druhem + delete
CREATE TABLE output (
    id integer primary key autoincrement,
    dt datetime not null,
    filename varchar(50),
    filevalue varchar(20)
);

-- tinyha_doorbell.sh: zaznamy zazvoneni
-- REQ: zaznamy za poslednich 7 dnu
CREATE TABLE doorbell (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp
);
