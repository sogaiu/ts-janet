(import ./_conf :as c)
(import ./_util :as u)

(defn main
  [& argv]
  (def shared-lib-path 
    (string c/ts-lib-dir "/" "janet_simple.so"))
  (when (os/stat shared-lib-path)
    (os/rm shared-lib-path))
  #
  true)
