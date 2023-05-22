# SLpipeline design with bash?

The top level script **SLpipeline.sh** is written in **bash**, and here
we describe some salient points of the main pros and cons of such a design.

Why bash, and not python? The original code base was a set of scripts that
were executed from the command line, and a shell language like bash was a
more natural fit to this without having to change major interfaces.

bash is a very powerful programming language, and so far in LMTOY we are only
using a few simple features, which we enumerate below in order to assess the
impact if the design is going to change or expanded.


## Features 

1. The **source** command will find a file from the users' **$PATH**, thus
   with the command

        source lmtoy_functions.sh

   we can keep a library of functions useful for the pipeline. You will see
   most bash scrips now use these functions.

2. Variables in bash are shared between functions, and don't need to be declared. 

   We are not using (yet) the **declare** command in bash to enforce typing etc.

   We are not using (yet) the **local** command to enforce local variables in a function.

   Use the **debug=1** to monitor and force better variable declaration habits, e.g. in order
   to force an error if an unset variables is used, use **debug=2**  [TBD]

3. Our command line parser expects a series of *keyword=value*, but they are not
   'registered', thus misspelling a keyword name can cause confusion. The
   function **lmtoy_args** contains the following parser:

        for arg in "$@"; do
	    export "$arg"
        done

   notice we don't use **eval** but **export**. Since it is used inside a function,
   we need this in order for keyword with spaces to be properly parsed

4. Inline help is defined as sections of bash commands between two **#--HELP** comments in the script.
   Normally the defaults of the PI parameters are stored here, but multiple sections of HELP are
   perfectly fine in a script. This idea is somewhat similar to the **docopt** python module, which
   we have started to use for some of the python scripts.   It's a more *WYSIWYG* approach to command
   line interfaces, and makes for so much more readable code.

5. Command Line Processing is done in the following order:

    1.  Default PI parameters as defined in the **#--HELP** sections of a script (or anything equivalent,
        usually viewable with the --help option to the script.

    2.  **lmtinfo.py** parameters (some are PI parameters, and can override the script defaults)

    3.  CLI parameters meant to override any of the ones  defined before

   All of these parameters are then stored in an **lmtoy_OBSNUM.rc** file, which is meant to be readable by
   bash (using the bash source command) and
   python (using the python exec function, e.g. in mk_metadata.py)

6. At the top level, SLpipeline.sh finds out what instrument and (science) goal is, and directs
   the instrument specific processing to scripts such as seq_pipeline.sh and rsr_pipeline.sh after
   having set some rc defaults (TBD)

   Each instrument then processes parameters and sets up the variables that then are processed
   in functions like lmtoy_seq1 and lmtoy_rsr1, where all the hard pipeline work is done.
   
99. Various peculiarities to enable analytics

    1. The date= variable is used to store beginning and ending of pipeline processing

## References

Apart from the **man bash** command, 
there are of course plenty of programming and reference guides online. We mention a few:

* https://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html  (from 2000, somewhat outdated)
* https://www.gnu.org/software/bash/manual/bash.html  - bash reference manual
* https://www.redhat.com/sysadmin/stupid-bash-tricks
* https://github.com/PacktPublishing/Complete-Bash-Shell-Scripting-

