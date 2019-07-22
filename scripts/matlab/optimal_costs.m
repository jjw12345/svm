function wopt=optimal_costs(data,class,weights,max_class,file,prop,err_type,problem_type,copt,gopt)
	fprintf(file,'finding optimal costs\n');
	wopt=ones(max_class,1);
	train_data=data; test_data=[]; train_class=class; test_class=[]; predict_class=class; weight=wopt; %class1_w=0.5;

	classification=strcmp(problem_type, 'classification');
	if classification
		for i=1:max_class
			class_cnt(i) = numel(find(class == i));
		end
		class_cnt=class_cnt/numel(class);
		
	end
	best_loss=intmax;best_total_error=1;wopt=weight;
	fields=2; indices=crossvalind('kfold', class,fields);
	train_data=cell(fields,1); train_class=cell(fields,1); train_weights=cell(fields,1); test_data=cell(fields,1); test_class=cell(fields,1); test_prop=cell(fields,1);
	for k=1:fields
		test_ind=(indices==k); train_ind=~test_ind;
		train_data{k}=data(train_ind,:);train_class{k}=class(train_ind);train_weights{k}=weights(train_ind);
		test_data{k}=data(test_ind,:);test_class{k}=class(test_ind);test_prop{k}=prop(test_ind,:);
	end

	wstep=0.05; wprec=0.01;
	for i=-10:1:10
		for j=-10:1:10
			weight=calc_weight(class_cnt,i,j,max_class,wstep);
			cont=0;
			for k=1:max_class if (weight(k) < wprec || weight(k) > 1-wprec) cont=1; continue; end; end
			if cont continue; end
			stotal_error=0; sloss=0;
			smispredicted=zeros(max_class,1);
	
			for k=1:fields
				[loss,total_error,mispredicted]=loss_func(...
					weight,copt,gopt,train_data{k},train_class{k},train_weights{k},...
					test_data{k},test_class{k},test_prop{k},max_class,...
					err_type,problem_type);
%			fprintf(file,'test %d: loss=%.2f total_error=%d minority_error=%d mispredicted=%d+%d/%d+%d\n',...
%				k,loss,total_error,minority_error,mispredicted(1),mispredicted(2),...
%				numel(find(class(test_ind)==1)),numel(find(class(test_ind)~=1)));

				stotal_error=stotal_error+total_error;
				sloss=sloss+loss;
				smispredicted=smispredicted+mispredicted;
			end % for k=1:fields
			total_error=stotal_error/fields; loss=sloss/fields; mispredicted=smispredicted;
%			fprintf(file,'test: g=%.2f c=%.2f w=%.2f sloss=%.2f stotal_error=%d sminority_error=%d mispredicted=%d+%d/%d+%d\n',...
%				g,c,weight(1),sloss,stotal_error,sminority_error,smispredicted(1),smispredicted(2),...
%				numel(find(class==1)),numel(find(class~=1)));

			if loss < best_loss || (loss==best_loss && total_error<best_total_error)

				wopt=weight;

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
	fprintf(file,'\nOptimal costs:\nw=%s loss=%.2f\n', mat2str(wopt,2), best_loss);
%	fprintf(file,'finished the optimisation, exitflag=%d\n',exitflag);
end

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
