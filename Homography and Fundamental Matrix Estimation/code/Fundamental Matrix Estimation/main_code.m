%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN THIS CODE FOR ALL THE OUTPUTS FOR PART2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% load images and match files for the first example
%%

I1 = imread('../../data/part2/house1.jpg');
I2 = imread('../../data/part2/house2.jpg');
matches = load('../../data/part2/house_matches.txt'); 
% this is a N x 4 file where the first two numbers of each row
% are coordinates of corners in the first image and the last two
% are coordinates of corresponding corners in the second image: 
% matches(i,1:2) is a point in the first image
% matches(i,3:4) is a corresponding point in the second image

N = size(matches,1);

%%
%% display two images side-by-side with matches
%% this code is to help you visualize the matches, you don't need
%% to use it to produce the results for the assignment
%%
% imshow([I1 I2]); hold on;
% plot(matches(:,1), matches(:,2), '+r');
% plot(matches(:,3)+size(I1,2), matches(:,4), '+r');
% line([matches(:,1) matches(:,3) + size(I1,2)]', matches(:,[2 4])', 'Color', 'r');
% pause;

%%
%% display second image with epipolar lines reprojected 
%% from the first image
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. FIT FUNDAMENTAL MATRIX - UNNORMALIZED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first, fit fundamental matrix to the matches
F = fit_fundamental(matches); % this is a function that you should write
%F = fit_fundamental_normalized(matches); % this is a function that you should write
L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from 
% the first image to get epipolar lines in the second image

% find points on epipolar lines L closest to matches(:,3:4)
L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

% find endpoints of segment on epipolar line (for display purposes)
pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

%calculate the residual
residuals1 = calc_residuals(F,matches);

% display points and segments of corresponding epipolar lines

imshow(I2); hold on;
plot(matches(:,3), matches(:,4), '+r');
ttle = ['Mean Residual using non-normalized : ', num2str(mean(residuals1))];
title(ttle);
line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'b');
line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. FIT FUNDAMENTAL MATRIX - NORMALIZED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first, fit fundamental matrix to the matches
%F = fit_fundamental(matches); % this is a function that you should write
F = fit_fundamental_normalized(matches); % this is a function that you should write
L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from 
% the first image to get epipolar lines in the second image

% find points on epipolar lines L closest to matches(:,3:4)
L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

% find endpoints of segment on epipolar line (for display purposes)
pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

%calculate the residual
residuals2 = calc_residuals(F,matches);

% display points and segments of corresponding epipolar lines
%clf;
figure;
imshow(I2); hold on;
plot(matches(:,3), matches(:,4), '+r');
ttle = ['Mean Residual using normalized : ', num2str(mean(residuals2))];
title(ttle);
line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'y');
line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. PUTATIVE MATCH AND RANSAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[F, inlierIndices] = ransac(matches);
display(['Number of inliers is: ', num2str(length(inlierIndices))]);
display(['Average Residual of Inliers is: ', num2str(mean(calc_residuals(F,matches(inlierIndices,:))))]);
display(['Mean residual is: ' , num2str(mean(calc_residuals(F,matches)))]);
L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from 
% the first image to get epipolar lines in the second image

% find points on epipolar lines L closest to matches(:,3:4)
L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

% find endpoints of segment on epipolar line (for display purposes)
pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

%calculate the residual
residuals3 = calc_residuals(F,matches);

% display points and segments of corresponding epipolar lines
clf;
figure;
imshow(I2); hold on;
plot(matches(:,3), matches(:,4), '+r');
ttle = ['Mean Residual using RANSAC : ', num2str(mean(residuals3))];
title(ttle);
line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'm');
line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. CENTERS OF CAMERAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load the camera matrices and determine the camera centers
camMatrix1 = load('../../data/part2/house1_camera.txt');
[~, ~, V] = svd(camMatrix1);
camCenter1 = V(:,end);
camCenter1 = homo_2_cart(camCenter1');

camMatrix2 = load('../../data/part2/house2_camera.txt');
[~, ~, V] = svd(camMatrix2);
camCenter2 = V(:,end);
camCenter2 = homo_2_cart(camCenter2');


%homogenize the coordinates
x1 = cart_2_homo(matches(:,1:2));
x2 = cart_2_homo(matches(:,3:4));
numMatches = size(x1,1);
triangPoints = zeros(numMatches, 3);
projPointsImg1 = zeros(numMatches, 2);
projPointsImg2 = zeros(numMatches, 2);

%calcualte the triangulated points, + their projections onto each img plane
for i = 1:numMatches
    pt1 = x1(i,:);
    pt2 = x2(i,:);
    crossProductMat1 = [  0   -pt1(3)  pt1(2); pt1(3)   0   -pt1(1); -pt1(2)  pt1(1)   0  ];
    crossProductMat2 = [  0   -pt2(3)  pt2(2); pt2(3)   0   -pt2(1); -pt2(2)  pt2(1)   0  ];    
    Eqns = [ crossProductMat1*camMatrix1; crossProductMat2*camMatrix2 ];
    
    [~,~,V] = svd(Eqns);
    triangPointHomo = V(:,end)'; %4 dim (3 dimensions + homo coord)
    %save the triangulated 3d point
    triangPoints(i,:) = homo_2_cart(triangPointHomo);
    
    %project the triangulated point using both camera matrices for later
    %residual calculations
    projPointsImg1(i,:) = homo_2_cart((camMatrix1 * triangPointHomo')');
    projPointsImg2(i,:) = homo_2_cart((camMatrix2 * triangPointHomo')');
    
end

% plot the triangulated points and the camera centers

figure; axis equal;  hold on; 
plot3(-triangPoints(:,1), triangPoints(:,2), triangPoints(:,3), '.r');
plot3(-camCenter1(1), camCenter1(2), camCenter1(3),'*b');
plot3(-camCenter2(1), camCenter2(2), camCenter2(3),'*m');
grid on; xlabel('x'); ylabel('y'); zlabel('z'); axis equal;
ttle = ['Camera1 - Blue, Camera2 - Magenta'];
title(ttle);
    

%calculate the error distance between the triangulated point projected onto
%the image plane and the actual location of the point on the image plane
distances1 = diag(dist2(matches(:,1:2), projPointsImg1));
distances2 = diag(dist2(matches(:,3:4), projPointsImg2));
display(['Mean Residual 1.: ', num2str(mean(distances1))]);
display(['Mean Residual 2.: ', num2str(mean(distances2))]);



