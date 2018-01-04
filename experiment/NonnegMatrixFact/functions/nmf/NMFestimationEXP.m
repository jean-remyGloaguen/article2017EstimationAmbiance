function [LeqTrafficEstimate,LpTrafficEstimate,H,cost,sequentialData] = NMFestimationEXP(V,dictionary,setting,sequentialData)


%% limit the spectrogram and the dictionary to cutOffFreq
[soundMix] = cutSpectrogramEXP(dictionary,setting);

W = soundMix.W(1:soundMix.ind,:);
V = V(1:soundMix.ind,:);
binTemp = size(V,2);

switch setting.nmfType
    case 'supervised'
        
        if isempty(sequentialData)
            iteration = setting.iteration;
            rng(soundMix.seed)
            H = rand(size(W,2),binTemp);
        else
            % continuing step of the sequential run
            iteration = setting.iteration-sequentialData.numberIteration;
            H = sequentialData.H;
        end

        NMF = algo_nmfSupervisedEXP(H,W,V,iteration,soundMix,setting);
        cost = betadivEXP(V,NMF.Vap,setting.beta,NMF.H,setting.sparsity,setting.SM_weight);

    case 'semi-supervised'
        
        Wrand = setting.SS_sizeWrand;
        if isempty(sequentialData)
            iteration = setting.iteration;
            rng(soundMix.seed); Y =  rand(size(W,1),Wrand);
            rng(soundMix.seed); H = rand(size(W,2),binTemp);
            rng(soundMix.seed); Z = rand(Wrand,binTemp);
        else
            % continuing step of the sequential run
            iteration = setting.iteration-sequentialData.numberIteration;
            H = sequentialData.H;
            Z = sequentialData.Z;
            Y = sequentialData.Y;
        end

        NMF = algo_nmfSemiSupervisedEXP(H,W,Y,Z,V,iteration,soundMix,setting);
        cost = betadivSemiEXP(V,NMF,setting);
        
        sequentialData.Y = NMF.Y;
        sequentialData.Z = NMF.Z;
		
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% extraction traffic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[NMF] = separationTrafficEXP(NMF,soundMix,setting);

LeqTrafficEstimate = NMF.LeqTrafficEstimate;
LpTrafficEstimate = NMF.LpTrafficEstimate;

sequentialData.numberIteration = setting.iteration;
sequentialData.H = NMF.H;


