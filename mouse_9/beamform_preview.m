clear; clc; close all;

% Make sure MATLAB can find MUST.
addpath(genpath(fullfile(pwd, 'MUST')));

% Read the acquisition settings.
param = jsondecode(fileread('sequence.json'));

% Read the preview binary file: 3 integer dimensions, then int16 samples.
fid = fopen('preview_5frames.bin', 'r', 'ieee-le');
if fid == -1
    error('Cannot find preview_5frames.bin. Check that mouse_9 is the current folder.');
end
header = fread(fid, 3, 'int32=>double');
samples = fread(fid, Inf, 'int16=>double');
fclose(fid);

if numel(samples) ~= prod(header)
    error('The number of data values does not match the binary header.');
end

% Reshape samples into [fast-time samples, channels, transmit events].
raw = reshape(samples, header(1), header(2), header(3));

% The dataset stores I and Q on alternating rows.
iq = complex(raw(1:2:end, :, :), -raw(2:2:end, :, :));

% The transmit events contain 11 angles for each compounded frame.
nbAngles = str2double(param.nbAngles);
if mod(header(3), nbAngles) ~= 0
    error('Transmit-event count is not divisible by the angle count.');
end
iq = reshape(iq, size(iq, 1), size(iq, 2), nbAngles, []);

% Load probe settings and create transmit delays for each angle.
Probe = getProbe(param);
Probe.Nelements = size(raw, 2);

angles = sscanf(param.angles_deg, '%f,');
txdel = cell(nbAngles, 1);
for k = 1:nbAngles
    txdel{k} = txdelay(Probe, angles(k) * pi / 180);
end

% Set the beamforming parameters.
ParamBF = Probe;
ParamBF.fc = str2double(param.frequency_MHz) * 1e6;

if strcmp(param.sampling, 'BS100BW')
    ParamBF.fs = ParamBF.fc;
elseif strcmp(param.sampling, 'BS50BW')
    ParamBF.fs = ParamBF.fc / 2;
else
    error('This script does not support this sampling mode.');
end

ParamBF.fnumber = 1.4;

startDepth = str2double(param.startDepth_wavelengths);
ParamBF.t0 = (2 * (startDepth - Probe.lensCorrection_wl) ...
    - Probe.twPeak_wl) / ParamBF.fc;

% Define the image grid (in meters).
deltaGrid = 25e-6;
startX = -5e-3;
endX = 5e-3;
startZ = 0.5e-3;
endZ = 8.5e-3;

speedOfSound = str2double(param.speedOfSound);
zFirstSample = speedOfSound * ParamBF.t0 / 2;
startZ = max(startZ, ceil(zFirstSample / deltaGrid) * deltaGrid);

xaxis = startX:deltaGrid:endX-deltaGrid;
zaxis = startZ:deltaGrid:endZ-deltaGrid;
[xgrid, zgrid] = meshgrid(xaxis, zaxis);

% Beamform each steering angle, then combine the angles.
iq_bf = zeros(length(zaxis), length(xaxis), size(iq, 4), nbAngles);
for k = 1:nbAngles
    fprintf('Beamforming angle %d of %d...\n', k, nbAngles);
    iq_bf(:, :, :, k) = das( ...
        squeeze(iq(:, :, k, :)), xgrid, zgrid, txdel{k}, ParamBF);
end
iq_bf = sum(iq_bf, 4);

% Display the first beamformed frame.
imageDb = 20 * log10(abs(iq_bf(:, :, 1)) + eps);
imageDb = imageDb - max(imageDb(:));

figure;
imagesc(xaxis * 1e3, zaxis * 1e3, imageDb, [-40 0]);
axis image;
colormap gray;
colorbar;
xlabel('Lateral position (mm)');
ylabel('Depth (mm)');
title('Beamformed preview: first sample frame');