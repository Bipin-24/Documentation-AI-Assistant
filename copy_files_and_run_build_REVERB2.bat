@REM This script copies the source files to use to generate doc build output and then calls build_reverb2.bat to set up output directories and run WebWorks to populate them. 

@REM Clean up any previous output directories
rd /s/q C:\cmsrc
rd /s/q C:\cmbuild

@REM Set cmsrc work area for source file copies
set CMSRCDIR=C:\cmsrc

@REM Call in the name of the repo directory and set to %REPONAME%
call REPONAME_VAR.cmd

@REM Copy vector files to the cmsrc work area where build_reverb2.bat will run. Running from copies keeps the original source trees clean.
xcopy /seiq .\* %CMSRCDIR%\%REPONAME%

cd %CMSRCDIR%\%REPONAME%

call build_reverb2.bat

@pause
