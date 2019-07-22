#!/bin/bash

for file in ${SVM_ANS_PREDICTIONS_NUMBERED}; do 
	toolid=0; 
	for toolname in ${SVCOMP_TOOLS} none; do 
		cmd='s% '${toolid}'% '${toolname}'%'";$cmd"
		let toolid++; 
	done 

	cat ${file} | sed "$cmd"  > ${file}_names; 
done
