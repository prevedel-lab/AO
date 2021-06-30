function [mode_max, max_Metric_val] = fit_Metric_seq_IWS(Zorder,Amplitude_Zorder, Metric_Zorder, N_Zernical, fitfun, flag)

     hSI = evalin('base','hSI');    
     
        if strcmp(fitfun, 'gauss1')
            
            try
                [fitM, gof, opt] = fit(Amplitude_Zorder, Metric_Zorder, fitfun);
                mode_max = fitM.b1;
                
                if mode_max> max(Amplitude_Zorder(:))  || mode_max< min(Amplitude_Zorder(:))
                    
                    [amp, idx] = min(abs(Amplitude_Zorder-mode_max));
                    mode_max = Amplitude_Zorder(idx);
                end
                
                if gof.rsquare < flag.threshhold_fit
                    
                    mode_max = hSI.AO.Zern_vec_Iterations(Zorder,hSI.AO.Iteration);
                    
                end
                
            catch
                
                    mode_max = hSI.AO.Zern_vec_Iterations(Zorder,hSI.AO.Iteration);
                    gof.rsquare = 0.01;
                
            end
                
                     
        elseif strcmp(fitfun, 'poly2')
                fitM = fit(Amplitude_Zorder, Metric_Zorder, fitfun);
                mode_max = - fitM.p2/2/fitM.p1;
                
        elseif strcmp(fitfun, 'smoothingspline')
                fitM = fit(Amplitude_Zorder, Metric_Zorder, fitfun);
                xinterp = [min(Amplitude_Zorder):0.01:max(Amplitude_Zorder)];
                yinterp = feval(fitM,xinterp);
                [ymax xmax] =max(yinterp);
                mode_max = xinterp(xmax);
        elseif strcmp(fitfun, 'gauss2')
                fitM = fit(Amplitude_Zorder, Metric_Zorder, fitfun);
                xinterp = [min(Amplitude_Zorder):0.01:max(Amplitude_Zorder)];
                yinterp = feval(fitM,xinterp);
                [ymax xmax] =max(yinterp);
                mode_max = xinterp(xmax);
            
        else
            disp(' no fit method defined')
        end
        

        
    if gof.rsquare < flag.threshhold_fit

        max_Metric_val = NaN;
        
    elseif ~exist('fitM')
      
        max_Metric_val = NaN;
        
    else
        
        max_Metric_val = fitM(mode_max);
    end

    try
        clear figure(2003); 
        figure(2003); 
        plot(fitM); hold on; 
        plot(Amplitude_Zorder, Metric_Zorder,'o'); 
        hold off

    end
    if gof.rsquare < flag.threshhold_fit

        title(['REJECTED  ', '  - Zernical',num2str(Zorder), ',  R sqart = ' num2str(gof.rsquare)])

    else
        title(['Zernical',num2str(Zorder), ',  R sqart = ' num2str(gof.rsquare)])
        
    end
        
  
end


