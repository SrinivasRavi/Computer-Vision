%% Comment/Uncomment the relevant sections before running this main script.
%% Sections for guessing the image and evaluating the accuracy have been left uncommented in case this main script is run without any modifications.


% %%1.1 - Extracting filter Responses
% filterBank = createFilterBank();
% inImg = imread('../data/art_gallery/sun_ayczxofzbpncahin.jpg');
% 
% filterResponses = extractFilterResponses (inImg, filterBank);
% 
% % %%save all the files from the filterResponses to the current location and
% % then fetch for using Montage.
% % commandirOutput = dir('./*.jpg');
% % fileNames = {dirOutput.name}';
% % montage(fileNames, 'Size', [4 5]);
% 
% %Reshape the cell array so that it's a 4 x 5 matrix, then
% %convert the 2D cell array into a final 2D matrix.
% outImg = cell2mat(reshape(filterResponses, [5, 4]).');
% 
% %// Write to file
% imwrite(outImg,'../results/filter_output.jpg');
 

% %%1.2 - Creating visual words
% computeDictionary();
 

% %%1.3 - Computing Visual Words
% batchToVisualWords(2);

% %%2.1
% load('../data/garden/sun_baljkrrrkviakqdo.mat');
% load('../code/dictionary.mat');
% dictionarySize = size(dictionary,1);
% [h] = getImageFeatures(wordMap, dictionarySize);
% hist(h,dictionarySize);
% % % figure();
% % % histogram(wordMap,dictionarySize,'Normalization','pdf');

% %%2.2 - Multi-resolution: Spatial Pyramid Matching
% load('../data/garden/sun_baljkrrrkviakqdo.mat');
% load('../code/dictionary.mat');
% dictionarySize = size(dictionary,1);
% layerNum = 2;
% [h] = getImageFeaturesSPM(layerNum, wordMap, dictionarySize);
% %hist(h,dictionarySize); %or bar(h);
% 
% bar(h);

%2.3 - Comparing images
% load('../data/art_gallery/sun_alzdvjuueuqoucnr.mat');
% load('../code/dictionary.mat');
% dictionarySize = size(dictionary,1);
% layerNum = 2;
% wordHist = getImageFeaturesSPM(layerNum, wordMap, dictionarySize);
% %hist(h,dictionarySize); %or bar(h);
% 
% load('../data/visionTest.mat');
% histograms = x;
% [histInter,I] = distanceToSet(wordHist, histograms)
% 
% % A = [8 -1 7; 17 9 11; 20 23 22; 24 1 23];
% % B = [0; 10; 21; 22];
% % wordHist = B;
% % histograms = A;

%2.4 - Building A Model of the Visual World
buildRecognitionSystem();
guessImage('../data/garden/sun_btpwxzbarctnpoaf.jpg');
%


%2.5 - Quantitative Evaluation
conf = evaluateRecognitionSystem()
accuracy = (trace(conf)/sum(conf(:)))*100
% 
