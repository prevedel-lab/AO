% main script 
% set all parameters in scanimge and initilize aquisition 
% here you need to define your DM 

clearvars -except hSI hSICtl 
close all

%set path 
% Add that folder plus all subfolders to the path.
addpath(genpath('AO'));

%%%


%%DM Alpao
% Determine where your m-file's folder is.
% Add 'Wrapper' folder to Matlab path
addpath( 'C:\Program Files\Alpao\SDK\Samples\Matlab\Wrapper\' );
addpath( 'D:\Alpao\Example\Config' );
addpath( 'D:\Alpao\Example' );
%%%

% Connect the mirror
serialName = 'BAX410';
% Load configuration file
dm = asdkDM( serialName );

% Load matrix Zernike to command matrix
% in NOLL's order without Piston in µm RMS
Z2C = importdata( [serialName '-Z2C.mat'] ); % load your Z2C matrix

%% no further specifications needed 

flag.AO.CM_Zern = Z2C;
% get parameter settings
set_parameters

% generate Zernical look up table for aquisition
[flag] = GeneZernState;

%set scanimage parameters
assert(strcmpi(hSI.acqState,'idle'));   % make sure scanimage is in an idle state
% hSI.acqsPerLoop = Num_Loop;
hSI.hScan2D.logAverageFactor = 1;
hSI.acqsPerLoop = size(hSI.AO.Zernical_State,1);
hSI.hStackManager.numSlices = 1;


%set hSI AO 
hSI.AO.dm = dm;
hSI.AO.Zern_vec_Iterations = zeros(size(flag.AO.CM_Zern,1),flag.AO.Iteration.rounds);
hSI.AO.last_Zern = hSI.AO.Zernical_State(2,2);
hSI.AO.Motor_position_start = hSI.hMotors.motorPosition ;
hSI.AO.Iteration = 1;
hSI.AO.Zern_vec = zeros(size(flag.AO.CM_Zern,1),1);
hSI.AO.Zern_vec_start = hSI.AO.Zern_vec;

%% Send zeros to the DM
dm.Reset( );

disp('mirror was set to flat')

% start Loop image aquisition
clearvars -except hSI hSICtl flag dm 

hSI.startLoop();                        % start the loop
hSI.hScan2D.trigIssueSoftwareAcq    % generate software trigger 


   


