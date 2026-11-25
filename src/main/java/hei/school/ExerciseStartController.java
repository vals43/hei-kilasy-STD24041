package hei.school;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ExerciseStartController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostMapping("/exercises/{id}/start")
    public ResponseEntity<?> start(@PathVariable long id, @RequestBody Map<String, Object> body) {
        if (body.get("studentId") == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "studentId est obligatoire"));
        }
        long studentId = ((Number) body.get("studentId")).longValue();

        List<Map<String, Object>> exercises = jdbcTemplate.queryForList(
                "SELECT duration_minutes FROM exercise WHERE id = ?", id);
        if (exercises.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Exercice introuvable"));
        }
        Object duration = exercises.get(0).get("duration_minutes");
        if (duration == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Cet exercice n'est pas minuté"));
        }

        List<Map<String, Object>> students = jdbcTemplate.queryForList("SELECT id FROM student WHERE id = ?", studentId);
        if (students.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Étudiant introuvable"));
        }
        Integer already = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM exercise_start WHERE exercise_id = ? AND student_id = ?",
                Integer.class, id, studentId);
        if (already != null && already > 0) {
            return ResponseEntity.status(409).body(Map.of("error", "Exercice déjà démarré"));
        }

        LocalDateTime now = LocalDateTime.now();
        jdbcTemplate.update(
                "INSERT INTO exercise_start (exercise_id, student_id, started_at) VALUES (?, ?, ?)",
                id, studentId, Timestamp.valueOf(now));

        Map<String, Object> result = new HashMap<>();
        result.put("exerciseId", id);
        result.put("studentId", studentId);
        result.put("startedAt", now);
        result.put("endsAt", now.plusMinutes(((Number) duration).longValue()));
        return ResponseEntity.status(201).body(result);
    }
}
