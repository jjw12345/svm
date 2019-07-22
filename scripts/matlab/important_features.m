function res=important_features(data, class, weight, names, max_class,...
		file,bench_info,err_type,problem_type)
	colnum=size(data,2);
	%$res=linspace(1,colnum, colnum);
	copt=1;gopt=0.5;
	if strcmp(problem_type, 'classification')
		wopt=ones(max_class,1);
		%for i=1:max_class wopt(i)=numel(find(class==i)); end
		%wopt=wopt/numel(class);
	end

	%fprintf(file, 'data:%dx%d, class:%dx%d, weight:%dx%d, names:%dx%d\n',...
	%	size(data,1),size(data,2),size(class,1),size(class,2),...
	%	size(weight,1),size(weight,2),size(names,1),size(names,2));

	if (strcmp(err_type, 'svcomp_score'))
		crit_precision=1;
	elseif (strcmp(err_type, 'total_error') || strcmp(err_type, 'weighted_sum'))
		crit_precision=0.01;
	else
		fprintf('UNKNOWN err_type\n'); res=linspace(1,colnum, colnum); return;
	end

	[~,excluded]=ismember({'FILE_DESCR','OUTPUT','CHAR','ASSERT_FILE_DESCR','ASSERT_OUTPUT','ASSERT_CHAR'},names,'R2012a');
	excluded=excluded.';
	excluded=excluded(excluded~=0);
	disp(excluded);

	c=copt;g=gopt;
	fprintf(file, 'feature selection\n');
	fprintf('size(data)=%dx%d size(class)=%dx%d size(weight)=%dx%d\n',size(data,1),size(data,2),...
		size(class,1),size(class,2), size(weight,1),size(weight,2));
	colind=linspace(1,colnum,colnum);
	opts = statset('display','iter'); %'UseParallel',true,
	prop=bench_info{1}; catid=bench_info{2}; catsize=bench_info{3}; scores=bench_info{4};
	[inmodel,history]=sequentialfs(...
		@(train_data,train_class,train_weight,train_prop,train_catid,train_scores,test_data,test_class,test_weight,test_prop,test_catid,test_scores)...
			criterion_fun(train_data,train_class,train_weight,test_data,test_class,test_prop,test_catid,catsize,test_scores,c,g,wopt,...
				max_class,err_type,problem_type),data,class,weight,prop,catid,scores,'cv',4,'options',opts,...
				'nfeatures',1, 'keepout', excluded, 'direction', 'backward');%, 'nullmodel', true);
				%FILE_DESCR,OUTPUT,CHAR,ASSERT_...

	[mincrit, mincrit_ind]=min(history.Crit);
	res=find(history.In(mincrit_ind,:)==1);

	for i=1:mincrit_ind
		if i==1
			prev_f=zeros(1,size(history.In,2));
			prev_crit=1;
		else
			prev_f=history.In(i-1,:);
			prev_crit=history.Crit(i-1);
		end
		diff=xor(prev_f,history.In(i,:));
		added=find(diff);
		assert(numel(added)==1 || i==1);

		j=added;
		crit_diff=prev_crit - history.Crit(i);
		if crit_diff < crit_precision
			if i > 1 res = res(res~=added); end;
		else
		%if i==1 || crit_diff > 0
%			if i==1
%				name='Null_Hypothesis';
%			else
				name=names{j,:};
%			end

			%if crit_diff < 1e-3
			%	name=['*' name];
			%end
			fprintf(file,' %s Crit=%.1f\n', name, history.Crit(i));
		end
	end
end

function crit=criterion_fun(train_data,train_class,train_weight,test_data,test_class,test_prop,test_catid,catsize,test_scores,c,g,wopt,...
		max_class,err_type,problem_type)
	test_bench_info={test_prop,test_catid,catsize,test_scores};

	model=svm_binary_train(train_data,train_class,train_weight,...
		c,g,wopt,max_class,problem_type);

	[res]=svm_binary_classify(model,test_data,test_class,test_bench_info,...
		max_class,err_type,problem_type);

	crit=res*size(test_data,1);
	%fprintf('criterion_fun(): crit=%.7f res=%.7f size(test_data,1)=%d\n',crit, res, size(test_data,1));
end
