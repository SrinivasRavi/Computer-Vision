function [filterResponses] = extractFilterResponses(img, filterBank)
% Extract filter responses for the given image.
% Inputs: 
%   img:                a 3-channel RGB image with width W and height H
%   filterBank:         a cell array of N filters
% Outputs:
%   filterResponses:    a W x H x N*3 matrix of filter responses


% TODO Implement your code here

    if size(img,3)==1%Check if the image has only 1 channel (Grayscale)
        img = repmat(img, [1 1 3]);%If yes, return image with 3 channels.
    end

    image = RGB2Lab(img);% or you can use the matlab default function : %rgb2lab(img1); %related info in rgb. 
    %Luminosity a and b are two different ends of color spectrum

    %Create filterResponse cell array holding all the responses from the
    %convolution
    filterResponses = cell(numel(filterBank),1); 

    %Perform convolution in a loop against all the filters.
    for i = 1:numel(filterBank)
        H = filterBank{i};
        filterResponses{i} = imfilter(image,H,'conv');   
    end

end
