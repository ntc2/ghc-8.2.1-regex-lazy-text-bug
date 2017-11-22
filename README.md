Regression in Text.RE.TDFA + Text.Lazy in GHC 8.2.1
===================================================

In GHC 8.2.1, I observe apparently exponential time in the length of
the file when matching a simple regex using `Text.Regex.TDFA` and
`Data.Text.Lazy`. And this is a Heisenbug, in that the performance
problem goes away if I build with profiling support! The problem is
not present in GHC 8.0.2, or when using `String` or strict
`Data.Text`.

Timing stats for buggy configuration
------------------------------------

For the buggy combination `Data.Text.Lazy` without profiling, the bad
run times are

    File: defs-10000.txt
    Lines: 10000
    Defs: 10000
    stack exec --stack-yaml stack-ghc-8.2.1.yaml slow-regex text-lazy   3.38s user 0.08s system 100% cpu 3.456 total

    File: defs-20000.txt
    Lines: 20000
    Defs: 20000
    stack exec --stack-yaml stack-ghc-8.2.1.yaml slow-regex text-lazy   10.41s user 0.16s system 100% cpu 10.555 total

    File: defs-30000.txt
    Lines: 30000
    Defs: 30000
    stack exec --stack-yaml stack-ghc-8.2.1.yaml slow-regex text-lazy   22.48s user 0.16s system 100% cpu 22.637 total

    File: defs-40000.txt
    Lines: 40000
    Defs: 40000
    stack exec --stack-yaml stack-ghc-8.2.1.yaml slow-regex text-lazy   39.84s user 0.30s system 100% cpu 40.121 total

I.e. the run times are 3s, 10s, 22s, and 40s for files with 10000,
20000, 30000, and 40000 lines, respectively. For all of the
unproblematic configurations, the run time is always about 1s.

How the results were computed
-----------------------------

Running test without profiling:

    results=results-without-profiling.txt; :>$results; for yaml in stack-ghc-8.0.2.yaml stack-ghc-8.2.1.yaml; do for mode in string text-strict text-lazy; do for file in defs-10000.txt defs-20000.txt defs-30000.txt defs-40000.txt; do stack build --stack-yaml $yaml slow-regex && zsh -c "time stack exec --stack-yaml $yaml slow-regex $mode $file"; echo; done; done; done 2>&1 | tee -a $results

Running test with profiling:

    results=results-with-profiling.txt; :>$results; for yaml in stack-ghc-8.0.2.yaml stack-ghc-8.2.1.yaml; do for mode in string text-strict text-lazy; do for file in defs-10000.txt defs-20000.txt defs-30000.txt defs-40000.txt; do stack build --profile --stack-yaml $yaml slow-regex && zsh -c "time stack exec --stack-yaml $yaml slow-regex $mode $file"; echo; done; done; done 2>&1 | tee -a $results
