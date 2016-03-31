%Read the input image
Img=imread('images.jpg');
axes('Position',[0 .1 .74 .8],'xtick',[],'ytick',[]);
imshow(Img);title('Original Image');
I=rgb2gray(Img);     % Converting RGB Image to
                                % Gray Scale Image
I=im2double(I);      % Converting Gray scale Image
                                % to Double type

J = medfilt2(I,[3 3]); % Median Filter , 
                                  % 3x3 Convolution
                                  % on Image
I2 = imadjust(J);     % Improve to quality of Image
                                 % and adjusting
                                 % contrast and brightness values
Ib = I2> 0.9627;  
%Labelling
[Label,total] = bwlabel(Ib,4); % Indexing segments by
                                          % binary label function

            %Remove components that is small and tiny
for i=1:total
    if(sum(sum(Label==i)) < 500 )
        Label(Label==i)=0;
    end
end
%Find the properties of the image
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
C=imcrop(Img,box);

          %Find the centroid
cen=Sdata(ele).Centroid;


          %Display the image

axes('Position',[0 .1 .74 .8],'xtick',[],'ytick',[])
imshow(Img);
hold on
plot(cen(1,1),cen(1,2),'rx');%Mark the centroid
if(0)
Rad=(Sdata(ele).EquivDiameter)/2;
Rad=strcat('Radius of the Ball :',num2str(Rad));
     
Area=Sdata(ele).Area;
Area=strcat('Area of the ball:',num2str(Area));
       
Pmt=Sdata(ele).Perimeter;
Pmt=strcat('Perimeter of the ball:',num2str(Pmt));
       
Cen=Sdata(ele).Centroid;
Cent=strcat('Centroid:',num2str(Cen(1,1)),',',num2str(Cen(1,2)));
print ('-depsc',Cent);
end;
