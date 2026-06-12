/**
 * test-negative.mjs
 *
 * Executes negative tests for build-css.mjs guards:
 *   1. Fake unmatched selector → exit non-zero naming it
 *   2. Widget CSS without @generated sentinel → refused
 *   3. @import injected in sliced content → exit non-zero
 *
 * Runs against temp copies; original files untouched.
 * Exits 0 if all three negative tests pass, 1 if any fail.
 */

import { spawnSync } from 'child_process';
import { readFileSync, writeFileSync, mkdirSync, existsSync, unlinkSync, rmSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, '..');
const SCRIPTS   = __dirname;

const INPUT_CSS   = resolve(REPO_ROOT, 'assets/basecoat.css');
const SRC_SAOLA   = resolve(REPO_ROOT, 'src/saola');
const BUILD_SCRIPT = resolve(SCRIPTS, 'build-css.mjs');

let allPassed = true;

// ---------------------------------------------------------------------------
// Helper: run build-css.mjs with a different INPUT_CSS by creating a patched
// temp script that imports from the same ./scripts/ dir.
// ---------------------------------------------------------------------------
function runWithInput(testInputPath) {
  let script = readFileSync(BUILD_SCRIPT, 'utf8');
  // Replace the INPUT_CSS constant with our test path (escaped for Windows backslashes)
  const escapedPath = testInputPath.replace(/\\/g, '/');
  script = script.replace(
    /const INPUT_CSS\s*=\s*resolve\(REPO_ROOT,\s*'assets\/basecoat\.css'\);/,
    `const INPUT_CSS = '${escapedPath}';`
  );
  // Also suppress the output writes to avoid polluting src/saola/ with test output
  // We redirect output dir to a temp location
  const tempOutputDir = resolve(REPO_ROOT, '.build-css/.test-output');
  mkdirSync(tempOutputDir, { recursive: true });
  const escapedOut = tempOutputDir.replace(/\\/g, '/');
  script = script.replace(
    /const SRC_SAOLA\s*=\s*resolve\(REPO_ROOT,\s*'src\/saola'\);/,
    `const SRC_SAOLA = '${escapedOut}';`
  );

  const tempScript = resolve(SCRIPTS, '_test-build-css-temp.mjs');
  writeFileSync(tempScript, script, 'utf8');

  const result = spawnSync('bun', [tempScript], {
    cwd: REPO_ROOT,
    encoding: 'utf8',
    timeout: 30000,
  });

  try { unlinkSync(tempScript); } catch {}
  try { rmSync(tempOutputDir, { recursive: true, force: true }); } catch {}

  return result;
}

// ---------------------------------------------------------------------------
// Test 1: Fake unmatched selector → exit non-zero naming it
// ---------------------------------------------------------------------------
console.log('Negative test 1: fake selector .frobnicator …');
{
  const css = readFileSync(INPUT_CSS, 'utf8');
  // Inject a .frobnicator block before the first @layer components block
  // Use the actual CRLF line endings that are in the compiled file
  const patched = css.replace(
    '@layer components {\r\n  .alert, .alert-destructive {',
    '@layer components {\r\n  .frobnicator { color: red; }\r\n}\r\n@layer components {\r\n  .alert, .alert-destructive {'
  );
  const tempInput = resolve(REPO_ROOT, '.build-css/test-fake-selector.css');
  mkdirSync(resolve(REPO_ROOT, '.build-css'), { recursive: true });
  writeFileSync(tempInput, patched, 'utf8');

  const result = runWithInput(tempInput);
  unlinkSync(tempInput);

  if (result.status !== 0 && (result.stderr + result.stdout).includes('frobnicator')) {
    console.log('  PASS: exited non-zero and named .frobnicator');
  } else {
    console.error('  FAIL: expected non-zero exit naming .frobnicator');
    console.error('  status:', result.status);
    console.error('  output:', (result.stderr + result.stdout).slice(0, 300));
    allPassed = false;
  }
}

// ---------------------------------------------------------------------------
// Test 2: Widget CSS without @generated sentinel → refused on write
// ---------------------------------------------------------------------------
console.log('Negative test 2: widget file without sentinel …');
{
  const targetFile = resolve(SRC_SAOLA, 'button.css');
  const originalContent = readFileSync(targetFile, 'utf8');
  // Write a version without the sentinel
  const noSentinel = originalContent.replace(
    '/* @generated saola-css — do not edit; regenerated from basecoat */',
    '/* this file was hand-written */'
  );
  writeFileSync(targetFile, noSentinel, 'utf8');

  const result = spawnSync('bun', [BUILD_SCRIPT], {
    cwd: REPO_ROOT,
    encoding: 'utf8',
    timeout: 30000,
  });

  // Restore the original file regardless
  writeFileSync(targetFile, originalContent, 'utf8');

  if (result.status !== 0 && (result.stderr + result.stdout).includes('Sentinel')) {
    console.log('  PASS: exited non-zero with sentinel guard message');
  } else {
    console.error('  FAIL: expected non-zero exit with sentinel guard');
    console.error('  status:', result.status);
    console.error('  output:', (result.stderr + result.stdout).slice(0, 300));
    allPassed = false;
  }
}

// ---------------------------------------------------------------------------
// Test 3: @import injected in sliced content → exit non-zero
// ---------------------------------------------------------------------------
console.log('Negative test 3: @import in sliced content …');
{
  const css = readFileSync(INPUT_CSS, 'utf8');
  // Inject @import inside the first @layer components block (CRLF line endings in compiled file)
  const patched = css.replace(
    '@layer components {\r\n  .alert, .alert-destructive {',
    '@layer components {\r\n  @import "evil.css";\r\n  .alert, .alert-destructive {'
  );
  const tempInput = resolve(REPO_ROOT, '.build-css/test-import-injection.css');
  writeFileSync(tempInput, patched, 'utf8');

  const result = runWithInput(tempInput);
  unlinkSync(tempInput);

  if (result.status !== 0 && (result.stderr + result.stdout).toLowerCase().includes('import')) {
    console.log('  PASS: exited non-zero rejecting @import');
  } else {
    console.error('  FAIL: expected non-zero exit rejecting @import');
    console.error('  status:', result.status);
    console.error('  output:', (result.stderr + result.stdout).slice(0, 300));
    allPassed = false;
  }
}

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------
if (allPassed) {
  console.log('\nAll negative tests PASSED.');
  process.exit(0);
} else {
  console.error('\nSome negative tests FAILED.');
  process.exit(1);
}
