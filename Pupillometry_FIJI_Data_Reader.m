function Pupillometry=Pupillometry_FIJI_Data_Reader()
%% Directories
FoldDir=uigetdir();
PupilDir=[FoldDir filesep 'Pupil_Analysis' filesep];
BlinkDir=[FoldDir filesep 'Pupil_Intensity' filesep];
cd(PupilDir)
ListOfPupil=dir('*.txt');
cd(BlinkDir)
ListOfBlink=dir('*.txt');
if size(ListOfPupil,1)~=size(ListOfBlink,1)
    disp('mismatch between folder sizes');
    return;
end
%% Parameters
nTrials=size(ListOfPupil,1);
framerate=20;
maxTime=15.1;
filenames=cell(nTrials,1);
%% Blinking
cd(BlinkDir)
Blink=zeros(framerate*maxTime,nTrials);
nbOfFrames=zeros(1,nTrials);
for thisTrial=1:nTrials
    thisfile=ListOfBlink(thisTrial);
    filenames{thisTrial}=thisfile.name(1:end-14);
    thisTable=readtable(thisfile.name);
    thisIntensity=thisTable.Mean1;
    thisSTD=thisTable.StdDev1;
    thisIntT=mean(thisIntensity)+6*std(thisIntensity);
    thisSTDT=mean(thisSTD)+6*std(thisSTD);
	Blink((thisIntensity>thisIntT & thisSTD>thisSTDT),thisTrial)=1;
    nbOfFrames(thisTrial)=length(thisIntensity);
end
nFrames=max(nbOfFrames);
Blink=Blink(1:nFrames,:);
%% Pupil extraction
cd(PupilDir)
Time=1/framerate:1/framerate:nFrames*1/framerate;
Pupil=NaN(nFrames,nTrials);
cd(PupilDir);
for thisTrial=1:nTrials
    thisfile=ListOfPupil(thisTrial);
    thisTable=readtable(thisfile.name);
    thisPupil=thisTable.Major;
    thisSlice=thisTable.Slice;
    RepIndex=[];
% remove frame with more than one ROI detected % Could think to implement
% an x,y check to detect which one was the pupil
    for i=1:size(thisSlice,1)-1
        if thisSlice(i)==thisSlice(i+1)
            RepIndex=[RepIndex i i+1];
        end
    end
    thisSlice(RepIndex)=[];
    thisPupil(RepIndex)=[];
% add to final matrix    
    Pupil(thisSlice,thisTrial)=thisPupil;
end
% Smoothing
PupilSmooth=fillmissing(Pupil,'nearest','EndValues','none');
PupilSmooth=smoothdata(PupilSmooth,'gaussian',4);

%% Quality control Table
QC(1,:)=nbOfFrames;
QC(2,:)=sum(isnan(Pupil(1:nbOfFrames,:)),1);
QC(3,:)=QC(2,:)./nbOfFrames;
QC(4,QC(3,:)>0.2)=1;
QC(5,sum(Blink,1)>=1)=1;
QC(6:8,:)=NaN;
QC(6,1)=sum(QC(4,:));
QC(7,1)=QC(6,1)/nTrials;
QC(8,1)=sum(QC(5,:));
QCTable=table(QC);
QCTable.Properties.RowNames={'Frames','Non Analzyed Frames','Ratio','Discard Trial','Blink',...
                                'TotalDiscardTrials','RatioTotalDiscardTrials','TotalBlink'};
%%QCTable.Properties.VariableNames=filenames;
if QC(7,1)>0.05
    disp('#### MORE THAN 5% of the Trials DO NOT PASS THE QC ####'); 
end
%% Data to return
Name=filenames{1};
USindex=strfind(Name,'_');
Pupillometry.Parameters.Name=Name(1:USindex(1)-1);
Pupillometry.Parameters.Date=Name(USindex(1)+1:USindex(2)-1);
Pupillometry.Parameters.nTrials=nTrials;
Pupillometry.Parameters.nFrames=nFrames;
Pupillometry.Parameters.frameRate=framerate;
Pupillometry.Data.FileNames=filenames;
Pupillometry.Data.Time=Time;
Pupillometry.Data.Blink=Blink;
Pupillometry.Data.Pupil=Pupil;
Pupillometry.Data.PupilSmooth=PupilSmooth;
Pupillometry.QualityControl=QCTable;
%% Save
cd(FoldDir)
FileName=Name(1:USindex(2)-1);
save(FileName,'Pupillometry');
end