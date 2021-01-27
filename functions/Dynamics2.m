
function Dynamics2(block)
setup(block);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setup(block)

  % Register the number of ports.
  %------
  block.NumInputPorts  = 9;
  %------
  block.NumOutputPorts = 13;
  
  % Set up the port properties to be inherited or dynamic.
  
  for i = 1:8 % These are the motor inputs
  block.InputPort(i).Dimensions        = 1;
  block.InputPort(i).DirectFeedthrough = false;
  block.InputPort(i).SamplingMode      = 'Sample';
  end
  %------

   % This is the disturbance input
    block.InputPort(9).Dimensions        = 3; % torques x,y,z; forces x,y,z.
    block.InputPort(9).DirectFeedthrough = false;
    block.InputPort(9).SamplingMode      = 'Sample';
  
  
  
  %------
  for i = 1:12
  block.OutputPort(i).Dimensions       = 1;
  block.OutputPort(i).SamplingMode     = 'Sample';
  end
  
  %acceleration in the body frame
  block.OutputPort(13).Dimensions       = 3;
  block.OutputPort(13).SamplingMode     = 'Sample';

  % Register the parameters.
  block.NumDialogPrms = 2;
  
  % Set up the continuous states.
  block.NumContStates = 12;

  % Register the sample times.
  %  [0 offset]            : Continuous sample time
  %  [positive_num offset] : Discrete sample time
  %
  %  [-1, 0]               : Inherited sample time
  %  [-2, 0]               : Variable sample time
  block.SampleTimes = [0 0];
  
  % -----------------------------------------------------------------
  % Options
  % -----------------------------------------------------------------
  % Specify if Accelerator should use TLC or call back to the 
  % MATLAB file
  block.SetAccelRunOnTLC(false);
  
  % Specify the block simStateCompliance. The allowed values are:
  block.SimStateCompliance = 'DefaultSimState';
  
  % -----------------------------------------------------------------
  
   block.RegBlockMethod('CheckParameters', @CheckPrms);

  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
 
  block.RegBlockMethod('InitializeConditions', @InitializeConditions);
  
  block.RegBlockMethod('Outputs', @Outputs);

  block.RegBlockMethod('Derivatives', @Derivatives);


% -------------------------------------------------------------------
% The local functions below are provided to illustrate how you may implement
% the various block methods listed above.
% -------------------------------------------------------------------

 function CheckPrms(block)
     model   = block.DialogPrm(1).Data;
     IC     = block.DialogPrm(2).Data;

%     
function DoPostPropSetup(block)

  block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'A_b';
  block.Dwork(1).Dimensions      = 3;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real

%endfunction

%% initialization
function InitializeConditions(block)
% Initialize 12 States

IC = block.DialogPrm(2).Data;

% IC.P, IC.Q, IC.R are in deg/s ... convert to rad/s
P = IC.P*pi/180; Q = IC.Q*pi/180; R = IC.R*pi/180; 
% IC.Phi, IC.The, IC.Psi are in deg ... convert to rads
Phi = IC.Phi*pi/180; The = IC.The*pi/180; Psi = IC.Psi*pi/180;
U = IC.U; V = IC.V; W = IC.W; 
X = IC.X; Y = IC.Y; Z = IC.Z;

init = [P,Q,R,Phi,The,Psi,U,V,W,X,Y,Z];
for i=1:12
block.OutputPort(i).Data = init(i);
block.ContStates.Data(i) = init(i);
end
block.OutputPort(13).Data = IC.Ab;



%% output
function Outputs(block)
for i = 1:12
  block.OutputPort(i).Data = block.ContStates.Data(i);  
end
block.OutputPort(13).Data  = block.Dwork(1).Data;




% function Update(block)
%   
%   block.Dwork(1).Data = block.InputPort(1).Data;
  
%endfunction

function Derivatives(block)
% Name all the states and motor inputs

model = block.DialogPrm(1).Data;

% P Q R in units of rad/sec in body frame
p = block.ContStates.Data(1);
q = block.ContStates.Data(2);
r = block.ContStates.Data(3);
% Phi The Psi in radians in inertial/earth frame
Phi = block.ContStates.Data(4);
The = block.ContStates.Data(5);
Psi = block.ContStates.Data(6);
% U V W in units of m/s in body frame
U = block.ContStates.Data(7);
V = block.ContStates.Data(8);
W = block.ContStates.Data(9);
% X Y Z in units of m in inertial/earth frame
X = block.ContStates.Data(10);
Y = block.ContStates.Data(11);
Z = block.ContStates.Data(12);

% w values in rev/min! NOT radians/s!!!!
w1 = block.InputPort(1).Data;
w2 = block.InputPort(2).Data;
w3 = block.InputPort(3).Data;
w4 = block.InputPort(4).Data;
w5 = block.InputPort(5).Data;
w6 = block.InputPort(6).Data;
w7 = block.InputPort(7).Data;
w8 = block.InputPort(8).Data;
w  = [w1; w2; w3; w4;w5; w6; w7; w8];

%to fix numerical issues
w=round(w,2);
% transform rpm to rad/s
w=w./(60/(2*pi));

% Disturbances Input------
% Dist_tau = block.InputPort(5).Data(1:3);
% Dist_F   = block.InputPort(5).Data(4:6);
Dist_F   = block.InputPort(9).Data(1:3);
% Wind Disturbances Input------
%v_we = block.InputPort(9).Data; % wind velocity in m/s in inertial frame
%------
%------

%% Notation
% b - body frame
% e - intertial/earth frame
% Theta - Euler angles vector, Thetadot - Euler angles derivatives
% The -> pitch, Psi -> yaw, Phi -> roll

% transformation and rotation matrices
% T_b_e - transformation matrix from body frame to intertial frame for Euler derivatives
% R_b_e - rotation matrix from body frame to intertial frame 
% R_e_b - rotation matrix from intertial frame to body frame 
% E_m_b - tilted mixing matrix Thrust from motor frame to body frame 
% R_m - displacement matrix Torque/Moment of motor frame to Centre Structure Frame 

%% Parameters
% model.dl - long arm separation (m)
% model.ds - short arm separation (m)
% model.ct - coefficient of thrust (Ns^2)
% model.cq - drag coefficient (Nms^2)
% model.mass - total mass (Kg)
% model.Jb - total intertia matrix in the center structure frame (Kg*m^2)
% model.g - gravity acceleration

% for calculation of drag force and moment, modeling the UAV as a cube
% model.cd - translational drag coefficient (adimensional, =1 for a cube) 
% model.Axy - cross-sectional area of the UAV in the xy plane (m^2)
% model.Axz - cross-sectional area of the UAV in the xz plane (m^2)
% model.Ayz - cross-sectional area of the UAV in the yz plane (m^2)
% model.rho - air density at 20 degrees (Kd/m^3)
% model.lx - radius of the cube in x axe
% model.ly - radius of the cube in y axe
% model.lz - radius of the cube in z axe

%% Equation dynamics

% inertial matrix components
I_xx=model.Jb(1,1);
I_yy=model.Jb(2,2);
I_zz=model.Jb(3,3);

% thrust generated by rotors
T=(model.ct .*(w.^2));
T_total=round(sum(T),2);

% moment of each rotor
M=(model.cq .*(w.^2));

% torque generated by rotors
Tau_x=model.l*(T(1)+ (sqrt(2)/2)*T(2)+ (sqrt(2)/2)*T(8) ...
    - T(5)- (sqrt(2)/2)*T(4)- (sqrt(2)/2)*T(6));%Tau_roll

Tau_y=model.l*(T(7)+ (sqrt(2)/2)*T(6)+ (sqrt(2)/2)*T(8) ...
    - T(3)- (sqrt(2)/2)*T(2)- (sqrt(2)/2)*T(4));%Tau_theta

Tau_z= -M(1) +M(2) -M(3) +M(4) -M(5) +M(6) -M(7) +M(8);%%Tau_yaw

% linear velocity in the inertial frame
dX=U;
dY=V; 
dZ=W;

%linear accelerations in the inertial frame
m_t=model.mass;

% set of equations 1
% acc_x=((cos(Psi)*sin(The)*cos(Phi)+sin(Psi)*sin(Phi))/m_t)*T_total;
% acc_y=((sin(Psi)*sin(The)*cos(Phi)-sin(Psi)*sin(Phi))/m_t)*T_total;
% acc_z=-model.g +((cos(Phi)*cos(The))/m_t)*T_total;
% dU=acc_x; 
% dV=acc_y; 
% dW=acc_z;

% set of equations 2
R_b_e = [cos(Psi)*cos(The) cos(Psi)*sin(The)*sin(Phi)-sin(Psi)*cos(Phi) cos(Psi)*sin(The)*cos(Phi)+sin(Psi)*sin(Phi);
       sin(Psi)*cos(The) sin(Psi)*sin(The)*sin(Phi)+cos(Psi)*cos(Phi) sin(Psi)*sin(The)*cos(Phi)-cos(Psi)*sin(Phi);
       -sin(The)         cos(The)*sin(Phi)                            cos(The)*cos(Phi)]; % Rib
R_e_b = R_b_e';

Dist_Fb = R_e_b*Dist_F;
% old
vdot_b=[0 ;0; -m_t*model.g]+R_b_e*[0; 0; T_total] - Dist_F/model.mass; % Linear Acceleration
dU=vdot_b(1); 
dV=vdot_b(2); 
dW=vdot_b(3);

% angular velocity rotational dynamics of the UAV in the body reference frame
p=(p + q*sin(Phi)*tan(The)+r*cos(Phi)*tan(The));
q=(q*cos(Phi)-r*sin(Phi));
r=(q*(sin(Phi)/cos(The)) + r*(cos(Phi)/cos(The)));
dPhi=p;
dTheta=q; 
dPsi=r;
% angular acceleration in the body reference frame
ang_acc_x=((I_yy-I_zz)/I_xx)*q*r+(model.l/I_xx)*Tau_x; % - Dist_F(1)/model.mass;
ang_acc_y=((I_zz-I_xx)/I_yy)*q*r+(model.l/I_yy)*Tau_y; % - Dist_F(2)/model.mass;
ang_acc_z=((I_xx-I_yy)/I_zz)*q*r+(model.l/I_zz)*Tau_z; % - Dist_F(3)/model.mass;

dP=ang_acc_x; 
dQ=ang_acc_y; 
dR=ang_acc_z;

% all state vector
f = [dP dQ dR dPhi dTheta dPsi dU dV dW dX dY dZ].';
f=round(f,3);
%This is the state derivative vector
block.Derivatives.Data = f;

%% additional outputs
block.Dwork(1).Data=vdot_b;

%endfunction