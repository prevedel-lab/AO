function obj = update_DM(dm, pattern_1D)  % must be 1D array with real actrator number
            
          if  length(pattern_1D(:)) ~= 140
              error('pattern varable must be a one D array and size of 140!');
              return;
          end

          
          pattern_1D = pattern_1D - median(pattern_1D) + 0.5;  % always normalize DM pattern
          
          pattern_1D(pattern_1D>1) = 1;
          pattern_1D(pattern_1D<0) = 0;
          BMCSendData(dm, pattern_1D);


end