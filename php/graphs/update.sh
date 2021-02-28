#!/bin/sh

cd /var/www/html/graphs

rrdtool graph sht30_t.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "temperature [°C]" \
    DEF:obyvak=/opt/tinyha/db/sht30.rrd:t:AVERAGE LINE1:obyvak#0000FF:"obyvak" \
    DEF:spajz=/opt/tinyha/db/ds18b20.rrd:t2:AVERAGE LINE1:spajz#FF0000:"spajz"

rrdtool graph garaz.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now --vertical-label "temperature [°C] - garaz" \
    DEF:t3=/opt/tinyha/db/ds18b20.rrd:t3:AVERAGE LINE1:t3#0000FF

rrdtool graph sht30_co2.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now -X 0 --vertical-label "CO2 [ppm]" \
    DEF:co2=/opt/tinyha/db/sht30.rrd:co2:AVERAGE LINE1:co2#0000FF

rrdtool graph sht30_hum.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now --vertical-label "humidity [%]" \
    DEF:hum=/opt/tinyha/db/sht30.rrd:hum:AVERAGE LINE1:hum#0000FF

rrdtool graph ds18b20.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "temperature [°C]" \
    DEF:t5=/opt/tinyha/db/ds18b20.rrd:t5:AVERAGE LINE1:t5#0000FF:"venkovni - TinyHA" \
    DEF:BT1=/opt/tinyha/db/nibe.rrd:BT1:AVERAGE LINE1:BT1#FF0000:"BT1 outdoor temp."

rrdtool graph nibe_water.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "temperature [°C]" \
    DEF:BT6=/opt/tinyha/db/nibe.rrd:BT6:AVERAGE LINE1:BT6#0000FF:"BT6 hot water charging" \
    DEF:BT7=/opt/tinyha/db/nibe.rrd:BT7:AVERAGE LINE1:BT7#FF0000:"BT7 hot water top"

rrdtool graph nibe_heat1.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "degree-minutes" \
    DEF:DM=/opt/tinyha/db/nibe.rrd:DM:AVERAGE LINE1:DM#0000FF

rrdtool graph nibe_heat2.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "temperature [°C]" \
    DEF:S1=/opt/tinyha/db/nibe.rrd:S1:AVERAGE LINE1:S1#0000FF:"S1 calculated flow temp." \
    DEF:BT25=/opt/tinyha/db/nibe.rrd:BT25:AVERAGE LINE1:BT25#FF0000:"BT25 external flow temp." \
    DEF:BT71=/opt/tinyha/db/nibe.rrd:BT71:AVERAGE LINE1:BT71#00FF00:"BT71 external return temp."

rrdtool graph nibe_heat2b.png -w 785 -h 220 -a PNG --slope-mode --start -12h --end now  --vertical-label "temperature [°C]" \
    --lower-limit 20 --upper-limit 35 --rigid \
    DEF:BT25=/opt/tinyha/db/nibe.rrd:BT25:AVERAGE LINE1:BT25#FF0000:"BT25 external flow temp." \
    DEF:BT71=/opt/tinyha/db/nibe.rrd:BT71:AVERAGE LINE1:BT71#0000FF:"BT71 external return temp."

rrdtool graph nibe_heat3.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "temperature [°C]" \
    DEF:BT14=/opt/tinyha/db/nibe3.rrd:BT14:AVERAGE LINE1:BT14#0000FF:"EB101-BT14 hot gas" \
    DEF:BT16=/opt/tinyha/db/nibe3.rrd:BT16:AVERAGE LINE1:BT16#008000:"EB101-BT16 evaporator"

#    DEF:BT63=/opt/tinyha/db/nibe3.rrd:BT63:AVERAGE LINE1:BT63#EE82EE:"BT63 addition temperature"
#    DEF:BT15=/opt/tinyha/db/nibe3.rrd:BT15:AVERAGE LINE1:BT15#FF0000:"EB101-BT15 liquid line" \
#    DEF:BT17=/opt/tinyha/db/nibe3.rrd:BT17:AVERAGE LINE1:BT17#FFA500:"EB101-BT17 suction gas" \
#    DEF:BT3=/opt/tinyha/db/nibe3.rrd:BT3:AVERAGE LINE1:BT3#FFFF00:"EB101-BT3 return temp." \
#    DEF:BT12=/opt/tinyha/db/nibe3.rrd:BT12:AVERAGE LINE1:BT12#4B0082:"EB101-BT12 condenser out" \

rrdtool graph nibe_heat4.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "time or count" \
    DEF:Tadd=/opt/tinyha/db/nibe2.rrd:Tadd:AVERAGE LINE1:Tadd#0000FF:"Tadd addition heater" \
    DEF:Tcomp=/opt/tinyha/db/nibe2.rrd:Tcomp:AVERAGE LINE1:Tcomp#FF0000:"Tcomp comptessor total" \
    DEF:Thot=/opt/tinyha/db/nibe2.rrd:Thot:AVERAGE LINE1:Thot#FFA500:"Thot hot water" \
    DEF:Tcool=/opt/tinyha/db/nibe2.rrd:Tcool:AVERAGE LINE1:Tcool#EE82EE:"Tadd cooling" \
    DEF:Nstart=/opt/tinyha/db/nibe2.rrd:Nstart:AVERAGE LINE1:Nstart#008000:"Nstart compressor starts"

rrdtool graph power_u.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now --vertical-label "batt voltage [V]" \
    DEF:u_batt=/opt/tinyha/db/power.rrd:u_batt:AVERAGE LINE1:u_batt#0000FF

rrdtool graph power_i.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now --vertical-label "current [A]" \
    DEF:i_batt=/opt/tinyha/db/power.rrd:i_batt:AVERAGE LINE1:i_batt#0000FF:"I_batt" \
    DEF:i_out=/opt/tinyha/db/power.rrd:i_out:AVERAGE LINE1:i_out#FF0000:"I_output"

rrdtool graph power_w.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "sys power [W]" \
    DEF:pwr_out=/opt/tinyha/db/power.rrd:pwr_out:AVERAGE LINE1:pwr_out#0000FF

rrdtool graph tank.png -w 785 -h 220 -a PNG --slope-mode --start -3d --end now  --vertical-label "litres [l]" \
    DEF:litres=/opt/tinyha/db/tank2.rrd:litres:AVERAGE LINE1:litres#0000FF:"water consumption" \
    DEF:dist=/opt/tinyha/db/tank2.rrd:tank:AVERAGE LINE1:dist#FF0000:"capacity"
