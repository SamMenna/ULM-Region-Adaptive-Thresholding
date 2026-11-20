% Frame-based bubble candidate generation stage
% Takes in Raw ultrasound channel data for one acquisition
% and matching sequence metadata (probe, sampling, angles, frame rate, etc.)
% Outputs a bubble-response score map for each processed frame
%
% NO THRESHOLDING YET

% Use filtered-signal magnitude as the first continuous score.
% Do not normalize individual frames or apply a score cutoff.
scoreMaps = abs(iqFiltered);
frameCount = size(scoreMaps, 3);
candidateRows = cell(frameCount, 1);

for frameIdx = 1:frameCount
    scoreMap = scoreMaps(:, :, frameIdx);
    peakMask = imregionalmax(scoreMap);
    [rows, columns] = find(peakMask);

    xCoordinates = xaxis(columns);
    xCoordinates = xCoordinates(:);
    zCoordinates = zaxis(rows);
    zCoordinates = zCoordinates(:);
    peakScores = scoreMap(peakMask);
    peakScores = peakScores(:);

    candidateRows{frameIdx} = table( ...
        repmat(frameIdx, numel(rows), 1), ...
        rows, columns, xCoordinates, zCoordinates, peakScores, ...
        'VariableNames', ...
        {'Frame', 'PixelRow', 'PixelColumn', 'X_m', 'Z_m', 'Score'});
end

candidateTable = vertcat(candidateRows{:});

fprintf('Created %d score maps for %d frames.\n', frameCount, frameCount);
fprintf('Recorded %d local-peak candidates with no score cutoff.\n', ...
    height(candidateTable));
disp(candidateTable(1:min(10, height(candidateTable)), :));

save('bubble_candidates_preview.mat', ...
    'scoreMaps', 'candidateTable', 'xaxis', 'zaxis', '-v7.3');
