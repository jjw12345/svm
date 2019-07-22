function [wopt,copt,gopt]=optimal_weights(data,class,weights,max_class,file,bench_info,err_type,problem_type)
	fprintf(file,'finding optimal weights\n');
	wopt=ones(max_class,1); copt=1;gopt=1/size(data,2);
	train_data=data; test_data=[]; train_class=class; test_class=[]; predict_class=class; weight=wopt; %class1_w=0.5;

	classification=strcmp(problem_type, 'classification');
	if classification
		%[minclass_cnt, minclass]=find_minority(class, yes_class);
		%if  minclass_cnt <= 1 fprintf(file,'number of labels of class %d is zero',yes_class); return; end

		%predict_size=numel(class);
		%minclass_w=1-minclass_cnt/predict_size;
		%if minclass==1 class1_w=minclass_w; else class1_w=1-minclass_w;end;
		%fprintf(file,'minclass_cnt=%d predict_size=%d miclass_w=%.2f class1_w=%.2f\n', minclass_cnt, predict_size, minclass_w,class1_w);

		%weight(1)=class1_w; weight(2)=1-weight(1);
		for i=1:max_class
			class_cnt(i) = numel(find(class == i));
		end
		class_cnt=class_cnt/numel(class);
		
	end
	best_loss=intmax;best_gp=-1;gopt=-1;best_cp=-1;copt=-1;best_total_error=1;wopt=weight;
	fields=2; indices=crossvalind('kfold', class,fields);
	prop=bench_info{1};catid=bench_info{2};catsize=bench_info{3};scores=bench_info{4};
	train_data=cell(fields,1); train_class=cell(fields,1); train_weights=cell(fields,1); test_data=cell(fields,1); test_class=cell(fields,1); test_bench_info=cell(fields,1);
	for k=1:fields
		test_ind=(indices==k); train_ind=~test_ind;
		train_data{k}=data(train_ind,:);train_class{k}=class(train_ind);train_weights{k}=weights(train_ind);
		test_data{k}=data(test_ind,:);test_class{k}=class(test_ind);test_bench_info{k}={prop(test_ind,:),catid(test_ind,:),catsize,scores{test_ind,:}};
	end

	wstep=0.05; wprec=0.01;
	for cp=-6:6 
		for gp=-6:6
			for i=-10:1:10
				for j=-10:1:10
					weight=calc_weight(class_cnt,i,j,max_class,wstep);
					cont=0;
					for k=1:max_class if (weight(k) < wprec || weight(k) > 1-wprec) cont=1; continue; end; end
					if cont continue; end
					c=2.^cp; g=2.^gp;
					stotal_error=0; sloss=0;
					smispredicted=zeros(max_class,1);
	
					for k=1:fields
						[loss,total_error,mispredicted]=loss_func(...
							weight,c,g,train_data{k},train_class{k},train_weights{k},...
							test_data{k},test_class{k},test_bench_info{k},max_class,...
							err_type,problem_type);
%					fprintf(file,'test %d: loss=%.2f total_error=%d minority_error=%d mispredicted=%d+%d/%d+%d\n',...
%						k,loss,total_error,minority_error,mispredicted(1),mispredicted(2),...
%						numel(find(class(test_ind)==1)),numel(find(class(test_ind)~=1)));

						stotal_error=stotal_error+total_error;
						sloss=sloss+loss;
						smispredicted=smispredicted+mispredicted;
					end % for k=1:fields
					total_error=stotal_error/fields; loss=sloss/fields; mispredicted=smispredicted;
%					fprintf(file,'test: g=%.2f c=%.2f w=%.2f sloss=%.2f stotal_error=%d sminority_error=%d mispredicted=%d+%d/%d+%d\n',...
%						g,c,weight(1),sloss,stotal_error,sminority_error,smispredicted(1),smispredicted(2),...
%						numel(find(class==1)),numel(find(class~=1)));

					if loss < best_loss || (loss==best_loss && total_error<best_total_error) || ...
						(loss==best_loss && best_gp*best_gp+best_cp*best_cp>= gp*gp+cp*cp)

						wopt=weight;
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
				end %for j=-10:wstep:10
				if ~classification continue; end
				if max_class == 2 continue; end
			end %for i=-10:wstep:10
			if ~classification continue; end
		end %for gp=-6:6
	end % for cp=-6:6
	fprintf(file,'\nOptimal weights:\nw=%s c=%.5f g=%.5f loss=%.2f\n',...
		mat2str(wopt,2),copt,gopt,best_loss);
%	fprintf(file,'finished the optimisation, exitflag=%d\n',exitflag);
end

function [loss,total_error,mispredicted]=loss_func(...
	weight,c,g,train_data,train_class,train_weight,test_data,test_class,...
	test_bench_info,max_class,err_type,problem_type)

	if (numel(test_class)==0) predict_class=train_class; else predict_class=test_class; end;
	predict_size=numel(predict_class);
	[min_class_cnt,min_class] = find_minority(predict_class,1);

	model = svm_binary_train(train_data,train_class,train_weight,...
		c,g,weight,max_class,problem_type);

	[loss,predicted_labels, prob_estimates, mispredicted]=svm_binary_classify(...
		model,test_data,test_class,test_bench_info,max_class,err_type,problem_type);

	total_error=numel(find(predicted_labels~=test_class))/numel(test_class);

	%fprintf('weights=[%.2f %.2f], c=%.2f, g=%.2f loss=%.2f\n', weight(1), weight(2), c, g, loss);
end

%	data_size=size(data,1);
%	train_size=round(0.66*data_size);

%	while true
%		perm=transpose(randperm(data_size));
%		data_perm=data(perm,:);
%		class_perm=class(perm);
%		weights_perm=weights(perm);

%		train_data=data_perm(1:train_size,:); test_data=data_perm(train_size+1:end,:);
%		train_class=class_perm(1:train_size); test_class=class_perm(train_size+1:end);
%		train_weights=weights_perm(1:train_size); test_weights=weights_perm(train_size+1:end);

		%fprintf(file,'data: %dx%d, class: %dx%d, perm:%dx%d weight:%dx%d', size(data,1), size(data, 2),...
		%	size(class, 1), size(class, 2), size(perm,1), size(perm,2),size(weights,1),size(weights,2));

%		[minclass_cnt, minclass] = find_minority(test_class, yes_class);
%		if minclass_cnt > 0 break; end;
%	end

function w=calc_weight(class_cnt,i,j,max_class,step)
	if max_class == 2
		w(1)=class_cnt(1)+i*step;
		w(2)=1-w(1);
	elseif max_class == 3
		w(1)=class_cnt(1)+i*step;
		w(2)=class_cnt(2)+j*step;
		w(3)=1-w(1)-w(2);
	else
		fprintf('unexpected max_class: %d\n',max_class);
		exit;
	end
end
