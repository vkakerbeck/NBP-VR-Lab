%Pupil Labs Data Analysis
%Name the pupil folder after your subject number. With pupil Player export
%the data as a csv file. What you do with it then is up to you, this is
%just a rough template.
suj_num = input('Enter subject number (1-50): ','s');
file = strcat('D:\v.kakerbeck\Tracking\PupilRecording\',num2str(suj_num),'\exports\pupil_postions.csv');
data = fopen(file);
A = textscan(data,'%s','Delimiter','\n');A=A{1};
A = split(A,',');
A=A(1:end,1:7);%remove irrelevant data
eyedet=str2double(A(:,4));
xpos=str2double(A(eyedet>0.5,5));%xpos=xpos(xpos<=1);
ypos=str2double(A(eyedet>0.5,6));%ypos=ypos(ypos<=1);
id=str2double(A(eyedet>0.5,3));
scatter(xpos,ypos,3,id)
file2 = strcat('D:\v.kakerbeck\Tracking\PupilRecording\',num2str(suj_num),'\exports\gaze_postions.csv');
data2 = fopen(file2);
B = textscan(data2,'%s','Delimiter','\n');B=B{1};
B = split(B,',');
B=B(1:end,1:5);
gazedet=str2double(B(:,4));
gazex=str2double(B(gazedet>0.5,4));%xpos=xpos(xpos<=1);
gazey=str2double(B(gazedet>0.5,5));%ypos=ypos(ypos<=1);
index = str2double(B(gazedet>0.5,2));
scatter(gazex,gazey,3,index);