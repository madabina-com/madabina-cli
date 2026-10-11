Unicode true
RequestExecutionLevel user
SetCompressor /SOLID zlib

!ifndef VERSION
  !error "VERSION is required"
!endif
!ifndef ARCH
  !error "ARCH is required"
!endif
!ifndef SOURCE_DIR
  !error "SOURCE_DIR is required"
!endif
!ifndef OUTPUT_FILE
  !error "OUTPUT_FILE is required"
!endif

Name "Madabina CLI ${VERSION} (${ARCH})"
OutFile "${OUTPUT_FILE}"
InstallDir "$LOCALAPPDATA\Programs\Madabina CLI"
ShowInstDetails show
ShowUnInstDetails show

!include "MUI2.nsh"
!include "StrFunc.nsh"
${StrStr}
${StrRep}

!define MUI_ABORTWARNING
!define MUI_LICENSEPAGE_TEXT_TOP "Please review the Madabina CLI binary license."
!define MUI_LICENSEPAGE_BUTTON "I Agree"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SOURCE_DIR}\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Madabina CLI" SEC_MAIN
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File "${SOURCE_DIR}\madabina.exe"
  File "${SOURCE_DIR}\LICENSE"
  File "${SOURCE_DIR}\README.md"
  File "${SOURCE_DIR}\README.fr.md"
  File "${SOURCE_DIR}\README.ar.md"
  SetOutPath "$INSTDIR\third_party_licenses"
  File /r "${SOURCE_DIR}\third_party_licenses\*.*"

  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI" "DisplayName" "Madabina CLI ${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI" "Publisher" "Madabina LLC"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI" "UninstallString" '"$INSTDIR\Uninstall.exe"'

  ReadRegStr $0 HKCU "Environment" "Path"
  ${StrStr} $1 ";$0;" ";$INSTDIR;"
  StrCmp $1 "" 0 path_done
  StrCmp $0 "" 0 path_append
  WriteRegExpandStr HKCU "Environment" "Path" "$INSTDIR"
  Goto path_done
path_append:
  WriteRegExpandStr HKCU "Environment" "Path" "$0;$INSTDIR"
path_done:
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  ReadRegStr $0 HKCU "Environment" "Path"
  ${StrRep} $0 "$0" ";$INSTDIR" ""
  ${StrRep} $0 "$0" "$INSTDIR;" ""
  ${StrRep} $0 "$0" "$INSTDIR" ""
  WriteRegExpandStr HKCU "Environment" "Path" "$0"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\MadabinaCLI"
  Delete "$INSTDIR\madabina.exe"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\README.md"
  Delete "$INSTDIR\README.fr.md"
  Delete "$INSTDIR\README.ar.md"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR\third_party_licenses"
  RMDir "$INSTDIR"
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=5000
SectionEnd
