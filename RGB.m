function [imR, imG, imB] = RGB (image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Im = im2double(image);
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
        imshow(imBinaryB);

end

