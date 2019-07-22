if ~isdeployed
	scripts_dir=getenv('MATLAB_SCRIPTS_DIR')
	addpath([scripts_dir '/libsvm-weights/matlab'])
	addpath(scripts_dir)
	addpath([scripts_dir '/run'])
end

answers_file=getenv('SVM_ANS_PREFIX');
tool_num=str2num(getenv('SVCOMP_TOOLS_NUM'));
max_class=3;
svcomp=getenv('SVCOMP');
model_file=getenv('MODEL_NAME');

output_dir=getenv('SVM_OUTPUT_DIR');
if ~exist(output_dir, 'dir')
	mkdir(output_dir);
end

fprintf('output_dir=%s svcomp=%s answers_file=%s\n',...
	output_dir, svcomp, answers_file);

p=getenv('SVM_INPUT_DIR');
fprintf('cd %s\n', p);
cd(p);

predict_output(answers_file,tool_num,max_class,'classification',...
	model_file, output_dir);
