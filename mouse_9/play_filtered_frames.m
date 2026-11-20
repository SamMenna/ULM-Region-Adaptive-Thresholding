if ~exist('iqFiltered', 'var')
    error('Run beamform_filter_preview.m first so iqFiltered is available.');
end

displayPeak = max(abs(iqFiltered(:)));
if displayPeak == 0
    error('The filtered data contains no signal to display.');
end

% Set up one image that we update for each frame.
firstFrameDb = 20 * log10(abs(iqFiltered(:, :, 1)) / displayPeak + eps);

figure;
imageHandle = imagesc( ...
    xaxis * 1e3, zaxis * 1e3, firstFrameDb, [-40 0]);
axis image;
colormap gray;
colorbar;
xlabel('Lateral position (mm)');
ylabel('Depth (mm)');

% Play all filtered frames, keeping the display scale fixed.
for k = 1:size(iqFiltered, 3)
    frameDb = 20 * log10(abs(iqFiltered(:, :, k)) / displayPeak + eps);
    set(imageHandle, 'CData', frameDb);
    title(sprintf('Filtered frame %d of %d', k, size(iqFiltered, 3)));
    drawnow;
    pause(0.1);
end