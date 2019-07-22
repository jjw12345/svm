function features=read_features(features_filename, tool)
	file=[features_filename '_' num2str(tool)];
	data=tdfread(file, ' '); %importdata(file, ' ');
	%pwd
	features=data.('features');
