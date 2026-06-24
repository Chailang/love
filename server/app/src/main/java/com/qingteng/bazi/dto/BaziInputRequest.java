package com.qingteng.bazi.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class BaziInputRequest {
    @NotNull @Min(1900) @Max(2100)
    private Integer birthYear;

    @NotNull @Min(1) @Max(12)
    private Integer birthMonth;

    @NotNull @Min(1) @Max(31)
    private Integer birthDay;

    @NotNull @Min(0) @Max(23)
    private Integer hour;
}