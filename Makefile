DO_TASKS:=task_1

BASEDIR:=${CURDIR}
RSCRIPT_EXE:=/usr/bin/Rscript

STUDENTS_FILE:=$(BASEDIR)/students.tsv
TOOLSDIR:=$(BASEDIR)/tools
CONFFILE:=$(TOOLSDIR)/validator.config
CONFFILE_ENV:=$(addsuffix .env, $(CONFFILE))
CONFFILE_ENVWIN:=$(addsuffix .env_win, $(CONFFILE))

SOLUTIONS:=$(addsuffix _sol, $(DO_TASKS))
TEST:=$(addsuffix _test, $(DO_TASKS))

$(info creating tasks $(DO_TASKS))

all: taskfiles solutionfiles

taskfiles: $(CONFFILE) $(DO_TASKS)

solutionfiles: $(CONFFILE) taskfiles $(SOLUTIONS)

test: $(CONFFILE) solutionfiles $(TEST)

$(DO_TASKS):
	python3 $(TOOLSDIR)/create_packages.py $(STUDENTS_FILE) $(BASEDIR)/$@.tsv $(CONFFILE)

$(SOLUTIONS):
	cd $(@:_sol=) && python3 $(TOOLSDIR)/make_solutions.py $(CONFFILE)

$(TEST):
	cd $(@:_test=) && python3 $(TOOLSDIR)/run_tests.py $(CONFFILE)

ifeq ($(OS),Windows_NT)
$(CONFFILE): $(CONFFILE_ENVWIN)
	powershell -command "$$Env:BASEDIR = '$(BASEDIR)'; $$Env:RSCRIPT_EXE = '$(RSCRIPT_EXE)'; Get-Content $< | foreach { [System.Environment]::ExpandEnvironmentVariables($$_) } | Set-Content -path $@"
else
$(CONFFILE): $(CONFFILE_ENV)
	BASEDIR="$(BASEDIR)" RSCRIPT_EXE="$(RSCRIPT_EXE)" envsubst < $< > $@
endif
