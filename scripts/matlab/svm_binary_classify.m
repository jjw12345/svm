function [err, predicted_labels, prob_estimates, mispredicted]=svm_binary_classify(...
	model,test_data,test_class,test_bench_info,max_class,err_type,problem_type)
	
try	
	prob_estimates=ones(size(test_data,1), 1);
	mispredicted=zeros(max_class,1);

	%def_eps=0.001; eps=0.1*c; if (def_eps < eps) eps=def_eps; end;
	if strcmp(problem_type,'classification')
%		if numel(unique(train_class))==1
%			predicted_labels=ones(numel(test_class),1);
%			elem=unique(train_class);
%			for i=1:numel(test_class) predicted_labels(i)=elem;end
%		else
%	    	param=sprintf('-c %.7f -g %.7f -h 1 -q -b 1 -e %.7f', c, g, eps);
			%yes_ind=find(train_class)==yes_class; no_ind=find(train_class~=yes_class);
			%train_weight(yes_ind)=train_weight(yes_ind)*w(1); train_weight(no_ind)=train_weight(no_ind)*w(2);
%			fprintf('test_data: %dx%d, test_class: %dx%d\n',...
%				size(test_data,1),size(test_data,2),size(test_class,1),size(test_class,2));
%			for i=1:max_class
%				ind=find(test_class == i);
%				fprintf('numel(%d)=%d\n',i,numel(ind));
%				train_weight(ind) = train_weight(ind) * w(i);
%			end
%			for i=1:10
%				fprintf('test_class[%d]=%d ',i,test_class(i));
%			end
%			fprintf('\n');
%			model=svmtrain(train_weight,train_class, train_data, param);

			param1='-b 1';
%			[dummy nr_class]=evalc('svm_get_nr_class(model)');
%			fprintf('model.nr_class=%d\n', model.nr_class);
			if model.nr_class == 1
				label=model.Label(1);
				predicted_labels=zeros(numel(test_class),1);
				predicted_labels(:)=label;
				prob_estimates=ones(numel(test_class),1);
			else
	    		[dummy predicted_labels accuracy, prob_estimates_all]=evalc('svmpredict(test_class, test_data, model, param1)');
				if (numel(predicted_labels) ~= size(test_data,1)) || ...
					(size(prob_estimates_all,1) ~= size(test_class,1))
					fprintf('numel(predicted_labels)=%d, size(prob_estimates_all)=%d, err_msg=%s\n',...
						numel(predicted_labels), size(prob_estimates_all), dummy);
				else
					for j=1:size(prob_estimates_all,1)
						prob_estimates(j)=prob_estimates_all(j,find(model.Label==predicted_labels(j)));
						if (prob_estimates(j) < 0.001)
							fprintf('zero prob_estimates: j=%d prob_estimates_all(j)=%s model_labels=%d predicted_label=%d\n',...
							j, mat2str(prob_estimates_all(j,:)), mat2str(model.Label), predicted_labels(j));
						end
					end

					assert (size(prob_estimates_all,1) == size(test_class,1));
					%disp(prob_estimates_all);
				end
			end
			assert(numel(predicted_labels) == size(test_data,1),'invalid size of predicted_labels returned from svmpredict');
			%disp(prob_estimates);
%		end
	elseif strcmp(problem_type, 'regression')
%		param=sprintf('-s 3 -c %.7f -g %.7f -h 1 -q -b 1 -e %.7f', c, g, eps);
%		model=svmtrain(train_weight,train_class, train_data, param);
		param1='-b 1';
   		[dummy predicted_labels accuracy, prob_estimates]=evalc('svmpredict(test_class, test_data, model, param1)');
		assert(numel(predicted_labels) == size(test_data,1),'invalid size of predicted_labels returned from svmpredict');
	end

	for i=1:max_class
		mispredicted(i)=numel(find(predicted_labels~=test_class & predicted_labels == i));
	end

	if strcmp(problem_type,'regression')
		assert(size(accuracy,1)>=2);
		err=accuracy(2);
	elseif strcmp(err_type,'total_error')
		total_error=numel(find(predicted_labels~=test_class))/numel(test_class);
		err=total_error;
	elseif strcmp(err_type,'weighted_sum')
		err=0;
		for i=1:max_class
%			loss=loss+w(i)*log(1+exp(-2*dot(test_class,prediction_labels)));
			num_i=numel(find(test_class==i));
			if (num_i > 0) err=err+mispredicted(i)/num_i; end
		end
	elseif strcmp(err_type,'svcomp_score')
		err=-svcomp_score(test_bench_info,predicted_labels);
	elseif strcmp(err_type, 'none')
		err=0;
	end

	%fprintf('svm_binary_classify(): err=%.7f\n',err);
%	fprintf('mispredicted: %d+%d/%d+%d=%.2f, minority_error=%.2f\n', ...
%		mispredicted(1), mispredicted(2),numel(find(strcmp(test_class,'YES'))),...
%		numel(find(strcmp(test_class,'NO'))),total_error,minority_error);

catch ME
	error('exception in svm_binary_classify:%s',ME.message);
end
end
