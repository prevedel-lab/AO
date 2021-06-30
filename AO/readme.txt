The indirect modal-based adaptive optics code runs with scanimage 2016 and the Alpao deformable mirror DM97-15



% modify scanimage file SI.m 
add property AO

% Scanimage 

in Gui 'Main Controls' enable 'Ext Triggering' 
in Gui 'USER FUNCTIONS' enable : Event Name = acq Done ,  User Function = userF_seq_IWFS

% before running the indirect wavefront sensing AO script 
- configure your DM in 'main_IWS'
- define parameters for AO modulation (e.g. number of Zernike modes and amplitude range) in 'set_parameters.m'
- define parameters for Metric calculation in 'IMetric_Scanimage_seq_IWS.m'
    - define Metric, default if mean Intesnity ( flag.MeanI = 1)
    - define fitting function, default is  (fitfun = 'gauss1')
    - define R-square fitting error to reject noisy measurements, default it (flag.threshhold_fit = 0.80)

% run 'main_IWS'

% results are saved in the current filepath folder

filename_AquisitionStart_Imean_results.mat
variable Zern_vec_Iteration lists the optimum mode amplitude for each iteration
variable Zernical_State lists the modulated Zernike mode and corresponding amplitude for each aquisition






