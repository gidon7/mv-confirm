# CRUD 파일 생성

테이블명: $ARGUMENTS

## 작업 절차

1. `schema.sql`에서 해당 테이블의 컬럼 구조를 확인한다.
2. MCP `get_pattern("dao-custom")`으로 DAO 패턴을 조회한다.
3. MCP `get_pattern("jsp-list")`, `get_pattern("jsp-insert")`, `get_pattern("jsp-modify")`, `get_pattern("jsp-delete")`, `get_pattern("jsp-view")`로 JSP 패턴을 조회한다.
4. MCP `get_pattern("html-list")`, `get_pattern("html-form")`, `get_pattern("html-view")`로 HTML 패턴을 조회한다.

## 생성할 파일

테이블명에서 `tb_` 접두사를 제거하여 폴더명/파일명으로 사용한다. (예: tb_notice → notice)

### DAO (테이블 구조 기반)
- `src/dao/{ClassName}Dao.java`

### JSP (로직만, HTML 없음)
- `public_html/{name}/{name}_list.jsp` — 목록 (페이징+검색)
- `public_html/{name}/{name}_write.jsp` — 등록 (Postback)
- `public_html/{name}/{name}_modify.jsp` — 수정 (Postback)
- `public_html/{name}/{name}_delete.jsp` — 삭제 (POST only)
- `public_html/{name}/{name}_view.jsp` — 상세 조회

### HTML 템플릿 (테이블 컬럼 기반으로 필드 구성)
- `public_html/html/{name}/{name}_list.html` — 목록 테이블
- `public_html/html/{name}/{name}_write.html` — 등록 폼
- `public_html/html/{name}/{name}_modify.html` — 수정 폼
- `public_html/html/{name}/{name}_view.html` — 상세 화면

## 완료 후
1. 생성된 모든 JSP 코드를 MCP `validate_code`로 검증한다.
2. `ant compile`로 DAO를 컴파일한다.
3. 생성된 파일 목록을 사용자에게 보여준다.
