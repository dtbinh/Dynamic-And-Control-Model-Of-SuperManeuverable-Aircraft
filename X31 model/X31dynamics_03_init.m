%{
****************************** DISCLAIMER *********************************
    I, �d�߫�, personally create and debug all parts of this simulation program.
However, it is not me nor anyone that truely "invent" the numerical aircraft 
model like this one. It is based on the long history of all mathematical, 
science, and engineering of humanity. Like Isaac Newton said, "standing on
 the shoulders of giants".
    The aerodynamical parameter of the vehicle in this project comes from 
the thesis written by Snell [1]. In his work, he collected and estimated the
data from multiple source including all major aero-astro research and develop
institude around the world. Also, the method to model the dynamics of the 
vehicle and the controller implemented including the NDI and Gain Scheduling 
also came from his thesis.              
    The quaternion kinematics mainly reference to the toturial paper done by 
Trawny [2], where he collected and organized all fundamental properties and
mathematical operation of such system.                   
    This model is released to improve our ability to understand and develop 
control methodology of aerial vehicle system similar to this one. It is 
released free of charge now and always will be so in the hope of sharing the
knowledge as much as possible and making this world a better place. 
    However, despite my greatest effort to ensure the correctness of the 
code, it is not garantee to be free of bug or other issue. You are free to 
use and modify the program to meet your need but I'm not responsible for any
potential risk or damaged of any kind.
    Long live and prosper
***************************** Liscence: GPLv2 ****************************
Dynamic Model of Super-Maneuverable Aircraft
Copyright (C) 2016 Hsin-Yi Kang
DAA, NCKU
f039281310@yahoo.com.tw
This program is free software; you can redistribute it and/or modify it   
under the terms of the GNU General Public License as published by the Free 
Software Foundation; either version 2 of the License, or (at your option) 
any later version. This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details. You should have received a copy of the GNU 
General Public License along with this program; if not, write to the Free 
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
MA 02110-1301, USA. 
**************************** Main Reference *******************************
X31:
    [1] Snell, Sidney Antony, "Nonlinear Dynamic-Inversion Flight Control 
of Supermaneuverable Aircraft", Ph.D thesis, UoMinnesota, 1991
Quaternion:
    [2] Nikolas Trawny and StergiosI. Roumeliotis, "Indirect Kalman Filter 
for 3D Attitude Estimation," University of Minnesota, 2005.
                         ***Side Reference***
X31:
    [3] David F. Fisher, John H. Del Frate, and David M. Richwinc, "In-Flight 
Flow Visualization Characteristics of the NASA F-18 High Alpha Research 
Vehicle at High Angles of Attack", Technical Memorandum4193, NASA, Edwards, 
CA, 1990.
    [4] W. B. W. a. W. P. Fellers, "Tail Configurations for Highly 
Maneuverable Aircraft," AGARD, 1981.

Quaternion:
    [5] Nikolas Trawnyand StergiosI. Roumeliotis, "Indirect Kalman Filter 
for 3D Attitude Estimation," University of Minnesota, 2005.
    [6] W. G. Breckenridge, "Quaternions -Proposed Standard Conventions" 
JPL, Tech. Rep. INTEROFFICE MEMORANDUM 343-79-1199, 1999.
    [7] D. M. Henderson, "EularAngles, Quaternions, and Transformation 
Matrices," Mission Planning and Analysis Division, NASA, July 1977.
%}



function X31dynamics_03_init()
%THIS NEED TO BE PROGRAM TO BE REAL FUNCTIONAL AND MORE INPUT FRIENDLY

[ initX, initR] = X31dynamics_init_state();
initP = X31dynamics_init_poly();
x31physical = X31physical_init();
initC = X31actuator_init();
assignin('base', 'X31_initX', initX);
assignin('base', 'X31_initR', initR);
assignin('base', 'X31_initP', initP);
assignin('base', 'X31_physical', x31physical);
assignin('base', 'X31_initC', initC);
%global initP;
end

function [ linear, angular] = X31dynamics_init_state()

speed = [50 0 0];
position =[0.1 0.1 -0.1];

linear.pos = position;
linear.vel = speed;
linear.vinf = sqrt(speed(1)^2+speed(2)^2+speed(3)^2);
%initX=[1 ;0; -0.1; 0; 0; 0];        % tail sit
%initX=[2 ;0; 0.5; 0; 0; 0];         % straight & level launch

roll_rate = 0;
pitch_rate = 0;
yaw_rate = 0;

t3 = 0;         % yaw
t2 = pi/37;         % pitch
t1 = 0;         % row

q0 = sin(t1/2)*sin(t2/2)*sin(t3/2) + cos(t1/2)*cos(t2/2)*cos(t3/2);         % cos(theta/2)
q1 = -cos(t1/2)*sin(t2/2)*sin(t3/2) + sin(t1/2)*cos(t2/2)*cos(t3/2);         % x sin(theta/2)
q2 = sin(t1/2)*cos(t2/2)*sin(t3/2) + cos(t1/2)*sin(t2/2)*cos(t3/2);        % y sin(theta/2)
q3 = -sin(t1/2)*sin(t2/2)*cos(t3/2) + cos(t1/2)*cos(t2/2)*sin(t3/2);        % z sin(theta/2)

% pqr %cos 2/theta ;x sin 2/theta;y sin 2/theta; z sin 2/theta
%angular=[0; 0; 0; cos(40*pi/180); 0; sin(40*pi/180); 0];          % tail sit 
%initR=[0; 0; 0; cos(5*pi/180); 0; sin(5*pi/180); 0];          % 10 degree

angular.w = [roll_rate , pitch_rate , yaw_rate];
angular.q = [q0 , q1 , q2 , q3];

%clearvars speed alpha beta position
%clearvars roll_rate pitch_rate yaw_rate 
%clearvars rho theta phi 

end

function polynomial = X31dynamics_init_poly()
% [ODD or EVEN function] [a=alpha, b=beta]
% polynomial order : [1 2 3 4 5 6 0, ODD=1/EVEN=0 ]
polynomial.fig2_2(1).a = [+0.068166435 , +0.000838565 , -7.53902E-05 , +1.05377E-06 , -4.55181E-09 , -1.73074E-13 , +0.0         , 1];        % [ODD ][a] Cl
polynomial.fig2_2(1).b = [+0.009653169 , -0.000177299 , +2.91271E-05 , -4.79288E-07 ,  2.16121E-09 ,  +0.0000E+00 , +0.003815982 , 0];        % [EVEN][a] Cd
polynomial.fig2_2(2).a = [-2.98973E-05 , +2.87863E-06 , -1.12387E-07 , +1.83108E-09 , -1.36183E-11 ,  3.85119E-14 , +0.002310071 , 0];        % [EVEN][a] Cl delta canard
polynomial.fig2_2(2).b = [-0.161987094 , -0.061576775 , +0.001116867 , -4.89738E-06 , -1.82458E-08 ,  1.83146E-10 , -0.015086919 , 1];        % [ODD ][a] canard lift offset
polynomial.fig2_2(3).a = [  0          ,            0 ,            0 ,            0 ,            0 ,            0 ,           -1 , 0];        % [EVEN][a] CY 
polynomial.fig2_2(3).b = [+0.000129449 , -1.68066E-05 , +4.58837E-07 , -4.98703E-09 ,    1.931E-11 ,            0 , +0.003236518 , 0];        % [EVEN][a] CY with rudder(deg)
polynomial.fig2_2(4).a = [+0.010568349 , -0.001180732 , +3.75585E-05 , -4.51658E-07 , +1.81067E-09 , +4.91796E-13 , -0.083588788 , 0];        % [EVEN][a] Cl with beta(rad)
polynomial.fig2_2(4).b = [-0.009013965 , -0.000415504 , +1.97183E-05 , -2.69626E-07 , +1.27567E-09 ,  -6.5435E-13 , +0.175202791 , 0];        % [EVEN][a] Cn with beta
polynomial.fig2_2(5).a = [+0.009368111 , -0.001403253 , +5.02484E-05 ,   -6.593E-07 , +2.89722E-09 , +2.46726E-13 , -0.078285489 , 0];        % [EVEN][a] Cl with p
polynomial.fig2_2(5).b = [+0.001564168 , -0.001140853 , +5.19084E-05 , -7.95876E-07 , +3.84628E-09 , +1.11711E-12 , -0.000286817 , 1];        % [ODD ][a] Cn with p
polynomial.fig2_2(6).a = [-0.022525193 , +0.003573161 , -0.000125695 , +1.67113E-06 , -7.98271E-09 , +4.30185E-12 , -0.0758901   , 1];        % [ODD ][a] Cl with r
polynomial.fig2_2(6).b = [+0.017397535 , -0.001987539 , +6.01596E-05 , -6.69396E-07 , +2.49322E-09 , +3.48365E-13 , -0.32966209  , 0];        % [EVEN][a] Cn with r
polynomial.fig2_2(7).a = [+5.11295E-05 , -6.16355E-06 , +1.57143E-07 ,  -1.7579E-09 , +8.54994E-12 , -1.20465E-14 , +0.002346565 , 0];        % [EVEN][a] Cl with ailron(deg)
polynomial.fig2_2(7).b = [+2.49532E-05 , -2.72807E-06 , +7.90021E-08 , -1.01864E-09 ,  +5.8109E-12 , -1.07828E-14 , +0.000760346 , 0];        % [EVEN][a] Cn with ailron(deg)
polynomial.fig2_2(8).a = [+1.61374E-05 , -1.74829E-06 , +4.94371E-08 , -6.15656E-10 ,  +3.3101E-12 , -5.31398E-15 , +0.000507964 , 0];        % [EVEN][a] Cl with rudder(deg)
polynomial.fig2_2(8).b = [-9.46234E-05 ,  1.16858E-05 , -3.46362E-07 ,  4.56883E-09 , -2.82200E-11 ,  6.61620E-14 , -1.91018E-03 , 0];        % [EVEN][a] Cn with rudder(deg)
polynomial.fig2_2(9).a = [+0.002907947 , +8.80921E-05 , -6.66764E-06 , +1.44272E-07 , -1.34607E-09 ,  +4.6273E-12 , +0           , 1];        % [ODD ][a] Cm0 (4.65% static instability)
polynomial.fig2_2(9).b = [           0 ,            0 ,            0 ,            0 ,            0 ,            0 ,           -3 , 0];        % [EVEN][a] Cm with q
polynomial.fig2_2(10).a = [-4.46671E-05 , +3.84916E-06 , -1.32161E-07 , +1.54809E-09 ,  -5.0072E-12 ,  -9.9798E-15 , +0.005052863 , 0];       % [EVEN][a] Cm with canard(deg)
polynomial.fig2_2(10).b = [-0.137580555 , -0.070398444 , +0.001549639 ,  -1.2966E-05 ,  4.63561E-08 ,            0 , -0.099241141 , 1];       % [ODD ][a] canard pitching-moment offset(deg)

end

function physical = X31physical_init()
physical.inertia.mass = 10617;
physical.inertia.Ixx = 22682;
physical.inertia.Iyy = 77095;
physical.inertia.Izz = 95561;
physical.inertia.Ixy = 0;
physical.inertia.Ixz = 1125;
physical.inertia.Iyz = 0;

physical.geometry.Sref = 57.7;
physical.geometry.b = 13.11;
physical.geometry.Cbar = 4.4;
physical.geometry.Xp = 7;
physical.geometry.Xc = 9.68;
physical.geometry.Xr = 7.91;
physical.geometry.Xt = 8.5;

physical.size.fuselage.length = 20;
physical.size.fuselage.radius = 3;
physical.size.fuselage.offset_x = 0;
physical.size.mainwing.span = 13.11;
physical.size.mainwing.center_chord = 8.8;
physical.size.mainwing.offset_x = -3;
physical.size.mainwing.offset_z = 1.5;
physical.size.canard.span = 6;
physical.size.canard.center_chord = 4;
physical.size.canard.offset_x = 9.68;
physical.size.canard.offset_z = 0;
physical.size.fin.height = 3;
physical.size.fin.base_width = 4;
physical.size.fin.tip_width = 2;
physical.size.fin.offset_x = -7.91;
physical.size.fin.offset_z = -1.2;
end

function control = X31actuator_init()
control.thrust = 30;  % KN
end