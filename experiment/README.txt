% This is the README for the experiment NonnegMatrixFact
                                                        
% Created on 13-Jan-2017 by gloaguen                    
                                                        
% Purpose:                                              
                                                        
% Reference:                                            
                                                        
% Licence:                                              
                                                        
                                                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Getting started with your experiment based on expLanes          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Please have a look at the Config file. It allows you to set the general
% configuration parameters.
% 

% Next, please have a look at the Factors file. It allows you to set the
% specific parameters that need to be set and tested for every
% configurations of your algorithm under evaluation.

% More information can be found in the documentation of expLanes:

% https://github.com/mathieulagrange/expLanes/blob/gh-pages/doc/expLanesDocumentation.pdf

This experience estimates the traffic sound levels of simulated sound mixtures with the help of different versions of NMF. 

First download the expLanes tool (https://github.com/mathieulagrange/expLanes)
Then download the sound database (https://sandbox.zenodo.org/record/176695#.Wk4eeXkiGos) which contains all the sound mixtures and the audio files useful to build the dictionary and decompress the folder.

NonnegMatrixFact folder allows the estimation of the traffic sound level by supervised and semi-supervised NMF.
NMFThreshold folder allows the estimation of the traffic sound level by Threshold Initialized NMF.