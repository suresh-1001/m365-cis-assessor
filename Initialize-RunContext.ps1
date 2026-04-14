[
  {
    "id": "CIS.M365.1.3.2",
    "title": "Ensure that 'Restrict non-admin users from creating tenants' is set to 'Yes'",
    "section": "1.3 — Admin Center Access",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Allowing non-admin users to create new Entra tenants introduces risk of shadow IT and data exfiltration via unmanaged tenants.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/users-default-permissions",
    "assertion": "\nparam($Connections)\n$policy = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'\n$restricted = $policy.defaultUserRolePermissions.allowedToCreateTenants -eq $false\nif (-not $restricted) {\nreturn @{ Pass = $false; Detail = 'Non-admin users are allowed to create new Entra tenants. Set allowedToCreateTenants to false.'; Evidence = $policy.defaultUserRolePermissions }\n}\nreturn @{ Pass = $true; Detail = 'Non-admin users are restricted from creating new tenants.'; Evidence = $policy.defaultUserRolePermissions }\n"
  },
  {
    "id": "CIS.M365.1.3.3",
    "title": "Ensure guest user access restrictions are configured",
    "section": "1.3 — Admin Center Access",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Guest users should have limited visibility into directory objects to reduce data exposure to external parties.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/users-default-permissions#restrict-member-users-default-permissions",
    "assertion": "\nparam($Connections)\n$policy = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'\n$guestRole = $policy.guestUserRoleId\n# b67df4b8-8c5c-4ac9-8635-3a66f0400bf5 = Restricted Guest (most restricted)\n# 10dae51f-b6af-4016-8d66-8c2a99b929b3 = Guest (default)\n# a0b1b346-4d3e-4e8b-98f8-753987be4970 = Member (least restricted - bad)\n$restricted = $guestRole -in @('b67df4b8-8c5c-4ac9-8635-3a66f0400bf5','10dae51f-b6af-4016-8d66-8c2a99b929b3')\nif (-not $restricted) {\nreturn @{ Pass = $false; Detail = 'Guest users have Member-level access. Restrict to Guest or Restricted Guest role.'; Evidence = @{ GuestUserRoleId = $guestRole } }\n}\nreturn @{ Pass = $true; Detail = 'Guest user access is appropriately restricted.'; Evidence = @{ GuestUserRoleId = $guestRole } }\n"
  },
  {
    "id": "CIS.M365.1.3.4",
    "title": "Ensure user consent to apps accessing company data on their behalf is restricted",
    "section": "1.3 — Admin Center Access",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Allowing users to consent to third-party apps without admin review creates risk of OAuth phishing and data exfiltration via malicious app permissions.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent",
    "assertion": "\nparam($Connections)\n$policy = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'\n$consentSetting = $policy.defaultUserRolePermissions.allowedToCreateApps\n$permPolicy = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/policies/permissionGrantPolicies'\n$userConsentEnabled = $permPolicy.value | Where-Object { $_.id -eq 'microsoft-user-default-legacy' }\nif ($userConsentEnabled) {\nreturn @{ Pass = $false; Detail = 'User consent to apps is using the legacy permissive policy. Configure admin consent workflow instead.'; Evidence = $permPolicy.value }\n}\nreturn @{ Pass = $true; Detail = 'User consent to apps is restricted — admin approval required.'; Evidence = $permPolicy.value }\n"
  }
]
