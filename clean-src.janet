(import ./_conf :as c)
(import ./_util :as u)

(defn main
  [& argv]
  (when (os/stat (string c/grammar-path "/" "src"))
    (def dir (os/cwd))
    (defer (os/cd dir)
      (os/cd c/grammar-path)
      # XXX: use absolute paths?
      (each path ["src/parser.c"
                  "src/grammar.json"
                  "src/node-types.json"]
        (when (os/stat path)
          (os/rm path)))
      (def headers-path "src/tree_sitter")
      (when (os/stat headers-path)
        (each path (os/dir headers-path)
          (def fuller-path (string headers-path "/" path))
          (when (os/stat fuller-path)
            (os/rm fuller-path)))
        (os/rmdir headers-path))))
  #
  true)
