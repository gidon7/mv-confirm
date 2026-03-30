# 관리자 페이지 HTML 패턴 가이드

sysop 관리자단 페이지를 만들 때 사용하는 **admin2.css 기반** HTML 패턴 모음.
모든 HTML은 `public_html/sysop/html/{기능}/` 폴더에, JSP는 `public_html/sysop/{기능}/` 폴더에 위치.

> **주의:** Bootstrap 5 클래스(`btn btn-primary`, `form-control`, `col-lg-*` 등)는 sysop 관리자단에서 사용하지 않는다.
> 반드시 admin2.css의 클래스(`bttn2`, `l_tb01`, `f_tb01` 등)를 사용할 것.

---

## 레이아웃 사용법

```jsp
p.setLayout("sysop");           // layout_sysop.html (콘텐츠 영역)
p.setBody("user.user_list");    // html/user/user_list.html
```

> 관리자단 전체 셸은 `layout_admin.html`이 담당하며, 각 콘텐츠 페이지는 iframe 안에서 `layout_sysop.html`로 렌더링된다.

---

## 패턴 1 — 기존 방식 목록 (t_tb01 + l_tb01)

가장 기본적이고 많이 사용되는 패턴. HTML 변경 없이 admin2.css만으로 모던하게 보인다.

```html
<!-- ① 검색 폼 -->
<form name="form1" method="get">
<input type="hidden" name="ord" value="{{ord}}">

<table class="t_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="t_th01">상태</td>
    <td class="t_td01">
      <label><input type="radio" name="s_status" value="" checked> 전체</label>
      <label><input type="radio" name="s_status" value="1"> 정상</label>
      <label><input type="radio" name="s_status" value="0"> 중지</label>
    </td>
    <td class="t_th01">검색</td>
    <td class="t_td01">
      <select name="s_field">
        <option value="name">이름</option>
        <option value="email">이메일</option>
      </select>
      <input type="text" name="s_keyword" value="{{s_keyword}}">
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
      <button type="button" class="bttn2 blue" onclick="location.href='xxx_insert.jsp'">
        <i class="fa fa-plus"></i> 등록
      </button>
    </td>
  </tr>
</table>
</form>

{{form_script}}

<!-- ③ 목록 테이블 -->
<form name="form2" method="post">
<table class="l_tb01" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <td class="l_th01 w30"><input type="checkbox" onclick="AutoCheck('form2','idx')"></td>
      <td class="l_th01 w50">No</td>
      <td class="l_th01"><span class="l_sort01" id="CL_name" onclick="ListSort(this,'{{ord}}')">이름</span></td>
      <td class="l_th01 w80">상태</td>
      <td class="l_th01 w80">관리</td>
    </tr>
  </thead>
  <tbody>
    <!--@loop(list)-->
    <tr class="l_tr_{{list.ROW_CLASS}}">
      <td class="l_td01 tc"><input type="checkbox" name="idx" value="{{list.id}}"></td>
      <td class="l_td01 tc">{{list.__ord}}</td>
      <td class="l_td01">
        <a href="xxx_view.jsp?id={{list.id}}">{{list.name}}</a>
      </td>
      <td class="l_td01 tc"><span class="label">{{list.status_conv}}</span></td>
      <td class="l_td01 tc">
        <a href="xxx_modify.jsp?id={{list.id}}" class="btn_simp blue">수정</a>
      </td>
    </tr>
    <!--/loop(list)-->
  </tbody>
</table>

<!--@nif(list)-->
<table class="n_tb01" cellpadding="0" cellspacing="0">
  <tr><td>해당 자료가 없습니다.</td></tr>
</table>
<!--/nif(list)-->

<table class="p_tb01" cellpadding="0" cellspacing="0">
  <tr><td class="p_td01">{{pagebar}}</td></tr>
</table>

<script>
ListSort(null, "{{ord}}");
addEvent("onload", function() { setLabel(); });
</script>
</form>
```

---

## 패턴 2 — 모던 방식 목록 (filter-bar + action-bar)

기존 패턴의 모던 버전. `admin-modern-guide.md` 참조.

```html
<form name="form1" method="get">
<input type="hidden" name="ord" value="{{ord}}">

<!-- ① 필터 바 (t_tb01 대체) -->
<div class="filter-bar">
  <div class="filter-chips">
    <label class="filter-chip"><input type="radio" name="s_status" value=""> 전체</label>
    <label class="filter-chip"><input type="radio" name="s_status" value="1"> 정상</label>
    <label class="filter-chip"><input type="radio" name="s_status" value="0"> 중지</label>
  </div>
  <div class="filter-search">
    <select name="s_field">
      <option value="name">이름</option>
      <option value="email">이메일</option>
    </select>
    <div class="filter-search-input">
      <i class="fa fa-search"></i>
      <input type="text" name="s_keyword" placeholder="검색어 입력" value="{{s_keyword}}">
    </div>
    <button type="submit" class="bttn2 blue">검색</button>
  </div>
</div>

<!-- ② 액션 바 (a_tb01 대체) -->
<div class="action-bar">
  <div class="action-bar-left">
    <span class="result-count">총 <strong>{{list_total}}</strong>건</span>
    <select name="s_listnum" onchange="document.forms['form1'].submit();">
      <option value="20">20개씩</option>
      <option value="50">50개씩</option>
    </select>
  </div>
  <div class="action-bar-right">
    <button type="button" class="bttn2 blue" onclick="location.href='xxx_insert.jsp'">
      <i class="fa fa-plus"></i> 등록
    </button>
  </div>
</div>
</form>

{{form_script}}

<!-- ③ 강화 테이블 -->
<form name="form2" method="post">
<div class="table-wrap">
<table class="l_tb01" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <th class="l_th01 w30"><input type="checkbox" onclick="AutoCheck('form2','idx')"></th>
      <th class="l_th01 w50">No</th>
      <th class="l_th01"><span class="l_sort01" id="CL_name" onclick="ListSort(this,'{{ord}}')">이름</span></th>
      <th class="l_th01 w80">상태</th>
      <th class="l_th01 w80">관리</th>
    </tr>
  </thead>
  <tbody>
    <!--@loop(list)-->
    <tr>
      <td class="l_td01 tc"><input type="checkbox" name="idx" value="{{list.id}}"></td>
      <td class="l_td01 tc">{{list.__ord}}</td>
      <td class="l_td01">
        <a href="xxx_view.jsp?id={{list.id}}">{{list.name}}</a>
        <span class="sub-text">{{list.email}}</span>
      </td>
      <td class="l_td01 tc"><span class="label">{{list.status_conv}}</span></td>
      <td class="l_td01 tc row-actions">
        <a href="xxx_modify.jsp?id={{list.id}}" class="btn_simp blue">수정</a>
      </td>
    </tr>
    <!--/loop(list)-->
  </tbody>
</table>
</div>

<!--@nif(list)-->
<div class="empty-state">
  <i class="fa fa-inbox"></i>
  <p>해당 자료가 없습니다.</p>
</div>
<!--/nif(list)-->

<table class="p_tb01"><tr><td class="p_td01">{{pagebar}}</td></tr></table>

<script>
ListSort(null, "{{ord}}");
addEvent("onload", function() { setLabel(); initFilterChips(); });
</script>
</form>
```

---

## 패턴 3 — 기존 방식 등록/수정 폼 (c_tb01 + f_tb01)

```html
<form name="form1" method="post" target="sysfrm">
<input type="hidden" name="mode" value="{{mode}}">

<!-- 섹션 타이틀 -->
<table class="c_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="c_th01">기본 정보</td>
    <td class="c_td01"></td>
  </tr>
</table>

<!-- 폼 필드 -->
<table class="f_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <th class="f_th01">이름 *</th>
    <td class="f_td01"><input type="text" name="name" value="{{name}}"></td>
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
      <textarea name="content" rows="8" style="width:100%;">{{content}}</textarea>
    </td>
  </tr>
</table>

<!-- 하단 버튼 -->
<table class="b_tb01" cellpadding="0" cellspacing="0">
  <tr>
    <td class="b_th01"></td>
    <td class="b_td01">
      <button type="submit" class="bttn2 blue"><i class="fa fa-save"></i> 저장</button>
      <button type="button" class="bttn2" onclick="history.back();">목록</button>
    </td>
  </tr>
</table>
</form>

{{form_script}}
```

---

## 패턴 4 — 모던 방식 등록/수정 폼 (form-card)

```html
<form name="form1" method="post" enctype="multipart/form-data" target="sysfrm">
<input type="hidden" name="mode" value="{{mode}}">

<div class="form-card">
  <div class="form-card-header">
    <h3 class="form-card-title"><i class="fa fa-user"></i> 기본 정보</h3>
  </div>
  <div class="form-card-body">
    <table class="f_tb01" cellpadding="0" cellspacing="0">
      <tr>
        <th class="f_th01">이름 <span class="required">*</span></th>
        <td class="f_td01"><input type="text" name="name" value="{{name}}"></td>
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
          <textarea name="content" rows="8" style="width:100%;">{{content}}</textarea>
        </td>
      </tr>
    </table>
  </div>
</div>

<div class="form-bottom">
  <button type="submit" class="bttn2 blue"><i class="fa fa-save"></i> 저장</button>
  <button type="button" class="bttn2" onclick="history.back()">목록</button>
</div>
</form>

{{form_script}}
```

---

## 패턴 5 — 상세 보기

```html
<div class="form-card">
  <div class="form-card-header">
    <h3 class="form-card-title"><i class="fa fa-user"></i> 기본 정보</h3>
    <div class="form-card-header-right">
      <a href="xxx_modify.jsp?id={{id}}" class="bttn2 blue"><i class="fa fa-edit"></i> 수정</a>
      <button type="button" class="bttn2 red" onclick="if(confirm('삭제하시겠습니까?')) location.href='xxx_delete.jsp?id={{id}}'">
        <i class="fa fa-trash"></i> 삭제
      </button>
    </div>
  </div>
  <div class="form-card-body">
    <table class="f_tb01" cellpadding="0" cellspacing="0">
      <tr>
        <th class="f_th01">이름</th>
        <td class="f_td01">{{name}}</td>
        <th class="f_th01">이메일</th>
        <td class="f_td01">{{email}}</td>
      </tr>
      <tr>
        <th class="f_th01">전화번호</th>
        <td class="f_td01">{{phone}}</td>
        <th class="f_th01">가입일</th>
        <td class="f_td01">{{reg_date_format}}</td>
      </tr>
    </table>
  </div>
</div>

<div class="form-bottom">
  <button type="button" class="bttn2" onclick="history.back()">목록</button>
</div>
```

---

## 패턴 6 — 통계 카드 (대시보드)

```html
<div class="stat-grid">
  <div class="stat-card">
    <div class="stat-card-icon blue"><i class="fa fa-users"></i></div>
    <div>
      <div class="stat-card-value">{{total_user}}</div>
      <div class="stat-card-label">전체 회원</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon green"><i class="fa fa-check-circle"></i></div>
    <div>
      <div class="stat-card-value">{{active_user}}</div>
      <div class="stat-card-label">정상 회원</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon orange"><i class="fa fa-clock-o"></i></div>
    <div>
      <div class="stat-card-value">{{today_join}}</div>
      <div class="stat-card-label">오늘 가입</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon red"><i class="fa fa-exclamation-triangle"></i></div>
    <div>
      <div class="stat-card-value">{{stop_user}}</div>
      <div class="stat-card-label">중지 회원</div>
    </div>
  </div>
</div>
```

---

## CSS 클래스 참조 (admin2.css)

### 검색/필터 영역

| 클래스 | 용도 |
|--------|------|
| `.t_tb01` `.t_th01` `.t_td01` | 기존 검색 테이블 (라벨+셀) |
| `.filter-bar` `.filter-chips` `.filter-chip` | 모던 필터 바 + 칩 (t_tb01 대체) |
| `.filter-search` `.filter-search-input` | 검색 인풋 그룹 |
| `.filter-label` `.filter-sep` | 필터 라벨/구분자 |

### 액션/건수 영역

| 클래스 | 용도 |
|--------|------|
| `.a_tb01` `.a_th01` `.a_td01` | 기존 액션 바 테이블 |
| `.action-bar` `.action-bar-left` `.action-bar-right` | 모던 액션 바 (a_tb01 대체) |
| `.result-count` | 건수 표시 |

### 목록 테이블

| 클래스 | 용도 |
|--------|------|
| `.l_tb01` `.l_th01` `.l_td01` | 목록 테이블 (기본) |
| `.table-wrap` | 강화 테이블 래퍼 (border-radius, shadow) |
| `.sub-text` | 셀 내 보조 텍스트 |
| `.row-actions` | hover 시 표시되는 인라인 버튼 영역 |
| `.empty-state` | 데이터 없음 표시 (n_tb01 대체) |
| `.tc` | text-align: center |
| `.text-muted` | 회색 텍스트 |

### 폼/카드 영역

| 클래스 | 용도 |
|--------|------|
| `.c_tb01` `.c_th01` `.c_td01` | 기존 섹션 타이틀 바 |
| `.f_tb01` `.f_th01` `.f_td01` | 폼 필드 테이블 |
| `.b_tb01` `.b_td01` | 기존 하단 버튼 바 |
| `.form-card` `.form-card-header` `.form-card-body` | 모던 카드 폼 (c_tb01+f_tb01 대체) |
| `.form-card-title` `.form-card-header-right` | 카드 제목/우측 버튼 |
| `.form-bottom` | 모던 하단 버튼 영역 (b_tb01 대체) |
| `.required` | 필수 입력 빨간 별표 |

### 버튼

| 클래스 | 용도 |
|--------|------|
| `.bttn2` | 표준 버튼 (흰 배경) |
| `.bttn2.blue` | 파랑 (주요 액션 — 등록/저장) |
| `.bttn2.red` | 빨강 (삭제/경고) |
| `.bttn2.green` | 초록 (승인/완료) |
| `.bttn2.sky` | 하늘 (보조 — 엑셀/일괄등록) |
| `.bttn2.yellow` | 주황 (수정/주의) |
| `.bttn2.purple` | 보라 (특수) |
| `.btn_simp` | 소형 인라인 버튼 (테이블 셀 내) |

### 라벨 (상태 뱃지)

```html
<span class="label blue">정상</span>
<span class="label gray">중지</span>
<span class="label red">탈퇴</span>
<span class="label green">승인</span>
<span class="label sky">대기</span>
<span class="label purple">최고관리자</span>
<span class="label orange">주의</span>
```

> `setLabel()` JS 함수가 텍스트 내용에 따라 자동으로 색상 클래스를 부여한다.

### 알림/리마인더

```html
<div class="reminder01 blue">일반 안내 메시지</div>
<div class="reminder01 green">처리 완료</div>
<div class="reminder01 yellow">주의 필요</div>
<div class="reminder01 red">오류 발생</div>
```

### 탭

```html
<div class="tabs_02">
  <ul>
    <li class="current"><a href="?tab=1">기본정보</a></li>
    <li><a href="?tab=2">수강내역</a></li>
    <li class="tab_right">
      <button class="bttn2 blue">저장</button>
    </li>
  </ul>
</div>
```

### 통계/기타

| 클래스 | 용도 |
|--------|------|
| `.stat-grid` `.stat-card` `.stat-card-icon` | 통계 카드 그리드 |
| `.page-header` `.page-header-title` `.page-header-desc` | 페이지 상단 헤더 |
| `.sticky-footer` | 긴 폼의 하단 고정 버튼 |
| `.toast-container` `.toast-item` | 토스트 알림 |

### 아이콘

Font Awesome 4.x (`fa fa-*`) 사용:

```html
<i class="fa fa-search"></i>    검색
<i class="fa fa-plus"></i>      추가
<i class="fa fa-edit"></i>      수정
<i class="fa fa-trash"></i>     삭제
<i class="fa fa-download"></i>  다운로드
<i class="fa fa-save"></i>      저장
<i class="fa fa-star"></i>      즐겨찾기
<i class="fa fa-users"></i>     회원
<i class="fa fa-inbox"></i>     빈 상태
```
