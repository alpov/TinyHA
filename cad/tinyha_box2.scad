//projection(cut=true) translate([0,0,-1])
union() {
    difference() {
        translate([0.7+3.5/2,0,4.5]) {
            intersection() {
                cube([43.5,39,9], center=true);
                translate([-0.7,0,0]) rotate(45) {
                    cube(54, center=true);
                }
            }
        }
        translate([0.7+3.5/2,0,5.1]) {
            intersection() {
                cube([42.5,38,9], center=true);
                translate([-0.7,0,0]) rotate(45) {
                    cube(53, center=true);
                }
            }
        }
    }

    translate([-11,  +12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([-11,  -12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+22.5,+11,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+22.5,-11,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
}
