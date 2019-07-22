function res=predict_output(data_file, tool_num, max_class,...
	problem_type,model_file,output_dir)

	[test_data, test_class, names1, test_files]=read_svm_input(...
		[data_file '_test'],false);

	test_data_bu = test_data;
	test_size=size(test_files,1);
	scores=zeros(test_size, tool_num);

%	fprintf(['data_file=%s\nmodel_file=%s\noutput_dir=%s\n' ...
%		'test_data: %dx%d, test_class:%dx%d'],...
%		data_file,model_file,output_dir, ...
%		size(test_data,1),size(test_data,2), ...
%		size(test_class,1),size(test_class,2));

	parfor tool=0:tool_num-1
		%fprintf('started tool %d\n',tool);

		[model,train_shift,train_scale] = load_data(...
			[model_file '_' num2str(tool) '.mat']);
		test_data=shift_and_scale(test_data_bu,train_shift,train_scale);

		file = open_file([output_dir '/' data_file '_test_log_' ...
			 num2str(tool)], 'wt+');

		[err, predicted_labels,prob_estimates, mispredicted]=...
			svm_binary_classify(model,test_data,test_class,{},...
			max_class,'none',problem_type);

%		fprintf(file, ['mispredicted: %s/%d+%d+%d=%.2f%%\n' ... 
%			'numel(predicted_labels)=%d\n'], ...
%			mat2str(mispredicted),numel(find(test_class==1)),...
%			numel(find(test_class==2)),numel(find(test_class==3)),...
%			numel(find(predicted_labels~=test_class))/ ...
%				numel(test_class)*100,...
%			numel(predicted_labels));

		predicted_labels_file=open_file([output_dir '/' data_file ...
			 '_predictions_' num2str(tool)], 'wt+');

		for j=1:numel(predicted_labels)
			fprintf(predicted_labels_file, '%d\n', predicted_labels(j));
		end;
		fclose(predicted_labels_file);

		if strcmp(problem_type,'classification')
			prob_estimates_file=open_file([output_dir '/' data_file ...
				 '_prob_estimates_' num2str(tool)], 'wt+');

			for j=1:numel(prob_estimates)
				fprintf(prob_estimates_file, '%f\n', prob_estimates(j));
			end
			fclose(prob_estimates_file);
		end

		fclose(file);
%		fprintf('finished tool %d\n',tool);
	end
	res=0;
end

function file = open_file(filename, mode)
	[file,errmsg]=fopen(filename, mode);
	if file < 0
		fprintf('unable to open file %s: %s', filename, errmsg);
	end
end

function [model, train_shift, train_scale] = load_data(filename)
	dims = load(filename, 'model','train_shift','train_scale');
	model = dims.model;
	train_shift = dims.train_shift;
	train_scale = dims.train_scale;
end
