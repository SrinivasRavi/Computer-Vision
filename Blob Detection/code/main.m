inImg = imread('../data/random1.jpg');
sigma = 2;
k = 1.189;
max_sigma = 20;
threshold = 0.01; 
gryImg = rgb2gray(inImg);

%method1: Keep image of same size and increase the size of the filter
%Uncomment the below comments to use method 1. Comment method2 too. Vice
%versa for vice versa.
% method = 'f';
% [rows_1, columns_1, radii_1] = DetectsBlob(inImg, sigma, max_sigma, k, threshold, method );
% show_all_circles(gryImg, columns_1, rows_1, radii_1, 'red', 1.5);

%method2:Keep filter of same size and downsample the image
method = 'i';
[rows_2, columns_2, radii_2] = DetectsBlob(inImg, sigma, max_sigma, k, threshold, method );
show_all_circles(gryImg, columns_2, rows_2, radii_2, 'red', 1.5);
