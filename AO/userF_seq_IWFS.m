function [flag] = userF_seq_IWFS(~,evt,varargin)
%Summary of this function goes here
%   Detailed explanation goes here




flag = evalin('base','flag');
hSI = evalin('base','hSI');             % get hSI from the base workspace

%get variables
CM_Zern = flag.AO.CM_Zern;
Zernical_State = hSI.AO.Zernical_State;
dm = hSI.AO.dm;

if  hSI.loopAcqCounter == hSI.acqsPerLoop % if acquisition is at end
    
    Loop = hSI.loopAcqCounter;
    Z_order = hSI.AO.Zernical_State(Loop,2);
    Z_order = NaN;
    Z_step =  0;


else % get current aquisition number and the corresponding DM shape to apply
    Loop = hSI.loopAcqCounter +2;
    Z_order = hSI.AO.Zernical_State(Loop,2);
    Z_step =  hSI.AO.Zernical_State(Loop,3);

end




if hSI.AO.last_Zern == Z_order

   % disp('no zernike mode switch')

else

  % evalute metric function to find maxima  --> updates Zern_vector 
    IMetric_Scanimage_seq_IWS

        
    if Zernical_State(Loop,1)~ 0 % if new Iteration starts
        
        Zernical_State = hSI.AO.Zernical_State;
        Amp_step = flag.AO.Iteration.Amp_step;
        Zern_vec = hSI.AO.Zern_vec;
        N_new_amp = flag.AO.Iteration.N_Amp;
        N_Zern = length(flag.AO.corr_Zernical);
        new_amp = repmat(Zern_vec(flag.AO.corr_Zernical),[1,flag.AO.Iteration.N_Amp]);
        
        % finde the maximum amplitude for each mode 
        DM_max_amp = flag.AO.DM_max_amp([flag.AO.corr_Zernical]);
   
        % calculate the new Amplitude values for the next iteration
        if flag.AO.Iteration.N_Amp == 3

            Step_M = [Amp_step 0 -Amp_step]
            Step_M = repmat(Step_M,[size(new_amp,1),1]); 

        elseif flag.AO.Iteration.N_Amp ==5
            
            Step_M = [-2 -1 0 1 2];
            Step_M = repmat(Step_M,[size(new_amp,1),1]);
            DM_max_amp_M = repmat(DM_max_amp,[size(Step_M,2),1])';
            
            Step_M = Step_M.*DM_max_amp_M*Amp_step;
               

        end

        new_amp = new_amp+Step_M; % new Zern amplitude for next iteration 
        
        if flag.AO.defocus % if defocus is used
                
            idx_defocus = find(flag.AO.corr_Zernical ==3);
            defocus_range = linspace(-flag.AO.defocus_range,flag.AO.defocus_range, N_new_amp)*flag.AO.DM_max_amp(3);
            defocus_range = repmat(defocus_range,length(idx_defocus),1);
            new_amp([idx_defocus],:) = defocus_range;

        end
        
        % update hSI.AO
        idx_new_amp = find(~new_amp);
        new_amp(idx_new_amp) = 1e-3;
        n_amp = reshape(new_amp', [],1); % new amplitude vector which needs to be updated in zern file 
        Zernical_State(Loop:Loop+N_Zern*N_new_amp-1,3) = n_amp;
        Z_step =  Zernical_State(Loop,3);
        hSI.AO.Zernical_State = Zernical_State;
        hSI.AO.Zern_vec_Iterations(:,Zernical_State(Loop,1)-1) = Zern_vec;
        hSI.AO.Iteration = hSI.AO.Iteration +1;
    end

    hSI.AO.last_Zern = Z_order;
    disp('analysis')


end

% Get Zern_vector 
Zern_vec = hSI.AO.Zern_vec;

if ~isnan(Z_order)
    Zern_vec(Z_order,1) = Z_step;
end



% remove focus shift by adding defocus on DM
if flag.AO.focus_shift.state

        % add your function with DM
end

% remove focus shift by adding defocus on DM
if flag.AO.focus_shift.state_stage

        % add your function with stage 
end


hSI.AO.Zern_vec =  Zern_vec; % update object 

pattern_1D = Zern_vec'*CM_Zern;
updateAlpao(dm, pattern_1D) % send pattern to DM


fprintf('Zernical is : %d .\n', hSI.AO.Zernical_State(Loop,2));
fprintf('Amplitude is : %d .\n', hSI.AO.Zernical_State(Loop,3));

if  hSI.loopAcqCounter == hSI.acqsPerLoop % if acquisition is at end parameters are saved

    hSI.AO.Zern_vec_Iterations(:,end) = Zern_vec;
    
    filepath = hSI.hScan2D.logFilePath;
    name = hSI.hScan2D.logFileStem;
    AqcCount = sprintf( '%05d', hSI.hScan_LinScanner.logFileCounter-hSI.loopAcqCounter);
    savename = strcat(name, '_', AqcCount , '_',hSI.AO.analysis,'_','results', '.mat');
    savepath = fullfile(filepath, savename);
    Zern_vec_Iterations = hSI.AO.Zern_vec_Iterations;
    save(savepath, 'Zern_vec_Iterations','Zernical_State')
    
    %% Reset the mirror (send zeros) 
    dm.Reset();

     
end

hSI.hScan2D.trigIssueSoftwareAcq 
  



end

