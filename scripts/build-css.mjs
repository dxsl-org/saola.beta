#!/usr/bin/env bun
/**
 * build-css.mjs
 *
 * Strategy-B CSS slicer: classifies the compiled assets/basecoat.css by
 * SELECTOR SET, then emits:
 *   src/saola/base.css          — @property passthrough + tokens + scoped reset
 *   src/saola/<widget>.css ×N   — per-widget basecoat sections wrapped in @layer saola.components
 *   .build-css/preflight.css    — isolated global reset for Phase-03 opt-in bundle
 *
 * Security gate (m2): rejects any @import or non-allowlisted url() in sliced content.
 * Sentinel guard (M1): refuses to overwrite src/saola/*.css lacking @generated sentinel.
 * Path guard (M1): asserts all output paths resolve within src/saola/.
 * Fail-loud: unmatched selector, zero-block widget, unrecognized construct → exit 1.
 * Idempotent: re-run produces byte-identical generated regions.
 *
 * Run: bun scripts/build-css.mjs
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'fs';
import { resolve, dirname, relative } from 'path';
import { fileURLToPath } from 'url';
import { tokenize } from './css-tokenizer.mjs';
import { classifyConstruct, extractComponentSelectors, matchWidget } from './css-classify.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..');

const INPUT_CSS   = resolve(REPO_ROOT, 'assets/basecoat.css');
const SRC_SAOLA   = resolve(REPO_ROOT, 'src/saola');
const BUILD_CSS   = resolve(REPO_ROOT, '.build-css');
const SECTION_MAP = resolve(__dirname, 'css-section-map.json');

const SENTINEL = '/* @generated saola-css — do not edit; regenerated from basecoat */';
const CUSTOM_MARKER = '/* saola:custom */';

// --- Allowlist guard (m2) ---
// url() may only reference data:image/svg+xml or relative paths.
// The compiled basecoat uses both: data:image/svg+xml SVG icons and nothing else.
const ALLOWED_URL_PATTERN = /url\(\s*['"]?(data:image\/svg\+xml|[^'"\s)]*\.[a-z]{2,5})['"]?\s*\)/gi;

/**
 * Verify no @import directives and only allowlisted url() in sliced CSS content.
 * Exits non-zero on violation.
 *
 * @param {string} content   — raw CSS text of the sliced block
 * @param {string} context   — description for error messages
 */
function assertAllowlist(content, context) {
  // Strip comments before checking to avoid false positives in commented-out code
  const stripped = content.replace(/\/\*[\s\S]*?\*\//g, '');

  if (/@import\b/i.test(stripped)) {
    fatal(`Security (m2): @import found in sliced content [${context}]. Failing build.`);
  }

  // Find all url() occurrences
  const urlRegex = /url\(\s*(['"]?)(.*?)\1\s*\)/gi;
  let match;
  while ((match = urlRegex.exec(stripped)) !== null) {
    const ref = match[2];
    // Relative-only: any scheme'd URL (://) or protocol-relative (//) is an exfiltration vector
    const isRemote = ref.includes('://') || ref.startsWith('//');
    const ok =
      ref.startsWith('data:image/svg+xml') ||
      (!isRemote && /^[^'"\s)]+\.[a-z]{2,5}$/i.test(ref));
    if (!ok) {
      fatal(`Security (m2): url() with disallowed reference "${ref}" in [${context}]. Failing build.`);
    }
  }
}

/**
 * Print error message and exit with code 1.
 *
 * @param {string} msg
 */
function fatal(msg) {
  console.error(`\nFATAL: ${msg}`);
  process.exit(1);
}

/**
 * Assert that a resolved output path is strictly within src/saola/.
 * Prevents path-traversal attacks from a compromised upstream.
 *
 * @param {string} resolvedPath
 */
function assertWithinSrcSaola(resolvedPath) {
  const rel = relative(SRC_SAOLA, resolvedPath);
  if (rel.startsWith('..') || rel.includes(':')) {
    fatal(`Path guard: resolved output path "${resolvedPath}" is outside src/saola/. Aborting.`);
  }
}

/**
 * Write a file only if its current content differs from the new content.
 * This preserves file mtimes when the output is unchanged (pure idempotency).
 *
 * @param {string} path
 * @param {string} content
 * @returns {boolean} true if file was actually written
 */
function writeIfChanged(path, content) {
  if (existsSync(path)) {
    const existing = readFileSync(path, 'utf8');
    if (existing === content) return false;
  }
  writeFileSync(path, content, 'utf8');
  return true;
}

/**
 * For each widget output file, check if it already exists and lacks the
 * @generated sentinel → exit non-zero (M1 guard).
 *
 * @param {string} filePath
 */
function assertSentinelOrNew(filePath) {
  if (!existsSync(filePath)) return; // new file — fine
  const content = readFileSync(filePath, 'utf8');
  if (!content.includes(SENTINEL)) {
    fatal(
      `Sentinel guard (M1): "${filePath}" exists but lacks the @generated sentinel.\n` +
      `Remove the file or add the sentinel before regenerating.`
    );
  }
}

/**
 * Extract the /* saola:custom *\/ region (everything after the marker) from
 * an existing widget file. Returns empty string if the marker is absent.
 *
 * @param {string} filePath
 * @returns {string}
 */
function extractCustomRegion(filePath) {
  if (!existsSync(filePath)) return '';
  const content = readFileSync(filePath, 'utf8');
  const idx = content.indexOf(CUSTOM_MARKER);
  if (idx === -1) return '';
  // Preserve the marker itself and everything after
  return content.slice(idx);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

console.log('build-css: reading input…');
const css = readFileSync(INPUT_CSS, 'utf8');
const sectionMapData = JSON.parse(readFileSync(SECTION_MAP, 'utf8'));
const { widgetSelectorMap, widgetOutputFiles, authoredWidgetRoots = [] } = sectionMapData;

// Ensure output directories exist
mkdirSync(BUILD_CSS, { recursive: true });

// ---------------------------------------------------------------------------
// Step 1: Tokenize the compiled CSS into top-level constructs
// ---------------------------------------------------------------------------
console.log('build-css: tokenizing…');
const constructs = tokenize(css);

// ---------------------------------------------------------------------------
// Step 2: Classify each construct
// ---------------------------------------------------------------------------
console.log('build-css: classifying…');
const classified = constructs.map(c => classifyConstruct(c));

// Fail loud on unknown constructs
const unknowns = classified.filter(c => c.taxonomy === 'unknown');
if (unknowns.length > 0) {
  for (const u of unknowns) {
    console.error(`  UNKNOWN at line ${u.startLine}: ${u.reason || u.raw?.slice(0, 80)}`);
  }
  fatal(`${unknowns.length} unrecognized top-level construct(s) found. See above.`);
}

// ---------------------------------------------------------------------------
// Step 3: Classify each @layer components block by selector set → widget
// ---------------------------------------------------------------------------
console.log('build-css: classifying @layer components blocks…');

// widgetBlocks: widgetName → ordered array of block raw content (excluding @layer components { })
const widgetBlocks = {};
for (const key of Object.keys(widgetOutputFiles)) {
  widgetBlocks[key] = [];
}

// Track the last component block to associate a following @keyframes rule
let lastWidgetForKeyframes = null;

for (let i = 0; i < classified.length; i++) {
  const c = classified[i];

  if (c.taxonomy === 'keyframes') {
    // Associate with the most recent component-section widget before this rule.
    // Whitespace/comment/other constructs between the block and @keyframes are allowed.
    if (lastWidgetForKeyframes) {
      classified[i] = { ...c, widget: lastWidgetForKeyframes };
    } else {
      fatal(`@keyframes "${c.name}" at line ${c.startLine} has no preceding @layer components block to associate with.`);
    }
    continue;
  }

  // Only skip non-component constructs; do NOT reset lastWidgetForKeyframes on whitespace/comments/etc.
  // Reset only when we encounter a NEW component-section (so keyframes associates with the last widget seen).
  if (c.taxonomy !== 'component-section') {
    continue;
  }

  // Extract top-level selectors from the block content
  const selectors = extractComponentSelectors(c.block ?? '');

  if (selectors.length === 0) {
    fatal(`@layer components at line ${c.startLine} contains no top-level selectors. Cannot classify.`);
  }

  const { widget, unmatched } = matchWidget(selectors, widgetSelectorMap);

  if (unmatched.length > 0) {
    fatal(
      `Fail-loud: unmatched selectors in @layer components at line ${c.startLine}:\n` +
      unmatched.map(s => `  → ${s}`).join('\n') +
      `\n\nAdd these selectors to scripts/css-section-map.json to resolve.`
    );
  }

  if (!widget) {
    fatal(`@layer components at line ${c.startLine} could not be classified. Selectors: ${selectors.slice(0, 3).join(' | ')}`);
  }

  if (!(widget in widgetBlocks)) {
    fatal(`Widget "${widget}" from selector map has no entry in widgetOutputFiles. Fix css-section-map.json.`);
  }

  // Validate allowlist on this block's content before storing
  assertAllowlist(c.block ?? '', `${widget} block at line ${c.startLine}`);

  widgetBlocks[widget].push(c.block ?? '');
  classified[i] = { ...c, widget };
  lastWidgetForKeyframes = widget;
}

// Fail loud on any mapped widget resolving to zero blocks
const zeroBlockWidgets = Object.keys(widgetBlocks).filter(w => widgetBlocks[w].length === 0);
if (zeroBlockWidgets.length > 0) {
  fatal(
    `Fail-loud: the following widgets have zero @layer components blocks in the compiled CSS:\n` +
    zeroBlockWidgets.map(w => `  → ${w}`).join('\n') +
    `\n\nUpstream basecoat may have renamed/removed these. Update css-section-map.json.`
  );
}

// ---------------------------------------------------------------------------
// Step 4: Collect passthrough constructs (registered-property + properties-layer)
// ---------------------------------------------------------------------------
const passthroughParts = [];
const seenProperties = new Set();

for (const c of classified) {
  if (c.taxonomy === 'registered-property') {
    // Dedupe by property name (c.prelude is the property name like " --tw-translate-x")
    const propName = (c.prelude ?? '').trim();
    if (!seenProperties.has(propName)) {
      seenProperties.add(propName);
      passthroughParts.push(c.raw.trim());
    }
  }
  if (c.taxonomy === 'properties-layer') {
    // There should be exactly one @layer properties { } block — include it once
    if (c.block !== null) {
      passthroughParts.push(c.raw.trim());
    }
  }
}

const passthroughCSS = passthroughParts.join('\n');

// ---------------------------------------------------------------------------
// Step 5: Collect theme tokens
// ---------------------------------------------------------------------------
// theme tokens: @layer theme { :root, :host { ... } } + :root { } + .dark { }
// We gather them in source order to reproduce faithfully.
const themeTokenParts = [];

for (const c of classified) {
  if (c.taxonomy === 'theme-token') {
    themeTokenParts.push(c.raw.trim());
  }
}

// Extract :root and .dark blocks for the saola.theme sublayer.
// The @layer theme { :root, :host { } } block is Tailwind's theme vars.
// The top-level :root { } and .dark { } are Basecoat's custom token overrides.
// We'll extract just the inner :root/:host and .dark var blocks for our layer.

const themeVarBlocks = [];
for (const c of classified) {
  if (c.taxonomy !== 'theme-token') continue;

  if (c.type === 'at-rule' && c.name === 'layer' && (c.prelude ?? '').trim() === 'theme') {
    // @layer theme { :root, :host { … } } — take the block content directly
    themeVarBlocks.push({ selector: ':root, :host', content: (c.block ?? '').trim() });
  }

  if (c.type === 'qualified') {
    const sel = (c.selector ?? '').trim();
    if (sel === ':root' || sel === '.dark') {
      themeVarBlocks.push({ selector: sel, content: (c.block ?? '').trim() });
    }
  }
}

// Build the @layer saola.theme content
// The @layer theme block content is already "{ :root, :host { … } }" but we have
// the block content (between the outer braces), which is " :root, :host { … }".
// We need to re-wrap correctly for our saola.theme layer.
function buildThemeLayer() {
  const parts = [];
  for (const { selector, content } of themeVarBlocks) {
    if (selector === ':root, :host') {
      // This is from @layer theme { :root, :host { ... } }
      // The block content is the inner text of @layer theme { }, which should be
      // " :root, :host { --font-sans: ... } "
      // We inline it directly into our layer.
      parts.push(content.trim());
    } else {
      // Top-level :root { } or .dark { }
      parts.push(`${selector} {\n${indent(content.trim(), 2)}\n}`);
    }
  }
  return parts.join('\n');
}

// ---------------------------------------------------------------------------
// Step 6: Derive widget-roots list for scoped reset
// ---------------------------------------------------------------------------
// We generate the :where(<widget-roots>) selector list from the widget selector
// map. The root selectors are the primary class/element selectors for each widget.
// We pick the most intuitive representative selector per widget.

const WIDGET_ROOT_SELECTORS = [
  '.alert',
  '.badge',
  '.btn',
  '.button-group',
  '.card',
  'input[type=checkbox]:not([role=switch])',
  'details',
  '.command',
  '.command-dialog',
  '.dialog',
  '.dropdown-menu',
  '.fieldset',
  '.field',
  'input[type=text]',
  '.kbd',
  '.label',
  '[data-popover]',
  'input[type=radio]',
  'input[type=range]',
  'select',
  '.sidebar',
  'input[type=checkbox][role=switch]',
  '.table',
  '.tabs',
  'textarea',
  '.toaster',
  '.toast',
  '[data-tooltip]',
];

// Combine generated-widget roots with authored-widget roots from the map JSON.
// authoredWidgetRoots covers Phase-02 standalone widgets that have no basecoat counterpart.
const ALL_WIDGET_ROOT_SELECTORS = [...WIDGET_ROOT_SELECTORS, ...authoredWidgetRoots];
const widgetRootsList = ALL_WIDGET_ROOT_SELECTORS.join(',\n  ');

// ---------------------------------------------------------------------------
// Step 7: Build preflight content — the global @layer base blocks
// ---------------------------------------------------------------------------
const preflightParts = [];
for (const c of classified) {
  if (c.taxonomy === 'preflight') {
    preflightParts.push(c.raw.trim());
  }
}
const preflightCSS = preflightParts.join('\n\n');

// ---------------------------------------------------------------------------
// Step 8: Build the scoped reset for saola.base (C2 preflight-dependency audit)
// ---------------------------------------------------------------------------
// Preflight rules that widget CSS depends on (from @layer base analysis):
//   Line 67-72:  *, ::after, ::before, ::backdrop, ::file-selector-button
//                  { box-sizing: border-box; margin: 0; padding: 0; border: 0 solid; }
//   Line 297-303: * { border-color: var(--color-border); outline-color: var(--color-ring); }
//   Line 149-157: button, input, select, optgroup, textarea, ::file-selector-button
//                  { font: inherit; font-feature-settings: inherit; font-variation-settings: inherit;
//                    letter-spacing: inherit; color: inherit; border-radius: 0;
//                    background-color: transparent; opacity: 1; }
//   Line 314-327: .scrollbar { scrollbar-width: thin; … } — reusable utility, included in base
//
// Global-only rules excluded from scoped reset (go only to preflight.css):
//   html, :host { line-height, text-size-adjust, font-family, … }
//   body { overscroll-behavior, background-color, color, font-smoothing }
//   hr, abbr, h1-h6, a, b, strong, code, kbd, … — typography resets
//
// Scoped reset: applied only to :where(<widget-roots>) and :where(<widget-roots>) *
// so host rules always win (zero specificity via :where, documented limit).

function buildScopedReset() {
  const rootSel = `:where(\n  ${widgetRootsList}\n)`;
  const childSel = `:where(\n  ${widgetRootsList}\n) *`;

  return `${rootSel},\n${childSel} {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  border: 0 solid;
  border-color: var(--color-border);
  outline-color: var(--color-ring);
  @supports (color: color-mix(in lab, red, red)) {
    outline-color: color-mix(in oklab, var(--color-ring) 50%, transparent);
  }
}

/* Form element font inheritance — widgets use native inputs/buttons/selects */
:where(
  ${ALL_WIDGET_ROOT_SELECTORS.filter(s => s.match(/^(input|select|textarea|button)/)).join(',\n  ')}
) {
  font: inherit;
  font-feature-settings: inherit;
  font-variation-settings: inherit;
  letter-spacing: inherit;
  color: inherit;
  border-radius: 0;
  background-color: transparent;
  opacity: 1;
}

/* Scrollbar utility — reusable across all widgets (from @layer base .scrollbar) */
.scrollbar {
  scrollbar-width: thin;
  scrollbar-color: var(--scrollbar-thumb) var(--scrollbar-track);
  &::-webkit-scrollbar {
    width: var(--scrollbar-width);
  }
  &::-webkit-scrollbar-track {
    background: var(--scrollbar-track);
  }
  &::-webkit-scrollbar-thumb {
    background: var(--scrollbar-thumb);
    border-radius: var(--scrollbar-radius);
  }
}`;
}

// ---------------------------------------------------------------------------
// Step 9: Build base.css
// ---------------------------------------------------------------------------
console.log('build-css: building base.css…');

const themeLayerContent = buildThemeLayer();
const scopedResetContent = buildScopedReset();

const baseCssContent = [
  `${SENTINEL}`,
  `/* Tailwind v4 registered custom properties — passthrough, must be top-level (invalid inside @layer). */`,
  passthroughCSS,
  ``,
  `/* Saola cascade layer declaration — establishes layer order for all per-widget imports. */`,
  `@layer saola, saola.theme, saola.base, saola.components;`,
  ``,
  `@layer saola.theme {`,
  indent(themeLayerContent, 2),
  `}`,
  ``,
  `@layer saola.base {`,
  indent(scopedResetContent, 2),
  `}`,
].join('\n');

const baseOutputPath = resolve(SRC_SAOLA, 'base.css');
assertWithinSrcSaola(baseOutputPath);
const baseWritten = writeIfChanged(baseOutputPath, baseCssContent);
console.log(`  base.css → ${baseWritten ? 'written' : 'unchanged'} (${baseCssContent.length} chars)`);

// ---------------------------------------------------------------------------
// Step 10: Emit per-widget CSS files
// ---------------------------------------------------------------------------
console.log('build-css: emitting per-widget files…');

let widgetCount = 0;
for (const [widgetName, outputFile] of Object.entries(widgetOutputFiles)) {
  const blocks = widgetBlocks[widgetName];
  const outputPath = resolve(SRC_SAOLA, outputFile);

  assertWithinSrcSaola(outputPath);
  assertSentinelOrNew(outputPath);

  // Preserve the custom region if it exists
  const customRegion = extractCustomRegion(outputPath);

  // Build the @layer saola.components content from all aggregated blocks
  const aggregatedRules = blocks.join('\n');

  // Find keyframes for this widget
  const keyframesForWidget = classified
    .filter(c => c.taxonomy === 'keyframes' && c.widget === widgetName)
    .map(c => c.raw.trim());

  // Build generated region
  const generatedLines = [
    SENTINEL,
    `@layer saola;`,
    `@import "./base.css";`,
    `@layer saola.components {`,
    aggregatedRules,
    `}`,
  ];

  // Keyframes must live outside @layer (they are not cascade-layer-aware in the same way)
  // Include them after the layer block
  if (keyframesForWidget.length > 0) {
    generatedLines.push('');
    generatedLines.push(...keyframesForWidget);
  }

  const generatedRegion = generatedLines.join('\n');

  // Compose: generated region + optional custom region
  const finalContent = customRegion
    ? generatedRegion + '\n' + customRegion
    : generatedRegion + '\n';

  const written = writeIfChanged(outputPath, finalContent);
  if (written) {
    console.log(`  ${outputFile} → written (${blocks.length} block(s))`);
  }
  widgetCount++;
}

console.log(`  ${widgetCount} widget files processed.`);

// ---------------------------------------------------------------------------
// Step 11: Emit .build-css/preflight.css
// ---------------------------------------------------------------------------
console.log('build-css: writing .build-css/preflight.css…');

const preflightOutput = resolve(BUILD_CSS, 'preflight.css');
const preflightFull = [
  `/* preflight.css — global Tailwind/Basecoat reset, isolated for Phase-03 opt-in bundle. */`,
  `/* Do not import this in per-widget files; use saola-preflight.css bundle instead. */`,
  ``,
  preflightCSS,
].join('\n');

const preflightWritten = writeIfChanged(preflightOutput, preflightFull);
console.log(`  preflight.css → ${preflightWritten ? 'written' : 'unchanged'}`);

// ---------------------------------------------------------------------------
// Done
// ---------------------------------------------------------------------------
console.log('\nbuild-css: done.');
console.log(`  Widgets emitted : ${widgetCount}`);
console.log(`  @property rules : ${seenProperties.size}`);
console.log(`  Widget roots    : ${ALL_WIDGET_ROOT_SELECTORS.length} (${WIDGET_ROOT_SELECTORS.length} generated + ${authoredWidgetRoots.length} authored)`);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Indent each non-empty line of a multi-line string by N spaces.
 *
 * @param {string} text
 * @param {number} spaces
 * @returns {string}
 */
function indent(text, spaces) {
  const pad = ' '.repeat(spaces);
  return text
    .split('\n')
    .map(line => (line.trim() === '' ? '' : pad + line))
    .join('\n');
}
