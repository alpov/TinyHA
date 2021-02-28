create table ds18b20 (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    t1 float,
    t2 float,
    t3 float,
    t4 float,
    t5 float
);

create table sht30 (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    t float,
    co2 integer,
    hum integer
);

create table reed (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    reed varchar(20)
);

create table tank (
    id integer primary key autoincrement,
    dt datetime not null default current_timestamp,
    litres integer,
    dist integer
);


insert into ds18b20 (t1, t2, t3, t4, t5) values (23.1, 24.1, 23.1, 23.5, 16.8);

insert into sht30 (t, co2, hum) values (23.5, 1080, 35);

delete from reed;
insert into reed (reed) values ('OCOOCCCOX');


delete from ds18b20 where dt < datetime('now', '-30 day');
delete from sht30 where dt < datetime('now', '-30 day');


select dt, avg(t1), avg(t2), avg(t3), avg(t4), avg(t5) from ds18b20 group by strftime('%s', dt)/3600;
