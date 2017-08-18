%Script to analyze individual house viewing data
%Input: .txt file with number of house looked at and timestamp
% log 10 times per second
data = fopen('viewedHousesOffline.txt');
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
%initialize fields
len = int16(length(data)/2);
%variables for time stamps, not used in new version
%len = int16(length(data)/3);
%time = cell(1,len); %time in string format
%timet = cell(1,len); %time in time format
%startTime = datetime(data{2});
houses = cell(1,len);
distance = cell(1,len);
totaldist = 0;
count =0;
%--------------for old files with time info-------------------
% put houses, time and avgdistances in separate variables
% for a = 1:double(len)
%     houses{a} = data{a*3-2};
%     %time{a} = string(datetime(data{a*3-1})-startTime);
%     %timet{a} = datetime(data{a*3-1})-startTime;
%     distance{a} = data{a*3};
%     if distance{a}>0
%         totaldist = totaldist+str2num(distance{a});count = count+1;
%     end
% end
%--------------for new files without time stamp --------------
for a = 1:double(len)
    houses{a} = data{a*2-1};
    distance{a} = data{a*2};
    if distance{a}>0%calculate average distance from which a house is looked at
        totaldist = totaldist+str2num(distance{a});
        count = count+1;
    end
end
avgdist = totaldist/count;
clear data;clear a;clear count;clear totaldist;
%% Count the number of occurances of a house and write it in a table
[uniqueX, ~, J]=unique(houses); %uniqueX = which elements exist in houses, J = to which of the elements in uniqueX does the element in houses correspond 
occ = histc(J, 1:numel(uniqueX)); %histogram bincounts to count the # of occurances of each house
NumViews = table(uniqueX',occ); %Table saying how often which house was looked at. (1 count = 10th of a second)
%make timeline
housenumbers = cell(1,len);
for a = 1:len-1%convert data -> replace NH by NaN and convert numbers to strings
   if houses{a}(1:2)=='NH'
       housenumbers{a} = NaN; 
   else
       housenumbers{a} = str2num(houses{a}(1:3));
   end
end
clear a;
%% make list of house blocks -> this will be the time line
list = {,};
first = 1;
last = 1;
label = 'NaN';
for e = 2:length(housenumbers)-1%define first and last element of a block
    if not((isnan(housenumbers{e})&&isnan(housenumbers{e-1}))||housenumbers{e}== housenumbers{e-1})
        last = e-1;
        list{end+1,1}=houses{e-1};
        list{end,2}=[first,last];
        first = e;
    end
end
list{end+1,1}=houses{e-1};
list{end,2}=[first,length(housenumbers)-1];
clear e; clear first; clear last;
%%Create timeline
%make sure the list is ordered in reverse chronological order (to help identify the last label of a row)
[~, order] = sortrows(vertcat(list{:, 2}), [-1 2]);
list = list(order, :);
%identify unique label and generate vertical positioning
[labels, idx, ylabels] = unique(list(:, 1), 'stable');
ypatches = max(ylabels) + 1 - [ylabels, ylabels, ylabels-1, ylabels-1]'; 
ylabels = max(ylabels) + 1 - ylabels(idx);
%generate horizonal positioning
xpatches = [vertcat(list{:, 2}), fliplr(vertcat(list{:, 2}))]';
xlabels = xpatches(2, idx);
%plot
figure;
color = parula(size(list, 1)); %color distribution
patch(xpatches, ypatches, reshape(color, 1, [], 3)); 
text(xlabels+5, ylabels+0.5, labels, 'fontsize', 10);
xlabel('Time (seconds/10)');
grid on
clear color; clear idx; clear labels; clear order; clear xlabels; clear ylabels; clear xpatches; clear ypatches;clear list;clear label;clear housenumbers;clear houses;
%% Distance analysis: adds column to NumViews table with average distance from which a house was viewed.
lenHouses = length(uniqueX);
avgdistances = cell(lenHouses,2);
avgdistances(1:lenHouses) = uniqueX;
ix=cellfun('isempty',avgdistances);
avgdistances(ix)={0};
for a = 1:len
    houseN = J(a);
    avgdistances{houseN,2}=avgdistances{houseN,2}+str2num(distance{a});
end
for a = 1:lenHouses
    avgdistances{a,2}=avgdistances{a,2}/occ(a);
end
NumViews = [NumViews avgdistances];
NumViews(:,[3])=[]; 
clear uniqueX;clear occ;clear J;clear a;clear ix;clear lenHouses;clear houseN;clear avgdistances;clear distance;clear len;
%% recover houses
% data = fopen('recoverHouses.txt');
% data = textscan(data,'%s','delimiter', '\n');
% data = data{1};
% data = table2array(cell2table(data));
% [uniqueX, ~, J]=unique(data); %uniqueX = which elements exist in houses, J = to which of the elements in uniqueX does the element in houses correspond 
% occ = histc(J, 1:numel(uniqueX)); %histogram bincounts to count the # of occurances of each house
% NumViews2 = table(uniqueX,occ);
% len=size(NumViews2,1);
% for h=1:len
%     found=false;
%     for e=1:size(NumViews)
%         if strcmp((NumViews2.uniqueX(h)),NumViews.Var1(e))
%             NumViews.occ(e)=NumViews.occ(e)+NumViews2.occ(h);
%             found = true;
%         end
%     end
%     if found==false
%         NumViews=[NumViews;{NumViews2.uniqueX(h) NumViews2.occ(h)}];
%     end
% end
%% Save
suj_num = str2double(input('Enter subject number (1-50): ','s'));
if suj_num < 1 || suj_num > 50
    error('subject number invalid');
end
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Viewed Houses/','NumViewsD_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Viewed Houses/','NumViewsD_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'NumViews')