ifndef TASK
$(error TASK is not set)
else
	DO_TASKS:=$(TASK)
endif

ifdef STUDENT
	DO_STUDENT:=$(STUDENT)
endif

ifdef USE_BASEDIR
	BASEDIR:=$(USE_BASEDIR)
else
	BASEDIR:=${CURDIR}
endif

ifdef USE_TASKDBDIR
	BASEDIR_TASKDB:=$(USE_TASKDBDIR)
else
	BASEDIR_TASKDB:=$(BASEDIR)
endif

ifdef USE_TASKDESCRDIR
	BASEDIR_TASKDESCR:=$(USE_TASKDESCRDIR)
else
	BASEDIR_TASKDESCR:=$(BASEDIR)
endif

ifdef USE_STUDENTS_DB
	STUDENTS_DB:=$(USE_STUDENTS_DB)
else
	STUDENTS_DB:=$(BASEDIR)/students.tsv
endif


STUDENTS_FILE:=$(BASEDIR)/students.tmp.tsv
TOOLSDIR:=$(BASEDIR)/tools
CONFFILE:=$(TOOLSDIR)/validator.config
CONFFILE_ENV:=$(addsuffix .env, $(CONFFILE))
CONFFILE_ENVWIN:=$(addsuffix .env_win, $(CONFFILE))
RSCRIPT_EXE:=/usr/bin/Rscript
SOLUTIONS:=$(addsuffix _sol, $(DO_TASKS))
TEST:=$(addsuffix _test, $(DO_TASKS))

$(info creating tasks $(BASEDIR_TASKDESCR)/$(DO_TASKS))

.PHONY: $(DO_TASKS)
.INTERMEDIATE: $(STUDENTS_FILE)

all: taskfiles solutionfiles

taskfiles: $(CONFFILE) $(DO_TASKS)

solutionfiles: $(CONFFILE) taskfiles $(SOLUTIONS)

test: $(CONFFILE) solutionfiles $(TEST)

$(DO_TASKS): $(STUDENTS_FILE)
	python3 $(TOOLSDIR)/taskfiles.py $(STUDENTS_FILE) $(BASEDIR_TASKDESCR)/$@.tsv $(CONFFILE)

$(SOLUTIONS):
	cd $(@:_sol=) && python3 $(TOOLSDIR)/solutionfiles.py $(CONFFILE)

$(TEST):
	cd $(@:_test=) && python3 $(TOOLSDIR)/run_tests.py $(CONFFILE)

ifndef $(DO_STUDENT)
$(STUDENTS_FILE):
	cp $(STUDENTS_DB) $@
else
$(STUDENTS_FILE):
	$(shell head -n1 $(STUDENTS_DB) > $@ && grep "$(DO_STUDENT)" $(STUDENTS_DB) >> $@ )
endif

ifeq ($(OS),Windows_NT)
$(CONFFILE): $(CONFFILE_ENVWIN)
	powershell -command "$$Env:BASEDIR = '$(BASEDIR)'; "$$Env:BASEDIR_TASKDB = '$(BASEDIR_TASKDB)'; $$Env:RSCRIPT_EXE = '$(RSCRIPT_EXE)'; Get-Content $< | foreach { [System.Environment]::ExpandEnvironmentVariables($$_) } | Set-Content -path $@"
else
$(CONFFILE): $(CONFFILE_ENV)
	BASEDIR="$(BASEDIR)" BASEDIR_TASKDB="$(BASEDIR_TASKDB)" RSCRIPT_EXE="$(RSCRIPT_EXE)" envsubst < $< > $@
endif
