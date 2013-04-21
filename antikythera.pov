#version 3.6;

#include "colors.inc"
#include "math.inc"
#include "transforms.inc"
#include "metals.inc"
#include "golds.inc"
#include "skies.inc"


global_settings {
  assumed_gamma 1.0
}

// ----------------------------------------

camera {
  location  <0.25, 0.5, 0.5>
  direction 1.5*z
  right     x*image_width/image_height
  look_at   <0.0, 0.0,  0.0>
}

sky_sphere { S_Cloud1 }

light_source {
  <1, 2, 1>
  color White
}
         
#macro GearBase(Radius, Depth, Thickness, AxisRadius, Name)
    #local base_radius = Radius-ToothScale;
    difference {
        cylinder { <0,0,0>, <0,Depth,0>, Radius }
        cylinder { <0,-0.001,0>, <0,Depth+0.001,0>, Radius-Thickness }
    }
    difference {
        cylinder { <0,0,0>, <0,Depth,0>, AxisRadius+Thickness }
        cylinder { <0,-0.001,0>, <0,Depth+0.001,0>, AxisRadius }
    }
    difference {
        union {
            #local i = 0;
            #while (i < 5)
                box { <-Thickness/2,0,AxisRadius>, <Thickness/2,Depth,Radius> rotate i/5*360*y }
                #local i = i + 1;
            #end
        }
        #local label = text {
            ttf "courbd.ttf", Name, 0.002, 0.0
            rotate 90*x
            rotate -90*y
            scale <Thickness,1,Thickness>
        }
        #local minext = min_extent(label);
        #local maxext = max_extent(label);
        #local mp1 = (maxext.x + minext.x)/2;
        #local mp2 = (maxext.z + minext.z)/2;
        object { label translate <-mp1,Depth+0.001,(Radius+AxisRadius)/2-mp2> }
    }
    
#end

#macro Gear(Radius, Teeth, ToothScale, Depth, Thickness, AxisRadius, Name)
union {
    #local base_radius = Radius-ToothScale;
    #local base_offset = tan(pi/6)*2*ToothScale;
    #local tooth_radius = sqrt(base_radius*base_radius - base_offset*base_offset);
    GearBase(base_radius, Depth, Thickness, AxisRadius, Name)
    
    #local tooth = prism {
        0, Depth, 5
        <0,0>, <-base_offset,0>, <0,ToothScale*2>, <base_offset,0>, <0,0>
    }
    
    #local i = 0;
    #while (i < Teeth)
        object { tooth translate tooth_radius*z rotate i/Teeth*360*y }
        #local i = i + 1;
    #end
}
#end

#macro CrownGear(Radius, Teeth, ToothScale, Depth, Thickness, AxisRadius, Name)
union {
    #local base_radius = Radius-ToothScale;
    #local base_offset = tan(pi/6)*2*ToothScale;
    GearBase(Radius+Depth/2, Depth, Thickness, AxisRadius, Name)
    
    #local tooth = prism {
        0, Depth, 5
        <0,0>, <-base_offset,0>, <0,ToothScale*2>, <base_offset,0>, <0,0>
        rotate 90*x
    }
    
    #local i = 0;
    #while (i < Teeth)
        object { tooth translate (Radius-Depth/2)*z rotate i/Teeth*360*y }
        #local i = i + 1;
    #end
}
#end

#macro Zodiac(InnerRadius, OuterRadius, Thickness)
difference {
    cylinder { <0,0,0>, <0,Thickness,0>, OuterRadius }
    union {
        cylinder { <0,-0.001,0>, <0,Thickness+0.001,0>, InnerRadius }
        
        #local letters = array[12]{"A","B","C","D","E","F","G","H","I","J","K","L"};
        
        #local i = 0;
        #while (i < 12)
            box { <-Thickness/2,Thickness-0.001,0>, <Thickness/2,Thickness+0.001,OuterRadius+0.001> rotate (i+0.5)/12*360*y }
            #local label = text {
                ttf "astro.ttf", letters[i], 0.002, 0.0
                rotate 90*x
                scale <(OuterRadius-InnerRadius)*0.8,1,(OuterRadius-InnerRadius)*0.8>
            }
            #local minext = min_extent(label);
            #local maxext = max_extent(label);
            #local w = maxext.x - minext.x;
            #local h = maxext.z - minext.z;
            object { label translate <-w/2,Thickness+0.001,InnerRadius+(OuterRadius-InnerRadius-h)/2> rotate i/12*360*y }
            #local i = i + 1;
        #end
    }
}
#end

#declare B2Teeth = 64;
#declare C1Teeth = 38;
#declare C2Teeth = 48;
#declare D1Teeth = 24;
#declare D2Teeth = 127;
#declare B3Teeth = 32;
#declare B4Teeth = 65;
#declare A2Teeth = 65;
#declare B5Teeth = 65;

#declare BCDist = B2Teeth + C1Teeth;
#declare CDDist = C2Teeth + D1Teeth;
#declare DBDist = D2Teeth + B3Teeth;
#declare CAngle = acos((BCDist*BCDist + DBDist*DBDist - CDDist*CDDist)/(2*BCDist*DBDist));

#declare CPosX = -BCDist*sin(CAngle)/1000;
#declare CPosY = BCDist*cos(CAngle)/1000;
#declare DPosX = 0;
#declare DPosY = DBDist/1000;

#declare B2Angle = clock*360;
#declare C2Angle = -B2Angle*B2Teeth/C1Teeth;
#declare D2Angle = -C2Angle*C2Teeth/D1Teeth;
#declare B3Angle = -D2Angle*D2Teeth/B3Teeth;
#declare A2Angle = B3Angle*B4Teeth/A2Teeth;
#declare B5Angle = -A2Angle*A2Teeth/B5Teeth;

#declare BoxTop = -0.15;
#declare BoxBottom = 0.3;
#declare BoxLeft = -0.15;
#declare BoxRight = 0.15;
#declare BoxThickness = 0.01;
#declare BoxDepth = 0.2;

box { <BoxLeft,0,BoxTop>, <BoxRight,BoxThickness,BoxBottom> pigment { White } }
box { <BoxLeft,BoxThickness,BoxTop>, <BoxRight,BoxDepth,BoxTop-BoxThickness> pigment { White } }
box { <BoxLeft,BoxThickness,BoxBottom>, <BoxRight,BoxDepth,BoxBottom+BoxThickness> pigment { White } }
box { <BoxLeft,BoxThickness,BoxTop>, <BoxLeft+BoxThickness,BoxDepth,BoxBottom> pigment { White } }
box { <BoxRight,BoxThickness,BoxTop>, <BoxRight-BoxThickness,BoxDepth,BoxBottom> pigment { White } }

cylinder { <0,0,0>, <0,0.2,0>, 0.005 pigment { White } }
cylinder { <DPosX,0,DPosY>, <DPosX,0.2,DPosY>, 0.005 pigment { White } }
cylinder { <CPosX,0.16,CPosY>, <CPosX,0.2,CPosY>, 0.005 pigment { White } }
difference {
    cylinder { <0,0.17,0>, <0,0.19,0>, 0.015 }
    cylinder { <0,0.17-0.001,0>, <0,0.19+0.001,0>, 0.01 }
    pigment { White }
}
difference {
    cylinder { <0,0.0,0>, <0,0.04,0>, 0.015 }
    cylinder { <0,0.0-0.001,0>, <0,0.04+0.001,0>, 0.01 }
    pigment { White }
}
union {
    cylinder { <BoxRight+0.02,0,0>, <0.05,0,0>, 0.005 }
    sphere { <BoxRight+0.02,0,0>, 0.005 }
    cylinder { <BoxRight+0.02,0,0>, <BoxRight+0.02,0,0.05>, 0.005 }
    sphere { <BoxRight+0.02,0,0.05>, 0.005 }
    cylinder { <BoxRight+0.05,0,0.05>, <BoxRight+0.02,0,0.05>, 0.005 }

    blob {                               
        sphere { <BoxRight+0.05,0,0.05>, 0.025 1 }
        sphere { <BoxRight+0.075,0,0.05>, 0.025, 1 }
        threshold 0.4
        texture { T_Brass_5A }
    }
    
    rotate A2Angle*x
    translate 0.1*y
    pigment { White } 
}

object { Zodiac(0.065, 0.09, 0.002) translate <0,0.1975-0.001,0> texture { T_Brass_5A } }

object { Gear(B2Teeth/1000, B2Teeth, 0.0025, 0.01, B2Teeth/10000, 0.015, "B2") rotate B2Angle*y translate <0,0.18,0> pigment { Yellow } }
object { Gear(C1Teeth/1000, C1Teeth, 0.0025, 0.01, C1Teeth/10000, 0.005, "C1") rotate C2Angle*y translate <CPosX,0.18,CPosY> pigment { Yellow } }
object { Gear(C2Teeth/1000, C2Teeth, 0.0025, 0.01, C2Teeth/10000, 0.005, "C2") rotate C2Angle*y translate <CPosX,0.17,CPosY> pigment { Yellow } }
object { Gear(D1Teeth/1000, D1Teeth, 0.0025, 0.01, D1Teeth/10000, 0.005, "D1") rotate D2Angle*y translate <DPosX,0.17,DPosY> pigment { Yellow } }
object { Gear(D2Teeth/1000, D2Teeth, 0.0025, 0.01, D2Teeth/10000, 0.005, "D2") rotate D2Angle*y translate <DPosX,0.02,DPosY> pigment { Yellow } }
object { Gear(B3Teeth/1000, B3Teeth, 0.0025, 0.01, B3Teeth/10000, 0.015, "B3") rotate B3Angle*y translate <0,0.02,0> pigment { Yellow } }
object { Gear(B4Teeth/1000, B4Teeth, 0.0025, 0.01, B4Teeth/10000, 0.015, "B4") rotate B3Angle*y translate <0,0.03,0> pigment { Yellow } }
object { CrownGear(A2Teeth/1000, A2Teeth, 0.0025, 0.01, A2Teeth/10000, 0.005, "A2") rotate A2Angle*y rotate -90*z translate <0.0677,0.10,0> pigment { Yellow } }
object { Gear(B5Teeth/1000, B5Teeth, 0.0025, 0.01, B5Teeth/10000, 0.005, "B5") rotate B5Angle*y translate <0,0.16,0> pigment { Yellow } }
cylinder { <0,0.1975,0>, <0,0.1975,0.04>, 0.0025 rotate B5Angle*y pigment { White } }
sphere { <0,0.1975,0.04>, 0.005 rotate B5Angle*y texture { T_Silver_5E } }
cylinder { <0,0.18,0.055>, <0,0.1975,0.055>, 0.0025 rotate B2Angle*y pigment { White } }
sphere { <0,0.1975,0.055>, 0.005 rotate B2Angle*y texture { T_Gold_1E } }
