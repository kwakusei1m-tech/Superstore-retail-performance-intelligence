# GitHub completion and release guide

Repository: <https://github.com/kwakusei1m-tech/Superstore-retail-performance-intelligence>

## Live repository review — 11 August 2026

The repository identity, description, topics, MIT License and visual assets are strong. The chart images render correctly. The remaining issue is structural: several intended folders/files were created as one-byte placeholder files, and two directory names do not match the paths used by the README.

| Current live item | Required correction |
|---|---|
| `power query/` | Replace with `power-query/` |
| `power query/FactSales` | Delete placeholder; upload all `.m` files from this package |
| `workbook./` | Replace with `workbook/` |
| `workbook./Superstore_Retail_Performance_Intelligence` | Delete placeholder; upload the actual `.xlsx` |
| `dax/measures.md` | Replace the empty file with this package's completed catalogue |
| `docs/Superstore_Retail_Performance_Intelligence_Report` | Delete placeholder |
| `docs/Superstore_Rretail_Performance_Intelligence_Report.docx` | Rename to `Superstore_Retail_Performance_Intelligence_Report.docx` |
| `data/Sample-Superstore_raw_data` | Delete the one-byte placeholder |
| Current live `README.md` | Replace with the actual Markdown file in this package; do not copy its rendered text |

## Recommended repository identity

**Title:** Superstore Retail Performance Intelligence — Refreshable Excel BI Analytics  
**Repository name:** `Superstore-retail-performance-intelligence`

**Description:**

> Refreshable Excel BI project using Power Query, Power Pivot, DAX, data-quality controls and interactive dashboards to analyze Superstore sales, profitability, discounts, customers and regional performance.

## Upload the package while preserving structure

### Recommended method: GitHub Desktop

1. Download and extract `Superstore_GitHub_Repository_Completion_Package.zip`.
2. In GitHub Desktop, choose **File > Clone repository**.
3. Select `kwakusei1m-tech/Superstore-retail-performance-intelligence` and clone it.
4. In File Explorer, open the extracted package and the cloned repository side by side.
5. Copy the **contents** of the package root into the cloned repository root. Do not copy the outer package folder itself.
6. Allow the corrected `README.md` to replace the existing one.
7. Remove the placeholder paths listed in the review table.
8. In GitHub Desktop, review the changes and confirm the final folders are named exactly `assets`, `data`, `dax`, `docs`, `power-query`, `release` and `workbook`.
9. Commit with: `docs: complete reproducible Excel BI project package`.
10. Select **Push origin**.

### Command-line alternative

From a parent working directory:

```bash
git clone https://github.com/kwakusei1m-tech/Superstore-retail-performance-intelligence.git
cd Superstore-retail-performance-intelligence
```

Copy the extracted package contents into this directory, remove the known placeholders, then run:

```bash
git status
git add -A
git commit -m "docs: complete reproducible Excel BI project package"
git push origin main
```

The browser uploader is acceptable for small corrections, but GitHub Desktop or Git is safer for an entire nested project because the local folder tree is visible before committing.

## Add the project to MASTER-PORTFOLIO-README

This instruction refers to the **project**, not the ZIP package. Open the README in <https://github.com/kwakusei1m-tech/MASTER-PORTFOLIO-README>, insert the contents of `MASTER_PORTFOLIO_ENTRY.md` alongside the other project entries, preview it, and commit. The entry links to the live project and its latest release; do not upload the package ZIP to the portfolio repository.

## Export Power Query M manually in future versions

1. Open **Data > Queries & Connections** in Excel.
2. Double-click a query.
3. Open **Home > Advanced Editor**.
4. Copy the full expression from `let` through the final expression after `in`.
5. Save as `power-query/QueryName.m` using the exact query name.
6. For `pSourcePath`, replace the personal path with a generic example and remove leading/trailing spaces.
7. Repeat for every query and parameter.
8. Compare the file list with `power-query/README.md` before committing.

This package already contains the 14 definitions identified in the workbook.

## Publish v1.0.0

1. Commit and push the completed repository files first.
2. On the repository page, select **Releases > Draft a new release**.
3. Under **Choose a tag**, enter `v1.0.0` and create the tag from `main`.
4. Set the release title to `v1.0.0 — Refreshable Excel BI implementation`.
5. Paste `release/RELEASE_NOTES_v1.0.0.md` into the description.
6. Attach:
   - `workbook/Superstore_Retail_Performance_Intelligence_Excel_BI_v1.0.xlsx`
   - `docs/Superstore_Retail_Performance_Intelligence_Report.docx`
7. Leave **Set as a pre-release** unchecked.
8. Check **Set as the latest release**, if shown.
9. Select **Publish release**.
10. Test the workbook and report downloads from the published release page.

## Validate the completed repository

- README headings, tables, badges and Mermaid diagrams render rather than appearing as plain text.
- All eight PNG visuals render.
- Workbook and report links open the real files.
- `power-query/` contains 14 `.m` files plus its README.
- `dax/measures.md` contains 63 explicit measures.
- Data dictionary and refresh runbook render in `docs/`.
- The right sidebar shows **Cite this repository** after `CITATION.cff` reaches `main`.
- `releases/latest` opens `v1.0.0`.
- No one-byte placeholders, personal source paths or duplicate misspelled filenames remain.
