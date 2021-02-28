  //h_mu = 7.6;  
  h_mu = 10;  
    
   for (i = [0,1,2,3]) {
    translate([0, h_mu*i, 0])
      rotate([0,90,0]) union() {
          translate([0,0,2.5/2]) cube([3.7, 3.7, 2.5], center=true);
          difference() {
            translate([0,0,-2.3/2]) cube([5, 7, 2.3], center=true);
            #translate([-1.26,0,-2.8+0.8/2-0.01+0.2]) cube([3.5, 4.6, 0.8], center=true);
          }
      }
   }
