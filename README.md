# BitLocker-to-Go-Removable-Drives
Automates BitLocker recovery key escrow for USB drives using PowerShell and a SYSTEM-level scheduled task. Detects BitLocker encryption events, identifies removable drives, and securely uploads recovery keys to Microsoft Entra ID without user interaction.

Script Overview: Automated BitLocker Recovery Key Escrow for Removable Storage

This solution uses PowerShell and a Windows Scheduled Task to automatically escrow BitLocker recovery keys for removable USB drives to Microsoft Entra ID.

The PowerShell script first detects connected USB storage devices and resolves their logical drive letters. It then queries BitLocker for the encrypted volume and securely uploads the associated recovery key protector to Microsoft Entra ID, ensuring the key is centrally available for recovery.

To make this process automatic and reliable, the script also generates a Scheduled Task (defined via XML). The task is configured to:

Trigger from BitLocker event logs when encryption activity occurs

Run under the SYSTEM account with the highest privileges

Execute silently in the background without user interaction

The scheduled task ensures that whenever a user encrypts a removable drive, the recovery key is escrowed immediately, removing any dependency on users to save or print recovery keys.

This approach closes a common BitLocker gap for removable storage while remaining fully compatible with Intune-managed devices.
