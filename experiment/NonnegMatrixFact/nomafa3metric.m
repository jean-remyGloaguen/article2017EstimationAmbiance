function [config, store, obs] = nomafa3metric(config, setting, data)
% nomafa3metric metric step of the expLanes experiment NonnegMatrixFact
%    [config, store, obs] = nomafa3metric(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: <userName>
% Date: 16-Jan-2017

% Set behavior for debug mode
if nargin==0, NonnegMatrixFact('do', 3, 'mask',{2 2 1 3 1,...
            3 0 6 2 1, 0 0 0 3 2, 1 1 1 1 1, 1 1 1 1}); return; else store=[]; obs=[]; end

levels = data.levels;
p0 = setting.p0;

if strcmp(setting.formW,'cut') && strcmp(setting.domain,'spectra')
    ind = 2;
else
    ind = 1;
end

LeqTrafficEstimate = zeros(length(levels),1);
LeqTrafficEstimatedB = zeros(length(levels),1);
LeqTrafficExact = zeros(length(levels),1);
LeqTrafficExactdB = zeros(length(levels),1);

%% EXTRACTION LEVELS
for ii = 1:length(levels)
    %% linear sound level
    LpTrafficExact = levels{ii}.LpTraffic;
    LpTrafficExact(LpTrafficExact==0) = 2e-5;
    
    LpTrafficEstimate = levels{ii}.LpTrafficEstimate{ind};
    LpTrafficEstimate(LpTrafficEstimate==0) = 2e-5;
    
    LpGlobal = levels{ii}.LpGlobal;
    LpGlobal(LpGlobal==0) = 2e-5;
        
    LeqTrafficEstimate = levels{ii}.LeqTrafficEstimate(ind);
    LeqTrafficExact = levels{ii}.LeqTraffic;
    LeqGlobal = levels{ii}.LeqGlobal;
    
    if size(LpGlobal,2)>size(LpTrafficEstimate,2)
        LpGlobal = LpGlobal(:,1:size(LpTrafficEstimate,2));
    elseif size(LpGlobal,2)<size(LpTrafficEstimate,2)
        LpTrafficEstimate = LpTrafficEstimate(:,1:size(LpGlobal,2));
    end
    
    obs.rmse(ii) = rmseEXP(LpTrafficExact,LpTrafficEstimate);
    obs.nrmse(ii) = rmseEXP(LpTrafficExact./LpGlobal,LpTrafficEstimate./LpGlobal);
    
    %% sound level in dB
    LpTrafficExactdB = 20*log10(LpTrafficExact/p0);
    LpTrafficEstimatedB = 20*log10(LpTrafficEstimate/p0);
    LeqTrafficExactdB(ii) = 20*log10(LeqTrafficExact/p0);
    LeqTrafficEstimatedB(ii) = 20*log10(LeqTrafficEstimate/p0);
    
    obs.LeqGlobaldB(ii) = 20*log10(LeqGlobal/p0);
    
    rmse_temp = rmseEXP(LpTrafficExactdB,LpTrafficEstimatedB);
    obs.rmsedB(ii) = mean(rmse_temp);
    obs.cost(ii) = levels{ii}.cost;
end
mae = sum(abs(LeqTrafficEstimatedB-LeqTrafficExactdB))/length(LeqTrafficEstimatedB);
rmseLeq = rmseEXP(LeqTrafficEstimate,LeqTrafficExact);
rmseLeqdB = rmseEXP(LeqTrafficEstimatedB,LeqTrafficExactdB);

obs.rmseLeq = rmseLeq;
obs.rmseLeqdB = rmseLeqdB;
obs.mae = mae;

% figure
% plot(LpTrafficExactdB), hold on 
% plot(LpTrafficEstimatedB)

% if setting.id == 1
%     close all
% end
% figure(setting.id)
% subplot(2,1,1), semilogx(levels{1}.Y(:,1)), hold on 
% title([setting.aType '-' setting.domain '-' num2str(setting.TPR)])
% subplot(2,1,2), semilogx(levels{1}.Y(:,2)), hold on 
% 
% sauvegardePlotEXP([setting.aType '-' setting.domain '-' num2str(setting.TPR)],...
%         'D:\gloaguen\Documents\Production\2017 - Applied Acoustics\image','fig') 

% figure
% plot(LeqTrafficExactdB), hold on
% plot(LeqTrafficEstimatedB)
% legend('exact','estimate')
% sauvegardePlotEXP(['Leq - ' setting.aType '-' num2str(setting.TPR)],...
%         'D:\gloaguen\Documents\Production\2017 - Applied Acoustics\image','fig') 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mask filter ambiance
% 1 0 0 0 0, 0 0 0 2 1
%% mask filter grafic
% 1 0 0 0 0, 0 0 0 1 2
%% mask filter car
% 1 0 0 0 0, 0 0 0 1 3
%% mask supervised NMF car
% 2 0 1 0 2, ...
%     1 0 0 1 3, 0 0 0 3 1, 1 1 1 1 1
% % 2 [1 2] 1 [1 2] 2,...
%         1 0 [1 2 3] 2 1, 0 0 0 2 2, 1 1 1 1 1, 0 0 0 0 0
%% mask K = 50 ambiance supervised, semi-supervised
% {2 2 1 2 2 1 0 0 2 1, 0 0 0 3 1, 1 1 1 1 1},...
% {2 1 1 2 2 1 0 0 2 1, 0 0 0 3 2, 1 1 1 1 1}
% {2 1 1 1 2 ,...
%             1 0 1 2 1, 1 0 2:4 3 1, 1 1 1 1 1, 0 0 0 0 10, 2},{2 1 1 1 2,...
%             3 0 6 2 1, 1 0 2:4 2 1, 1 1 1 1 1, 0 0 0 0 10, 2}
%% early stop iteration =  =  = [1:2:19 20:20:100]
% {2 2 1 1 2 ,...
%             1 0 1 2 1, [1 3 5] 0 [2 4] 3 1, 1 1 1 1 1}
% {2 1 1 3 2,...
%         1 0 6 2 1, [1 3 5] 0 [2 4] 3 2, 1 1 1 1 1}
%% mask ambiance supervised SPECTRA beta = 2
% 2 [1 2] 1 [1 3] 2,...
%     1 0 0 2 1, 0 0 0 3 1, 1 1 1 1 1
%% mask ambiance supervised smooth spectra and 1/3 octave
% 2 2 1 1 2, ...
%     1 0 1 2 1, 0 0 0 3 1, 1 2 2 1 1
% 2 2 1 1 2, ...
%     3 0 6 2 1, 0 0 0 3 1, 1 2 2 1 1
%% mask ambiance supervised/semi-supervised TIERS OCTAVE beta = 1/2
% 2 0 1 0 2,...
%    3 0 6 2 1, 0 0 0 [2 3] 0, 1 1 1 1 1, 0 0 0 0 0
%% mask ambiance semi-supervised NMF
% 2 [1 2] 1 [1 3] 2, ...
%     1 0 0 2 1, 0 0 0 3 2, 1 1 1 1 1
%% mask semi-supervised smooth spectra and 1/3 octave
% 2 1 1 3 2,...
%     1 0 6 2 1, 0 0 0 3 2, 1 2 2 1 1
% 2 2 1 1 2,...
%     3 0 6 2 1, 0 0 0 3 2, 1 2 2 1 1
%% mask ambiance semi-supervised constrained NMF
% 2 1 1 3 2, ...
%     1 0 0 2 1, 0 0 0 3 2, 1 1 1 1 2, 2 0 0 0 0
%% mask supervised/semi-supervised NMF grafic 1/3 octave-mel beta = 0,1,2
% 2 0 1 1 2 ,...
%	2:3 0 6 1 2, 0 0 0 0 0, 1 1 1 1 1