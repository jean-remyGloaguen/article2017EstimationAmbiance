function [config, store, obs] = nmfth3threshold(config, setting, data)
% nmfth3threshold THRESHOLD step of the expLanes experiment NMFThreshold
%    [config, store, obs] = nmfth3threshold(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: <userName>
% Date: 01-Dec-2017

% Set behavior for debug mode
if nargin==0, NMFThreshold('do', 3, 'mask', {2 2 1 0 1,...
            3 0 6 3 1, 0 0 2:3 30 1, 1 1}); return; else store=[]; obs=[]; end

levels = cell(1,setting.sceneSelect);
nmf =  data.nmf;

if strcmp(setting.type,'nmf')
    distanceMethod = setting.distanceMethod;
    displayDistance = setting.displayDistance;
    methodThreshold = setting.methodThreshold;
    
    valueThresholdCheck = 1;
    switch  methodThreshold
        case 'firm'
            threshold(1) = setting.thresholdFirmHigh;
            threshold(2) = setting.thresholdFirmLow;
            if threshold(1) < threshold(2)
                valueThresholdCheck = 0;
            end
        otherwise
            threshold = setting.threshold;
    end
    
    [soundMix] = cutSpectrogramEXP(nmf{1}.W0,setting);
    W0 = soundMix.W(1:soundMix.ind,:);
    [F,K] = size(W0);
    
    switch setting.displayDistance
        case 'sigmoid'
            lambda = 1;
        case 'RBF'
            lambda = 1;
        otherwise
            lambda = 0;
    end
    
    if valueThresholdCheck == 1
        for ii = 1:setting.sceneSelect
            W = nmf{ii}.W(1:F,:);
            H = nmf{ii}.H;
            
            switch distanceMethod
                case 'cosine'
                    dist = sum(W.*W0)./(sqrt(sum(W.^2,1)).*sqrt(sum(W0.^2,1)));
                    dist(isnan(dist)) = 0;
                    [~, order] = sort(dist,'descend');
                    
                case 'none'
                    order = 1:K;
            end
            
            Wn = W(:,order);
            Hn = H(order,:);
            
            switch distanceMethod
                case 'none'
                    Wtraffic = Wn;
                    Htraffic = Hn;
                    
                otherwise
                    dist = dist(order);
                    
                    switch displayDistance
                        case 'sigmoid'
                            dist = 1./(1+exp(-lambda*dist));
%                             dist = (dist-dist(end))./(dist(1)-dist(end));
                        case 'RBF'
                            dist = exp(-dist./lambda);
%                             dist = (dist-dist(1))./(dist(end)-dist(1));
                    end
                    vec = zeros(1,K);
                    
                    switch methodThreshold
                        case 'hard'
                            switch displayDistance
                                case 'RBF'
                                    vec(dist>threshold) = 0;
                                    vec(dist<=threshold) = 1;
                                otherwise
                                    vec(dist>threshold) = 1;
                                    vec(dist<=threshold) = 0;
                            end
                            
                        case 'soft'
                            vec(dist>threshold) = 2;
                            vec(dist<=threshold) = 1;
                            
                            switch displayDistance
                                case 'RBF'
                                    if ~isempty(dist(vec==1))
                                        vec(vec==1) = dist(vec==1)-threshold;
                                    end
                                    vec(vec==2) = 0;
                                otherwise
                                    if ~isempty(dist(vec==1))
                                        vec(vec==1) = dist(vec==1)-threshold;
                                    end
                                    vec(vec==2) = 0;
                            end

                        case 'firm'
                            vec(dist>threshold(1)) = 1;
                            vec(dist<=threshold(1) & dist>threshold(2)) = 2;
                            vec(dist<=threshold(2)) = 3;
                            
                            switch displayDistance
                                case 'RBF'
                                    vec(vec==1) = 0;
                                    vec(vec==2) = threshold(1)*(dist(vec==2)-threshold(2))/(threshold(1)-threshold(2));
                                    vec(vec==3) = 1;
                                otherwise
                                    vec(vec==1) = 1;
                                    vec(vec==2) = threshold(1)*(dist(vec==2)-threshold(2))/(threshold(1)-threshold(2));
                                    vec(vec==3) = 0;
                            end
                    end
                    Wtraffic = Wn.*repmat(vec,F,1);
                    Htraffic = Hn;
            end
            
            [LpTrafficEstimate,LeqTrafficEstimate] = estimationLpEXP(Wtraffic*Htraffic,setting);
            
            levels{ii}.LpTrafficEstimate = LpTrafficEstimate;
            levels{ii}.LeqTrafficEstimate = LeqTrafficEstimate;
            levels{ii}.LpTraffic = nmf{ii}.LpTraffic;
            levels{ii}.LeqTraffic = nmf{ii}.LeqTraffic;
            levels{ii}.LpGlobal = nmf{ii}.LpGlobal;
            levels{ii}.LeqGlobal = nmf{ii}.LeqGlobal;
            levels{ii}.cost = nmf{ii}.cost;

        end
    else
        for ii = 1:setting.sceneSelect
            levels{ii}.LpTrafficEstimate{1} = nan;
            levels{ii}.LeqTrafficEstimate(1) = nan;
            levels{ii}.LpTraffic = nmf{ii}.LpTraffic;
            levels{ii}.LeqTraffic = nmf{ii}.LeqTraffic;
            levels{ii}.LpGlobal = nmf{ii}.LpGlobal;
            levels{ii}.LeqGlobal = nmf{ii}.LeqGlobal;
            levels{ii}.cost = nmf{ii}.cost;
        end
    end
    store.levels = levels;
else
    for ii = 1:setting.sceneSelect
        levels{ii}.LeqTrafficEstimate = nmf{ii}.LeqTrafficEstimate;
        levels{ii}.LpTrafficEstimate = nmf{ii}.LpTrafficEstimate;
        levels{ii}.LpTraffic = nmf{ii}.LpTraffic;
        levels{ii}.LeqTraffic = nmf{ii}.LeqTraffic;
        levels{ii}.LpGlobal = nmf{ii}.LpGlobal;
        levels{ii}.LeqGlobal = nmf{ii}.LeqGlobal;
        levels{ii}.cost = nmf{ii}.cost;
    end
    store.levels = levels;
end