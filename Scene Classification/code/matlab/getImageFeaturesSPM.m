function [h] = getImageFeaturesSPM(layerNum, wordMap, dictionarySize)
% Compute histogram of visual words using SPM method
% Inputs:
%   layerNum: Number of layers (L+1)
%   wordMap: WordMap matrix of size (h, w)
%   dictionarySize: the number of visual words, dictionary size
% Output:
%   h: histogram of visual words of size {dictionarySize * (4^layerNum - 1)/3} (l1-normalized, ie. sum(h(:)) == 1)

% TODO Implement your code here

    hist0 = histogram(wordMap,dictionarySize);
    for i = 1:size(hist0.BinCounts,2)
        h0(1,i) = hist0.BinCounts(1,i);
    end
    
    [wmHeight, wmWidth] = size(wordMap);
    
    wmWidthMoreBy = mod(wmWidth,4);
    wmHeightMoreBy = mod(wmHeight,4);
    
    if wmWidthMoreBy > 0
        horzZero = zeros (wmHeight,(4 - wmWidthMoreBy));
        wordMapModWidth = horzcat(wordMap,horzZero);
    else
        wordMapModWidth = wordMap;
    end
    
    if wmHeightMoreBy > 0
        vertZero = zeros ((4 - wmHeightMoreBy),(size(wordMapModWidth, 2)));
        wordMapMod = vertcat(wordMapModWidth,vertZero);
    else
        wordMapMod = wordMapModWidth;
    end
        
    [wmHeight, wmWidth] = size(wordMapMod);
    
    hort1cell = mat2cell(wordMapMod, [(wmHeight/2) (wmHeight/2)], [(wmWidth/2) (wmWidth/2)]);
    h1 =[];
    for i = 1:2
        for j = 1:2
            h11 = hort1cell{i,j};
            hist1 = histogram(h11,dictionarySize);
            for k = 1:size(hist1.BinCounts,2)
                h1t(1,k) = hist1.BinCounts(1,k);
            end
            h1 = horzcat(h1,h1t);
        end
    end
    
    hort2cell = mat2cell(wordMapMod, [(wmHeight/4) (wmHeight/4) (wmHeight/4) (wmHeight/4)], [(wmWidth/4) (wmWidth/4) (wmWidth/4) (wmWidth/4)]);
    h2 =[];
    for i = 1:4
        for j = 1:4
            h21 = hort2cell{i,j};
            hist2 = histogram(h21,dictionarySize);
            for k = 1:size(hist2.BinCounts,2)
                h2t(1,k) = hist2.BinCounts(1,k);
            end
            h2 = horzcat(h2,h2t);
        end
    end

    h0 = h0/4;
    h1 = h1/4;
    h2 = h2/2;
    h01 = horzcat(h0,h1);
    h012 = horzcat(h01,h2);
    sum = 0;
    for i = 1:size(h012,2)
        sum = sum + h012(1,i);
    end
    
    for i = 1:size(h012,2)
        ht(1,i) = (h012(1,i)/sum);
    end
    
    h = transpose(ht);

end