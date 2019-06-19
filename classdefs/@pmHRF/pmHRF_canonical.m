classdef pmHRF_canonical <  pmHRF
    % This is "friston" implementation of the Hemodynamic Response Function
    % Friston et al (1994)
    %
    % Syntax:
    %      hrf = friston();
    %
    % Inputs:
    %
    % Outputs:
    %
    % Optional key/value pairs:
    %
    % Description
    %
    % See also
    %    boyntonHIRF
    
    % Examples
    %{
       
    %}
    
    
    % TODO: copy somewhere above
    % Inputs:
    %   t:  Temporal samples
    %   parms:  Parameters for the Friston function.  Default is from
    %           Friston-Worsley
    %
    %Brief description:
    %
    %
    % Example:
    %    t = 0:0.1:15
    %    [hirf, params] = fristonHIRF(t);
    %    plot(t,hirf);
    %    xlabel('Time (sec)'); ylabel('Relative amp'); grid on;
    %
    
    %
    
    
    
    properties (GetAccess=public, SetAccess=public)
        params;
        values;
    end
    
    properties (GetAccess=public, SetAccess=private)
        Type;
    end
    
    
    %%
    methods
        % Constructor
        function hrf = pmHRF_canonical(pm,varargin)
            % <stimDuration> is the duration of the stimulus in seconds.
            %            must be a multiple of 0.1.
            % <tr> is the TR in seconds.
            
            % Create default params struct.
            params.stimDuration = pm.TR;
            % Read the inputs
            varargin = mrvParamFormat(varargin);
            p = inputParser;
            p.addRequired('pm',@(x)(isa(x,'prfModel')));
            p.addParameter('params',params,@isstruct);
            p.addParameter('duration',20,@isnumeric);
            p.parse(pm, varargin{:});
            % Assign it
            params   = p.Results.params;
            Duration = p.Results.duration;
            
            % Initialize the pm model and hrf model parameters
            hrf.PM       = pm;
            hrf.Type     = 'canonical';
            hrf.Duration = Duration;
            hrf.params   = params;
        end
        
        
        function compute(obj)
            % average empirical HRFs from various datasets (where the HRFs were
            % in response to a 3-s stimulus) and then do the requisite
            % deconvolution and convolution to obtain a predicted HRF to a
            % stimulus of duration <duration>, with data sampled at a TR of <tr>.
            %
            % the resulting HRF is a row vector whose first point is
            % coincident with stimulus onset.  the HRF is normalized such
            % that the maximum value is one.  note that if <duration> is
            % small, the resulting HRF will be quite noisy.
            %
            % example:
            % hrf = getcanonicalhrf(4,1);
            % figure; plot(0:length(hrf)-1,hrf,'ro-');
            
            % load HRFs from five datasets and then take the average.
            % these were the empirical response to a 3-s stimulus, TR 1.323751 s
            % hrf = mean(catcell(2,getsamplehrf([9 10 11 12 14],1)),2)';  % 1 x time
            % store a hard copy for speed
            hrf    = [0 0.0314738742235483 0.132892311247317 0.312329209862644 0.441154423620173 0.506326320948033 0.465005683404153 0.339291735120426 0.189653785392583 0.0887497190889423 0.0269546540274463 -0.00399259325523179 -0.024627314416849 -0.0476309054781231 -0.0550487226952204 -0.0533213710918957 -0.0543354934559645 -0.053251015547776 -0.0504861257190311 -0.0523878049128595 -0.0480250705100501 -0.0413692129609857 -0.0386230204112975 -0.0309582779400724 -0.0293100898508089 -0.0267610584328128 -0.0231531738458546 -0.0248940860170463 -0.0256090744971939 -0.0245258893783331 -0.0221593630969677 -0.0188920336851537 -0.0205456587473883 -0.0230804062250214 -0.0255724832493459 -0.0200646133809936 -0.0101145804661655 -0.014559191655812];
            trorig = 1.323751;
            
            
            % Obtain the parameters for this instance
            duration = obj.params.stimDuration;
            tr       = obj.TR;
            
            
            % resample to 0.1-s resolution
            % GLU: added the condition for 1.82. Generalize it for other cases. 
            trnew = 0.1;
            if tr==1.82
                trnew=0.02;
            end
            hrf = interp1((0:length(hrf)-1)*trorig,hrf,0:trnew:(length(hrf)-1)*trorig,'PCHIP');
            
            % deconvolve to get the predicted response to 0.1-s stimulus
            hrf = deconvolvevectors(hrf,ones(1,3/trnew));
            
            % convolve to get the predicted response to the desired stimulus duration
            hrf = conv(hrf,ones(1,duration/trnew));
            
            % resample to desired TR
            hrf = interp1((0:length(hrf)-1)*trnew,hrf,0:tr:(length(hrf)-1)*trnew,'PCHIP');
            
            % make the peak equal to one
            hrf = hrf / max(hrf);
            
            % Add it to the output
            obj.values = hrf;
            
            
        end
    end
    
end




% This is the getcanonicalhrf.m function from knkutils
%{
    function hrf = getcanonicalhrf(duration,tr)

    % function hrf = getcanonicalhrf(duration,tr)
    %
    % <duration> is the duration of the stimulus in seconds.
    %   must be a multiple of 0.1.
    % <tr> is the TR in seconds.
    %
    % average empirical HRFs from various datasets (where the HRFs were
    % in response to a 3-s stimulus) and then do the requisite 
    % deconvolution and convolution to obtain a predicted HRF to a 
    % stimulus of duration <duration>, with data sampled at a TR of <tr>.
    %
    % the resulting HRF is a row vector whose first point is 
    % coincident with stimulus onset.  the HRF is normalized such 
    % that the maximum value is one.  note that if <duration> is 
    % small, the resulting HRF will be quite noisy.
    %
    % example:
    % hrf = getcanonicalhrf(4,1);
    % figure; plot(0:length(hrf)-1,hrf,'ro-');

    % load HRFs from five datasets and then take the average.
    % these were the empirical response to a 3-s stimulus, TR 1.323751 s
    % hrf = mean(catcell(2,getsamplehrf([9 10 11 12 14],1)),2)';  % 1 x time
      % store a hard copy for speed
    hrf = [0 0.0314738742235483 0.132892311247317 0.312329209862644 0.441154423620173 0.506326320948033 0.465005683404153 0.339291735120426 0.189653785392583 0.0887497190889423 0.0269546540274463 -0.00399259325523179 -0.024627314416849 -0.0476309054781231 -0.0550487226952204 -0.0533213710918957 -0.0543354934559645 -0.053251015547776 -0.0504861257190311 -0.0523878049128595 -0.0480250705100501 -0.0413692129609857 -0.0386230204112975 -0.0309582779400724 -0.0293100898508089 -0.0267610584328128 -0.0231531738458546 -0.0248940860170463 -0.0256090744971939 -0.0245258893783331 -0.0221593630969677 -0.0188920336851537 -0.0205456587473883 -0.0230804062250214 -0.0255724832493459 -0.0200646133809936 -0.0101145804661655 -0.014559191655812];
    trorig = 1.323751;

    % resample to 0.1-s resolution
    trnew = 0.1;
    if tr==1.82
        trnew=0.02;
    end
    hrf = interp1((0:length(hrf)-1)*trorig,hrf,0:trnew:(length(hrf)-1)*trorig,'PCHIP');

    % deconvolve to get the predicted response to 0.1-s stimulus
    hrf = deconvolvevectors(hrf,ones(1,3/trnew));

    % convolve to get the predicted response to the desired stimulus duration
    hrf = conv(hrf,ones(1,duration/trnew));

    % resample to desired TR
    hrf = interp1((0:length(hrf)-1)*trnew,hrf,0:tr:(length(hrf)-1)*trnew,'PCHIP');

    % make the peak equal to one
    hrf = hrf / max(hrf);
%}