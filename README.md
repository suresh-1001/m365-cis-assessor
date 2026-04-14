# Benchmark Support Matrix

CIS Microsoft 365 Foundations Benchmark v6.0.1 — control coverage status.

---

## Entra ID / Graph (Section 1)

| Control ID | Title | Level | Status |
|---|---|---|---|
| CIS.M365.1.1.1 | Security Defaults disabled when CA in use | 1 | ✅ Automated |
| CIS.M365.1.1.2 | Only approved public M365 Groups exist | 2 | ✅ Automated |
| CIS.M365.1.1.3 | Password expiration set to Never | 1 | ✅ Automated |
| CIS.M365.1.2.1 | MFA enabled for all privileged users | 1 | ✅ Automated |
| CIS.M365.1.3.1 | Restrict access to Entra admin center | 1 | 📋 Manual |
| CIS.M365.1.3.2 | Restrict non-admin users from creating tenants | 1 | ✅ Automated |
| CIS.M365.1.3.3 | Guest user access restrictions | 2 | ✅ Automated |
| CIS.M365.1.3.4 | User consent for apps restricted | 1 | ✅ Automated |

---

## Exchange Online (Section 2)

| Control ID | Title | Level | Status |
|---|---|---|---|
| CIS.M365.2.1.1 | DKIM enabled for all accepted domains | 1 | ✅ Automated |
| CIS.M365.2.1.2 | SPF records published for all domains | 1 | ✅ Automated |
| CIS.M365.2.1.3 | DMARC policy of quarantine or reject | 1 | ✅ Automated |
| CIS.M365.2.1.4 | Common Attachment Types Filter enabled | 1 | ✅ Automated |
| CIS.M365.2.1.5 | Safe Links policy enabled | 2 | ✅ Automated |
| CIS.M365.2.1.6 | Safe Attachments policy enabled | 2 | ✅ Automated |
| CIS.M365.2.1.7 | Anti-phishing policy configured | 1 | ✅ Automated |
| CIS.M365.2.1.8 | Outbound spam policy configured | 1 | ✅ Automated |

---

## Microsoft Teams (Section 3)

| Control ID | Title | Level | Status |
|---|---|---|---|
| CIS.M365.3.1.1 | External access restricted | 1 | ✅ Automated |
| CIS.M365.3.1.2 | Teams not enabled for anonymous join | 1 | ✅ Automated |
| CIS.M365.3.1.3 | Only org users can present in meetings | 2 | ✅ Automated |
| CIS.M365.3.1.4 | External participants cannot give/request control | 1 | ✅ Automated |
| CIS.M365.3.2.1 | Unmanaged external users cannot initiate contact | 1 | 📋 Manual |

---

## SharePoint / OneDrive (Section 4)

| Control ID | Title | Level | Status |
|---|---|---|---|
| CIS.M365.4.1.1 | SharePoint sharing restricted to org users | 1 | ✅ Automated |
| CIS.M365.4.1.2 | External sharing expiration set | 2 | ✅ Automated |
| CIS.M365.4.1.3 | OneDrive sharing restricted | 1 | ✅ Automated |
| CIS.M365.4.2.1 | Default link type set to specific people | 1 | ✅ Automated |
| CIS.M365.4.2.2 | Guest access set to expire | 2 | 📋 Manual |

---

## Legend

| Symbol | Meaning |
|---|---|
| ✅ Automated | Control is fully automated — assertion runs and collects evidence |
| 📋 Manual | Control requires human review — flagged in report with guidance |
| 🔄 In Progress | Control is being developed |
