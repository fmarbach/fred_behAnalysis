%%% plot some photometry things

type = 'type_1';
cueTime = -1.5;
preCue_time = [-1 0]+cueTime; % in seconds
postCue_time = [0 2]+cueTime;
preOut_time = [-0.1 0.1];
postOut_time = [0.1 0.7 ];

offset_samp = find(Analysis.(type).Photo_470.Time(1,:)>0,1,'first');
n = length(Analysis.(type).Photo_470.Time(:,1));
sr = length(Analysis.(type).Photo_470.Time(1,:)) ...
     / (Analysis.(type).Photo_470.Time(1,end)-Analysis.(type).Photo_470.Time(1,1));
b.preCue_samp = round(sr * preCue_time);
b.postCue_samp = round(sr * postCue_time);
b.preOut_samp = round(sr * preOut_time);
b.postOut_samp = round(sr * postOut_time);
bnames = fieldnames(b);

avg = []; mx = [];
for ii = 1:n % loop over trials
    
    data = Analysis.(type).Photo_470.DFF(ii,:);
    for bb = 1:length(bnames)
        tmp = [b.(bnames{bb})(1):b.(bnames{bb})(2)] + offset_samp;
        avg(ii,bb) = mean(data(tmp));
        mx(ii,bb) = max(data(tmp));
    end
    
end

% plot 

% scatter(avg(:,2)-avg(:,1),avg(:,4))
% xlab = 'cue response';
% ylab = 'outcome response';
% formatFigure(gcf,gca,14,2,10,...
%                xlab,ylab,0,0,...
%                1,[1 1 1],0,0,1);

% plot time course of cue response
muscTrial = 150;
w = 7;
musc = find(Analysis.(type).TrialNb>muscTrial,1,'first');
data = avg(:,2)-avg(:,1);
%data = mx(:,2)-avg(:,1);
plot(data,'linewidth',1)
hold on;
plot(filtfilt(ones(1,w)/w,1,data),'linewidth',2);
line([musc musc],[min(data) max(data)],'linewidth',1.5,'color','k');
xlab = 'CueA trial number';
ylab = 'CueA response (mean DF/F)';
formatFigure(gcf,gca,14,2,10,...
               xlab,ylab,0,0,...
               1,[1 1 1],0,0,1);

% plot time course of reward response
data = avg(:,4)-avg(:,3);
%data = mx(:,4)-avg(:,3);
plot(data,'linewidth',1)
hold on;
plot(filtfilt(ones(1,w)/w,1,data),'linewidth',2);
line([musc musc],[min(data) max(data)],'linewidth',1.5,'color','k');
xlab = 'CueA trial number';
ylab = 'Mean response [DF/F]';
formatFigure(gcf,gca,14,2,10,...
               xlab,ylab,0,0,...
               1,[1 1 1],0,0,1);
legend({'CueA','CueA','Muscimol injection','CueA Reward','CueA Reward'});





