//projection(cut=true) translate([0,0,-1])
union() {
    difference() {
        translate([0,0,4.5]) {
            intersection() {
                cube([18.5,39,9], center=true);
                translate([0.7,0,0]) rotate(45) {
                    cube(36, center=true);
                }
            }
        }
        translate([0,0,5.1]) {
            intersection() {
                cube([17.5,38,9], center=true);
                translate([0.7,0,0]) rotate(45) {
                    cube(35, center=true);
                }
            }
        }
    }

    translate([-7.5,  +12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([-7.5,  -12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+6.5,  +10,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+6.5,  -10,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
}
