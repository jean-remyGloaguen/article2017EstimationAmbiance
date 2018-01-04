function [config, store, obs] = nmfth4metric(config, setting, data)                
% nmfth4metric METRIC step of the expLanes experiment NMFThreshold                 
%    [config, store, obs] = nmfth4metric(config, setting, data)                    
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: <userName>                                                            
% Date: 01-Dec-2017                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, NMFThreshold('do', 4, 'mask', {2 2 1 0 1,...
            3 0 6 3 1, 0 0 2:3 30 1, 1 1}); return; else store=[]; obs=[]; end
                                                                                   
levels = data.levels;
pref = setting.p0;

LeqTrafficEstimate = zeros(length(levels),1);
LeqTrafficEstimatedB = zeros(length(levels),1);
LeqTrafficExact = zeros(length(levels),1);
LeqTrafficExactdB = zeros(length(levels),1);
LeqGlobal = zeros(length(levels),1);

%% EXTRACTION LEVELS
for ii = 1:length(levels)
    LpTrafficExact = levels{ii}.LpTraffic;
    LpTrafficExact(LpTrafficExact==0) = pref;
    
    LpTrafficEstimate = levels{ii}.LpTrafficEstimate{1};
    LpTrafficEstimate(LpTrafficEstimate==0) = pref;
    
    LpGlobal = levels{ii}.LpGlobal;
    LpGlobal(LpGlobal==0) = pref;
       
    LeqTrafficEstimate(ii) = levels{ii}.LeqTrafficEstimate(1);
    LeqTrafficExact(ii) = levels{ii}.LeqTraffic;
    LeqGlobal(ii) = levels{ii}.LeqGlobal;
    
    if size(LpGlobal,2)>size(LpTrafficEstimate,2)
        LpGlobal = LpGlobal(:,1:size(LpTrafficEstimate,2));
    elseif size(LpGlobal,2)<size(LpTrafficEstimate,2)
        LpTrafficEstimate = LpTrafficEstimate(:,1:size(LpGlobal,2));
    end
    
    
    %% linear sound level
    obs.rmse(ii) = rmseEXP(LpTrafficExact,LpTrafficEstimate);
    obs.nrmse(ii) = rmseEXP(LpTrafficExact./LpGlobal,LpTrafficEstimate./LpGlobal);
    
    %% sound level in dB
    LpTrafficExactdB = 20*log10(LpTrafficExact/pref);
    LpTrafficEstimatedB = 20*log10(LpTrafficEstimate/pref);
    LeqTrafficEstimatedB(ii) = 20*log10(LeqTrafficEstimate(ii)/pref);
    LeqTrafficExactdB(ii) = 20*log10(LeqTrafficExact(ii)/pref);
    
    rmse_temp = rmseEXP(LpTrafficExactdB,LpTrafficEstimatedB);
    obs.rmsedB(ii) = mean(rmse_temp);
    obs.cost(ii) = levels{ii}.cost(end);
end
mae = sum(abs(LeqTrafficEstimatedB-LeqTrafficExactdB))/length(LeqTrafficEstimatedB);
rmseLeq = rmseEXP(LeqTrafficEstimate,LeqTrafficExact);
rmseLeqdB = rmseEXP(LeqTrafficEstimatedB,LeqTrafficExactdB);

obs.LeqGlobal = 20*log10(LeqGlobal./pref);
obs.LeqTrafficExa = LeqTrafficExactdB;
obs.LeqTrafficEst = LeqTrafficEstimatedB;

obs.rmseLeq = rmseLeq;
obs.rmseLeqdB = rmseLeqdB;
obs.mae = mae;