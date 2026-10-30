package cn.edu.xmu.zhanxu;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

@Repository
public class ExhibitionRepository {
    private final JdbcTemplate jdbc;
    public ExhibitionRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }
    public record Exhibition(long id, String title, String introduction, String statement,
        String venue, String cover, String status, boolean visible, LocalDateTime startsAt, LocalDateTime endsAt) {}
    public record Input(String title, String introduction, String statement, String venue,
        String cover, String status, Boolean visible, LocalDateTime startsAt, LocalDateTime endsAt) {}
    private static final String PUBLIC = " public_visible=TRUE AND status IN ('collecting','on_view','archived') ";
    private static final RowMapper<Exhibition> MAPPER = (r, i) -> new Exhibition(r.getLong("id"),
        r.getString("title"), r.getString("introduction"), r.getString("curatorial_statement"),
        r.getString("venue_label"), r.getString("cover_url"), r.getString("status"), r.getBoolean("public_visible"),
        r.getObject("starts_at", LocalDateTime.class), r.getObject("ends_at", LocalDateTime.class));

    public List<Exhibition> list(boolean admin, String q, String status) {
        if (q.length() > 160) throw bad("搜索词不能超过 160 字");
        if (!status.isEmpty() && !List.of("draft","collecting","preparing","on_view","archived","cancelled").contains(status))
            throw bad("展览状态无效");
        return jdbc.query("SELECT * FROM exhibitions WHERE " + (admin ? "1=1" : PUBLIC)
            + " AND LOCATE(?, title)>0 AND (?='' OR status=?) ORDER BY FIELD(status,'on_view','collecting','preparing','draft','archived','cancelled'), id DESC", MAPPER, q, status, status);
    }

    public Exhibition get(long id, boolean admin) {
        var rows = jdbc.query("SELECT * FROM exhibitions WHERE id=?" + (admin ? "" : " AND " + PUBLIC), MAPPER, id);
        if (rows.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "展览不存在或尚未公开");
        return rows.getFirst();
    }

    @Transactional
    public Exhibition create(Input in) {
        validate(in);
        String slug = UUID.randomUUID().toString();
        jdbc.update("""
            INSERT INTO exhibitions (title,slug,introduction,curatorial_statement,venue_label,cover_url,
              status,public_visible,starts_at,ends_at,created_by) VALUES (?,?,?,?,?,?,?,?,?,?,1)
            """, in.title().strip(), slug, in.introduction().strip(), in.statement(), in.venue().strip(),
            in.cover(), in.status(), in.visible(), in.startsAt(), in.endsAt());
        Long id = jdbc.queryForObject("SELECT id FROM exhibitions WHERE slug=?", Long.class, slug);
        return get(id, true);
    }

    @Transactional
    public Exhibition update(long id, Input in) {
        validate(in);
        get(id, true);
        jdbc.update("""
            UPDATE exhibitions SET title=?,introduction=?,curatorial_statement=?,venue_label=?,cover_url=?,
              status=?,public_visible=?,starts_at=?,ends_at=? WHERE id=?
            """, in.title().strip(), in.introduction().strip(), in.statement(), in.venue().strip(), in.cover(),
            in.status(), in.visible(), in.startsAt(), in.endsAt(), id);
        return get(id, true);
    }

    @Transactional
    public void delete(long id) {
        get(id, true);
        if (jdbc.update("DELETE FROM exhibitions WHERE id=? AND status='draft' AND public_visible=FALSE", id) != 1)
            throw new ResponseStatusException(HttpStatus.CONFLICT, "仅可删除未公开草稿；其他展览请下架保留档案");
    }

    private static void validate(Input in) {
        field(in.title(), 160, "标题"); field(in.introduction(), 1000, "简介"); field(in.venue(), 255, "地点");
        if (in.statement() != null && in.statement().length() > 5000) throw bad("策展序言不能超过 5000 字");
        if (in.status() == null || !List.of("draft","collecting","preparing","on_view","archived","cancelled").contains(in.status())) throw bad("展览状态无效");
        if (in.visible() == null) throw bad("必须指定是否公开");
        if (in.visible() && !List.of("collecting","on_view","archived").contains(in.status())) throw bad("仅征集中、展出中、已归档状态可公开");
        if (in.startsAt() == null || in.endsAt() == null || !in.endsAt().isAfter(in.startsAt())) throw bad("结束时间必须晚于开始时间");
        if (!List.of("/assets/厦园晨雾.png","/assets/凤凰花季.png","/assets/瓦影.png","/assets/向海.png").contains(in.cover() == null ? "" : in.cover())) throw bad("请选择素材库中的封面");
    }
    private static void field(String value, int max, String label) {
        if (value == null || value.isBlank() || value.length() > max) throw bad(label + "必填，且不超过 " + max + " 字");
    }
    private static ResponseStatusException bad(String message) { return new ResponseStatusException(HttpStatus.BAD_REQUEST, message); }
}
