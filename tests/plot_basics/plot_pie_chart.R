checkSourceContains("pie(","used base pie function",fname="@FNAME@")
checkSourceContains("main *=","assigned a title",fname="@FNAME@", fixed=F) 
checkSourceContains("labels *=","assigned labels",fname="@FNAME@", fixed=F)
files_before <- list.files(path=".")
@STD_PARAMS@
@CALL@
files_after <- list.files(path=".")
new_files <- setdiff(files_after, files_before)
file.remove(new_files)
checkTrue("Rplots.pdf" %in% new_files, "Plot created (inside Rplots.pdf)")
