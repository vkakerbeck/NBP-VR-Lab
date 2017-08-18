%Script to analyze House viewing data
%Input: .txt file with number of house looked at and timestamp
% log 10 time per second
data = fopen('viewedHouses.txt');
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
%initialize fields
len = int16(length(data)/3);
houses = cell(1,len);
time = cell(1,len); %time in string format
timet = cell(1,len); %time in time format
distance = cell(1,len);
startTime = datetime(data{2});
% put houses, time and distances in separate variables
for a = 1:double(len)
    houses{a} = data{a*3-2};
    time{a} = string(datetime(data{a*3-1})-startTime);
    timet{a} = datetime(data{a*3-1})-startTime;
    distance{a} = data{a*3};
end
clear data;
dataStruct = struct('houses',houses,'time',time,'distance',distance);
%% 
%Count the number of occurances of a house and write it in a table
[uniqueX, ~, J]=unique(houses); %uniqueX = which elements exist in houses, J = to which of the elements in uniqueX does the element in houses correspond 
occ = histc(J, 1:numel(uniqueX)); %histogram bincounts to count the # of occurances of each house
NumViews = table(uniqueX',occ);
%make timeline
housenumbers = cell(1,len);
for a = 1:len-1%convert data
   if houses{a}(1:2)=='NH'
       housenumbers{a} = NaN; 
   else
       housenumbers{a} = str2num(houses{a}(1:3));
   end
end
h = cell2mat(housenumbers);
%old timeline:
% t = timeseries (h,1:length(h));%create timeline -> plot(t)
% t.Name = 'Timeline - Houses looked at';
% t.TimeInfo.Units = 'seconds/32';
clear J;clear uniqueX;clear occ;clear a;clear h;
%% 
%make list of house blocks
list = {,};
first = 1;
last = 1;
label = 'NaN';
for e = 2:length(housenumbers)-1
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
%%
%Create timeline
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
%text(xlabels-(xlabels-1200), ylabels+0.5, labels, 'fontsize', 10); 
text(xlabels+5, ylabels+0.5, labels, 'fontsize', 10);
xlabel('Time (seconds/10)');
grid on
clear color; clear idx; clear labels; clear order; clear xlabels; clear ylabels; clear xpatches; clear ypatches;
%% Save
suj_num = str2double(input('Enter subject number (1-50): ','s'));
if suj_num < 1 || suj_num > 50
    error('subject number invalid');
end
if suj_num < 10
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Viewed Houses/','NumViews_','VP_',num2str(0),num2str(suj_num),'.mat');
else
    current_name = strcat('D:/v.kakerbeck/Tracking/VP_Data/Viewed Houses/','NumViews_','VP_',num2str(suj_num),'.mat');
end 
save(current_name,'NumViews')
clear all