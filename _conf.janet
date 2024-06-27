(def proj-dir (os/cwd))

########################################################################

(def grammar-url "https://github.com/sogaiu/tree-sitter-janet-simple")

(def grammar-ref "master")

# from portion of url after last slash
(def grammar-dir
  (string/slice grammar-url
                (-> (string/find-all "/" grammar-url)
                    last
                    inc)))

(def grammar-path
  (string proj-dir "/" grammar-dir))

########################################################################

(def ts-url "https://github.com/tree-sitter/tree-sitter")

(def ts-ref "v0.20.8")

(def ts-abi (string 13))

(def ts-src-path
  (string proj-dir "/" "tree-sitter"))

(def ts-bin-path
  (string ts-src-path "/" "target/release/tree-sitter"))

(def ts-conf-dir
  (string proj-dir "/" ".tree-sitter"))

(def ts-lib-dir
  (string proj-dir "/" ".tree-sitter/lib"))

(def ts-env-dict
  {"TREE_SITTER_DIR" ts-conf-dir
   "TREE_SITTER_LIBDIR" ts-lib-dir})

