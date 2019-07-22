function model=svm_binary_train(...
	train_data,train_class,train_weight,c,g,w,max_class,problem_type)
	
try	
	def_eps=0.001; eps=0.1*c; if (def_eps < eps) eps=def_eps; end;
	if strcmp(problem_type,'classification')
%		if numel(unique(train_class))==1
%			predicted_labels=ones(numel(test_class),1);
%			elem=unique(train_class);
%			for i=1:numel(test_class) predicted_labels(i)=elem;end
%		else
	    	param=sprintf('-c %.7f -g %.7f -h 1 -b 1 -e %.7f -q', c, g, eps);
			param1='-b 1';
			for i=1:max_class
				ind=find(train_class == i);
				train_weight(ind) = train_weight(ind) * w(i);
			end
%			fprintf('param=%s train_weight=%dx%d, train_class=%dx%d, train_data=%dx%d\n',param, size(train_weight,1),size(train_weight,2),...
%				size(train_class,1),size(train_class,2),size(train_data,1),size(train_data,2))
   			model=svmtrain(train_weight,train_class, train_data, param);
%			fprintf('param=%s\n',param)


%    		[dummy predicted_labels accuracy, prob_estimates_all]=evalc('svmpredict(test_class, test_data, model, param1)');
%			assert(numel(predicted_labels) == size(test_data,1),'invalid size of predicted_labels returned from svmpredict');

%			assert (size(prob_estimates_all,1) == size(test_class,1));
%			for j=1:size(prob_estimates_all,1)
%				prob_estimates(j)=prob_estimates_all(j,find(model.Label==predicted_labels(j)));
%				if (prob_estimates(j) < 0.001) fprintf('zero prob_estimates: j=%d prob_estimates_all(j)=%s model_labels=%d predicted_label=%d\n',...
%					j, mat2str(prob_estimates_all(j,:)), mat2str(model.Label), predicted_labels(j));
%				end
%			end

			%disp(prob_estimates_all);
			%disp(prob_estimates);
%		end
	elseif strcmp(problem_type, 'regression')
		param=sprintf('-s 3 -c %.7f -g %.7f -h 1 -q -b 1 -e %.7f', c, g, eps);
		param1='-b 1';
   		model=svmtrain(train_weight,train_class, train_data, param);
%		[dummy predicted_labels accuracy, prob_estimates]=evalc('svmpredict(test_class, test_data, model, param1)');
%		assert(numel(predicted_labels) == size(test_data,1),'invalid size of predicted_labels returned from svmpredict');
	end

%	for i=1:max_class
%		mispredicted(i)=numel(find(predicted_labels~=test_class & predicted_labels == i));
%	end

%	if strcmp(problem_type,'regression')
%		assert(size(accuracy,1)>=2);
%		err=accuracy(2);
%	elseif strcmp(err_type,'total_error')
%		total_error=numel(find(predicted_labels~=test_class))/numel(test_class);
%		err=total_error;
%	elseif strcmp(err_type,'weighted_sum')
%		err=0;
%		for i=1:max_class
%			loss=loss+w(i)*log(1+exp(-2*dot(test_class,prediction_labels)));
%			num_i=numel(find(test_class==i));
%			if (num_i > 0) err=err+mispredicted(i)/num_i; end
%		end
%	elseif strcmp(err_type,'svcomp_score')
%		err=-svcomp_score(test_bench_info,predicted_labels);
%	end

	%fprintf('svm_binary_classify(): err=%.7f\n',err);
%	fprintf('mispredicted: %d+%d/%d+%d=%.2f, minority_error=%.2f\n', ...
%		mispredicted(1), mispredicted(2),numel(find(strcmp(test_class,'YES'))),...
%		numel(find(strcmp(test_class,'NO'))),total_error,minority_error);

catch ME
	error('exception in svm_binary_train:%s',ME.message);
end
end
