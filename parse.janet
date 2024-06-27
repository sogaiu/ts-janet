(import ./_conf :as c)
(import ./_util :as u)
(import ./gen-parser-c :as gpc)

(defn main
  [& argv]
  (when (not (gpc/main))
    (eprintf "gen-parser-c task failed")
    (break false))
  #
  (def subcommand-args (drop 1 argv))
  #
  (when (not (u/ts-command ["parse" ;subcommand-args]))
    (eprintf "tree-sitter parse failed for: %n" subcommand-args)
    (break false))
  #
  true)
