%--------------------Entropy Over Houses in Interval-----------------------
PartList = {3755,6876};% {1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,18,19,20,21,22,24,25,26,28,29};
savepath = 'C:/Users/vivia/Dropbox/Project Seahaven/Tracking/ViewedHouses/';
IntervalLen = 2*30;%=2 seconds
%--------------------------------------------------------------------------
Number = length(PartList);
avgdist = cell(1,Number);
avgEs = cell(1,Number);
for ii = 1:Number
    suj_num = cell2mat(PartList(ii));
    file = strcat('ViewedHouses_VP',num2str(suj_num),'.txt');
    data = fopen(file);
    data = textscan(data,'%s','delimiter', '\n');
    data = data{1};
    data = table2array(cell2table(data));
    %initialize fields
    len = int64(length(data));
    houses = cell(1,len);
    distance = zeros(1,len);
    timestamps = zeros(1,len);
    for a = 1:double(len)
        line = textscan(data{a},'%s','delimiter', ',');line = line{1};
        l = char(line(1));
        if l(1:2) == 'NH'
            house = 0;%XX add distance
        else
            house = str2num(l(1:3));
        end
        houses{a} = house;
    end
    avgdist = mean(distance);
    clear data;
    entropy = cell(1,len-IntervalLen);
    for s = 1:len-IntervalLen
        h = hist(cell2mat(houses(s:s+IntervalLen)));
        p = h/sum(h);
        entropy{s} = -nansum(times(p,log2(p)));
    end
    plot(cell2mat(entropy))
    avgE = mean(cell2mat(entropy));
    avgEs{ii} = avgE;
    saveas(gcf,fullfile(savepath,['Results\Entropy_' num2str(IntervalLen) '_' num2str(suj_num) '.jpeg']));
end
save(fullfile(savepath,['Results\Entropy_' num2str(IntervalLen) '_' num2str(min([PartList{:}])) '-' num2str(max([PartList{:}])) '.mat']), 'avgE');
%clear all;