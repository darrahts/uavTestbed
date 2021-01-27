function Dynamics(block)
setup(block);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setup(block)

  % Register the number of ports.
  %------
  block.NumInputPorts  = 8;
  %------
  block.NumOutputPorts = 18;
  
  % Set up the port properties to be inherited or dynamic.
  
  for i = 1:8 % These are the motor inputs
  block.InputPort(i).Dimensions        = 1;
  block.InputPort(i).DirectFeedthrough = false;
  block.InputPort(i).SamplingMode      = 'Sample';
  end
  %------

  %------
  for i = 1:18
  block.OutputPort(i).Dimensions       = 1;
  block.OutputPort(i).SamplingMode     = 'Sample';
  end

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
  
  block.Dwork(1).Name            = 'ForcesTorques';
  block.Dwork(1).Dimensions      = 6;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
    
  % Register all tunable parameters as runtime parameters.
  block.AutoRegRuntimePrms;

%endfunction

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


function Outputs(block)
for i = 1:12
  block.OutputPort(i).Data = block.ContStates.Data(i);
end

count=1;
for i = 13:18
  block.OutputPort(i).Data = block.Dwork(1).Data(count);
  count=count+1;
end




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

% Disturbances Input------
% Dist_tau = block.InputPort(5).Data(1:3);
% Dist_F   = block.InputPort(5).Data(4:6);
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

%% rotation matrix
% Z-Y-X rotation convention 
R_b_e = [cos(Psi)*cos(The) cos(Psi)*sin(The)*sin(Phi)-sin(Psi)*cos(Phi) cos(Psi)*sin(The)*cos(Phi)+sin(Psi)*sin(Phi);
       sin(Psi)*cos(The) sin(Psi)*sin(The)*sin(Phi)+cos(Psi)*cos(Phi) sin(Psi)*sin(The)*cos(Phi)-cos(Psi)*sin(Phi);
       -sin(The)         cos(The)*sin(Phi)                            cos(The)*cos(Phi)]; % Rib
R_e_b = R_b_e'; % Rbi  
gamma=model.tiltmotorangle;
alpha=model.separationmotorangle;
E_m_b = [0 -sin(alpha)*sin(gamma) sin(gamma) -cos(alpha)*sin(gamma) 0 sin(alpha)*sin(gamma) -sin(gamma) cos(alpha)*sin(gamma);
         -sin(gamma)  cos(alpha)*sin(gamma) 0 -sin(alpha)*sin(gamma) sin(gamma) -cos(alpha)*sin(gamma) 0 sin(alpha)*sin(gamma);
         -cos(gamma) -cos(gamma) -cos(gamma) -cos(gamma) -cos(gamma) -cos(gamma) -cos(gamma) -cos(gamma)];
dl=model.dl;constant=(1/sqrt(2));
ds=model.ds;
R_m=[dl 0 0; ...
    constant*ds constant*ds 0; ...
    0 dl 0; ...
    -constant*ds constant*ds 0; ...
    -dl 0 0; ...
    -constant*ds -constant*ds 0; ...
    0 -dl 0; ...
    constant*ds -constant*ds 0]';

%% Force created by motor
%through the lumped ct parameter
Fw=(model.ct .*(w.^2));

Ftotal=zeros(3,1);
for i=1:8
    e_i_b=E_m_b(:,i);
    Ftemp=Fw(i).*e_i_b;
    Ftotal=Ftotal+Ftemp;
end
% output Ftotal  -Forces in the body frame
Ftotal_inertial=R_b_e*Ftotal;
block.Dwork(1).Data(1:3)=Ftotal_inertial;

%% Torque created by motor
%if using lumped cq parameter
Qw=(model.cq .*(w.^2));

Qtotal=zeros(3,1);
for i=1:8
    e_i_b=E_m_b(:,i);
    Qtemp1=((-1)^(i+1)*Qw(i)).*e_i_b;
    
    r_m=R_m(:,i);
    Qtemp2=cross( r_m,e_i_b ).*Fw(i);
    
    Qtotal=Qtotal + (Qtemp1+Qtemp2);
end
% output Qtotal -Torques in the body frame
block.Dwork(1).Data(4:6)=Qtotal;

%% Moments in the body frame (N*m)
Mb = Qtotal;

% 3-torque created by drag
Mdrag=(((-1/2)*model.rho*model.cd)*[model.Axy*p*abs(p)*model.lx model.Axy*q*abs(q)*model.ly 8*model.Ayz*r*abs(r)*model.lz])';


% dynamic equation of the angular velocity - obtain dP dQ dR
w_b = [p; q; r]; % omb_bi
w_x_b = [ 0,-r, q; % OMb_bi
           r, 0,-p;
          -q, p, 0];
% dynamic equation of motion for angular acceleration
wdot_b = model.Jbinv * (Mb  + Mdrag - (w_x_b * model.Jb * w_b)); % b_omdotb_bi

% angular acceleration
dP = wdot_b(1);
dQ = wdot_b(2);
dR = wdot_b(3);

%angular velocity - Euler angles derivatives in the intertial frame
T_b_e = [1,tan(The)*sin(Phi), tan(The)*cos(Phi);
         0,         cos(Phi),         -sin(Phi);
         0,sin(Phi)/cos(The),cos(Phi)/cos(The)];  
Thetadot = T_b_e*w_b;     
dPhi = Thetadot(1);
dTheta = Thetadot(2);
dPsi = Thetadot(3);

%% -Forces calculated in the body frame (Newtons)
% 2-gravitational force
ge = [0; 0; -model.g];
Fg = R_e_b*ge; % gb

% Linear Velocity in the body frame
v_b = [U;V;W];

% Wind in the inertial frame
v_wenom=[0 0 0]'; % nominal wind velocity in m/s in inertial frame
v_weturb=[0 0 0]'; % nominal wind velocity in m/s in inertial frame
v_we=v_wenom+v_weturb; % wind velocity in m/s in inertial frame
v_wb=R_e_b*v_we; % wind velocity in m/s in body frame
v_a=v_wb+v_b; % apparent velocity resulting from wind and body

% 3-Drag force
Fdrag=(((-1/2)*model.rho*model.cd)*[model.Ayz*v_a(1)*abs(v_a(1)) model.Axz*v_a(2)*abs(v_a(2)) model.Axy*v_a(3)*abs(v_a(3))])';

%net thrust acceleration in body frame
Acc_b=(1/model.mass)*(Ftotal+Fdrag);
%to deal with numerical issues
Acc_b=round(Acc_b,2);

% dynamic equation of motion for linear acceleration
vdot_b = Acc_b + Fg - w_x_b*v_b; % Acceleration in body frame (FOR VELOCITY)

% linear acceleration
dU = vdot_b(1);
dV = vdot_b(2);
dW = vdot_b(3);

% velocity vector in the intertial frame
v_e = R_b_e*v_b; % Units OK SI: Velocity of body frame w.r.t inertia frame (FOR POSITION)

dX = v_e(1);
dY = v_e(2);
dZ = v_e(3);

% Rough rule to impose a "ground" boundary...could easily be improved...
if ((Z<=0) && (dZ<=0)) % better  version then before?
    dZ = 0;
    block.ContStates.Data(12) = 0;
end

%% all variables
f = [dP dQ dR dPhi dTheta dPsi dU dV dW dX dY dZ].';
  %This is the state derivative vector
block.Derivatives.Data = f;

%endfunction