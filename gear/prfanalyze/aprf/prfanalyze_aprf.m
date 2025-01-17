function prfanalyze_aprf(opts_file, json_file, bold_file, stim_file, output_dir)
% 
% (C) Vista Lab, Stanford University, 2019
% 
    
%% Initial checks

% If nothing was passed in, display help and return
if nargin == 0
    help_file = '/opt/help.txt';
    if exist(help_file, 'file')
        system(['cat ', help_file]);
    else
        help(mfilename);
    end
    return
end

% Assume the user wanted to see the help, and show it
if ischar(json_file)
    if strcmpi(json_file, 'help') ...
            || strcmpi(json_file, '-help') ...
            || strcmpi(json_file, '-h') ...
            || strcmpi(json_file, '--help')
        help(mfilename);
    end
end


% read in the opts file
if ~isempty(opts_file)
    fprintf('This is the config.json file being read: %s\n',opts_file)
    tmp = loadjson(opts_file);
    disp('These are the contents of the json file:')
    tmp
    if ~isempty(tmp)
        options = struct();
        options.aprf = tmp;
    else
        opts = {};
    end
else
    opts = {};
end

% Check if the hrf comes in rows, make it columns
if size(options.aprf.hrf, 1) < size(options.aprf.hrf, 2)
    options.aprf.hrf = options.aprf.hrf';
end

% Make the output directory
if ~exist(output_dir,'dir');mkdir(output_dir);end


%% check that the other relevant files exist
if exist(bold_file, 'file') ~= 2
    disp(sprintf('Given BOLD 4D nifti file does not exist: %s', bold_file))
    return
end
if exist(stim_file, 'file') ~= 2
    disp(sprintf('Given stimulus 3D nifti file does not exist: %s', stim_file))
    return
end


%% TODO: check that the input stimuli file is [0,1]


%% Call pmModelFit!
[pmEstimates, results] = pmModelFit({bold_file, json_file, stim_file}, 'aprf', 'options',options);

%% Write out the results
estimates_file = fullfile(output_dir, 'estimates.mat');
estimates = struct(pmEstimates);
save(estimates_file, 'estimates', 'pmEstimates');
results_file = fullfile(output_dir, 'results.mat');
save(results_file, 'results');


% Save it as  json file as well
% Select filename to be saved
fname = fullfile(output_dir, ['estimates.json']);
% Encode json
jsonString = jsonencode(pmEstimates);
% Format a little bit
jsonString = strrep(jsonString, ',', sprintf(',\n'));
jsonString = strrep(jsonString, '[{', sprintf('[\n{\n'));
jsonString = strrep(jsonString, '}]', sprintf('\n}\n]'));

% Write it
fid = fopen(fname,'w');if fid == -1,error('Cannot create JSON file');end
fwrite(fid, jsonString,'char');fclose(fid);










% Permissions
fileattrib(output_dir,'+w +x', 'o'); 

return 



