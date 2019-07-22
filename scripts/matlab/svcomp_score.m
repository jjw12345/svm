function score=svcomp_score(bench_info,predictions)
	score=0;
	%prop=bench_info{1};
	catid=bench_info{2};
	catsize=bench_info{3};
	scores=bench_info{4};

	for i=1:size(predictions)
		if predictions(i) == 1
		% where the tool is predicted to gove a correct answer
			score=score+scores(i)/catsize(catid(i));
		end
	end
	score=score*mean(catsize);
end
