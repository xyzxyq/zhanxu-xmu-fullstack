package cn.edu.xmu.zhanxu;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class HomeRepository {
    private final JdbcTemplate jdbc;
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("MM.dd");

    public HomeRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public HomeResponse load() {
        var exhibitions = jdbc.query("""
                SELECT e.id, e.title, e.introduction, e.status, e.cover_url,
                       e.starts_at, e.ends_at, c.deadline_at
                FROM exhibitions e
                LEFT JOIN calls_for_works c ON c.exhibition_id = e.id AND c.status = 'open'
                WHERE e.public_visible = TRUE AND e.status IN ('on_view', 'collecting', 'archived')
                ORDER BY FIELD(e.status, 'on_view', 'collecting', 'archived'), e.id
                LIMIT 3
                """, (row, index) -> new HomeResponse.Exhibition(
                row.getLong("id"), row.getString("title"), row.getString("introduction"),
                row.getString("status"), statusLabel(row), row.getString("cover_url"),
                row.getString("title"), switch (row.getString("status")) {
                    case "on_view" -> "blue";
                    case "collecting" -> "coral";
                    default -> "sand";
                }));

        var works = jdbc.query("""
                SELECT a.id, v.title, v.public_credit, v.medium, f.file_url
                FROM section_placements p
                JOIN exhibition_sections s ON s.id = p.section_id AND s.exhibition_id = p.exhibition_id
                JOIN exhibitions e ON e.id = p.exhibition_id
                JOIN submissions sub ON sub.id = p.submission_id AND sub.exhibition_id = p.exhibition_id
                JOIN artworks a ON a.id = sub.artwork_id
                JOIN submission_versions v ON v.submission_id = p.submission_id AND v.version_no = p.version_no
                JOIN submission_version_files f ON f.submission_id = v.submission_id
                    AND f.version_no = v.version_no AND f.is_primary = TRUE
                WHERE e.public_visible = TRUE AND e.status IN ('on_view', 'archived')
                    AND a.status = 'published' AND sub.status = 'selected'
                ORDER BY e.id, s.sort_order, p.sort_order, f.sort_order
                LIMIT 4
                """, (row, index) -> new HomeResponse.Artwork(
                row.getLong("id"), row.getString("title"), row.getString("public_credit"),
                row.getString("medium"), row.getString("file_url")));
        return new HomeResponse(exhibitions, works);
    }

    private static String statusLabel(ResultSet row) throws SQLException {
        return switch (row.getString("status")) {
            case "on_view" -> "正在展出 · " + date(row.getTimestamp("starts_at")) + " — " + date(row.getTimestamp("ends_at"));
            case "collecting" -> "征集中 · 截止 " + date(row.getTimestamp("deadline_at"));
            default -> "往期档案 · 线上持续开放";
        };
    }

    private static String date(Timestamp value) {
        return value == null ? "待公布" : DATE.format(value.toLocalDateTime());
    }
}
