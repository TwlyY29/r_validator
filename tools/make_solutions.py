#!/usr/bin/env python3

import csv
import os
import re
from pathlib import Path
import configparser

def fill_function_in_string(string, function, rump, indent=2):
  i = string.find(function)
  i = string.find('\n', i)
  end = string.find('}', i)
  rump = ' '*indent + rump.rstrip('\n').replace('\n', '\n'+' '*indent)
  return f"{string[0:i]}\n{rump}\n{string[end:len(string)]}"

def create_solution_file(task_meta, task_file, sol_file, config):
  with open(task_file, 'r') as _f:
    solution = ''.join(_f.readlines())
  with open(task_meta, 'r') as _tsv:
    db = csv.DictReader(_tsv, delimiter='\t')
    for task in db:
      f = task['function']
      s = Path(config.get('R_TESTS_SOLUTIONDIR'), task['competency'], f+'.R')
      if not s.exists():
        raise Exception(f"expecting solution file for function {f}: '{s}'")
      with open(s,'r') as _sol:
        rump = ''.join(_sol.readlines())
      
      solution = fill_function_in_string(solution, f, rump)
      
  with open(sol_file, 'w') as _out:
    print(solution, file=_out)

def init_config(config_file):
  c = configparser.ConfigParser()
  c.read(config_file)
  return c['VALIDATOR']

def main(config='validator.config'):
  config = init_config(config)
  here = Path(os.getcwd())
  for p in here.rglob("*"):
    if p.is_dir():
      task_meta = Path(p, 'tasks.tsv')
      task_file = Path(p, 'task.R')
      sol_file = Path(p, 'solution.R')
      if task_meta.exists() and task_file.exists():
        create_solution_file(task_meta, task_file, sol_file, config)
      
  

if __name__=='__main__':
  import plac
  plac.call(main)
