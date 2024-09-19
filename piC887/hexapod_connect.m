function PIdevice = hexapod_connect()
    % TODO catch error assocaited with not doing "ifs 100 ipmaxconn 2" and
    % give sensible suggestion to user

    % Load drivers and connect to C-887 hexapod controller in CPTF 
    % There would be a lot of arguments to this if this code were used in
    % any other situation, but fortunately we only have one of these :)
    ip = '169.254.11.63';
    port = 50000;
    % Load PI MATLAB Driver 
    addpath(getenv('PI_MATLAB_DRIVER'));
    % Load PI_GCS_Controller if not already loaded
    if(~exist('Controller','var'))
        Controller = PI_GCS_Controller();
    end
    if(~isa(Controller,'PI_GCS_Controller'))
        Controller = PI_GCS_Controller();
    end
    % connect to the hexapod and return object
    try
        % TODO check if a connection already exists and close it if so
        PIdevice = Controller.ConnectTCPIP ( ip, port ) ;
        % query controller identification string
        connectedControllerName = PIdevice.qIDN();
        disp(connectedControllerName);
        % initialize PIdevice object for use in MATLAB
        PIdevice = PIdevice.InitializeController ();
    catch
        Controller.Destroy;
        clear Controller;
        clear PIdevice;
        rethrow(lasterror);
    end
end

