(import ./_conf :as c)
(import ./_util :as u)

(defn main
  [& argv]
  (each so (os/dir c/ts-lib-dir)
    (def fuller-path (string c/ts-lib-dir "/" so))
    (when (os/stat fuller-path)
      (os/rm fuller-path)))
  #
  true)
