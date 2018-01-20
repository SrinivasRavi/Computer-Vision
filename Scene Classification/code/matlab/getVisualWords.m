function [wordMap] = getVisualWords(img, filterBank, dictionary)
% Compute visual words mapping for the given image using the dictionary of visual words.

% Inputs:
% 	img: Input RGB image of dimension (h, w, 3)
% 	filterBank: a cell array of N filters
% Output:
%   wordMap: WordMap matrix of same size as the input image (h, w)

% TODO Implement your code here

%calculate the filter responses for the image
filterResponses = extractFilterResponses (img, filterBank);
filterRespMat = cat(3, filterResponses{:});


%for all the 60 channels for an image's filter responses for every pixel,
%compare the value with the corresponding channel in K clusters. The
%cluster with minimum distance from the pixel will be the word for that
%pixel.

    for i = 1:size(filterRespMat,1)
        for j = 1:size(filterRespMat,2)
            %Builds a vector that stores all the values of a pixel across the channels
            for k = 1:size(filterRespMat,3)
                vect(1,k) = filterRespMat(i,j,k);
            end

            %Finds the minimum distance between the channels and the dictionary
            [dist, I] = pdist2(dictionary, vect,'euclidean','Smallest',1);
            wordMap(i, j) = I;
        end
    end

end
