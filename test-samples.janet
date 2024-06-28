(import ./_conf :as c)
(import ./_util :as u)
(import ./gen-parser-c :as gpc)

########################################################################

(defn parse-paths
  [paths-file]
  (with [tf (file/temp)]
    # will exit 1 on parse errors, but only after processing all
    # files in paths-file (iiuc)
    (u/ts-command ["parse"
                   "--paths" paths-file
                   "--quiet"]
                  :e
                  {:out tf})
    (file/flush tf)
    (file/seek tf :set 0)
    #
    (file/read tf :all)))

# XXX: format of line has changed at least once...hopefully it won't
#      change again...the peg below is not as precise as it could be
#      but it may be more robust across different ts cli versions
(defn parse-error-line
  [line]
  (def parse-peg
    ~(sequence (capture (some :S))
               (some " ")
               (capture (thru "ms"))
               (capture (to "("))
               (sequence "("
                         (capture (some :S))
                         " "
                         (capture (to ")"))
                         ")")))
  (peg/match parse-peg line))

(comment

  (def error-line
    (string "repos/github.com/jjkh/aoc-2023/day2.janet"
            "                                               "
            "\t"
            "0 ms"
	    "\t"
            "(ERROR [46, 28] - [46, 29])"))

  (parse-error-line error-line)
  # =>
  @["repos/github.com/jjkh/aoc-2023/day2.janet"
    "\t0 ms"
    "\t"
    "ERROR"
    "[46, 28] - [46, 29]"]

  )

########################################################################

(defn main
  [& args]
  (when (not (u/do-deps gpc/main))
    (break false))

  (when (not (u/is-dir? c/repos-path))
    (eprintf "expected a directory for: %s" c/repos-path)
    (break false))

  # find all .janet files
  (def src-paths @[])
  (u/just-files c/repos-path
                src-paths
                |(string/has-suffix? ".janet" $))

  # put paths of .janet files in a single file for ts cli
  (def paths-file "__paths.txt")
  (when (os/stat paths-file)
    (eprintf "please move %s out of the way" paths-file)
    (break false))
  (spit paths-file
        (string/join src-paths "\n"))

  # finally, parse the paths
  (def error-lines 
    (defer (os/rm paths-file)
      (parse-paths paths-file)))

  # go over the results and report
  (var i 0)
  (each line (string/split "\n" error-lines)
    (when (not (empty? line))
      (if-let [parsed (parse-error-line line)]
        (do
          (eprintf "%M" parsed)
          (++ i))
        (eprintf "failed to parse: %s" line))))
  #
  (printf "Files parsed: %d" (length src-paths))
  (eprintf "Files with parse errors: %d" i)
  #
  true)

