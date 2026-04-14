[
  {
    "id": "CIS.M365.2.1.5",
    "title": "Ensure Safe Links policy is enabled for all users",
    "section": "2.1 — Exchange Online",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Safe Links rewrites URLs in email and Office documents to scan them at time-of-click, protecting against deferred phishing attacks where a URL becomes malicious after delivery.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-links-about",
    "assertion": "\nparam($Connections)\n$policies = Get-SafeLinksPolicy\n$rules    = Get-SafeLinksRule\n$enabled  = $policies | Where-Object { $_.IsEnabled -eq $true -and $_.EnableSafeLinksForEmail -eq $true }\n$hasRule  = $rules    | Where-Object { $_.State -eq 'Enabled' }\nif (-not $enabled -or -not $hasRule) {\nreturn @{ Pass = $false; Detail = 'No active Safe Links policy found with email scanning enabled. Create and enable a Safe Links policy covering all recipients.'; Evidence = ($policies | Select-Object Name, IsEnabled, EnableSafeLinksForEmail) }\n}\nreturn @{ Pass = $true; Detail = \"Safe Links is active: $($enabled.Count) enabled policy/policies found.\"; Evidence = ($policies | Select-Object Name, IsEnabled, EnableSafeLinksForEmail) }\n"
  },
  {
    "id": "CIS.M365.2.1.6",
    "title": "Ensure Safe Attachments policy is enabled for all users",
    "section": "2.1 — Exchange Online",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Safe Attachments detonates email attachments in a sandbox before delivery, catching zero-day malware that signature-based scanning misses.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/safe-attachments-about",
    "assertion": "\nparam($Connections)\n$policies = Get-SafeAttachmentPolicy\n$rules    = Get-SafeAttachmentRule\n$enabled  = $policies | Where-Object { $_.Enable -eq $true -and $_.Action -ne 'Allow' }\n$hasRule  = $rules    | Where-Object { $_.State -eq 'Enabled' }\nif (-not $enabled -or -not $hasRule) {\nreturn @{ Pass = $false; Detail = 'No active Safe Attachments policy found. Create and enable a policy with Block or DynamicDelivery action.'; Evidence = ($policies | Select-Object Name, Enable, Action) }\n}\nreturn @{ Pass = $true; Detail = \"Safe Attachments is active: $($enabled.Count) enabled policy/policies found.\"; Evidence = ($policies | Select-Object Name, Enable, Action) }\n"
  },
  {
    "id": "CIS.M365.2.1.7",
    "title": "Ensure the anti-phishing policy has been configured",
    "section": "2.1 — Exchange Online",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Anti-phishing policies in Defender for Office 365 protect against impersonation attacks, spoof intelligence, and mailbox intelligence-based phishing.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-policies-about",
    "assertion": "\nparam($Connections)\n$policies = Get-AntiPhishPolicy\n$default  = $policies | Where-Object { $_.IsDefault -eq $true }\n$custom   = $policies | Where-Object { $_.IsDefault -eq $false -and $_.Enabled -eq $true }\n$evidence = $policies | Select-Object Name, Enabled, IsDefault, EnableSpoofIntelligence, EnableMailboxIntelligence, PhishThresholdLevel\nif ($default.PhishThresholdLevel -lt 2 -and -not $custom) {\nreturn @{ Pass = $false; Detail = 'Anti-phishing policy is using default low-sensitivity settings. Increase PhishThresholdLevel to 2 or higher and enable spoof/mailbox intelligence.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'Anti-phishing policy is configured with appropriate sensitivity settings.'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.2.1.8",
    "title": "Ensure the outbound spam filter policy is configured",
    "section": "2.1 — Exchange Online",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Outbound spam filtering prevents compromised accounts from sending spam, which protects your domain reputation and helps avoid blocklisting.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/outbound-spam-filter-policy-configure",
    "assertion": "\nparam($Connections)\n$policy = Get-HostedOutboundSpamFilterPolicy -Identity Default\n$notifyAddress = $policy.BccSuspiciousOutboundMail -or $policy.NotifyOutboundSpam\n$evidence = $policy | Select-Object Name, BccSuspiciousOutboundMail, NotifyOutboundSpam, RecipientLimitExternalPerHour, RecipientLimitInternalPerHour\nif (-not $notifyAddress) {\nreturn @{ Pass = $false; Detail = 'Outbound spam policy does not have admin notification configured. Enable BccSuspiciousOutboundMail or NotifyOutboundSpam.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'Outbound spam filter policy is configured with admin notification.'; Evidence = $evidence }\n"
  }
]
