# Permissions Matrix

Full list of permissions required by the M365 CIS Assessor app registration.

---

## Microsoft Graph — Application Permissions

| Permission | Controls Using It | Why Needed |
|---|---|---|
| `Policy.Read.All` | CIS.M365.1.1.x CA policy controls | Read Conditional Access and identity policies |
| `Directory.Read.All` | CIS.M365.1.x user, group, role controls | Read users, groups, directory roles, devices |
| `AuditLog.Read.All` | CIS.M365.1.3.x audit controls | Read unified audit log settings |
| `IdentityRiskyUser.Read.All` | CIS.M365.1.2.x MFA / identity risk controls | Read risky user detections |
| `SecurityEvents.Read.All` | CIS.M365.5.x Defender controls | Read Defender security alerts |
| `Organization.Read.All` | CIS.M365.1.1.3 password policy | Read org-level settings and domain config |
| `RoleManagement.Read.All` | CIS.M365.1.2.1 privileged user MFA | Read directory role assignments |
| `TeamworkAppSettings.Read.All` | CIS.M365.3.x Teams controls | Read Teams tenant-wide settings |
| `Team.ReadBasic.All` | CIS.M365.3.x Teams controls | Read Teams configuration |
| `Sites.FullControl.All` | CIS.M365.4.x SharePoint controls | Read SharePoint tenant settings (read-only operations only) |

**All permissions are Application type (not Delegated). Admin consent required.**

---

## Exchange Online — App Role

Exchange Online cmdlets require a service principal with an Exchange role assignment — Graph permissions do not cover Exchange PowerShell.

| Role | Controls Using It |
|---|---|
| `View-Only Organization Management` | All Exchange CIS controls (DKIM, DMARC, malware policy, safe links, etc.) |

Setup:
```powershell
New-ServicePrincipal -AppId '<client-id>' -DisplayName 'M365-CIS-Assessor'
Add-RoleGroupMember -Identity 'View-Only Organization Management' -Member 'M365-CIS-Assessor'
```

---

## Teams — Application Permission

Teams connectivity uses `Connect-MicrosoftTeams` with the same certificate. No separate role assignment needed beyond the Graph permissions above.

---

## SharePoint — PnP App Permission

PnP.PowerShell connects to the SharePoint Admin Center using the same certificate. The `Sites.FullControl.All` Graph permission covers tenant-level read access.

> The assessor only reads SharePoint configuration — it does not modify any settings.

---

## Principle of Least Privilege Notes

- All permissions are **read-only** in practice — no write operations are performed
- `Sites.FullControl.All` is required by the PnP module for admin-level tenant reads; there is no `Sites.Read.All` equivalent at the tenant admin scope
- The certificate is the only credential — no client secrets, no passwords stored anywhere
