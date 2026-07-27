import { readFileSync, readdirSync } from "node:fs";
import path from "node:path";

const TESTS_PER_SHARD = 2;
const EXCLUDED_TESTS = new Set(["autoheal-test-authorship-demo.test.yaml"]);

const [selectionPath, projectDirectory] = process.argv.slice(2);
if (!selectionPath || !projectDirectory) {
  throw new Error(
    "Usage: build-ai-select-matrix.mjs <selection.json> <project-directory>",
  );
}

/**
 * Converts standalone `momentic ai select --json` output into a GitHub Actions
 * matrix. A safe fallback runs every candidate, while an empty valid selection
 * skips the runner job.
 */
const selection = JSON.parse(readFileSync(selectionPath, "utf8"));
const tests = selection.fallbackToRunAll
  ? listCandidateTests()
  : listSelectedTests();
const matrix = buildMatrix(tests);

process.stdout.write(`has_tests=${tests.length > 0}\n`);
process.stdout.write(`matrix=${JSON.stringify(matrix)}\n`);

function listSelectedTests() {
  const projectPrefix = `${path
    .relative(process.cwd(), projectDirectory)
    .split(path.sep)
    .join("/")}/`;
  const tests = (selection.selectedTests ?? [])
    .map(({ testPath }) => testPath)
    .filter(Boolean)
    .map((testPath) =>
      testPath.startsWith(projectPrefix)
        ? testPath.slice(projectPrefix.length)
        : testPath,
    )
    .filter((testPath) => !EXCLUDED_TESTS.has(testPath));

  return [...new Set(tests)];
}

function listCandidateTests() {
  return readdirSync(projectDirectory, { recursive: true })
    .map((testPath) => testPath.split(path.sep).join("/"))
    .filter((testPath) => testPath.endsWith(".test.yaml"))
    .filter((testPath) => !EXCLUDED_TESTS.has(testPath))
    .sort();
}

function buildMatrix(tests) {
  if (tests.length === 0) {
    // The skipped consumer still needs a valid matrix expression.
    return { include: [{ shard: 0, totalShards: 0, testArgs: "" }] };
  }

  const totalShards = Math.ceil(tests.length / TESTS_PER_SHARD);
  const include = Array.from({ length: totalShards }, (_, index) => ({
    shard: index + 1,
    totalShards,
    // This repository's test paths do not contain whitespace.
    testArgs: tests
      .slice(index * TESTS_PER_SHARD, (index + 1) * TESTS_PER_SHARD)
      .join(" "),
  }));

  return { include };
}
