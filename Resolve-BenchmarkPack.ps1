[
  {
    "id": "CIS.M365.1.1.1",
    "title": "Ensure Security Defaults are disabled when Conditional Access is in use",
    "section": "1.1 — Identity and Access Management",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Security Defaults and Conditional Access are mutually exclusive. If CA policies are deployed, Security Defaults must be disabled to avoid conflicts.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults",
    "assertion": "\nparam($Connections)\n$policy = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy'\n$caPolicies = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies'\n$caEnabled = ($caPolicies.value | Where-Object { $_.state -eq 'enabled' }).Count -gt 0\n$sdEnabled = $policy.isEnabled\nif ($caEnabled -and $sdEnabled) {\nreturn @{ Pass = $false; Detail = 'Security Defaults is ENABLED while Conditional Access policies are active — this causes conflicts.'; Evidence = $policy }\n}\nreturn @{ Pass = $true; Detail = 'Security Defaults is correctly disabled while CA policies are in use.'; Evidence = $policy }\n"
  },
  {
    "id": "CIS.M365.1.1.2",
    "title": "Ensure that only organizationally managed/approved public groups exist",
    "section": "1.1 — Identity and Access Management",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Public Microsoft 365 Groups allow anyone in the organization to join and view content. Unmanaged public groups increase data exposure risk.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/solutions/collaboration-governance-overview",
    "assertion": "\nparam($Connections)\n$groups = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/groups?$filter=groupTypes/any(c:c+eq+''Unified'')&$select=id,displayName,visibility'\n$publicGroups = $groups.value | Where-Object { $_.visibility -eq 'Public' }\nif ($publicGroups.Count -gt 0) {\nreturn @{ Pass = $false; Detail = \"$($publicGroups.Count) public Microsoft 365 group(s) found. Review and convert to Private where appropriate.\"; Evidence = $publicGroups }\n}\nreturn @{ Pass = $true; Detail = 'No unmanaged public Microsoft 365 groups found.'; Evidence = @() }\n"
  },
  {
    "id": "CIS.M365.1.1.3",
    "title": "Ensure the 'Password expiration policy' is set to 'Set passwords to never expire'",
    "section": "1.1 — Identity and Access Management",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Modern authentication with MFA makes periodic password expiration counterproductive. CIS recommends passwords never expire when MFA is enforced.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoft-365/admin/misc/password-policy-recommendations",
    "assertion": "\nparam($Connections)\n$domains = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/domains'\n$expiring = $domains.value | Where-Object { $_.passwordValidityPeriodInDays -ne 2147483647 -and $_.passwordValidityPeriodInDays -ne $null }\nif ($expiring.Count -gt 0) {\nreturn @{ Pass = $false; Detail = \"$($expiring.Count) domain(s) have password expiration configured. Set to 'Never Expire'.\"; Evidence = $expiring }\n}\nreturn @{ Pass = $true; Detail = 'All domains are configured with passwords set to never expire.'; Evidence = $domains.value }\n"
  },
  {
    "id": "CIS.M365.1.2.1",
    "title": "Ensure that 'Multi-Factor Auth Status' is 'Enabled' for all privileged users",
    "section": "1.2 — MFA",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Privileged accounts without MFA are a critical attack surface. All Global Admins and privileged role members must have MFA enforced.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/authentication/tutorial-enable-azure-mfa",
    "assertion": "\nparam($Connections)\n$roles = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/directoryRoles'\n$adminRole = $roles.value | Where-Object { $_.displayName -eq 'Global Administrator' }\nif (-not $adminRole) {\nreturn @{ Pass = $false; Detail = 'Could not locate Global Administrator role.'; Evidence = $null }\n}\n$members = Invoke-MgGraphRequest -Method GET -Uri \"https://graph.microsoft.com/v1.0/directoryRoles/$($adminRole.id)/members\"\n$evidence = @{ RoleId = $adminRole.id; MemberCount = $members.value.Count; Members = $members.value | Select-Object id, displayName, userPrincipalName }\nreturn @{ Pass = $true; Detail = \"$($members.value.Count) Global Admin(s) found. Verify MFA registration via Entra ID > Users > MFA per-user or via CA policy coverage.\"; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.1.3.1",
    "title": "Ensure that 'Restrict access to Microsoft Entra admin center' is set to 'Yes'",
    "section": "1.3 — Admin Center Access",
    "level": 1,
    "assessmentStatus": "Manual",
    "description": "Non-admin users should be prevented from accessing the Entra admin center to reduce risk of accidental or malicious configuration changes.",
    "remediationUrl": "https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/users-default-permissions"
  }
]
