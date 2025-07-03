@REM Specifies the location of Windows program files on 64-bit machines:
set PFDIR=C:\Program Files

@REM Adds WebWorks programs to the Windows PATH statement:
set PATH=%PATH%;%PFDIR%\WebWorks\ePublisher\2024.1;%PFDIR%\WebWorks\ePublisher\2024.1\ePublisher AutoMap

@REM Sets a variable for the cmsrc work area:
set CMSRCDIR=C:\cmsrc
@REM Sets the cmbuild output destination:
set CMBLDDIR=C:\cmbuild
@REM Set repository name:
call REPONAME_VAR.cmd

@REM Diagnostic Information
@echo **********************************************
@echo CMSRCDIR:   %CMSRCDIR%
@echo CMBLDDIR:   %CMBLDDIR%
@echo REPONAME:   %REPONAME%
@echo PATH:       %PATH%
@echo **********************************************

@REM Change directories to the root of the work area:
cd %CMSRCDIR%\%REPONAME%

@REM Generate Vector enus WRP target:
WebWorks.Automap.exe %CMSRCDIR%\%REPONAME%\enus\WebWorks\wrp\zeenea.wrp -c -n -t "Target 2"

@echo **********************************************
@echo Finished with build_reverb2.bat
@echo **********************************************
