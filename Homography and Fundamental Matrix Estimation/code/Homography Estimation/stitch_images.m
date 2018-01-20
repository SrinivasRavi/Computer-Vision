% STITCH_IMAGES - Returns a stitched image of the two given images
% 
% Usage: [opimg] = stitch2images( ipimg1, ipimg2 ) 
%or
% imtool(stitch_images('../../data/part1/uttower/left.jpg','../../data/part1/uttower/right.jpg'))
% 
%Arguments:
%         ipimg1 - left image ipimg2 - right image
%         
% Returns:
%         opimg  - stitched output image
% 
% Author: Srinivas Ravi
% 
% November 2017
        
function [ opimg ] = stitch_images( ipimg1, ipimg2 )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. CONVERT IMAGES TO DOUBLE AND GRAYSCALE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img1_org = imread(ipimg1);
    img2_org = imread(ipimg2);
    img1 = im2double(img1_org);
    img2 = im2double(img2_org);
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2. DETECT FEATURE POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set parameters for harris corner detector
    sigma = 3;
    thresh = 0.05;
    radius = 3;
    disp = 1;
    
    %Detect feature points in both images using the Harris corner detector
    %code harris.m provided Usage: [cim, r, c] = harris(im, sigma, thresh,
    %radius, disp)
    [~, r_1, c_1] = harris(img1, sigma, thresh, radius, disp);
    [~, r_2, c_2] = harris(img2, sigma, thresh, radius, disp);
    %cim_1 - binary img1 marking corners r_1, c_1 - row and column
    %coordinates of corner points respectively of img1 cim_2 - binary img1
    %marking corners r_2, c_2 - row and column coordinates of corner points
    %respectively of img1
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3. FORM DESCRIPTORS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    neighborhood_depth=3;
    %experiment with different depth shows depth of 3 or 4 gives proper
    %result.
    descriptors_1 = extract_neighborhood(img1, r_1, c_1, neighborhood_depth);
    descriptors_2 = extract_neighborhood(img2, r_2, c_2, neighborhood_depth);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 4. FIND DISTANCES BETWEEN DESCRIPTORS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %descriptors points are re-written in terms of number of standard
    %deviations from the mean using zscore. This normalizes the descriptors
    %to use mean 0 and unit standard deviation.
    descriptors_1 = zscore(descriptors_1')';
    descriptors_2 = zscore(descriptors_2')';
    %zscore uses mean and standard deviation along the columns of
    %descriptors, as we want along the rows, we transpose it. We transpose
    %it back after zscore is calculated.
    distances_matrix = dist2(descriptors_1, descriptors_2);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 5. SELECT PUTATIVE MATCHES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    threshold_distance=8;
    %select all pairs whose descriptor distances are below a specific\
    match_putative_count=1;
    for i=1:size(distances_matrix,1)
        for j=1:size(distances_matrix,2)
            if(distances_matrix(i,j)<threshold_distance)
                matches_putative_img1(match_putative_count,1) = i;
                matches_putative_img2(match_putative_count,1) = j;
                matches_putative(match_putative_count,1) = distances_matrix(i,j);
                match_putative_count=match_putative_count+1;
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 6. RANSAC - HOW TO MAP ONE IMAGE ON ANOTHER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [best_fit_model, inlier_index , inlier_count, avg_residual] = ransac(matches_putative_img1, matches_putative_img2,r_1,c_1,r_2,c_2);
    %best model is selected using RANSAC
    
    %Report number of inliers and the average residual of inliers
    sprintf('Number of inliers: %s',num2str(inlier_count))
    sprintf('Average Residual: %s',num2str(avg_residual))
    
    %Display location of inlier matches in both images
    figure();
    imshow(img1);
    hold on;
    m = matches_putative_img1(inlier_index(:, 1),1);
    scatter(c_1(m),r_1(m), 'g','*');
    ttle = ['Inliers in image 1'];
    title(ttle);
    
    figure();
    imshow(img2);
    hold on;
    n = matches_putative_img2(inlier_index(:, 1),1);
    scatter(c_2(n),r_2(n), 'g','*');
    ttle = ['Corresponding inliers in image 2'];
    title(ttle);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 7. WARP ONE IMAGE ON ANOTHER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    homography_matrix = maketform('projective', inv(best_fit_model));
    % Generate the homography_matrix matrix according to the best_fit_model to warp
    [~, x_mapping, y_mapping] = imtransform(img2_org, homography_matrix);
    % Warp the second image according to the homography_matrix

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 8. STITCH THE TWO IMAGES - GRAYSCALE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute bounds for stitched image
    x_mappingout = [min(1, x_mapping(1)) max(size(img1, 2), x_mapping(2))];
    y_mappingout = [min(1, y_mapping(1)) max(size(img1, 1), y_mapping(2))];
    % Transform both images with the computed x_mapping and y_mapping
    img2_transform = imtransform(img2, homography_matrix, 'XData', x_mappingout, 'YData', y_mappingout);
    transform_2 = maketform('affine', eye(3));
    img1_transform = imtransform(img1, transform_2,'XData', x_mappingout, 'YData', y_mappingout);
    stiched_grayscale = max(img1_transform, img2_transform); 
    figure, imshow(stiched_grayscale);
    ttle = ['Stitched grayscale'];
    title(ttle);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 9. CREATE COLOR PANAROMAS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Transform both images with the computed x_mapping and y_mapping
    img2_transform = imtransform(img2_org, homography_matrix, 'XData', x_mappingout, 'YData', y_mappingout);
    transform_2 = maketform('affine', eye(3));
    img1_transform = imtransform(img1_org, transform_2,'XData', x_mappingout, 'YData', y_mappingout);
    stiched_color = max(img1_transform, img2_transform); 
    opimg = stiched_color;
   
end

function [descriptors] = extract_neighborhood( img, r, c, neighborhood_depth)
    %Extract local neighborhoods around every keypoint in both images, and
    %form descriptors simply by ?flattening? the pixel values in each
    %neighborhood to one-dimensional vectors.
    mask_size=2*neighborhood_depth + 1;
    mask = zeros(mask_size);
    feature_nos = size(r,1); 
    feature_col= (mask_size)^2;
    mask(neighborhood_depth + 1, neighborhood_depth + 1) = 1;

    boundary_replicated_img = imfilter(img, mask, 'replicate', 'full');

    descriptors = zeros(feature_nos, feature_col);

    for i = 1 : feature_nos
        rowRange = r(i) : r(i) + 2*neighborhood_depth;
        colRange = c(i) : c(i) + 2*neighborhood_depth;
        neighborhood_values = boundary_replicated_img(rowRange, colRange);
        descriptor = neighborhood_values(:);
        descriptors(i,:) = descriptor;
    end

end
