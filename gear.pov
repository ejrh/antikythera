#version 3.6;

#include "colors.inc"
#include "math.inc"
#include "transforms.inc"
#include "metals.inc"


global_settings {
  assumed_gamma 1.0
}

// ----------------------------------------

camera {
  location  <0, 5, 4>
  direction 1.5*z
  right     x*image_width/image_height
  look_at   <0.0, 0.0,  0.0>
}

sky_sphere {
  pigment {
    gradient y
    color_map {
      [0.0 rgb <0.6,0.7,1.0>]
      [0.7 rgb <0.0,0.1,0.8>]
    }
  }
}

light_source {
  <1, 3, 1>
  color White
}

#declare ToothProfileAngle = function(BaseRadius, r)
{
    360*sqrt(r*r - BaseRadius*BaseRadius)/(2*pi*BaseRadius)
}     

#macro Gear(PitchRadius, PitchAngle, Thickness, NumTeeth, CanonicalRadius)
union {
    #local BaseRadius = PitchRadius * cos(radians(PitchAngle));
    #local ActionLen = PitchRadius * sin(radians(PitchAngle)); 
    
    difference {
        cylinder { <0,0,0>, <0,Thickness,0>, BaseRadius }
        cylinder { <0,-0.001,0>, <0,Thickness+0.001,0>, BaseRadius-Thickness }
    }
    cylinder { <0,0,0>, <0,Thickness,0>, Thickness }
    
    #local i = 0;
    #while (i < 3)
        box { <0,0,-Thickness/2>, <BaseRadius,Thickness,Thickness/2> rotate 120*i*y }
        #local i = i + 1;
    #end
    
    
    //torus { PitchRadius, 0.001 pigment { Green } }
    
    #local i = 0;
    #while (i < NumTeeth)
        union {
             //cylinder { <BaseRadius,Thickness,0>, <BaseRadius,Thickness,-ActionLen>, 0.005 pigment { Red } }
             
             #local NUM_SEGMENTS = 5;
             
             #local ppa = sqrt(PitchRadius*PitchRadius - BaseRadius*BaseRadius)*360/(2*pi*BaseRadius);
             #local points = array[NUM_SEGMENTS+1];
             #local points2 = array[NUM_SEGMENTS+1];
             
             #local minr = BaseRadius;
             #local maxr = PitchRadius + (PitchRadius - BaseRadius);
             
             #local pitcha = ToothProfileAngle(BaseRadius, PitchRadius);
             #local pitchh = pitcha/360 * 2*pi*BaseRadius;
             #local pitcha2 = degrees(atan2(pitchh,BaseRadius));
             
             #local i2 = 0;                                                    
             #while (i2 <= NUM_SEGMENTS)
                 #local r = minr + i2/NUM_SEGMENTS*(maxr-minr);
                 #local a = ToothProfileAngle(BaseRadius, r);
                 #local h = a/360 * 2*pi*BaseRadius;
                 #local a2 = degrees(atan2(h,BaseRadius));
                 #local xf = transform { rotate (a-a2 + pitcha2-pitcha)*y };
                 #local p = vtransform(<r,0,0>, xf);
                 #local points[i2] = <p.x,p.z>;
                 
                 #local xf2 = transform { rotate ((360/NumTeeth/2)-(a-a2 + pitcha2-pitcha))*y };
                 #local p2 = vtransform(<r,0,0>, xf2);
                 #local p = <p.x,p.z>;
                 #local points2[i2] = <p2.x,p2.z>;
                     
                 #local i2 = i2 + 1;
             #end
             
             prism {
                 linear_spline  
                 0, Thickness+0.001,
                 (NUM_SEGMENTS+1)*2
                 
                 #local i2 = 0;                                                    
                 #while (i2 <= NUM_SEGMENTS)
                     ,points[i2]
                     
                     #local i2 = i2 + 1;
                 #end
                 
                 #local i2 = NUM_SEGMENTS;                                                    
                 #while (i2 >= 0)
                     ,points2[i2]
                     
                     #local i2 = i2 - 1;
                 #end
             }
             
             rotate (i*360/NumTeeth)*y
        }
        #local i = i + 1;
    #end
}        
#end
                                                                                                                                          
object { Gear(1.0, 22.5, 0.2, 24, 1.0) rotate 360/32*clock*y translate -x texture { T_Brass_2A } }
object { Gear(1.0, 22.5, 0.2, 24, 1.0) rotate -360/32*clock*y translate x texture { T_Brass_3A } }
object { Gear(0.5, 22.5, 0.1, 16, 1.0) rotate -360/32*clock*y translate <1,0.2,0> texture { T_Brass_3A } }
object { Gear(0.5, 22.5, 0.1, 16, 1.0) rotate 360/32*clock*y translate <1,0.2,1> texture { T_Brass_4A } }
object { Gear(0.25, 22.5, 0.05, 8, 1.0) rotate 360/32*clock*y translate <1,0.3,1> texture { T_Brass_4A } }
object { Gear(0.25, 22.5, 0.05, 8, 1.0) rotate -360/32*clock*y translate <0.5,0.3,1> texture { T_Brass_5A } }
