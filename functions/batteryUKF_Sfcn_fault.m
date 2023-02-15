function batteryUKF_Sfcn(block)
% Level-2 MATLAB file S-Function for inherited sample time demo.
%   Copyright 1990-2009 The MathWorks, Inc.

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of input and output ports
  block.NumInputPorts  = 3;
  block.NumOutputPorts = 7;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  % voltage measurement
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  block.InputPort(1).SamplingMode      = 'Sample';
  
  % current measurement
  block.InputPort(2).Dimensions        = 1;
  block.InputPort(2).DirectFeedthrough = false;
  block.InputPort(2).SamplingMode      = 'Sample';

  % current time
  block.InputPort(3).Dimensions        = 1;
  block.InputPort(3).DirectFeedthrough = false;
  block.InputPort(3).SamplingMode      = 'Sample';

  % soc estimate
  block.OutputPort(1).Dimensions       = 1;
  block.OutputPort(1).SamplingMode     = 'Sample';
  
  % soc bounds
  block.OutputPort(2).Dimensions       = 1;
  block.OutputPort(2).SamplingMode     = 'Sample';
  
  % voltage estimate
  block.OutputPort(3).Dimensions       = 1;
  block.OutputPort(3).SamplingMode     = 'Sample';
  
  % internal resistance estimate and bound
  block.OutputPort(4).Dimensions       = 1;
  block.OutputPort(4).SamplingMode     = 'Sample';
  block.OutputPort(5).Dimensions       = 1;
  block.OutputPort(5).SamplingMode     = 'Sample';
  
  % capacity estimate and bound
  block.OutputPort(6).Dimensions       = 1;
  block.OutputPort(6).SamplingMode     = 'Sample';
  block.OutputPort(7).Dimensions       = 1;
  block.OutputPort(7).SamplingMode     = 'Sample';
  
  block.NumDialogPrms     = 5; % battery, dt, ukfBatteryParams
  
  %% Set block sample time to inherited
%   block.SampleTimes = [-1 0];
  block.SampleTimes = [1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 7;
  
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 5;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name = 'sigmax1'; 
  block.Dwork(2).Dimensions      = 3;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;
  
  block.Dwork(3).Name = 'sigmax2'; 
  block.Dwork(3).Dimensions      = 3;
  block.Dwork(3).DatatypeID      = 0;
  block.Dwork(3).Complexity      = 'Real';
  block.Dwork(3).UsedAsDiscState = true;
  
  block.Dwork(4).Name = 'sigmax3'; 
  block.Dwork(4).Dimensions      = 3;
  block.Dwork(4).DatatypeID      = 0;
  block.Dwork(4).Complexity      = 'Real';
  block.Dwork(4).UsedAsDiscState = true;
  
  block.Dwork(5).Name = 'R0'; 
  block.Dwork(5).Dimensions      = 2;
  block.Dwork(5).DatatypeID      = 0;
  block.Dwork(5).Complexity      = 'Real';
  block.Dwork(5).UsedAsDiscState = true;
  
  block.Dwork(6).Name = 'Q'; 
  block.Dwork(6).Dimensions      = 2;
  block.Dwork(6).DatatypeID      = 0;
  block.Dwork(6).Complexity      = 'Real';
  block.Dwork(6).UsedAsDiscState = true;
  
  block.Dwork(7).Name = 'PriorI'; 
  block.Dwork(7).Dimensions      = 1;
  block.Dwork(7).DatatypeID      = 0;
  block.Dwork(7).Complexity      = 'Real';
  block.Dwork(7).UsedAsDiscState = true;

  
%endfunction

function InitConditions(block)
    %% Initialize Dwork
    % Initialize 3 states and outputs
    battery = block.DialogPrm(1).Data;
    init = [battery.z, battery.Ir, battery.h];
    %init = [.95, .05, .002];
    for i=1:3
        block.Dwork(1).Data(i) = init(i);
    end
    
    ukfBatteryParams = block.DialogPrm(3).Data;
    
    block.Dwork(2).Data(1:3) = ukfBatteryParams.sigma_x(1,:);
    block.Dwork(3).Data(1:3) = ukfBatteryParams.sigma_x(2,:);
    block.Dwork(4).Data(1:3) = ukfBatteryParams.sigma_x(3,:);
    
    % bounds
    block.Dwork(1).Data(4) = 0;
    
    % voltage
    block.Dwork(1).Data(5) = battery.v0;
    
    % gets the soc given the current voltage
    % block.OutputPort(1).Data = find(ukfBatteryParams.soc_ocv>=battery.v0,1);
    
    block.OutputPort(1).Data = min(1.0, normrnd(battery.z, .025));

    % init internal resistance state and variance uncertainty
    block.Dwork(5).Data(1) = ukfBatteryParams.R0init;
    block.Dwork(5).Data(2) = ukfBatteryParams.SigmaR0;
    
    % init capacitance state and variance uncertainty
    block.Dwork(6).Data(1) = ukfBatteryParams.Qinit;
    block.Dwork(6).Data(2) = ukfBatteryParams.SigmaQ;
    
    % initial current
    block.Dwork(7).Data(1) = 0;
  
%endfunction

function Output(block)
    % soc
    block.OutputPort(1).Data = block.Dwork(1).Data(1);
    
    % soc bounds
    block.OutputPort(2).Data = block.Dwork(1).Data(4);
    
    % voltage estimate
    block.OutputPort(3).Data = block.Dwork(1).Data(5);
    
    % internal resistance estimate and respective bounds
    block.OutputPort(4).Data = block.Dwork(5).Data(1);
    block.OutputPort(5).Data = block.Dwork(5).Data(2);
    
    % capacity estimate and respective bounds
    block.OutputPort(6).Data = block.Dwork(6).Data(1);
    block.OutputPort(7).Data = block.Dwork(6).Data(2);
    
  
%endfunction

function Update(block)
    % get block arguments
    battery           = block.DialogPrm(1).Data;
    dt                = block.DialogPrm(2).Data;
    ukfBatteryParams  = block.DialogPrm(3).Data;
    deltat=dt;

    % parameters
    n  = battery.n;
    Q  = battery.Q;
    G  = battery.G;
    M0 = battery.M0;
    M  = battery.M;
    R0 = battery.R0;
    R  = battery.R;
    RC = exp(-dt/abs(battery.RC))';

    % input current and voltage
    voltage = block.InputPort(1).Data;
    current = block.InputPort(2).Data;


    % states
    z  = block.Dwork(1).Data(1);
    Ir = block.Dwork(1).Data(2);
    h  = block.Dwork(1).Data(3);
    %for parameter estimation
    priorzk = z;



    % get current time
    t = block.InputPort(3).Data;

    % get fault time
    ft = block.DialogPrm(4).Data;

    % implement fault
    if t > (ft + .15)
        Q = block.DialogPrm(5).Data;
        battery.z_coef(7) = battery.z_coef(7) * .98;
        z = z * .99999;
    end



    if current<0
        current = current*n; 
    end

    x_hat = [Ir h z]';

    sigma_x = zeros(3,3);
    sigma_x(1,:) = block.Dwork(2).Data(1:3);
    sigma_x(2,:) = block.Dwork(3).Data(1:3);
    sigma_x(3,:) = block.Dwork(4).Data(1:3);

    % Get data stored in params structure
    sigma_w = ukfBatteryParams.sigma_w;
    sigma_noise = ukfBatteryParams.sigma_noise;
    bump_val  = ukfBatteryParams.bump_val;
    gamma  = ukfBatteryParams.gamma;

    x_len   = ukfBatteryParams.x_len;
    w_len   = ukfBatteryParams.w_len;
    v_len   = ukfBatteryParams.v_len;
    aux_len = ukfBatteryParams.aux_len;

    cov_weights = ukfBatteryParams.cov_weights;
    mu_weights  = ukfBatteryParams.mu_weights;

    u_sign = sign(current);

    % create augmented sigma_x and x_hat
    [sigma_x_aux,p] = chol(sigma_x,'lower'); 
    if p > 0
        fprintf('Cholesky error.  Recovering...\n');
        diag_sigma_x = abs(diag(sigma_x));
        sigma_x_aux = diag(max(SQRT(diag_sigma_x),SQRT(sigma_w)));
    end

    sigma_x_aux=[real(sigma_x_aux) zeros([x_len w_len+v_len]); zeros([w_len+v_len x_len]) sigma_noise];
    x_hat_aux = [x_hat; zeros([w_len+v_len 1])];
    % sigma_x_aux is lower-triangular

    % calculate sigma points
    aux_state_mat = x_hat_aux(:,ones([1 2*aux_len+1])) + ...
       gamma*[zeros([aux_len 1]), sigma_x_aux, -sigma_x_aux];

    % state update
    x_hat_pre = aux_state_mat(1:x_len,:);
    xnoise = aux_state_mat(x_len+1:x_len+w_len,:);
    current = current + xnoise;
    H_mat = exp(-abs(n*current*G*dt/(3600*Q))); 

    x_hat_post = 0*x_hat_pre;
    x_hat_post(1,:) = RC*x_hat_pre(1,:) + (1-diag(RC))*current; 
    x_hat_post(2,:) = H_mat.*x_hat_pre(2,:) + (H_mat-1).*sign(current);
    x_hat_post(3,:) = x_hat_pre(3,:) - n*current/3600/Q;

    x_hat_post(2,:) = min(1,max(-1,x_hat_post(2,:)));
    x_hat_post(3,:) = min(1.05,max(-0.05,x_hat_post(3,:)));

    x_hat = x_hat_post*mu_weights;

    % error cov update
    cov_pre = x_hat_post - x_hat(:,ones([1 2*aux_len+1]));
    sigma_x = cov_pre*diag(cov_weights)*cov_pre';

    % output estimate
    ynoise = aux_state_mat(x_len+w_len+1:end,:); 
    %obtain OCV
    sochat=x_hat_post(3,:);
    if any(sochat < 0.0)
        sochat(sochat < 0.0) = 0;
    elseif any(sochat > 1.0)
        sochat(sochat > 1.0) = 1.0;
    end    
    idx = ceil(sochat*100);    
    if any(idx > 101)
        idx(idx > 101) = 101;
    end
    if any(idx < 1)
        idx(idx < 1) = 1;
    end
    
    ocv = polyval(battery.z_coef, idx);
    %ocv = ukfBatteryParams.soc_ocv(idx);    
    
    Y = ocv + M*x_hat_post(2,:) + M0*u_sign - R*x_hat_post(1,:) - R0*current + ynoise(1,:);

    y_hat = Y*mu_weights;

    % update kalman gain
    residual = Y - y_hat(:,ones([1 2*aux_len+1]));
    innov = cov_pre*diag(cov_weights)*residual';
    sigma_y = residual*diag(cov_weights)*residual';
    K = innov/sigma_y; 

    % measurement update
    r = voltage - y_hat; % residual.  Use to check for sensor errors...
    if r^2 > 100*sigma_y, K(:,1)=0.0; end 
    x_hat = x_hat + K*r; 
    x_hat(3)=min(1.05,max(-0.05,x_hat(3)));
    x_hat(2) = min(1,max(-1,x_hat(2)));

    % error cov measurement update, use hager method to ensure positive
    % semidefinite
    sigma_x = sigma_x - K*sigma_y*K';
    [~,S,V] = svd(sigma_x);
    HH = V*S*V';
    sigma_x = (sigma_x + sigma_x' + HH + HH')/4; % Help maintain robustness

    % Q-bump code
    if r^2>1*sigma_y, % bad voltage estimate by 2-SigmaX, bump Q 
        % fprintf('Bumping sigmax\n');
        sigma_x(3,3) = sigma_x(3,3)*bump_val;
    end

    block.Dwork(1).Data(1)=x_hat(3);
    block.Dwork(1).Data(2)=x_hat(1);
    block.Dwork(1).Data(3)=x_hat(2);

    block.Dwork(1).Data(4) = 3*sqrt(sigma_x(3,3));
    block.Dwork(1).Data(5) = sum(y_hat)/length(y_hat);

    block.Dwork(2).Data(1:3) = sigma_x(1,:);
    block.Dwork(3).Data(1:3) = sigma_x(2,:);
    block.Dwork(4).Data(1:3) = sigma_x(3,:);
    
    %% parameter estimation
     
% **** 1-state parameter-estimation SPKF to estimate R0 **** 
    voltage = block.InputPort(1).Data;
    current = block.InputPort(2).Data;
    xhat=x_hat;
     
    % get last value of the state
    spkfData.R0hat  = block.Dwork(5).Data(1);
    %for initialization
    spkfData.SigmaR0= block.Dwork(5).Data(2);    
    
    %parameters    
    spkfData.SigmaWR0=ukfBatteryParams.SigmaWR0;
    spkfData.R0c=ukfBatteryParams.R0c;
    spkfData.R0m=ukfBatteryParams.R0m;
    spkfData.h=ukfBatteryParams.h;
    irInd = 1;
    hkInd = 2;
    zkInd = 3;
    spkfData.xhat=[Ir h z]';
    ik=current;vk=voltage;
    spkfData.SigmaV=ukfBatteryParams.sigma_v;
    
    % Implement SPKF for R0hat
    % Step 1a -- R0hat prediction = R0hat estimate... no code needed
    % Step 1b -- R0hat covariance update
    spkfData.SigmaR0 = spkfData.SigmaR0 + spkfData.SigmaWR0;
    % Step 1c -- ouput estimate
    W = spkfData.R0hat*[1 1 1] + sqrt(spkfData.h*spkfData.SigmaR0)*[0 1 -1];
    % Next line is simplified output equation
%     D = OCVfromSOCtemp(spkfData.xhat(zkInd),Tk,model)*[1 1 1] -W*ik;
    %obtain OCV
    sochat=spkfData.xhat(zkInd,:);
    if sochat < 0.0
        sochat = 0;
    elseif sochat > 1.0
        sochat = 1.0;
    end    
    idx = ceil(sochat*100);    
    if any(idx > 101)
        idx(idx > 101) = 101;
    elseif any(idx < 1)
        idx(idx < 1) = 1;
    end
    %ocv = ukfBatteryParams.soc_ocv(idx);  
    ocv = polyval(battery.z_coef, idx);
    D = ocv*[1 1 1] -W*ik;
    % Next line is enhanced output equation -- uncomment the next line for two quiz questions!
    D = D + M*xhat(hkInd) - R*xhat(irInd);
    Dhat = D*spkfData.R0m;
    % Step 2a -- gain estimate 
    Ds = D - Dhat;
    Ws = W - spkfData.R0hat;
    Sd = Ds*diag(spkfData.R0c)*Ds' + spkfData.SigmaV; % linear sensor noise
    Swd = Ws*diag(spkfData.R0c)*Ds';
    L = Swd/Sd;
    % Step 2b -- R0 estimate measurement update
    spkfData.R0hat = spkfData.R0hat + L*(vk - Dhat);
    % Step 2c -- R0 estimatation error covariance
    spkfData.SigmaR0 = spkfData.SigmaR0 - L*Sd*L';
    
    block.Dwork(5).Data(1) = spkfData.R0hat;
    block.Dwork(5).Data(2) = spkfData.SigmaR0;
    
% **** end of simple 1-state SPKF to estimate R0 ****  

% **** 1-state parameter-estimation SPKF to estimate Q **** 
 % Implement SPKF for Qhat 
 
    % get last value of the state
    spkfData.Qhat  = block.Dwork(6).Data(1);
    % for initialization
    spkfData.SigmaQ= block.Dwork(6).Data(2);  
    % current from the previous time
    spkfData.priorI=block.Dwork(7).Data(1);
    
    spkfData.SigmaWQ=ukfBatteryParams.SigmaWQ;
    spkfData.Qc=ukfBatteryParams.Qc;
    spkfData.Qm=ukfBatteryParams.Qm;
    spkfData.h=ukfBatteryParams.h;
    irInd = 1;
    hkInd = 2;
    zkInd = 3;
    spkfData.xhat=[Ir h z]';
    ik=current;
    vk=voltage;
    spkfData.SigmaV=ukfBatteryParams.sigma_v;
    
    % Step 1a -- Qhat prediction = Qhat estimate... no code needed
    % Step 1b -- Qhat covariance update
    spkfData.SigmaQ = spkfData.SigmaQ + spkfData.SigmaWQ;
    % Step 1c -- ouput estimate
    W = spkfData.Qhat*[1 1 1] + sqrt(spkfData.h*spkfData.SigmaQ)*[0 1 -1];
    % Next line is constructed output equation
    D = xhat(zkInd) - priorzk + spkfData.priorI*deltat./(3600*W);
    Dhat = D*spkfData.Qm;
    % Step 2a -- gain estimate 
    Ds = D - Dhat;
    Ws = W - spkfData.Qhat;
    Sd = Ds*diag(spkfData.Qc)*Ds' + spkfData.SigmaV; % linear sensor noise
    Swd = Ws*diag(spkfData.Qc)*Ds';
    L = Swd/Sd;
    % Step 2b -- Q estimate measurement update
    spkfData.Qhat = spkfData.Qhat + L*(0 - Dhat);
    % Step 2c -- Q estimatation error covariance
    spkfData.SigmaQ = spkfData.SigmaQ - L*Sd*L';
    
    block.Dwork(6).Data(1) = spkfData.Qhat;
    block.Dwork(6).Data(2) = spkfData.SigmaQ;
    % prior current
    block.Dwork(7).Data(1) = ik;
  % **** end of simple 1-state SPKF to estimate Q ****  

%endfunction


