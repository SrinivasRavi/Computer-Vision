function histInter = distanceToSet(wordHist, histograms)
% Compute distance between a histogram of visual words with all training image histograms.
% Inputs:
% 	wordHist: visual word histogram - K * (4^(L+1) − 1 / 3) × 1 vector
% 	histograms: matrix containing T features from T training images - K * (4^(L+1) − 1 / 3) × T matrix
% Output:
% 	histInter: histogram intersection similarity between wordHist and each training sample as a 1 × T vector

	% TODO Implement your code here
    
    %bsxfun(@min, histograms, wordHist) returns a matrix with minimum
    %values of histograms and wordHist. sum(output,1) fetches a vector with
    %column-wise summation
    
    histInter = sum(bsxfun(@min,histograms,wordHist),1);
end