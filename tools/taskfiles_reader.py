from pathlib import Path
import re

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

  
