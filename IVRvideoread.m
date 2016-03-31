function background = IVRvideoread(file_dir)

	filenames = dir([file_dir '*.jpg']);

	frame = imread([file_dir filenames(1).name]);
	figure(1); h1 = imshow(frame);

	% Read first 25 frames to obtain background.
	for k = 1 : 25
		X(:,:,:,k) = imread([file_dir filenames(k).name]);
		figure(1);
		imshow(X(:,:,:,k));
		h1 = imshow(X(:,:,:,k));
		disp(['showing frame ' num2str(k)]);
	end

	background = median(X,4);

	Xcent = [];
	Ycent = [];

	SE = strel('disk', 5, 8);

    
    Im = im2double(background);

	imR = squeeze(Im(:,:,1));
	imG = squeeze(Im(:,:,2));
	imB = squeeze(Im(:,:,3));
    
	imRNorm = imR./(imR+imG+imB);
	imGNorm = imG./(imR+imG+imB);
	imBNorm = imB./(imR+imG+imB);

	normBack = cat(3, imRNorm, imGNorm, imBNorm);
    
    flag = 2;
    
    starX = 0;
    starY = 0;
    
	%Read remaining frames to look for objects
	%GOPR0002 - Objects start: 230, 495, 618, 820, 1063, 1261, 1432, 1548, 1704, 
	for k = 900 : size(filenames,1)
		isHighestPoint = false;

		%Code for path detection
		frame_1 = imread([file_dir filenames(k-4).name]);
		frame = imread([file_dir filenames(k).name]);
		consecutive_difference = abs(frame_1 - frame);
		Igray = rgb2gray(consecutive_difference);
		Ithresh = Igray > 3;
		BW = imopen(Ithresh, SE);
		[labels,number] = bwlabel(BW, 4);
		Istats = regionprops(labels, 'basic', 'Centroid');
		[maxVal, maxIndex] = max([Istats.Area]);
		Xcent = [ Xcent Istats(maxIndex).Centroid(1) ];
		Ycent = [ Ycent Istats(maxIndex).Centroid(2) ];
		if (size(Ycent,2))
			disp(['Y coordinate: ' num2str(Ycent(size(Ycent,2)))]);
		end


		%Code for object highlighting
		
		Im = im2double(frame);

		imR = squeeze(Im(:,:,1));
		imG = squeeze(Im(:,:,2));
		imB = squeeze(Im(:,:,3));
    
		imRNorm = imR./(imR+imG+imB);
		imGNorm = imG./(imR+imG+imB);
		imBNorm = imB./(imR+imG+imB);

		normFrame = cat(3, imRNorm, imGNorm, imBNorm);

		difference = imabsdiff(normBack, normFrame);
		difference = im2bw(difference, 0.035);
		difference = bwareaopen(difference,250);
		difference = imfill(difference, 'holes');

		object = bwmorph(difference, 'erode', 1);
		object = ~object;

		labeled = bwlabel(object, 4);

		edges = edge(labeled);
		edges2 = cat(3,zeros(size(edges, 1), size(edges, 2)), edges, zeros(size(edges, 1), size(edges, 2)));
		detectedObj = frame;
        
		for i = 1 : size(edges2,1)
			for j = 1 : size(edges2,2)
				if (edges2(i,j,2) ~= 0)
					detectedObj(i,j,1) = 0;
					detectedObj(i,j,2) = 255;
					detectedObj(i,j,3) = 0;
			    	end
			end
        end

		%Code for highest point detection

        i = size(Ycent,2);
        if (i >= 4)
            if (Ycent(i) - Ycent(i-1) <= 1.7 && Ycent(i-1) - Ycent(i-2) <= 1.7 && Ycent(i-2) - Ycent(i-3) <= 1.7)
                isHighestPoint = true;
            end
        end
        
        
        

       %Code for Ball Detection
       [labeledImage numberOfObjects] = bwlabel(~object); %%%
       blobMeasurements = regionprops(labeledImage,...
	'Perimeter', 'Area', 'FilledArea', 'Solidity', 'Centroid'); 
       boundaries = bwboundaries(~object);% just for fun %%%
       perimeters = [blobMeasurements.Perimeter];
       areas = [blobMeasurements.Area];
       filledAreas = [blobMeasurements.FilledArea];
       solidities = [blobMeasurements.Solidity];
       % Calculate circularities:
       circularities = perimeters .^2 ./ (4 * pi * filledAreas);
       % Print to command window.
       fprintf('#, Perimeter,        Area, Filled Area, Solidity, Circularity\n');
       for blobNumber = 1 : numberOfObjects
            fprintf('%d, %9.3f, %11.3f, %11.3f, %8.3f, %11.3f\n', ...
            blobNumber, perimeters(blobNumber), areas(blobNumber), ...
            filledAreas(blobNumber), solidities(blobNumber), circularities(blobNumber));
       end
       
       for blobNumber = 1 : numberOfObjects
            % Outline the object so the user can see it.
            thisBoundary = boundaries{blobNumber};
            hold on;
            % Display prior boundaries in blue
            for l = 1 : blobNumber-1
                thisBoundary = boundaries{l};
                plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 3);
            end
            % Display this bounary in red.
            thisBoundary = boundaries{blobNumber};
            plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 3);

            % Determine the shape.
            if (circularities(blobNumber) < 1.2 && circularities(blobNumber) > 0.3)
                message = sprintf('The circularity of object #%d is %.3f,\nso the object is a ball',...
                    blobNumber, circularities(blobNumber));
                shape = 'circle';
            elseif circularities(blobNumber) < 1.6
                message = sprintf('The circularity of object #%d is %.3f,\nso the object is a square',...
                    blobNumber, circularities(blobNumber));
                shape = 'square';
            elseif circularities(blobNumber) > 1.6 && circularities(blobNumber) < 1.8
                message = sprintf('The circularity of object #%d is %.3f,\nso the object is an isocoles triangle',...
                    blobNumber, circularities(blobNumber));
                shape = 'triangle';
            else
                message = sprintf('The circularity of object #%d is %.3f,\nso the object is something else.',...
                    blobNumber, circularities(blobNumber));
                shape = 'something else';
            end
            % Display in overlay above the object
            overlayMessage = sprintf('Object #%d = %s\ncirc = %.2f, s = %.2f', ...
                blobNumber, shape, circularities(blobNumber), solidities(blobNumber));
            text(blobMeasurements(blobNumber).Centroid(1), blobMeasurements(blobNumber).Centroid(2), ...
                overlayMessage, 'Color', 'r');
                pause(0.1);
            %button = questdlg(message, 'Continue', 'Continue', 'Cancel', 'Continue');
            %if strcmp(button, 'tats(maxIndex).Centroid(1),2) ~= 0) ||Cancel')
            %    break;
            %end
       end

       
       
       
        
		%Code for displaying
		h1 = imshow(detectedObj);
		set(h1, 'CData', detectedObj);
		hold on;
		line(Xcent, Ycent, 'color', 'green', 'LineWidth', 2);
        if (isHighestPoint)
            bla = size(Istats(maxIndex).Centroid(1),2);
            bli = size(Istats(maxIndex).BoundingBox(2),2);
            if(bla > 0)
                plot(Istats(maxIndex).Centroid(1), Istats(maxIndex).BoundingBox(2), '-+b');
                pause(0.01);
                flag = 1;
            end
        else if(flag == 1)
            starX = Istats(maxIndex).Centroid(1);
            starY = Istats(maxIndex).BoundingBox(2);
            %plot(Istats(maxIndex).Centroid(1), Istats(maxIndex).BoundingBox(2), '-pc');
			pause(1);
            flag = 0;
            end
        end
        
        if(starX && starY)
            plot(starX, starY, '-pc');
        end
            
        drawnow;
		disp(['tracking obj in frame ' num2str(k)]);
        end
end