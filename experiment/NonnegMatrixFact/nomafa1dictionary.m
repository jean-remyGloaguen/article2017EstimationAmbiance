function [config, store, obs] = nomafa1dictionary(config, setting, data)
% nomafa1dictionary DICTIONARY step of the expLanes experiment NonnegMatrixFact
%    [config, store, obs] = nomafa1dictionary(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: <userName>
% Date: 13-Jan-2017

% Set behavior for debug mode
if nargin==0, NonnegMatrixFact('do', 1, 'mask',{1 2 1 0 1}); return; else, store=[]; obs=[]; end

if strcmp(setting.type,'nmf')
    K = setting.numberElementW;
    inputPath = config.inputPath;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% NAME & NUMBER SAMPLE EXTRACTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch setting.dictionaryClass
        case 'car'
            cityCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*cityCar*'));
            roadCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*roadCar*'));
            stopCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*stopCar*'));
            sample = [cityCarSamples; roadCarSamples; stopCarSamples];
            indiceClass = ones(1,length(sample));

        case 'all'
            sample = dir(strcat(inputPath,'dictionary',filesep,'*.wav'));

            indiceClass = zeros(1,length(sample));
            for ii = 1:length(sample)
                if ~isempty(strfind(sample(ii).name,'cityCar')) ||...
                        ~isempty(strfind(sample(ii).name,'roadCar')) || ...
                        ~isempty(strfind(sample(ii).name,'stopCar'))
                    indiceClass(ii) = 1;
                else
                    indiceClass(ii) = 0;
                end
            end
        otherwise
            cityCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*cityCar*'));
            roadCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*roadCar*'));
            stopCarSamples = dir(strcat(inputPath,'dictionary',filesep,'*stopCar*'));
            sample = [cityCarSamples; roadCarSamples; stopCarSamples];
            indiceClass = ones(1,length(sample));
            
            birdSample = dir(strcat(inputPath,'dictionary',filesep,'*bird*'));
            sample = [sample; birdSample];
            indiceClass = [indiceClass zeros(1,length(birdSample))];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% AUDIO SAMPLE EXTRACTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    W = cell(1,length(sample));
    frequency = cell(1,length(sample));
    indTraffic = W; 

    parfor ind = 1:length(sample)

        file = audioread(strcat(inputPath,'dictionary',filesep,sample(ind).name));

        [W{ind},frequency{ind},indTraffic{ind}] = creationDictionaryEXP(file,indiceClass(ind),setting);

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CLUSTERING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    W = cell2mat(W);
    indTraffic = cell2mat(indTraffic);
    W(W<eps) = 0;

    if size(W,2) > K
        idx = zeros(K,1);
        switch setting.reduceSizeW
            case 'rand'
                idx = randperm(size(W,2),K);
                W = W(:,idx);
                indTraffic = indTraffic(idx);
                
            case 'kmeans'
                [~,C] = kmeans(W',K,'MaxIter',200);
                C = (C./repmat(sum(C,2),1,size(C,2)))';
                for ii = 1:K
                    dist = 0.5*sum((repmat(C(:,ii),1,size(W,2))-W).^2,1);
                    [~,idx(ii)] = min(dist);
                end
                indTraffic = indTraffic(idx);
                W = C;
                
            case 'kmeansMedoids'
                W_new = zeros(size(W,1),K);             
                [~,C] = kmeans(W',K,'MaxIter',200);

                for ii = 1:K   % euclidean distance between kmeans and my W
                    [~,idx(ii)] = min(0.5*sum((repmat(C(ii,:)',1,size(W,2))-W).^2,1));  % the closest element is part of the built dictionary 
                    W_new(:,ii) = W(:,idx(ii));
                    W(:,idx(ii)) = [];
                    
                end
                indTraffic = indTraffic(idx);
                W = W_new;
        end
    end

    dictionary.className = setting.dictionaryClass;
    dictionary.indTraffic = indTraffic;
    dictionary.W = W;
    dictionary.frequency = frequency{1};
    dictionary = orderfields(dictionary);
else
    
    dictionary = [];
end

store.dictionary = dictionary;