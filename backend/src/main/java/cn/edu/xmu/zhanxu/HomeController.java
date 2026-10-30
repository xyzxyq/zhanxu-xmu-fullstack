package cn.edu.xmu.zhanxu;

import java.util.Map;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {
    private final HomeRepository repository;

    public HomeController(HomeRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/api/home")
    public HomeResponse home() {
        return repository.load();
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<Map<String, String>> databaseUnavailable(DataAccessException exception) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of("message", "展览数据暂时无法加载，请稍后重试。"));
    }
}
