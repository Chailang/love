package com.qingteng.bazi.repository;

import com.qingteng.bazi.entity.UserBazi;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserBaziRepository extends JpaRepository<UserBazi, Long> {
    Optional<UserBazi> findByUserId(Long userId);
}