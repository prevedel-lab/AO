%%% set parameters 


%% set different analysis modes

flag.AO.focus_shift.state = false; % use focus shift correct via defocus on DM. This uses mirror to correct defocus
flag.AO.focus_shift.state_stage = true; % use focus shift correct via motor stage

flag.AO.Channel = 1; % channel ID ; image for metric calculation

% flag Image postprocessing to calcuate image metric 

flag.Img_Analysis.Kernal_median = true;
flag.Img_Analysis.Kernal_size = 7;


%% Zernike modes to be modulated 
% set Zernik mode number & amplitude
flag.AO.Zernike_Coefficients = zeros(1,size(flag.AO.CM_Zern,1));
flag.AO.Zernike_Coefficients([3:5]) = [3:5]; % set modes to be modulated 
flag.AO.defocus_range = [0.05]; % for defocus mode only; set amplitude range

flag.AO.Zern_step = 0.2; % mode amplitude 0 to 1 in percent of maximum amplitude 
flag.AO.Zern_Nstep = 5; % symmetric interval divided by Nsetp is actual step increment

flag.AO.Iteration.rounds = 2; % number of iterations
flag.AO.Iteration.N_Amp = 5; %  number of Nstep increment during iterations; so far only 3 and 5 supported 
flag.AO.Iteration.Amp_step = 0.07; % mode amplitude for iterations; 0 to 1 ; set size left right from maximum relative to min-max range 


%% load function for shift correct
% your function

% load DM max amplitude file 
flag.AO.DM_max_amp = load('D:\Alpao\Example\max_ampl.mat'); % file for normalizing the maximum amplitude command for each Zernike to fit 0-1 range
flag.AO.DM_max_amp = flag.AO.DM_max_amp.max_amp;

% 
[flag.AO.corr_Zernical] = find(flag.AO.Zernike_Coefficients~=0);
