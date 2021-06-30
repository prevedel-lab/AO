function [flag] = GeneZernState()
%GENEZERNSTATE Summary of this function goes here

% generates a look-up table Zernical_State : list which mode and amplitude
% is executed for aquisition n 



    hSI = evalin('base','hSI');             % get hSI from the base workspace
    hSICtl = evalin('base','hSICtl');
    flag = evalin('base','flag');
    
% get numbers   
corr_Zern = flag.AO.corr_Zernical;
Nzern = length(corr_Zern);
Zern_step  = flag.AO.Zern_step; % 0 to 1 
Nampl = flag.AO.Zern_Nstep;
ampl_Mode = linspace(-1,1,Nampl);
ampl_Mode(ampl_Mode ==0) =0.0001;
Nframes = Nzern*Nampl; % total number of frames 

% with defocus 
if sum(corr_Zern==3) ~= 0 % note defocus is mode = 3
    
    defocus_mode = true;
    flag.AO.defocus = true;
    
else
    defocus_mode = false;
    flag.AO.defocus = false;
    
end

% max amplitude of DM to reach -1 1 value command
DM_max_amp = flag.AO.DM_max_amp;


% change order of Zernik mode correction start with spherical Z=10 than coma Z = 6,7 then
% astigmatism Z =4,5

idx_coma = find(ismember(corr_Zern,[6 7])==1);
coma_val = corr_Zern([idx_coma]);
corr_Zern(idx_coma) = [];
corr_Zern = [coma_val corr_Zern];

if defocus_mode
    
    idx_defocus = find(ismember(corr_Zern,[3])==1);
    defocus_val = corr_Zern([idx_defocus]);
    corr_Zern(idx_defocus) = [];
    corr_Zern = [defocus_val corr_Zern];

end

idx_spherical_2 = find(ismember(corr_Zern,[21])==1);
spherical_val_2 = corr_Zern([idx_spherical_2]);
corr_Zern(idx_spherical_2) = [];
corr_Zern = [spherical_val_2 corr_Zern];

idx_spherical = find(ismember(corr_Zern,[10])==1);
spherical_val = corr_Zern([idx_spherical]);
corr_Zern(idx_spherical) = [];
corr_Zern = [spherical_val corr_Zern];

if defocus_mode
    
    corr_Zern = [3 corr_Zern];
    Nzern = length(corr_Zern);
    Nframes = Nzern*Nampl; % total number of frames 

end



flag.AO.corr_Zernical = corr_Zern;
DM_max_amp = DM_max_amp([corr_Zern]);

% change max_amp order
Zernical_State= zeros(Nframes+1,4);
Zernical_State(2,1) = 1;


% Set amplitude  
ampl_Mode = repmat(ampl_Mode',[Nzern,1]);
DM_max_amp = repmat(DM_max_amp,[Nampl,1]);
DM_max_amp = reshape(DM_max_amp,[],1);

ampl_Mode = ampl_Mode.*DM_max_amp.*Zern_step;

% Set Zernik mode
corr_Zern = repmat(corr_Zern,[Nampl,1]);
corr_Zern = reshape(corr_Zern,[],1);
Zernical_State(2:end,2) = corr_Zern;

% set different range for defocus

if defocus_mode
    
    idx_defocus = find(corr_Zern ==3);
    defocus_range = linspace(-flag.AO.defocus_range,flag.AO.defocus_range,Nampl)*flag.AO.DM_max_amp(3);
    defocus_range = repmat(defocus_range,1,length(idx_defocus)/Nampl)';
    ampl_Mode(idx_defocus) = defocus_range ;
    
end

idx_zero = find(ampl_Mode==0);
ampl_Mode(idx_zero) = 0.001;


Zernical_State(2:end,3) = ampl_Mode;

% save imaging parameters totalAquisitions, frames, slices, avg, zoom,

Zernical_State(1,5) = hSICtl.hModel.hRoiManager.scanZoomFactor;
Zernical_State(2,5) = size(hSI.hChannels.channelSave,1);
Zernical_State(3,5) = size(corr_Zern,2);
Zernical_State(4,5) = size(ampl_Mode,2);

% if more then 1 iteration
if flag.AO.Iteration.rounds > 1
 
    corr_Zern = flag.AO.corr_Zernical;
    Nzern = length(corr_Zern);
    Nampl_I = flag.AO.Iteration.N_Amp;

    
    corr_Zern = repmat(corr_Zern,[Nampl_I,1]);
    corr_Zern = reshape(corr_Zern,[],1);
    Iteration_Zern = corr_Zern;
    Iteration_Zern = repmat(Iteration_Zern,[flag.AO.Iteration.rounds-1,1]);
    
    Iteration_Matrix = zeros(length(Iteration_Zern),size(Zernical_State,2));
    Iteration_Matrix(:,2) = Iteration_Zern;
    Zernical_State = [Zernical_State; Iteration_Matrix];
    
    nf = 2;
    for kf = 1: flag.AO.Iteration.rounds -1 
      
      pk = 2+Nzern*Nampl + (kf-1)*Nzern*Nampl_I; 
      Zernical_State(pk,1)  = nf;
      nf = nf+1;
        
    end
    
    
end


hSI.AO.Zernical_State = Zernical_State;
end

