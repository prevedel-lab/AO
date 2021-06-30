function [Image] = load_tiff_scanImage_IWS( filepath, name, AqcCountStart, Channel, hSI, flag);
%LOAD_TIFF Summary of this function goes here
%   Detailed explanation goes here

numSlices = hSI.hStackManager.numSlices;
frames = hSI.hStackManager.framesPerSlice;
Avg = hSI.hScan2D.logAverageFactor;

AqcCount = sprintf( '%05d', AqcCountStart );


if hSI.AO.Iteration == 1
    Modulation_total = flag.AO.Zern_Nstep;
else
    Modulation_total = flag.AO.Iteration.N_Amp;
end

AcqNumber = str2double(AqcCount);

% save imaging parameters totalAquisitions, frames, slices, avg, zoom,
% Channels, Number Zernical modes, number mode amplitude
    for kf = 1:Modulation_total
    
        try
        Acqstring = sprintf( '%05d', AcqNumber );

        fname = strcat(name, '_', Acqstring, '.tif');
        ffname = fullfile(filepath, fname);

        % set image size properties
        InfoImage=imfinfo(ffname);
        mImage=InfoImage(1).Width;
        nImage=InfoImage(1).Height;
        NumberImages=length(InfoImage);


                for jk=1:NumberImages
                   Image_Stack(:,:,jk)=imread(ffname,'Index',jk,'Info',InfoImage);
                end




        if hSI.hStackManager.numSlices ==1  % if only one slice

            if length(hSI.hChannels.channelSave) == 2 % average and channel for 2 channels

                Image_CH1 = Image_Stack(:,:,1:2:end);
                Image_CH2 = Image_Stack(:,:,2:2:end);

                    if Channel == 1
                        Image_single = Image_CH1;
                    else
                        Image_single = Image_CH2;
                    end


            elseif length(hSI.hChannels.channelSave) == 1

                Image_single = Image_Stack;
 
            end

% image post processing



       if flag.Img_Analysis.Kernal_median

            for jf= 1:size(Image_single,3)

                Image_single(:,:,jf) = medfilt2(Image_single(:,:,jf),[flag.Img_Analysis.Kernal_size, flag.Img_Analysis.Kernal_size],'symmetric');

            end

        end

        Image_single = mean(Image_single,3);

        Image(:,:,kf) = Image_single;
        
        AcqNumber = AcqNumber +1;
     end

    catch 
        disp('error ocurred : Error using rtifc TIFF library error - TIFFFetchDirectory:  Can not read TIFF directory count.')

    end
end

