package cn.edu.xmu.zhanxu;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/admin")
public class AdminSessionController {
    private final AdminAccess access;
    public AdminSessionController(AdminAccess access) { this.access = access; }
    public record Login(String username, String password) {}

    @PostMapping("/login")
    public Map<String, String> login(@RequestBody Login credentials, HttpServletRequest request) {
        if (!access.matches(credentials.username(), credentials.password())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "账号或密码不正确");
        }
        if (request.getSession(false) != null) request.getSession(false).invalidate();
        request.getSession(true).setAttribute("admin", credentials.username());
        return Map.of("username", credentials.username());
    }

    @GetMapping("/session")
    public Map<String, Object> session(HttpServletRequest request) {
        return Map.of("username", request.getSession(false).getAttribute("admin"));
    }

    @PostMapping("/logout")
    public Map<String, String> logout(HttpServletRequest request) {
        request.getSession(false).invalidate();
        return Map.of("message", "已退出登录");
    }
}
