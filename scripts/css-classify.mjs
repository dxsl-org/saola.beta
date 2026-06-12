/**
 * css-classify.mjs
 *
 * Classifies top-level CSS constructs from the compiled assets/basecoat.css
 * into the taxonomy defined in css-section-map.json.
 *
 * Taxonomy (exhaustive — any unrecognized construct causes a non-zero exit):
 *   layer-decl        — @layer <name-list> ; declaration (Tailwind-native ordering)
 *   theme-token       — @layer theme { :root, :host { … } } or top-level :root { } / .dark { }
 *   preflight         — @layer base { … } blocks styling *,html,body,hr,a… (global reset)
 *   registered-property — @property --tw-* { … }
 *   properties-layer  — @layer properties { @supports … } passthrough block
 *   utilities-block   — @layer utilities ; statement (Tailwind placeholder, no output)
 *   component-section — @layer components { … } block, further classified by selector set
 *   keyframes         — @keyframes <name> { … } associated with a widget
 *   comment           — CSS comment (only the Tailwind banner appears in compiled file)
 *   whitespace        — inter-construct whitespace/newlines (discarded from output)
 *
 * Contract:
 *   classifyConstruct(construct, sectionMap) → ClassifiedConstruct
 *   extractComponentSelectors(blockContent) → string[]  (first selector of each nested rule)
 *   matchWidget(selectors, widgetSelectorMap) → string | null
 *
 * Exported: classifyConstruct, extractComponentSelectors, matchWidget
 */

import { tokenize } from './css-tokenizer.mjs';

/**
 * Classify a single top-level construct.
 * Returns the construct annotated with a `taxonomy` field.
 *
 * On unrecognized constructs the caller must exit non-zero — this function
 * returns taxonomy: 'unknown' and the caller decides to fail.
 *
 * @param {{ type: string, name?: string, prelude?: string, selector?: string, block: string|null, raw: string, startLine: number }} construct
 * @returns {object} construct + { taxonomy: string }
 */
export function classifyConstruct(construct) {
  const { type, name, prelude, selector } = construct;

  if (type === 'comment') return { ...construct, taxonomy: 'comment' };
  if (type === 'whitespace') return { ...construct, taxonomy: 'whitespace' };

  if (type === 'at-rule') {
    // @layer properties;  →  properties-layer (the statement-form)
    // @layer properties { … }  →  properties-layer (the block-form)
    if (name === 'layer') {
      const prelTrimmed = (prelude ?? '').trim().replace(/;$/, '').trim();

      if (prelTrimmed === 'properties') {
        // Could be statement (@layer properties;) or block (@layer properties { })
        return { ...construct, taxonomy: 'properties-layer' };
      }

      if (prelTrimmed.includes(',')) {
        // @layer theme, base, components, utilities;  — Tailwind ordering decl
        return { ...construct, taxonomy: 'layer-decl' };
      }

      if (prelTrimmed === 'utilities' || prelTrimmed === 'utilities;') {
        return { ...construct, taxonomy: 'utilities-block' };
      }

      if (prelTrimmed === 'theme') {
        return { ...construct, taxonomy: 'theme-token' };
      }

      if (prelTrimmed === 'base') {
        return { ...construct, taxonomy: 'preflight' };
      }

      if (prelTrimmed === 'components') {
        return { ...construct, taxonomy: 'component-section' };
      }

      // Unknown named layer
      return { ...construct, taxonomy: 'unknown', reason: `Unrecognized @layer name: ${prelTrimmed}` };
    }

    if (name === 'property') {
      // @property --tw-*  — registered custom property passthrough
      return { ...construct, taxonomy: 'registered-property' };
    }

    if (name === 'keyframes') {
      return { ...construct, taxonomy: 'keyframes' };
    }

    // Any other at-rule at top level is unknown
    return { ...construct, taxonomy: 'unknown', reason: `Unrecognized at-rule: @${name}` };
  }

  if (type === 'qualified') {
    // Top-level qualified rules in compiled basecoat are theme tokens:
    //   :root { --radius: … } — basecoat custom properties
    //   .dark { --background: … }
    const sel = (selector ?? '').trim();
    if (sel === ':root' || sel === '.dark') {
      return { ...construct, taxonomy: 'theme-token' };
    }
    return { ...construct, taxonomy: 'unknown', reason: `Unrecognized top-level qualified rule selector: ${sel}` };
  }

  return { ...construct, taxonomy: 'unknown', reason: `Unrecognized construct type: ${type}` };
}

/**
 * Extract the first (outermost) selector of each rule inside a @layer components block.
 * These are the selectors we use to classify the block into a widget.
 *
 * We tokenize the block content and return the first selector found.
 * For component blocks, the ENTIRE block content belongs to a single widget,
 * so we extract just the first selector to identify it.
 *
 * @param {string} blockContent  — content between the outer { } of @layer components
 * @returns {string[]}  array of top-level selectors found in this block
 */
export function extractComponentSelectors(blockContent) {
  // Tokenize the block content as if it were a CSS document
  const constructs = tokenize(blockContent);
  const selectors = [];

  for (const c of constructs) {
    if (c.type === 'whitespace' || c.type === 'comment') continue;
    if (c.type === 'qualified' && c.selector) {
      // The selector may be a comma-separated list; split and add each
      const parts = splitSelectorList(c.selector);
      selectors.push(...parts.map(s => s.trim()).filter(Boolean));
    }
    if (c.type === 'at-rule') {
      // At-rules inside a component block (e.g. @supports) are not individual selectors
      // We skip them for classification — the outer selector-set drives the widget match
    }
  }

  return selectors;
}

/**
 * Split a CSS selector list by top-level commas (not commas inside parens).
 *
 * @param {string} selectorList
 * @returns {string[]}
 */
function splitSelectorList(selectorList) {
  const parts = [];
  let depth = 0;
  let current = '';

  for (let i = 0; i < selectorList.length; i++) {
    const ch = selectorList[i];
    if (ch === '(' || ch === '[') { depth++; current += ch; continue; }
    if (ch === ')' || ch === ']') { depth--; current += ch; continue; }
    if (ch === ',' && depth === 0) {
      parts.push(current);
      current = '';
      continue;
    }
    current += ch;
  }
  if (current.trim()) parts.push(current);
  return parts;
}

/**
 * Match an array of selectors from a @layer components block to a widget name
 * by consulting the widgetSelectorMap from css-section-map.json.
 *
 * Rules:
 * 1. More-specific entries come first in the map (enforced by map order).
 * 2. A selector "matches" a map entry if the selector starts with the entry's
 *    selectorPrefix (after normalizing whitespace).
 * 3. ALL selectors in the block must map to the SAME widget, or the block is ambiguous.
 * 4. Returns the widget name if unambiguous, null if no match, throws on conflict.
 *
 * @param {string[]} selectors
 * @param {Array<{selectorPrefix: string, widget: string}>} widgetSelectorMap
 * @returns {{ widget: string, unmatched: string[] }}
 *   widget:    matched widget name (or null if truly empty)
 *   unmatched: selectors that matched no entry (caller must fail-loud on these)
 */
export function matchWidget(selectors, widgetSelectorMap) {
  if (selectors.length === 0) return { widget: null, unmatched: [] };

  const widgetsFound = new Set();
  const unmatched = [];

  for (const sel of selectors) {
    const normalized = normalizeSelector(sel);
    const entry = findBestMatch(normalized, widgetSelectorMap);
    if (entry) {
      widgetsFound.add(entry.widget);
    } else {
      unmatched.push(sel);
    }
  }

  if (unmatched.length > 0) {
    return { widget: null, unmatched };
  }

  if (widgetsFound.size === 0) {
    return { widget: null, unmatched: selectors };
  }

  if (widgetsFound.size > 1) {
    throw new Error(
      `Ambiguous @layer components block maps to multiple widgets: ${[...widgetsFound].join(', ')}. ` +
      `Selectors: ${selectors.slice(0, 3).join(' | ')}`
    );
  }

  return { widget: [...widgetsFound][0], unmatched: [] };
}

/**
 * Normalize a selector for prefix matching:
 * - collapse internal whitespace sequences to a single space
 * - trim
 *
 * @param {string} sel
 * @returns {string}
 */
function normalizeSelector(sel) {
  return sel.replace(/\s+/g, ' ').trim();
}

/**
 * Find the most-specific (longest matching prefix) entry in widgetSelectorMap
 * whose selectorPrefix is a prefix of the given selector.
 *
 * "Prefix" means: the selector starts with the prefix string (case-sensitive).
 * We pick the LONGEST matching prefix for specificity.
 *
 * @param {string} selector  — normalized selector
 * @param {Array<{selectorPrefix: string, widget: string}>} map
 * @returns {{ selectorPrefix: string, widget: string } | null}
 */
function findBestMatch(selector, map) {
  let best = null;
  for (const entry of map) {
    if (selector.startsWith(entry.selectorPrefix)) {
      if (!best || entry.selectorPrefix.length > best.selectorPrefix.length) {
        best = entry;
      }
    }
  }
  return best;
}
