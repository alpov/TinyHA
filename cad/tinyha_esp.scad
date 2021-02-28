$fs=0.5;
$fa=6;

//animation view parameters
/*
$vpt = [0, 0, -28]; 

ROT = 90;
r = $t < 0.5 ? $t*4*ROT : 2*ROT- ($t-0.5)*ROT *4;
 
$vpr = [75,0,250-90+r];
//$vpr = [75,0,250];
$vpd = 350;
*/

// Type of model 
TYPE = "preview"; // [preview, front, back, backmount, wallmount]

//M3 hole
M3_HOLE_DIA = 3.8;
//M3 hole for tapping
M3_TAP_DIA = 2.8;
//M3 nut diameter
M3_NUT_DIA = 6.01;
//M3 nut height (thickness)
M3_NUT_HEIGHT = 2.4;
//M3 screw head diameter
M3_HEAD_DIA = 6.5;

// Diameter of PCB mounting holes
PCB_MOUNT_HOLE_DIA = 3.5;
// Diameter of PCB rounded edges (has same center as PCB mounting holes)
PCB_EDGE_DIA = 4.5;
// PCB width
PCB_X = 43;
// PCB height
PCB_Y = 96;
// PCB thickness
PCB_Z = 1.2;

// OLED width
OLED_X = 31.5;
// OLED total height
OLED_Y = 69;
// OLED height of real display area
OLED_Y_VISIBLE = OLED_Y;
// OLED Z coordinate of surface
OLED_Z = 3.7;
// Distance of OLED from PCB top
OLED_TOP_OFFSET = (PCB_Y-OLED_Y)/2;// 11.6;

// Diameter of camera lens (at top surface)
LENS_DIA = 10.1 + 0.5;
// Distance of camera lens center from PCB bottom
LENS_BOTTOM_OFFSET = 27.5;
// Z coordinate of camera lens surface
LENS_Z = 10;

// Diameter of PIR sensor cap
PIR_DIA = 12.5+0.5;
// Distance of PIR sensor cap from PCB bottom
PIR_BOTTOM_OFFSET = 14;
// Z coordinate of PIR sensor cap base (lowest Z of removable cap)
PIR_BASE_Z = 8.0;

// Width/height of buttons
BUTTON_XY = 5+0.5;
// Diameter of buttons rounded edges
BUTTON_EDGE_DIA = 1.5;
// Distance of buttons from PCB bottom (should be the aligned with the PIR sensor)
BUTTON_BOTTOM_OFFSET = PIR_BOTTOM_OFFSET - (BUTTON_XY/2);
// Distance of buttons from PCB side
BUTTON_SIDE_OFFSET = 1.0; 
// Z coordinate of button surface
BUTTON_Z = 5.0;

// Width of micro USB socket
USB_Y = 7;
// Height of micro USB socket
USB_X = 8;
// Z coordinate of micro USB socket surface 
USB_Z = 4 - PCB_Z;
// Distance of USB socket from PCB bottom
USB_BOTTOM_OFFSET = -1.5;

// Wall thickness
WALL_THICKNESS = 2.0;
// Use a thinner wall on front
FRONT_WALL_THICKNESS = PCB_Z;

// Z coordinate of front surface
FRONT_Z = PIR_BASE_Z + FRONT_WALL_THICKNESS;

// Wall clearance in mm
WALL_CLEARANCE = 0.3;

// Radius of cover edges
COVER_SMOOTHER = 1.5;

// Overlap of cover parts
COVER_OVERLAP = 2;

//length of countersunk head screws (M3) to mount the back
BACK_SCREW_LENGTH = 18;
//head diameter of countersunk head screws (M3)
BACK_SCREW_HEAD_DIA= 5.5 +0.5;
//Thickness of back cover
BACK_Z = BACK_SCREW_LENGTH - FRONT_Z + FRONT_WALL_THICKNESS - COVER_OVERLAP + WALL_CLEARANCE;

//echo("BACK_Z:",BACK_Z);


//Diameter of a circle used to position the holes of the wall mount
WALL_MOUNT_DIA = 45;
//Number of screws used for the wall mount
WALL_MOUNT_HOLE_COUNT = 3;
//Wall mount screws head dia (this is Spax 4.5mm...)
WALL_MOUNT_HEAD_DIA = 8.8 + 0.4;
//Diameter of screw holes for wall mount
WALL_MOUNT_HOLE_DIA = 5;



_BLOCK_Z = PCB_Z + FRONT_Z + (2*WALL_THICKNESS);

module oled(block=false)
{
  delta = block ? OLED_Y - OLED_Y_VISIBLE : 0.0;
  y = block ? OLED_Y_VISIBLE-WALL_CLEARANCE : OLED_Y;
  x = block ? OLED_X-2*WALL_CLEARANCE : OLED_X;
  
  
  z = block ? _BLOCK_Z : OLED_Z+PCB_Z;
  translate([-x/2,-y+(PCB_Y/2)-OLED_TOP_OFFSET-delta,0])
    cube([x, y, z]);  
    
  translate([0,0.1,8.7])
    scale([1.15,2.56,1])
    rotate([0,0,45]) cylinder(2,18,21,center=true,$fn=4);  
}


module rounded_cube(left_x, top_y, width_x, height_y, thickness_z, edge_dia, smooth=0)
{
  r = edge_dia/2;
  
  z_base = smooth > 0 ?  thickness_z - smooth: thickness_z;
  
  
  hull() {
    for (x = [left_x + r, left_x + width_x - r], y = [top_y - r, top_y - height_y + r]) {
      translate([x,y,0]) cylinder(h=z_base, d=edge_dia);
    }
    
    if (smooth > 0) {
      for (x = [left_x + smooth, left_x + width_x - smooth], y = [top_y - smooth, top_y - height_y + smooth])  
      {      
        translate([x,y,z_base])sphere(r=smooth, center=true);
      }
            
    }    
  }
}


module buttons(block=false)
{
    
  z = block ? _BLOCK_Z : PCB_Z + BUTTON_Z;
  
  all_x = [ (-PCB_X/2) + BUTTON_SIDE_OFFSET, (PCB_X/2) - BUTTON_SIDE_OFFSET - BUTTON_XY ];
  start_y = -(PCB_Y/2) + BUTTON_BOTTOM_OFFSET + BUTTON_XY;
  
  r = BUTTON_EDGE_DIA / 2.0;
  
  for (start_x = all_x) {
    rounded_cube(start_x, start_y, BUTTON_XY, BUTTON_XY, z, BUTTON_EDGE_DIA);       
  }  
}

module usb(block=false)
{
  y_offset = block ? (2*WALL_THICKNESS) : 0;
  
  h_usb = -34;  
    
//  translate([-PCB_X/2 + USB_BOTTOM_OFFSET - y_offset, -USB_Y/2+h_usb, +1.5])
//    cube([USB_Y + y_offset, USB_X, USB_Z+PCB_Z]);  
   
  h_sh = -9.4;
  h_mu = 7.6;  
    
   for (i = [0,1,2,3]) {
    translate([-PCB_X/2 + USB_BOTTOM_OFFSET, h_sh+h_mu*i, 3.5+1.5])
      rotate([0,90,0]) cube([4, 4, 10], center=true); //cylinder(h=10, d=2.9, center=true);   
   }

   for (i = [0:6]) {
    translate([0, 3*i+22, 6])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
    translate([0, 3*i+22, 2])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
   }
   for (i = [-0.5:6.5]) {
    translate([0, 3*i+22, 4])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
   }

}


module pcb(block=false) 
{
  clearance = block ? WALL_CLEARANCE : 0.0;
  
  // positions of edge holes
  x_off = (PCB_X / 2) - (PCB_EDGE_DIA/2) + clearance;
  y_off = (PCB_Y / 2) - (PCB_EDGE_DIA/2) + clearance;
  
  pcb_height = block ? (FRONT_Z - FRONT_WALL_THICKNESS) : PCB_Z;
 
  // PCB with mount holes
  difference() {
  
    // PCB base    
    rounded_cube(-PCB_X/2-clearance, PCB_Y/2+clearance, PCB_X+(2*clearance), PCB_Y+(2*clearance), pcb_height, PCB_EDGE_DIA);
    
    if (block==false) {
      // mount holes
      union() {
        for (x = [x_off, -x_off], y = [y_off, -y_off]) {
          translate([x,y,0])cylinder(h=4*PCB_Z, d=PCB_MOUNT_HOLE_DIA, center=true);   
        }      
      }
    }
  }
    
}

module espcam(block=false) 
{
  pcb(block);
  oled(block);
  //buttons(block);
}

module pcb_edge_mount()
{
  
  // positions of edge holes
  x_off = -(OLED_X / 2) - (32.84-OLED_X)/2 - 0.0;
  y_off = -(OLED_Y / 2) - (84.58-OLED_Y)/2 - 3.3+0.2;
  
  z = PIR_BASE_Z-WALL_CLEARANCE+2;
  
  // mount holes
  union() {
    for (x = [x_off, x_off+32.84], y = [y_off, y_off+84.58+0.2]) {
      translate([x,y,z/2+WALL_CLEARANCE+PCB_Z]) {
          cylinder(h=z-4, d=3.0, center=true);   
      }
    }      
  }
  
  translate([-21,18.5,4]) cube([3,1.5,10], center=true);
  translate([-21,-15,4]) cube([3,1.5,10], center=true);
  
}

module front_cover()
{ 
  difference() {
    
   rounded_cube(-PCB_X/2-WALL_THICKNESS, PCB_Y/2+WALL_THICKNESS, PCB_X + (2*WALL_THICKNESS) ,PCB_Y + (2*WALL_THICKNESS), FRONT_Z, PCB_EDGE_DIA,COVER_SMOOTHER);
      
    
    translate([0,0,-0.01]) {
        espcam(true);
        usb(true);
    }
  }
  pcb_edge_mount();
    
}



module back_cover()
{
  //BACK_Z;
  C = WALL_CLEARANCE;
  T = WALL_THICKNESS;
  
  // positions of edge holes
  x_off = (PCB_X / 2) - (PCB_EDGE_DIA/2);// + WALL_CLEARANCE;
  y_off = (PCB_Y / 2) - (PCB_EDGE_DIA/2);// + WALL_CLEARANCE;
  // give some more room to not crush the PCB... 
  FIX_CLEAR = 1*WALL_CLEARANCE;
  z = BACK_Z + COVER_OVERLAP - FIX_CLEAR; //PIR_BASE_Z-WALL_CLEARANCE;
    
  difference() {
    union()
    {   
      //shell
      difference() {
        rounded_cube(-PCB_X/2-T, PCB_Y/2+T, PCB_X + (2*T) ,PCB_Y + (2*T), BACK_Z, PCB_EDGE_DIA,0);
          
        translate([0,0,-0.01]) rounded_cube(-PCB_X/2-C, PCB_Y/2+C, PCB_X+(2*C) ,PCB_Y+(2*C), BACK_Z-T, PCB_EDGE_DIA,0);
        
        
      }
      //overlap
      //left_x, top_y, width_x, height_y, thickness_z, edge_dia, smooth=0
      //T = WALL_THICKNESS/2;
      W = (T/2) * 0.9;
      translate([0,0,-COVER_OVERLAP+0.01]) difference() {
        rounded_cube(-PCB_X/2-T, PCB_Y/2+T, PCB_X + (2*T) ,PCB_Y + (2*T), COVER_OVERLAP, PCB_EDGE_DIA);
        
        translate([0,0,-0.1])rounded_cube(-PCB_X/2-T+W, PCB_Y/2+T-W, PCB_X + (2*T) - (2*W) ,PCB_Y + (2*T) - (2*W), 2*COVER_OVERLAP, PCB_EDGE_DIA);   
          }      

  translate([0,-49+27,4]) cube([46,2,8], center=true);
  translate([0,-49+27,4-7]) cube([43,2,6], center=true);

    }

    shx=-44;
   for (i = [0:6]) {
    translate([0, 3*i+shx, 5])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
    translate([0, 3*i+shx, 1])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
   }
   for (i = [-0.5:6.5]) {
    translate([0, 3*i+shx, 3])
      rotate([0,90,0]) cylinder(h=60, d=1.5, center=true);   
   }

  translate([20, 0, 6.5])
      rotate([0,80,0]) cylinder(h=20, d=2.1, center=true);   

  translate([11,-49+27,3]) cube([5,3,3], center=true);
  translate([17,-49+27,3]) cube([5,3,3], center=true);

  translate([-13,-49+27,-3.6]) cube([5,3,5], center=true);
    
  }
 
    
}


module overlap()
{
  T = WALL_THICKNESS/2;
  translate([0,0,-COVER_OVERLAP+0.01])
  difference() {
    rounded_cube(-PCB_X/2-T, PCB_Y/2+T, PCB_X + (2*T) ,PCB_Y + (2*T), COVER_OVERLAP, PCB_EDGE_DIA);
    translate([0,0,-0.05]) espcam(true);
  }
}

if ("preview" == TYPE) {
  //color("PaleTurquoise", 0.7) 
  union() {
    front_cover();
    overlap();
    
  }
  
  ROT = 25;

  translate([0,0,-BACK_Z]) rotate([0,180,0]){
    back_cover();
    //translate([0,0,-(2*WALL_THICKNESS+BALL_COVER_DIA)] 
  }
  
} else if ("front" == TYPE) {
  union() {
    front_cover();
    overlap();    
  }
} else if ("back" == TYPE) {
  back_cover();

}


