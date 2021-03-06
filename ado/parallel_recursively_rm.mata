
mata

/*
 *@brief Recursively removes parallel tmpfiles
 *@param parallelid Id of the parallel process to clean
 *@param path Path where to search for auxiliary files
 */
void function parallel_recursively_rm(string scalar parallelid ,| string scalar path, real scalar atomic, real scalar rmlogs)
{
	if (path==J(1,1,"")) path = pwd()
	else if (!regexm(path,"[/\]$")) path = path+"/"

	// display("{hline}{break}Entering folder "+path)
	
	if (atomic == J(1,1,.)) atomic = 0
	if (rmlogs == J(1,1,.)) rmlogs = 0
	
	string scalar pattern
	if (!atomic) pattern = "__pll"+parallelid+"_*"
	else pattern = "*"

	string colvector dirs
	string colvector files

	/* Listing files */
	dirs  = dir(path,"dirs",pattern,1)
	files = dir(path,"files",pattern,1)\dir(path,"files","l"+pattern,1)
	
	real scalar i, retcode
	if (atomic)
	{
		for(i=1;i<=length(files);i++){
			retcode = _unlink(files[i])
			if (retcode !=0){
				stata("sleep 2000")
				_unlink(files[i])
			}
		}
	}
	else
	{
		/* We don't want to remove logfiles in tmpdir */
		for(i=1;i<=length(files);i++)
			if ( !regexm(files[i],"do[0-9]+\.log$") | rmlogs){
				retcode = _unlink(files[i])
				if (retcode !=0){
					stata("sleep 2000")
					_unlink(files[i])
				}
			}
	}

	/* Entering each folder */
	for(i=1;i<=length(dirs);i++)
		parallel_recursively_rm(parallelid, dirs[i], 1)

	/* Removing empty folders */
	for(i=1;i<=length(dirs);i++){
		retcode = _rmdir(dirs[i])
		if (retcode !=0){
			stata("sleep 2000")
			_rmdir(dirs[i])
		}
	}


	return
}

end
