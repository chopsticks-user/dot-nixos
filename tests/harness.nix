# runs lib.debug.runTests cases (attributes named test*) and turns failures into an evaluation
# error that shows each failing case with its expected and actual value
{ lib, pkgs }:
name: cases:
let
  failures = lib.debug.runTests cases;
  show = lib.generators.toPretty { multiline = false; };
in
if failures == [ ] then
  pkgs.runCommand "test-${name}" { } "touch $out"
else
  throw (
    "${name}: ${toString (lib.length failures)} of ${toString (lib.length (lib.attrNames cases))} failed\n"
    + lib.concatMapStringsSep "\n" (
      f: "  ${f.name}\n    expected: ${show f.expected}\n    actual:   ${show f.result}"
    ) failures
  )
