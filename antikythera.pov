#version 3.6;

#include "colors.inc"
#include "math.inc"
#include "transforms.inc"
#include "metals.inc"
#include "golds.inc"
#include "skies.inc"
#include "woods.inc"


global_settings {
  assumed_gamma 1.0
}

// ----------------------------------------

camera {
  location <0.0, 0.75, 0.001>
  direction 1.5*z
  right x*image_width/image_height
  look_at <0.0, 0.0, 0.0>
}

sky_sphere { S_Cloud1 }

light_source {
  <1, 2, 1>
  color White
}

#macro GearBase(Radius, Depth, Thickness, AxisRadius, Name)
    #local base_radius = Radius-ToothScale;
    difference {
        cylinder { <0,0.25*Depth,0>, <0,0.75*Depth,0>, Radius }
        cylinder { <0,0.25*Depth-0.001,0>, <0,0.75*Depth+0.001,0>, Radius-Thickness }
    }
    difference {
        cylinder { <0,0,0>, <0,Depth,0>, AxisRadius+Thickness }
        cylinder { <0,-0.001,0>, <0,Depth+0.001,0>, AxisRadius }
    }
    difference {
        union {
            #local i = 0;
            #while (i < 5)
                box { <-Thickness/2,0.25*Depth,AxisRadius>, <Thickness/2,0.75*Depth,Radius> rotate i/5*360*y }
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
        object { label translate <-mp1,0.75*Depth+0.001,(Radius+AxisRadius)/2-mp2> }
    }
    
#end

#macro Gear(Radius, Teeth, ToothScale, Depth, Thickness, AxisRadius, Name)
union {
    #local base_radius = Radius-ToothScale;
    #local base_offset = tan(pi/6)*2*ToothScale;
    #local tooth_radius = sqrt(base_radius*base_radius - base_offset*base_offset);
    GearBase(base_radius, Depth, Thickness, AxisRadius, Name)
    
    #local tooth = prism {
        0.25*Depth, 0.75*Depth, 5
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
        object { tooth translate 0.25*Depth*y translate (Radius-Depth/2)*z rotate i/Teeth*360*y }
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
                texture { T_Silver_5E } 
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

#macro NormaliseAngle(a1)
    #while (a1 <= -180)
        #local a1 = a1 + 360;
    #end
    #while (a1 > 180)
        #local a1 = a1 -360;
    #end
    a1
#end

#macro AngleDiff(a1, a2)
    NormaliseAngle(a1) - NormaliseAngle(a2)
#end

#macro TriangleAngle(ab,bc,cd)
#warning str(ab,0,3)
#warning str(bc,0,3)
#warning str(cd,0,3)
    acos((ab*ab + bc*bc - cd*cd)/(2*ab*bc))
#end

#declare B1Teeth = 223;
#declare B2Teeth = 64;
#declare C1Teeth = 38;
#declare C2Teeth = 48;
#declare D1Teeth = 24;
#declare D2Teeth = 127;
#declare E2Teeth = 32;
#declare L1Teeth = 38;
#declare L2Teeth = 53;
#declare M1Teeth = 96;
#declare M2Teeth = 15;
#declare M3Teeth = 27;
#declare E3Teeth = 223;
#declare E5Teeth = 50;
#declare K1Teeth = 50;
#declare K2Teeth = 50;
#declare E6Teeth = 50;
#declare E1Teeth = 32;
#declare B3Teeth = 32;
#declare B0Teeth = 20;
#declare MB3Teeth = B0Teeth;
#declare MB2Teeth = 15;
#declare MA1Teeth = MB2Teeth;

#declare K1K2Dist = 0.0025;
#declare KPinDist = 0.04;
#declare KPinRad = 0.00125;

#macro PinSlotAngle(Input, Offset, PinDist)
    #local pinx = PinDist*cos(radians(Input));
    #local piny = PinDist*sin(radians(Input));
    degrees(atan2(piny,pinx-Offset))
#end

#macro NextAngle(Input, FromTeeth, ToTeeth, RelAngle)
    #local teeth_past = FromTeeth*RelAngle/360;
    -Input*FromTeeth/ToTeeth + 180-RelAngle - (teeth_past+0.5)/ToTeeth*360
#end

#declare B2Angle = clock*360/10;
#declare C2Angle = NextAngle(B2Angle, B2Teeth, C1Teeth, 0);
#declare D2Angle = NextAngle(C2Angle, C2Teeth, D1Teeth, 0);
#declare E2Angle = NextAngle(D2Angle, D2Teeth, E2Teeth, 0);
#declare L1Angle = NextAngle(B2Angle, B2Teeth, L1Teeth, 0);
#declare L2Angle = L1Angle;
#declare M1Angle = NextAngle(L2Angle, L2Teeth, M1Teeth, 0);
#declare M2Angle = M1Angle;
#declare M3Angle = M1Angle;
#declare E3Angle = NextAngle(M3Angle, M3Teeth, E3Teeth, 0);
#declare E5Angle = E2Angle;
#declare K1Angle = NextAngle(E5Angle, E5Teeth, K1Teeth, 0) + E3Angle;
#declare K2Angle = PinSlotAngle(K1Angle, K1K2Dist, KPinDist);
#declare E6Angle = NextAngle(K2Angle, K2Teeth, E6Teeth, 0) + E3Angle;
#declare E1Angle = E6Angle;
#declare B3Angle = NextAngle(E1Angle, E1Teeth, B3Teeth, 0);
#declare B0Angle = B2Angle;
#declare MB3Angle = NextAngle(B0Angle, B0Teeth, MB3Teeth, 0) + B3Angle;
#declare MB2Angle = MB3Angle;
#declare MA1Angle = -NextAngle(MB2Angle, MB2Teeth, MA1Teeth, 0);

#declare BCDist = (B2Teeth + C1Teeth)/1000;
#declare CDDist = (C2Teeth + D1Teeth)/1000;
#declare DEDist = (D2Teeth + E2Teeth)/1000;
#declare EBDist = (E1Teeth + B3Teeth)/1000;
#declare EKDist = (E5Teeth + K1Teeth)/1000;
#declare BLDist = (B2Teeth + L1Teeth)/1000;
#declare LMDist = (L2Teeth + M1Teeth+5)/1000;
#declare MEDist = (M3Teeth + E3Teeth)/1000;
#declare BCBearing = pi/2;
#declare CDBearing = BCBearing;
#declare DEBearing = -BCBearing - TriangleAngle(BCDist+CDDist, DEDist, EBDist);
#declare BEBearing = BCBearing + TriangleAngle(BCDist+CDDist, EBDist, DEDist);
#declare BLBearing = BCBearing + 2*TriangleAngle(BCDist+CDDist, EBDist, DEDist);
#declare BMBDist = (B0Teeth + MB3Teeth)/1000; 

#declare BPosX = 0;
#declare BPosY = 0;
#declare CPosX = BPosX + BCDist*cos(BCBearing);
#declare CPosY = BPosY + BCDist*sin(BCBearing);
#declare DPosX = CPosX + CDDist*cos(CDBearing);
#declare DPosY = CPosY + CDDist*sin(CDBearing);
#declare EPosX = DPosX + DEDist*cos(DEBearing);
#declare EPosY = DPosY + DEDist*sin(DEBearing);
#declare K1PosX = 0;
#declare K1PosY = EKDist;
#declare K2PosX = 0;
#declare K2PosY = EKDist + K1K2Dist;
#declare KPinPosX = K1PosX + KPinDist*cos(pi/2 - radians(K1Angle));
#declare KPinPosY = K1PosY + KPinDist*sin(pi/2 - radians(K1Angle));
#declare LPosX = BPosX + BLDist*cos(BLBearing);
#declare LPosY = BPosY + BLDist*sin(BLBearing);

#declare ELDist = sqrt((EPosX-LPosX)*(EPosX-LPosX) + (EPosY-LPosY)*(EPosY-LPosY));
#declare ELBearing = atan2(LPosY-EPosY,LPosX-EPosX);
#declare EMBearing = ELBearing + TriangleAngle(MEDist, ELDist, LMDist);
#declare MPosX = EPosX + MEDist*cos(EMBearing);
#declare MPosY = EPosY + MEDist*sin(EMBearing);

#declare BoxTop = -0.35;
#declare BoxBottom = 0.35;
#declare BoxLeft = -0.30;
#declare BoxRight = 0.30;
#declare BoxThickness = 0.01;
#declare BoxDepth = 0.2;

#declare PlanetHeight = 0.2;

union {
    box { <BoxLeft,0,BoxTop>, <BoxRight,BoxThickness,BoxBottom> }
    box { <BoxLeft,BoxThickness,BoxTop>, <BoxRight,BoxDepth,BoxTop-BoxThickness> }
    box { <BoxLeft,BoxThickness,BoxBottom>, <BoxRight,BoxDepth,BoxBottom+BoxThickness> }
    box { <BoxLeft,BoxThickness,BoxTop>, <BoxLeft+BoxThickness,BoxDepth,BoxBottom> }
    box { <BoxRight,BoxThickness,BoxTop>, <BoxRight-BoxThickness,BoxDepth,BoxBottom> }
    
    texture { T_Wood12 }
}

union {
    box { <BoxLeft,0.09,BPosY-0.01>, <BoxRight,0.10,BPosY+0.01> }
    box { <BoxLeft,0.09,CPosY-0.01>, <BoxRight,0.10,CPosY+0.01> }
    box { <BoxLeft,0.09,DPosY-0.01>, <BoxRight,0.10,DPosY+0.01> }
    box { <BoxLeft,0.09,EPosY-0.01>, <BoxRight,0.10,EPosY+0.01> }
    box { <BoxLeft,0.09,LPosY-0.01>, <BoxRight,0.10,LPosY+0.01> }
    box { <BoxLeft,0.09,MPosY-0.01>, <BoxRight,0.10,MPosY+0.01> }
    //box { <BoxLeft,BoxDepth-BoxThickness,BoxTop>, <BoxRight,BoxDepth,BoxBottom> }
    
    texture { T_Brass_5C }
}

union {
    cylinder { <BPosX,0.08,0>, <BPosY,0.2,0>, 0.005 }
    cylinder { <CPosX,0.09,CPosY>, <CPosX,0.12,CPosY>, 0.005 }
    cylinder { <DPosX,0.07,DPosY>, <DPosX,0.11,DPosY>, 0.005 }
    cylinder { <EPosX,0.01,EPosY>, <EPosX,0.10,EPosY>, 0.005 }
    difference {
        cylinder { <BPosX,0.09,0>, <BPosY,0.19,0>, 0.01 }
        cylinder { <BPosX,0.09-0.001,0>, <BPosY,0.19+0.001,0>, 0.005 }
    }
    cylinder { <LPosX,0.09,LPosY>, <LPosX,0.12,LPosY>, 0.005 }
    cylinder { <MPosX,0.01,MPosY>, <MPosX,0.11,MPosY>, 0.005 }

    cylinder { <0,PlanetHeight,0>, <0,PlanetHeight,0.11>, 0.0025 rotate B3Angle*y }
    union {
        difference {
            sphere { <0,0,0>, 0.01 texture { T_Silver_5E } }
            plane { -y,0 }
        }
        difference {
            sphere { <0,0,0>, 0.01 texture { T_Chrome_1A } }
            plane { y,0 }
        }
        rotate MA1Angle*z
        translate <0,PlanetHeight,0.11> rotate B3Angle*y
    }
    cylinder { <0,0.12,0.135>, <0,PlanetHeight,0.135>, 0.0025 rotate B2Angle*y }
    sphere { <0,PlanetHeight,0.135>, 0.01 rotate B2Angle*y texture { T_Gold_1E } }

    texture { T_Brass_5C }
}

/*union {
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
}*/

object { Zodiac(0.15 0.2, 0.002) translate <0,PlanetHeight-0.001,0> texture { T_Brass_5A } }

union {
    object { Gear(B1Teeth/1000, B1Teeth, 0.0025, 0.01, B1Teeth/10000, 0.01, "B1") rotate B2Angle*y translate <0,0.12,0> }
    object { Gear(B2Teeth/1000, B2Teeth, 0.0025, 0.01, B2Teeth/10000, 0.01, "B2") rotate B2Angle*y translate <0,0.11,0> }
    object { Gear(C1Teeth/1000, C1Teeth, 0.0025, 0.01, C1Teeth/10000, 0.005, "C1") rotate C2Angle*y translate <CPosX,0.11,CPosY> }
    object { Gear(C2Teeth/1000, C2Teeth, 0.0025, 0.01, C2Teeth/10000, 0.005, "C2") rotate C2Angle*y translate <CPosX,0.10,CPosY> }
    object { Gear(D1Teeth/1000, D1Teeth, 0.0025, 0.01, D1Teeth/10000, 0.005, "D1") rotate D2Angle*y translate <DPosX,0.10,DPosY> }
    object { Gear(D2Teeth/1000, D2Teeth, 0.0025, 0.01, D2Teeth/10000, 0.005, "D2") rotate D2Angle*y translate <DPosX,0.07,DPosY> }
    object { Gear(E2Teeth/1000, E2Teeth, 0.0025, 0.01, E2Teeth/10000, 0.005, "E2") rotate E2Angle*y translate <EPosX,0.07,EPosY> }
    
    union {
        difference {
            object { Gear(E3Teeth/1000, E3Teeth, 0.0025, 0.01, E3Teeth/10000, 0.005, "  E3") }
            cylinder { <K1PosX,-0.001,K1PosY>, <K1PosX,0.01+0.001,K1PosY>, 0.005 }
        }
        cylinder { <K1PosX,-0.01,K1PosY>, <K1PosX,0.01,K1PosY>, 0.005 }
        cylinder { <K2PosX,-0.02,K2PosY>, <K2PosX,-0.01,K2PosY>, 0.005-K1K2Dist }
        union {
            difference {
                object { Gear(K1Teeth/1000, K1Teeth, 0.0025, 0.01, K1Teeth/10000, 0.005, "K1") }
                cylinder { <0,-0.001,KPinDist>, <0,0.001,KPinDist>, KPinRad }
            }
            cylinder { <0,-0.01-0.001,KPinDist>, <0,0.001,KPinDist>, KPinRad }
            rotate K1Angle*y translate <K1PosX,-0.01,K1PosY>
        }
        difference {
            object { Gear(K2Teeth/1000, K2Teeth, 0.0025, 0.01, K2Teeth/10000, 0.005-K1K2Dist, "K2") }
            union {
                box { <-KPinRad,-0.001,KPinDist-K1K2Dist>, <KPinRad,0.01+0.001,KPinDist+K1K2Dist> }
                cylinder { <0,-0.001,KPinDist-K1K2Dist>, <0,0.01+0.001,KPinDist-K1K2Dist>, KPinRad }
                cylinder { <0,-0.001,KPinDist+K1K2Dist>, <0,0.01+0.001,KPinDist+K1K2Dist>, KPinRad }
            }
            rotate K2Angle*y translate <K2PosX,-0.02,K2PosY>
        }
        
        rotate E3Angle*y translate <EPosX,0.06,EPosY>
    }
    
    object { Gear(E5Teeth/1000, E5Teeth, 0.0025, 0.01, E5Teeth/10000, 0.005, "E5") rotate E5Angle*y translate <EPosX,0.05,EPosY> }
    object { Gear(E6Teeth/1000 + K1K2Dist, E6Teeth, 0.0025, 0.01, E6Teeth/10000, 0.005, "E6") rotate E6Angle*y translate <EPosX,0.04,EPosY> }
    object { Gear(E1Teeth/1000, E1Teeth, 0.0025, 0.01, E1Teeth/10000, 0.005, "E1") rotate E1Angle*y translate <EPosX,0.08,EPosY> }
    object { Gear(B3Teeth/1000, B3Teeth, 0.0025, 0.01, B3Teeth/10000, 0.005, "B3") rotate B3Angle*y translate <0,0.08,0> }
    
    
    object { Gear(L1Teeth/1000, L1Teeth, 0.0025, 0.01, L1Teeth/10000, 0.005, "L1") rotate L1Angle*y translate <LPosX,0.11,LPosY> }
    object { Gear(L2Teeth/1000, L2Teeth, 0.0025, 0.01, L2Teeth/10000, 0.005, "L2") rotate L2Angle*y translate <LPosX,0.10,LPosY> }
    object { Gear((M1Teeth+5)/1000, M1Teeth, 0.0025, 0.01, M1Teeth/10000, 0.005, "M1") rotate M1Angle*y translate <MPosX,0.10,MPosY> }
    //object { Gear(M2Teeth/1000, M2Teeth, 0.0025, 0.01, M2Teeth/10000, 0.005, "M2") rotate M2Angle*y translate <MPosX,0.08,MPosY> }
    object { Gear(M3Teeth/1000, M3Teeth, 0.0025, 0.01, M3Teeth/10000, 0.005, "M3") rotate M3Angle*y translate <MPosX,0.06,MPosY> }

    object { Gear(B0Teeth/1000, B0Teeth, 0.0025, 0.005, B0Teeth/10000, 0.01, "B0") rotate B0Angle*y translate <0,PlanetHeight-MA1Teeth/1000-0.01,0> pigment { Yellow } }
    union {
        object { Gear(MB3Teeth/1000, MB3Teeth, 0.0025, 0.005, MB3Teeth/10000, 0.0025, "MB3") rotate MB3Angle*y translate <0,PlanetHeight-MA1Teeth/1000-0.01,BMBDist> pigment { Yellow } }
        object { Gear(MB2Teeth/1000, MB2Teeth, 0.0025, 0.005, MB2Teeth/10000, 0.0025, "MB2") rotate MB2Angle*y translate <0,PlanetHeight-MA1Teeth/1000-0.005,BMBDist> pigment { Yellow } }
        object { CrownGear(MA1Teeth/1000, MA1Teeth, 0.0025, 0.005, MA1Teeth/10000, 0.0025, "MA1") rotate MA1Angle*y rotate 90*x translate <0,PlanetHeight,BMBDist+MB2Teeth/1000+0.0025> pigment { Yellow } }

        cylinder { <0,PlanetHeight-MA1Teeth/1000-0.005,BMBDist>, <0,PlanetHeight,BMBDist>, 0.0025 texture { T_Brass_5C } }

        rotate B3Angle*y
    }
    
    texture { T_Brass_5D }
}

#warning vstr(2, <BPosX,BPosY>, ",", 0,3)
#warning vstr(2, <CPosX,CPosY>, ",", 0,3)
#warning vstr(2, <DPosX,DPosY>, ",", 0,3)
#warning vstr(2, <EPosX,EPosY>, ",", 0,3)
#warning vstr(2, <LPosX,LPosY>, ",", 0,3)
#warning vstr(2, <MPosX,MPosY>, ",", 0,3)
