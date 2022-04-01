# R-Checker
The R-Checker enables students to self-check their code and teachers to automatically correct exercises for R courses.

It can be integrated into environments like the [Virtual Programming Lab](https://github.com/jcrodriguez-dis/moodle-mod_vpl) in Moodle or the [Praktomat](https://github.com/KITPraktomatTeam/Praktomat/).

## The Idea
When learning a programming language like R, exercise and feedback are key to success. But feedback has to cover more than the syntax of the code. It needs to be as specific as possible covering the semantic of the code. That means feedback has to express if an answer produces the **correct result** - often this is more than just code that doesn't produce errors.

For example, if you ask your students to merge two tables, the correct answer contains all columns and all data from the two original tables. That means, a correct answer is more than just syntactically correct. It also produces the correct outcome.

This collection of scripts allows to check students' submissions for **correctness** programmatically. Together with an environment like the [Virtual Programming Lab](https://github.com/jcrodriguez-dis/moodle-mod_vpl), you end up with an environment which allows students to self-check their code and which supports the supervisors in correct students' exercises.


## The System
The system is a collection of scripts that is used to create individual task-files for students together with an individual test-file for each student which checks their submission. 

To be able to put this together, you need a database of tasks, task descriptions, and tests. The database is file-based, i.e. it is just a collection of files on your hard-drive.

The following describes the system in-depth.

### The Task Database
There is one central task database:

| Competency | Points | Function Name | Signature | Standard Parameters | Test/Rump | Task Description |
| --- | --- | --- | --- | --- | --- | --- |
| vectors_basics | 3 | create_sequence_from_10_to_20 | function() | | vector_basics/create_sequence_from_10_to_20.R | vector_basics/create_sequence_from_10_to_20.txt |
| vectors_basics | 3 | create_sequence_from_20_to_30 | function() | | vector_basics/create_sequence_from_20_to_30.R | vector_basics/create_sequence_from_20_to_30.txt |
| vectors_basics | 3 | create_sequence_from_40_to_80 | function() | | vector_basics/create_sequence_from_40_to_80.R | vector_basics/create_sequence_from_40_to_80.txt |
| sum_basics | 3 | sum_4th_and_6th_position | function(vec) | vec=c(10:20) | sum_basics/sum_4th_and_6th_position.R | sum_basics/sum_4th_and_6th_position.txt |
| sum_basics | 3 | sum_vec1_and_vec2_without_plus | function(vec1,vec2) | vec1=c(10:20), vec2=c(20:30) | sum_basics/sum_vec1_and_vec2_without_plus.R | sum_basics/sum_vec1_and_vec2_without_plus.txt |

It lists all the available tasks together with some meta information. Tasks belong to a certain competency. This example consists of a single competency. But you get the idea. 

As you can see, the functions of the `sum_basics` competency take parameters. The column Standard Parameters contains a standard intitialization of the parameters as if they were part of a function call, e.g. 

```
sum_vec1_and_vec2_without_plus <- function(vec1=c(10:20), vec2=c(20:30)) ...
```

They have to be given in a separate column instead of the Signature-colum to allow for testing of the standard values later.

The description of the task is given in the specified file in your `tasks`-directory. Have a look at [one example description](tasks/vector_basics/create_sequence_from_40_to_80.txt).

The tests and the solution of a task are given in the file stated in the 'Test/Rump' column. Note that this references two different files - one in your `tests` folder and one in your `solutions` folder. In both of these folders, you'll find the sub-folder `vector_basics` and the file `create_sequence_from_40_to_80.R`. 

Have a look at the [file in `tests/` folder](tests/vector_basics/create_sequence_from_40_to_80.R) and the  [file in `solutions/` folder](solutions/vector_basics/create_sequence_from_40_to_80.R). The file in `solutions` contains the correct solution. Note that it does not contain the function name as this will be put together automatically later. 

The files in `tests`-folder contain all the unit-like tests to check the students' submissions.

### Testing Tasks
Since the main aim of this system is to test submissions for internal correctness, we need more than a syntax-check. The tests are therefore inspired by the excellent [RUnit](https://cran.r-project.org/web/packages/RUnit/index.html) Framework for R. 

To be able to check a submission for correctness, we formulate some requirements:

* **Tasks are functions.**<br/>
    A student has to enter her solution to a task inside the body of a function. Anything that is written outside the body of the function does not count as a solution to a task.
* **Tasks produce results.**<br/>
    The function has to produce one result object. The result object is what can be evaluated in your checks. It is passed to your checks in a variable `res`.
* **Only tasks count.**<br/>
    For testing an individual task, the corresponding function is called. Effects of sourcing the student submission file do not count to individual tasks.

The solution of a student is inside an object called `res` (this is specified in the [test_safe_call.R](tools/test_safe_call.R) if you're interested in the nitty whitty details). You have a few built-in possibilities to perform checks of this `res` object:

* `checkEquals`: checks if two lists contain the same elements
* `checkEqualsNumeric`: checks if two vectors contain the same numbers
* `checkTrue`: checks if some condition is met
* `checkIdentical`: checks if some object is identical to something else
* `checkError`: checks if something produces an error
* `checkSourceContains`: checks if the submission source code contains a pattern. This can be focused on a function body as well.

Have a look at two [basic](tests/vector_basics/create_sequence_from_40_to_80.R) [examples](tests/vector_basics/create_sequence_from_10_to_20.R) to see some of the functions in action. A rather advanced check that also makes use of function parameters is found in [sum_vec1_and_vec2_without_plus](tests/sum_basics/sum_vec1_and_vec2_without_plus).

Every check produces an output if the test succeeded or if it failed. This output will be used to count the points inside an execution environment like the [Virtual Programming Lab](#Using-this-with-Virtual-Programming-Lab) or the Praktomat.

### Defining a Task Sheet
A task sheet is defined by creating a table of competencies and a number of tasks to check the corresponding competency. This is the content of [task_1.tsv](task_1.tsv):

| Competency | Number of Tasks|
| --- | --- |
| vectors_basics | 2 |
| sum_basics | 2 |

The competency `vectors_basics` should be tested with 2 different tasks per student. From our [task database](task_db.tsv) [above](#The-Task-Database) we know that we have 3 tasks in our database.

Since we have more tasks available than required for the sheet, the tasks are **randomly sampled** for **each student individually**. That's why we need to test each student's submission with an individual test as well. 

For the competency `sum_basics` all available tasks will be used.

Have a look at [an individual task sheet](task_1/123456/task.R). As you can see, a function call is inserted to support students in developing and exectuing their answer. Also, for functions taking parameters, this makes explicit what kind of parameters should be processed.

### Testing Submissions
The [individual task sheet](task_1/123456/task.R) is tested using the [corresponding individual test sheet](task_1/123456/test.R). 

The test sheet is completely stand-alone. It contains all the code required to perform the tests. It only expects the submission file as an argument.

The test sheet then takes care of sourcing the submission file, executing the tasks, and performing all the checks.

### The Task Descriptions
The descriptions are contained in the files in your `tasks`-folder.

Task descriptions can contain multiple lines. The content of these files will end up as comments in the task-files.

## Self-Check and Corrections
The individual test files need to be executed for an individual submission somewhere. That's what the [Virtual Programming Lab](https://github.com/jcrodriguez-dis/moodle-mod_vpl) in Moodle or the [Praktomat](https://github.com/KITPraktomatTeam/Praktomat/) can be used for. Up to now, an integration to VPL is ready. If you want to get this working with Praktomat, get in touch.

### Using this with Virtual Programming Lab
For the VPL, you need to have a look at the [vpl_evaluate.sh](tools/vpl_evaluate.sh).
The script will receive the submission file of the student inside the variable `$VPL_SUBFILE0`. 

As you can see, from the submission file the student id is parsed and checked for correctness. Then, the `test.R` for this particular student is downloaded from some URL. The downloaded individual `test.R` is then used to correct the submission.

The rest of the [vpl_evaluate.sh](tools/vpl_evaluate.sh) converts the output of the `test.R` such that points appear in the Moodle exercise as well as some comments from the tests. This means that each succeeded test will count as one point for the exercise.

By the way, the way the student's functions are called prohibit messing with this system. Have a look at the [test_safe_call.R](tools/test_safe_call.R) to see that all output of the student's function is redirected to `/dev/null`.


## Usage
To get started, you'll need three things:

1. A database of tasks and tests
2. A definition of a task sheet
3. A list of students participating in your course.

Then it is all about calling

```
make
```

which will end up in a folder with the same name as your task sheet (here, it is `task_1` because we have `task_1.tsv`). Inside, you'll find folders for all the students together with their individual task sheets, their test files, and their solutions.

If you want to deliver the task sheets from a website, it is advised to skip creation of solutions until you synced the directory to your webserver. So you'd rather do

```
make taskfiles
```

sync the `task_1` folder with your webserver and then

```
make solutionfiles
```

While developing tasks and tests you can use 

```
make tests
```

Be aware that this creates solution files!

### Using this under Windows
You can also use this system with Windows. The python3 scripts are fairly platform-independent. The only thing is to adjust the path to your `Rscript.exe` if you want to execute your tests locally. The adjustments either go into a `validator.config`. If you do not want to create one yourself from [the example](tools/validator.config.env_win), you can use the `Makefile`. You just need a way to execute it.

To execute `make` commands under Windows, I tried using [chocolatery](https://chocolatey.org/) which works fairly well. To get this running, follow these steps:

1. Open PowerShell with Administrator privileges<br/>
   Open the Start Menu, search for PowerShell, and right-click the icon selecting "Open with Admin..."
2. Right-click the title bar of the PowerShell window and select "Properties" or "Eigenschaften". Then, activate "Copy/Paste using CTRL+SHIFT+C/V" to be able to paste a command into the shell.
3. Visit [https://chocolatey.org/install#individual](https://chocolatey.org/install#individual) and find the PowerShell command. Copy it.
4. Paste the command to the PowerShell (using CTRL+SHIFT+V) and execute it.
5. Run `choco install make` in the PowerShell
6. Run `python3` in the PowerShell.<br/>
   If this opens the Windows App Store, install Python 3 from there. Otherwise hit CTRL+D to exit the Python shell
7. Run `pip3 install plac` still in the PowerShell
8. Open the [`Makefile`](Makefile) in [a good text editor](https://geany.org/) and ajdust the path to your `RScript.exe`. It resides in the install directory of `R` in the subfolder `bin\`

Now you're good to go. Just refer to [the usage section](#usage).
