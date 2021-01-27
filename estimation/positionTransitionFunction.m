function [x] = positionTransitionFunction(x,u)

dt = 0.01; % [s] Sample time
x= x + fnContinuous(x,u)*dt;

end

function dxdt = fnContinuous(x,u)
g=9.8; % gravity acceleration
% States
x_pos= x(1);
y_pos= x(2); 
z_pos= x(3);  
V_x= x(4);
V_y= x(5);
V_z= x(6);
Phi= x(7);
The= x(8);
Psi= x(9);

% Inputs
a_x= u(1);
a_y= u(2);
a_z= u(3);
p= u(4);
q= u(5);
r= u(6);

R_b_e = [cos(Psi)*cos(The) cos(Psi)*sin(The)*sin(Phi)-sin(Psi)*cos(Phi) cos(Psi)*sin(The)*cos(Phi)+sin(Psi)*sin(Phi);
       sin(Psi)*cos(The) sin(Psi)*sin(The)*sin(Phi)+cos(Psi)*cos(Phi) sin(Psi)*sin(The)*cos(Phi)-cos(Psi)*sin(Phi);
       -sin(The)         cos(The)*sin(Phi)                            cos(The)*cos(Phi)]; % Rib

dxdt = [ V_x  ; ...
         V_y ; ...
         V_z ; ...
         cos(Psi)*cos(The)*a_x + (cos(Psi)*sin(The)*sin(Phi)-sin(Psi)*cos(Phi))*a_y + (cos(Psi)*sin(The)*cos(Phi)+sin(Psi)*sin(Phi))*a_z; ...
         sin(Psi)*cos(The)*a_x + (sin(Psi)*sin(The)*sin(Phi)+cos(Psi)*cos(Phi))*a_y + (sin(Psi)*sin(The)*cos(Phi)-cos(Psi)*sin(Phi))*a_z; ...
         -sin(The)*a_x + cos(The)*sin(Phi)*a_y + cos(The)*cos(Phi)*a_z ; ... % - g ; ...
         p + q*sin(Phi)*tan(The) + r*cos(Phi)*tan(The); ...
         q*cos(Phi) - r*sin(Phi) ; ...
         q*sin(Phi)/cos(The) + r*cos(Phi)/cos(The) ];
end