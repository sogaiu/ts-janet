(import ./_conf :as c)
(import ./_util :as u)

(defn main
  [& argv]
  (when (not (os/stat c/grammar-path))
    (def dir (os/cwd))
    (defer (os/cd dir)
      (when (not (u/run ["git" "clone" c/grammar-url]))
        (eprintf "cloning of grammar failed")
        (break false))
      #
      (os/cd c/grammar-path)
      (when (not (u/run ["git" "checkout" c/grammar-ref]))
        (eprintf "checkout failed for ref: %s" c/grammar-ref)
        (break false))))
  #
  true)

