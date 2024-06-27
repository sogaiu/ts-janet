(import ./_util :as u)
(import ./clean-src :as cs)
(import ./clean-dot-ts :as cdt)

(defn main
  [& argv]
  (when (not (u/do-deps cs/main cdt/main))
    (break false))
  #
  true)
