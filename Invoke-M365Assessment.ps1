[
  {
    "id": "CIS.M365.4.1.1",
    "title": "Ensure SharePoint external sharing is restricted to existing guests or org users only",
    "section": "4.1 — SharePoint / OneDrive",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Allowing SharePoint to share content with anyone via anonymous links ('Anyone') creates uncontrolled data exposure with no authentication required.",
    "remediationUrl": "https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off",
    "assertion": "\nparam($Connections)\n$tenant = Get-PnPTenant\n$evidence = $tenant | Select-Object SharingCapability, DefaultSharingLinkType, RequireAnonymousLinksExpireInDays\n# 0=Disabled, 1=ExternalUserSharingOnly, 2=ExternalUserAndGuestSharing(Anyone), 3=ExistingExternalUserSharingOnly\nif ($tenant.SharingCapability -eq 'ExternalUserAndGuestSharing') {\nreturn @{ Pass = $false; Detail = 'SharePoint external sharing is set to Anyone (anonymous links). Restrict to ExistingExternalUserSharingOnly or ExternalUserSharingOnly.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = \"SharePoint sharing is set to: $($tenant.SharingCapability)\"; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.4.1.2",
    "title": "Ensure external sharing links have an expiration date set",
    "section": "4.1 — SharePoint / OneDrive",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Anonymous sharing links without expiration dates remain active indefinitely, allowing access long after the intended sharing period ends.",
    "remediationUrl": "https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off",
    "assertion": "\nparam($Connections)\n$tenant = Get-PnPTenant\n$evidence = $tenant | Select-Object RequireAnonymousLinksExpireInDays, ExternalUserExpireInDays\n$anonExpiry = $tenant.RequireAnonymousLinksExpireInDays\nif ($anonExpiry -le 0 -or $null -eq $anonExpiry) {\nreturn @{ Pass = $false; Detail = 'Anonymous sharing links do not expire. Set RequireAnonymousLinksExpireInDays to 30 or fewer days.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = \"Anonymous links expire after $anonExpiry day(s).\"; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.4.1.3",
    "title": "Ensure OneDrive external sharing is restricted",
    "section": "4.1 — SharePoint / OneDrive",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "OneDrive sharing settings should be at least as restrictive as SharePoint tenant-level settings to prevent data leakage through personal storage.",
    "remediationUrl": "https://learn.microsoft.com/en-us/sharepoint/turn-external-sharing-on-or-off",
    "assertion": "\nparam($Connections)\n$tenant = Get-PnPTenant\n$evidence = $tenant | Select-Object SharingCapability, OneDriveSharingCapability\n$spLevel  = $tenant.SharingCapability\n$odLevel  = $tenant.OneDriveSharingCapability\n# OneDrive should never be more permissive than SharePoint\n$sharingOrder = @('Disabled','ExistingExternalUserSharingOnly','ExternalUserSharingOnly','ExternalUserAndGuestSharing')\n$spIndex = $sharingOrder.IndexOf($spLevel)\n$odIndex = $sharingOrder.IndexOf($odLevel)\nif ($odIndex -gt $spIndex) {\nreturn @{ Pass = $false; Detail = \"OneDrive sharing ($odLevel) is more permissive than SharePoint ($spLevel). Align OneDrive to match or be more restrictive than SharePoint.\"; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = \"OneDrive sharing ($odLevel) is aligned with or more restrictive than SharePoint ($spLevel).\"; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.4.2.1",
    "title": "Ensure the default sharing link type is set to 'Specific people'",
    "section": "4.2 — SharePoint Link Settings",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "The default sharing link type determines what users see when they click 'Share'. Setting it to 'Specific people' prevents accidental broad sharing and encourages intentional access grants.",
    "remediationUrl": "https://learn.microsoft.com/en-us/sharepoint/change-default-sharing-link",
    "assertion": "\nparam($Connections)\n$tenant = Get-PnPTenant\n$evidence = $tenant | Select-Object DefaultSharingLinkType\n# 0=None(direct), 1=View, 2=Edit, 3=AnonymousAccess — DefaultSharingLinkType should be Direct(specific people)\nif ($tenant.DefaultSharingLinkType -ne 'Direct') {\nreturn @{ Pass = $false; Detail = \"Default sharing link type is '$($tenant.DefaultSharingLinkType)'. Set to 'Direct' (Specific people) to prevent accidental broad sharing.\"; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'Default sharing link type is set to Specific people (Direct).'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.4.2.2",
    "title": "Ensure guest access to SharePoint sites is set to expire",
    "section": "4.2 — SharePoint Link Settings",
    "level": 2,
    "assessmentStatus": "Manual",
    "description": "Guest access that never expires allows former collaborators, vendors, or contractors to retain access to SharePoint content indefinitely after the relationship ends.",
    "remediationUrl": "https://learn.microsoft.com/en-us/sharepoint/sharepoint-azureb2b-integration"
  }
]
