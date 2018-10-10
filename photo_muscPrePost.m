%%% plot avg trace of different trial types or before / after inactivation

clear d

filterType = {'type_1'};

muscTrial = 0;

pdfName = 'muscCueA.pdf';

pre_time = -3;
post_time = 3;
stim_duration = 1;
stim_time = -1.5;

ylim = 0;
ylim = [-0.5 2.8];

antLickWindow = [-1.5 -0.05];
%antLickWindow = [-0 0.2];
nLicksThreshold = 1;
% colors
%trialColor = 0.7*[1 1 1];
%stimColor = [0.7 0.8 1]; %light blue
stimColor = 0.9*[1 1 1];
avgColor = [0.8 0.2 0.2];

% ----------------
filterIndex = find(strcmp(Analysis.Filters.Names,filterType));

thisIndexVec = Analysis.Filters.Logicals(:,filterIndex)==1;
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
antLick_samp = round(sr * antLickWindow) + offset_samp;

% find antLicking trials
lickData = Analysis.AllData.LickEvents;
[antLick] = photo_antLicking(thisIndexVec,antLickWindow,nLicksThreshold,lickData);

%set up different trial types to plot
if muscTrial == 0
    totalTrials = length(thisIndexVec);
    muscTrial = totalTrials - Analysis.Properties.nTrials;
end
filterIndexPre = thisIndexVec & antLick.miss.index;
filterIndexPre(muscTrial:end) = 0;
filterIndexPost = thisIndexVec & antLick.miss.index;
filterIndexPost(1:muscTrial-1) = 0;
d.miss.preMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPre,pre_samp:post_samp)';
d.miss.postMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPost,pre_samp:post_samp)';

filterIndexPre = thisIndexVec & antLick.hit.index;
filterIndexPre(muscTrial:end) = 0;
filterIndexPost = thisIndexVec & antLick.hit.index;
filterIndexPost(1:muscTrial-1) = 0;
d.hit.preMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPre,pre_samp:post_samp)';
d.hit.postMuscimol = Analysis.AllData.Photo_470.DFF(filterIndexPost,pre_samp:post_samp)';

dNames1 = fieldnames(d.hit);
dNames2 = {'hit' 'miss'};
%colors = colormap(lines(length(dNames)));
colors = colormap(lines(5));
for jj = 1:2
    figure;
    for ii = 1:length(dNames1)

        thisData = d.(dNames2{jj}).(dNames1{ii});
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
        if ~strcmp(filterType,'type_4')
            rh = rectangle('Position',[stim_time min(ci(:)) stim_duration abs(min(ci(:)))+max(ci(:))],...
                       'FaceColor',stimColor,'EdgeColor','none');
        end
        hold on;
        shadedErrorBar(xvec,dataAvg,[ci(2,:)-dataAvg;dataAvg-ci(1,:)],...
                        {'LineWidth',2,'Color',thisColor},1);


    end
    % figure grooming
    if ~strcmp(filterType,'type_4')
        uistack(rh,'bottom');
    end
    
    xlab = 'Time from reward [s]';
    ylab = 'DF/F [%]';
    xlim = [pre_time-0.1 post_time+0.1];
    formatFigure(gcf,gca,22,0,10,...
                   xlab,ylab,xlim,ylim,...
                   1,[1 1 1],0,0,1);
    title([dNames2{jj}])
end


%legend(dNames,'Location','NorthWest');
           
%fname = [type '_' pdfName];
%fPath = [DefaultParam.PathName DefaultParam.FileList(1:end-4) '_' fname];
%saveas(gcf,fPath);




