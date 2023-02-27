# SLpipeline design with bash?

The top level script **SLpipeline.sh** is written in **bash**, and here
we describe some salient points of the main pros and cons of such a design.
bash is a very powerful programming language, and so far in LMTOY we are only
using a few simple features, which we enumerate in order to assess the
impact if the design is going to change or expanded:

## Features 

1. The **source** command will find a file from the users' **$PATH**, thus
   with the command

        source lmtoy_functions.sh

   we can keep a library of functions useful for the pipeline.

2. Variables in bash are shared between functions, and don't need to be declared.
   Use the **debug=1** to monitor and force better variable declaration habits, e.g. in order
   to force an error if an unset variables is used, use **debug=2**  [TBD]

   We are not using (yet) the **declare** command in bash to enforce typing etc.

   We are not using (yet) the **local** command to enforce local variables in a function.

3. Command line parser expects a series of *keyword=value*, but they are not
   'registered', thus misspelling a keyword name can cause confusion. The
   function **lmtoy_args** contains the following parser:

        for arg in "$@"; do
	    export "$arg"
        done

    notice we don't use **eval** but **export**, in order for keyword with spaced
    to be properly parsed.

4.  Inline help is defined as sections of bash commands between two **#--HELP** comments in the script.
    Normally the defaults of the PI parameters are stored here, but multiple sections of HELP are
    perfectly fine in a script. 

5.  Command Line Processing is done in the following order:

    1.  Default PI parameters as defined in the **#--HELP** sections of a script

    2.  **lmtinfo.py** parameters (some are PI parameters)

    3.  CLI parameters meant to override any of the ones  defined before

    All of these are stored in an **lmtoy_OBSNUM.rc** file, which is means to be readable by
    bash (using the source command) and python (using the exec function). There are no examples
    yet of usage in python.




## References

Apart from the **man bash** command, 
there are of course plenty of programming and reference guides online. We mention a few:

* https://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html  (from 2000, somewhat outdated)
* https://www.gnu.org/software/bash/manual/bash.html  - bash reference manual
* https://www.redhat.com/sysadmin/stupid-bash-tricks
* https://github.com/PacktPublishing/Complete-Bash-Shell-Scripting-

