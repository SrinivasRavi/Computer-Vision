function [rows, columns, radii] = DetectsBlob(img, sigma, max_sigma, k, threshold , method)
%DETECTSBLOB Summary of this function goes here
%   Detailed explanation goes here

    %convert to grayscale
    gryImg = rgb2gray(img);
    %imtool(gryImg);
    
    %convert to double
    dbImg = im2double(gryImg);
    %imtool(dbImg);
    
    %calculate number of iterations - n
    n = ceil((log(max_sigma) - log(sigma))/log(k));
    %max_sigma = sigma * k^n
    
    %or alternatively choose the number of iterations and remove the
    %concept of max_sigma
    
    %method1: Keep image of same size and increase the size of the filter
    %in each iteration
    if (method == 'f')
        tic

        %create empty scale space for the h * w * n
        [h, w] = size(dbImg);
        scaleSpace_1 = zeros(h, w, n);

        sigma_i = sigma;

        for i = 1:n
            hsize = 2*ceil(3*sigma_i)+1; %kernel size is kept odd
            LoG = sigma_i^2 * fspecial('log', hsize, sigma_i); % scale normalized Laplacian

            % filter the image with LoG and replicate the border and have same output size as the input size
            filtered_i = imfilter(dbImg, LoG, 'same', 'replicate');  
            filtered_i = filtered_i.^2;%squared laplacian response
            scaleSpace_1(:,:,i) = filtered_i;%save the response in the i'th layer

            sigma_i = sigma_i * k; %increase kernel size by k for next iteration 
        end
        toc
        %method1 ends
        scaleSpace = scaleSpace_1;
     else

        %method2:Keep filter of same size and downsample the image
        tic
        reshapedImage = dbImg;
        [h, w] = size(dbImg);
        scaleSpace_2 = zeros(h, w, n);
        hsize = 2*ceil(3*sigma)+1; %kernel size is kept odd
        LoG = sigma^2 * fspecial('log', hsize, sigma); % scale normalized Laplacian
        
        for i = 1:n
            filtered = imfilter(reshapedImage, LoG, 'same', 'replicate');  
            filtered = filtered.^2;%squared laplacian response

            scaleSpace_2(:,:,i) = imresize(filtered, size(dbImg), 'bicubic'); % bilinear supersampling will result in a loss of spatial resolution
            if i < n        
                reshapedImage = imresize(dbImg, 1/(k^i), 'bicubic');
            end
        end
        toc
        %method2 ends
        scaleSpace = scaleSpace_2;
    end
    
    
    %Non-maximum suppression within scales
    space_max = zeros(h,w,n);
    for i = 1:n
        space_max(:,:,i) = ordfilt2(scaleSpace(:,:,i),9,ones(3,3));
        %ordfilt2 looks at all the 8 neighbouring values for a point and
        %determines the maximum (or the 9th minimum)of around that point and
        %prints it at the first location. Doing so for all the values
        %results in a point in space_max having the maximum value of all
        %the points surrounding it (8 neighbors).Comparing this with 
        %scaleSpace, the values which had the highest value among it's 
        %neighbourhood would not change and,
        %thus comparing with scaleSpace with space_max would give a 3D
        %matrix of points that are the maximum in their neighbourhood.
    end
    
    %Non-maximum suppression between the scales
    space_max_1 = zeros(h,w,n);
    for i = 1:n
        
        %save maximum across the scales back into space_max   
        space_max_1(:,:,i) = max(space_max(:,:,max(i-1,1):min(i+1,n)),[],3); % 3 because in 3rd dimension
        % max(i-1,1): to ensure i-1 doesn't fall off the array
        % min(i+1,n): to ensure i+1 doesn't fall off the array  
    end

    space_max_2 = (space_max_1 == scaleSpace).* space_max_1;
    %space_max == scaleSpace returns array of dimension of scaleSpace, with
    %the value of 1 for all elements which are equal and 0 for which are
    %different. If a point in space_max_1 is same as a point in scaleSpace,
    %that point is the maximum in scaleSpace. So multiplying it with
    %space_max_1 or scaleSpace gives all the maximum points only and all
    %the non-maximum points are suppressed.
    
    
    %Threshold and find the co-ordinates of the maximum value.
    %Also capture the scale at which maxima is observed as that is used to
    %calculate the radius of the circle centered at that maxima point.
    
   
    rows = [];   
    columns = [];   
    radii = [];
    for i=1:n
        sigma_i = sigma * k^(i-1);
        %select sigma for the i'th scale
        
        [row, col] = find(space_max_2(:,:,i) >= threshold);
        %find all the points in the scale that have non-zero value and are
        %above threshold (to remove any noise, yes, despite the gaussian filter applied with LoG)
        
        radius =  sqrt(2) * sigma_i;
        %radius calculated according to the formula. It depends on the
        %sigma value at the scale with maximum value for the point across
        %the scales
        
        radius = repmat(radius, length(col), 1);
        %repeat all the radius for all the points on the scale
        
        rows = [rows; row];
        %add all the y co-ordinates of all the maxima points in vector rows
        
        columns = [columns; col];
        %add all the x co-ordinates of all the maxima points in vector
        %columns
        
        radii = [radii; radius];
        %%add all the radii of all the maxima points in vector radii
    end
end

