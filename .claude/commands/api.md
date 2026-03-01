# REST API 엔드포인트 생성

테이블명: $ARGUMENTS

## 작업 절차

1. `schema.sql`에서 해당 테이블의 컬럼 구조를 확인한다.
2. `public_html/api/init.jsp`를 읽어 API 초기화 구조를 확인한다.
3. `public_html/api/index.jsp`를 읽어 라우터 구조를 확인한다.
4. MCP `get_pattern("jsp-restapi")`로 REST API 패턴을 조회한다.
5. 기존 `public_html/api/board.jsp`를 참고하여 동일한 스타일로 작성한다.

## 생성할 파일

테이블명에서 `tb_` 접두사를 제거하여 파일명으로 사용한다. (예: tb_notice → notice)

- `public_html/api/{name}.jsp` — CRUD REST API (list, view, write, update, delete)

## 필수 구현 사항

- `api.success()` / `api.error("ERROR_CODE", "메시지")` 응답
- 라우트별 로그인 체크 (`if(!isLogin)`)
- 수정/삭제 시 작성자 본인 확인
- `f.get()`으로 POST 데이터 처리
- 바인딩 파라미터 사용 (SQL Injection 방지)

## 완료 후
1. `public_html/api/index.jsp`에 새 API 라우트를 추가한다.
2. 생성된 코드를 MCP `validate_code`로 검증한다.
3. 필요한 DAO가 없으면 생성하고 `ant compile`로 컴파일한다.
