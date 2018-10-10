% rename files from pupil .avi movies to have 3-digit numbers
% folderPath = where the .avi files are
% file_regexp = usually '*.avi' (all files to be worked on)
% assumes: '_number.avi' naming convention

function [] = renameFiles_pupil(folderPath, file_regexp)

cd(folderPath);
files = dir(file_regexp);

for ii = 1:length(files)

    % find number at end of file name
    f = files(ii).name;
    tmp = strfind(f,'_');
    startInd = tmp(end)+1;
    endInd = strfind(f,'.avi')-1;
    
    % convert number to 3 digits
    thisNumber = str2double(f(startInd:endInd));
    nn = sprintf('%03d', thisNumber);
    
    % create new file name
    newname = [f(1:startInd-1) nn '.avi'];
    
    % rename file if names are different
    if ~strcmp(newname, f)
        movefile(f, newname);
    end
end
    
    
    
    
