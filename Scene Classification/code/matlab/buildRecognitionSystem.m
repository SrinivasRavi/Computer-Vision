function buildRecognitionSystem()
% Creates vision.mat. Generates training features for all of the training images.

	%load('dictionary.mat');
	%load('../data/traintest.mat');

	% TODO create train_features
    load('dictionary.mat','filterBank','dictionary');
    load('../data/traintest.mat','train_imagenames','train_labels');
    
    %create train_features
    l = length(train_imagenames);
    layerNum = 2;
    dictionarySize = size(dictionary,1);
    source = '../data/'; 
    train_features = [];
    for i=1:l
        train_wordMapNames{i} = strcat(source, strrep(train_imagenames{i},'.jpg','.mat'));
        fprintf('Processing Wordmap for %s\n', train_wordMapNames{i});
        load(train_wordMapNames{i});
        h = getImageFeaturesSPM(layerNum, wordMap, dictionarySize);
        train_features = horzcat(train_features, h);
    end
    
    %save the newly created train_features, filterBank, dictionary and train_labels into a file - vision.mat
    save('vision.mat', 'filterBank', 'dictionary', 'train_features', 'train_labels');

end