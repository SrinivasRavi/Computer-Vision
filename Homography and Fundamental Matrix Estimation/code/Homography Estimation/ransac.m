function [ best_fit_model, inlier_index , max_inlier_count, avg_residual] = ransac(match_putative_img1,match_putative_img2,r_1,c_1,r_2,c_2 )

    k = 2000; %the number of iterations to run
    n = 4;   %number of matches to use each iteration
    t = 10;   %the maximum distance for an inlier
    d = 0.2; %the minimum acceptable threshold
    r1_cood = r_1(match_putative_img1,1);
    c1_cood = c_1(match_putative_img1,1);
    r2_cood = r_2(match_putative_img2,1);
    c2_cood = c_2(match_putative_img2,1);
    putative_no=size(match_putative_img1,1);
    left_img = [c1_cood, r1_cood, ones(putative_no,1)];
    right_img = [c2_cood, r2_cood, ones(putative_no,1)];

    inliner_count = zeros(k,1);
    maybe_model = {};%zeros(k,3,3);
    best_fit_model_till_now = {};

    max_inlier_count = 0;
    iteration=1;
    while iteration<k

        %select a random subset of points
        subsetIndices = randsample(putative_no, n);
        left_img_subset = left_img(subsetIndices, :);
        right_img_subset = right_img(subsetIndices, :);

        %fit a model to that subset
        model = fit_homography(left_img_subset, right_img_subset);

        %calculate residualerrors
        [residual_errors, ~] = calc_residuals(model, left_img, right_img);

        %calculate inlier_index
        inlier_index = find(residual_errors < t);

        %record the number of inliers
        inliner_count(iteration) = length(inlier_index);

        %keep the acceptable inliners
        currentInlierRatio = inliner_count(iteration)/putative_no;

        if (max_inlier_count < inliner_count(iteration))
            max_inlier_count = inliner_count(iteration);
            left_img_inliers = left_img(inlier_index, :);
            right_img_inliers = right_img(inlier_index, :);
            best_fit_model_till_now = fit_homography(left_img_inliers, right_img_inliers);
        end

        iteration=iteration+1;
    end

    %retrieve the model with the best fit (highest number of inliers)
    % best_inliners = find(inliner_count == max(inliner_count));
    % best_inliners = best_inliners(1);
    % best_fit_model = maybe_model{best_inliners};

    best_fit_model = best_fit_model_till_now;

    %recalculate the inlier indices for all points
    [residual_errors, avg_residual] = calc_residuals(best_fit_model, left_img, right_img);
    inlier_index = find(residual_errors < t);

end

function [residuals,avg_residual] = calc_residuals(model, left_img, right_subset)

    %transform the points from img 1 by multiplying the homo coord by H
    transformedPoints = left_img * model;

    lambda_t =  transformedPoints(:,3); %scale factor
    lambda_2 = right_subset(:,3);    %scale factor
    cartDistX = transformedPoints(:,1) ./ lambda_t - right_subset(:,1) ./ lambda_2;
    cartDistY = transformedPoints(:,2) ./ lambda_t - right_subset(:,2) ./ lambda_2;
    residuals = cartDistX .* cartDistX + cartDistY .* cartDistY;
    avg_residual = mean2(residuals);

end

function model = fit_homography(img1_subset, img2_subset)

       n = size(img1_subset,1); 
        %create the A matrix
        A = []; 
        for i = 1:n
            %assume homogenous versions of all the feature points
            i1 = img1_subset(i,:);
            i2 = img2_subset(i,:);

            % 2x9 matrix to append onto A. 
            A_new = [ zeros(1,3)  ,   -i1     ,   i2(2)*i1;
                        i1      , zeros(1,3),   -i2(1)*i1];
            A = [A; A_new];        
        end

        %solve for A*h = 0
        [~,~,eigenVecs] = svd(A); % Eigenvectors of transpose(A)*A
        h = eigenVecs(:,9);     % Vector corresponding to smallest eigenvalue 
        model = reshape(h, 3, 3);   % Reshape into 3x3 matrix
        model = model ./ model(3,3);        % Divide through by H(3,3)

end
