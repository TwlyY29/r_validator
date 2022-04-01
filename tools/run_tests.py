#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
import configparser

def init_config(config_file):
  c = configparser.ConfigParser()
  c.read(config_file)
  return c['VALIDATOR']

def main(config='validator.config'):
  config = init_config(config)
  
  here = Path(os.getcwd())
  for p in here.rglob("*"):
    if p.is_dir():
      test_file = Path(p, 'test.R')
      sol_file = Path(p, 'solution.R')
      if test_file.exists() and sol_file.exists():
        print(f"#########\n  student {p.name}")
        cmd = f"Rscript --vanilla {test_file.name} {sol_file.name}"
        result = subprocess.run(cmd.split(' '), stdout=subprocess.PIPE, cwd = str(p.resolve()))
        result = result.stdout.decode('utf-8').strip()
        if result:
          n_tasks = 0
          n_tests = 0
          n_correct = 0
          current_name = ''
          for line in result.split('\n'):
            if '@START@' in line:
              n_tasks += 1
              current_name = line.strip()[7:len(line)]
            elif '@OK@' in line:
              n_correct += 1
            elif '@NTESTS@' in line:
              n_tests += int(line.strip()[8:len(line)])
            elif '@FAIL@' in line:
              raise Exception(f"failed test '{(line.split('@'))[2]}' in function '{current_name}' ({str(sol_file.resolve())})")
            elif '@ERROR@' in line:
              raise Exception(f"error '{(line.split('@'))[2]}' occured in {str(sol_file.resolve())}")
          print(f"  checked {n_tasks} tasks with {n_correct}/{n_tests} successful checks\n#########")

if __name__=='__main__':
  import plac
  plac.call(main)
