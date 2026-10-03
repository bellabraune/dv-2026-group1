# Project Context

Shared, living context for this project. Keep this file updated as the project
progresses so any AI assistant (or group member) can pick up the work without
re-reading every source.

## Data Context

This project works with four files on the Dutch **doorstroomtoets** (the
group-8 "transfer test" that all primary-school pupils take, which feeds their
secondary-school track advice). The topic sits in a live public fairness
debate: since 2023-2024 a school may choose **which** of six approved
providers administers the test, and the core finding in the data is that that
choice is *not* neutral — different providers produce systematically different
results and advice, partly (but not fully) explained by how disadvantaged a
school's student population is.

All four files are snapshots of school year **2024-2025** except `schoolweging`
(a three-year average, 2022-2023 through 2024-2025). They are downloaded into
`data/raw/` by `scripts/01-get-data.R`.

### Key Dutch terms (they appear in column names)

| Term | Meaning |
|---|---|
| doorstroomtoets | the standardized group-8 (final primary year) "transfer test" |
| PO / basisonderwijs | primary education |
| Sbo | special-needs primary school (`SOORT_PO` = `Sbo`; regular = `Bo`) |
| voortgezet onderwijs (VO) | secondary education (tracks VMBO → HAVO → VWO) |
| leerling / leerlingen | pupil(s) (`aantal` = number/count; `gem`/`gemiddelde` = average) |
| instelling / vestiging | a "school" (`INSTELLING`) can have several physical `VESTIGING` locations |
| schoolweging | a school-level score for how socio-economically disadvantaged its pupil population is (**higher = more disadvantaged**); in practice values run roughly 20-40 |
| CvTE | College voor Toetsen en Examens — the body overseeing the six test providers |
| referentieniveau | "reference level" — a standardized skill level meant to mean the same thing regardless of which test a pupil took |

### File 1 — `eindscores_2024-2025.csv`

One row per school location. The average doorstroomtoets score per provider,
**only for the provider(s) that school actually used** (most schools use
exactly one, so ~5 of the 6 provider pairs are zero on most rows).

Delimited by `;`, comma as decimal point, quoted fields. ~26 columns:

| Column | Meaning |
|---|---|
| `PEILDATUM_LEERLINGEN` | reference date for the pupil count (1 Oct 2024) |
| `PRIKDATUM` | date the data extract was published (`20250904`) |
| `INSTELLINGSCODE` | the school's main ID (a.k.a. BRIN), e.g. `00AP` |
| `VESTIGINGSCODE` | location code — which physical building (e.g. `00`) |
| `INSTELLINGSNAAM_VESTIGING` | school (location) name |
| `POSTCODE_VESTIGING` / `PLAATSNAAM` | postal code / town |
| `GEMEENTENUMMER` / `GEMEENTENAAM` | municipality code / name |
| `PROVINCIE` | province (12 in the Netherlands) |
| `SOORT_PO` | `Bo` = regular primary, `Sbo` = special primary |
| `DENOMINATIE_VESTIGING` | religious/pedagogical affiliation (e.g. `Openbaar` = public) |
| `BEVOEGD_GEZAG_NUMMER` | school-board (competent authority) number |
| `ONTHEFFING_REDEN_ND` | pupils exempted from the test |
| `<P>_AANTAL` | number of pupils tested by provider `<P>` |
| `<P>_GEM` | average raw score for provider `<P>` |

The six providers (each a `<P>_AANTAL`/`<P>_GEM` pair):

| Prefix | Provider |
|---|---|
| `IEP` | IEP Eindtoets (Bureau ICE) |
| `ROUTE8` | Route 8 (A-VISION) |
| `DIA` | Dia-Eindtoets (Diataal BV) |
| `AMN` | AMN Eindtoets |
| `DOE` | Overheidsdoorstroomtoets (Stichting Cito) — the free government test |
| `LIB` | Leerling in Beeld (Cito B.V.) — the most dominant provider |

**Critical gotcha:** the raw `*_GEM` scores are on **six completely different,
non-comparable numerical scales** (e.g. IEP ~53-90, AMN ~316-456, DOE is on a
third scale). You **cannot** compare `IEP_GEM` to `LIB_GEM` directly, or
average across providers. The `referentieniveaus` file is what makes
cross-provider comparison valid.

### File 2 — `referentieniveaus_2024-2025.csv`

One row per school location. How many pupils reached each **standardized
reference level** (in maths, reading, and language conventions). This is the
comparable outcome — a reference level is defined the same way no matter which
test a pupil took. Same identifier columns as `eindscores`, plus:

| Column | Meaning |
|---|---|
| `REKENEN_LAGER1F` | maths: pupils **below** the basic 1F level |
| `REKENEN_1F` | maths: reached the basic (1F) level, not the higher one |
| `REKENEN_1S` | maths: reached the higher target ("1S") level |
| `REKENEN_2F` | (rarely used for maths; its target is 1S, not 2F — usually 0) |
| `LV_LAGER1F` / `LV_1F` / `LV_2F` | same three buckets for **reading** (*leesvaardigheid*), target level 2F |
| `TV_LAGER1F` / `TV_1F` / `TV_2F` | same three buckets for **language conventions/writing**, target level 2F |

"1F" = fundamental/basic level (what nearly every pupil should reach).
"1S"/"2F" = the higher target (*streefniveau*) for maths and language.
These six pairs are the standard "share of pupils reaching target" metrics
(e.g. `pct_maths_1s`, `pct_reading_2f`) used for cross-provider comparison.

### File 3 — `schooladviezen_2024-2025.csv`

One row per school location. How many pupils ended up with each
**secondary-school track advice** (final advice, including upward revisions
after the test). Same identifier columns as `eindscores`, plus one count column
per advice track (lowest → highest): `VSO`, `PRO`, `VMBO_B`, `VMBO_B_K`,
`VMBO_K`, `VMBO_K_GT`, `VMBO_GT`, `VMBO_GT_HAVO`, `HAVO`, `HAVO_VWO`, `VWO`,
`ADVIES_NIET_MOGELIJK`. The `_`-joined columns are "advice split between two
tracks" categories.

### File 4 — `schoolweging_2022-2025.ods`

An **ODS workbook** (not CSV) with one sheet per school year
(`"2022-2023"`, `"2023-2024"`, `"2024-2025"`), a three-year-average sheet, and
two explanatory sheets. Use the `"2024-2025"` sheet (matches the other files).
One row per school **location**:

| Column | Meaning |
|---|---|
| `OVT` | school-location id formatted like `"00AP\|C1"` — the part **before** the `\|` is `INSTELLINGSCODE`; the part after identifies the location (but **not** the same numbering as `VESTIGINGSCODE`) |
| `Naam` | school (location) name |
| `BGNR` | school-board number (same concept as `BEVOEGD_GEZAG_NUMMER`) |
| `schoolweging` | the disadvantage score itself (higher = more disadvantaged; values ~20-40) |
| `aantal_leerlingen` | number of pupils this weighting is based on |
| `spreiding` | spread within the school's own pupils (not used in this project) |

**Join quirk:** the first three files all share the joining columns
`INSTELLINGSCODE` + `VESTIGINGSCODE`. `schoolweging` does **not** — to join it,
`str_split` the `OVT` column on `"\\|"` and use the left part. Note that many
schools (mostly `Sbo` special-primary schools) have **no** row in
`schoolweging`, so a left-join will leave those `schoolweging` values `NA`.

### Cross-cutting data caveats

1. **`"<5"` privacy suppression.** DUO replaces any count below 5 with the
   text `"<5"`. It appears in `referentieniveaus` and `schooladviezen` (where
   many small advice buckets are common) and in `eindscores` (`*_AANTAL`).
   This is text, not a number — convert before use, and decide on a
   replacement (e.g. 2.5, the midpoint of 1-4) and test sensitivity to it.
2. **Comma decimals + `;` delimiter.** The Dutch files use a comma as the
   decimal separator and `;` as the field delimiter. Load with
   `delim=";"`, `locale(decimal_mark=",")`, `na=c("NA","")` (not a plain
   `read.csv`).
3. **Provider self-selection confound.** Schools choose their provider, so raw
   between-provider differences conflate (a) genuine test difficulty with
   (b) which kinds of schools chose which test. Comparing at matched
   `schoolweging` is what makes a provider comparison fair.
4. **School-level, not pupil-level.** Each row is a school; you know which
   provider a school used and its aggregate score/level counts — not
   individual pupil scores. Conclusions are about schools, not pupils.

### Derived "primary provider" pattern (used consistently)

Because most schools use a single provider and the other files have no
provider column, the project labels each school by its **primary provider**:
`pivot_longer` the `<P>_AANTAL` pairs, keep the provider with the highest
`AANTAL` per `INSTELLINGSCODE` (drop ties / keep the first). This is a
school-level approximation, not pupil-level data.

### Comparable composite score

The project's provider-independent score averages three target-level attainment
rates: `100 * REKENEN_1S / n_rekenen + 100 * LV_2F / n_lezen + 100 * TV_2F /
n_taal`. Because these are reference-level shares, the composite is comparable
across providers even though the raw `*_GEM` scores are not.

## Code Styling

These conventions are used in the assignment Rmd files and should be preserved
in any future work on this project.

### General philosophy

- **Simple and elegant.** This is data-analysis code, not software engineering.
  Prefer one-liners and short chains when they make the code easier to read.
  No helper functions, no S4 classes, no over-engineered abstractions.
- **Logical flow.** Rmd chunks should follow a readable narrative: data in →
  transform → plot → annotate. Each chunk should be self-contained enough to
  understand in sequence.
- **Explain the non-obvious.** Add a one-line `#` comment above a chunk when
  its purpose is not self-evident from the code alone (e.g. a join that drops
  rows, a filter that changes the analysis unit). Do not restate what the code
  already says.

### Pipes and data transformations

- New pipe `|>` throughout (not `%>%`).
- Pipe at the **start** of continuation lines.
- Standard tidyverse chain: `filter()` → `mutate()` → `group_by()` →
  `summarise()` → `.groups = "drop"`.
- `ungroup()` after `slice_max()`.

### Indentation and line length

- 2-space indent.
- One function call per line when the chain is short; break arguments
  one-per-line when the call exceeds ~80 chars.
- Continuation lines align with the first argument (not the pipe).

### Naming

| Context | Convention | Examples |
|---|---|---|
| Raw data columns (Dutch) | ALL_CAPS or as-source | `INSTELLINGSCODE`, `AANTAL`, `GEM`, `schoolweging` |
| Derived / computed columns | snake_case English | `n_students`, `primary_provider`, `hover_text` |
| Plot objects (static) | `fig_*` | `fig_density`, `fig_weight` |
| Plot objects (interactive) | descriptive name | `part2_plot` |
| Intermediate data frames | snake_case noun | `school_data`, `plot_data`, `part2_data` |

### ggplot2

- Structure: `ggplot(data, aes(...))` **+** `geom_*()` **+** `scale_*()`
  **+** `labs()` **+** `theme()`.
- `theme_minimal()` (or `theme_bw()`) as base, then `theme(...)` overrides.
- `legend.position` set explicitly (`"top"`, `"right"`, `"none"`).
- Manual scales with named `values = c(...)` and `name = "..."` for the
  legend title.
- Chunk headers carry `fig.height`, `fig.width`, `fig.align` for layout.

### plotly

- **ggplot2 is the default.** All static plots use ggplot2.
- **plotly only when ggplotly is insufficient.** The only justification for
  using `plot_ly()` directly is when `ggplotly()` cannot achieve the required
  behaviour (e.g. two independent legends, custom `layout()` calls that
  `ggplotly` overwrites). The reasoning should be noted in a comment.
- `plot_ly(...)` **|** `add_markers(...)` **|** `layout(...)`.
- Tooltip: pre-build an `hover_text` column with
  `paste0("<b>name</b><br>", ...)` and use `hoverinfo = "text"`.
- Point sizing: `size = ~var` + `sizes = c(min, max)`.
- Custom legend groups: `legendgroup` + `legendgrouptitle = list(text = ...)`.
- Auxiliary legend markers:
  `add_markers(..., inherit = FALSE, hoverinfo = "skip")`.

### Comments

- Short, one-line `#` comments above non-obvious code.
- Explain **why**, not what (e.g. `"# DUO writes '<5' for small counts -> NA"`).
- No comment blocks; keep them to 1–2 lines max.

### Chunk headers

- `{r setup}` — global options, `rm(list = ls())`, `library()` calls,
  `source()`.
- `{r data-prep-N}` — named prep chunks.
- `{r}` — unnamed chunks for plots or single steps.
- Figure chunks:
  `{r part-a-combine, fig.height = 6, fig.width = 11.5, fig.align = "center"}`.
- `echo = TRUE` set once via `knitr::opts_chunk$set(echo = TRUE)`.

### Packages

- `tidyverse`, `cowplot`, `readODS`, `plotly` (loaded in setup chunk).
- Addittional packages that are useful to be added should be justifiable and confirmed before addition.
