function [loss,total_error,mispredicted]=loss_func(...
	weight,c,g,train_data,train_class,train_weight,test_data,test_class,...
	test_bench_info,max_class,err_type,problem_type)

	if (numel(test_class)==0) predict_class=train_class; else predict_class=test_class; end;
	predict_size=numel(predict_class);
	[min_class_cnt,min_class] = find_minority(predict_class,1);
	model=svm_binary_train(train_data,train_class,train_weight,...
		c,g,weight,max_class,problem_type);
	[loss,predicted_labels, prob_estimates, mispredicted]=svm_binary_classify(...
		model,test_data,test_class,test_bench_info,max_class,err_type,problem_type);

	total_error=numel(find(predicted_labels~=test_class))/numel(test_class);

	%fprintf('weights=[%.2f %.2f], c=%.2f, g=%.2f loss=%.2f\n', weight(1), weight(2), c, g, loss);
end
