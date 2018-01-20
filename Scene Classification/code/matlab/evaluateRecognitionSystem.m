function [conf] = evaluateRecognitionSystem()
% Evaluates the recognition system for all test-images and returns the confusion matrix

	load('vision.mat');
	load('../data/traintest.mat','test_imagenames','test_labels','mapping');
    
	% TODO Implement your code here
    
    
    conf = zeros(8,8);
        
    source = '../data/';
    
    %for each test image
    for i = 1:(length(test_imagenames))
        %Deduce the actual index for the image (corresponding to the labels)
        actual_index = test_labels(i,1);
        
        %determine it's guessed_index
        test_wordMapNames{i} = strcat(source, strrep(test_imagenames{i},'.jpg','.mat'));
        load(test_wordMapNames{i});
        h = getImageFeaturesSPM(3, wordMap, size(dictionary,1));
        distances = distanceToSet(h, train_features);
        [~,nnI] = max(distances);
        guessedImage = mapping{train_labels(nnI)};
        guessed_index = find(contains(mapping,guessedImage));
        
        %set the confusion matrix
        conf(actual_index, guessed_index) = conf(actual_index,guessed_index) + 1;    
    end
    
    

end