//projection(cut=true) translate([0,0,-1])
union() {
    difference() {
        translate([0,0,4.5]) {
            intersection() {
                cube([20,36.5,9], center=true);
                translate([0,0,0]) rotate(45) {
                    cube(36, center=true);
                }
            }
        }
        translate([0,0,5.1]) {
            intersection() {
                cube([19,35.5,9], center=true);
                translate([0,0,0]) rotate(45) {
                    cube(35, center=true);
                }
            }
        }
    }

    translate([-8.3,  +12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([-8.3,  -12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+8.3,  +12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
    translate([+8.3,  -12,1.8]) cylinder(3.6,1.5,1.5,center=true,$fn=10);
}
