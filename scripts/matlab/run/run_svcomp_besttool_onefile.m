if ~isdeployed
	scripts_dir=getenv('MATLAB_SCRIPTS_DIR')
	addpath([scripts_dir '/libsvm-weights/matlab'])
	addpath(scripts_dir)
	addpath([scripts_dir '/run'])
end

predict_besttool(getenv('SVM_ANS_PREFIX'), '', ...
	str2num(getenv('SVCOMP_TOOLS_NUM')),...
	output_path(''),...
	getenv('ANS_PREDICTION'), input_path(''));
