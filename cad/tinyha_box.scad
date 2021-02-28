union() {
    difference() {
        translate([0.7,0,4.5]) {
            intersection() {
                cube([47,39,9], center=true);
                rotate(45) {
                    cube(55, center=true);
                }
            }
        }
        translate([0.7,0,5.1]) {
            intersection() {
                cube([46,38,9], center=true);
                rotate(45) {
                    cube(54, center=true);
                }
            }
        }
        translate([0,0,4.5]) {
            cylinder(20,5.0,5.0,center=true,$fn=50);
        }
    }

    translate([+14,0,1.8]) {
        cylinder(3.6,1.5,1.5,center=true,$fn=10);
    }
    translate([-13,+12,1.8]) {
        cylinder(3.6,1.5,1.5,center=true,$fn=10);
    }
    translate([-13,-12,1.8]) {
        cylinder(3.6,1.5,1.5,center=true,$fn=10);
    }
    translate([+22.5,+11,1.8]) {
        cylinder(3.6,1.5,1.5,center=true,$fn=10);
    }
    translate([+22.5,-11,1.8]) {
        cylinder(3.6,1.5,1.5,center=true,$fn=10);
    }

    translate([0,0,4.5]) {
        difference() {
            cylinder(9.0,5.4,5.0,center=true,$fn=50);
            cylinder(9.1,4.9,4.5,center=true,$fn=50);
        }
    }
}
