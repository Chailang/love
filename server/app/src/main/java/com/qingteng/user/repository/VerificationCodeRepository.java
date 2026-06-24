package com.qingteng.user.repository;

import com.qingteng.user.entity.VerificationCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {
    Optional<VerificationCode> findTopByPhoneAndTypeAndUsedFalseOrderByCreatedAtDesc(String phone, VerificationCode.CodeType type);

    @Modifying
    @Transactional
    @Query("UPDATE VerificationCode v SET v.used = true WHERE v.phone = :phone AND v.type = :type AND v.used = false")
    void markUsed(String phone, VerificationCode.CodeType type);
}