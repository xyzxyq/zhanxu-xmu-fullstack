package cn.edu.xmu.zhanxu;

import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.RANDOM_PORT)
class ExhibitionApiTest {
    @LocalServerPort int port;
    @Value("${app.admin.username}") String username;
    @Value("${app.admin.password}") String password;
    @Autowired ObjectMapper json;
    @Autowired JdbcTemplate jdbc;
    final HttpClient http = HttpClient.newBuilder().cookieHandler(new CookieManager(null, CookiePolicy.ACCEPT_ALL)).build();
    HttpResponse<String> call(String method, String path, Object body, boolean header) throws Exception {
        var builder = HttpRequest.newBuilder(URI.create("http://127.0.0.1:"+port+path)).header("Content-Type","application/json");
        if (header) builder.header("X-Zhanxu-Request","1");
        return http.send(builder.method(method, body==null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(json.writeValueAsString(body))).build(), HttpResponse.BodyHandlers.ofString());
    }
    @Test void authenticatedCrudPublicationValidationAndSessionLifecycle() throws Exception {
        assertThat(call("GET","/api/admin/exhibitions",null,true).statusCode()).isEqualTo(401);
        assertThat(call("GET","/api/admin;ignored/exhibitions",null,true).statusCode()).isNotEqualTo(200);
        assertThat(call("POST","/api/admin/login",Map.of("username",username,"password","incorrect"),true).statusCode()).isEqualTo(401);
        assertThat(call("POST","/api/admin/login",Map.of("username",username,"password",password),false).statusCode()).isEqualTo(403);
        var login = call("POST","/api/admin/login",Map.of("username",username,"password",password),true);
        assertThat(login.statusCode()).isEqualTo(200);
        assertThat(login.headers().firstValue("set-cookie").orElse("")).contains("HttpOnly", "SameSite=Strict");
        assertThat(call("GET","/api/exhibitions/4",null,true).statusCode()).isEqualTo(404);
        assertThat(call("GET","/api/exhibitions/5",null,true).statusCode()).isEqualTo(404);
        Map<String,Object> form=new HashMap<>(Map.of("title","API集成测试展览","introduction","用于校验完整发布与下架链路",
            "statement","测试结束后仅删除本测试记录","venue","测试展厅","cover","/assets/厦园晨雾.png",
            "status","draft","visible",false,"startsAt","2026-11-01T09:00:00","endsAt","2026-11-02T18:00:00"));
        form.put("endsAt","2026-10-01T09:00:00");
        assertThat(call("POST","/api/admin/exhibitions",form,true).statusCode()).isEqualTo(400);
        form.put("endsAt","2026-11-02T18:00:00"); form.put("visible",true);
        assertThat(call("POST","/api/admin/exhibitions",form,true).statusCode()).isEqualTo(400);
        form.put("visible",false); form.put("title"," ");
        assertThat(call("POST","/api/admin/exhibitions",form,true).statusCode()).isEqualTo(400);
        form.put("title","API集成测试展览"); form.put("cover","javascript:alert(1)");
        assertThat(call("POST","/api/admin/exhibitions",form,true).statusCode()).isEqualTo(400);
        form.put("cover","/assets/厦园晨雾.png");
        var created=call("POST","/api/admin/exhibitions",form,true);
        assertThat(created.statusCode()).isEqualTo(201);
        long id=json.readTree(created.body()).get("id").asLong();
        try {
            assertThat(call("GET","/api/exhibitions/"+id,null,true).statusCode()).isEqualTo(404);
            form.put("status","on_view"); form.put("visible",true);
            assertThat(call("PUT","/api/admin/exhibitions/"+id,form,false).statusCode()).isEqualTo(403);
            assertThat(call("PUT","/api/admin/exhibitions/"+id,form,true).statusCode()).isEqualTo(200);
            assertThat(call("GET","/api/exhibitions/"+id,null,true).statusCode()).isEqualTo(200);
            assertThat(jdbc.queryForObject("SELECT public_visible FROM exhibitions WHERE id=?",Boolean.class,id)).isTrue();
            assertThat(call("GET","/api/exhibitions?q=API&status=on_view",null,true).body()).contains("API集成测试展览");
            assertThat(call("GET","/api/exhibitions?q=API&status=archived",null,true).body()).isEqualTo("[]");
            assertThat(call("DELETE","/api/admin/exhibitions/"+id,null,true).statusCode()).isEqualTo(409);
            form.put("visible",false);
            assertThat(call("PUT","/api/admin/exhibitions/"+id,form,true).statusCode()).isEqualTo(200);
            assertThat(call("GET","/api/exhibitions/"+id,null,true).statusCode()).isEqualTo(404);
            form.put("status","draft");
            assertThat(call("PUT","/api/admin/exhibitions/"+id,form,true).statusCode()).isEqualTo(200);
            assertThat(call("DELETE","/api/admin/exhibitions/"+id,null,true).statusCode()).isEqualTo(204);
            assertThat(call("PUT","/api/admin/exhibitions/"+id,form,true).statusCode()).isEqualTo(404);
            assertThat(call("POST","/api/admin/logout",null,true).statusCode()).isEqualTo(200);
            assertThat(call("GET","/api/admin/session",null,true).statusCode()).isEqualTo(401);
        } finally { jdbc.update("DELETE FROM exhibitions WHERE id=?",id); }
    }
}
