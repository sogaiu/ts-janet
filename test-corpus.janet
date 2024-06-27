(import ./_conf :as c)
(import ./_util :as u)
(import ./gen-parser-c :as gpc)

(defn main
  [& argv]
  (when (not (u/do-deps gpc/main))
    (break false))
  #
  (def dir (os/cwd))
  (defer (os/cd dir)
    (os/cd c/grammar-path)
    (when (not (u/ts-command ["test"]))
      (eprintf "tree-sitter test subcommand failed")
      (break false)))
  #
  true)
