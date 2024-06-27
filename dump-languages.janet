(import ./_util :as u)
(import ./ensure-tree-sitter :as ets)

(defn main
  [& argv]
  (when (not (ets/main))
    (eprintf "ensure-tree-sitter task failed")
    (break false))
  #
  (when (not (u/ts-command ["dump-languages"]))
    (eprintf "tree-sitter dump-languages subcommand failed")
    (break false))
  #
  true)
