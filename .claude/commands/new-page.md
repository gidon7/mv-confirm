# 새 페이지 생성

$ARGUMENTS 형식: {폴더명}/{파일명} (예: main/notice, board/faq)

## 절차

1. 사용자에게 페이지 유형을 확인한다:
   - 목록 페이지 (ListManager 사용)
   - 폼 페이지 (Postback 패턴)
   - 단순 페이지 (조회/표시만)
2. 해당 유형의 MCP `get_pattern(type)`을 조회한다.
3. 두 파일을 생성한다:
   - `public_html/{폴더명}/{파일명}.jsp` — JSP (로직)
   - `public_html/html/{폴더명}/{파일명}.html` — HTML (템플릿)
4. 생성된 JSP를 MCP `validate_code`로 검증한다.
