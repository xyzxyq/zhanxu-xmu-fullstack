package cn.edu.xmu.zhanxu;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AdminAccess extends OncePerRequestFilter {
    private final String username;
    private final String password;
    private final ObjectMapper json;

    public AdminAccess(@Value("${app.admin.username}") String username,
                       @Value("${app.admin.password}") String password, ObjectMapper json) {
        if (password.length() < 12) throw new IllegalArgumentException("ADMIN_PASSWORD 至少 12 位");
        this.username = username;
        this.password = password;
        this.json = json;
    }

    public boolean matches(String user, String secret) {
        return username.equals(user) && secret != null && MessageDigest.isEqual(
            password.getBytes(StandardCharsets.UTF_8), secret.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "no-store");
        if (request.getServletPath().startsWith("/api/admin")) {
            // 自定义请求头触发跨域预检；不开放 CORS，阻止跨站表单写入。
            if (!request.getMethod().equals("GET") && !"1".equals(request.getHeader("X-Zhanxu-Request"))) {
                error(response, 403, "缺少安全请求头");
                return;
            }
            if (!request.getServletPath().equals("/api/admin/login") &&
                (request.getSession(false) == null || request.getSession(false).getAttribute("admin") == null)) {
                error(response, 401, "请先登录管理后台");
                return;
            }
        }
        chain.doFilter(request, response);
    }

    private void error(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        json.writeValue(response.getWriter(), Map.of("message", message));
    }
}
