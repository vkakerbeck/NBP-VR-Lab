map = imread('map5.png'); 
map = imresize(map,[500 450]);
mapC = map;
lineLength = 50;
%Read in map and positions
suj_num = cell2mat(PartList(ii));
disp(suj_num);
file = 'HouseList.txt';
data = fopen(file);
data = textscan(data,'%s','delimiter', '\n');
data = data{1};
data = table2array(cell2table(data));
len = int64(length(data));
%format and sort the raw data
x = zeros(1,len);
y = zeros(1,len);