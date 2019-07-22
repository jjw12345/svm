function res=create_model(data_file, weight_file, tool_num, max_class,...
	problem_type, err_type,scores_file,catid_file, model_file,...
	output_dir)

	bestcp=-5; bestgp=1;
	c=2.^bestcp; g=2.^bestgp;

	[train_data, train_class, feature_names, train_files]=...
		read_svm_input([data_file '_0_train'],true);

	[train_scores,~,~]=tblread(([scores_file '_0_train']),' ');
	train_bench_info=get_bench_info(train_files, [catid_file '_0_train']);

	parfor tool = 0:tool_num-1
		fprintf('training a model for tool %d\n',tool);

		[train_data, train_class, feature_names, train_files]=...
			read_svm_input([data_file '_' num2str(tool) '_train'],true);

		[train_data, train_shift, train_scale] = ...
			normalise(train_data,feature_names);

		[train_weight, train_weight_class, train_names, train_files2] = ...
			read_svm_input([weight_file  '_' num2str(tool) '_train'],true);
	
		file = fopen([output_dir data_file '_train_log_' num2str(tool)], ...
			 'wt+');
		
		train_bench_info_i={train_bench_info{1},train_bench_info{2},...
			train_bench_info{3},train_scores(:,tool+1)};

		[copt,gopt] = optimal_params(train_data, train_class, ...
			train_weight, max_class, file,train_bench_info_i, ...
			err_type,problem_type, ones(max_class,1));
	
		c=copt;g=gopt;
		wopt=ones(max_class,1);
		fprintf(file,'training tool %d...\n', tool);

		model = svm_binary_train(train_data,train_class,train_weight,...
			c,g,wopt,max_class,problem_type);

		save_data(model, train_shift, train_scale, ...
			[model_file '_' num2str(tool) '.mat']);

		fclose(file);
	end
	res=0;
end

function res = save_data(model, train_shift, train_scale, filename)
	save(filename, 'model','train_shift','train_scale');
end
