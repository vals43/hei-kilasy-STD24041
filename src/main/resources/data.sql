-- Teachers (ids 1 and 2)
INSERT INTO teacher (id, reference, full_name, email) VALUES (1, 'TCR001', 'Marie', 'marie@kilasy.test') ON CONFLICT (id) DO NOTHING;
INSERT INTO teacher (id, reference, full_name, email) VALUES (2, 'TCR002', 'Paul', 'paul@kilasy.test') ON CONFLICT (id) DO NOTHING;

-- Students (ids 1 to 6)
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (1, 'STD24001', 'Alice', 'alice@etu.kilasy.test', '+261 34 00 000 01', 'L3-A') ON CONFLICT (id) DO NOTHING;
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (2, 'STD24002', 'Bob', 'bob@etu.kilasy.test', '+261 34 00 000 02', 'L3-A') ON CONFLICT (id) DO NOTHING;
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (3, 'STD24003', 'Clara', 'clara@etu.kilasy.test', '+261 34 00 000 03', 'L3-A') ON CONFLICT (id) DO NOTHING;
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (4, 'STD24004', 'David', 'david@etu.kilasy.test', '+261 34 00 000 04', 'L3-B') ON CONFLICT (id) DO NOTHING;
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (5, 'STD24005', 'Emma', 'emma@etu.kilasy.test', '+261 34 00 000 05', 'L3-B') ON CONFLICT (id) DO NOTHING;
INSERT INTO student (id, reference, full_name, email, phone, cohort) VALUES (6, 'STD24006', 'Felix', 'felix@etu.kilasy.test', '+261 34 00 000 06', 'L3-B') ON CONFLICT (id) DO NOTHING;

-- Exercises (ids 1 to 5)
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline) VALUES (1, 1, 'Tri à bulles', 'Implémenter le tri à bulles sur un tableau d''entiers, puis mesurer le nombre d''échanges.', 20, '2026-11-10') ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline) VALUES (2, 1, 'Pile et file', 'Implémenter une pile et une file à partir d''une liste chaînée.', 10, '2026-11-14') ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline) VALUES (3, 2, 'Requêtes SQL avec jointures', 'Écrire les douze requêtes demandées sur la base des bibliothèques municipales.', 40, '2026-11-17') ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline) VALUES (4, 2, 'API REST de réservation', 'Exposer une API REST de réservation de terrains de sport.', 20, '2027-01-15') ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline) VALUES (5, 1, 'FizzBuzz piloté par les tests', 'Écrire FizzBuzz en commençant par les tests.', 20, '2027-02-01') ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline, duration_minutes) VALUES (6, 1, 'Tri à bulles minuté', 'Trier le tableau avant la fin du chrono.', 20, NULL, 1) ON CONFLICT (id) DO NOTHING;
INSERT INTO exercise (id, teacher_id, title, description, max_points, deadline, duration_minutes) VALUES (7, 1, 'Jointures minutées', 'Écrire les jointures avant la fin du chrono ; échéance dépassée depuis le 10/11.', 20, '2026-11-10', 1) ON CONFLICT (id) DO NOTHING;

-- Submissions: Bubble sort (deadline 10/11, max 20)
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (1, 1, 1, 'public class BubbleSort { /* ... */ }', '2026-11-09 18:00:00', 16, 'Correct, pense à arrêter la boucle quand le tableau est trié.', '2026-11-20 09:00:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (2, 1, 2, 'public class BubbleSort { /* ... */ }', '2026-11-11 02:00:00', 16, 'Bon travail.', '2026-11-20 09:05:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, repo_url, submitted_at, raw_points, feedback, graded_at) VALUES (3, 1, 3, 'https://github.com/clara/tri-bulles', '2026-11-13 10:00:00', 16, 'Bon travail, mais en retard.', '2026-11-20 09:10:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (4, 1, 4, 'public class BubbleSort { /* ... */ }', '2026-11-18 15:00:00', 16, 'Rendu très tardif.', '2026-11-20 09:15:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at) VALUES (5, 1, 6, 'public class BubbleSort { /* ... */ }', '2026-11-10 23:30:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;

-- Submissions: Stack and queue (deadline 14/11, max 10)
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (6, 2, 1, 'public class Stack<T> { /* ... */ }', '2026-11-13 20:15:00', 8.5, 'Très propre.', '2026-11-21 14:00:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at) VALUES (7, 2, 2, 'public class Stack<T> { /* ... */ }', '2026-11-15 08:40:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, repo_url, submitted_at, raw_points, feedback, graded_at) VALUES (8, 2, 3, 'https://github.com/clara/pile-file', '2026-11-14 11:00:00', 7, 'La file ne gère pas le cas vide.', '2026-11-21 14:10:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;

-- Submissions: SQL queries with joins (deadline 17/11, max 40)
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (9, 3, 1, 'SELECT ...', '2026-11-16 22:00:00', 33, 'Bien, sauf la requête 11.', '2026-11-22 10:00:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (10, 3, 4, 'SELECT ...', '2026-11-19 09:00:00', 30, 'Correct.', '2026-11-22 10:05:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at, raw_points, feedback, graded_at) VALUES (11, 3, 5, 'SELECT ...', '2026-11-17 18:30:00', 27.5, 'Attention aux jointures externes.', '2026-11-22 10:10:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;
INSERT INTO submission (id, exercise_id, student_id, content, submitted_at) VALUES (12, 3, 6, 'SELECT ...', '2026-11-17 23:50:00') ON CONFLICT (exercise_id, student_id) DO NOTHING;

-- Realign the sequences after inserting explicit ids
SELECT setval(pg_get_serial_sequence('teacher', 'id'), (SELECT MAX(id) FROM teacher));
SELECT setval(pg_get_serial_sequence('student', 'id'), (SELECT MAX(id) FROM student));
SELECT setval(pg_get_serial_sequence('exercise', 'id'), (SELECT MAX(id) FROM exercise));
SELECT setval(pg_get_serial_sequence('submission', 'id'), (SELECT MAX(id) FROM submission));
