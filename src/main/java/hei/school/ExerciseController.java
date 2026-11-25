package hei.school;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ExerciseController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/exercises")
    public List<Exercise> list() {
        return jdbcTemplate.query("SELECT * FROM exercise ORDER BY deadline", (rs, i) -> {
            Exercise e = new Exercise();
            e.setId(rs.getLong("id"));
            e.setTeacherId(rs.getLong("teacher_id"));
            e.setTitle(rs.getString("title"));
            e.setDescription(rs.getString("description"));
            e.setMaxPoints(rs.getDouble("max_points"));
            Date deadline = rs.getDate("deadline");
            e.setDeadline(deadline == null ? null : deadline.toLocalDate());
            e.setDurationMinutes((Integer) rs.getObject("duration_minutes"));
            return e;
        });
    }

    @GetMapping("/exercises/{id}")
    public ResponseEntity<?> get(@PathVariable long id) {
        List<Exercise> found = jdbcTemplate.query("SELECT * FROM exercise WHERE id = ?", (rs, i) -> {
            Exercise e = new Exercise();
            e.setId(rs.getLong("id"));
            e.setTeacherId(rs.getLong("teacher_id"));
            e.setTitle(rs.getString("title"));
            e.setDescription(rs.getString("description"));
            e.setMaxPoints(rs.getDouble("max_points"));
            Date deadline = rs.getDate("deadline");
            e.setDeadline(deadline == null ? null : deadline.toLocalDate());
            e.setDurationMinutes((Integer) rs.getObject("duration_minutes"));
            return e;
        }, id);
        if (found.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Exercice introuvable"));
        }
        return ResponseEntity.ok(found.get(0));
    }

    @PostMapping("/exercises")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        if (title == null || title.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Le titre est obligatoire"));
        }
        LocalDate deadline = null;
        if (body.get("deadline") != null) {
            try {
                deadline = LocalDate.parse((String) body.get("deadline"));
            } catch (Exception ex) {
                return ResponseEntity.badRequest().body(Map.of("error", "L'échéance doit être au format AAAA-MM-JJ"));
            }
            if (deadline.isBefore(LocalDate.now())) {
                return ResponseEntity.badRequest().body(Map.of("error", "L'échéance doit être dans le futur"));
            }
        }
        Integer durationMinutes = null;
        if (body.get("durationMinutes") != null) {
            try {
                durationMinutes = ((Number) body.get("durationMinutes")).intValue();
            } catch (Exception ex) {
                return ResponseEntity.badRequest().body(Map.of("error", "La durée doit être un entier en minutes"));
            }
            if (durationMinutes <= 0) {
                return ResponseEntity.badRequest().body(Map.of("error", "La durée doit être positive"));
            }
        }
        if (deadline == null && durationMinutes == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Une échéance ou une durée est obligatoire"));
        }
        double maxPoints = 20;
        if (body.get("maxPoints") != null) {
            maxPoints = ((Number) body.get("maxPoints")).doubleValue();
        }
        if (maxPoints <= 0) {
            return ResponseEntity.badRequest().body(Map.of("error", "Le barème doit être positif"));
        }
        // TODO: get the logged-in teacher once authentication exists
        long teacherId = 1;
        if (body.get("teacherId") != null) {
            teacherId = ((Number) body.get("teacherId")).longValue();
        }

        jdbcTemplate.update(
                "INSERT INTO exercise (teacher_id, title, description, max_points, deadline, duration_minutes) VALUES (?, ?, ?, ?, ?, ?)",
                teacherId, title, body.get("description"), maxPoints,
                deadline == null ? null : Date.valueOf(deadline), durationMinutes);
        Long id = jdbcTemplate.queryForObject("SELECT max(id) FROM exercise", Long.class);

        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("title", title);
        result.put("maxPoints", maxPoints);
        result.put("deadline", deadline);
        result.put("durationMinutes", durationMinutes);
        System.out.println("Nouvel exercice créé : " + title + " (id " + id + ")");
        return ResponseEntity.status(201).body(result);
    }
}
