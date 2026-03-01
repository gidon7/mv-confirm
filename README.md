# 맑은프레임워크 웹사이트 템플릿

**맑은프레임워크** 기반 웹사이트 개발 템플릿입니다.

Bootstrap 5 반응형 디자인으로 회원 시스템, 게시판, 신청 폼, REST API 등 기본 기능을 제공하며, **Claude Code와 MCP를 활용한 바이브코딩 표준화**가 적용되어 있습니다.

---

## 시작하기

### 빠른 시작 (Claude Code 사용)

```bash
git clone https://github.com/hopegiver/malgn-template.git my-project
cd my-project
claude
```

Claude Code가 자동으로 `CLAUDE.md`, 코딩 규칙, MCP 도구를 로드합니다.
상세한 온보딩 절차는 **`ONBOARDING.md`** 를 참고하세요.

### 수동 설정

1. DB 생성 후 `schema.sql` 실행
2. `public_html/WEB-INF/config.xml`에 JNDI 설정
3. `ant compile`로 DAO 컴파일
4. WAS(Tomcat/Resin) 배포

---

## Claude Code 연동

이 템플릿에는 Claude Code 바이브코딩을 위한 표준 설정이 포함되어 있습니다.

### MCP (Model Context Protocol)

맑은프레임워크 전용 MCP 서버가 연결되어 코딩 규칙, 패턴 템플릿, 클래스 정보, 문서를 실시간으로 제공합니다.

| 도구 | 기능 |
|------|------|
| `get_context` | 작업별 규칙+패턴+클래스 일괄 조회 |
| `get_pattern` | 코드 패턴 템플릿 (13종) |
| `validate_code` | 코드 규칙 위반 검증 |
| `get_class` | 클래스 메소드 상세 조회 |
| `get_rules` | 코딩 규칙 조회 |
| `get_doc` / `search_docs` | 프레임워크 문서 조회 |

### 커스텀 커맨드

| 커맨드 | 기능 | 예시 |
|--------|------|------|
| `/project:crud` | CRUD 전체 생성 (DAO+JSP+HTML) | `/project:crud tb_notice` |
| `/project:api` | REST API 엔드포인트 생성 | `/project:api tb_notice` |
| `/project:schema` | 테이블 스키마 생성 | `/project:schema tb_faq FAQ` |
| `/project:new-page` | 단일 페이지 생성 | `/project:new-page main/about` |
| `/project:validate` | 코드 규칙 검증 | `/project:validate` |
| `/project:review` | 코드 리뷰 | `/project:review` |

### 자동 검증 Hook

JSP, HTML, Java(DAO) 파일 작성/수정 시 Hook이 자동 실행되어 맑은프레임워크 규칙 위반을 감지합니다.

---

## 주요 기능

- **회원 시스템**: 회원가입, 로그인, 로그아웃 (SHA-256 암호화)
- **게시판**: CRUD, 검색, 페이징, 작성자 권한 확인
- **신청 폼**: 문의/신청 접수 (AJAX 처리)
- **REST API**: JWT 인증, CORS, 완전한 CRUD 지원
- **반응형 디자인**: Bootstrap 5 모바일 지원

---

## 기술 스택

- **백엔드**: JSP/Servlet, 맑은프레임워크 (malgn.jar)
- **프론트**: Bootstrap 5, 맑은템플릿 엔진
- **DB**: MySQL (JNDI 연결)
- **API**: RESTful + JWT 인증
- **빌드**: Ant
- **AI**: Claude Code + MCP

---

## 프로젝트 구조

```
malgn-template/
├── CLAUDE.md                  # Claude Code 프로젝트 설명 (자동 로드)
├── GUIDE.md                   # 맑은프레임워크 AI 코딩 가이드
├── ONBOARDING.md              # 신규 직원 온보딩 가이드
├── schema.sql                 # DB 스키마
├── build.xml                  # Ant 빌드 설정
├── .mcp.json                  # MCP 서버 연결 설정
│
├── .claude/                   # Claude Code 설정
│   ├── rules/malgn.md         # 코딩 규칙 (자동 로드)
│   ├── settings.json          # 팀 공유 권한 + Hook 설정
│   ├── commands/              # 커스텀 슬래시 커맨드
│   │   ├── crud.md            # /project:crud
│   │   ├── api.md             # /project:api
│   │   ├── schema.md          # /project:schema
│   │   ├── new-page.md        # /project:new-page
│   │   ├── validate.md        # /project:validate
│   │   └── review.md          # /project:review
│   └── hooks/
│       └── post-write.sh      # 파일 저장 시 자동 규칙 검증
│
├── src/dao/                   # DAO 클래스 (Java)
│   ├── UserDao.java
│   ├── BoardDao.java
│   └── ApplyDao.java
│
└── public_html/               # 웹 루트
    ├── init.jsp               # 공통 초기화
    ├── index.jsp              # 루트 리다이렉트
    ├── member/                # 회원 JSP
    ├── main/                  # 메인 JSP
    ├── board/                 # 게시판 JSP
    ├── api/                   # REST API
    │   ├── init.jsp           # API 초기화 (JWT, CORS)
    │   ├── index.jsp          # API 라우터
    │   ├── auth.jsp           # 인증 API
    │   ├── board.jsp          # 게시판 API
    │   └── apply.jsp          # 신청 API
    ├── html/                  # HTML 템플릿
    │   ├── layout/            # 레이아웃
    │   ├── main/              # 메인 템플릿
    │   ├── board/             # 게시판 템플릿
    │   └── member/            # 회원 템플릿
    ├── css/style.css
    ├── js/common.js
    └── WEB-INF/
        ├── config.xml         # 프레임워크 설정
        ├── web.xml            # 서블릿 설정
        ├── lib/malgn.jar      # 프레임워크 라이브러리
        └── classes/           # 컴파일된 DAO
```

---

## 참고 문서

| 문서 | 용도 |
|------|------|
| `CLAUDE.md` | Claude Code 프로젝트 컨텍스트 |
| `GUIDE.md` | 맑은프레임워크 코딩 가이드 (상세) |
| `ONBOARDING.md` | 신규 직원 온보딩 |
| `schema.sql` | DB 테이블 스키마 |

---

## 라이선스

맑은프레임워크의 라이선스를 따릅니다.
