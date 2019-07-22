if ~isdeployed
	scripts_dir=getenv('MATLAB_SCRIPTS_DIR');
	addpath([scripts_dir '/libsvm-weights/matlab'])
	addpath(scripts_dir)
	addpath([scripts_dir '/run'])
end

svm_path=getenv('SVM_INPUT_DIR');
answers_file=getenv('SVM_ANS_PREFIX');
weights_file='ans_weightsnorm_by_score_time';
tool_num=str2num(getenv('SVCOMP_TOOLS_NUM'));
max_class=3;
err_type='svcomp_score';
ex=getenv('EX');
scores_file='num_scores';
catid_file='svcomp_cats';
svcomp=['svcomp' getenv('SVCOMP')];
model_name=getenv('MODEL_NAME');

matlabpool open;
%fprintf('starting experiment %d\n',ex);
%fprintf('svm_path=%s svcomp=%s\n',svm_path, svcomp);

SVM_PATH=input_path(['ex' ex '/']);
%fprintf('cd %s\n', SVM_PATH);
cd(SVM_PATH);

output_dir=output_path(['ex' ex '/']);
if ~exist(output_dir, 'dir')
	mkdir(output_dir);
end

model_file=[output_dir model_name];

create_model(answers_file,weights_file,tool_num,max_class,...
	'classification',err_type,scores_file, catid_file,...
	model_file,output_dir);

predict_output(answers_file,tool_num,max_class,'classification',...
	model_file,output_dir);

matlabpool close;
%fprintf('finishing experiment %d,time elapsed=%d sec\n',ex, timei);
