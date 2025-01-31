function newport_range(np, power_W)
%NEWPORT_RANGE Manually set PM range (in W) for the currently active channel
% First, the power meter is set to manual ranging
newport_autorange(np, false);
% The range will be set to the most sensitive range that doesn't saturate
% the provided powers. Depending on the detector head attached to the unit,
% the exact cutoffs differ, so we do a bit of chatting with the box to
% figure out what's the best

% If this fails, also provide a functionality to give index manually TODO

RANGE_FACTOR = 10; % 10x increment between ranges in terms of power
% get current max power and range idx, then calculate needed range
existing_max_W = str2double(newport_query(np, 'PM:MAX:Power?'));

if is_good_range(power_W, existing_max_W, RANGE_FACTOR)
    % don't do anything if the range is already good
    return
end

existing_range_idx = str2double(newport_query(np, "PM:RANGE?"));
% this is the power corresponding to a range of "0"
base_range_W = existing_max_W/RANGE_FACTOR^existing_range_idx;
% calculate best index
best_idx = ceil(logbase(RANGE_FACTOR, power_W/base_range_W));
if(best_idx < 0)
    warning("Requested power is too small for minimum power meter range, using lowest possible range.")
    best_idx = 0;
elseif(best_idx > 7)
    warning("Requested power is too big for maximum power meter range, using highest possible range.")
    best_idx = 7;
end
% write it
newport_write(np, sprintf("PM:RANGE %d", best_idx));

% check again
existing_max_W = str2double(newport_query(np, 'PM:MAX:Power?'));
if is_good_range(power_W, existing_max_W, RANGE_FACTOR)
    fprintf("Updated power meter range to %1.2e W for specified power %1.2e W\n", existing_max_W, power_W);
else
    warning("Updated power meter range %1.2e W isn't actually the best range for desired power %1.2e W, you either exceeded power meter range (see previous warning) or my code is broken :(", existing_max_W, power_W);
end

end

function out = is_good_range(power_W, existing_max_W, RANGE_FACTOR)
    out = power_W < existing_max_W && power_W > existing_max_W/RANGE_FACTOR;
end

function out = logbase(base, value)
    % so silly that matlab doesn't have this
    out = log2(value) / log2(base);
end
