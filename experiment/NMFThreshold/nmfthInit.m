function [config, store] = nmfthInit(config)                       
% nmfthInit INITIALIZATION of the expLanes experiment NMFThreshold 
%    [config, store] = nmfthInit(config)                           
%      - config : expLanes configuration state                     
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: <userName>                                            
% Date: 01-Dec-2017                                                
                                                                   
if nargin==0, NMFThreshold(); return; else store=[];  end          
