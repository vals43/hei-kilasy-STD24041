# Journal IA — Kilasy C1/C2 : Pénalité de retard et notification SMS

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

## C2 — Notification par SMS

### Échange 1 — besoin et contrainte d'architecture
Demande : « L'étudiant doit aussi recevoir un SMS simulé dans les logs ; si
l'envoi échoue, la note reste publiée ; changer de fournisseur plus tard ne doit
pas modifier la notation. »
Proposition : introduire une interface `SmsSender` et une implémentation
`LogSmsSender` annotée `@Component`. `SubmissionController` ne connaît que
l'interface, comme il connaît déjà `JavaMailSender`.
Décision : gardé.
Pourquoi : la mise à jour de la note est faite avant les notifications. Un
autre fournisseur sera un autre bean, sans toucher au code de la notation.
Vérification : compilation avec JDK 21 OK.

### Échange 2 — tolérance aux pannes
Demande : « Simulez une panne en levant une exception et vérifiez ce que devient
la note. »
Proposition : `@Value("${sms.simulate-failure:false}")` dans `LogSmsSender`,
exception levée quand la propriété est vraie ; capture de l'exception dans
`SubmissionController`, log `[SMS][ERREUR]` et poursuite normale.
Divergence : fallait-il laisser l'exception remonter ou l'isoler ? J'ai retenu
l'isolement, car le critère demande explicitement que la note reste publiée ;
l'email est envoyé avant le SMS et reste inchangé.
Décision : gardé.
Vérification : avec `--sms.simulate-failure=true`, `PUT /submissions/12/grade`
(30/40) → réponse `grade: 15.0`, log `[SMS][ERREUR] envoi impossible pour
+261 34 00 000 06`, email reçu par Felix, `GET /submissions/12` → 15.0 et
export CSV → `15,0`. OK.

### Échange 3 — format du message
Demande : « Un message dans les logs suffit. »
Proposition : `[SMS] <téléphone> : Votre note pour « <exercice> » est disponible :
<note>/20.`
Correction : `BigDecimal` affiche `14.4`, mais l'exemple du client attend
`14,4` ; j'ai utilisé `toPlainString().replace('.', ',')`.
Décision : gardé.
Vérification : en mode normal, `PUT /submissions/7/grade` (8/10) → log
`[SMS] +261 34 00 000 02 : Votre note pour « Pile et file » est disponible :
14,4/20.`, email reçu par Bob, réponse `grade: 14.4`. OK.

## Bilan C2 — ce que j'ai gardé, corrigé ou refusé
- Gardé : interface `SmsSender`, implémentation `LogSmsSender`, envoi après la
  publication de la note et après l'email, affichage de la note avec une virgule,
  et commits distincts.
- Corrigé : le séparateur décimal du SMS (`14.4` → `14,4`) pour coller à
  l'exemple du client.
- Refusé : un appel direct au logger dans `SubmissionController` (aurait lié la
  notation au fournisseur) et la propagation de l'exception SMS (aurait fait
  échouer la publication de la note).
- Fichiers ajoutés : `SmsSender.java`, `LogSmsSender.java`.
- Fichiers modifiés : `SubmissionController.java`, `Journal_IA.md`.
- Fichier non commité : `compose.yaml` (port 5434, spécifique à la machine).
- Application relancée en mode normal après le test de panne.
