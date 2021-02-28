CREATE TABLE ds18b20 (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    t1 float,
    t2 float,
    t3 float,
    t4 float,
    t5 float
);
CREATE TABLE sht30 (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    t float,
    co2 integer,
    hum integer
);
CREATE TABLE tank (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    litres integer,
    dist integer,
    err integer);
CREATE TABLE tank_daily (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    litres integer,
    dist integer
);
CREATE TABLE reed (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    reed varchar(20)
);
CREATE TABLE online (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    online varchar(20)
);
CREATE TABLE output (
    id integer primary key autoincrement,
    dt datetime not null,
    filename varchar(50),
    filevalue varchar(20)
);
CREATE TABLE doorbell (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp
);
