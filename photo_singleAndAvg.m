%%% plot individual traces with average over it

type = 'type_4';
%typeB = 'type_2';

pdfName = 'trials.pdf';

pre_time = -4;
post_time = 6;

rectStart = 0;
stim_duration = 0.05;

% colors
trialColor = 0.7*[1 1 1];
stimColor = [0.7 0.8 1];
avgColor = [0.8 0.2 0.2];

% ----------------

% time is already 'event subtracted', so usually 0 for reward delivery
offset_samp = find(Analysis.(type).Photo_470.Time(1,:)>0,1,'first');
n = length(Analysis.(type).Photo_470.Time(:,1)); % number of trials
% get sampling rate (this is probably saved somewhere)
sr = length(Analysis.(type).Photo_470.Time(1,:)) ...
     / (Analysis.(type).Photo_470.Time(1,end)-Analysis.(type).Photo_470.Time(1,1));
pre_samp = round(sr * pre_time) + offset_samp;
post_samp = round(sr * post_time) + offset_samp;
stimON_samp = round(sr * pre_time);
stimOFF_samp = stimON_samp + round(stim_duration * sr)-1;

data = Analysis.(type).Photo_470.DFF(:,pre_samp:post_samp)';
%f0 = prctile(data(1:round(abs(sr * pre_time)),:),0.2,1);
%data0 = bsxfun(@minus,data,f0);
dataAvg = nanmean(data,2);
xvec = pre_time:1/sr:post_time;

% plot things


rectangle('Position',[rectStart min(data(:)) stim_duration abs(min(data(:)))+max(data(:))],...
          'FaceColor',stimColor,'EdgeColor','none')
hold on;
plot(xvec,data,'Color',trialColor,'LineWidth',1)
plot(xvec,dataAvg,'Color',avgColor,'LineWidth',3)

xlab = 'Time from reward [s]';
ylab = 'DF/F [%]';
xlim = [pre_time-0.1 post_time+0.1];
formatFigure(gcf,gca,18,0,10,...
               xlab,ylab,xlim,0,...
               1,[1 1 1],0,0,1);

fname = [type '_' pdfName];
fPath = [DefaultParam.PathName DefaultParam.FileList(1:end-4) '_' fname];
saveas(gcf,fPath);




