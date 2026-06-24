package com.qingteng.common.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class FileService {

    @Value("${app.upload.dir:${user.home}/qingteng-uploads}")
    private String uploadDir;

    @Value("${app.upload.url-prefix:/uploads}")
    private String urlPrefix;

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(Paths.get(uploadDir));
        } catch (IOException e) {
            throw new RuntimeException("无法创建上传目录: " + uploadDir, e);
        }
    }

    /**
     * 上传文件到本地磁盘。后续对接 OSS 时只需改此方法。
     */
    public String upload(MultipartFile file) {
        if (file.isEmpty()) throw new RuntimeException("文件为空");

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;

        try {
            Path target = Paths.get(uploadDir, filename);
            file.transferTo(target.toFile());
            return urlPrefix + "/" + filename;
        } catch (IOException e) {
            throw new RuntimeException("文件保存失败", e);
        }
    }
}