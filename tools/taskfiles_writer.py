from pathlib import Path
from datetime import datetime

from checks import check_surrounding_function_required_for_task

def write_out_task_ids_for_student(taskdb, task_config, outfile):
  with open(outfile, 'w') as _f:
    print("competency\tpoints\tfunction\tno_surrounding_function", file=_f)
    for t in task_config:
      c = taskdb[t]['competency']
      fun = taskdb[t]['function']
      s = taskdb[t]['no_surrounding_function']
      p = taskdb[t]['points']
      print(f"{c}\t{p}\t{fun}\t{s}", file=_f)

def write_student_solution_base_file(solfile, student, text, n_points):
  with open(solfile, 'w') as _sol:
    timestamp = datetime.strftime(datetime.now(),'%Y-%m-%d')
    print(f"################################\n# DO NOT MODIFY THIS BLOCK!\n# id: {student}\n# created: {timestamp}\n# achievable score: {n_points}\n# DO NOT MODIFY THIS BLOCK! \n################################\n\n", file=_sol)
    print(text, file=_sol)
