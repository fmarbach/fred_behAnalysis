%%% plot avg trace of different trial types or before / after inactivation

clear d

filterType = {'type_1','LicksCue'};

muscTrial = 0;

pdfName = 'muscCueA.pdf';

pre_time = -3;
post_time = 3;
stim_duration = 1;
stim_time = -1.5;

% colors
%trialColor = 0.7*[1 1 1];
%stimColor = [0.7 0.8 1]; %light blue
stimColor = 0.9*[1 1 1];
avgColor = [0.8 0.2 0.2];

% ----------------
filterIndex = [];
for ff = 1:length(filterType)
    filterIndex(ff) = find(strcmp(Analysis.Filters.Names,filterType{ff}));
end
tmp = Analysis.Filters.Logicals(:,filterIndex);
thisIndexVec = sum(tmp,2)==length(filterType);
thisTime = Analysis.AllData.Photo_470.Time(thisIndexVec,:);

% time is already 'event subtracted', so usually 0 for reward delivery
offset_samp = find(thisTime(1,:)>0,1,'first');
n = length(thisTime(:,1)); % number of trials
% get sampling rate (this is probably saved somewhere)
sr = length(thisTime(1,:)) ...
     / (thisTime(1,end)-thisTime(1,1));
pre_samp = round(sr * pre_time) + offset_samp;
post_samp = round(sr * post_time) + offset_samp;
stimON_samp = round(sr * stim_time);
stimOFF_samp = stimON_samp + round(stim_duration * sr)-1;

%set up different trial types to plot
type = 'type_1';
if muscTrial == 0
    totalTrials = length(thisIndexVec);
    muscTrial = totalTrials - Analysis.Properties.nTrials;
end
filterIndexPre = thisIndexVec;
filterIndexPre(muscTrial:end) = 0;
filterIndexPost = thisIndexVec;
filterIndexPost(1:muscTrial-1) = 0;
d.preMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPre,pre_samp:post_samp)';
d.postMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPost,pre_samp:post_samp)';


dNames = fieldnames(d);
%colors = colormap(lines(length(dNames)));
colors = colormap(lines(5));

for ii = 1:length(dNames)
    
    thisData = d.(dNames{ii});
    thisColor = colors(ii,:);
    
    %f0 = prctile(data(1:round(abs(sr * pre_time)),:),0.2,1);
    %data0 = bsxfun(@minus,thisData,f0);
    dataAvg = nanmean(thisData,2)';
    xvec = pre_time:1/sr:post_time;
    
    % plot things
    
    %plot(xvec,thisData,'Color',trialColor,'LineWidth',1)
    %plot(xvec,dataAvg,'Color',avgColor,'LineWidth',3)

    % get confidence intervals for shaded error bar
    ci = bootci(500,@mean,thisData');
    rh = rectangle('Position',[stim_time min(ci(:)) stim_duration abs(min(ci(:)))+max(ci(:))],...
                   'FaceColor',stimColor,'EdgeColor','none');
    hold on;
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
           
%legend(dNames,'Location','NorthWest');
           
%fname = [type '_' pdfName];
%fPath = [DefaultParam.PathName DefaultParam.FileList(1:end-4) '_' fname];
%saveas(gcf,fPath);




