# BridgeLinuxSetup.nsi

As of right now, there are some dead entries in `BridgeLinuxSetup.nsi`. However, those dead entries will be fixed in the future once I make the actual Bridge Linux operating system.

There are some dead entries to files that do not exist as of the time of writing this, like:

    TransferExists:
        Exec "$INSTDIR\BridgeFileTransfer.exe"
        Return

    Delete "$INSTDIR\BridgeUSB.exe"

`BridgeUSB.exe` and `BridgeFileTransfer.exe` have not had their code written yet. This is why there are dead entries for all of these.
