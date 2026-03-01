#!/bin/bash
# 맑은프레임워크 JSP/HTML 자동 검증 Hook
# PostToolUse (Write|Edit) 시 실행되어 기본 규칙 위반을 체크

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)

# file_path가 없으면 tool_input 안에서 찾기
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path" *: *"[^"]*"' | head -1 | cut -d'"' -f4)
fi

# 파일이 없거나 대상이 아니면 종료
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

ERRORS=""

# JSP 파일 검증
if [[ "$FILE_PATH" == *.jsp ]]; then
  CONTENT=$(cat "$FILE_PATH")

  # init.jsp는 검증 제외
  if [[ "$FILE_PATH" == */init.jsp ]]; then
    exit 0
  fi

  # 1. JSP 헤더 체크 (contentType 선언)
  if ! echo "$CONTENT" | head -1 | grep -q 'contentType="text/html; charset=utf-8"'; then
    # API JSP는 application/json 허용
    if ! echo "$CONTENT" | head -1 | grep -q 'contentType="application/json'; then
      # api/init.jsp include 패턴도 허용
      if ! echo "$CONTENT" | head -1 | grep -q 'include file="/api/init.jsp"'; then
        ERRORS="$ERRORS\n- JSP 헤더 누락: contentType 선언 필요"
      fi
    fi
  fi

  # 2. page import 금지
  if echo "$CONTENT" | grep -q '<%@ page import'; then
    ERRORS="$ERRORS\n- <%@ page import %> 금지: init.jsp가 모든 import 처리"
  fi

  # 3. 표현식 태그 금지
  if echo "$CONTENT" | grep -q '<%='; then
    ERRORS="$ERRORS\n- <%= %> 표현식 태그 금지: HTML 템플릿에서 {{변수}} 사용"
  fi

  # 4. try-catch 금지
  if echo "$CONTENT" | grep -q 'try *{'; then
    ERRORS="$ERRORS\n- try-catch 금지: boolean 리턴값으로 성공/실패 판단"
  fi

  # 5. request.getParameter 금지
  if echo "$CONTENT" | grep -q 'request.getParameter'; then
    ERRORS="$ERRORS\n- request.getParameter() 금지: m.rs()/m.ri() 또는 f.get() 사용"
  fi

  # 6. SQL 문자열 연결 체크
  if echo "$CONTENT" | grep -qE '\+ *"' | grep -qi 'where\|select\|insert\|update\|delete'; then
    ERRORS="$ERRORS\n- SQL 문자열 연결 의심: ? 바인딩 파라미터 사용 권장"
  fi
fi

# HTML 템플릿 파일 검증
if [[ "$FILE_PATH" == *.html ]] && [[ "$FILE_PATH" == */html/* ]]; then
  CONTENT=$(cat "$FILE_PATH")

  # HTML에 JSP 스크립틀릿이 있으면 안됨
  if echo "$CONTENT" | grep -q '<%'; then
    ERRORS="$ERRORS\n- HTML 템플릿에 JSP 코드(<%) 금지"
  fi
fi

# Java DAO 파일 검증
if [[ "$FILE_PATH" == *.java ]] && [[ "$FILE_PATH" == */dao/* ]]; then
  CONTENT=$(cat "$FILE_PATH")

  # DataObject 상속 체크
  if ! echo "$CONTENT" | grep -q 'extends DataObject'; then
    ERRORS="$ERRORS\n- DAO는 DataObject를 상속해야 함"
  fi

  # this.table 설정 체크
  if ! echo "$CONTENT" | grep -q 'this.table'; then
    ERRORS="$ERRORS\n- 생성자에서 this.table 설정 필요"
  fi
fi

# 결과 출력
if [ -n "$ERRORS" ]; then
  # JSON으로 systemMessage 출력 - Claude가 이 메시지를 보고 수정
  echo "{\"systemMessage\": \"[맑은프레임워크 Hook] 규칙 위반 발견 ($FILE_PATH):$ERRORS\nMCP validate_code로 상세 검증 후 수정하세요.\"}"
fi

exit 0
