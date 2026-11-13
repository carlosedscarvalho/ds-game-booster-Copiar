
@echo off
chcp 65001 >nul
setlocal EnableExtensions
title DS Informatica - Game Booster V2.0
color 0B

:: ============================================================
:: DS INFORMATICA - GAME BOOSTER V2.0
:: AGGRESSIVE PERFORMANCE PROFILE
:: Windows 10 / 11
:: ============================================================

set "VERSION=2.0"
set "ROOT=%ProgramData%\DS Informatica\Game Booster"
set "LOG=%ROOT%\GameBooster.log"
set "LASTBACKUP=%ROOT%\lastbackup.txt"

:: ============================================================
:: ADMINISTRADOR
:: ============================================================

fltmc >nul 2>&1

if errorlevel 1 (
    echo.
    echo  Solicitando permissao de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath $env:ComSpec -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

if not exist "%ROOT%" mkdir "%ROOT%" >nul 2>&1

:: ============================================================
:: IDENTIFICAR WINDOWS
:: ============================================================

set "WINDOWS=Windows nao identificado"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption" 2^>nul') do (
    set "WINDOWS=%%A"
)

:: ============================================================
:: MENU PRINCIPAL
:: ============================================================

:MENU
cls
echo.
echo  ============================================================
echo.
echo                     DS INFORMATICA
echo                       GAME BOOSTER
echo.
echo                  AGGRESSIVE PERFORMANCE
echo.
echo  ============================================================
echo.
echo    COMPUTADOR : %COMPUTERNAME%
echo    WINDOWS    : %WINDOWS%
echo    VERSAO     : %VERSION%
echo.
echo  ------------------------------------------------------------
echo.
echo    [1] APLICAR OTIMIZACAO AGGRESSIVE
echo.
echo    [2] RESTAURAR CONFIGURACOES ANTERIORES
echo.
echo    [3] LIMPEZA COMPLETA DO WINDOWS
echo.
echo    [4] DIAGNOSTICO DE HARDWARE
echo.
echo    [5] ANALISAR PROGRAMAS DE INICIALIZACAO
echo.
echo    [6] REPARAR WINDOWS (DISM + SFC)
echo.
echo    [7] VISUALIZAR RELATORIO
echo.
echo    [0] SAIR
echo.
echo  ------------------------------------------------------------
echo.
set "OPCAO="
set /p "OPCAO=    Selecione uma opcao: "

if "%OPCAO%"=="1" goto OTIMIZAR
if "%OPCAO%"=="2" goto RESTAURAR
if "%OPCAO%"=="3" goto LIMPEZA
if "%OPCAO%"=="4" goto DIAGNOSTICO
if "%OPCAO%"=="5" goto INICIALIZACAO
if "%OPCAO%"=="6" goto REPARAR
if "%OPCAO%"=="7" goto RELATORIO
if "%OPCAO%"=="0" exit /b

echo.
echo  Opcao invalida!
timeout /t 2 >nul
goto MENU

:: ============================================================
:: 1 - APLICAR OTIMIZACAO
:: ============================================================

:OTIMIZAR
cls
echo.
echo  ============================================================
echo                  AGGRESSIVE PERFORMANCE
echo  ============================================================
echo.
echo  ALTERACOES QUE SERAO APLICADAS:
echo.
echo  [1] Ativar plano de Alto Desempenho.
echo  [2] Ativar Windows Game Mode.
echo  [3] Desativar captura em segundo plano do Game DVR.
echo  [4] Criar backup das configuracoes originais.
echo.
echo  Defender, Firewall e Windows Update serao preservados.
echo.
choice /c SN /n /m "Deseja aplicar as otimizacoes? [S/N]: "

if errorlevel 2 goto MENU

:: ------------------------------------------------------------
:: CRIAR BACKUP
:: ------------------------------------------------------------

echo.
echo  Criando backup das configuracoes...

for /f %%A in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%A"

set "BACKUP=%ROOT%\Backup_%STAMP%"

mkdir "%BACKUP%" >nul 2>&1

if not exist "%BACKUP%\" (
    echo  ERRO: Nao foi possivel criar o backup.
    pause
    goto MENU
)

:: Salvar plano de energia atual

set "ORIGINAL_PLAN="

for /f "tokens=4" %%G in ('powercfg /getactivescheme 2^>nul') do (
    set "ORIGINAL_PLAN=%%G"
)

if not defined ORIGINAL_PLAN (
    echo  ERRO: Nao foi possivel identificar o plano de energia.
    rmdir "%BACKUP%" 2>nul
    pause
    goto MENU
)

echo %ORIGINAL_PLAN%>"%BACKUP%\powerplan.txt"

:: Exportar configuracoes do Registro

reg export "HKCU\Software\Microsoft\GameBar" "%BACKUP%\GameBar.reg" /y >nul 2>&1

reg export "HKCU\System\GameConfigStore" "%BACKUP%\GameConfigStore.reg" /y >nul 2>&1

reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" "%BACKUP%\GameDVR.reg" /y >nul 2>&1

echo %BACKUP%>"%LASTBACKUP%"

call :LOG Backup criado: %BACKUP%

:: ------------------------------------------------------------
:: ATIVAR ALTO DESEMPENHO
:: ------------------------------------------------------------

echo.
echo  [1/3] Configurando plano de energia...

powercfg /setactive SCHEME_MIN >nul 2>&1

if errorlevel 1 (
    echo  Nao foi possivel ativar Alto Desempenho.
    call :LOG Falha ao ativar plano de energia.
) else (
    echo  Alto Desempenho ativado.
    call :LOG Plano Alto Desempenho ativado.
)

:: ------------------------------------------------------------
:: ATIVAR GAME MODE
:: ------------------------------------------------------------

echo.
echo  [2/3] Ativando Windows Game Mode...

reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1

if errorlevel 1 (
    echo  Erro ao configurar Game Mode.
    call :LOG Erro na configuracao Game Mode.
) else (
    echo  Game Mode configurado.
    call :LOG Game Mode ativado.
)

:: ------------------------------------------------------------
:: DESATIVAR CAPTURA EM SEGUNDO PLANO
:: ------------------------------------------------------------

echo.
echo  [3/3] Ajustando captura de jogos...

reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo  Captura em segundo plano desativada.
call :LOG Captura Game DVR desativada.

:: ------------------------------------------------------------
:: FINALIZAR
:: ------------------------------------------------------------

echo.
echo  ============================================================
echo                  OTIMIZACAO CONCLUIDA
echo  ============================================================
echo.
echo  Backup salvo em:
echo  %BACKUP%
echo.
echo  Algumas configuracoes podem exigir reinicializacao.
echo.
echo  As alteracoes podem ser revertidas pelo menu principal.
echo.

call :LOG Otimizacao aplicada.

pause
goto MENU

:: ============================================================
:: 2 - RESTAURAR CONFIGURACOES
:: ============================================================

:RESTAURAR
cls
echo.
echo  ============================================================
echo                   RESTAURAR CONFIGURACOES
echo  ============================================================
echo.

if not exist "%LASTBACKUP%" (
    echo  Nenhum backup encontrado.
    pause
    goto MENU
)

set "BACKUP="

set /p "BACKUP="<"%LASTBACKUP%"

if not exist "%BACKUP%\powerplan.txt" (
    echo  Backup incompleto ou inexistente.
    pause
    goto MENU
)

echo  Backup localizado:
echo.
echo  %BACKUP%
echo.
choice /c SN /n /m "Deseja restaurar as configuracoes? [S/N]: "

if errorlevel 2 goto MENU

:: Restaurar plano de energia

set "ORIGINAL_PLAN="

set /p "ORIGINAL_PLAN="<"%BACKUP%\powerplan.txt"

echo.
echo  Restaurando plano de energia...

powercfg /setactive %ORIGINAL_PLAN% >nul 2>&1

if errorlevel 1 (
    echo  Nao foi possivel restaurar o plano de energia.
    call :LOG Falha ao restaurar plano de energia.
) else (
    echo  Plano de energia restaurado.
    call :LOG Plano de energia restaurado.
)

:: Remover valores aplicados pelo programa

echo.
echo  Restaurando configuracoes do Registro...

reg delete "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /f >nul 2>&1

reg delete "HKCU\System\GameConfigStore" /v GameDVR_Enabled /f >nul 2>&1

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /f >nul 2>&1

:: Importar backups originais

if exist "%BACKUP%\GameBar.reg" (
    reg import "%BACKUP%\GameBar.reg" >nul 2>&1
)

if exist "%BACKUP%\GameConfigStore.reg" (
    reg import "%BACKUP%\GameConfigStore.reg" >nul 2>&1
)

if exist "%BACKUP%\GameDVR.reg" (
    reg import "%BACKUP%\GameDVR.reg" >nul 2>&1
)

call :LOG Restauracao das configuracoes executada.

echo.
echo  ============================================================
echo                   RESTAURACAO CONCLUIDA
echo  ============================================================
echo.
echo  Reinicie o computador para aplicar todas as alteracoes.
echo.
echo  O backup foi preservado.
echo.

pause
goto MENU

:: ============================================================
:: 3 - LIMPEZA COMPLETA
:: ============================================================

:LIMPEZA
cls
echo.
echo  ============================================================
echo                    LIMPEZA DO WINDOWS
echo  ============================================================
echo.
echo  [1] Temporarios do usuario
echo  [2] Temporarios do Windows
echo  [3] Cache de miniaturas
echo  [4] Lixeira (opcional)
echo.
choice /c SN /n /m "Deseja iniciar a limpeza? [S/N]: "

if errorlevel 2 goto MENU

call :GET_FREE_SPACE FREE_BEFORE

echo.
echo  [1/4] Temporarios do usuario...

if defined TEMP (
    if exist "%TEMP%\" (
        del /f /s /q "%TEMP%\*" >nul 2>&1

        for /d %%D in ("%TEMP%\*") do (
            rd /s /q "%%~fD" >nul 2>&1
        )
    )
)

echo  Concluido.

echo.
echo  [2/4] Temporarios do Windows...

if exist "%WINDIR%\Temp\" (
    del /f /s /q "%WINDIR%\Temp\*" >nul 2>&1

    for /d %%D in ("%WINDIR%\Temp\*") do (
        rd /s /q "%%~fD" >nul 2>&1
    )
)

echo  Concluido.

echo.
echo  [3/4] Cache de miniaturas...

if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer\" (
    del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
)

echo  Concluido.

echo.
echo  [4/4] Lixeira...

choice /c SN /n /m "Deseja esvaziar a lixeira da unidade do Windows? [S/N]: "

if errorlevel 2 goto FINALIZAR_LIMPEZA

powershell -NoProfile -Command "Clear-RecycleBin -DriveLetter $env:SystemDrive.Substring(0,1) -Force -ErrorAction Stop" >nul 2>&1

if errorlevel 1 (
    echo  Nao foi possivel esvaziar a lixeira.
) else (
    echo  Lixeira esvaziada.
)

:FINALIZAR_LIMPEZA

call :GET_FREE_SPACE FREE_AFTER

echo.
echo  ============================================================
echo                    LIMPEZA FINALIZADA
echo  ============================================================
echo.
echo  ESPACO LIVRE ANTES : %FREE_BEFORE% bytes
echo  ESPACO LIVRE DEPOIS: %FREE_AFTER% bytes
echo.

call :LOG Limpeza de temporarios executada.

pause
goto MENU

:: ============================================================
:: 4 - DIAGNOSTICO DE HARDWARE
:: ============================================================

:DIAGNOSTICO
cls
echo.
echo  ============================================================
echo                   DIAGNOSTICO DO PC
echo  ============================================================
echo.

echo  PROCESSADOR:
powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object -First 1 Name,NumberOfCores,NumberOfLogicalProcessors | Format-List"

echo  MEMORIA:
powershell -NoProfile -Command "Get-CimInstance Win32_ComputerSystem | ForEach-Object { 'RAM instalada: {0:N2} GB' -f ($_.TotalPhysicalMemory/1GB) }"

echo.
echo  PLACA DE VIDEO:
powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion | Format-Table -AutoSize"

echo.
echo  UNIDADES DE DISCO:

powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,@{N='Total GB';E={[math]::Round($_.Size/1GB,2)}},@{N='Livre GB';E={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize"

echo.
echo  PLANO DE ENERGIA:

powercfg /getactivescheme

echo.
echo  TOP 10 PROCESSOS POR MEMORIA:

powershell -NoProfile -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 ProcessName,@{N='RAM MB';E={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize"

pause
goto MENU

:: ============================================================
:: 5 - ANALISAR INICIALIZACAO
:: ============================================================

:INICIALIZACAO
cls
echo.
echo  ============================================================
echo                 PROGRAMAS DE INICIALIZACAO
echo  ============================================================
echo.
echo  Identificando aplicativos iniciados com Windows...
echo.
echo  Nenhum programa sera desativado automaticamente.
echo.

powershell -NoProfile -Command "Get-CimInstance Win32_StartupCommand | Select-Object Name,Location,Command | Format-List"

echo.
echo  Analise concluida.
echo.
echo  Avalie os programas antes de desativar qualquer item.
echo.

pause
goto MENU

:: ============================================================
:: 6 - REPARAR WINDOWS
:: ============================================================

:REPARAR
cls
echo.
echo  ============================================================
echo                    REPARAR WINDOWS
echo  ============================================================
echo.
echo  Este procedimento executara:
echo.
echo  [1] DISM /Online /Cleanup-Image /RestoreHealth
echo  [2] SFC /Scannow
echo.
echo  O processo pode demorar varios minutos.
echo.
choice /c SN /n /m "Deseja iniciar a verificacao? [S/N]: "

if errorlevel 2 goto MENU

echo.
echo  Iniciando DISM...
echo.

call :LOG Inicio do DISM.

DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo  DISM finalizado.
echo.
echo  Iniciando SFC...
echo.

call :LOG Inicio do SFC.

sfc /scannow

echo.
echo  Verificacao concluida.
echo.

call :LOG Verificacao DISM e SFC finalizada.

pause
goto MENU

:: ============================================================
:: 7 - RELATORIO
:: ============================================================

:RELATORIO
cls
echo.
echo  ============================================================
echo                    RELATORIO DE ATIVIDADES
echo  ============================================================
echo.

if exist "%LOG%" (
    type "%LOG%"
) else (
    echo  Nenhum registro encontrado.
)

echo.
pause
goto MENU

:: ============================================================
:: FUNCAO - ESPACO LIVRE
:: ============================================================

:GET_FREE_SPACE

set "%~1=Indisponivel"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_LogicalDisk | Where-Object DeviceID -eq $env:SystemDrive).FreeSpace" 2^>nul') do (
    set "%~1=%%A"
)

exit /b

:: ============================================================
:: FUNCAO - REGISTRO
:: ============================================================

:LOG

>>"%LOG%" echo [%date% %time%] %*

exit /b
