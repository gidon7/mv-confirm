# 관리자단 모던 리뉴얼 가이드 (UI 구조 변경)

> **기존 admin2-guide.md와의 차이**
> admin2.css 교체는 "색만 바꾼" 수준. 이 가이드는 검색표 → 필터바, 테이블 → 카드/강화테이블 등
> **HTML 구조 자체를 바꾸는 실질적 리뉴얼 패턴**을 다룬다.
> 단, 맑은프레임워크 템플릿 문법(`{{변수}}`, `<!--@loop-->`)은 그대로 유지.

---

## 핵심 철학

| 구분 | 기존 방식 | 모던 방식 |
|------|----------|---------|
| 검색 | `t_tb01` 테이블 (라벨+셀 격자) | `.filter-bar` 인라인 필터 + 칩 |
| 목록 | `l_tb01` 일반 테이블 | 강화 테이블 (sticky header, row action) |
| 폼 | `f_tb01` + `c_tb01` 섹션 | `.card` 기반 섹션 |
| 통계 | 없음 / 텍스트 | `.stat-card` 그리드 |
| 상태 표시 | `.label` 뱃지 | `.label` 유지 + 행 강조 |
| 액션 | 상단 버튼만 | 행 인라인 액션 버튼 |

---

## 1. 필터 바 (Filter Bar) — t_tb01 대체

### 기존 (t_tb01)
```html
<table class="t_tb01">
  <tr>
    <td class="t_th01">상태</td>
    <td class="t_td01">
      <select name="s_status">...</select>
    </td>
    <td class="t_th01">검색</td>
    <td class="t_td01">
      <input type="text" name="s_keyword">
      <button class="bttn2 blue">검색</button>
    </td>
  </tr>
</table>
```

### 신규 (.filter-bar)
```html
<div class="filter-bar">
  <!-- 왼쪽: 필터 칩 그룹 -->
  <div class="filter-chips">
    <label class="filter-chip">
      <input type="radio" name="s_status" value=""> 전체
    </label>
    <label class="filter-chip">
      <input type="radio" name="s_status" value="1"> 정상
    </label>
    <label class="filter-chip">
      <input type="radio" name="s_status" value="0"> 중지
    </label>
  </div>

  <!-- 오른쪽: 검색 인풋 -->
  <div class="filter-search">
    <select name="s_field">
      <option value="name">이름</option>
      <option value="email">이메일</option>
    </select>
    <div class="filter-search-input">
      <i class="fa fa-search"></i>
      <input type="text" name="s_keyword" placeholder="검색어 입력">
    </div>
    <button type="submit" class="bttn2 blue">검색</button>
    <button type="button" class="bttn2" onclick="resetFilter()">초기화</button>
  </div>
</div>
```

### 드롭다운 필터가 많을 때
```html
<div class="filter-bar filter-bar-multi">
  <div class="filter-row">
    <span class="filter-label">구분</span>
    <select name="s_kind"><option value="">전체</option>...</select>

    <span class="filter-label">기간</span>
    <input type="text" name="s_date_from" class="datepicker" placeholder="시작일">
    <span class="filter-sep">~</span>
    <input type="text" name="s_date_to" class="datepicker" placeholder="종료일">

    <span class="filter-label">검색</span>
    <select name="s_field">...</select>
    <div class="filter-search-input">
      <i class="fa fa-search"></i>
      <input type="text" name="s_keyword" placeholder="검색어">
    </div>
    <button type="submit" class="bttn2 blue"><i class="fa fa-search"></i> 검색</button>
  </div>
</div>
```

---

## 2. 액션 바 (Action Bar) — a_tb01 강화

### 기존 (a_tb01 테이블)
```html
<table class="a_tb01">
  <tr>
    <td class="a_th01">{{list_total}}</td>
    <td class="a_td01"><button class="bttn2 blue">등록</button></td>
  </tr>
</table>
```

### 신규 (.action-bar)
```html
<div class="action-bar">
  <div class="action-bar-left">
    <span class="result-count">총 <strong>{{list_total}}</strong>건</span>
    <select name="s_listnum" onchange="document.forms['form1'].submit();">
      <option value="20">20개씩</option>
      <option value="50">50개씩</option>
      <option value="100">100개씩</option>
    </select>
  </div>
  <div class="action-bar-right">
    <button type="button" class="bttn2" onclick="excelDown()">
      <i class="fa fa-download"></i> 엑셀
    </button>
    <button type="button" class="bttn2 red" onclick="delSelected()">
      <i class="fa fa-trash"></i> 선택삭제
    </button>
    <button type="button" class="bttn2 blue" onclick="location.href='xxx_insert.jsp'">
      <i class="fa fa-plus"></i> 등록
    </button>
  </div>
</div>
```

---

## 3. 강화 테이블 — l_tb01 유지 + 행 액션

테이블 클래스는 유지하되 행 내 인라인 액션과 hover 효과를 강화한다.

```html
<div class="table-wrap">
<table class="l_tb01" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <th class="l_th01 w30"><input type="checkbox" onclick="AutoCheck('form2','idx')"></th>
      <th class="l_th01 w50">No</th>
      <th class="l_th01">이름</th>
      <th class="l_th01 w100">연락처</th>
      <th class="l_th01 w80">상태</th>
      <th class="l_th01 w60">가입일</th>
      <th class="l_th01 w80">관리</th>   <!-- 신규: 인라인 액션 컬럼 -->
    </tr>
  </thead>
  <tbody>
    <!--@loop(list)-->
    <tr>
      <td class="l_td01 tc"><input type="checkbox" name="idx" value="{{list.id}}"></td>
      <td class="l_td01 tc">{{list.__ord}}</td>
      <td class="l_td01">
        <a href="user_view.jsp?id={{list.id}}">{{list.user_nm}}</a>
        <span class="sub-text">{{list.login_id}}</span>
      </td>
      <td class="l_td01 tc">{{list.mobile_conv}}</td>
      <td class="l_td01 tc"><span class="label">{{list.status_conv}}</span></td>
      <td class="l_td01 tc text-muted">{{list.reg_date_conv}}</td>
      <td class="l_td01 tc row-actions">
        <a href="user_view.jsp?id={{list.id}}" class="btn_simp">보기</a>
        <a href="user_modify.jsp?id={{list.id}}" class="btn_simp blue">수정</a>
      </td>
    </tr>
    <!--/loop(list)-->
  </tbody>
</table>
</div>

<!--@nif(list)-->
<div class="empty-state">
  <i class="fa fa-inbox"></i>
  <p>데이터가 없습니다.</p>
</div>
<!--/nif(list)-->
```

---

## 4. 카드 폼 — c_tb01 + f_tb01 대체

### 기존 방식
```html
<table class="c_tb01"><tr><td class="c_th01">기본정보</td></tr></table>
<table class="f_tb01">...</table>
```

### 신규 (.form-card)
```html
<div class="form-card">
  <div class="form-card-header">
    <h3 class="form-card-title"><i class="fa fa-user"></i> 기본 정보</h3>
    <div class="form-card-header-right">
      <!-- 우측 버튼이 필요할 때 -->
      <button type="button" class="bttn2 blue">저장</button>
    </div>
  </div>
  <div class="form-card-body">
    <table class="f_tb01" cellpadding="0" cellspacing="0">
      <tr>
        <th class="f_th01">이름 <span class="required">*</span></th>
        <td class="f_td01"><input type="text" name="name"></td>
        <th class="f_th01">이메일 <span class="required">*</span></th>
        <td class="f_td01"><input type="email" name="email"></td>
      </tr>
    </table>
  </div>
</div>
```

### 섹션이 여러 개일 때
```html
<div class="form-card">
  <div class="form-card-header">
    <h3 class="form-card-title">기본 정보</h3>
  </div>
  <div class="form-card-body">...</div>
</div>

<div class="form-card">
  <div class="form-card-header">
    <h3 class="form-card-title">추가 정보</h3>
  </div>
  <div class="form-card-body">...</div>
</div>

<!-- 하단 버튼은 카드 밖에 독립 배치 -->
<div class="form-bottom">
  <button type="submit" class="bttn2 blue"><i class="fa fa-save"></i> 저장</button>
  <button type="button" class="bttn2" onclick="history.back()">목록</button>
</div>
```

---

## 5. 통계 카드 (Stat Card) — 대시보드/상단 요약

```html
<div class="stat-grid">
  <div class="stat-card">
    <div class="stat-card-icon blue"><i class="fa fa-users"></i></div>
    <div class="stat-card-body">
      <div class="stat-card-value">{{total_user}}</div>
      <div class="stat-card-label">전체 회원</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon green"><i class="fa fa-check-circle"></i></div>
    <div class="stat-card-body">
      <div class="stat-card-value">{{active_user}}</div>
      <div class="stat-card-label">정상 회원</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon orange"><i class="fa fa-clock-o"></i></div>
    <div class="stat-card-body">
      <div class="stat-card-value">{{today_join}}</div>
      <div class="stat-card-label">오늘 가입</div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-card-icon red"><i class="fa fa-exclamation-triangle"></i></div>
    <div class="stat-card-body">
      <div class="stat-card-value">{{stop_user}}</div>
      <div class="stat-card-label">중지 회원</div>
    </div>
  </div>
</div>
```

---

## 6. 전체 목록 페이지 완성 패턴

```html
<!-- ① 필터 폼 -->
<form name="form1" method="get">
<input type="hidden" name="ord" value="{{ord}}">

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

<!-- ② 액션 바 -->
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

<!-- ③ 목록 -->
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
      </td>
      <td class="l_td01 tc"><span class="label">{{list.status_conv}}</span></td>
      <td class="l_td01 tc row-actions">
        <a href="xxx_modify.jsp?id={{list.id}}" class="btn_simp">수정</a>
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

## 7. 전체 등록/수정 페이지 완성 패턴

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

## 8. 신규 CSS 클래스 (admin2.css에 추가)

아래 CSS를 `admin2.css` 하단에 추가한다.

```css
/* =====================================================
   Filter Bar (필터 바)
   ===================================================== */
.filter-bar {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
    padding: 12px 14px;
    background: var(--bg-white);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    margin-bottom: 8px;
    box-shadow: var(--shadow-sm);
}
.filter-bar-multi .filter-row {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
    width: 100%;
}
.filter-label {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-muted);
    white-space: nowrap;
    padding: 0 4px;
}
.filter-sep { color: var(--text-light); padding: 0 2px; }

/* 필터 칩 (라디오/체크박스 버튼화) */
.filter-chips { display: flex; gap: 4px; flex-wrap: wrap; }
.filter-chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 10px;
    border: 1px solid var(--border-dark);
    border-radius: 20px;
    font-size: 12px;
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.15s;
    white-space: nowrap;
    background: #fff;
}
.filter-chip:hover { border-color: var(--primary); color: var(--primary); }
.filter-chip input[type=radio],
.filter-chip input[type=checkbox] { display: none; }
.filter-chip:has(input:checked) {
    background: var(--primary);
    border-color: var(--primary);
    color: #fff;
    font-weight: 600;
}
/* :has() 미지원 브라우저용 — JS로 .active 클래스 추가 */
.filter-chip.active {
    background: var(--primary);
    border-color: var(--primary);
    color: #fff;
    font-weight: 600;
}

/* 검색 인풋 그룹 */
.filter-search { display: flex; align-items: center; gap: 6px; margin-left: auto; flex-wrap: wrap; }
.filter-search-input {
    position: relative;
    display: inline-flex;
    align-items: center;
}
.filter-search-input i {
    position: absolute;
    left: 8px;
    color: var(--text-light);
    font-size: 13px;
    pointer-events: none;
}
.filter-search-input input[type=text] {
    padding-left: 28px;
    width: 200px;
}

/* =====================================================
   Action Bar (액션 바)
   ===================================================== */
.action-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 6px 0;
    margin-bottom: 6px;
    gap: 8px;
}
.action-bar-left  { display: flex; align-items: center; gap: 8px; }
.action-bar-right { display: flex; align-items: center; gap: 6px; }
.result-count { font-size: 13px; color: var(--text-muted); }
.result-count strong { color: var(--primary); font-weight: 700; }

/* =====================================================
   Table Wrap + 강화 테이블
   ===================================================== */
.table-wrap {
    border-radius: var(--radius);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    margin-bottom: 0;
}
.table-wrap .l_tb01 { margin-top: 0; border-radius: 0; box-shadow: none; }

/* 행 내 서브텍스트 */
.sub-text { display: block; font-size: 11px; color: var(--text-light); margin-top: 1px; }
.text-muted { color: var(--text-muted) !important; }
.tc { text-align: center !important; }

/* 인라인 행 액션 버튼 (hover 시 표시) */
.row-actions { white-space: nowrap; }
.row-actions .btn_simp { opacity: 0; transition: opacity 0.15s; }
.l_tb01 tbody tr:hover .row-actions .btn_simp { opacity: 1; }

/* Empty State (데이터 없음) */
.empty-state {
    text-align: center;
    padding: 48px 16px;
    color: var(--text-light);
    background: var(--bg-white);
    border: 1px solid var(--border);
    border-top: none;
}
.empty-state i { font-size: 32px; display: block; margin-bottom: 12px; }
.empty-state p { font-size: 13px; margin: 0; }

/* =====================================================
   Form Card (카드 폼)
   ===================================================== */
.form-card {
    background: var(--bg-white);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    box-shadow: var(--shadow-sm);
    margin-bottom: 12px;
    overflow: hidden;
}
.form-card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 16px;
    background: var(--bg-th);
    border-bottom: 2px solid var(--primary);
}
.form-card-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text-base);
    margin: 0;
    display: flex;
    align-items: center;
    gap: 6px;
}
.form-card-title i { color: var(--primary); }
.form-card-header-right { display: flex; gap: 6px; }
.form-card-body { padding: 0; }
.form-card-body .f_tb01 { margin-bottom: 0; }

/* 하단 버튼 영역 */
.form-bottom {
    display: flex;
    justify-content: flex-end;
    gap: 6px;
    padding: 12px 0;
    margin-top: 4px;
}

/* 필수 입력 표시 */
.required { color: var(--danger); font-weight: 700; margin-left: 2px; }

/* =====================================================
   Stat Card (통계 카드)
   ===================================================== */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 10px;
    margin-bottom: 16px;
}
.stat-card {
    background: var(--bg-white);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    box-shadow: var(--shadow-sm);
    transition: box-shadow 0.15s;
}
.stat-card:hover { box-shadow: var(--shadow); }
.stat-card-icon {
    width: 40px;
    height: 40px;
    border-radius: var(--radius);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    flex-shrink: 0;
}
.stat-card-icon.blue   { background: var(--primary-light); color: var(--primary); }
.stat-card-icon.green  { background: var(--success-light);  color: var(--success); }
.stat-card-icon.red    { background: var(--danger-light);   color: var(--danger); }
.stat-card-icon.orange { background: var(--warning-light);  color: var(--warning); }
.stat-card-icon.purple { background: #f3e8ff; color: #7c3aed; }
.stat-card-value {
    font-size: 22px;
    font-weight: 700;
    color: var(--text-base);
    line-height: 1.2;
}
.stat-card-label {
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 2px;
}
```

---

## 9. 필터 칩 JS 헬퍼

`:has()` CSS 선택자를 지원하지 않는 구형 브라우저 대응:

```js
function initFilterChips() {
    document.querySelectorAll('.filter-chip input').forEach(function(input) {
        // 초기 상태 반영
        if(input.checked) input.closest('.filter-chip').classList.add('active');

        input.addEventListener('change', function() {
            var name = this.name;
            // 같은 name 그룹 전체 active 해제
            document.querySelectorAll('.filter-chip input[name="' + name + '"]').forEach(function(i) {
                i.closest('.filter-chip').classList.remove('active');
            });
            if(this.checked) this.closest('.filter-chip').classList.add('active');
        });
    });
}
```

---

## 10. 마이그레이션 우선순위

| 우선순위 | 대상 | 변경 내용 |
|---------|------|---------|
| ★★★ | 자주 쓰는 목록 페이지 | filter-bar + action-bar + empty-state |
| ★★☆ | 등록/수정 폼 | form-card 래핑 |
| ★☆☆ | 대시보드/통계 | stat-card 그리드 |
| ─ | CRM 탭 내부 | 동일 패턴 적용 |

> **실용 팁:** 한 페이지씩 점진적으로 교체한다.
> `t_tb01` → `filter-bar`, `a_tb01` 테이블 → `action-bar div` 순으로 교체하면
> 기존 로직(`form.submit()`, `ListSort()` 등) 변경 없이 UI만 바뀐다.
