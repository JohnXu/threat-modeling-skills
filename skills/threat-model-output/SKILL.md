---
name: threat-model-output
description: Entry point for any threat-modeling request (STRIDE, LINDDUN, PASTA, attack tree, abuse case, trust boundary, DFD, "threat model this"). Use first, before the methodology skill — asks once whether to generate a data flow diagram (OWASP Threat Dragon by default, or Microsoft Threat Modeling Tool .tm7, Mermaid, draw.io, PlantUML, Graphviz) and whether to generate a report (PDF or Word), then runs the methodology and produces those files.
---

# Threat Model Output Options (DFD + Report)

## Overview

This is the single place where output choices are asked. The methodology skills (`threat-model-stride`, `-linddun`, `-pasta`, `-attack-tree`, `-abuse-case`, `-trust-boundary`, `-dfd`) only do analysis and contain no output questions. Ask once per threat-modeling session, even if several methodologies are run back to back (e.g. DFD, then STRIDE, then LINDDUN) — reuse the answers and produce one set of outputs.

Two optional deliverables beyond the Markdown threat model:

1. **DFD file** — default **OWASP Threat Dragon v2** (`.json`, contains the threats found). Also offered: **Microsoft Threat Modeling Tool** (`.tm7`), Mermaid, draw.io, PlantUML, Graphviz DOT.
2. **Report** — the Markdown threat model rendered to **PDF** or **Word (.docx)**.

Nothing here depends on bundled scripts: write the files yourself, following the verified formats below. Use Python or any scripting you have to generate the files (do not hand-edit large XML/JSON).

## Step 1 — Ask once, before starting the analysis

Ask these two questions, one at a time (use the `ask_user` tool when available, otherwise ask in chat). Skip a question only if the user already answered it in their request or earlier in the session.

1. **"Generate a DFD file?"** — choices: `Yes` / `No`.
   If Yes, ask the format — choices: `OWASP Threat Dragon (.json) (Recommended, default)`, `Microsoft Threat Modeling Tool (.tm7)`, `Mermaid (.mmd)`, `draw.io (.drawio)`, `PlantUML (.puml)`, `Graphviz DOT (.dot)`. More than one may be chosen. If the user just says "yes" without a format, use Threat Dragon. If the request is itself to build a DFD, do not ask yes/no; ask only the format.
2. **"Generate a report?"** — choices: `Yes` / `No`.
   If Yes, ask the report format — choices: `PDF (Recommended, default)`, `Word (.docx)`. Both may be chosen. If the user just says "yes" without a format, use PDF.

Remember the answers; never re-ask in the same session.

## Step 2 — Do the analysis

Run the requested methodology skill(s) and write the Markdown threat model as usual. Save it as `<system-slug>-threat-model.md` (in the user's chosen location, otherwise the working directory).

## Step 3 — Generate the DFD (only if answered Yes)

### 3a. Build one neutral model first

Collect, once, from the analysis: **elements** (`actor` = external entity, `process`, `store`; each with a unique id and name), **flows** (from → to, name, protocol, encrypted?, public network?), **trust boundaries** (name + the element ids inside), and the **threats** found (each attached to the element or flow it targets). Every flow endpoint must be an element. Flows are one-way: model a request/response as two flows.

Auto-layout (good enough, user can drag later): put actors first, then each element one column right of the element that feeds it (breadth-first from the actors), `x = 60 + column*280`, `y = 60 + row*170`. Sizes: actor 160×80, process 100×100, store 160×80. A boundary box is the bounding box of its members plus 50 px padding.

Threat type strings (use exactly): STRIDE — `Spoofing`, `Tampering`, `Repudiation`, `Information disclosure`, `Denial of service`, `Elevation of privilege`. LINDDUN — `Linkability`, `Identifiability`, `Non-repudiation`, `Detectability`, `Disclosure of information`, `Unawareness`, `Non-compliance`. `severity`: `Low` | `Medium` | `High` (map Critical to High); `status`: `Open` | `Mitigated` | `NotApplicable`.

### 3b. OWASP Threat Dragon v2 (`<slug>-dfd.threat-dragon.json`)

Validated against the official `threat-dragon-v2.schema.json`. UTF-8 JSON, pretty-printed:

```
{ "version": "2.0",
  "summary": {"title": "<system>", "owner": "", "description": "", "id": 0},
  "detail": {
    "contributors": [{"name": "<name>"}], "reviewer": "", "diagramTop": 1,
    "threatTop": <total number of threats>,
    "diagrams": [{ "id": 0, "title": "Main Data Flow", "version": "2.0",
                   "diagramType": "STRIDE",            // or "LINDDUN" for the LINDDUN skill
                   "thumbnail": "./public/content/images/thumbnail.stride.jpg",   // .linddun.jpg for LINDDUN
                   "cells": [ ... ] }] } }
```

Every cell needs `id` (uuid), `shape`, `zIndex`. Cells:

- **Trust boundary**: `shape "trust-boundary-box"`, `zIndex -50`, `position {x,y}`, `size {width,height}`, `attrs {"label": {"text": name}}`, `data {"type": "tm.BoundaryBox", "name", "description": "", "isTrustBoundary": true, "hasOpenThreats": false}`.
- **Actor / process / store**: `shape` `actor` | `process` | `store`, `position`, `size`, `attrs {"text": {"text": name}, "body": {"stroke": "#333333", "strokeWidth": 1, "strokeDasharray": null}}` (for `store` use `"topLine"` and `"bottomLine"` with that same object instead of `"body"`), and `data`: `type` `tm.Actor` | `tm.Process` | `tm.Store`, `name`, `description`, `outOfScope`, `reasonOutOfScope`, `isTrustBoundary: false`, `hasOpenThreats`, `threats: []`; extras: actor `providesAuthentication`, store `isALog`, `storesCredentials`, `isEncrypted`, `isSigned`.
- **Flow**: `shape "flow"`, `width 200`, `height 100`, `connector "smooth"`, `source {"cell": <id>}`, `target {"cell": <id>}`, `vertices []`, `attrs {"line": {"stroke": "#333333", "strokeWidth": 1, "targetMarker": {"name": "block"}, "strokeDasharray": null}}`, `labels [{"position": 0.5, "attrs": {"label": {"text": "Name (PROTOCOL)"}}}]`, `data {"type": "tm.Flow", "name", "description", "outOfScope", "reasonOutOfScope", "protocol", "isBidirectional", "isEncrypted", "isPublicNetwork", "isTrustBoundary": false, "hasOpenThreats", "threats": []}`. Add `"sourceMarker": {"name": "block"}` to `line` only for a bidirectional flow.
- **Threat** (inside `data.threats`): `{"id": uuid, "title", "type", "status", "severity", "description", "mitigation", "modelType": "STRIDE"|"LINDDUN"}` — all of title/type/status/severity/description/mitigation are required.
- If an element or flow has an `Open` threat: `hasOpenThreats: true` and draw it with `"stroke": "red", "strokeWidth": 2.5`.

Open it in Threat Dragon via *Open an existing threat model*.

### 3c. Microsoft Threat Modeling Tool (`<slug>-dfd.tm7`)

**Requirements (check first, never install for the user):**

- MTMT is Windows-only. Check it is installed: a Start Menu entry under `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft Threat Modeling Tool` (ClickOnce `.appref-ms`), or `TMT7.exe` under `Program Files*\Microsoft Threat Modeling Tool*`. If it is missing, recommend https://aka.ms/threatmodelingtool and offer another format meanwhile.
- **A template model is required.** A `.tm7` must embed MTMT's knowledge base (threat catalog). It is Microsoft's, so it is not shipped here and must not be hand-made: only reusing a knowledge base saved by the user's own MTMT has been verified to open in MTMT 7.3. Ask the user once to open MTMT → *Create A Model* → pick the template → *File → Save Model*, and give you that `.tm7` path. Reuse it afterwards.
- **Choose the template with the right rules.** The diagram uses MTMT's *generic* element types (`GE.P`, `GE.EI`, `GE.DS`, `GE.TB.B`, `GE.DF`), and MTMT only generates threats for elements that a template's rules target. Ask the user to pick **"SDL TM Knowledge Base (Core)"** (the default `Default.tb7`: 47 rules, all on the generic types, many triggered by flows crossing trust boundaries). The *Azure Threat Model Template* targets specific stencils (`SE.P.TMCore.WebApp`, `SE.DS.TMCore.SQL`, …), so a generic diagram gets almost no threats from it (verified: the diagram opened but the Analysis view was empty). You can tell which template a `.tm7` carries from `<a:Manifest>…<a:Name>…</a:Name>` inside `<KnowledgeBase>`; if it is not the SDL core one and the user wants threats, ask them to re-save the model from the SDL core template.
- (`.tb7` files are templates, opened through *Open Template*; they are not models and are not what you generate.)

**Method — fill the template, don't build from scratch.** Read the template as UTF-8 text and replace only these parts with string/regex operations, keeping everything else (especially `<KnowledgeBase>`) byte-for-byte:

1. The inside of `<Borders …>…</Borders>` → boundaries and elements below. In a freshly saved empty model the tag is **self-closing** (`<Borders xmlns:a="…"/>`): turn it into `<Borders xmlns:a="…">…items…</Borders>`, keeping its attributes. Do the same for `<Lines>`; handle both forms (a template saved from a model with a diagram has open/close tags).
2. The inside of `<Lines …>…</Lines>` → data flows below.
3. `<Header>…</Header>` and the drawing surface's `Name` property value (the first `StringDisplayAttribute` whose DisplayName is `Name`; its `<b:Name>` is either empty or `Name`, depending on the template) → diagram title.
4. `<MetaInformation>…</MetaInformation>` → `<MetaInformation><Assumptions/><Contributors>…</Contributors><ExternalDependencies/><HighLevelSystemDescription>…</HighLevelSystemDescription><Owner>…</Owner><Reviewer>…</Reviewer><ThreatModelName>…</ThreatModelName></MetaInformation>` (XML-escape values).
5. `<ThreatInstances …>` → empty (`<ThreatInstances xmlns:a="…"/>`, keeping the attributes the template has).
6. If the template lacks `<Validations`, insert `<ThreatGenerationEnabled i:nil="true"/><Validations xmlns:a="http://schemas.datacontract.org/2004/07/ThreatModeling.KnowledgeBase"/><Version>4.3</Version>` immediately before `<KnowledgeBase`. (A model without `Validations` crashes MTMT 7.3 with a null-reference exception.)

Write the result as one continuous UTF-8 string: **no** `<?xml?>` declaration, **no** pretty-printing, **no** BOM.

Namespaces: `ABS` = `http://schemas.datacontract.org/2004/07/ThreatModeling.Model.Abstracts`, `KB` = `http://schemas.datacontract.org/2004/07/ThreatModeling.KnowledgeBase`, `XSD` = `http://www.w3.org/2001/XMLSchema`. The template root already declares `a`, `i` and `z`; each child element below carries its own `xmlns="ABS"`.

Each item in `<Borders>` / `<Lines>` is:

```
<a:KeyValueOfguidanyType><a:Key>{GUID}</a:Key>
 <a:Value z:Id="i{N}" i:type="{ITYPE}">
  <GenericTypeId xmlns="ABS">{TYPEID}</GenericTypeId><Guid xmlns="ABS">{GUID}</Guid>
  <Properties xmlns="ABS">{PROPS}</Properties>
  <TypeId xmlns="ABS">{TYPEID}</TypeId>{GEOMETRY}
 </a:Value></a:KeyValueOfguidanyType>
```

- `{GUID}` is a real UUID, identical in `Key` and `Guid`. `z:Id` values (`i101`, `i102`, …) must be unique across the whole file: start above the largest `z:Id` already in the template (e.g. max + 100) and never reuse one.
- `{TYPEID}` is used for both `GenericTypeId` and `TypeId`; `{ITYPE}` / `{TYPEID}` / header text: actor `StencilRectangle` / `GE.EI` / "Generic External Interactor"; process `StencilEllipse` / `GE.P` / "Generic Process"; store `StencilParallelLines` / `GE.DS` / "Generic Data Store"; boundary `BorderBoundary` / `GE.TB.B` / "Generic Trust Border Boundary"; flow `Connector` / `GE.DF` / "Generic Data Flow".
- Property building blocks (put inside `{PROPS}`, each is an `a:anyType` carrying `xmlns:b="KB"`):
  - header: `<a:anyType i:type="b:HeaderDisplayAttribute" xmlns:b="KB"><b:DisplayName>{header text}</b:DisplayName><b:Name/><b:Value i:nil="true"/></a:anyType>`
  - string: `<a:anyType i:type="b:StringDisplayAttribute" xmlns:b="KB"><b:DisplayName>{label}</b:DisplayName><b:Name>{name or empty <b:Name/>}</b:Name><b:Value i:type="c:string" xmlns:c="XSD">{value}</b:Value></a:anyType>`
  - boolean: `<a:anyType i:type="b:BooleanDisplayAttribute" xmlns:b="KB"><b:DisplayName>{label}</b:DisplayName><b:Name>{name}</b:Name><b:Value i:type="c:boolean" xmlns:c="XSD">false</b:Value></a:anyType>`
- Properties per kind (order matters). Actor / process / store: header, string `Name` = element name, boolean `Out Of Scope` (Name `71f3d9aa-b8ef-4e54-8126-607a1d903103`), string `Reason For Out Of Scope` (Name `752473b6-52d4-4776-9a24-202153f7d579`, empty value). Boundary: header, string `Name`, string `Dataflow Order` (Name `15ccd509-98eb-49ad-b9c2-b4a2926d1780`, value `0`). Flow: header, string `Name` (use `Name (PROTOCOL)`), string `Dataflow Order` (as above), boolean `Out Of Scope`, string `Reason For Out Of Scope`. A missing `Out Of Scope` property is a known cause of "corrupted or incompatible".
- Geometry, boxes (elements and boundaries): `<Height>`, `<Left>`, `<StrokeDashArray i:nil="true"/>`, `<StrokeThickness>1</StrokeThickness>`, `<Top>`, `<Width>` — each in that order and each with `xmlns="ABS"`. Elements before boundaries is fine; list boundaries first so they sit behind.
- Geometry, flows: `<HandleX>`, `<HandleY>` (midpoint), `<PortSource>`, `<PortTarget>`, `<SourceGuid>`, `<SourceX>`, `<SourceY>`, `<TargetGuid>`, `<TargetX>`, `<TargetY>`, in that order. Ports are `East`/`West`/`North`/`South` (never `None`): horizontal gap larger → source `East`, target `West` (or reversed if the target is to the left); otherwise `South`→`North` (or `North`→`South`). Source/Target X,Y are the points on those sides (East = right edge middle, West = left edge middle, North = top middle, South = bottom middle).
- **Keep flows between the same two elements apart** (e.g. a request/response pair, or several flows between one pair). They would otherwise share identical endpoints and draw on top of each other. Keep the endpoints on the port, and only move the handle away from the straight line, perpendicular to it: with `n` such flows, give flow `k` (0-based) an offset of `(k - (n-1)/2) * 80` px, added to `HandleY` when the flow runs left/right (`East`/`West` ports) or to `HandleX` when it runs up/down. For a pair this gives −40 and +40: two arcs bowing in opposite directions (verified in MTMT 7.3 to separate cleanly; shifting both endpoints and the handle to make parallel lines also works but looked worse).

**Threats are not written into the `.tm7`.** MTMT only accepts threat instances that reference a threat type (`TypeId`) in its own template; custom or untyped threat instances make the file unopenable. MTMT generates its own threats from the diagram and the template's rules: tell the user to open the model and switch to the *Analysis* view (how many appear depends on the template, see above). The threats from your STRIDE/LINDDUN analysis stay in the Markdown report and in the Threat Dragon file.

Open it in MTMT via *Open A Model*. Never claim a `.tm7` opens in MTMT unless it was actually opened there; say it was generated from the user's template and ask them to confirm. If MTMT shows "corrupted or incompatible", check the pitfalls above (z:Id duplicates, missing `Out Of Scope`, port `None`, missing `Validations`, edited `KnowledgeBase`).

### 3d. Mermaid, DOT, PlantUML, draw.io

Flows from the neutral model; use a `subgraph`/cluster per trust boundary, label each flow `Name (PROTOCOL)`.

- **Mermaid** (`.mmd`): `flowchart LR`; actor `id["Name"]`, process `id(("Name"))`, store `id[("Name")]`; boundary `subgraph tb0["Name (trust boundary)"] … end`; flow `a -->|"label"| b`. Sanitize ids to `\w` only.
- **Graphviz DOT** (`.dot`): `digraph DFD { rankdir=LR; … }`; actor `shape=box`, process `shape=ellipse`, store `shape=cylinder`; boundary `subgraph cluster_0 { label="Name (trust boundary)"; style=dashed; color=red; … }`; flow `a -> b [label="…"];`.
- **PlantUML** (`.puml`): `@startuml` / `left to right direction`; actor `rectangle "Name" as id`, process `usecase "Name" as id`, store `database "Name" as id`; boundary `rectangle "Name (trust boundary)" #line.dashed;line:red { … }`; flow `a --> b : label`.
- **draw.io** (`.drawio`): `<mxfile><diagram name="DFD"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/>` then one `<mxCell … vertex="1" parent="1"><mxGeometry x y width height as="geometry"/></mxCell>` per element and boundary (boundary style `rounded=1;dashed=1;fillColor=none;strokeColor=#CC0000;verticalAlign=top;align=left;`, process style `ellipse;whiteSpace=wrap;html=1;`, actor `rounded=0;whiteSpace=wrap;html=1;`, store `shape=partialRectangle;whiteSpace=wrap;html=1;left=0;right=0;fillColor=none;`), and one `<mxCell … edge="1" parent="1" source="…" target="…"><mxGeometry relative="1" as="geometry"/></mxCell>` per flow with `style="endArrow=block;html=1;edgeStyle=orthogonalEdgeStyle;"`. XML-escape attribute values.

### 3e. Finish the DFD step

Tell the user how to open each file, and reference the DFD file(s) from the Markdown report. If you cannot run code at all, give Mermaid inline and say the other exports were skipped.

## Step 4 — Generate the report (only if answered Yes)

Do this last, after the Markdown is final and the DFD references are in place. Describe the DFD in the report as tables (elements, flows, boundaries): Mermaid code blocks are not rendered in PDF/Word.

- **Word**: `pandoc <slug>-threat-model.md -f gfm -o <slug>-threat-model.docx --metadata title="<title>"` (needs `pandoc`).
- **PDF**: convert Markdown to a standalone HTML file (`pandoc <md> -f gfm -t html5 --no-highlight`, or the Python `markdown` package with the `tables`, `fenced_code` and `sane_lists` extensions), wrapped in `<!doctype html><html><head><meta charset="utf-8"><title>…</title><style>…</style></head><body>…</body></html>` with CSS such as `@page{size:A4;margin:18mm 15mm} body{font-family:"Segoe UI",Arial,sans-serif;font-size:10.5pt;line-height:1.45} table{border-collapse:collapse;width:100%} th,td{border:1px solid #d0d7de;padding:4px 7px;vertical-align:top} th{background:#f0f3f6} pre{white-space:pre-wrap;background:#f6f8fa;padding:8px} tr{page-break-inside:avoid}`. Then print it with headless Edge/Chrome/Chromium:

  ```
  <browser> --headless --disable-gpu --no-sandbox --no-pdf-header-footer --user-data-dir=<temp dir> --print-to-pdf=<out.pdf> <file:///path/to/report.html>
  ```

  Browser candidates: Windows `…\Microsoft\Edge\Application\msedge.exe` or `…\Google\Chrome\Application\chrome.exe` under `Program Files (x86)`/`Program Files`/`%LOCALAPPDATA%`; macOS `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` or Microsoft Edge; Linux `google-chrome`, `chromium`, `microsoft-edge` on PATH. Use a fresh `--user-data-dir` so the command does not attach to an already-running browser instance.

After each conversion check that the output file exists and is non-empty before claiming success. If a tool is missing, say which one and give the manual fallback (open the Markdown in a viewer and "Print to PDF"; Word via `pandoc`).

## Final message

List every file created with its path and format. Do not mention files that were not requested.

## Pitfalls

- Asking the questions after the analysis is done — ask up front so the report can reference the outputs.
- Inventing threat type strings; Threat Dragon only shows threats whose `type` matches its category list.
- Bidirectional flows: Threat Dragon can mark them, but `.tm7` flows are one-way — always use two flows.
- Building a `.tm7` without a user-supplied MTMT template, or putting threats in it (see 3c).
- Claiming files open in a tool you did not run.
