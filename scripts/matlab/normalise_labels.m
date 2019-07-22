function [new_class,map]=normalise_labels(class,max_class)
	new_class=class;
	map=zeros(max_class,1);
	class_prime=0;

	for l=1:max_class
		index=find(class==l);
		map(l)=-1;
		if (numel(index) > 0)
			class_prime = class_prime+1;
			map(class_prime)=l;
			new_class(index)=class_prime;
		end
	end

	for l=1:max_class
		fprintf('%d -> %d, numel(l)=%d\n', l, map(l), numel(find(new_class==l)));
	end
end


%function [res,shift,k]=normalise(A)
%	shift=mean2(A);
%	B = A - shift;
%	k=max(abs(max2(B)), abs(min2(B)));
%	res = B / k;
%end
