function np = newport_start()
    % connect to to a SINGLE newport 1936 or 2936 box
    % returned object has fields np.USB for usb object and np.ID for ID of
    % this box, which is needed when using the Newport .NET functions

    % load dll for talking to newport over USB
    filepath = fileparts(mfilename('fullpath'));
    dllPath = fullfile(filepath, "UsbDllWrap.dll");
    NET.addAssembly(dllPath);
    % create object representing ALL newport USB connections
    np.USB = Newport.USBComm.USB();
    % open connection to all devices
    np.USB.CloseDevices();
    np.USB.OpenDevices(); pause(1);
    % get list of devices
    alDevInfoList = np.USB.GetDevInfoList(); pause(1);
    % get device ID of first one (for now, assume we only talk to 1 box)
    if(alDevInfoList.Count == 0)
        error("No newport devices detected, check that the USB is connected. If it is, restart the Newport.")
    end
    np.ID = alDevInfoList.Item(0).ID;
    % query ID to final confirm connection
    response = newport_query(np, "*IDN?");
    if(response == "")
        error("Newport returning blank messages upon queries, the cause of this issue has not yet been identified. Please restart MATLAB and try again.");
    else
        disp(response);
    end
    % set units to watts, which is what is assumed throughout our code
    newport_write(np, "PM:UNITS 2"); % 2 = Watts
end

