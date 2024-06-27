(import ./_conf :as c)
(import ./_util :as u)
(import ./clean :as c)
(import ./ensure-grammar :as eg)
(import ./ensure-tree-sitter :as ets)

(defn main
  [& argv]
  (when (not (ets/main))
    (eprintf "ensure-tree-sitter task failed")
    (break false))
  #
  (when (not (c/main))
    (eprintf "clean task failed")
    (break false))
  #
  (when (not (eg/main))
    (eprintf "ensure-grammar task failed")
    (break false))
  #
  (def dir (os/cwd))
  (defer (os/cd dir)
    (os/cd c/grammar-path)
    (when (not (u/ts-command ["generate"
                              "--abi" c/ts-abi
                              "--no-bindings"]))
      (eprintf "tree-sitter generate subcommand failed")
      (break false)))
  #
  true)
