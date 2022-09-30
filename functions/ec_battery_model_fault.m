%%
%           Level 2 continuous time equivalent circuit battery model
%           
%           Adapted from Gregory Plett
%
%           By Tim Darrah
%
%%   
function ec_battery_model(block)
    setup(block);
  

%%  ------------------------------------------------------------ SETUP
function setup(block)
  
    % battery struct is the only parameter
    block.NumDialogPrms = 3;

    % u 
    % v_(t-1)       this is needed for the charging logic
    % t             time for fault implementation
    block.NumInputPorts  = 3;

    % v
    % z
    % Ir
    % h
    % Q
    % R0
    block.NumOutputPorts = 6;

    % setup port info
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    % inputs
    for i = 1:block.NumInputPorts
        block.InputPort(i).Dimensions        = 1;
        block.InputPort(i).DirectFeedthrough = false;
        block.InputPort(i).SamplingMode      = 'Sample';
    end

    % outputs
    for i = 1:block.NumOutputPorts
        block.OutputPort(i).Dimensions       = 1;
        block.OutputPort(i).SamplingMode     = 'Sample';
    end

    % continuous time
    block.SampleTimes = [0 0];

    % three state parameters (z, Ir, h)
    block.NumContStates = 3;

    % block setup
    block.RegBlockMethod('InitializeConditions',    @InitConditions);  
    block.RegBlockMethod('Outputs',                 @Output);  
    block.RegBlockMethod('Derivatives',             @Derivative);  
    block.SimStateCompliance = 'DefaultSimState';
    

    
%%  ------------------------------------------------------------ INIT_CONDITIONS
function InitConditions(block)
    % battery parameters
    battery = block.DialogPrm(1).Data;

    % set block states
    block.ContStates.Data(1) = battery.z;  
    block.ContStates.Data(2) = battery.Ir;
    block.ContStates.Data(3) = battery.h; 

    % for whatever reason, matlab inconsistently throws errors regarding
    % assigning single to double, or in other cases, double to single. This
    % is a stupid workaround. When the battery discharges, it likes the
    % double. When it charges, it likes the single. ???
    try
        % set outputs 
        block.OutputPort(1).Data = double(battery.v);
        block.OutputPort(2).Data = double(battery.z);
        block.OutputPort(3).Data = double(battery.Ir);
        block.OutputPort(4).Data = double(battery.h);
        block.OutputPort(5).Data = double(battery.Q);
        block.OutputPort(6).Data = double(battery.R0);
    catch ME
        % set outputs 
        block.OutputPort(1).Data = single(battery.v);
        block.OutputPort(2).Data = single(battery.z);
        block.OutputPort(3).Data = single(battery.Ir);
        block.OutputPort(4).Data = single(battery.h);
        block.OutputPort(5).Data = single(battery.Q);
        block.OutputPort(6).Data = single(battery.R0);
    end
     
    
%%  ------------------------------------------------------------ OUTPUT
function Output(block)

    % battery constants
    battery = block.DialogPrm(1).Data;
    M0 = battery.M0;  
    M  = battery.M;
    R0 = battery.R0;
    R  = battery.R;
    Q  = battery.Q;


    % inputs
    u = block.InputPort(1).Data;
    
                    % z and h need to be bounded and then update the state
    % z
    z = block.ContStates.Data(1);
    z = min(1.02, max(-.01, z));

    % get current time
    t = block.InputPort(3).Data;

    % get fault time
    ft = block.DialogPrm(2).Data;

    % implement fault
    if t > ft
        Q = block.DialogPrm(3).Data;
        battery.z_coef(7) = battery.z_coef(7) * .98;
        z = z * .99999;
    end



    block.ContStates.Data(1) = z;
    
    % h
    h = block.ContStates.Data(3);
    h = min(1, max(-1, h));
    block.ContStates.Data(3) = h;
    
    % Ir (no constraints)
    Ir = block.ContStates.Data(2);
    
                    % calculate the output voltage
    % if discharging
    if u < 0        
        % get v_(t-1)
        v = block.InputPort(2).Data;     
        % don't use the soc_ocv curve to update v if it is less than eod
        if v < battery.EOD               
            v = v + M0*sign(u) + M*h - R*Ir - R0*u;
        % otherwise use the curve
        else
            v = polyval(battery.z_coef, z*100.0) + M0*sign(u) + M*h - R*Ir - R0*u;
        end
    % if charging    
    else
        v = polyval(battery.z_coef, z*100.0) + M0*sign(u) + M*h - R*Ir - R0*u;
    end
    
    % bound v
    v = min(battery.v0, max(battery.v0/2, v));    
        
    try      
        % assign outputs
        block.OutputPort(1).Data = double(v);
        block.OutputPort(2).Data = double(z);
        block.OutputPort(3).Data = double(Ir);
        block.OutputPort(4).Data = double(h);
        block.OutputPort(5).Data = double(Q);
        block.OutputPort(6).Data = double(R0);
    catch ME
        % assign outputs
        block.OutputPort(1).Data = single(v);
        block.OutputPort(2).Data = single(z);
        block.OutputPort(3).Data = single(Ir);
        block.OutputPort(4).Data = single(h);
        block.OutputPort(5).Data = single(Q);
        block.OutputPort(6).Data = single(R0);
    end

    
    
 %%  ------------------------------------------------------------ DERIVATIVE
function Derivative(block)
    
    % get battery constants
    battery = block.DialogPrm(1).Data;  
    M  = battery.M;
    RC = battery.RC;
    n  = battery.n;
    Q  = battery.Q;
    G  = battery.G;
    
    % get battery state parameters 
    Ir = block.ContStates.Data(2);
    h  = block.ContStates.Data(3);
    
    % get current 
    u =  block.InputPort(1).Data;

    % get current time
    t = block.InputPort(3).Data;

    % get fault time
    ft = block.DialogPrm(2).Data;

    % implement fault
    if t > ft
        Q = block.DialogPrm(3).Data;
    end

    % z_dot
    block.Derivatives.Data(1) = - u * n / Q / 3600;
    
    % Ir_dot
    block.Derivatives.Data(2) = -1.0 / RC * Ir + 1.0 / RC * u;
    
    % h_dot
    block.Derivatives.Data(3) = -abs(n * u * G / Q / 3600.0) * h + abs(n * u * G / Q / 3600.0) * M * sign(u);
    
    
    
    
    
    
    
    
    
