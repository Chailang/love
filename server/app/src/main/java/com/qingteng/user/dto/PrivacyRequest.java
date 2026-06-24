package com.qingteng.user.dto;

import lombok.Data;

@Data
public class PrivacyRequest {
    private Boolean readReceipt;
    private Boolean locationVisible;
    private Boolean onlineVisible;
    private Boolean allowStrangerChat;
    private Boolean onlineAlert;
}