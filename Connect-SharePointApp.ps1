# Leonardo AI Image Prompts — M365 CIS Assessor

Generate these images in Leonardo AI and save them to the `diagrams/` folder
using the exact filenames listed. All images should be exported as **WebP**.

Recommended model: **Kino XL** or **Leonardo Diffusion XL**
Recommended resolution: 1920x1080 (16:9) for banners, 1200x800 for diagrams
Negative prompt for all: `blurry, low quality, watermark, cartoon, anime, distorted text, people, faces`

---

## 1. `diagrams/m365-cis-assessor-banner.webp`

**Used in:** README.md (hero banner)

**Prompt:**
```
A dark navy blue enterprise security dashboard interface, futuristic and
professional. Glowing shield icon in the center with a Microsoft 365 logo
integrated into it. Surrounding it are floating holographic panels showing
security compliance checkmarks, bar charts of pass/fail rates, and CIS
benchmark score metrics. Color palette: deep navy (#1a2742), electric blue
accents, white text, green checkmarks for passed controls, red for failed.
Clean, modern, minimal. No people. Cinematic lighting. 4K quality.
```

---

## 2. `diagrams/assessment-architecture.webp`

**Used in:** README.md, docs/architecture.md

**Prompt:**
```
A clean technical architecture diagram on a dark navy background. Shows a
vertical flow from top to bottom: "Orchestrator" at the top connecting to an
"Auth Broker" box with four branches labeled Graph, Exchange, Teams,
SharePoint. Below that a "Benchmark Catalog" layer, then a "Test Engine"
layer, then an "Output Pipeline" layer with three icons for HTML, JSON, and
CSV. Connected by glowing electric blue arrows. Microsoft cloud service icons.
Professional enterprise IT style. Dark navy and electric blue color scheme.
Clean sans-serif labels.
```

---

## 3. `diagrams/cert-auth-flow.webp`

**Used in:** docs/deployment-runbook.md (after Step 3)

**Prompt:**
```
A clean technical flow diagram showing certificate-based app-only
authentication for Microsoft Azure. Left side: a PowerShell terminal window.
Center: a certificate icon with a thumbprint label. Right side: Microsoft
Entra ID logo with four service icons below it — Graph API, Exchange Online,
Teams, SharePoint. Arrows flow from the terminal through the certificate to
Entra ID and then fan out to the four services. Dark background, blue and
white color scheme, professional enterprise style. No people.
```

---

## 4. `diagrams/control-catalog-schema.webp`

**Used in:** docs/architecture.md (Control Catalog Schema section)

**Prompt:**
```
A developer-focused illustration of a JSON schema structure. Shows a glowing
code editor panel on a dark background displaying structured JSON with fields
like id, title, level, assertion. To the right, an arrow points to a results
panel showing a compliance scorecard with green Pass badges and red Fail
badges. Clean, minimal, technical aesthetic. Electric blue syntax
highlighting. Dark background. No people. 4K quality.
```

---

## 5. `diagrams/output-dashboard-preview.webp`

**Used in:** README.md (Output Structure section)

**Prompt:**
```
A sleek enterprise security dashboard UI screenshot mockup on a dark navy
background. At the top, a header bar reading "M365 CIS Assessment Report".
Below it, five score cards showing: Pass Rate 78%, Pass 44, Fail 12, Error 2,
Manual 9. Below that, a filterable data table with columns for Control ID,
Title, Workload, Level, Status. Status badges are color-coded: green for Pass,
red for Fail, orange for Error, gray for Manual. Clean modern web UI, Segoe UI
font style, Microsoft design language. Realistic mockup quality.
```

---

## 6. `diagrams/github-actions-pipeline.webp`

**Used in:** README.md (CI/CD section), docs/architecture.md (CI/CD section)

**Prompt:**
```
A clean DevOps pipeline diagram on a dark background. Shows a GitHub Actions
workflow with five sequential steps connected by arrows: "Schedule Trigger"
then "Install Modules" then "Validate Connections" then "Run Assessment" then
"Upload Artifacts". Each step is in a rounded rectangle with a relevant icon
— clock, package, shield, play button, cloud upload. GitHub logo at the top.
Blue and white color scheme on dark navy background. Professional technical
illustration. No people.
```

---

## Image Reference Summary

| Filename | Used In |
|---|---|
| `m365-cis-assessor-banner.webp` | README.md |
| `assessment-architecture.webp` | README.md, docs/architecture.md |
| `cert-auth-flow.webp` | docs/deployment-runbook.md |
| `control-catalog-schema.webp` | docs/architecture.md |
| `output-dashboard-preview.webp` | README.md |
| `github-actions-pipeline.webp` | README.md, docs/architecture.md |

After generating, drop all six `.webp` files into the `diagrams/` folder and push.
