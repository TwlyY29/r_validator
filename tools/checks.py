import configparser

def init_config(config_file):
  c = configparser.ConfigParser()
  c.read(config_file)
  return c['VALIDATOR']

def check_sheet_requires_tasks_in_functions(indices, taskdb):
  for idx,i in enumerate(indices):
    task = taskdb[i]
    if check_surrounding_function_required_for_task(task):
      return True
  return False

def check_surrounding_function_required_for_task(task):
  if task['no_surrounding_function'] != '':
    return False
  return True

