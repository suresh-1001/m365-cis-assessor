<#
.SYNOPSIS
    Generates the HTML assessment dashboard from run results.
#>
function New-AssessmentDashboard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$Results,

        [Parameter(Mandatory)]
        [hashtable]$Summary,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $passRate = if ($Summary.TotalControls -gt 0) {
        [math]::Round(($Summary.Pass / $Summary.TotalControls) * 100, 1)
    } else { 0 }

    $scoreColor = if ($passRate -ge 80) { '#27ae60' } elseif ($passRate -ge 60) { '#e67e22' } else { '#e74c3c' }

    # Build control rows
    $rows = foreach ($r in $Results | Sort-Object ControlId) {
        $statusClass = switch ($r.Status) {
            'Pass'   { 'pass'   }
            'Fail'   { 'fail'   }
            'Error'  { 'error'  }
            'Manual' { 'manual' }
            default  { 'unknown'}
        }
        $remediation = if ($r.RemediationUrl) {
            "<a href='$($r.RemediationUrl)' target='_blank'>Remediate</a>"
        } else { '' }

        "<tr class='$statusClass'>
            <td>$($r.ControlId)</td>
            <td>$($r.Section)</td>
            <td>$($r.Title)</td>
            <td>$($r.Workload)</td>
            <td>L$($r.Level)</td>
            <td><span class='badge $statusClass'>$($r.Status)</span></td>
            <td class='reason'>$($r.StatusReason)</td>
            <td>$remediation</td>
        </tr>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>M365 CIS Assessment — $($Summary.TenantName)</title>
<style>
  :root {
    --pass:   #27ae60;
    --fail:   #e74c3c;
    --error:  #e67e22;
    --manual: #7f8c8d;
    --bg:     #f4f6f9;
    --card:   #ffffff;
    --text:   #2c3e50;
    --border: #dde3ec;
    --accent: #2980b9;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Segoe UI', Arial, sans-serif; background: var(--bg); color: var(--text); }
  header { background: #1a2742; color: #fff; padding: 20px 32px; display: flex; align-items: center; gap: 16px; }
  header img { height: 40px; }
  header h1 { font-size: 22px; font-weight: 600; }
  header p  { font-size: 13px; opacity: .7; margin-top: 2px; }
  .main { padding: 24px 32px; }
  .scorecard { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 28px; }
  .card { background: var(--card); border-radius: 8px; padding: 18px 20px; border: 1px solid var(--border); }
  .card .label { font-size: 12px; text-transform: uppercase; letter-spacing: .5px; opacity: .6; }
  .card .value { font-size: 32px; font-weight: 700; margin-top: 4px; }
  .card.score  .value { color: $scoreColor; }
  .card.pass   .value { color: var(--pass); }
  .card.fail   .value { color: var(--fail); }
  .card.error  .value { color: var(--error); }
  .card.manual .value { color: var(--manual); }
  .filters { display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; align-items: center; }
  .filters input, .filters select {
    padding: 7px 12px; border: 1px solid var(--border); border-radius: 6px;
    font-size: 13px; background: var(--card);
  }
  .filters input { width: 260px; }
  table { width: 100%; border-collapse: collapse; background: var(--card);
    border-radius: 8px; overflow: hidden; border: 1px solid var(--border); font-size: 13px; }
  th { background: #1a2742; color: #fff; padding: 10px 12px; text-align: left; font-weight: 500; }
  td { padding: 9px 12px; border-bottom: 1px solid var(--border); vertical-align: top; }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #f0f4f9; }
  .badge { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 11px;
    font-weight: 600; text-transform: uppercase; letter-spacing: .4px; }
  .badge.pass   { background: #d5f5e3; color: var(--pass); }
  .badge.fail   { background: #fde8e8; color: var(--fail); }
  .badge.error  { background: #fef0e6; color: var(--error); }
  .badge.manual { background: #eaecee; color: var(--manual); }
  .reason { max-width: 280px; font-size: 12px; color: #555; }
  a { color: var(--accent); text-decoration: none; }
  a:hover { text-decoration: underline; }
  tr.pass   { }
  tr.fail   td:first-child { border-left: 3px solid var(--fail); }
  tr.error  td:first-child { border-left: 3px solid var(--error); }
  footer { padding: 20px 32px; font-size: 12px; color: #888; border-top: 1px solid var(--border); margin-top: 24px; }
</style>
</head>
<body>

<header>
  <div>
    <h1>M365 CIS Assessment Report</h1>
    <p>Tenant: $($Summary.TenantName) &nbsp;|&nbsp; Benchmark: $($Summary.Benchmark) &nbsp;|&nbsp; Completed: $($Summary.CompletedAt)</p>
  </div>
</header>

<div class="main">

  <div class="scorecard">
    <div class="card score">
      <div class="label">Pass Rate</div>
      <div class="value">$passRate%</div>
    </div>
    <div class="card pass">
      <div class="label">Pass</div>
      <div class="value">$($Summary.Pass)</div>
    </div>
    <div class="card fail">
      <div class="label">Fail</div>
      <div class="value">$($Summary.Fail)</div>
    </div>
    <div class="card error">
      <div class="label">Error</div>
      <div class="value">$($Summary.Error)</div>
    </div>
    <div class="card manual">
      <div class="label">Manual</div>
      <div class="value">$($Summary.Manual)</div>
    </div>
  </div>

  <div class="filters">
    <input type="text" id="searchBox" placeholder="Search controls..." onkeyup="filterTable()">
    <select id="statusFilter" onchange="filterTable()">
      <option value="">All Statuses</option>
      <option value="Pass">Pass</option>
      <option value="Fail">Fail</option>
      <option value="Error">Error</option>
      <option value="Manual">Manual</option>
    </select>
    <select id="workloadFilter" onchange="filterTable()">
      <option value="">All Workloads</option>
      <option value="Graph">Entra ID / Graph</option>
      <option value="Exchange">Exchange Online</option>
      <option value="Teams">Teams</option>
      <option value="SharePoint">SharePoint</option>
    </select>
  </div>

  <table id="resultsTable">
    <thead>
      <tr>
        <th>Control ID</th>
        <th>Section</th>
        <th>Title</th>
        <th>Workload</th>
        <th>Level</th>
        <th>Status</th>
        <th>Detail</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
      $($rows -join "`n")
    </tbody>
  </table>

</div>

<footer>
  Generated by M365 CIS Assessor &nbsp;|&nbsp; Built by <a href="https://linesightdigital.com">Linesight Digital</a> &nbsp;|&nbsp; Run ID: $($Summary.RunId)
</footer>

<script>
function filterTable() {
  const search   = document.getElementById('searchBox').value.toLowerCase();
  const status   = document.getElementById('statusFilter').value.toLowerCase();
  const workload = document.getElementById('workloadFilter').value.toLowerCase();
  const rows     = document.querySelectorAll('#resultsTable tbody tr');

  rows.forEach(row => {
    const text = row.textContent.toLowerCase();
    const matchSearch   = !search   || text.includes(search);
    const matchStatus   = !status   || row.className.includes(status);
    const matchWorkload = !workload || text.includes(workload);
    row.style.display = (matchSearch && matchStatus && matchWorkload) ? '' : 'none';
  });
}
</script>

</body>
</html>
"@

    $html | Out-File -FilePath (Join-Path $OutputPath 'dashboard.html') -Encoding UTF8 -Force
    Write-Verbose "Dashboard written to $OutputPath\dashboard.html"
}
