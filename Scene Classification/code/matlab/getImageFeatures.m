function [h] = getImageFeatures(wordMap, dictionarySize)
% Compute histogram of visual words
% Inputs:
% 	wordMap: WordMap matrix of size (h, w)
% 	dictionarySize: the number of visual words, dictionary size
% Output:
%   h: vector of histogram of visual words of size dictionarySize (l1-normalized, ie. sum(h(:)) == 1)

	% TODO Implement your code here
	
    
    %extracts the histogram of visual words within the given image (i.e., the bag of visual words).

    histo = histogram(wordMap,dictionarySize);
    sum = 0;
    for i = 1:size(histo.BinCounts,2)
        sum = sum + histo.BinCounts(1,i);
    end
    
    for i = 1:size(histo.BinCounts,2)
        h(1,i) = (histo.BinCounts(1,i)/sum);
    end

	assert(numel(h) == dictionarySize);
    
end