# 테이블 스키마 생성

$ARGUMENTS 형식: 테이블명과 설명 (예: tb_notice 공지사항)

## 절차

1. 사용자에게 필요한 컬럼 정보를 확인한다. 정보가 부족하면 질문한다.
2. `schema.sql`을 읽어 기존 테이블 구조와 컨벤션을 파악한다.
3. 기존 컨벤션에 맞춰 CREATE TABLE 문을 작성한다.

## 컨벤션 (schema.sql 기반)

- 테이블명: `tb_` 접두사
- PK: `id INT NOT NULL AUTO_INCREMENT`
- 날짜: `VARCHAR(14)` (yyyyMMddHHmmss 형식)
- 상태: `status INT DEFAULT 1` 또는 `status VARCHAR(20) DEFAULT 'pending'`
- 외래키: `{참조테이블}_id INT` + FOREIGN KEY 제약조건
- 인덱스: 검색/조회 빈도가 높은 컬럼에 추가
- ENGINE=InnoDB, CHARSET=utf8mb4

## 완료 후
1. 생성된 CREATE TABLE 문을 `schema.sql` 파일 끝에 추가한다.
2. 사용자에게 DDL을 보여주고 확인을 받는다.
3. 확인 후 `/project:crud` 실행을 제안한다.
