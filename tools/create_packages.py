#!/usr/bin/env python3

import os
import csv
import re
from datetime import datetime
from pathlib import Path
import configparser
import random

def read_task_description(task_file, taskdescriptiondir):
  out=''
  with open(Path(taskdescriptiondir, task_file).resolve(), 'r') as _f:
    for line in _f:
      out += '\n# ' + line.strip()
  return out

def read_task_db(taskdb):
  db = {}
  with open(taskdb) as _db:
    db = csv.DictReader(_db, delimiter="\t")
    db = list(db) # convert to list of dicts
  return db

def sample_tasks_for_competencies(task_config_file, taskdb, config):
  indices = []
  with open(task_config_file, 'r') as _tsv:
    db = csv.DictReader(_tsv, delimiter='\t')
    for line in db:
      tasks = [t for t in taskdb if t['competency'] == line['competency']]
      k = int(line['n_tasks'])
      l = len(tasks)
      if k < l:
        indices += random.sample(range(l), k=k)
      elif k==l:
        indices += range(l)
  return indices

def create_solution_file(identifier, indices, taskdb, solfile, config):
  out = ''
  n_points = 0
  for idx,i in enumerate(indices):
    task = taskdb[i]
    fun_name = task['function']
    fun_sig = task['signature']
    fun_points = task['points']
    n_points += int(fun_points)
    fun_task = read_task_description(task['task'], config.get('R_TASKS_DESCRDIR'))
    out += f"# Task {idx+1}:\n# {fun_points} Points{fun_task}\n#\n# Do NOT change the following line\n{fun_name} <- {fun_sig}{{\n  # Add your solution here\n  \n}}\n\n"
  with open(solfile, 'w') as _sol:
    timestamp = datetime.strftime(datetime.now(),'%Y-%m-%d')
    print(f"################################\n# DO NOT MODIFY THIS BLOCK!\n# id: {identifier}\n# created: {timestamp}\n# achievable score: {n_points}\n# DO NOT MODIFY THIS BLOCK! \n################################\n\n", file=_sol)
    print(out, file=_sol)

def load_source_file(fun_test, fun_task, fun_file, config, indent=2):
  content = None
  with open (config.get('BASE_TEST_CALL'), 'r' ) as _testf:
    content = (' '*indent).join(_testf.readlines())
    content = re.sub('@FUN_TEST@', fun_test, content, flags=re.M)
    content = re.sub('@FUN_CALL@', fun_task, content, flags=re.M)
    with open(Path(config.get('R_TESTS_SOURCEDIR'), fun_file), 'r') as _f:
      tmp = ''.join(_f.readlines())
      tmp = tmp.rstrip('\n').replace('\n', '\n'+' '*(indent+2))
      content = re.sub('@TESTS@', tmp, content, flags=re.M)
    # ~ content = content.rstrip('\n').replace('\n', '\n'+' '*indent)
  return content.rstrip('\n')

def prepare_sandboxed_inline_test(funcname, func, indent=2):
  ind = ' '*indent
  return f"{ind}sandbox${func}\n{ind}environment(sandbox${funcname}) <- sandbox\n"

def create_test_file(indices, taskdb, solfile, outdir, config):
  # ~ test_files = '","'.join([taskdb[i]['checkr'] for i in indices])
  test_sources = ''
  test_functions = []
  r_functions = []
  for i in indices:
    f = taskdb[i]['function']
    ftest = f'test.{f}'
    src = load_source_file( ftest, f+'()', taskdb[i]['checkr'], config)
    test_sources += prepare_sandboxed_inline_test(ftest, src) + '\n'
    test_functions.append( ftest )
    r_functions.append( f'{f}' )
  test_functions = '","'.join(test_functions)
  r_functions = '","'.join(r_functions)
  with open(config.get('BASE_TEST_R'), 'r' ) as _testf:
    content = _testf.read()
  content_new = re.sub('###ADD_SOURCES_HERE###', test_sources, content, flags=re.M)
  content_new = re.sub('###ADD_TEST_FUNCTIONS_HERE###', test_functions, content_new, flags=re.M)
  content_new = re.sub('###ADD_R_FUNCTIONS_HERE###', r_functions, content_new, flags=re.M)
  content_new = re.sub('###NUM_TESTCASES###', str(len(indices)), content_new, flags=re.M)
  with open(Path(outdir, 'test.R'), 'w') as _out:
    print(content_new, file=_out)

def write_out_task_ids_for_student(taskdb, task_config, outfile):
  with open(outfile, 'w') as _f:
    print("competency\tpoints\tfunction\tsolution_file", file=_f)
    for t in task_config:
      c = taskdb[t]['competency']
      fun = taskdb[t]['function']
      sol = taskdb[t]['checkr']
      p = taskdb[t]['points']
      print(f"{c}\t{p}\t{fun}\t{sol}", file=_f)

def pack_student(student, task_config, taskdb, config):
  p = Path(config.get('outdir'), student)
  p.mkdir(parents=True, exist_ok=True)
  sol_file = Path(p,'task.R')
  create_solution_file(student, task_config, taskdb, str(sol_file.resolve()), config)
  create_test_file(task_config, taskdb, str(sol_file.resolve()), str(p.resolve()), config)
  write_out_task_ids_for_student(taskdb, task_config, Path(p, 'tasks.tsv'))

def init_config(config_file):
  c = configparser.ConfigParser()
  c.read(config_file)
  return c['VALIDATOR']

def main(students, tasks, config='validator.config'):
  config = init_config(config)
  config['outdir'] = str(Path(os.getcwd(), Path(tasks).stem).resolve())
  
  taskdb = read_task_db(config.get('TASK_DB'))
  with open(students, 'r') as _tsv:
    db = csv.DictReader(_tsv, delimiter='\t')
    for line in db:
      # sample tasks for student
      taskconfig = sample_tasks_for_competencies(tasks, taskdb, config)
      pack_student(line['id'], taskconfig, taskdb, config)
  

if __name__=='__main__':
  import plac
  plac.call(main)