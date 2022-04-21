#!/usr/bin/env python3

import os
import csv
import re
from datetime import datetime
from pathlib import Path
import configparser
import random

def read_task_description(fun_name, fun_competency, taskdescriptiondir):
  out=''
  with open(Path(taskdescriptiondir, fun_competency, fun_name+'.txt').resolve(), 'r') as _f:
    for line in _f:
      out += '\n# ' + line.strip()
  return out

def read_gap_body(fun_name, fun_competency, base_dir, indent=2):
  out=' '*indent
  delim = ' '*indent
  with open(Path(base_dir, fun_competency, fun_name+'.R').resolve(), 'r') as _f:
    out = ' '*indent + delim.join(_f.readlines())
  return out.rstrip()

def read_task_db(taskdb):
  db = {}
  with open(taskdb) as _db:
    db = csv.DictReader(_db, delimiter="\t")
    db = list(db) # convert to list of dicts
  for t in db:
    if t['has_gap_body'] != '':
      t['has_gap_body'] = True
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
        w = random.sample(range(l), k=k)
      elif k==l:
        w = range(l)
      for idx in w:
        indices.append(next((index for (index, d) in enumerate(taskdb) if d["function"] == tasks[idx]['function']), None))
  return indices

def create_task_file_for_student(identifier, indices, taskdb, solfile, config):
  out = ''
  n_points = 0
  for idx,i in enumerate(indices):
    task = taskdb[i]
    fun_name = task['function']
    fun_sig = task['signature']
    fun_points = task['points']
    fun_example_call = task['stdparams']
    fun_competency = task['competency']
    n_points += int(fun_points)
    fun_task = read_task_description(fun_name, fun_competency, config.get('R_TASKS_DESCRDIR'))
    if task['has_gap_body']:
      fun_body = read_gap_body(fun_name, fun_competency, config.get('R_TASKS_BODYDIR'), indent=2)
    else:
      fun_body = '  # Add your solution here\n  '
    out += f"# Task {idx+1}:\n# {fun_points} Points{fun_task}\n#\n# Do NOT change the following line\n{fun_name} <- {fun_sig}{{\n{fun_body}\n}}\n{fun_name}({fun_example_call})\n\n"
  with open(solfile, 'w') as _sol:
    timestamp = datetime.strftime(datetime.now(),'%Y-%m-%d')
    print(f"################################\n# DO NOT MODIFY THIS BLOCK!\n# id: {identifier}\n# created: {timestamp}\n# achievable score: {n_points}\n# DO NOT MODIFY THIS BLOCK! \n################################\n\n", file=_sol)
    print(out, file=_sol)

def split_std_params(params):
  if ',' in params:
    def handle_assignment(assgnm):
      return assgnm.strip().replace('=',' <- ')
    out = ''
    last_param = ''
    ignore_comma = False
    for char in params:
      if char in ['"', '(', "'"]:
        ignore_comma = True
      elif ignore_comma and char in ['"', ')', "'"]:
        ignore_comma = False
      
      if not ignore_comma and char == ',':
        out += handle_assignment(last_param) + '\n'
        last_param = ''
      else:
        last_param += char
    return out + handle_assignment(last_param)
  else:
    return params

def load_source_file(fun_test, taskdb_entry, config, indent=2):
  fun_task = taskdb_entry['function']+taskdb_entry['signature'].replace('function','')
  fun_file = Path(taskdb_entry['competency'], taskdb_entry['function']+'.R')
  
  base_call = ''
  with open (config.get('BASE_TEST_CALL'), 'r' ) as _testf:
    # ~ base_call = (' '*indent).join(_testf.readlines())
    base_call = ''.join(_testf.readlines())
    base_call = re.sub('@FUN_CALL@', fun_task, base_call, flags=re.M)
    base_call = base_call.rstrip('\n')
  
  just_call = True
  tests = ''
  with open(Path(config.get('R_TESTS_SOURCEDIR'), fun_file), 'r') as _f:
    tests = ''.join(_f.readlines())
    # ~ tests = tmp.rstrip('\n').replace('\n', '\n'+' '*(indent+2))
    if '@CALL@' in tests:
      tests = tests.replace('@CALL@', base_call)
      if '@STD_PARAMS@' in tests:
        params = split_std_params(taskdb_entry['stdparams'])
        tests = tests.replace('@STD_PARAMS@', params)
      tests = tests.rstrip('\n')
      just_call = False
  
  content = f"{fun_test} <- function(){{\n"
  if just_call:
    content += ' '*(indent+2) + base_call.replace('\n', '\n'+' '*(indent+2))+ '\n'
  content += ' '*(indent+2) + tests.rstrip('\n').replace('\n', '\n'+' '*(indent+2)) + '\n'+ ' '*indent + '}'
  content = content.replace('@FNAME@', taskdb_entry['function'])
  return content.rstrip('\n')

def prepare_sandboxed_inline_test(funcname, func, indent=2):
  ind = ' '*indent
  return f"{ind}sandbox${func}\n{ind}environment(sandbox${funcname}) <- sandbox\n"

def create_test_file(indices, taskdb, solfile, outdir, config):
  test_sources = ''
  test_functions = []
  r_functions = []
  for i in indices:
    f = taskdb[i]['function']
    ftest = f'test.{f}'
    src = load_source_file( ftest, taskdb[i], config)
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
    print("competency\tpoints\tfunction", file=_f)
    for t in task_config:
      c = taskdb[t]['competency']
      fun = taskdb[t]['function']
      p = taskdb[t]['points']
      print(f"{c}\t{p}\t{fun}", file=_f)

def pack_student(student, task_config, taskdb, config):
  p = Path(config.get('outdir'), student)
  p.mkdir(parents=True, exist_ok=True)
  sol_file = Path(p,'task.R')
  create_task_file_for_student(student, task_config, taskdb, str(sol_file.resolve()), config)
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
