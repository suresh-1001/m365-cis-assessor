[
  {
    "id": "CIS.M365.3.1.1",
    "title": "Ensure external access in Teams is restricted",
    "section": "3.1 — Microsoft Teams",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Unrestricted external access allows users from any Teams tenant to communicate with your users, increasing phishing and data exfiltration risk. External access should be limited to specific trusted domains or disabled.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoftteams/manage-external-access",
    "assertion": "\nparam($Connections)\n$config = Get-CsTenantFederationConfiguration\n$evidence = $config | Select-Object AllowFederatedUsers, AllowPublicUsers, AllowedDomains, BlockedDomains\nif ($config.AllowFederatedUsers -eq $true -and ($config.AllowedDomains.AllowedDomain.Count -eq 0)) {\nreturn @{ Pass = $false; Detail = 'External access is enabled for ALL external Teams tenants with no domain restrictions. Restrict to specific trusted domains or disable.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'External Teams access is either disabled or restricted to specific allowed domains.'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.3.1.2",
    "title": "Ensure anonymous users cannot join Teams meetings",
    "section": "3.1 — Microsoft Teams",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Allowing anonymous join enables anyone with a meeting link to join without authenticating, bypassing all identity and access controls.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoftteams/meeting-settings-in-teams",
    "assertion": "\nparam($Connections)\n$config = Get-CsTeamsMeetingConfiguration\n$evidence = $config | Select-Object AllowAnonymousUsersToJoinMeeting, AllowAnonymousUsersToStartMeeting\nif ($config.AllowAnonymousUsersToJoinMeeting -eq $true) {\nreturn @{ Pass = $false; Detail = 'Anonymous users are allowed to join Teams meetings. Set AllowAnonymousUsersToJoinMeeting to False.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'Anonymous users cannot join Teams meetings.'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.3.1.3",
    "title": "Ensure only organizers and co-organizers can present in meetings",
    "section": "3.1 — Microsoft Teams",
    "level": 2,
    "assessmentStatus": "Automated",
    "description": "Restricting presentation rights to organizers and co-organizers prevents attendees or guests from hijacking meetings or sharing inappropriate content.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-in-teams-general",
    "assertion": "\nparam($Connections)\n$policy = Get-CsTeamsMeetingPolicy -Identity Global\n$evidence = $policy | Select-Object Identity, DesignatedPresenterRoleMode, AllowExternalParticipantGiveRequestControl\n$goodValues = @('OrganizerOnlyUserOverride','OrganizerOnly')\nif ($policy.DesignatedPresenterRoleMode -notin $goodValues) {\nreturn @{ Pass = $false; Detail = \"Presenter role is set to '$($policy.DesignatedPresenterRoleMode)'. Set to 'OrganizerOnlyUserOverride' or 'OrganizerOnly'.\"; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'Meeting presenter role is restricted to organizers.'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.3.1.4",
    "title": "Ensure external participants cannot give or request remote control",
    "section": "3.1 — Microsoft Teams",
    "level": 1,
    "assessmentStatus": "Automated",
    "description": "Allowing external participants to request or receive remote control of a presenter's screen is a significant security risk — it can enable data theft or malware installation.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoftteams/meeting-policies-in-teams-general",
    "assertion": "\nparam($Connections)\n$policy = Get-CsTeamsMeetingPolicy -Identity Global\n$evidence = $policy | Select-Object Identity, AllowExternalParticipantGiveRequestControl\nif ($policy.AllowExternalParticipantGiveRequestControl -eq $true) {\nreturn @{ Pass = $false; Detail = 'External participants can give or request remote control. Set AllowExternalParticipantGiveRequestControl to False.'; Evidence = $evidence }\n}\nreturn @{ Pass = $true; Detail = 'External participants cannot give or request remote control.'; Evidence = $evidence }\n"
  },
  {
    "id": "CIS.M365.3.2.1",
    "title": "Ensure unmanaged external users cannot initiate contact with internal users",
    "section": "3.2 — Teams External Communication",
    "level": 1,
    "assessmentStatus": "Manual",
    "description": "Unmanaged Teams accounts (personal Microsoft accounts not associated with an organization) should not be able to initiate unsolicited contact with your users.",
    "remediationUrl": "https://learn.microsoft.com/en-us/microsoftteams/manage-external-access"
  }
]
