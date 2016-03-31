function background = IVRvideo(file_dir)

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

	SE = strel('disk', 5, 0);
          
        Im = im2double(background);

	imR = squeeze(Im(:,:,1));
	imG = squeeze(Im(:,:,2));
	imB = squeeze(Im(:,:,3));
    
	imRNorm = imR./(imR+imG+imB);
	imGNorm = imG./(imR+imG+imB);
	imBNorm = imB./(imR+imG+imB);

	normBack = cat(3, imRNorm, imGNorm, imBNorm);
	%Read remaining frames to look for objects
	%GOPR0002 - Objects start: 230, 495, 618, 820, 1063, 1261, 1432, 1548, 1704, 
	for k = 250 : size(filenames,1)
		       
		%Code for object highlighting
		frame = imread([file_dir filenames(k).name]);
		Im2 = im2double(frame);

		imRf = squeeze(Im2(:,:,1));
		imGf = squeeze(Im2(:,:,2));
		imBf = squeeze(Im2(:,:,3));
    
		imRNormf = imRf./(imRf+imGf+imBf);
		imGNormf = imGf./(imRf+imGf+imBf);
		imBNormf = imBf./(imRf+imGf+imBf);

		normFrame = cat(3, imRNormf, imGNormf, imBNormf);

		difference = imabsdiff(normBack, normFrame);
		difference = im2bw(difference, 0.035);
		difference = bwareaopen(difference,250);
		difference = imfill(difference, 'holes');
		
		object = bwmorph(difference, 'erode', 1);
		object = ~object;

                [Label,total] = bwlabel(object,4);
                
                stats=regionprops(bw,'CENTROID','Area','Perimeter');
                hold on
                if length(stats)>1
                    if ((([stats.Perimeter].^2) / (4 * pi * [stats.Area]))>0.8)
                if(0)
                Sdata = regionprops(Label,'all');
                Un=unique(Label);
                my_max=0.0;

                %Check the Roundness metrics
                %Roundness=4*PI*Area/Perimeter.^2
                for i=2:numel(Un)
                    Roundness=(4*pi*Sdata(Un(i)).Area)/Sdata(Un(i)).Perimeter.^2;
                    my_max=max(my_max,Roundness);
                    if(Roundness==my_max)
                       ele=Un(i);
                    end
                end
                %Draw the box around the ball
                box=Sdata(ele).BoundingBox;
                box(1,1:2)=box(1,1:2)-15;
                box(1,3:4)=box(1,3)+25;

                %Crop the image
                C=imcrop(object,box);

                %Find the centroid
                cen=Sdata(ele).Centroid;


                %Display the image

                axes('Position',[0 .1 .74 .8],'xtick',[],'ytick',[])
                imshow(object);
                hold on
                plot(cen(1,1),cen(1,2),'rx');%Mark the centroid
                end;

        if(0)
        se = strel('disk', 10, 4);
        %se = strel('ball', 5, 8, 0);
        imClean = imopen(difference,se);
        %% Fill the holes and clear border
        %imClean = imclose(imClean, se);
        %imClean = imfill(imClean,'holes');
        %imClean = imclearborder(imClean);
    
        figure(1);
        h1 = imshow(imClean);
        set(h1, 'CData', imClean); % replaces what h1 shows
        drawnow; % refreshes graphic objects
        disp(['showing frame ' num2str(k)]);
       	end;	
    
end


