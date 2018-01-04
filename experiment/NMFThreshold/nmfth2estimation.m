function [config, store, obs] = nmfth2estimation(config, setting, data)            
% nmfth2estimation ESTIMATION step of the expLanes experiment NMFThreshold         
%    [config, store, obs] = nmfth2estimation(config, setting, data)                
%      - config : expLanes configuration state                                     
%      - setting   : set of factors to be evaluated                                
%      - data   : processing data stored during the previous step                  
%      -- store  : processing data to be saved for the other steps                 
%      -- obs    : observations to be saved for analysis                           
                                                                                   
% Copyright: <userName>                                                            
% Date: 01-Dec-2017                                                                
                                                                                   
% Set behavior for debug mode                                                      
if nargin==0, NMFThreshold('do', 2, 'mask', {2 2 1 0 1,...
            3 0 6 3 2, 0 0 2:3}); return; else store=[]; obs=[]; end
% à faire :
% 2 1 1 [1 3] 1,...
%             1 0 [2 3 4] 3 1, 0 0 2:3
% 2 2 1 1:2 1,...
%             1 0 [2 3 4] 3 1, 0 0 2:3
% 2 1 1 [1 2 4] 1,...
%             3 0 6 3 1, 0 0 2:3

TIR = setting.TIR;
dataset = setting.dataset;
type = setting.type;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DICTIONARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(type,'nmf')
    dictionary.W = data.dictionary.W;
    dictionary.frequency = data.dictionary.frequency;
    dictionary.indTraffic = data.dictionary.indTraffic;
    nmf{1}.W0 = dictionary.W;
else
    dictionary = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BASELINE GLOBALE ERROR + FILTRE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch dataset
    case 'ambience'
        creationSceneDir = strcat(config.inputPath, dataset, filesep, setting.aType, filesep);
        
    case 'grafic'
        creationSceneDir = strcat(config.inputPath, dataset, filesep, setting.gType, filesep);
        
    case 'cars'
        creationSceneDir = strcat(config.inputPath, dataset, filesep);
end

files = dir(strcat(creationSceneDir,filesep,'*.wav'));
globalName = cell(1,length(files)/3);
ind = 1;

for ii = 1:length(files)
    if isempty(strfind(files(ii).name,'traffic')) && isempty(strfind(files(ii).name,'perturbator'))
        globalName{ind} = files(ii).name(1:end-4);
        ind = ind+1;
    end
end

switch dataset
    case 'ambiance'
        numberScene = setting.sceneSelect;
        if numberScene > length(globalName)
            error('sceneSelect is superior to the number of available scenes')
        end
    case 'grafic'
        numberScene = length(globalName);
end

nmf = cell(numberScene,1);

if isempty(config.sequentialData)
    sequentialData = cell(numberScene,1);
else
    sequentialData = config.sequentialData;
end

parfor ii = 1:numberScene
    
    fileTraffic = audioread(strcat(creationSceneDir,globalName{ii},'_traffic.wav'));
    fileRest = audioread(strcat(creationSceneDir,globalName{ii},'_perturbator.wav'));
    
    if strcmp(dataset,'ambience')        
        %% modif SNR
        A = rms(fileTraffic);
        B = rms(fileRest);
        if B ~= 0
            SNR_temp = 20*log10(A/B);
            facteur = 10.^((TIR-SNR_temp)/20);
            fileTraffic = facteur.*(fileTraffic);  % fichier perturbateur modifiï¿½*
        end 
    end
    
    fileTraffic(fileTraffic == 0) = eps;
    fileTot = fileRest+fileTraffic;
    
    [Vtraffic] = audio2SpectrogramEXP(fileTraffic',setting);
    [Lp,Leq] = estimationLpEXP(Vtraffic,setting);
    nmf{ii}.LpTraffic =  Lp{1};
    nmf{ii}.LeqTraffic = Leq(1);
    
    [V,Vlinear] = audio2SpectrogramEXP(fileTot',setting);
    [Lp,Leq] = estimationLpEXP(Vlinear,setting);
    nmf{ii}.LpGlobal = Lp{1};
    nmf{ii}.LeqGlobal = Leq(1);
    
    switch type
        case 'filter'
            [LeqFiltre,LpFiltre] = filtrePasseBasEXP(Vlinear,setting);
            nmf{ii}.LeqTrafficEstimate = LeqFiltre;
            nmf{ii}.LpTrafficEstimate = LpFiltre;
            sequentialData{ii} = 0;
            nmf{ii}.cost = 0;
            
        case 'nmf'
            [NMF,sequentialData{ii}] =...
                NMFestimationEXP(V,dictionary,setting,sequentialData{ii});
            
            nmf{ii}.H = NMF.H;
            nmf{ii}.W = NMF.W;
            nmf{ii}.cost = NMF.cost(end);
    end 
end

config.sequentialData = sequentialData;
store.nmf = nmf;
