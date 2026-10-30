package cn.edu.xmu.zhanxu;

import java.util.List;

public record HomeResponse(List<Exhibition> exhibitions, List<Artwork> works) {
    public record Exhibition(long id, String title, String subtitle, String state,
                             String status, String image, String alt, String tone) {}
    public record Artwork(long id, String title, String author, String medium, String image) {}
}
