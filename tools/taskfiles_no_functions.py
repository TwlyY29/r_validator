import re
from pathlib import Path
from taskfiles_reader import read_task_description, read_gap_body
from taskfiles_writer import write_student_solution_base_file, write_out_task_ids_for_student

class Taskfiles_No_Functions:
  
  def __init__(self, student, task_config, taskdb, config):
    self.student = student
    self.task_config = task_config
    self.taskdb = taskdb
    self.config = config
    
    self.sol_path = Path(self.config.get('outdir'), self.student)
    self.sol_path.mkdir(parents=True, exist_ok=True)
    self.sol_file = Path(self.sol_path,'task.R')
    

  # creates sheets with tasks living outside of functions
  def create_task_file_for_student(self):
    out = ''
    n_points = 0
    for idx,i in enumerate(self.task_config):
      task = self.taskdb[i]
      fun_points = task['points']
      fun_name = task['function']
      fun_competency = task['competency']
      
      n_points += int(fun_points)
      fun_task = read_task_description(fun_name, fun_competency, self.config.get('R_TASKS_DESCRDIR'))
      if task['has_gap_body']:
        fun_body = read_gap_body(fun_name, fun_competency, self.config.get('R_TASKS_BODYDIR'), indent=0)
      else:
        fun_body = '\n  '
      out += f"# Task {idx+1}:\n# {fun_points} Points{fun_task}\n{fun_body}\n\n\n# End of Task {idx+1}\n\n"
    write_student_solution_base_file(self.sol_file, self.student, self.config['taskid'], out, n_points)

  def load_tests_file(self, taskdb_entry, indent=2):
    fun_file = Path(taskdb_entry['competency'], taskdb_entry['function']+'.R')
    
    content = ''
    with open(Path(self.config.get('R_TESTS_SOURCEDIR'), fun_file), 'r') as _f:
      content = ''.join(_f.readlines())
    
    content = ' '*(indent+2) + content.rstrip('\n').replace('\n', '\n'+' '*(indent+2))
    return content.rstrip('\n')

  def create_test_file(self):
    test_sources = ''
    for i in self.task_config:
      test_sources += self.load_tests_file(self.taskdb[i]) + '\n'
    with open(self.config.get('BASE_TEST_R_FUN_NO'), 'r' ) as _testf:
      content = _testf.read()
    content_new = re.sub('###COPY_CHECKS_HERE###', test_sources, content, flags=re.M)
    with open(Path(self.sol_path, 'test.R'), 'w') as _out:
      print(content_new, file=_out)

  def pack_student(self):
    self.create_task_file_for_student()
    self.create_test_file()
    write_out_task_ids_for_student(self.taskdb, self.task_config, Path(self.sol_path, 'tasks.tsv'))

