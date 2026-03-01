# 코드 리뷰

$ARGUMENTS 가 있으면 해당 경로를, 없으면 현재 git 변경 파일 전체를 리뷰한다.

## 절차

1. 대상 파일 목록 수집:
   - 인자가 있으면 해당 파일/폴더
   - 없으면 `git diff --name-only HEAD`로 변경된 파일 목록
2. 각 파일을 읽고 확장자별로 분류한다 (jsp, html, java).
3. 모든 JSP/HTML/Java 파일을 MCP `validate_code(code, file_type)`로 검증한다. (병렬 실행)
4. MCP `get_rules(category: "checklist")`로 체크리스트를 조회한다.
5. 체크리스트 항목별로 코드를 검토하고 위반 여부를 판단한다.

## 리뷰 항목

- 맑은프레임워크 규칙 위반 (MCP validate_code)
- 명명 규칙 (DAO 변수명, DataSet 변수명)
- 보안 (SQL 바인딩, XSS, 인증 체크)
- Postback 패턴 준수 (수정 페이지 조회 시점, return 누락)
- 불필요한 코드 (null 체크, 변수 선언, try-catch)

## 출력 형식

파일별로 결과를 정리한다:
- 통과: 파일명 + "OK"
- 위반: 파일명 + 위반 내용 + 수정 제안

마지막에 전체 요약 (통과/위반 파일 수, 주요 위반 사항)을 출력한다.
