#!/usr/bin/env python3

import os
import csv
import re
from datetime import datetime
from pathlib import Path
import random

from checks import check_sheet_requires_tasks_in_functions, init_config
from taskfiles_with_functions import Taskfiles_With_Functions
from taskfiles_no_functions import Taskfiles_No_Functions

def read_task_db(taskdb):
  db = {}
  with open(taskdb) as _db:
    db = csv.DictReader(_db, delimiter="\t")
    db = list(db) # convert to list of dicts
  for t in db:
    if t['has_gap_body'] != '':
      t['has_gap_body'] = True
    if t['depends'] == '':
      t['depends'] = False
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
        indices.append(next((index for (index, d) in enumerate(taskdb) if d["function"] == tasks[idx]['function'] and d['competency'] == tasks[idx]['competency']), None))
  return indices

def main(students, tasks, config='validator.config'):
  _tid = Path(tasks).stem
  config = init_config(config)
  config['outdir'] = str(Path(os.getcwd(), _tid).resolve())
  config['taskid'] = _tid
  taskdb = read_task_db(config.get('TASK_DB'))
  with open(students, 'r') as _tsv:
    db = csv.DictReader(_tsv, delimiter='\t')
    for line in db:
      # sample tasks for student
      taskconfig = sample_tasks_for_competencies(tasks, taskdb, config)
      if check_sheet_requires_tasks_in_functions(taskconfig, taskdb):
        Taskfiles_With_Functions(line['id'], taskconfig, taskdb, config).pack_student()
      else:
        Taskfiles_No_Functions(line['id'], taskconfig, taskdb, config).pack_student()
  

if __name__=='__main__':
  import plac
  plac.call(main)
