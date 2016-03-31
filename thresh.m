function [output] = thresh(pic)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Comment

%pic = myjpgload('img.jpg',1);
[m,n] = size(pic);
vec = reshape(pic,1,m*n); 
first_hist = dohist(pic,1);
filter = fspecial('gaussian', [50 1], 6);
smooth_hist = conv(filter,first_hist);
[k, l] = size(smooth_hist);
max=0;
for i = 1:k
	if smooth_hist(i,1) > max
		max = smooth(i,1);
	end
end

plot(smooth_hist);

for row = 1 : m
	for col = 1 : n
		if (pic(row,col) > 112) %%& pic(row,col) > (max - 50)
			output(row,col) = 1;
		else
			output(row,col) = 0;
		end
	end
end

imshow(output);


end

