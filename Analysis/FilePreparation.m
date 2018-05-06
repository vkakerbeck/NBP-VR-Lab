%-----------------------Data Preparation-----------------------------------
%sort out all files which have been marked as faulty in the Google sheet
%--------------------------------------------------------------------------
%First double click on the csv file and click on import
dir = 'C:\Users\vivia\Dropbox\Project Seahaven\Tracking\';
for i=1:length(Subject)
    try
        if Discarded{i}=='yes'
            disp(Subject(i));
            movefile([dir 'Position\positions_VP' num2str(Subject(i)) '.txt'],[dir 'Position\Discard\positions_VP' num2str(Subject(i)) '.txt']);
            movefile([dir 'Position\Map_VP_' num2str(Subject(i)) '.mat'],[dir 'Position\Discard\Map_VP_' num2str(Subject(i)) '.mat']);
            movefile([dir 'Position\North_VP_' num2str(Subject(i)) '.mat'],[dir 'Position\Discard\North_VP_' num2str(Subject(i)) '.mat']);
            movefile([dir 'Position\Path_VP_' num2str(Subject(i)) '.mat'],[dir 'Position\Discard\Path_VP_' num2str(Subject(i)) '.mat']);
            movefile([dir 'EyesOnScreen\EyesOnScreen_VP' num2str(Subject(i)) '.txt'],[dir 'EyesOnScreen\Discard\EyesOnScreen_VP' num2str(Subject(i)) '.txt']);
            movefile([dir 'EyeBoxPos\EyeBoxPos_VP' num2str(Subject(i)) '.txt'],[dir 'EyeBoxPos\Discard\EyeBoxPos_VP' num2str(Subject(i)) '.txt']);
        end
    end
end