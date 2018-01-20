function [filterBank, dictionary] = getFilterBankAndDictionary(imPaths)
% Creates the filterBank and dictionary of visual words by clustering using kmeans.

% Inputs:
%   imPaths: Cell array of strings containing the full path to an image (or relative path wrt the working directory.
% Outputs:
%   filterBank: N filters created using createFilterBank()
%   dictionary: a dictionary of visual words from the filter responses using k-means.

    filterBank  = createFilterBank();
    alphaMatrixAll = [];
    alpha = 50; %set alpha between 50 and 200
    K = 100; %set K between 100 and 300

    %TODO Implement your code here
    %fetch training images
    for i = 1:size(imPaths,1)
        image_name = imPaths(i,1);
        img = imread(cell2mat(image_name));

        %find filterResponses for all the images
        filterResponses1 = extractFilterResponses(img, filterBank);
        filterRespMat = cat(3, filterResponses1{:});

        %for each image select 'alpha' random pixels and form a 2-D matrix out of it.
        [rowImg, colImg, ~] = size(img);
        randIndex = randperm(rowImg*colImg, alpha);
        [rowMat,colMat] = ind2sub([rowImg colImg],randIndex); %alpha number of random row and column co-ordinates
        alphaMatrix = zeros(alpha, size(filterRespMat,3));

        %forming the 2-D matrix
        for a = 1:alpha
           for channel = 1:size(filterRespMat,3)
              alphaMatrix(a, channel) = filterRespMat(rowMat(a), colMat(a), channel);
           end
        end
        alphaMatrixAll = [alphaMatrixAll; alphaMatrix]; 
    end
    [~, dictionary] = kmeans(alphaMatrixAll, K, 'EmptyAction','drop');

end
