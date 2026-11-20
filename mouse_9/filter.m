clear; clc; close all;

addpath(genpath(fullfile(pwd, 'MUST')));
param = jsondecode(fileread('sequence.json'));

fid = fopen('preview_50frames.bin', 'r', 'ieee-le');
if fid == -1
    error('Cannot find preview_50frames.bin. Check that mouse_9 is the current folder.');
end
header = fread(fid, 3, 'int32=>double');
samples = fread(fid, Inf, 'int16=>double');
fclose(fid);

if numel(samples) ~= prod(header)
    error('The sample count does not match the binary header.');
end

raw = reshape(samples, header(1), header(2), header(3));
iq = complex(raw(1:2:end, :, :), -raw(2:2:end, :, :));

nbAngles = str2double(param.nbAngles);
if mod(header(3), nbAngles) ~= 0
    error('The transmit-event count is not divisible by the angle count.');
end

iq = reshape(iq, size(iq, 1), size(iq, 2), nbAngles, []);
frameCount = size(iq, 4);
fprintf('Frames in sample: %d\n', frameCount);

Probe = getProbe(param);
Probe.Nelements = size(raw, 2);

angles = sscanf(param.angles_deg, '%f,');
if numel(angles) ~= nbAngles
    error('The number of steering angles does not match nbAngles.');
end

txdel = cell(nbAngles, 1);
for k = 1:nbAngles
    txdel{k} = txdelay(Probe, angles(k) * pi / 180);
end

ParamBF = Probe;
ParamBF.fc = str2double(param.frequency_MHz) * 1e6;

if strcmp(param.sampling, 'BS100BW')
    ParamBF.fs = ParamBF.fc;
elseif strcmp(param.sampling, 'BS50BW')
    ParamBF.fs = ParamBF.fc / 2;
else
    error('Unsupported sampling mode.');
end

ParamBF.fnumber = 1.4;
startDepth = str2double(param.startDepth_wavelengths);
ParamBF.t0 = (2 * (startDepth - Probe.lensCorrection_wl) ...
    - Probe.twPeak_wl) / ParamBF.fc;

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

% Beamform each angle and add it immediately to limit memory use.
iqBeamformed = zeros(length(zaxis), length(xaxis), frameCount);

for k = 1:nbAngles
    fprintf('Beamforming angle %d of %d...\n', k, nbAngles);
    angleResult = das( ...
        squeeze(iq(:, :, k, :)), xgrid, zgrid, txdel{k}, ParamBF);
    iqBeamformed = iqBeamformed + angleResult;
end

% Suppress the strongest slowly changing components across time.
iqFlat = reshape(iqBeamformed, [], frameCount);
[~, ~, eigVec] = svd(double(iqFlat' * iqFlat), 'econ');

nRemove = max(1, round(frameCount * 0.05));
if nRemove >= frameCount
    error('Not enough frames for the requested clutter filter.');
end

eigVec = eigVec(:, nRemove+1:end);
filteredFlat = (iqFlat * eigVec) * eigVec';
iqFiltered = reshape(filteredFlat, size(iqBeamformed));

% Calculate brightness for the first frame before and after filtering.
rawFrame = abs(iqBeamformed(:, :, 1));
filteredFrame = abs(iqFiltered(:, :, 1));

rawPeak = max(rawFrame(:));
filteredPeak = max(filteredFrame(:));

if rawPeak == 0
    error('The first beamformed frame contains no signal.');
end

if filteredPeak == 0
    filteredPeakDb = -Inf;
else
    filteredPeakDb = 20 * log10(filteredPeak / rawPeak);
end

fprintf('Filtered peak relative to raw peak: %.1f dB\n', filteredPeakDb);

% Panel 1: raw frame. Panel 2: filtered, same brightness reference.
% Panel 3: filtered, brightened only to reveal its remaining pattern.
rawDb = 20 * log10(rawFrame / rawPeak + eps);
filteredSameScaleDb = 20 * log10(filteredFrame / rawPeak + eps);

if filteredPeak > 0
    filteredBrightenedDb = 20 * log10(filteredFrame / filteredPeak + eps);
else
    filteredBrightenedDb = -Inf(size(filteredFrame));
end

figure;

subplot(1, 3, 1);
imagesc(xaxis * 1e3, zaxis * 1e3, rawDb, [-40 0]);
axis image;
colormap gray;
colorbar;
xlabel('Lateral position (mm)');
ylabel('Depth (mm)');
title('Raw');

subplot(1, 3, 2);
imagesc(xaxis * 1e3, zaxis * 1e3, filteredSameScaleDb, [-40 0]);
axis image;
colormap gray;
colorbar;
xlabel('Lateral position (mm)');
ylabel('Depth (mm)');
title('Filtered, same scale');

subplot(1, 3, 3);
imagesc(xaxis * 1e3, zaxis * 1e3, filteredBrightenedDb, [-40 0]);
axis image;
colormap gray;
colorbar;
xlabel('Lateral position (mm)');
ylabel('Depth (mm)');
title('Filtered, brightened for viewing');