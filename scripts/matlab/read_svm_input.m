function [data, design, names, files, shift, scale]=read_svm_input(file,labelled)
%	if nargin < 2
 %   	labelled=trues
%	end

	data=tdfread(file, ' '); %importdata(file, ' ');
	names=fieldnames(data); %colheaders;
%	data=struct2cell(data); %data.data

	%delete filename column
	field_num=numel(names);
	files=data.(names{1});
%	files1=files(:,1);
%	for i=1:size(files,1)
%		files1(i)='';
%		for j=1:size(files,2)
%			if files{i,j}=' ' break; end
%			files1(i)=[files1, files{i,j}];	
%		end
%	end

	row_num=numel(data.(names{2}));
	if field_num==2 || not (labelled)
		design=zeros(row_num,1);
		last_field=field_num;
	else
		design=data.(names{field_num});
		last_field=field_num-1;
	end;

	data1=zeros(row_num, last_field-1);
	for loopIndex = 2:last_field
		data1(:,loopIndex-1) = data.(names{loopIndex});
	end
%	data=data(2:size(data, 1), :); %data=data(:,2:size(data,2));
	data=data1;
	names=names(2:last_field);
%	fprintf('names before:\n');
%	disp(names);
	for i=1:size(names,1)
		names(i)=strtrim(names(i,:));
	end
%	fprintf('names after:\n');
%	disp(names);
%	for j=1:size(data,2) fprintf('%.2f ', data(1,j)); end; fprintf('\n');
%	for j=1:size(data,2) fprintf('%.2f ', data(end,j)); end; fprintf('\n');

%	data=data(1:size(data,1)-1, :);
%	data=data{:,:};%zeros(size(data{1},1), size(data,1));

%	for i = 1:size(data,1)
%		data1(:,i)=data{i};
%	end
%	data=data1;
end
