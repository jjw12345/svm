function [data,shift,scale_k]=normalise(data,colnames)
	cols=size(data, 2);
	scale_k=zeros(1,cols);
	shift=min(data);

	for j=1:cols
		data(:,j)=data(:,j)-shift(j);
		maxel=max(data(:,j));
		if maxel ~= 0	
			scale_k(j)=1/maxel;
			data(:,j)=data(:,j)*scale_k(j);
		else
			fprintf('column %s: shift=%.2f normalise=%.2f\n', colnames{j,:},shift(j),scale_k(j));
		end
	end
end


%function [res,shift,k]=normalise(A)
%	shift=mean2(A);
%	B = A - shift;
%	k=max(abs(max2(B)), abs(min2(B)));
%	res = B / k;
%end
