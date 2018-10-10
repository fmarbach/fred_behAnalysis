function [antLick] = photo_antLicking(trialIndexVec,timeWindow,nLicksThreshold,lickData)

trialNumbers = find(trialIndexVec);
nTrials = length(trialNumbers);

antLick.hit.index = false(length(trialIndexVec),1);
antLick.miss.index = false(length(trialIndexVec),1);
antLick.nLicks = zeros(nTrials,1);

for tt = 1:nTrials
    thisTrial = trialNumbers(tt);
    thisLicks = lickData{thisTrial};
    thisNLicks = sum(thisLicks > timeWindow(1) & ...
                     thisLicks < timeWindow(2));
    
    antLick.hit.index(thisTrial) = thisNLicks >= nLicksThreshold;
    antLick.miss.index(thisTrial) = ~antLick.hit.index(thisTrial);
    antLick.nLicks(tt) = thisNLicks;
    
end

antLick.hit.nTrials = sum(antLick.hit.index);
antLick.miss.nTrials = sum(antLick.miss.index);

binSize = 0.25; % histogram bin size
binVec = -4:binSize:4;
antLick.hit.binCenters = binVec(1:end-1) + binSize/2;
antLick.miss.binCenters = antLick.hit.binCenters;

licksHit = [lickData{antLick.hit.index}];
licksMiss = [lickData{antLick.miss.index}];

[antLick.hit.histogram,antLick.hit.binVec] = histcounts(licksHit,binVec);
[antLick.miss.histogram,antLick.miss.binVec] = histcounts(licksMiss,binVec);

% convert to Hz
antLick.hit.histogram = antLick.hit.histogram / antLick.hit.nTrials / binSize;
antLick.miss.histogram = antLick.miss.histogram / antLick.miss.nTrials / binSize;