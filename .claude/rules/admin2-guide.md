# admin2.css 관리자단 리뉴얼 가이드

기존 `admin.css` 클래스명을 그대로 유지하면서, CSS 파일만 `admin2.css`로 교체해 모던하게 리뉴얼한다.
HTML 파일은 수정 없이 레이아웃 파일에서 CSS 링크만 변경하면 된다.

---

## CSS 교체 방법

**`layout_sysop.html`** (실제 CSS 로드 위치) 에서 변경:

```html
<!-- 변경 전 (주석 처리) -->
<!-- <link rel="stylesheet" href="{{SYS_COMMON_CDN}}/sysop/html/css/admin.css?t={{SYS_TODAY}}151901"> -->

<!-- 변경 후 -->
<link rel="stylesheet" href="/sysop/html/css/admin2.css">
```

> `top.html`, `menu2.html` 등 개별 HTML 파일에는 CSS 링크가 없다.
> CSS는 **`layout_sysop.html` 한 곳**에서만 로드된다.

---

## 레이아웃 구조

sysop 관리자단은 **frameset 기반** 구조다. 각 영역이 별도로 로드된다.

```
┌─────────────────────────────────────────────┐
│  top.jsp → top.html    (GNB, 상단바)         │ ← iframe 외부 프레임
├──────────┬──────────────────────────────────┤
│          │  #sys-breadcrumb (페이지 타이틀)   │
│ menu2.jsp│──────────────────────────────────│
│ → menu2  │  #sys-contents                   │
│ .html    │    <!--@include(BODY)-->          │ ← layout_sysop.html
│ (LNB)    │    각 페이지 html/xxx.html 렌더링  │
│          │                                  │
└──────────┴──────────────────────────────────┘
```

### layout_sysop.html 구조

```html
<!-- 브레드크럼 / 페이지 타이틀 -->
<div id="sys-breadcrumb">
    <button id="sys-breadcrumb-arrow">◀</button>
    <div id="sys-page-title">{{p_title}}</div>
    <div id="sys-page-util">새로고침</div>
</div>

<!-- 스크롤 래퍼 -->
<div id="sys-wrap">
  <div id="sys-scroll">
    <div id="alert_area"></div>       <!-- 레이어 알럿 출력 위치 -->
    <div id="sys-contents">
      <!--@include(BODY)-->            <!-- 각 페이지 html 템플릿 삽입 -->
    </div>
  </div>
</div>
```

### menu2.html (LNB) 구조

```html
<div id="lnb_wrapper">
    <!-- 퀵메뉴 드롭다운 -->
    <div id="lnb_shortcut">
        <select id="favorite_select">퀵메뉴 선택</select>
    </div>
    <!-- 아코디언 메뉴 -->
    <div id="lnb_contents_wrapper">
        <div id="lnb_contents">
            <ul class="acc-nav" id="lnb-{{mid}}"></ul>
        </div>
    </div>
</div>
```

LNB 메뉴 항목은 JS로 동적 생성 (`addAccNode()` 함수).
활성 메뉴 항목: `a.active` 클래스 → admin2.css에서 `background: #2563eb; color: #fff;`

### noframe 모드

`noframe` 변수가 true면 iframe 없이 단독 페이지로 동작 (직접 접근 시):

```html
<!-- noframe 시 자체 GNB/LNB 포함 -->
<div id="sys-frame-top"> ... top.jsp ... </div>
<div id="sys-frame-bottom">
    <iframe id="sys-frame-menu" src="menu2.jsp"></iframe>
    <div id="sys-frame-main"> ... 콘텐츠 ... </div>
</div>
```

---

## 디자인 변경 사항 요약

| 항목 | admin.css (구) | admin2.css (신) |
|---|---|---|
| 폰트 | 맑은 고딕 | Pretendard + 맑은 고딕 fallback |
| 컬러 | 파란 GIF 배경 + `#B8D0FA` 테두리 | CSS 변수 기반 (인디고 `#6366f1` + 따뜻한 Zinc 계열) |
| 테이블 헤더 | GIF 이미지 배경 | 연회색 배경 (`#fafafb`) + 12px 볼드 |
| 폼 라벨 | GIF 이미지 배경 | 연회색 `#fafafb` 배경 + 좌측 정렬 + 테두리 최소화 |
| 버튼 | GIF 이미지 배경 + 색상 텍스트 | 그라데이션 버튼 + 컬러 섀도우 |
| 라벨 | 배경 채우기 (진한 색) | 파스텔 둥근사각 뱃지 (`border-radius: 8px`) |
| 테두리 | `#d1d1d1` | `#f0f0f0` (목록행) / `#e4e4e7` (폼/검색) |
| 행 hover | `background:#efefef` | `background:#f8f7ff` (인디고 틴트) |
| 페이징 | GIF 이미지 버튼 | 박스형 번호 버튼 + 인디고 active |
| GNB/사이드바 | 파란 배경 (`#235c9f`) | 딥 다크 (`#111113` 그라데이션) |
| LNB active | 파란 배경 | 인디고 반투명 글라스 (`rgba(99,102,241,0.25)`) |
| 모서리 | 사각 | `border-radius: 12px` (카드), `8px` (인풋/버튼) |
| 팝업 | 단순 테두리 | 블러 딤 + 그라데이션 액센트 라인 + 스프링 애니메이션 |

---

## 클래스 참조

### 검색 테이블 (t_tb01)

```html
<table class="t_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="t_th01">라벨</td>   <!-- 회색 배경 헤더 셀 -->
    <td class="t_td01">내용</td>   <!-- 흰 배경 입력 셀 -->
    <td class="t_th01">라벨2</td>
    <td class="t_td01">내용2</td>
  </tr>
</table>
```

### 액션 바 (a_tb01)

```html
<table class="a_tb01" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td class="a_th01">          <!-- 좌측: 건수, 페이지수 선택 -->
      {{list_total}} &nbsp;
      <select name="s_listnum" onchange="...">...</select> 건씩 보기
    </td>
    <td class="a_td01">          <!-- 우측: 버튼 (text-align:right) -->
      <button class="bttn2 blue">등록</button>
      <button class="bttn2 sky">엑셀</button>
      <button class="bttn2 red">삭제</button>
    </td>
  </tr>
</table>
```

### 목록 테이블 (l_tb01)

```html
<table class="l_tb01" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <td class="l_th01">No</td>        <!-- 기본 헤더 (파란 계열) -->
      <td class="l_th01">이름</td>
      <td class="l_th02">구분</td>      <!-- 회색 계열 헤더 -->
      <td class="l_th03">기타</td>      <!-- 더 연한 회색 헤더 -->
    </tr>
  </thead>
  <tbody>
    <!--@loop(list)-->
    <tr class="l_tr_{{list.ROW_CLASS}}">  <!-- l_tr_even / l_tr_odd -->
      <td class="l_td01">{{list.__ord}}</td>
    </tr>
    <!--/loop(list)-->
  </tbody>
</table>

<!-- 데이터 없음 -->
<table class="n_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td>해당 자료가 없습니다.</td>   <!-- td 또는 n_td01 클래스 사용 -->
  </tr>
</table>

<!-- 페이징 -->
<table class="p_tb01" cellpadding="0" cellspacing="0">
  <tr><td class="p_td01">{{pagebar}}</td></tr>
</table>
```

> `n_tb01 td`는 CSS에서 직접 스타일링됨. `n_th01` 클래스는 별도 정의 없음 → `td`로 작성하거나 `n_td01` 사용.

### 섹션 타이틀 + 폼 테이블

```html
<!-- 섹션 타이틀 바 -->
<table class="c_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="c_th01">기본 정보</td>
    <td class="c_td01"><button class="bttn2 blue">저장</button></td>
  </tr>
</table>

<!-- 폼 필드 테이블 -->
<table class="f_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <th class="f_th01">이름 *</th>
    <td class="f_td01"><input type="text" name="name"></td>
    <th class="f_th01">이메일 *</th>
    <td class="f_td01"><input type="email" name="email"></td>
  </tr>
  <tr>
    <th class="f_th01">내용</th>
    <td class="f_td01" colspan="3">
      <textarea name="content" rows="5"></textarea>
    </td>
  </tr>
</table>

<!-- 하단 버튼 바 -->
<table class="b_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="b_th01"></td>
    <td class="b_td01">
      <button class="bttn2 blue">저장</button>
      <button class="bttn2">목록</button>
    </td>
  </tr>
</table>
```

---

## 버튼

### bttn2 (표준 버튼)

```html
<button class="bttn2">기본 (흰 배경)</button>
<button class="bttn2 blue">파랑 (주요 액션 - 등록/저장)</button>
<button class="bttn2 sky">하늘 (보조 - 엑셀/일괄등록)</button>
<button class="bttn2 green">초록 (승인/완료)</button>
<button class="bttn2 red">빨강 (삭제/경고)</button>
<button class="bttn2 yellow">주황 (수정/주의)</button>
<button class="bttn2 purple">보라 (특수)</button>
<button class="bttn2 ruby">루비 (가려진정보 등)</button>
<button class="bttn2 lightgray">회색 (비활성)</button>
```

### btn_simp (소형 인라인 버튼)

```html
<button class="btn_simp">기본</button>
<button class="btn_simp blue">파랑</button>
<button class="btn_simp yellow"><i class="fa fa-star"></i> 퀵메뉴</button>
<button class="btn_simp green"><i class="fa fa-question-circle"></i> 가이드</button>
```

> `btn_simp`는 테이블 셀 안이나 `#sys-breadcrumb` 안에서 인라인 버튼으로 주로 사용.

---

## 아이콘

Font Awesome 4.x (`fa-*`) 클래스가 layout에서 로드됨. 그대로 사용 가능.

```html
<i class="fa fa-search"></i>    검색
<i class="fa fa-plus"></i>      추가
<i class="fa fa-edit"></i>      수정
<i class="fa fa-trash"></i>     삭제
<i class="fa fa-download"></i>  다운로드
<i class="fa fa-star"></i>      즐겨찾기
<i class="fa fa-angle-left"></i>  ◀
<i class="fa fa-retweet"></i>   새로고침
```

---

## 상태 라벨 (뱃지)

```html
<span class="label blue">정상</span>
<span class="label gray">중지</span>
<span class="label red">탈퇴 / 휴면대상</span>
<span class="label purple">최고관리자</span>
<span class="label sky">대기 / 온라인</span>
<span class="label green">승인 / 완료</span>
<span class="label orange">주의</span>
<span class="label brown">과정관리자</span>
```

JS로 자동 색상 지정 (기존 `setLabel()` 패턴 유지):

```js
function setLabel() {
    var colors = {
        "정상":"blue", "중지":"gray", "탈퇴":"purple", "노출":"blue", "숨김":"gray",
        "휴면대상":"red", "최고관리자":"red", "운영자":"blue",
        "과정운영자":"brown", "소속운영자":"purple",
        "답변완료":"blue", "답변대기":"red",
        "온라인":"sky", "집합":"red", "혼합":"green", "패키지":"brown",
        "승인":"green", "대기":"sky", "거절":"red"
    };
    // jQuery 버전 (기존 코드)
    $(".label").each(function() {
        var v = $(this).html();
        if(colors[v]) $(this).addClass(colors[v]);
    });
    // 또는 vanilla JS
    // document.querySelectorAll(".label").forEach(function(el) {
    //     var v = el.textContent.trim();
    //     if(colors[v]) el.classList.add(colors[v]);
    // });
}
```

---

## CSS 변수 (테마 커스터마이즈)

`admin2.css` 상단 `:root`에서 전체 테마 색상을 한번에 변경 가능:

```css
:root {
    --primary:       #6366f1;   /* 주 색상 (인디고) */
    --primary-hover: #4f46e5;
    --primary-light: #eef2ff;   /* 주 색상 연한 배경 */
    --border:        #f0f0f0;   /* 테두리 색 (연함) */
    --border-dark:   #e0e0e0;   /* 입력 테두리 색 */
    --bg-base:       #f7f7f8;   /* 페이지 배경 */
    --bg-th:         #fafafa;   /* 테이블 헤더 배경 */
    --text-base:     #18181b;   /* 기본 텍스트 (Zinc-900) */
    --text-muted:    #71717a;   /* 보조 텍스트 (Zinc-500) */
    --radius:        12px;      /* 카드 모서리 */
    --radius-sm:     8px;       /* 인풋/버튼 모서리 */
}
```

---

## 탭 (tabs_02)

```html
<div class="tabs_02">
  <ul>
    <li class="current"><a href="?tab=1">기본정보</a></li>
    <li><a href="?tab=2">수강내역</a></li>
    <li><a href="?tab=3">결제내역</a></li>
    <!-- 우측 정렬 버튼 -->
    <li class="tab_right">
      <button class="bttn2 blue">저장</button>
    </li>
  </ul>
</div>
```

---

## 알림 박스 (reminder01)

```html
<div class="reminder01 blue">일반 안내 메시지입니다.</div>
<div class="reminder01 green">처리 완료되었습니다.</div>
<div class="reminder01 yellow">주의가 필요합니다.</div>
<div class="reminder01 red">오류가 발생했습니다.</div>

<!-- 버튼 포함 (more 클릭 가능) -->
<div class="reminder01 yellow more">
    <h1>처리할 항목이 <em>3건</em> 있습니다.</h1>
    <button type="button" class="bttn2 yellow" onclick="...">자세히</button>
</div>
```

---

## 전체 목록 페이지 구조 패턴

```html
<!-- ① 검색 폼 -->
<form name="form1" method="get">
<input type="hidden" name="ord" value="">

<table class="t_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="t_th01">상태</td>
    <td class="t_td01">
      <label><input type="radio" name="s_status" value="" checked> 전체</label>
      <label><input type="radio" name="s_status" value="1"> 정상</label>
    </td>
    <td class="t_th01">검색</td>
    <td class="t_td01">
      <select name="s_field">...</select>
      <input type="text" name="s_keyword">
      <button type="submit" class="bttn2 blue">검색</button>
    </td>
  </tr>
</table>

<!-- ② 액션 바 -->
<table class="a_tb01" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td class="a_th01">
      {{list_total}} &nbsp;
      <select name="s_listnum" onchange="document.forms['form1'].submit();">
        <option value="20">20</option>
        <option value="50">50</option>
      </select> 건씩 보기
    </td>
    <td class="a_td01">
      <button type="button" class="bttn2 blue" onclick="location.href='xxx_insert.jsp'">등록</button>
    </td>
  </tr>
</table>
</form>

{{form_script}}

<!-- ③ 목록 테이블 -->
<form name="form2" method="post">
<table class="l_tb01" cellpadding="0" cellspacing="0">
  <thead>
    <tr align="center">
      <td class="l_th01">No</td>
      <td class="l_th01">이름</td>
      <td class="l_th01">상태</td>
      <td class="l_th01"><input type="checkbox" onclick="AutoCheck('form2', 'idx')"></td>
    </tr>
  </thead>
  <tbody>
    <!--@loop(list)-->
    <tr class="l_tr_{{list.ROW_CLASS}}" align="center">
      <td class="l_td01">{{list.__ord}}</td>
      <td class="l_td01" align="left">
        <span class="crm" _id="{{list.id}}">{{list.name}}</span>
      </td>
      <td class="l_td01"><span class="label">{{list.status_conv}}</span></td>
      <td class="l_td01"><input type="checkbox" name="idx" value="{{list.id}}"></td>
    </tr>
    <!--/loop(list)-->
  </tbody>
</table>

<!-- ④ 데이터 없음 -->
<!--@nif(list)-->
<table class="n_tb01" cellpadding="0" cellspacing="0">
  <tr><td>해당 자료가 없습니다.</td></tr>
</table>
<!--/nif(list)-->

<!-- ⑤ 페이징 -->
<table class="p_tb01" cellpadding="0" cellspacing="0">
  <tr><td class="p_td01">{{pagebar}}</td></tr>
</table>

<script>
ListSort(null, "{{ord}}");
addEvent("onload", function() { setCRM(); setLabel(); });
</script>
</form>
```

---

## 전체 등록/수정 페이지 구조 패턴

```html
<!-- ① 섹션 타이틀 -->
<table class="c_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="c_th01">기본 정보</td>
    <td class="c_td01"></td>
  </tr>
</table>

<!-- ② 폼 -->
<form name="form1" method="post">
<table class="f_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <th class="f_th01">이름 *</th>
    <td class="f_td01"><input type="text" name="name"></td>
    <th class="f_th01">상태</th>
    <td class="f_td01">
      <select name="status">
        <option value="1">정상</option>
        <option value="0">중지</option>
      </select>
    </td>
  </tr>
  <tr>
    <th class="f_th01">내용</th>
    <td class="f_td01" colspan="3">
      <textarea name="content" rows="8" style="width:100%;"></textarea>
    </td>
  </tr>
</table>

<!-- ③ 하단 버튼 -->
<table class="b_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="b_th01"></td>
    <td class="b_td01">
      <button type="submit" class="bttn2 blue">저장</button>
      <button type="button" class="bttn2" onclick="history.back();">목록</button>
    </td>
  </tr>
</table>
</form>

{{form_script}}
```
