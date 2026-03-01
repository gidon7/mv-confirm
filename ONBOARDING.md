# 맑은프레임워크 + Claude Code 온보딩 가이드

> 이 문서를 따라하면 5분 안에 Claude Code로 CRUD를 생성할 수 있습니다.

---

## 1단계: 프로젝트 클론

```bash
git clone https://github.com/hopegiver/malgn-template.git my-project
cd my-project
```

## 2단계: Claude Code 설치 확인

```bash
claude --version
```

설치가 안 되어 있다면: https://docs.anthropic.com/en/docs/claude-code

## 3단계: MCP 연결 확인

Claude Code를 실행하고 다음을 입력합니다:

```
mcp 연결 테스트
```

7개 도구(get_context, validate_code, get_class, get_rules, get_pattern, get_doc, search_docs)가 모두 정상이면 준비 완료.

## 4단계: DB 설정

1. MySQL에 데이터베이스 생성
2. `schema.sql` 실행하여 테이블 생성
3. `public_html/WEB-INF/config.xml`에 JNDI 설정

## 5단계: 첫 CRUD 만들기

### 방법 A: 슬래시 커맨드 (권장)

```
/project:schema tb_notice 공지사항
```
→ 스키마 생성 후:
```
/project:crud tb_notice
```
→ DAO + JSP 5개 + HTML 4개 자동 생성

### 방법 B: 자연어

```
공지사항 게시판을 만들어줘. 테이블은 tb_notice이고 제목, 내용, 작성자, 조회수가 필요해.
```

## 6단계: 컴파일 & 확인

```
ant compile
```

WAS(Tomcat/Resin)를 재시작하고 브라우저에서 확인합니다.

---

## 자주 쓰는 커맨드

| 커맨드 | 설명 | 예시 |
|--------|------|------|
| `/project:crud` | CRUD 전체 생성 | `/project:crud tb_notice` |
| `/project:api` | REST API 생성 | `/project:api tb_notice` |
| `/project:new-page` | 단일 페이지 생성 | `/project:new-page main/about` |
| `/project:schema` | 테이블 스키마 생성 | `/project:schema tb_faq FAQ` |
| `/project:validate` | 코드 규칙 검증 | `/project:validate board_list.jsp` |
| `/project:review` | 코드 리뷰 | `/project:review` |

## 자동 검증

JSP, HTML, Java(DAO) 파일을 작성하면 **Hook이 자동으로 규칙 위반을 체크**합니다.
위반이 발견되면 Claude가 자동으로 수정 제안을 합니다.

## 참고 문서

| 문서 | 용도 |
|------|------|
| `GUIDE.md` | 맑은프레임워크 코딩 가이드 (상세) |
| `public_html/api/README.md` | REST API 문서 |
| `schema.sql` | DB 스키마 |
| MCP `search_docs("키워드")` | 프레임워크 문서 검색 |
