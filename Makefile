BASEDIR=$(shell pwd)

STUDENTS_FILE=$(BASEDIR)/students.tsv
TASKS_FILE=$(BASEDIR)/task_1.tsv

TOOLSDIR=$(BASEDIR)/tools
CONFFILE=$(TOOLSDIR)/validator.config
CONFFILE_ENV=$(addsuffix .env, $(CONFFILE))
TASKBASENAME=$(notdir $(TASKS_FILE))
TASKDIR=$(TASKBASENAME:$(suffix $(TASKBASENAME))=)

$(info compiling $(TASKDIR))

all: packages solutions


packages: $(CONFFILE)
	python3 $(TOOLSDIR)/create_packages.py $(STUDENTS_FILE) $(TASKS_FILE) $(CONFFILE)

solutions: packages
	cd $(TASKDIR) && python3 $(TOOLSDIR)/make_solutions.py $(CONFFILE)

tests:	solutions
	cd $(TASKDIR) && python3 $(TOOLSDIR)/run_tests.py $(CONFFILE)

.INTERMEDIATE: $(CONFFILE)
$(CONFFILE): $(CONFFILE_ENV)
	BASEDIR="$(BASEDIR)" envsubst < $< > $@
