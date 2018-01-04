function [config, store] = nomafaInit(config)                          
% nomafaInit INITIALIZATION of the expLanes experiment NonnegMatrixFact
%    [config, store] = nomafaInit(config)                              
%      - config : expLanes configuration state                         
%      -- store  : processing data to be saved for the other steps     
                                                                       
% Copyright: <userName>                                                
% Date: 13-Jan-2017                                                    
                                                                       
if nargin==0, NonnegMatrixFact(); return; else store=[];  end          
