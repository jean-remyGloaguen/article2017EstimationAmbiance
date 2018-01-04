function [soundMix] = cutSpectrogramEXP(dictionary,setting)

W = dictionary.W;

switch setting.domain
    case 'mel'
        sr = setting.sr;
        numberMel = setting.numberMel; 

        [W,~] = spectre2MelEXP(W,numberMel,sr);
        ind = numberMel;
        
    case 'thirdOctave'
        [W,~,~,~] = NarrowToNthOctaveEXP(dictionary.frequency,W,3);
        ind = size(W,1);
        
    otherwise
        [~,ind] = min(abs(setting.cutOffFreq-dictionary.frequency));
end

soundMix.ind = ind;
soundMix.seed = rng;
soundMix.W = W;
soundMix.indTraffic = dictionary.indTraffic;