function background = Test(filedir)
% file_dir = 'GOPR0002/';
close all; clear all; clc;

    % Collection of frames
%filenames = dir([file_dir '*.jpg']);

%frame1 = imread([file_dir filenames(1).name]);
%figure(1); h1 = imshow(frame1);

  
     
close all; clear all; clc;
     
SF = 200;
EF = 628;
     
Xcent = [];
Ycent = [];
     
SE = strel('disk', 5, 0);
%avi = avifile('a_m.avi');
f=figure('visible','off');

% Put them back together to get average background

% Read remaining frames to look for objects
for k = 26 : 300
    %frame = imread([file_dir filenames(k).name]);
    %background = imread([file_dir filenames(k+1).name]);
    pos1 = imread(['frame0', sprintf('%2.4d',k), '.jpg']);
    pos2 = imread(['frame0', sprintf('%2.4d',k+1), '.jpg']);
    % Computes difference between background & image
    cla;
       
    %diff = abs(background - frame);
    diff = abs(pos1 - pos2);
    Igray = rgb2gray(diff);
    Ithresh = Igray > 10;
    BW = imopen(Ithresh, SE);
    [labels,number] = bwlabel(BW, 8);
    Istats = regionprops(labels, 'basic', 'Centroid');
    [maxVal, maxIndex] = max([Istats.Area]);
    Xcent = [ Xcent Istats(maxIndex).Centroid(1) ];
    Ycent = [ Ycent Istats(maxIndex).Centroid(2) ];
    imshow(pos2);
    hold on;
    line(Xcent, Ycent, 'color', 'green', 'LineWidth', 2);
    %avi = addframe(avi, f);
end
    
end