function new_class=apply_labels_norm(class,class_map)
	new_class=class;
	for l=1:numel(class_map)
		index=find(class==l)
		new_class(index)=class_map(l);
	end
end
