# R-Checker
The R-Checker enables students to self-check their code and teachers to automatically correct exercises for R courses.

It can be integrated into environments like the [Virtual Programming Lab](https://github.com/jcrodriguez-dis/moodle-mod_vpl) in Moodle or the [Praktomat](https://github.com/KITPraktomatTeam/Praktomat/).

A video of it being integrated into the Virtual Programming Lab [is available online: https://mms.uni-bayreuth.de/Panopto/Pages/Viewer.aspx?id=e81f6856-e3de-4149-99f5-ae8c0086e9a3](https://mms.uni-bayreuth.de/Panopto/Pages/Viewer.aspx?id=e81f6856-e3de-4149-99f5-ae8c0086e9a3).

## The Idea
When learning a programming language like R, exercise and feedback are key to success. But feedback has to cover more than the syntax of the code. It needs to be as specific as possible covering the semantic of the code. That means feedback has to express if an answer produces the **correct result** - often this is more than just code that doesn't produce errors.

For example, if you ask your students to merge two tables, the correct answer contains all columns and all data from the two original tables. That means, a correct answer is more than just syntactically correct. It also produces the correct outcome.

This collection of scripts allows to check students' submissions for **correctness** programmatically. Together with an environment like the [Virtual Programming Lab](https://github.com/jcrodriguez-dis/moodle-mod_vpl), you end up with an environment which allows students to self-check their code and which supports the supervisors in correct students' exercises.


## The System
The system is a collection of scripts that is used to create individual task-files for students together with an individual test-file for each student which checks their submission. 

To be able to put this together, you need a database of tasks, task descriptions, and tests. The database is file-based, i.e. it is just a collection of files on your hard-drive.

The following describes the system in-depth.

## For advanced students

This Readme starts with an introduction how to set-up a system for rather advanced students. [Below](#for-students-who-get-in-touch-with-r-for-the-first-time) you can find an introduction if you have students who get in touch with R for the first time. 

### The Task Database
For advanced students, the central task database [task_db.tsv](task_db.tsv) looks like this:

| Competency | Points | Function Name | Signature | Standard Parameters  | Gap Body | Dependency | No Surrounding Function Needed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| vectors_basics | 3 | create_sequence_from_10_to_20 | function() | | | | |
| vectors_basics | 3 | create_sequence_from_20_to_30 | function() | | | | |
| vectors_basics | 3 | create_sequence_from_40_to_80 | function() | | | | |
| sum_basics | 3 | sum_4th_and_6th_position | function(vec) | vec=c(10:20) | | | |
| sum_basics | 3 | sum_vec1_and_vec2_without_plus | function(vec1,vec2) | vec1=c(10:20), vec2=c(20:30) | | | |
| plot_basics | 4 | plot_pie_chart | function(data, labels, main) | data=c(10,15,25,30,10,10), labels=LETTERS[1:6], main="bla, fasel" | | | |
| plot_basics | 4 | plot_barplot_to_png | function(data, labels) | data=c(10,15,25,30,10,10), labels=LETTERS[1:6] | x | | |
| analysis_adv_read_data | 3 | read_data_iris | function() |  |  |  | |
| analysis_adv_read_data | 3 | read_data_cars | function() |  |  |  | |
| analysis_adv_plot | 5 | plot_data | function() |  |  | analysis_adv_read_data | |

It lists all the available tasks together with some meta information. Tasks belong to a certain competency.

As you can see, the functions of the `sum_basics` and `plot_basics` competency take parameters. The column Standard Parameters contains a standard intitialization of the parameters as if they were part of a function call, e.g. 

```
sum_vec1_and_vec2_without_plus <- function(vec1=c(10:20), vec2=c(20:30)) ...
```

The use of the colum Gap Body is explained in more details [later](#optional-files). The use of the column Dependency is explained in more details [later as well](#dependencies).

They have to be given in a separate column instead of the Signature-colum to allow for testing of the standard values later.

### Required Files
For the system to be able to put together task descriptions, tests, and standard solutions, you need to have **three files for each of the specified functions**. In all cases, you need to have a **subdirectory that matches the competency** and a **file inside that subdirectory matching the function name** in the `task_db.tsv`. These things go intro the three directories `tasks`, `tests`, and `solutions`.

The description of the task is given in the specified file in your `tasks`-directory. Have a look at [one example description](tasks/vector_basics/create_sequence_from_40_to_80.txt).

The tests and the solution of a task are given in corresponding files in your `tests` folder and one in your `solutions` folder. In both of these folders, you'll find the sub-folder `vector_basics` and the file `create_sequence_from_40_to_80.R`. 

Have a look at the [file in `tests/` folder](tests/vector_basics/create_sequence_from_40_to_80.R) and the [file in `solutions/` folder](solutions/vector_basics/create_sequence_from_40_to_80.R). The file in `solutions` contains the correct solution. Note that it does not contain the function name as this will be put together automatically later. 

The files in `tests`-folder contain all the unit-like tests to check the students' submissions.

### Optional Files
Sometimes, you want to provide a function body with some gaps that your students have to fill. Indicate this by checking the column Gap Body in `task_db.tsv` and create a file in the `gap_bodies`-subdirectory. As with the other files, the gap body has to live inside a subdirectory matching the competency and inside a file that matches the function name.

Have a look at the [example for `plot_barplot_to_png`](gap_bodies/plot_basics/plot_barplot_to_png.R) and how this looks like in the [corresponding individual task sheet](task_1/123456/task.R). 

### Dependencies
Sometimes, you want tasks to build on top of each other. For example, you want students to read in data in one task, and visualize the data in another. Specifying a dependency ensures that the required task, e.g. for reading in the data, is present. 

An example can be seen in the competencies `analysis_adv_plot` which depends on the competency `analysis_adv_read_data`. Inside the `plot_data`-function, a `read_data_*` function is called and the result is visualized. The dependency ensures that the task-file contains a `read_data_*`-function of the competency `analysis_adv_read_data`.

Have a look at the [solution file for plot_data](solutions/analysis_adv_plot/plot_data.R) to see how to react to different `read_data_*`-functions being sampled. Also, in the [test file for plot_data](tests/analysis_adv_plot/plot_data.R), you can see some advanced pattern matching to describe the tests.

### Testing Tasks
Since the main aim of this system is to test submissions for internal correctness, we need more than a syntax-check. The tests are therefore inspired by the excellent [RUnit](https://cran.r-project.org/web/packages/RUnit/index.html) Framework for R. 

To be able to check a submission for correctness, we formulate some requirements:

* **Tasks are functions.**<br/>
    A student has to enter her solution to a task inside the body of a function. Anything that is written outside the body of the function does not count as a solution to a task.
* **Tasks produce results.**<br/>
    The function has to produce one result object. The result object is what can be evaluated in your checks. It is passed to your checks in a variable `res`.
* **Only tasks count.**<br/>
    For testing an individual task, the corresponding function is called. Effects of sourcing the student submission file do not count to individual tasks.

The solution of a student is inside an object called `res`. The call to the student's function is assembled from the content of the columns "Function Name", "Signature" (and, optionally, "Standard Parameters") of the [task_db.tsv](task_db.tsv). It is surrounded with a few "security measurements" in order to prevent students from printing something that increases the point-counter (as specified in the [test_safe_call.R](tools/test_safe_call.R) if you're interested in the nitty whitty details). 

However, a test calls the student's function and saves the result in `res`. You have a few built-in possibilities to perform checks of this `res` object:

* `checkEquals`: checks if two lists contain the same elements
* `checkEqualsNumeric`: checks if two vectors contain the same numbers
* `checkTrue`: checks if some condition is met
* `checkIdentical`: checks if some object is identical to something else
* `checkError`: checks if something produces an error
* `checkSourceContains`: checks if the submission source code contains a pattern. This can be focused on a function body as well.

Have a look at two [basic](tests/vector_basics/create_sequence_from_40_to_80.R) [examples](tests/vector_basics/create_sequence_from_10_to_20.R) to see some of the functions in action. A rather advanced check that also makes use of function parameters is found in [sum_vec1_and_vec2_without_plus.R](tests/sum_basics/sum_vec1_and_vec2_without_plus.R). Finally, make sure to have a look at [plot_pie_chart.R](tests/plot_basics/plot_pie_chart.R) to see how you can check if a file is created during execution of a submitted function. That example expects the `Rplots.pdf` to be created to test if a plot was created.

Testing tasks with function parameters has two specialties: When defining your test, you can use `@STD_PARAMS@` and `@CALL@` in your R file. The keyword `@CALL@` is replaced by a call to the submitted function. It is assembled from the content of the columns "Function Name", "Signature" and "Standard Parameters" of the [task_db.tsv](task_db.tsv). The names of the parameters are the same as in the `task_db.tsv`. If the signature looks like `function(vec1)`, then you have to initialize the variable `vec1` somewhere in your test.

The keyword `@STD_PARAMS@` will be replaced with the content of the column "Standard Parameters" of the [task_db.tsv](task_db.tsv). If you have multiple paramters defined there, the comma separating the parameters will be eliminated and the parameter initializations will be spread across lines. The resulting piece of R code then defines the parameters as variables.

One thing related to `checkSourceContains` is worth mentioning. That check looks for a string or a pattern in the source file. If you want to restrict the search to the **body of a specific function**, you can pass it `fname="@FNAME@"` as a parameter. First, `@FNAME@` will be replaced by the function to test. Second, this will limit the search to the body of said function.

Every check produces an output if the test succeeded or if it failed. This output will be used to count the points inside an execution environment like the [Virtual Programming Lab](#Using-this-with-Virtual-Programming-Lab) or the Praktomat.

### Defining a Task Sheet
A task sheet is defined by creating a table of competencies and a number of tasks to check the corresponding competency. This is the content of [task_1.tsv](task_1.tsv):

| Competency | Number of Tasks|
| --- | --- |
| vectors_basics | 2 |
| sum_basics | 2 |
| plot_basics | 2 |

The competency `vectors_basics` should be tested with 2 different tasks per student. From our [task database](task_db.tsv) [above](#The-Task-Database) we know that we have 3 tasks in our database.

Since we have more tasks available than required for the sheet, the tasks are **randomly sampled** for **each student individually**. That's why we need to test each student's submission with an individual test as well. 

For the competencies `sum_basics` and `plot_basics` all available tasks will be used.

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

Watch [a video showing how this integrates with the Virtual Programming Lab: https://mms.uni-bayreuth.de/Panopto/Pages/Viewer.aspx?id=e81f6856-e3de-4149-99f5-ae8c0086e9a3](https://mms.uni-bayreuth.de/Panopto/Pages/Viewer.aspx?id=e81f6856-e3de-4149-99f5-ae8c0086e9a3).

### Using this with Virtual Programming Lab
For the VPL, you need to have a look at the [vpl_evaluate.sh](tools/vpl_evaluate.sh).
The script will receive the submission file of the student inside the variable `$VPL_SUBFILE0`. 

As you can see, from the submission file the student id is parsed and checked for correctness. Then, the `test.R` for this particular student is downloaded from some URL. The downloaded individual `test.R` is then used to correct the submission.

The rest of the [vpl_evaluate.sh](tools/vpl_evaluate.sh) converts the output of the `test.R` such that points appear in the Moodle exercise as well as some comments from the tests. This means that each succeeded test will count as one point for the exercise.

By the way, the way the student's functions are called prohibit messing with this system. Have a look at the [test_safe_call.R](tools/test_safe_call.R) to see that all output of the student's function is redirected to `/dev/null`.

## For students who get in touch with R for the first time
This is considered a special case for the system. It has a substantial difference to the above-mentioned descriptions: It doesn't require the students to enter their solutions *inside of functions* but rather just on the top level of their R-Scripts.

We still have the central task database [task_db.tsv](task_db.tsv):

| Competency | Points | Function Name | Signature | Standard Parameters  | Gap Body | Dependency | No Surrounding Function Needed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| first_steps | 3 | create_and_append_1 | NA | | | | x |
| first_steps | 3 | create_and_append_2 | NA | | | | x |

Just now, the last column is non-empty. Of course, you can combine functions that do not require surrounding functions in the central task database file with those that do. Beware, though, that they mustn't be combined in a single task sheet!

Everything else is still the same. So, you need a [task sheet](task_0.tsv) to define the task, which then yields in an [individual task sheet](task_0/123456/task.R) and an [individual test sheet](task_0/123456/test.R). An expected solution could look [like this](task_0/123456/solution.R).

Note that you have an additional check avilable ([see here for an example](tests/first_steps/create_and_append_1.R)): `checkVariableExists` checks if the student created a variable with a certain name that holds a calculated result, for example. If you combine multiple tasks in one sheet, you have to take care for yourself that variable names differ between tasks!

## Usage
To get started, you'll need three things:

1. A database of tasks and tests
2. A definition of a task sheet
3. A list of students participating in your course.

Then it is all about calling

```
TASK=task_1 make
```

which will end up in a folder with the same name as your task sheet (here, it is `task_1` because we have `task_1.tsv`). Inside, you'll find folders for all the students together with their individual task sheets, their test files, and their solutions.

The `TASK` variable can be exported to your environment so that you do not have to type it in every time. In any case, it configures which task sheet will be built.

If you want to deliver the task sheets from a website, it is advised to skip creation of solutions until you synced the directory to your webserver. So you'd rather do

```
TASK=task_1 make taskfiles
```

sync the `task_1` folder with your webserver and then

```
TASK=task_1 make solutionfiles
```

While developing tasks and tests you can use 

```
TASK=task_1 make tests
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
