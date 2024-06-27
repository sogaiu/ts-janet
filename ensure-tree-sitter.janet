(import ./_conf :as c)
(import ./_util :as u)
(import ./ensure-rust-bits :as erb)

(defn make-tree-sitter-config
  []
  (os/mkdir c/ts-conf-dir)
  (os/mkdir c/ts-lib-dir)
  (spit (string c/ts-conf-dir "/" "config.json")
        (string `{`                         "\n"
                `  "parser-directories": [` "\n"
                `    "."`                   "\n"
                `  ]`                       "\n"
                `}`                         "\n")))

(defn main
  [& argv]
  (make-tree-sitter-config)
  (when (not (os/stat c/ts-bin-path))
    (when (not (u/do-deps erb/main))
      (break false))
    #
    (def dir (os/cwd))
    (defer (os/cd dir)
      (when (not (u/run ["git" "clone" c/ts-url]))
        (eprintf "cloning of tree-sitter repo failed")
        (break false))
      #
      (os/cd c/ts-src-path)
      (when (not (u/run ["git" "checkout" c/ts-ref]))
        (eprintf "checkout failed for ref: %s" c/ts-ref)
        (break false))
      #
      (when (not (u/run ["cargo" "build" "--release"]))
        (eprintf "cargo build failed for tree-sitter cli")
        (break false))))
  #
  true)

