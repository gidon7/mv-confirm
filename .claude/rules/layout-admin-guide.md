# 관리자단 레이아웃 구조 분석 및 리뉴얼 가이드

> 작성일: 2026-03-22
> 대상: `/public_html/sysop/`
> 목표: iframe 방식 제거 → AJAX 콘텐츠 로딩 방식으로 전환

---

## 1. 현재 구조 (정확한 파악)

### 1-1. 전체 흐름

브라우저가 관리자단에 접속하면 `top.jsp`가 진입점이며,
`layout_admin.html`이 전체 셸(shell)로 렌더링된다.

```
브라우저
    │
    ▼
top.jsp  →  p.setLayout("admin"), p.setBody("main.top")
    │
    ▼
layout_admin.html  ← 전체 셸
    │
    ├── [사이드바 안에] top.html  ← top.jsp의 body
    │       ├── #gnb > #top_menu         ← 1depth 메뉴 (세로 버튼 목록)
    │       └── #lnb_wrapper             ← 2/3depth 아코디언 컨테이너
    │              (초기 비어있음, 1depth 클릭 시 AJAX로 채워짐)
    │
    └── [우측 콘텐츠] <iframe name="_Main">
```

**1depth 클릭 시:**
```
top.html의 go() 함수
    └── AJAX: menu2.jsp?mode=json&mid={id}
            └── JSON 반환 → #lnb_contents 아코디언에 동적 삽입
```

**3depth 메뉴 클릭 시:**
```
<a href="경로" target="_Main"> 클릭
    └── _Main iframe 안에서 해당 URL 로드
            └── 기능 JSP (예: user_list.jsp)
                    └── p.setLayout("sysop") → layout_sysop.html
```

---

### 1-2. 파일별 역할 (현재)

| 파일 | 역할 |
|------|------|
| `main/top.jsp` | 1depth GNB 목록 쿼리, `layout="admin"` 진입점 |
| `html/main/top.html` | 사이드바 본문 (1depth 탭 + 2/3depth 아코디언 컨테이너, `go()` 함수) |
| `main/menu2.jsp` | `mode=json` 시 2/3depth 메뉴 JSON 반환 |
| `html/layout/layout_admin.html` | **전체 셸** — 사이드바(250px) + 탑바 + `<iframe name="_Main">` |
| `html/layout/layout_sysop.html` | **콘텐츠 페이지 레이아웃** — iframe 안에서 각 기능 JSP에 적용 |
| 각 기능 JSP | `p.setLayout("sysop")` → layout_sysop.html 내부에 렌더링 |

---

### 1-3. layout_admin.html 실제 DOM 구조

```
<div id="admin-shell">            ← display: flex; height: 100vh

    <nav id="admin-sidebar">      ← width: 250px; 다크 배경 (#1a2535)
        .sidebar-logo             ← 로고 (하드코딩)
        .sidebar-body             ← <!--@include(BODY)--> → top.html 삽입
            #gnb > #top_menu      ← 1depth 세로 목록
            #lnb_wrapper
                #lnb_contents     ← 2/3depth 아코디언 (AJAX로 채워짐)

    <div id="admin-right">        ← flex: 1; display: flex; flex-direction: column

        <header id="admin-topbar"> ← height: 50px; 유저명/버튼

        <div id="admin-content">  ← flex: 1; overflow: hidden
            <iframe name="_Main"> ← 콘텐츠 로드 영역 (100% width/height)
```

---

### 1-4. layout_sysop.html 실제 DOM 구조

iframe 안에서 각 콘텐츠 JSP가 사용하는 레이아웃:

```
<body>
    <div id="sys-breadcrumb">     ← 페이지 제목 바 (퀵메뉴추가, 새로고침 버튼)
        #sys-page-title           ← {{p_title}}
        #sys-page-util

    <div id="sys-wrap">
        <div id="sys-scroll">
            <div id="sys-contents"> ← <!--@include(BODY)--> → 기능 HTML 삽입
```

> **주의:** layout_sysop.html 내에 구 frameset 시절 코드가 잔존함
> - `Toggle()` 함수 — `top.document.getElementById("_MFRM").cols` 조작 (frameset용)
> - `noframe` 조건 블록 — URL 직접 접근 시 임시 frameset 재구성
> - `parent.calcSize()` — iframe 크기 재계산

---

### 1-5. 현재 구조의 문제점

| 문제 | 설명 |
|------|------|
| **JS 통신 복잡** | 콘텐츠 → 셸 참조 시 `top.`, `parent.` 접두사 필수 |
| **뒤로가기 오동작** | 브라우저 히스토리가 iframe 내부 변경을 추적하지 못함 |
| **공통 UI 공유 불가** | 토스트, 전역 모달 등을 iframe 경계 넘어 띄우기 어려움 |
| **스크롤 이중화** | iframe 자체 스크롤 vs 셸 스크롤 충돌 |
| **레거시 코드 혼재** | Toggle(), _MFRM, noframe 등 frameset 잔재 |
| **개발자 도구 불편** | iframe 내부 DOM을 셸과 별개로 검사해야 함 |

---

## 2. 목표 구조 (iframe → AJAX div 로딩)

### 2-1. 변경 후 전체 구조

```
<div id="admin-shell">            ← display: flex; height: 100vh

    <nav id="admin-sidebar">      ← width: 250px
        .sidebar-logo
        .sidebar-body
            #gnb > #top_menu      ← 1depth 세로 목록 (유지)
            #lnb_wrapper
                #lnb_contents     ← 2/3depth 아코디언 (유지)

    <div id="admin-right">        ← flex: 1

        <header id="admin-topbar"> ← 브레드크럼 추가 + 유저명/버튼

        <div id="admin-content">  ← flex: 1; overflow-y: auto
            <div id="page-content"> ← AJAX 결과 innerHTML 삽입
```

---

### 2-2. 콘텐츠 로딩 흐름 변경

**현재 (iframe):**
```
메뉴 클릭 → <a target="_Main"> → iframe src 변경 → 브라우저가 iframe 안에서 전체 HTML 로드
```

**목표 (AJAX):**
```
메뉴 클릭 → loadPage(url) → fetch(url + '?_layout=ajax')
                                   → 서버: layout_ajax.html (body만 반환)
                                   → #page-content.innerHTML = 응답
                                   → <script> 태그 동적 재실행
                                   → history.pushState(url)
                                   → 탑바 브레드크럼 업데이트
```

---

### 2-3. 새 레이아웃: layout_ajax.html

AJAX 요청용 — HTML 래퍼 없이 body 콘텐츠만 반환:

```html
<!--@include(BODY)-->
```

각 기능 JSP에서 `?_layout=ajax` 파라미터 감지 시 이 레이아웃 사용:

```jsp
// 변경 전
p.setLayout("sysop");

// 변경 후
p.setLayout("ajax".equals(m.rs("_layout")) ? "ajax" : "sysop");
```

---

## 3. 단계별 작업 순서

---

### Phase 1 — AJAX 레이아웃 기반 준비

> 기존 동작에 전혀 영향 없음. 병행 준비 가능.

**작업 1-1. `layout_ajax.html` 신규 생성**

```
경로: html/layout/layout_ajax.html
내용: <!--@include(BODY)-->
```

단 한 줄. HTML 래퍼 없이 BODY 슬롯만 출력.

---

**작업 1-2. 주요 기능 JSP에 `_layout` 분기 추가**

우선 적용 순서 (사용 빈도 높은 순):
1. `main/index.jsp` (대시보드)
2. `user/` 전체
3. `course/` 전체
4. `order/` 전체
5. `board/` 전체
6. 나머지 모듈 순차 적용

각 JSP에서:
```jsp
p.setLayout("ajax".equals(m.rs("_layout")) ? "ajax" : "sysop");
```

---

### Phase 2 — layout_admin.html 셸 재구성

**작업 2-1. `<iframe>` 제거 → `<div id="page-content">` 교체**

```html
<!-- 제거 -->
<div id="admin-content">
    <iframe name="_Main" id="_Main" src="about:blank" frameborder="0"></iframe>
</div>

<!-- 교체 -->
<div id="admin-content">
    <div id="page-content"></div>
</div>
```

CSS 변경:
```css
/* 기존 */
#admin-content { flex: 1; overflow: hidden; position: relative; }
#admin-content iframe { width: 100%; height: 100%; border: none; display: block; }

/* 변경 */
#admin-content { flex: 1; overflow-y: auto; background: var(--bg-base); }
#page-content  { padding: 0; min-height: 100%; }
```

---

**작업 2-2. 탑바에 브레드크럼 추가**

```html
<header id="admin-topbar">
    <nav id="admin-breadcrumb" style="flex:1; display:flex; align-items:center; gap:6px; font-size:13px; color:var(--text-muted);">
        <span id="bc-gnb"></span>
        <i class="fa fa-angle-right" style="font-size:11px;"></i>
        <span id="bc-lnb"></span>
        <i class="fa fa-angle-right" style="font-size:11px;"></i>
        <strong id="bc-page" style="color:var(--text-base);"></strong>
    </nav>
    <div class="topbar-user">
        <!-- 기존 유저명/버튼 유지 -->
    </div>
</header>
```

---

**작업 2-3. `loadPage()` 핵심 JS 작성**

`layout_admin.html` 하단 `<script>` 블록에 추가:

```javascript
// ── AJAX 페이지 로더 ──────────────────────────────
function loadPage(url, breadcrumb) {
    var sep    = url.indexOf('?') >= 0 ? '&' : '?';
    var ajaxUrl = url + sep + '_layout=ajax';

    // 로딩 표시
    document.getElementById('page-content').innerHTML =
        '<div style="padding:40px 28px; color:var(--text-light); font-size:13px;">불러오는 중...</div>';

    fetch(ajaxUrl)
        .then(function(res) {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.text();
        })
        .then(function(html) {
            var el = document.getElementById('page-content');
            el.innerHTML = html;

            // <script> 태그 재실행 (innerHTML은 script 미실행)
            el.querySelectorAll('script').forEach(function(old) {
                var s = document.createElement('script');
                if (old.src) {
                    s.src = old.src;
                } else {
                    s.textContent = old.textContent;
                }
                old.parentNode.replaceChild(s, old);
            });

            // 브레드크럼 업데이트
            if (breadcrumb) {
                document.getElementById('bc-gnb').textContent  = breadcrumb.gnb  || '';
                document.getElementById('bc-lnb').textContent  = breadcrumb.lnb  || '';
                document.getElementById('bc-page').textContent = breadcrumb.page || '';
            }

            // 브라우저 URL/히스토리 업데이트
            history.pushState({ url: url, breadcrumb: breadcrumb }, '', url);

            // 콘텐츠 영역 스크롤 최상단으로
            document.getElementById('admin-content').scrollTop = 0;
        })
        .catch(function(err) {
            document.getElementById('page-content').innerHTML =
                '<div style="padding:40px 28px; color:#dc2626; font-size:13px;">' +
                '페이지를 불러오지 못했습니다. (' + err.message + ')</div>';
        });
}

// 브라우저 뒤로가기/앞으로가기 지원
window.addEventListener('popstate', function(e) {
    if (e.state && e.state.url) {
        loadPage(e.state.url, e.state.breadcrumb);
    }
});
```

---

### Phase 3 — top.html 메뉴 클릭 연동 수정

**작업 3-1. `target="_Main"` 링크 클릭 이벤트 가로채기**

`top.html` 내 `$(document).ready` 안에 추가:

```javascript
// 3depth 메뉴 클릭 → loadPage()
$(document).on('click', '#lnb_contents .acc-sub a', function(e) {
    e.preventDefault();
    var url  = $(this).attr('href');
    var page = $(this).text().replace(/<[^>]+>/g, '').trim();
    var gnb  = $('#top_menu a.current').text().trim();
    var lnb  = $(this).closest('.acc-title').children('a:first').text().replace(/<[^>]+>/g, '').trim();

    // 사이드바 활성 표시
    $('#lnb_contents .acc-sub a').removeClass('active');
    $(this).addClass('active');

    // 탑바 단순 제목 (기존 호환용)
    try { top.document.getElementById('admin-page-title').textContent = page; } catch(e2) {}

    // AJAX 로드
    if (top.loadPage) {
        top.loadPage(url, { gnb: gnb, lnb: lnb, page: page });
    }
});
```

**작업 3-2. 초기 대시보드 로드 방식 변경**

```javascript
$(document).ready(function() {
    // 기존: document.getElementById("_Main").src = "../main/index.jsp";
    // 변경:
    if (top.loadPage) {
        top.loadPage('../main/index.jsp', { gnb: '', lnb: '', page: '대시보드' });
    }

    // 아래는 기존 코드 그대로 유지
    $("#lnb_contents").mCustomScrollbar({ ... });
    go(null, "{{mid}}", "{{lnb}}");
    ...
});
```

---

### Phase 4 — layout_sysop.html 레거시 코드 정리

> Phase 1~3 완료 후 진행. layout_sysop.html은 직접 URL 접근 폴백용으로 유지.

**제거 대상:**

| 코드 | 제거 이유 |
|------|-----------|
| `Toggle()` 함수 전체 | `_MFRM` frameset 참조 — frameset 없음 |
| `html, body { overflow:hidden; }` | 셸이 overflow 관리하므로 불필요 |
| `noframe` 조건 블록 전체 | frameset 직접 접근 임시 처리 코드 |
| `parent.calcSize()` 호출 | iframe 크기 재계산 — 불필요 |
| `top.document.getElementById("_MFRM")` 참조 | frameset 잔재 |

**유지 대상:**

| 코드 | 유지 이유 |
|------|-----------|
| `#sys-breadcrumb` | 콘텐츠 내 페이지 제목/버튼 영역 |
| `#sys-wrap > #sys-contents` | 실제 콘텐츠 렌더링 영역 |
| `addShortcut()` | 퀵메뉴 추가 기능 |
| `HtmlConvertor()` | 맑은프레임워크 HTML 변환 |
| `call("/sysop/main/call_blind.jsp")` | 개인정보 블라인드 처리 |

---

### Phase 5 — `target="_Main"` 전수 대응 (선택)

기존 콘텐츠 HTML에서 `target="_Main"` 링크가 다수 존재.
Phase 2에서 이벤트 위임으로 한 번에 처리 가능:

```javascript
// layout_admin.html — #page-content 내부 링크 감지
$(document).on('click', '#page-content a[target="_Main"]', function(e) {
    e.preventDefault();
    if (top.loadPage) top.loadPage($(this).attr('href'));
});
```

이 방식으로 **각 콘텐츠 JSP/HTML 수정 없이** AJAX 전환 가능.

---

### Phase 6 — POST 폼 처리 (선택)

iframe에서는 form submit이 iframe 안에서 처리됐으나,
AJAX 방식에서는 form submit 결과가 전체 페이지를 교체함.

**기본 전략:** form submit은 그대로 두고, **submit 후 리디렉션 시 AJAX 로드**로 전환.

콘텐츠 JSP에서 `m.jsReplace("경로")` 호출 부분을 점진적으로:
```javascript
// 기존 (iframe 방식)
top.location.href = url;      // 전체 셸 이동
parent.location.href = url;   // iframe 교체

// 변경 (AJAX 방식)
top.loadPage(url);
```

> POST 전환은 가장 변경량이 많으므로 선택적 적용.
> 초기에는 POST submit → 전체 페이지 새로고침도 허용.

---

### Phase 7 — 공통 UI 통합 (선택)

iframe 제거 후 셸과 콘텐츠가 같은 DOM이 되므로 가능해지는 기능:

| 기능 | 구현 방법 |
|------|-----------|
| **토스트 알림** | layout_admin.html에 `#toast-area` 추가, `showToast(msg, type)` 전역 함수 |
| **전역 로딩 스피너** | fetch 시작/완료 시 overlay 표시 |
| **글로벌 모달** | layout_admin.html에 `#modal-area`, `openModal(url)` 함수 |
| **브레드크럼 자동화** | 메뉴 데이터에서 경로 자동 추출 (menu2.jsp JSON 활용) |

---

## 4. 신규/변경 파일 요약

| 파일 | 작업 | Phase |
|------|------|-------|
| `html/layout/layout_ajax.html` | **신규 생성** — body content만 반환 | Phase 1 |
| 각 기능 JSP | **수정** — `_layout` 파라미터 분기 추가 | Phase 1 |
| `html/layout/layout_admin.html` | **수정** — iframe→div 교체, loadPage() 추가, 브레드크럼 | Phase 2 |
| `html/main/top.html` | **수정** — 메뉴 클릭 → loadPage() 연동 | Phase 3 |
| `html/layout/layout_sysop.html` | **수정** — 레거시 Toggle/noframe 코드 제거 | Phase 4 |

---

## 5. 주의사항

### 5-1. `OpenWindow`, `OpenLayer` 팝업 — 변경 없음

별도 창/레이어 팝업 함수는 iframe과 무관하므로 그대로 동작.

### 5-2. `top.` 접두사 참조 — 유지 가능

콘텐츠 JSP에서 `top.loadPage()` 패턴을 셸에 등록하면
기존 `top.xxx()` 호출 패턴을 그대로 활용 가능.

### 5-3. 직접 URL 접근 폴백

`layout_sysop.html`은 유지되어야 함.
누군가 3depth 페이지 URL을 직접 접속 시 → layout_sysop으로 정상 렌더링.
AJAX 요청 시에만 layout_ajax 사용.

### 5-4. `<script>` 재실행 주의

innerHTML로 삽입된 `<script>` 태그는 자동 실행되지 않음.
Phase 2의 loadPage()에서 `querySelectorAll('script')` 재실행 처리 필수.
외부 CDN src 스크립트는 중복 로드 방지 로직 추가 검토.

---

## 6. 검증 체크리스트

- [ ] 대시보드(index.jsp) AJAX 로드 후 차트 정상 렌더링
- [ ] 목록 페이지 AJAX 로드 후 테이블/페이징 동작
- [ ] 등록/수정 폼 AJAX 로드 후 입력 요소 동작
- [ ] 폼 submit 처리 후 페이지 전환 정상
- [ ] 브라우저 뒤로가기 → 이전 콘텐츠 복원
- [ ] `OpenWindow`, `OpenLayer` 팝업 정상 동작
- [ ] `top.loadPage()` 콘텐츠 내 직접 호출 동작
- [ ] 탑바 브레드크럼 메뉴 이동마다 업데이트
- [ ] 사이드바 메뉴 활성 상태(.active) 정상 반영
- [ ] 3depth URL 직접 접근 시 layout_sysop 폴백 정상
- [ ] mCustomScrollbar 사이드바 스크롤 정상
