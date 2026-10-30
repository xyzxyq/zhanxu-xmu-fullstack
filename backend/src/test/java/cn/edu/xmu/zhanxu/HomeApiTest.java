package cn.edu.xmu.zhanxu;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class HomeApiTest {
    @Autowired TestRestTemplate http;

    @Test
    void returnsPublishedDatabaseContentAndExcludesPrivateFixtures() {
        var response = http.getForEntity("/api/home", HomeResponse.class);
        assertThat(response.getStatusCode().value()).isEqualTo(200);
        var home = response.getBody();
        assertThat(home).isNotNull();
        assertThat(home.exhibitions()).hasSize(3)
                .extracting(HomeResponse.Exhibition::id).containsExactly(1L, 2L, 3L);
        assertThat(home.works()).hasSize(4)
                .extracting(HomeResponse.Artwork::id).containsExactly(1L, 2L, 3L, 4L);
        assertThat(home.exhibitions().getFirst().status()).isEqualTo("正在展出 · 10.20 — 11.06");
        assertThat(home.works().getFirst().title()).isEqualTo("窗的秩序");
        assertThat(home.works().getFirst().image()).startsWith("/assets/");
    }
}
