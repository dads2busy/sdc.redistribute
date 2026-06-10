## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission, so R CMD check reports the standard
  "New submission" NOTE.
* The incoming-feasibility check flags "dasymetric" in the Description as
  possibly misspelled. It is spelled correctly: dasymetric mapping is a
  standard term in spatial analysis for distributing values using ancillary
  data.

(The local check additionally reports a "checking for future file timestamps ...
unable to verify current time" NOTE, which is an environmental artifact of the
build machine being unable to reach a time server and does not occur on
network-connected check services.)

## Test environments

* local macOS, R 4.5.0
* GitHub Actions: ubuntu-latest (release, devel, oldrel-1), macOS-latest
  (release), windows-latest (release)
* win-builder (R-devel)
