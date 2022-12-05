
@echo off

set startTime=%time%

@REM set loopcount=120
set loopcount=1

:loop
echo %loopcount%
START matlab -nosplash -nodesktop -r "try, run('jsss/sim_true.m'), catch me, fprintf('%%s', string(me.message)), end;"

TIMEOUT 300 /nobreak

set mcount=2

:mc
echo %mcount%
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par1.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par2.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par3.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par4.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par5.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par6.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par7.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par8.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par9.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par10.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par11.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par12.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par13.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par14.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par15.m'), catch me, fprintf('%%s', string('failed')), end; exit;"
TIMEOUT 4
START /B matlab -nosplash -nodesktop -r "try, run('jsss/sim_par16.m'), catch me, fprintf('%%s', string('failed')), end; exit;"

TIMEOUT 5064

set /a mcount=mcount-1
if %mcount%==0 goto mainloop
goto mc

:mainloop
set /a loopcount=loopcount-1
if %loopcount%==0 goto exitloop
goto loop

:exitloop
echo %startTime%
echo %time%