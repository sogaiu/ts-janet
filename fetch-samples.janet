(import ./_conf :as c)
(import ./git-some-janets/git-some-janets :as gsj)

(defn main
  [& argv]
  (os/setenv "GSJ_REPOS_NAME" c/repos-name)
  (gsj/main ;argv))
