(import ./_conf :as c)

########################################################################

(defn do-deps
  [& deps]
  (var all-passed true)
  (each dep-fn deps
    (def [success? result] (protect (dep-fn)))
    (when (or (not success?)
              (not result))
      # XXX: don't know a good way to get the name
      #(eprintf "%n task failed" dep-fn)
      (set all-passed false)
      (break)))
  #
  all-passed)

########################################################################

(defn bin-exists?
  [name]
  (with [of (file/temp)]
    (with [ef (file/temp)]
      # of and ef are here to swallow output
      (def r (os/execute ["which" name] :p {:out of :err ef}))
      #
      (zero? r))))

(defn run
  [args &opt flags env]
  (default flags :p)
  (default env {})
  # consistency check
  (when (not (empty? env))
    (assert (has-value? flags (chr "e"))
            (string/format "flags missing `e`: %n" flags)))
  (def r (os/execute args flags env))
  (def success? (zero? r))
  (when (not success?)
    (eprintf "%n failed with exit code %d" args r))
  #
  success?)

(defn ts-command
  [args &opt flags env]
  (default flags :e)
  (default env {})
  (assert (has-value? flags (chr "e"))
          (string/format "flags missing `e`: %n" flags))
  # ensure environment contains appropriate TREE_SITTER_* env vars
  (run [c/ts-bin-path ;args]
       flags (merge c/ts-env-dict (os/environ) env)))

########################################################################

(defn is-dir?
  [path]
  (when-let [path path
             stat (os/stat path)]
    (= :directory (stat :mode))))

(defn is-file?
  ``
  Returns true if `path` is an ordinary file (e.g. not a directory).
  Otherwise, returns false.
  ``
  [path]
  (truthy?
    (when-let [path path
               mode-stat (os/stat path :mode)]
      (= :file mode-stat))))

(def fs-sep
  (if (= :windows (os/which))
    "\\"
    "/"))

(defn path-join
  [left-part right-part &opt sep]
  (default sep fs-sep)
  (string/join @[left-part right-part] sep))

(comment

  (path-join "/root" ".local/share" "/")
  # =>
  "/root/.local/share"

  )

(defn just-files
  ``
  Recursively visit directory tree starting at `path`, accumulating
  file (not directory) paths by default into array `acc`.  If optional
  argument `a-fn` is specified, instead accumulate only file paths
  for which `a-fn` applied to the file path returns a truthy result.
  ``
  [path acc &opt a-fn]
  (default a-fn identity)
  (when (is-dir? path)
    (each thing (os/dir path)
      (def thing-path
        (path-join path thing))
      (cond
        (and (is-file? thing-path)
             (a-fn thing-path))
        (array/push acc thing-path)
        #
        (is-dir? thing-path)
        (just-files thing-path acc a-fn))))
  acc)

(comment

  (def paths @[])

  (just-files (string c/proj-dir "/" "repos")
              paths
              |(string/has-suffix? ".janet" $))

  )
