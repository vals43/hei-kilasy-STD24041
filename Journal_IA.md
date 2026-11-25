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

### Échange 2 — règle métier et architecture
Demande : « Comment appliquer −10 % par jour entamé, plafonné à −50 %, sans
réorganiser le code ? »
Proposition : ajouter une méthode statique `penalizedGrade` dans `GradeReport.java`
(fichier existant), appelée depuis `SubmissionController` et `CsvExport`. Jours
de retard = différence entre la date de soumission et l'échéance ; note plancher
à 0 ; arrondi `HALF_UP` à 1 décimale partout.
Décision : gardé, avec une contrainte supplémentaire.
Pourquoi : la consigne interdit la réorganisation et l'ajout d'une nouvelle
classe de domaine, mais la méthode partagée évite quatre copies divergentes.
Vérification : à compléter après exécution.

### Échange 3 — fork et validation du push
Demande : « Renommer le remote actuel et faire un commit de test. »
Proposition : `origin` = fork `vals43/hei-kilasy-STD24041`, `upstream` =
`hei-ryan/hei-kilasy`, commit vide `test: vérification du fork`, puis push.
Décision : gardé.
Pourquoi : permet de vérifier les droits d'écriture sur le fork avant C1.
Vérification : commit `7f2519e` visible sur GitHub. OK.

### Échange 4 — dépôt final
Demande : « Préparer le journal pour le formulaire Kilasy et faire un commit
distinct par modification. »
Proposition : créer `Journal_IA.md` (nom exact attendu par le formulaire),
faire un commit par fichier modifié, garder le commit final nommé exactement
`C1`, exclure `compose.yaml` (port 5434, adaptation locale à cette machine) et
joindre le même fichier au formulaire.
Décision : gardé.
Pourquoi : le journal est un livrable séparé, mais doit aussi rester dans le
dépôt pour tracer l'arbitrage ; les commits séparés facilitent la relecture.

## Bilan
- Fichiers modifiés : `GradeReport.java`, `SubmissionController.java`,
  `CsvExport.java`, `Journal_IA.md`.
- Fichier non commité : `compose.yaml` (port 5434, spécifique à la machine).
- Vérifications prévues : soumissions 1 → 16, 2 → 14,4, 3 → 11,2, 4 → 8 ;
  relevé de Bob et export CSV cohérents ; email après notation de la soumission 7.
