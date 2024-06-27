(import ./_util :as u)

# XXX: check versions?
(defn main
  [& argv]
  (when (not (u/bin-exists? "cargo"))
    (eprintf "cargo not found")
    (break false))
  #
  (when (not (u/bin-exists? "rustc"))
    (eprintf "rustc not found")
    (break false))
  #
  true)

