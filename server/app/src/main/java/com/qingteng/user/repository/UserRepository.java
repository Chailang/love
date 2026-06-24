package com.qingteng.user.repository;

import com.qingteng.user.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByPhone(String phone);
    boolean existsByPhone(String phone);

    @Query("SELECT u FROM User u WHERE u.id NOT IN :ids ORDER BY u.profileCompleteness DESC")
    List<User> findByIdNotIn(Collection<Long> ids);

    @Query("SELECT u FROM User u WHERE u.gender = :gender AND u.id NOT IN :ids ORDER BY u.profileCompleteness DESC")
    List<User> findByGenderAndIdNotIn(User.Gender gender, Collection<Long> ids);

    /** 随机找一个异性用户（排除自己） */
    @Query("SELECT u FROM User u WHERE u.gender <> :gender AND u.id <> :userId AND u.status = 'ACTIVE' ORDER BY RAND()")
    List<User> findRandomUserExclude(Long userId, User.Gender gender, Pageable pageable);

    default Optional<User> findRandomUserExcluding(Long userId, User.Gender gender) {
        List<User> users = findRandomUserExclude(userId, gender, Pageable.ofSize(1));
        return users.isEmpty() ? Optional.empty() : Optional.of(users.get(0));
    }
}