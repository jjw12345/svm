function [minclass_cnt, minclass]=find_minority(class, yes_class)
	class1_cnt=numel(find(class==yes_class)); class2_cnt=numel(find(class~=yes_class));
	class_cnts=[class1_cnt, class2_cnt];
	[minclass_cnt, minclass] = min(class_cnts);
%	fprintf('find_minority. class 1: %d instances, class 2: %d instances, total instances: %d minclass_cnt=%d minclass=%d\n', class1_cnt, class2_cnt, numel(class), minclass_cnt, minclass);
end
