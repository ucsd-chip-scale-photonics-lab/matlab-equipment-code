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
    np.USB.OpenDevices(); pause(1);
    % get list of devices
    alDevInfoList = np.USB.GetDevInfoList(); pause(1);
    % get device ID of first one (for now, assume we only talk to 1 box)
    np.ID = alDevInfoList.Item(0).ID;
    % query ID to final confirm connection
    newport_query(np, "*IDN?")
end

