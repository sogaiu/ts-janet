(import ./clean-src :as cs)
(import ./clean-dot-ts :as cdt)

(defn main
  [& argv]
  (when (not (cs/main))
    (eprintf "clean-src task failed")
    (break false))
  #
  (when (not (cdt/main))
    (eprintf "clean-dot-ts task failed")
    (break false))
  #
  true)
