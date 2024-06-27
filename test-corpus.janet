(import ./_conf :as c)
(import ./_util :as u)
(import ./gen-parser-c :as gpc)

(defn main
  [& argv]
  (when (not (gpc/main))
    (eprintf "gen-parser-c task failed")
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
