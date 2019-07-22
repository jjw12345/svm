function bench_info=get_bench_info(files,catid_file)

	csize=size(files,1);
	prop=zeros(csize,1);
	CATS=get_cats();
	catsize=zeros(size(CATS,1));

	for j=1:csize
		filename=strtrim(files(j,:));
		prop(j)=get_prop(filename);
	end

%	fprintf('catid_file=%s\n', catid_file);
	[catid,~,~]=tblread(catid_file,' ');

	[fullcatid,~,~]=tblread('../svcomp_cats_0');
	for j=1:size(CATS,2)
		catsize(j)=numel(find(fullcatid==j));
		%fprintf('cat %s, size=%d\n', CATS{j}, catsize(j));
	end

	bench_info={prop,catid,catsize};
end

function cats=get_cats()
	cats=strsplit(getenv('SVCOMP_CATS'));
end

function prop = get_prop(filename)
	true_ind=strfind(filename,'_true');
	false_ind=strfind(filename, '_false');

	prop = (numel(false_ind)==0 || (numel(false_ind) > 0 && ...
			numel(true_ind) > 0 && true_ind(1) < false_ind(1)));
end
