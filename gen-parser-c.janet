(import ./_conf :as c)
(import ./_util :as u)
(import ./clean :as c)
(import ./ensure-grammar :as eg)
(import ./ensure-tree-sitter :as ets)

(defn main
  [& argv]
  (when (not (u/do-deps ets/main c/main eg/main))
    (break false))
  #
  (def dir (os/cwd))
  (defer (os/cd dir)
    (os/cd c/grammar-path)
    (if (u/ts-command ["generate"
                       "--abi" c/ts-abi
                       "--no-bindings"])
      true
      (do
        (eprintf "tree-sitter generate subcommand failed")
        false))))

