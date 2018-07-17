
clear all; close all; clc;
%% Read in data
load 'D:/v.kakerbeck/Tracking/Data.mat';
Inst = imread ('D:/v.kakerbeck/Tracking/Instructions.png');
Output = struct();

suj_num = str2double(input('Enter subject number (1-50): ','s'));
if suj_num < 1 || suj_num > 50
    error('subject number invalid');
end
Img_Arr = randperm(50);
%% Initialize PTB
Screen('Preference', 'SkipSyncTests', 1);
[win winRect] = Screen('OpenWindow',0,1,[0 0 2560 1440]);

%% Instructions
white = WhiteIndex(win); % pixel value for white
Screen(win, 'FillRect', white);
Screen(win,'PutImage',Inst,[500 200 1800 800]);%[460 1100 1460 1800]
Screen('TextFont',win, 'Arial');
Screen('TextSize',win, 20);
DrawFormattedText(win, 'Weiter mit beliebiger Taste...',500,2000);
Screen(win,'Flip');
clear keycode;

while true
    [keyisdown,secs,keycode] = KbCheck;
    if(keyisdown ==1)
        break;
    end
end
WaitSecs(0.3);
clear keycode;

% white = WhiteIndex(win); % pixel value for white
% Screen(win, 'FillRect', white);
% Screen('TextFont',win, 'Arial');
% Screen('TextSize',win, 20);
% DrawFormattedText(win, 'Wenn du keine Fragen mehr hast kann es losgehen.',800,750);
% Screen('TextSize',win,20);
% DrawFormattedText(win, 'Los mit beliebiger Taste!',800,800);
% Screen(win,'Flip'); 
% while true
%     [keyisdown,secs,keycode] = KbCheck;
%     if(keyisdown ==1)
%         break;
%     end
% end  
% WaitSecs(0.3);
% clear keycode;

%% Main Loop
number = 0;
for trial = Img_Arr
    number = number +1;
    count = 1;
    
    img = Data{trial,1}.Data;
    
    Output.Trial(number,1).Image_Name = Data{trial,1}.Name;
    Output.Trial(number,1).Image_Nr = trial;
    
    
    while true
    Screen(win,'PutImage',img,[0 0 2560 1440]);%[183 1085 1736 2125]
    Screen('TextFont',win, 'Arial');
    Screen('TextSize',win, 40);
    DrawFormattedText(win,'How well can you remember the sight of this house? \n\n 1 = "Not at all"  2 = "Not really"  3 = "A little bit" \n\n 4 = "Good"  5 = "Very Good" ',20,50,[255 255 255]);
    
    [VBLTimestamp1 StimulusOnsetTime1 FlipTimestamp1 Missed1 Beampos1] = Screen('Flip', win);
    
       KbWait;
       [keyisdown,secs,keycode] = KbCheck;
       k = KbName(keycode);
       k=k(1);
       if(strcmp(k(1),'1')||strcmp(k(1),'2')||strcmp(k(1),'3')||strcmp(k(1),'4')||strcmp(k(1),'5'))%||k(1)==1||k(1)==2||k(1)==3||k(1)==4||k(1)==5)
           break;
       else
           Screen('TextFont',win, 'Arial');
           Screen('TextSize',win, 40);
           DrawFormattedText(win,'Bitte waehle eine Zahl zwischen 1 und 5','center',200,[0 0 0]);
           Screen('Flip', win);
           WaitSecs(1);
       end
    end
    Output.Trial(number,1).DecisionSight = str2num(k);
    WaitSecs(0.2);
    while true
    Screen(win,'PutImage',img,[0 0 2560 1440]);
    DrawFormattedText(win,'How confident are you that you could find back to this house?  \n\n 1 = "Definitely not"  2 = "Probably not"  3 = "Maybe I could" \n\n 4 = "Confident"  5 = "Very confident" ',20,50,[255 255 255]);
    
    [VBLTimestamp1 StimulusOnsetTime1 FlipTimestamp1 Missed1 Beampos1] = Screen('Flip', win);
       KbWait;
       [keyisdown,secs,keycode] = KbCheck;
       k = KbName(keycode);
       k=k(1);
       if(strcmp(k(1),'1')||strcmp(k(1),'2')||strcmp(k(1),'3')||strcmp(k(1),'4')||strcmp(k(1),'5'))%||k(1)==1||k(1)==2||k(1)==3||k(1)==4||k(1)==5)
           break;
       else
           Screen('TextFont',win, 'Arial');
           Screen('TextSize',win, 40);
           DrawFormattedText(win,'Bitte waehle eine Zahl zwischen 1 und 5','center',200,[0 0 0]);
           Screen('Flip', win);
           WaitSecs(1);
       end
    end
    Output.Trial(number,1).DecisionNav = str2num(k);
    WaitSecs(0.7);
end

%% Save
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Familiarity/','Fam_Houses_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Familiarity/','Fam_Houses_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'Output')
Screen('CloseAll')
sca
clear all
clc
