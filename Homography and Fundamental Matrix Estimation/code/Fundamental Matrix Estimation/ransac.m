function [ bestFitModel, inlierIndices ] = ransac(matches)
%RANSAC_F Summary of this function goes here
%   Detailed explanation goes here

    k = 2000; %%the number of iterations to run
    n = 4;   %%number of matches to use each iteration
    t = 10;   %the maximum distance for an inlier
    d = 0.2; %the minimum acceptable threshold
    
    [numMatches, ~] = size(matches);
    numInliersEachIteration = zeros(k,1);
    storedModels = {};%zeros(k,3,3);
    
    for i = 1 : k
        %display(['Running ransac Iteration: ', num2str(i)]);
        
        %select a random subset of points
        subsetIndices = randsample(numMatches, n);
        matches_subset = matches(subsetIndices, :);
            
        %fit a model to that subset
        model = fit_fundamental_normalized(matches_subset);
        
        %compute inliers, ie: find all remaining points that are 
        %"close" to the model and reject the rest as outliers
        residualErrors = calc_residuals(model, matches);
        
        %display(['Mean Residual Error: ', num2str(mean(residualErrors))]);
        inlierIndices = find(residualErrors < t);      

        %record the number of inliers
        numInliersEachIteration(i) = length(inlierIndices);
        
        %keep track of any models that generated an acceptable numbers of 
        %inliers. This collection can be parsed later to find the best fit
        currentInlierRatio = numInliersEachIteration(i)/numMatches;
        if currentInlierRatio >=  d
        %if numInliersEachIteration(i) >= max(numInliersEachIteration)
            %re-fit the model using all of the inliers and store it
            matches_inliers = matches(inlierIndices, :);
            storedModels{i} = fit_fundamental_normalized(matches_inliers);
        end
    end
    %display(storedModels);
    %display(numInliersEachIteration);
    
    %retrieve the model with the best fit (highest number of inliers)
    bestIteration = find(numInliersEachIteration == max(numInliersEachIteration));
    bestIteration = bestIteration(1); %incase there was more than 1 with same value
    bestFitModel = storedModels{bestIteration};
    
    %recalculate the inlier indices for all points, this was done once before 
    %when calculting this model, but it wasn't stored for space reasons. 
    %Recalculate it now so that it can be returned to the caller
    residualErrors = calc_residuals(bestFitModel, matches);
    inlierIndices = find(residualErrors < t);
end

