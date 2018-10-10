%%% plot avg trace of trials with / without anticipatory licking
close all;

% --- parameters to set ---

filterType = {'type_1'};
dataType = 'Photo_470';

pre_time = -3; % [s] before reward to plot
post_time = 3;
stim_duration = 1; 
stim_time = -1.5;

antLickWindow = [-1.4 0]; % [s]
nLicksThreshold = 1; % number of licks during antLickWindow to count as a antLicking trial

% colors
%trialColor = 0.7*[1 1 1];
%stimColor = [0.7 0.8 1]; %light blue
stimColor = 0.9*[1 1 1];
avgColor = [0.8 0.2 0.2];

% ------------------------

% get logical index vector for trial type of interest
filterIndex = find(strcmp(Analysis.Filters.Names,filterType)); % one number
thisIndexVec = Analysis.Filters.Logicals(:,filterIndex)==1; % vector over all trials

% get all time 'x axis' data
thisTime = Analysis.AllData.Photo_470.Time(thisIndexVec,:);

% time is already 'event subtracted', so usually 0 for reward delivery
offset_samp = find(thisTime(1,:)>0,1,'first');
n = length(thisTime(:,1)); % number of trials
% get sampling rate (this is probably saved somewhere)
sr = length(thisTime(1,:)) ...
     / (thisTime(1,end)-thisTime(1,1));
pre_samp = round(sr * pre_time) + offset_samp;
post_samp = round(sr * post_time) + offset_samp;
stimON_samp = round(sr * stim_time) + offset_samp;
stimOFF_samp = stimON_samp + round(stim_duration * sr)-1;
antLick_samp = round(sr * antLickWindow) + offset_samp;

% find antLicking trials
lickData = Analysis.AllData.Licks.Events;
[antLick] = photo_antLicking(thisIndexVec,antLickWindow,nLicksThreshold,lickData);
% plot lick histograms (sanity check)
figure;
plot(antLick.hit.binCenters,antLick.hit.histogram,...
     antLick.hit.binCenters,antLick.miss.histogram);
xlabel('time'); ylabel('lick rate [Hz]');

%set up data for different trial types to plot
d.antLick = Analysis.AllData.(dataType).DFF(antLick.hit.index,pre_samp:post_samp)';
d.no_antLick = Analysis.AllData.(dataType).DFF(antLick.miss.index,pre_samp:post_samp)';
dNames = fieldnames(d);

colors = colormap(lines(5));

% loop over fields of d
% add fields to d to add different conditions
figure;
for ii = 1:length(dNames)
    
    thisData = d.(dNames{ii});
    thisColor = colors(ii,:);
  
    dataAvg = nanmean(thisData,2)';
    xvec = pre_time:1/sr:post_time;
    
    % --- plot things ---

    % get confidence intervals for shaded error bar
    ci = bootci(1000,@mean,thisData');
    
    % plot rectangle during stimulus
    rh = rectangle('Position',[stim_time min(ci(:)) stim_duration abs(min(ci(:)))+max(ci(:))],...
                   'FaceColor',stimColor,'EdgeColor','none');
    hold on;
    % plot data with error bar
    shadedErrorBar(xvec,dataAvg,[ci(2,:)-dataAvg;dataAvg-ci(1,:)],...
                    {'LineWidth',2,'Color',thisColor},1);


end

% figure grooming
uistack(rh,'bottom');
xlab = 'Time from reward [s]';
ylab = 'DF/F [%]';
xlim = [pre_time-0.1 post_time+0.1];
formatFigure(gcf,gca,18,0,10,...
               xlab,ylab,xlim,0,...
               1,[1 1 1],0,0,1);
                      

figure;
stim_dff = mean(Analysis.AllData.Photo_470.DFF(thisIndexVec,stimON_samp:stimOFF_samp),2);
scatter(antLick.nLicks,stim_dff)



