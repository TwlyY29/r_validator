import re
from pathlib import Path
from taskfiles_reader import read_task_description, read_gap_body
from taskfiles_writer import write_student_solution_base_file, write_out_task_ids_for_student

class Taskfiles_With_Functions:
  
  def __init__(self, student, task_config, taskdb, config):
    self.student = student
    self.task_config = task_config
    self.taskdb = taskdb
    self.config = config
    
    self.sol_path = Path(self.config.get('outdir'), self.student)
    self.sol_path.mkdir(parents=True, exist_ok=True)
    self.sol_file = Path(self.sol_path,'task.R')
    
  
  def check_dependencies(self):
    sampled_competencies = [self.taskdb[i]['competency'] for i in self.task_config]
    for idx,i in enumerate(self.task_config):
      task = self.taskdb[i]
      if task['depends'] != False:
        dep = task['depends']
        if not dep in sampled_competencies:
          raise Exception(f"dependency of function '{task['function']}' on competency '{dep}' is not met")
    return True

  # creates sheets with multiple tasks each inside their own function
  def create_task_file_for_student(self):
    self.check_dependencies()
    out = ''
    n_points = 0
    for idx,i in enumerate(self.task_config):
      task = self.taskdb[i]
      fun_name = task['function']
      fun_sig = task['signature']
      fun_points = task['points']
      fun_example_call = task['stdparams']
      fun_competency = task['competency']
      n_points += int(fun_points)
      fun_task = read_task_description(fun_name, fun_competency, self.config.get('R_TASKS_DESCRDIR'))
      if task['has_gap_body']:
        fun_body = read_gap_body(fun_name, fun_competency, self.config.get('R_TASKS_BODYDIR'), indent=2)
      else:
        fun_body = '  # Add your solution here\n  '
      out += f"# Task {idx+1}:\n# {fun_points} Points{fun_task}\n#\n# Do NOT change the following line\n{fun_name} <- {fun_sig}{{\n{fun_body}\n}}\n{fun_name}({fun_example_call})\n\n"
    write_student_solution_base_file(self.sol_file, self.student, self.config['taskid'], out, n_points)

  def split_std_params(self, params):
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

  def load_tests_file(self, fun_test, taskdb_entry, indent=2):
    fun_task = taskdb_entry['function']+taskdb_entry['signature'].replace('function','')
    fun_file = Path(taskdb_entry['competency'], taskdb_entry['function']+'.R')
    
    base_call = ''
    with open (self.config.get('BASE_TEST_CALL'), 'r' ) as _testf:
      # ~ base_call = (' '*indent).join(_testf.readlines())
      base_call = ''.join(_testf.readlines())
      base_call = re.sub('@FUN_CALL@', fun_task, base_call, flags=re.M)
      base_call = base_call.rstrip('\n')
    
    just_call = True
    tests = ''
    with open(Path(self.config.get('R_TESTS_SOURCEDIR'), fun_file), 'r') as _f:
      tests = ''.join(_f.readlines())
      # ~ tests = tmp.rstrip('\n').replace('\n', '\n'+' '*(indent+2))
      if '@CALL@' in tests:
        tests = tests.replace('@CALL@', base_call)
        if '@STD_PARAMS@' in tests:
          params = self.split_std_params(taskdb_entry['stdparams'])
          tests = tests.replace('@STD_PARAMS@', params)
        tests = tests.rstrip('\n')
        just_call = False
    
    content = f"{fun_test} <- function(){{\n"
    if just_call:
      content += ' '*(indent+2) + base_call.replace('\n', '\n'+' '*(indent+2))+ '\n'
    content += ' '*(indent+2) + tests.rstrip('\n').replace('\n', '\n'+' '*(indent+2)) + '\n'+ ' '*indent + '}'
    content = content.replace('@FNAME@', taskdb_entry['function'])
    return content.rstrip('\n')

  def prepare_sandboxed_inline_test(self, funcname, func, indent=2):
    ind = ' '*indent
    return f"{ind}sandbox${func}\n{ind}environment(sandbox${funcname}) <- sandbox\n"

  def create_test_file(self):
    test_sources = ''
    test_functions = []
    r_functions = []
    for i in self.task_config:
      f = self.taskdb[i]['function']
      ftest = f'test.{f}'
      src = self.load_tests_file( ftest, self.taskdb[i])
      test_sources += self.prepare_sandboxed_inline_test(ftest, src) + '\n'
      test_functions.append( ftest )
      r_functions.append( f'{f}' )
    test_functions = '","'.join(test_functions)
    r_functions = '","'.join(r_functions)
    with open(self.config.get('BASE_TEST_R_FUN_WITH'), 'r' ) as _testf:
      content = _testf.read()
    content_new = re.sub('###ADD_SOURCES_HERE###', test_sources, content, flags=re.M)
    content_new = re.sub('###ADD_TEST_FUNCTIONS_HERE###', test_functions, content_new, flags=re.M)
    content_new = re.sub('###ADD_R_FUNCTIONS_HERE###', r_functions, content_new, flags=re.M)
    content_new = re.sub('###NUM_TESTCASES###', str(len(self.task_config)), content_new, flags=re.M)
    with open(Path(self.sol_path, 'test.R'), 'w') as _out:
      print(content_new, file=_out)

  def pack_student(self):
    self.create_task_file_for_student()
    self.create_test_file()
    write_out_task_ids_for_student(self.taskdb, self.task_config, Path(self.sol_path, 'tasks.tsv'))

