
; ============================================================
; Bridge Linux Setup
; Classic NSIS installer
; NO MUI / NO MUI2
; ============================================================

Unicode True

!include "nsDialogs.nsh"
!include "LogicLib.nsh"

; ------------------------------------------------------------
; General
; ------------------------------------------------------------

Name "Bridge Linux"
Caption "Bridge Linux Setup"

OutFile "Bridge-Linux-Setup.exe"

InstallDir "$PROGRAMFILES\Bridge Linux"

RequestExecutionLevel admin

; ------------------------------------------------------------
; Version information
; ------------------------------------------------------------

VIProductVersion "1.0.0.0"
VIFileVersion "1.0.0.0"

VIAddVersionKey "ProductName" "Bridge Linux"
VIAddVersionKey "CompanyName" "Scramix"
VIAddVersionKey "FileDescription" "Bridge Linux Setup"
VIAddVersionKey "FileVersion" "1.0.0"
VIAddVersionKey "ProductVersion" "1.0.0"
VIAddVersionKey "LegalCopyright" "Copyright © 2026 Scramix"

; ------------------------------------------------------------
; Variables
; ------------------------------------------------------------

Var SetupMode

Var ModeDialog
Var CustomRadio
Var EasyRadio

Var TransferFinishCheck

; ------------------------------------------------------------
; Pages
; ------------------------------------------------------------

PageEx license
    LicenseData "LICENSE.txt"
    LicenseForceSelection checkbox
PageExEnd

Page custom ModePageCreate ModePageLeave

PageEx directory
    DirText "Choose the folder where Bridge Linux will be installed."
PageExEnd

Page components

Page instfiles

Page custom FinishPageCreate FinishPageLeave

; ------------------------------------------------------------
; Uninstaller pages
; ------------------------------------------------------------

UninstPage uninstConfirm
UninstPage instfiles

; ------------------------------------------------------------
; Install Sections
; ------------------------------------------------------------

Section "Bridge Linux" SEC_CORE

    SectionIn RO

    WriteUninstaller "$INSTDIR\Uninstaller.exe"

    SetOutPath "$INSTDIR"

    ; Add your actual Bridge Linux files here later.
    ;
    ; File "BridgeLinux.exe"
    ; File "README.txt"
    ; File "Getting Started.txt"

SectionEnd

; ------------------------------------------------------------
; Bridge Linux USB Creator
; Always installed and cannot be unchecked.
; ------------------------------------------------------------

Section "Bridge Linux USB Creator" SEC_USB

    SectionIn RO

    SetOutPath "$INSTDIR"

    File /nonfatal "BridgeUSB.exe"

SectionEnd

; ------------------------------------------------------------
; Documentation
; ------------------------------------------------------------

Section "Documentation" SEC_DOCS

    SetOutPath "$INSTDIR"

    File /nonfatal "Docs.chm"

SectionEnd


; ------------------------------------------------------------
; File transfer support
; ------------------------------------------------------------

Section "Support for transferring files" SEC_TRANSFER

    SetOutPath "$INSTDIR"

    File /nonfatal "BridgeFileTransfer.exe"

SectionEnd

; ------------------------------------------------------------
; Mode selection page
; ------------------------------------------------------------

Function ModePageCreate

    nsDialogs::Create 1018
    Pop $ModeDialog

    ${If} $ModeDialog == error
        Abort
    ${EndIf}

    ; Header
    ${NSD_CreateLabel} 0 0 100% 20u \
        "Setup wants to know which mode is better for your preference."

    Pop $0

    ; Custom Mode
    ${NSD_CreateRadioButton} 0 32u 100% 12u \
        "Custom Mode"

    Pop $CustomRadio

    ; Easy Mode
    ${NSD_CreateRadioButton} 0 52u 100% 12u \
        "Easy Mode"

    Pop $EasyRadio

    ; Description
    ${NSD_CreateLabel} 18u 72u 90% 35u \
        "Easy Mode is better for newcomers coming from Windows."

    Pop $0

    ; Easy Mode selected by default.
    SendMessage $EasyRadio ${BM_CLICK} 0 0

    nsDialogs::Show

FunctionEnd


Function ModePageLeave

    ${NSD_GetState} $CustomRadio $0

    ${If} $0 == ${BST_CHECKED}

        StrCpy $SetupMode "custom"

        ; USB Creator: selected + read-only
        SectionSetFlags ${SEC_USB} 17

    ${Else}

        StrCpy $SetupMode "easy"

        ; USB Creator: selected + read-only
        SectionSetFlags ${SEC_USB} 17

        ; Documentation: selected
        SectionSetFlags ${SEC_DOCS} ${SF_SELECTED}

        ; File transfer: selected
        SectionSetFlags ${SEC_TRANSFER} ${SF_SELECTED}

        ; Easy Mode uses the default installation path.
        StrCpy $INSTDIR "$PROGRAMFILES\Bridge Linux"

    ${EndIf}

FunctionEnd

; ------------------------------------------------------------
; Directory page
; ------------------------------------------------------------

Function .onVerifyInstDir

    ; Easy Mode must not allow the user to change the path.

    ${If} $SetupMode == "easy"

        StrCmp $INSTDIR "$PROGRAMFILES\Bridge Linux" +2 0

        StrCpy $INSTDIR "$PROGRAMFILES\Bridge Linux"

    ${EndIf}

FunctionEnd

; ------------------------------------------------------------
; Initialization
; ------------------------------------------------------------

Function .onInit

    ; Default to Easy Mode.
    StrCpy $SetupMode "easy"

    ; Default installation directory.
    StrCpy $INSTDIR "$PROGRAMFILES\Bridge Linux"

FunctionEnd

; ------------------------------------------------------------
; Custom Finish Page
; ------------------------------------------------------------

Function FinishPageCreate

    nsDialogs::Create 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 20u \
        "Bridge Linux has been installed successfully."

    Pop $0

    ${NSD_CreateLabel} 0 30u 100% 20u \
        "Would you like to transfer your files from Windows to Bridge Linux?"

    Pop $0

    ${NSD_CreateCheckBox} 0 55u 100% 12u \
        "I would like to transfer my files from Windows to Bridge Linux"

    Pop $TransferFinishCheck

    nsDialogs::Show

FunctionEnd


Function FinishPageLeave

    ${NSD_GetState} $TransferFinishCheck $0

    ${If} $0 == ${BST_CHECKED}

        IfFileExists "$INSTDIR\BridgeFileTransfer.exe" TransferExists TransferMissing

        TransferExists:
            Exec "$INSTDIR\BridgeFileTransfer.exe"
            Return

        TransferMissing:
            MessageBox MB_ICONEXCLAMATION \
                "The Bridge Linux file transfer tool could not be found.$\r$\n$\r$\nPlease reinstall Bridge Linux Setup."

    ${EndIf}

FunctionEnd

; ------------------------------------------------------------
; Uninstaller
; ------------------------------------------------------------

Section "Uninstall"

    Delete "$INSTDIR\BridgeUSB.exe"
    Delete "$INSTDIR\Uninstaller.exe"
	Delete "$INSTDIR\BridgeFileTransfer.exe"
	Delete "$INSTDIR\Docs.chm"

    RMDir "$INSTDIR"

SectionEnd
