function data=shift_and_scale(data,shift,scale)
	for j=1:size(data,2)
		data(:,j)=data(:,j)-shift(j);
		data(:,j)=data(:,j)*scale(j);
	end
end
