@echo off
set "registryPath=HKLM\Software\Policies\Google\Chrome"
set "valueName1=BrowserSignin"
set "valueType1=REG_DWORD"
set "valueData1=0"
set "valueName2=PrivacySandboxPromptEnabled"
set "valueType2=REG_DWORD"
set "valueData2=0"


reg add "%registryPath%" /f


reg add "%registryPath%" /v "%valueName1%" /t %valueType1% /d %valueData1% /f
reg add "%registryPath%" /v "%valueName2%" /t %valueType2% /d %valueData2% /f

