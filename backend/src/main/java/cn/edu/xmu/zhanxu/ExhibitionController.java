package cn.edu.xmu.zhanxu;

import java.util.List;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;

@RestController
public class ExhibitionController {
    private final ExhibitionRepository repository;
    public ExhibitionController(ExhibitionRepository repository) { this.repository = repository; }
    @GetMapping("/api/exhibitions")
    public List<ExhibitionRepository.Exhibition> list(@RequestParam(defaultValue="") String q, @RequestParam(defaultValue="") String status) {
        return repository.list(false, q, status);
    }
    @GetMapping("/api/exhibitions/{id}")
    public ExhibitionRepository.Exhibition detail(@PathVariable long id) { return repository.get(id, false); }
    @GetMapping("/api/admin/exhibitions")
    public List<ExhibitionRepository.Exhibition> adminList(@RequestParam(defaultValue="") String q, @RequestParam(defaultValue="") String status) {
        return repository.list(true, q, status);
    }
    @PostMapping("/api/admin/exhibitions")
    @ResponseStatus(HttpStatus.CREATED)
    public ExhibitionRepository.Exhibition create(@RequestBody ExhibitionRepository.Input input) { return repository.create(input); }
    @PutMapping("/api/admin/exhibitions/{id}")
    public ExhibitionRepository.Exhibition update(@PathVariable long id, @RequestBody ExhibitionRepository.Input input) { return repository.update(id, input); }
    @DeleteMapping("/api/admin/exhibitions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable long id) { repository.delete(id); }
}
