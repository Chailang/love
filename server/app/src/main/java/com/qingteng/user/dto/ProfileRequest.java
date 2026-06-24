package com.qingteng.user.dto;

import lombok.Data;

@Data
public class ProfileRequest {
    private String nickname;
    private String avatar;
    private String gender;
    private String birthDate;
    private String city;
    private String occupation;
    private Integer height;
    private String salaryRange;
    private String bio;
}