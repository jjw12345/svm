function [copt,gopt]=optimal_params(data,class,weights,max_class,file,...
	bench_info,err_type,problem_type,wopt)

	fprintf(file,'finding optimal params\n');

	predict_class=class; 
	best_loss=intmax;best_gp=-1;gopt=-1;best_cp=-1;copt=-1;
	best_total_error=1;

	fields=2; indices=crossvalind('kfold', class,fields);
	train_data=cell(fields,1); test_data=cell(fields,1);
	train_class=cell(fields,1); test_class=cell(fields,1); 
	train_weights=cell(fields,1);
	test_bench_info=cell(fields,1);

	prop=bench_info{1};
	catid=bench_info{2};
	catsize=bench_info{3};
	scores=bench_info{4};

	for k=1:fields
		test_ind=(indices==k); train_ind=~test_ind;
%		fprintf('size(indices)=%d\n',size(indices,1))
		train_data{k}=data(train_ind,:); test_data{k}=data(test_ind,:);
		train_class{k}=class(train_ind); test_class{k}=class(test_ind);
		train_weights{k}=weights(train_ind);
		
		test_bench_info{k} = {prop(test_ind,:),catid(test_ind,:),...
			catsize,scores(test_ind,:)};
	end

	for cp=-6:6 
		for gp=-6:6
			c=2.^cp; g=2.^gp;
			stotal_error=0; sloss=0;
			smispredicted=zeros(max_class,1);
	
			for k=1:fields
				[loss,total_error,mispredicted]=loss_func(wopt,c,g,...
					train_data{k},train_class{k},train_weights{k},...
					test_data{k},test_class{k},test_bench_info{k},...
					max_class,err_type,problem_type);

%				fprintf(file,['test %d: loss=%.2f total_error=%d ' ...
%					'minority_error=%d mispredicted=%d+%d/%d+%d\n'],...
%					k,loss,total_error,minority_error,mispredicted(1),...
%					mispredicted(2),numel(find(class(test_ind)==1)),...
%					numel(find(class(test_ind)~=1)));

				stotal_error=stotal_error+total_error;
				sloss=sloss+loss;
				smispredicted=smispredicted+mispredicted;
			end % for k=1:fields

			total_error=stotal_error/fields;
			loss=sloss/fields;
			mispredicted=smispredicted;

%			fprintf(file,['test: g=%.2f c=%.2f w=%.2f sloss=%.2f ' ...
%				'stotal_error=%d sminority_error=%d ' ...
%				'mispredicted=%d+%d/%d+%d\n'], g,c,weight(1),sloss,...
%				stotal_error,sminority_error,smispredicted(1),...
%				smispredicted(2), numel(find(class==1)),...
%				numel(find(class~=1)));

			if loss < best_loss ||...
				(loss==best_loss && total_error<best_total_error) || ...
				(loss==best_loss && ...
					best_gp*best_gp+best_cp*best_cp>= gp*gp+cp*cp)

				best_gp=gp;gopt=2.^gp;
				best_cp=cp;copt=2.^cp;

				if (loss < best_loss)
					fprintf(file,'w=%s c=%.5f g=%.5f loss=%.2f',...
						mat2str(wopt,2),copt,gopt,loss);

					fprintf(file,' mispredict: %s/%d+%d+%d=%d\n', ...
						mat2str(mispredicted), ...
						numel(find(predict_class==1)),...
						numel(find(predict_class==2)),...
						numel(find(predict_class==3)),...
						total_error*100);
				end

				best_loss=loss; best_total_error=total_error;
			end
		end %for gp=-6:6
	end % for cp=-6:6

	fprintf(file,'\nOptimal params:\nc=%.5f g=%.5f loss=%.2f\n',...
		copt,gopt,best_loss);

%	fprintf(file,'finished the optimisation, exitflag=%d\n',exitflag);
end
