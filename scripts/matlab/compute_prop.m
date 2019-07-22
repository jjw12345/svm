function prop=compute_prop(files)
	csize=size(files,1);
	prop=zeros(csize,1);

	for j=1:csize
		ind=strfind(files(j,:),'_true');
		if numel(ind)>0
			prop(j)=true;
		else
			prop(j)=false;
		end
	end
end
