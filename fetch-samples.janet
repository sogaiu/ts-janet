(import ./_conf :as c)

########################################################################

# XXX: quick and dirty but may be fine for our purposes
(defn uri-to-dir-path
  [uri]
  (first (peg/match ~(sequence "https://"
                               (capture (thru -1)))
                    uri)))

(comment

  (uri-to-dir-path "https://gitlab.com/louis.jackman/janet-hypertext")
  # =>
  "gitlab.com/louis.jackman/janet-hypertext"

  )

(comment

  (def lines
    (slurp "./data/git-repos-list.txt"))

  (each line (string/split "\n" lines)
    (when (not (empty? line))
      (def url (string/trimr line))
      (print (uri-to-dir-path url))))

  )

(defn mkdir-p
  [path]
  (each idx (string/find-all "/" path)
    (when (< 0 idx)
      (let [curr-path (string/slice path 0 idx)]
        (when (not (os/lstat curr-path))
          (os/mkdir curr-path)))))
  (os/mkdir path))

(comment

  (def lines
    (slurp "./data/git-repos-list.txt"))

  (def repos-path "./repos")

  (os/mkdir repos-path)

  (each line (string/split "\n" lines)
    (when-let [url (string/trimr line)
               path (uri-to-dir-path url)]
      (mkdir-p (string repos-path "/" path))))

  )

(defn git-shallow-clone
  [repos-root url]
  (def old-dir (os/cwd))
  #
  (os/mkdir repos-root)
  (defer (os/cd old-dir)
    (os/cd repos-root)
    #
    (def dest-dir
      (uri-to-dir-path url))
    (assert dest-dir
      (string/format "failed to parse url: %n" url))
    # skip if dest-dir already exists
    (when (not (os/stat dest-dir))
      (mkdir-p dest-dir)
      (assert (os/stat dest-dir)
              (string/format "failed to create dir: %s" dest-dir))
      # need exit code so not using `run` from util.janet
      (os/execute ["git"
                   "clone" "--depth=1"
                   url dest-dir]
                  :p))))

(comment

  (git-shallow-clone "./repos" "https://git.sr.ht/~bakpakin/bee-server")

  )

(defn choose-n
  [list n &opt rng]
  (def actual-n
    (min n (length list)))
  (default rng (math/rng))
  #
  (def index-pool (range 0 (length list)))
  (def new-list @[])
  #
  (for i 0 actual-n
    (let [r-idx (math/rng-int rng (length index-pool))
          index (get index-pool r-idx)
          choice (get list index)]
      (array/push new-list choice)
      (array/remove index-pool r-idx)))
  #
  new-list)

(comment

  (let [an-rng (math/rng (os/cryptorand 8))
        list @[:a :b :c :x :y :z]
        n 3
        choices (choose-n list n an-rng)]
    (truthy?
      (and (= n (length choices))
           (all |(index-of $ list)
                choices)
           (= n (length (table ;(interleave choices choices)))))))
  # =>
  true

  )

########################################################################

(defn main
  [& args]
  (def n
    (if (> (length args) 1)
      (scan-number (get args 1))
      10))
  #
  (def repos-root (string c/proj-dir "/repos"))
  (os/mkdir repos-root)
  (when (not (= :directory
                (os/stat repos-root :mode)))
    (eprintf "repositories root needs to be a directory: %s" repos-root)
    (break false))
  #
  (def repos-list-path "data/git-repos-list.txt")
  (when (not (= :file
                (os/stat repos-list-path :mode)))
    (eprintf "%s should be a file" repos-list-path)
    (break false))
  #
  (def repo-lines (slurp repos-list-path))
  (def urls
    (keep |(when (pos? (length $))
             (string/trimr $))
          (string/split "\n" repo-lines)))
  #
  (def actual-n (min n (length urls)))
  (def n-urls
    (if (neg? n)
      urls
      (choose-n urls actual-n (math/rng (os/cryptorand 8)))))
  (def results @{})
  # skip git's prompts
  (os/setenv "GIT_TERMINAL_PROMPT" "0")
  (each url n-urls
    (def exit-code
      (git-shallow-clone repos-root url))
    (def results-for-code
      (array/push (get results exit-code @[])
                  url))
    (put results
         exit-code results-for-code))
  #
  (when (not (empty? results))
    (printf "%M" results)
    (printf "Successfully fetched repos: %d" (length (get results 0)))
    (eachk ret results
      (when (not (zero? ret))
        (eprintf "Error code %d: %d" ret (length (get results ret)))))))

