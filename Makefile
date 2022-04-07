BASEDIR=${CURDIR}

TASKS_FILE=$(BASEDIR)/task_1.tsv
RSCRIPT_EXE=/usr/bin/Rscript

STUDENTS_FILE=$(BASEDIR)/students.tsv
TOOLSDIR=$(BASEDIR)/tools
CONFFILE=$(TOOLSDIR)/validator.config
CONFFILE_ENV=$(addsuffix .env, $(CONFFILE))
CONFFILE_ENVWIN=$(addsuffix .env_win, $(CONFFILE))
TASKBASENAME=$(notdir $(TASKS_FILE))
TASKDIR=$(TASKBASENAME:$(suffix $(TASKBASENAME))=)

$(info creating tasks from $(TASKS_FILE) to $(TASKDIR))

all: taskfiles solutionfiles tests

taskfiles: $(CONFFILE)
	python3 $(TOOLSDIR)/create_packages.py $(STUDENTS_FILE) $(TASKS_FILE) $(CONFFILE)

solutionfiles: taskfiles $(CONFFILE)
	cd $(TASKDIR) && python3 $(TOOLSDIR)/make_solutions.py $(CONFFILE)

tests: solutionfiles $(CONFFILE)
	cd $(TASKDIR) && python3 $(TOOLSDIR)/run_tests.py $(CONFFILE)


ifeq ($(OS),Windows_NT)
$(CONFFILE): $(CONFFILE_ENVWIN)
	powershell -command "$$Env:BASEDIR = '$(BASEDIR)'; $$Env:RSCRIPT_EXE = '$(RSCRIPT_EXE)'; Get-Content $< | foreach { [System.Environment]::ExpandEnvironmentVariables($$_) } | Set-Content -path $@"
else
$(CONFFILE): $(CONFFILE_ENV)
	BASEDIR="$(BASEDIR)" RSCRIPT_EXE="$(RSCRIPT_EXE)" envsubst < $< > $@
endif
