package com.dnastack.dictator.data;

import java.time.LocalDate;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CensoredArticle extends Article {

    private LocalDate checkedAt;
    private String checkResult;

    public CensoredArticle(String title, String content, LocalDate datePosted, LocalDate checkedAt, String checkResult) {
        super(title, content, datePosted);
        this.checkedAt = checkedAt;
        this.checkResult = checkResult;
    }
}
