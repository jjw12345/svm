function res=predict_besttool(answers_file, times_file, tool_num,...
	output_dir,output_file,input_dir) 

	answers0=importdata([output_dir '/' answers_file '_predictions_0']);
	answers=zeros(numel(answers0),tool_num);
	ans_prob=zeros(numel(answers0),tool_num);
	times=zeros(numel(answers0),tool_num);
	%disp(size(answers));
	withtimes=~strcmp(times_file,'');

	for tool=0:tool_num-1
		answersi=importdata([output_dir '/' answers_file '_predictions_' ...
			num2str(tool)]);

		answers(:,tool+1)=transpose(answersi);
		ans_probi=importdata([output_dir '/' answers_file ...
			'_prob_estimates_' num2str(tool)]);

		ans_prob(:,tool+1)=transpose(ans_probi);

		if withtimes
			timesi=importdata([output_dir '/' times_file '_predictions_' ...
				num2str(tool)]);

			times(:,tool+1)=transpose(timesi);
		end
	end

	filename=[input_dir '/' answers_file '_test'];
	fid = fopen(filename);
	if fid == -1 fprintf('unable to open %s\n',filename); exit(1); end
	fgetl(fid); % skip the header of the table
	ofid_pure_ans=fopen([output_dir '/' output_file],'wt+');

	if withtimes
		ofid_wtimes = fopen([output_dir '/tool_choice_' answers_file ...
			'wtimes_pure_ans'],'wt+');
	end

	i=0;
	while true
		filename=strtok(fgetl(fid));
		if (~ischar(filename)) break; end;
		i=i+1;

		answersi=answers(i,:);
		posanswers=find(answersi == 1) - 1;

		if numel(posanswers) > 0
			best_pure_ans=max_prob(posanswers,ans_prob(i,:));
			if (withtimes) best_ans_wtimes=min_time(posanswers, times); end
		else
			best_pure_ans=tool_num;
			if (withtimes) best_ans_wtimes=tool_num; end
		end
		fprintf(ofid_pure_ans, '%s %d\n', filename, best_pure_ans);
		
		if (withtimes)
			fprintf(ofid_wtimes, '%s %d\n', filename, best_ans_wtimes);
		end;
	end
	fclose(ofid_pure_ans);
	if (withtimes) fclose(ofid_wtimes); end
end

function res=max_prob(tools,prob)
	res=-1;
	maxprob=intmin;
	for i=1:numel(tools)
		tool=tools(i);
		if prob(tool+1) > maxprob
			maxprob=prob(tool+1);
			res=tool;
		end
	end
end

function res=min_time(tools,times)
	res=-1;
	mintime=realmax;
	for i=1:numel(tools)
		tool=tools(i);
		if times(tool+1) < mintime
			mintime=times(tool+1);
			res=tool;
		end
	end
end
