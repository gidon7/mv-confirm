# 맑은프레임워크 템플릿 프로젝트

JSP 기반 맑은프레임워크(malgn framework) 웹 애플리케이션 템플릿.

## 기술 스택
- 백엔드: JSP/Servlet, 맑은프레임워크 (malgn.jar)
- 프론트: Bootstrap 5, HTML 템플릿 엔진
- DB: MySQL (JNDI 연결)
- API: RESTful + JWT 인증
- 빌드: Ant (`ant compile`)

## 프로젝트 구조
```
src/dao/              DAO 클래스 (Java) → ant compile로 빌드
public_html/
  init.jsp            공통 초기화 (m, f, p, j, auth 자동 생성)
  {기능}/              JSP (로직만)
  html/layout/        레이아웃 HTML (layout_xxx.html)
  html/{기능}/         본문 HTML 템플릿
  api/init.jsp        API 초기화 (JWT, CORS)
  api/{기능}.jsp       REST API 엔드포인트
  WEB-INF/config.xml  프레임워크 설정
schema.sql            DB 스키마
```

## 작업 워크플로우
1. MCP `get_context(task, table_name)` 로 규칙/패턴/클래스 조회
2. MCP `get_pattern(type)` 으로 표준 패턴 참조하여 코딩
3. MCP `validate_code(code, file_type)` 로 규칙 위반 검증
4. DAO 수정 시 `ant compile` 로 컴파일

## MCP 도구 (malgn)
- `get_context` — 작업별 규칙+패턴+클래스 일괄 조회 (작업 시작 시 사용)
- `get_pattern` — 코드 패턴 템플릿 (jsp-list, jsp-insert, dao-basic 등)
- `get_class` — 클래스 메소드 상세 조회
- `get_rules` — 코딩 규칙 조회
- `validate_code` — 코드 규칙 위반 검증
- `get_doc` / `search_docs` — 프레임워크 문서 조회

## 주요 파일
- `schema.sql` — DB 테이블 스키마

## .claude/rules/ 가이드 문서
- `malgn.md` — 맑은프레임워크 핵심 규칙
- `guide.md` — 맑은프레임워크 AI 코딩 가이드 (상세)
- `onboarding.md` — Claude Code 온보딩 가이드
- `admin-pattern.md` — 관리자 페이지 HTML 패턴
- `admin2-guide.md` — admin2.css 리뉴얼 가이드
- `admin-modern-guide.md` — 모던 리뉴얼 가이드 (UI 구조 변경)
- `renewal-plan.md` — 관리자단 리뉴얼 기획서
- `layout-admin-guide.md` — 레이아웃 구조 분석 및 리뉴얼 가이드
