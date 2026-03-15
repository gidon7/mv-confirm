# 관리자 페이지 HTML 패턴 가이드

관리자단 페이지를 만들 때 사용하는 Bootstrap 5 기반 HTML 패턴 모음.
모든 HTML은 `public_html/html/admin/` 폴더에, JSP는 `public_html/admin/` 폴더에 위치.

---

## 레이아웃 사용법

```jsp
p.setLayout("admin");        // layout_admin.html
p.setBody("admin.파일명");   // html/admin/파일명.html
```

---

## 패턴 1 — 목록 + 검색 (가장 많이 사용)

**파일:** `html/admin/xxx_list.html`

```html
<!-- 페이지 헤더 -->
<div class="d-flex align-items-center mb-4">
    <div>
        <div class="page-title">{{page_title}}</div>
        <div class="page-subtitle">총 {{total_count}}건</div>
    </div>
    <a href="xxx_write.jsp" class="btn btn-primary ms-auto">
        <i class="bi bi-plus-lg me-1"></i>등록
    </a>
</div>

<!-- 검색 바 -->
<div class="admin-card mb-3">
    <div class="p-3">
        <form method="get" class="row g-2 align-items-end">
            <div class="col-sm-3">
                <label class="form-label form-label-sm">검색 조건</label>
                <select name="search_type" class="form-select form-select-sm">
                    <option value="name">이름</option>
                    <option value="email">이메일</option>
                </select>
            </div>
            <div class="col-sm-4">
                <label class="form-label form-label-sm">검색어</label>
                <input type="text" name="keyword" class="form-control form-control-sm"
                       value="{{keyword}}" placeholder="검색어를 입력하세요">
            </div>
            <div class="col-sm-2">
                <label class="form-label form-label-sm">상태</label>
                <select name="status" class="form-select form-select-sm">
                    <option value="">전체</option>
                    <option value="1">활성</option>
                    <option value="0">비활성</option>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary btn-sm">
                    <i class="bi bi-search me-1"></i>검색
                </button>
                <a href="?" class="btn btn-outline-secondary btn-sm ms-1">초기화</a>
            </div>
        </form>
    </div>
</div>

<!-- 목록 테이블 -->
<div class="admin-card">
    <table class="table admin-table">
        <thead>
            <tr>
                <th style="width:60px">번호</th>
                <th>이름</th>
                <th>이메일</th>
                <th style="width:100px">상태</th>
                <th style="width:130px">가입일</th>
                <th style="width:100px">관리</th>
            </tr>
        </thead>
        <tbody>
            <!--@loop(list)-->
            <tr>
                <td class="text-muted">{{list.rownum}}</td>
                <td class="fw-medium">{{list.name}}</td>
                <td class="text-muted">{{list.email}}</td>
                <td>
                    <!--@if(list.is_active)-->
                    <span class="status-badge" style="background:#d1e7dd; color:#0a5c3a;">활성</span>
                    <!--/if(list.is_active)-->
                    <!--@nif(list.is_active)-->
                    <span class="status-badge" style="background:#f8d7da; color:#842029;">비활성</span>
                    <!--/nif(list.is_active)-->
                </td>
                <td class="text-muted">{{list.reg_date_format}}</td>
                <td>
                    <a href="xxx_view.jsp?id={{list.id}}" class="btn btn-sm btn-outline-primary">보기</a>
                </td>
            </tr>
            <!--/loop(list)-->
        </tbody>
    </table>

    <!-- 데이터 없음 -->
    <!--@nif(has_list)-->
    <div class="text-center text-muted py-5">
        <i class="bi bi-inbox" style="font-size:2rem; display:block; margin-bottom:0.5rem;"></i>
        데이터가 없습니다.
    </div>
    <!--/nif(has_list)-->

    <!-- 페이징 -->
    <!--@if(has_list)-->
    <div class="d-flex justify-content-center py-3">
        {{paging}}
    </div>
    <!--/if(has_list)-->
</div>
```

**JSP 예시:**
```jsp
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

String keyword  = m.rs("keyword");
String status   = m.rs("status");
int page        = m.ri("page");
if(page < 1) page = 1;

XxxDao xxx = new XxxDao();
xxx.addSearch("name", keyword, "like");
if(!status.isEmpty()) xxx.addWhere("status = '" + status + "'");
xxx.setOrderBy("id DESC");

DataSet list = xxx.find();
// rownum, reg_date_format 등 가공은 while 루프로 처리

p.setLayout("admin");
p.setBody("admin.xxx_list");
p.setVar("title", "XXX 관리");
p.setVar("page_title", "XXX 관리");
p.setVar("keyword", keyword);
p.setVar("has_list", list.size() > 0);
p.setLoop("list", list);
p.display();

%>
```

---

## 패턴 2 — 등록 / 수정 폼

**파일:** `html/admin/xxx_write.html`

```html
<!-- 페이지 헤더 -->
<div class="d-flex align-items-center mb-4">
    <div>
        <div class="page-title">{{page_title}}</div>
    </div>
    <a href="xxx_list.jsp" class="btn btn-outline-secondary ms-auto">
        <i class="bi bi-arrow-left me-1"></i>목록으로
    </a>
</div>

<div class="row">
    <div class="col-lg-8">
        <div class="admin-card">
            <div class="admin-card-header">
                <i class="bi bi-pencil-square text-primary"></i>
                <h6 class="admin-card-title">기본 정보</h6>
            </div>
            <div class="p-4">
                <form name="form1" method="post" data-ajax="true" data-redirect="xxx_list.jsp">

                    <div class="mb-3">
                        <label class="form-label fw-medium">이름 <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control" value="{{name}}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium">이메일 <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control" value="{{email}}">
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-medium">상태</label>
                        <select name="status" class="form-select">
                            <option value="1">활성</option>
                            <option value="0">비활성</option>
                        </select>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">저장</button>
                        <a href="xxx_list.jsp" class="btn btn-outline-secondary">취소</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- 우측 사이드 패널 (선택사항) -->
    <div class="col-lg-4">
        <div class="admin-card">
            <div class="admin-card-header">
                <i class="bi bi-info-circle text-muted"></i>
                <h6 class="admin-card-title">메모</h6>
            </div>
            <div class="p-3">
                <p class="text-muted small mb-0">추가 정보나 안내 메시지를 여기에 작성합니다.</p>
            </div>
        </div>
    </div>
</div>

{{form_script}}
```

---

## 패턴 3 — 상세 보기

**파일:** `html/admin/xxx_view.html`

```html
<div class="d-flex align-items-center mb-4">
    <div class="page-title">상세 보기</div>
    <div class="ms-auto d-flex gap-2">
        <a href="xxx_modify.jsp?id={{id}}" class="btn btn-primary btn-sm">수정</a>
        <button type="button" class="btn btn-danger btn-sm"
                onclick="if(confirm('삭제하시겠습니까?')) location.href='xxx_delete.jsp?id={{id}}'">삭제</button>
        <a href="xxx_list.jsp" class="btn btn-outline-secondary btn-sm">목록</a>
    </div>
</div>

<div class="admin-card">
    <div class="admin-card-header">
        <i class="bi bi-person text-primary"></i>
        <h6 class="admin-card-title">기본 정보</h6>
    </div>
    <div class="p-0">
        <table class="table mb-0" style="font-size:0.875rem;">
            <colgroup>
                <col style="width:160px">
                <col>
            </colgroup>
            <tbody>
                <tr>
                    <th class="ps-4 py-3 text-muted fw-medium bg-light">이름</th>
                    <td class="py-3">{{name}}</td>
                </tr>
                <tr>
                    <th class="ps-4 py-3 text-muted fw-medium bg-light">이메일</th>
                    <td class="py-3">{{email}}</td>
                </tr>
                <tr>
                    <th class="ps-4 py-3 text-muted fw-medium bg-light">전화번호</th>
                    <td class="py-3">{{phone}}</td>
                </tr>
                <tr>
                    <th class="ps-4 py-3 text-muted fw-medium bg-light">가입일</th>
                    <td class="py-3 text-muted">{{reg_date_format}}</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
```

---

## CSS 클래스 참조 (layout_admin.html 정의)

| 클래스 | 용도 |
|---|---|
| `.admin-card` | 흰 카드 컨테이너 (border + radius) |
| `.admin-card-header` | 카드 상단 헤더 영역 |
| `.admin-card-title` | 카드 제목 텍스트 |
| `.admin-table` | 관리자용 테이블 스타일 |
| `.stat-card` | 통계 카드 (대시보드용) |
| `.stat-icon` | 통계 아이콘 박스 |
| `.status-badge` | 상태 뱃지 (색상은 인라인으로 직접 지정) |
| `.page-title` | 페이지 제목 (큰 텍스트) |
| `.page-subtitle` | 페이지 부제목 (회색 작은 텍스트) |
| `.content-wrap` | 본문 패딩 영역 (레이아웃 자동 적용) |

---

## 상태 뱃지 색상 예시

```html
<!-- 활성 / 승인 -->
<span class="status-badge" style="background:#d1e7dd; color:#0a5c3a;">활성</span>

<!-- 대기 / 검토중 -->
<span class="status-badge" style="background:#fff3cd; color:#856404;">대기</span>

<!-- 비활성 / 거절 -->
<span class="status-badge" style="background:#f8d7da; color:#842029;">비활성</span>

<!-- 일반 정보 -->
<span class="status-badge" style="background:#e8f0fe; color:#0d6efd;">정보</span>
```
