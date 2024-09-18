function hexapod_upload_area_scan(hexapod, options)
    % this just wraps PI's own FDR function. The only purpose of this
    % function is to set some sensible defaults for our system and remove
    % a little clutter associated with making the AreaScanParameters object

    % to run a scan, do hexapod.FRS('scan_name')
    arguments
        hexapod
        % use invalid value here that will cause an error, so these
        % 'options' are actually mandatory
        options.routineName = ''; 
        options.scanAxis = 0;
        options.scanAxisRange = 0;
        options.stepAxis = 0;
        options.stepAxisRange = 0;
        options.thresholdLevel = -1; % L
        options.alignmentSignalInputChannel = 5; %A
        options.frequency = 5.0; % F
        % TODO LINE SPACING!
        options.velocity = 0.01; % V
        options.scanAxisMiddlePosition = 0.0; % TODO make these non-optional?
        options.stepAxisMiddlePosition = 0.0; % 
        % TODO make these strings or something!
        options.targetType = 0; % 0 = raster, 1 = spiral
        options.centroidMethod = 2; % 0 = naive max, 1 = gaussian, 2 = COG
        options.minimumRelativeFastAlignmentInputLevel = 10; % MIIL
        options.maximumRelativeFastAlignmentInputLevel = 80; % ;MAIL
        options.stopPositionOption = 0; % 0 = stop at max, 1 = stop at end, 2 = stop at start
    end

    %% Define Area Scan

    % Warning: given values of this sample can damage your system
    % adjust all values accordingly and remove the following line
    %error('adjust FDR values to match your configuration');
    % disp('define gradient scan routine...');
    % PIdevice.FDR needs some parameters as plain text string. The following
    % lines build this string from the parameters in struct 'AreaScan'.
    AreaScanParameters = ...
        [  'L ', num2str(options.thresholdLevel) ...
        , ' A ', num2str(options.alignmentSignalInputChannel) ...
        , ' F ', num2str(options.frequency) ...
        , ' V ', num2str(options.velocity) ...
        , ' MP1 ', num2str(options.scanAxisMiddlePosition) ...
        , ' MP2 ', num2str(options.stepAxisMiddlePosition) ...
        , ' TT ', num2str(options.targetType) ...
        , ' CM ', num2str(options.centroidMethod) ...
        , ' MIIL ', num2str(options.minimumRelativeFastAlignmentInputLevel) ...
        , ' MAIL ', num2str(options.maximumRelativeFastAlignmentInputLevel) ...
        , ' ST ', num2str(options.stopPositionOption)];

    % send definition to controller
    hexapod.FDR(options.routineName ...
        , options.scanAxis ...
        , options.scanAxisRange ...
        , options.stepAxis ...
        , options.stepAxisRange ...
        , AreaScanParameters);
end

