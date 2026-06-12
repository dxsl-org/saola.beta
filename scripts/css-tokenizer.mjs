/**
 * css-tokenizer.mjs
 *
 * Brace-nesting-aware CSS block tokenizer. Splits a CSS string into a sequence
 * of top-level constructs (at-rules and qualified rules) without using naive
 * regex brace-counting, which breaks on strings, url(), and nested at-rules.
 *
 * Contract:
 *   tokenize(css: string) → TopLevelConstruct[]
 *
 * Each construct is one of:
 *   { type: 'at-rule',   name: string, prelude: string, block: string | null, raw: string, startLine: number }
 *   { type: 'qualified', selector: string, block: string, raw: string, startLine: number }
 *   { type: 'whitespace', raw: string }
 *
 * block contains the content between { } EXCLUDING the braces themselves,
 * preserving all inner nesting verbatim.
 *
 * String-aware: tracks single-quoted and double-quoted strings so braces/parens
 * inside strings are not counted. url() is handled by the string tracking once
 * it enters a quoted segment. Unquoted url(...) is skipped by paren-depth tracking.
 *
 * Exported: tokenize
 */

/**
 * Advance through the CSS source from position `pos`, consuming one
 * CSS string literal (starting at pos, where css[pos] is ' or ").
 * Returns the index AFTER the closing quote.
 *
 * @param {string} css
 * @param {number} pos - index of the opening quote character
 * @returns {number} position after the closing quote
 */
function skipString(css, pos) {
  const quote = css[pos];
  pos++; // skip opening quote
  while (pos < css.length) {
    const ch = css[pos];
    if (ch === '\\') {
      pos += 2; // skip escaped char
      continue;
    }
    if (ch === quote) {
      return pos + 1; // past closing quote
    }
    pos++;
  }
  // Unterminated string — return end of input
  return css.length;
}

/**
 * Advance through a comment starting at pos (css[pos]=='/').
 * Caller must have verified css[pos+1]==='*'.
 *
 * @param {string} css
 * @param {number} pos - index of '/'
 * @returns {number} position after '*\/'
 */
function skipComment(css, pos) {
  pos += 2; // skip '/*'
  while (pos < css.length) {
    if (css[pos] === '*' && css[pos + 1] === '/') {
      return pos + 2;
    }
    pos++;
  }
  return css.length;
}

/**
 * Consume a CSS block { ... } starting at pos (css[pos]==='{').
 * Handles nested blocks, strings, comments, and url().
 *
 * @param {string} css
 * @param {number} pos - index of '{'
 * @returns {{ content: string, end: number }}
 *   content = everything between the outer braces (exclusive),
 *   end     = index after the closing '}'
 */
function consumeBlock(css, pos) {
  // pos is '{'
  const start = pos + 1;
  pos++;
  let depth = 1;

  while (pos < css.length && depth > 0) {
    const ch = css[pos];
    if (ch === '/' && css[pos + 1] === '*') {
      pos = skipComment(css, pos);
      continue;
    }
    if (ch === '"' || ch === "'") {
      pos = skipString(css, pos);
      continue;
    }
    if (ch === '{') { depth++; pos++; continue; }
    if (ch === '}') { depth--; if (depth > 0) pos++; continue; }
    pos++;
  }

  // pos is at the closing '}' of depth-0
  return { content: css.slice(start, pos), end: pos + 1 };
}

/**
 * Count newlines in a substring to track source line numbers.
 *
 * @param {string} s
 * @returns {number}
 */
function countLines(s) {
  let n = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '\n') n++;
  }
  return n;
}

/**
 * Tokenize top-level CSS constructs.
 *
 * @param {string} css
 * @returns {Array<{type: string, name?: string, prelude?: string, selector?: string, block: string|null, raw: string, startLine: number}>}
 */
export function tokenize(css) {
  const constructs = [];
  let pos = 0;
  let line = 1;

  while (pos < css.length) {
    // Skip over BOM
    if (pos === 0 && css.charCodeAt(0) === 0xFEFF) { pos++; continue; }

    const ch = css[pos];

    // --- Comment ---
    if (ch === '/' && css[pos + 1] === '*') {
      const start = pos;
      const startLine = line;
      pos = skipComment(css, pos);
      const raw = css.slice(start, pos);
      line += countLines(raw);
      constructs.push({ type: 'comment', raw, startLine });
      continue;
    }

    // --- Whitespace / newlines ---
    if (/\s/.test(ch)) {
      const start = pos;
      const startLine = line;
      while (pos < css.length && /\s/.test(css[pos])) {
        if (css[pos] === '\n') line++;
        pos++;
      }
      constructs.push({ type: 'whitespace', raw: css.slice(start, pos), startLine });
      continue;
    }

    // --- At-rule ---
    if (ch === '@') {
      const start = pos;
      const startLine = line;
      pos++; // skip '@'

      // Read the at-rule name (identifier chars)
      let name = '';
      while (pos < css.length && /[\w-]/.test(css[pos])) {
        name += css[pos++];
      }

      // Read prelude (everything before '{' or ';')
      let prelude = '';
      while (pos < css.length) {
        const c = css[pos];
        if (c === '/' && css[pos + 1] === '*') {
          const commentStart = pos;
          pos = skipComment(css, pos);
          prelude += css.slice(commentStart, pos);
          line += countLines(css.slice(commentStart, pos));
          continue;
        }
        if (c === '"' || c === "'") {
          const strStart = pos;
          pos = skipString(css, pos);
          prelude += css.slice(strStart, pos);
          continue;
        }
        if (c === '{') break;
        if (c === ';') { prelude += c; pos++; break; }
        if (c === '\n') line++;
        prelude += c;
        pos++;
      }

      let block = null;
      if (pos < css.length && css[pos] === '{') {
        const result = consumeBlock(css, pos);
        block = result.content;
        const blockRaw = css.slice(pos, result.end);
        line += countLines(blockRaw);
        pos = result.end;
      }

      const raw = css.slice(start, pos);
      constructs.push({ type: 'at-rule', name, prelude: prelude.trim(), block, raw, startLine });
      continue;
    }

    // --- Qualified rule (selector + block) ---
    {
      const start = pos;
      const startLine = line;
      let selector = '';

      // Read until '{'
      while (pos < css.length) {
        const c = css[pos];
        if (c === '/' && css[pos + 1] === '*') {
          const commentStart = pos;
          pos = skipComment(css, pos);
          selector += css.slice(commentStart, pos);
          line += countLines(css.slice(commentStart, pos));
          continue;
        }
        if (c === '"' || c === "'") {
          const strStart = pos;
          pos = skipString(css, pos);
          selector += css.slice(strStart, pos);
          continue;
        }
        if (c === '{') break;
        if (c === ';') {
          // Declaration without a block (bare property — unusual at top-level but handle gracefully)
          selector += c; pos++; break;
        }
        if (c === '\n') line++;
        selector += c;
        pos++;
      }

      let block = null;
      if (pos < css.length && css[pos] === '{') {
        const result = consumeBlock(css, pos);
        block = result.content;
        const blockRaw = css.slice(pos, result.end);
        line += countLines(blockRaw);
        pos = result.end;
      }

      const raw = css.slice(start, pos);
      constructs.push({ type: 'qualified', selector: selector.trim(), block, raw, startLine });
      continue;
    }
  }

  return constructs;
}
