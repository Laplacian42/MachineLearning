%--------------------------------------------------------------------------
%This is a example of the training of a svm with the purpose to distinguish
%green from red images.
% v1.0: 05.01.2018 Initial version from Michael Wutz
%--------------------------------------------------------------------------

%First load the training set into matlab
pathtomatTrain = fullfile(pwd,'TrainingSet','testimagesAsMatlab.mat');
theTruthTrain  = fullfile(pwd,'TrainingSet','Results.xlsx');
load(pathtomatTrain);

[NUM,TXT,RAW]=xlsread(theTruthTrain);

%init variables
li = length(images);
mycsv = nan(li,60);
theClass = nan(li,1);
%read images (NxMx3 matrices linearized) into one big matrix
%Each row equals one image
for k = 1:li
    curImage = images{k};
    mycsv(k,:) = curImage(:)';%linearization happens here
    if strcmpi(TXT{k},'true')
       theClass(k) = 1;
    else
       theClass(k) = 0;
    end
end

%--------------------------------------------------------------------------
% Train the model
z=tic;
 MODEL = fitcsvm(mycsv,theClass);
 elapsedTime = toc(z);
 disp(['Training time = ' num2str(elapsedTime)]);
%--------------------------------------------------------------------------
 
% Validate the svm
pathtomatVal = fullfile(pwd,'ValidationSet','testimagesAsMatlab.mat');
theTruthVal  = fullfile(pwd,'ValidationSet','Results.xlsx');
load(pathtomatVal);

[NUM,TXT,RAW]=xlsread(theTruthVal);

%init variables
li = length(images);
mycsvVal = nan(li,60);
theClassVal = nan(li,1);
%read images (NxMx3 matrices linearized) into one big matrix
%Each row equals one image
for k = 1:li
    curImage = images{k};
    mycsvVal(k,:) = curImage(:)';%linearization happens here
    if strcmpi(TXT{k},'true')
       theClassVal(k) = 1;
    else
       theClassVal(k) = 0;
    end
end

%Then predict the class given the images:
if all(MODEL.predict(mycsvVal) == theClassVal)
   disp('The SVM was able to predict all images correctly.'); 
end