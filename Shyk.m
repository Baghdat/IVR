function background = Shyk(file_dir)
% file_dir = 'GOPR0002/';

% Collection of frames
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1); h1 = imshow(frame);

% Read first 25 frames to obtain background.
for k = 1 : 25
    frame = imread([file_dir filenames(k).name]);
    set(h1, 'CData', frame); % replaces what h1 shows
    drawnow('expose'); % refreshes graphic objects
    disp(['showing frame ' num2str(k)]); % gives command-line argument

    % get each colour channel of current immage
    imR = (squeeze(frame(:,:,1)));
    imG = (squeeze(frame(:,:,2)));
    imB = (squeeze(frame(:,:,3)));
end    
    

% Put them back together to get average background
background = cat(3,imR,imG,imB);
disp(['calculated background']); % gives command-line argument

   
% Read remaining frames to look for objects
for k = 26 : size(filenames,1)
    
    frame = imread([file_dir filenames(k).name]);
    robots = imabsdiff(frame, background);
        % imshow(robots)
    robots = (255-robots);
       
    Im = im2double(robots);
    [r, c, p] = size(Im);
        %% Extract individual planes from RGB Image
    imR = squeeze(Im(:,:,1));
    imG = squeeze(Im(:,:,2));
    imB = squeeze(Im(:,:,3));
        %% Thresholding on individual planes
    imBinaryR = im2bw(imR,graythresh(imR));
    imBinaryG = im2bw(imG,graythresh(imG));
    imBinaryB = im2bw(imB,graythresh(imB));
    imBinary = imcomplement (imBinaryR&imBinaryG&imBinaryB);
    
    %figure(1);
    %h1 = imshow(imBinary);
    %set(h1, 'CData', imBinary); % replaces what h1 shows
    %drawnow; % refreshes graphic objects
    %disp(['showing frame ' num2str(k)]);

    %imshow(imBinaryB);
    
    se = strel('disk', 15, 8);
    %se = strel('ball', 5, 8, 0);
    imClean = imopen(imBinary,se);
    %% Fill the holes and clear border
    imClean = imfill(imClean,'holes');
    imClean = imclearborder(imClean);
    
    figure(1);
    h1 = imshow(imClean);
    set(h1, 'CData', imClean); % replaces what h1 shows
    drawnow; % refreshes graphic objects
    disp(['showing frame ' num2str(k)]);
    % imshow(imClean);
    %% Segmented gray-level image

    if(0)
    [labels, numLabels] = bwlabel(imClean);
    disp(['Number of objects detected: ' num2str(numLabels)]);
    end;
end;

