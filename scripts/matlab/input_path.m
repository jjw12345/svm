function abs_path=full_path(rel_path,input)
	abs_path=[ getenv('SVM_INPUT_DIR') '/' rel_path];
end
