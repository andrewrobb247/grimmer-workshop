# Publication status

0.1.30 specialist recipe display fix published to testing on 19 November 2026. Payload/source commit 1cc5b7303d889346c437df289311f21c60ceb21e; all 23 hosted payload/identity/archive/README files matched staging byte for byte before enabling channel 477817ada5c40e53b93e9b9840753dd3d583cb6e.

Unchanged original 0.1.10 updater reads schema 1, offers 0.1.30 and accepts all 20 files under Windows PowerShell 5.1.26100.9818. No enabled runtime payload was changed after verification.

Fix removes only redundant visible Workshop Gunsmith/Cooking Stove alternatives when the corresponding source recipe is already visible. At a specialist station it prefers that station's craftable variant, including all-recipes view. It does not delete item definitions, actual recipes, inventory, queues, saves or author pack files. Existing 635 routes and 54 optional Arsenal routes retained.

Production build, prior regressions, 17 display scenario checks and native recipe-field/list-builder/station-context checks pass. Live list check remains pending. Startup log confirms DSD_Arsenal 1.2.1 and Workshop 0.1.29 loaded and registered all 53 weapons plus Energy Cells; the pack installation is now complete. User should save/close game, install 0.1.30 through testing updater, then relaunch. No world reset.