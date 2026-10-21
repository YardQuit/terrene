;;;; init.lisp - Tuatara's settings, loaded after its defaults.
;;;;
;;;; This file comes from /etc/skel, so an account gets it when the account is
;;;; created. Tuatara writes its own init file, listing every setting commented
;;;; out, only when none exists yet. To see that list, move this file aside,
;;;; start Tuatara once, and copy the lines below into the file it writes.

;; The packages that live beside the editor rather than in it. Tuatara asks
;; before it first compiles and loads one, and offers its source to read.
(package-source "tuatara-packages" "https://github.com/Tuatara-Editor/tuatara-packages")

;; facematch: candidate photos ranked by how probable it is that they show the
;; person in the master photos. Its engine is the AppImage that the image
;; installs as /usr/bin/facematch. That is the name the package looks for on
;; PATH by default, so it needs no :config.
(load-package "facematch" :source "tuatara-packages")
