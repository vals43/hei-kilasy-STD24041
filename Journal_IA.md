# Journal IA — Kilasy C1 : Pénalité de retard

Outil utilisé : opencode (modèle big-pickle), dans le terminal, sur le fork
`vals43/hei-kilasy-STD24041`.

## Changement : pénalisation des soumissions rendues en retard

### Échange 1 — analyse du code existant
Demande : « Analyse le code pour localiser les calculs de note avant le plan C1. »
Proposition : le calcul est dupliqué dans `SubmissionController.get` (l.102),
`SubmissionController.grade` (l.134 et email l.149), `GradeReport` (l.66) et
`CsvExport` (l.35-38). Le CSV tronque avec `Math.floor` alors que les autres
arrondissent au dixième.
Décision : gardé.
Pourquoi : cela explique l'écart 13,7 / 13,8 observé sur Emma et montre où
appliquer la règle pour que les trois vues restent cohérentes.
Vérification : lecture des fichiers et appel à `GET /exports/grades.csv`. OK.

### Échange 2 — règle métier et deux lectures possibles
Demande : « Comment appliquer −10 % par jour entamé, plafonné à −50 %, sans
réorganiser le code ? »
Proposition : ajouter une méthode statique `penalizedGrade` dans `GradeReport.java`
(fichier existant), appelée depuis `SubmissionController` et `CsvExport`. Jours
de retard = différence entre la date de soumission et l'échéance ; note plancher
à 0 ; arrondi `HALF_UP` à 1 décimale partout.
Divergence d'interprétation : « jour entamé » pouvait signifier soit un décompte
en heures écoulées, soit une différence de dates. J'ai retenu la différence de
dates, car l'exemple du client (échéance 10/11, soumission 11/11 à 02:00 →
1 jour entamé) correspond à cette lecture. Autre arbitrage : appliquer la
pénalité après la conversion sur 20, puisque les exemples sont donnés sur la
note /20.
Correction apportée : le CSV utilisait `Math.floor` (13,7 pour Emma) alors que
`GradeReport` arrondissait à 13,8. J'ai refusé de conserver ce troncage et imposé
le même arrondi `HALF_UP` à une décimale dans les trois vues.
Décision : gardé, avec plafond 50 % et plancher 0.
Pourquoi : la consigne interdit la réorganisation et l'ajout d'une nouvelle
classe de domaine, mais la méthode partagée évite quatre copies divergentes.
Vérification : après redémarrage, `GET /submissions/1` → 16, `/2` → 14,4,
`/3` → 11,2, `/4` → 8 (plafond), `/5` → 15 ; relevé de Bob → 14,4 et moyenne
14,40 ; export CSV → `16,0`, `14,4`, `11,2`, `8,0`, `13,8` ; `PUT /submissions/7/grade`
(8/10, 1 jour de retard) → 14,4 dans la réponse, le relevé et le CSV, avec un
email Mailpit indiquant `14.4/20`. OK.

### Échange 3 — fork et validation du push
Demande : fournir le fork sur lequel travailler et vérifier que le push fonctionne.
Proposition initiale : créer un fork puis rename l'ancien `origin` en `upstream`.
Correction : l'étudiant a fourni directement l'URL
`https://github.com/vals43/hei-kilasy-STD24041`, déjà créée et basée sur le même
commit `0d10872`.
Décision : gardé.
Pourquoi : évite de recréer un fork inutile et vérifie les droits d'écriture
avant de commencer C1.
Vérification : commit vide `7f2519e` (« test: vérification du fork ») visible sur
GitHub. OK.


## Bilan — ce que j'ai gardé, corrigé ou refusé
- **Gardé** : méthode statique `penalizedGrade` dans `GradeReport.java` (aucune
  nouvelle classe, consigne « pas de réorganisation » respectée), différence de
  dates pour les jours entamés, plafond 50 %, plancher 0, arrondi `HALF_UP` à
  une décimale, champs `rawPoints` et `late` inchangés, commits distincts.
- **Refusé** : création d'une classe de domaine dédiée (interdite par la
  consigne), conservation du `Math.floor` du CSV (incohérent avec la correction
  et le relevé), calcul de la pénalité en heures écoulées (contraire aux exemples
  du client), inclusion de `compose.yaml` dans le commit (port local 5434).
- Fichiers modifiés : `GradeReport.java`, `SubmissionController.java`,
  `CsvExport.java`, `Journal_IA.md`.
- Vérifications effectuées : soumissions 1 → 16, 2 → 14,4, 3 → 11,2, 4 → 8 ;
  relevé de Bob et export CSV cohérents (14,4) ; notation de la soumission 7 →
  14,4 dans la réponse, le relevé, le CSV et l'email Mailpit.
