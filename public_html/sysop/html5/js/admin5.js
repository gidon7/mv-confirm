/* =====================================================
   admin5.js — 관리자단 모던 셸 JavaScript
   ===================================================== */

var Admin5 = (function() {
    'use strict';

    var _currentMid = '';     // 현재 선택된 1depth 메뉴 ID
    var _gnbData = [];        // 1depth 메뉴 데이터
    var _submenuOpen = false;

    // ── 초기화 ──────────────────────────────────────
    function init() {
        loadGnb();
        initLegacySupport();
    }

    // ── GNB (1depth) 로드 ───────────────────────────
    function loadGnb() {
        $.ajax({
            url: '/sysop/main/menu2.jsp',
            data: { mode: 'gnb_json' },
            dataType: 'json',
            success: function(data) {
                _gnbData = data;
                renderGnb(data);
                // 현재 URL 기반으로 활성 메뉴 찾기
                detectActiveMenu();
            },
            error: function() {
                // gnb_json 모드가 없으면 빈 상태로 유지
                // 사용자가 init.jsp에서 별도 처리
            }
        });
    }

    // ── GNB 렌더링 ──────────────────────────────────
    function renderGnb(items) {
        var nav = document.getElementById('icon-nav');
        if (!nav) return;

        var html = '';
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var icon = item.icon || 'fa-folder';
            html += '<a class="icon-nav-item" data-mid="' + item.id + '"'
                 + ' onclick="Admin5.selectGnb(this, \'' + item.id + '\', \'' + escapeHtml(item.name) + '\'); return false;"'
                 + ' href="#">'
                 + '<i class="fa ' + icon + '"></i>'
                 + '<span>' + escapeHtml(item.name) + '</span>'
                 + '</a>';
        }
        html += '<div class="icon-nav-spacer"></div>';
        html += '<a class="icon-nav-item icon-nav-help" href="/sysop/main/help.jsp" target="_blank">'
             + '<i class="fa fa-question-circle"></i><span>Help</span></a>';

        nav.innerHTML = html;
    }

    // ── GNB 선택 (1depth 클릭) ──────────────────────
    function selectGnb(el, mid, name) {
        _currentMid = mid;

        // 활성 표시
        var items = document.querySelectorAll('.icon-nav-item');
        for (var i = 0; i < items.length; i++) {
            items[i].classList.remove('active');
        }
        if (el) el.classList.add('active');

        // 서브메뉴 로드
        loadSubmenu(mid, name);

        // 쿠키 저장
        setCookie('mid', mid, 1);
    }

    // ── 서브메뉴 (2/3depth) 로드 ────────────────────
    function loadSubmenu(mid, gnbName) {
        var panel = document.getElementById('submenu-panel');
        var titleEl = document.getElementById('submenu-title');
        var listEl = document.getElementById('submenu-list');

        if (titleEl) titleEl.textContent = gnbName || '메뉴';
        if (listEl) listEl.innerHTML = '<div style="padding:20px; text-align:center; color:#94a3b8; font-size:12px;">불러오는 중...</div>';

        // 패널 열기
        if (panel) panel.classList.add('open');
        _submenuOpen = true;

        $.ajax({
            url: '/sysop/main/menu2.jsp',
            data: { mode: 'json', mid: mid, t: Date.now() },
            dataType: 'json',
            success: function(data) {
                renderSubmenu(data);
            },
            error: function() {
                if (listEl) listEl.innerHTML = '<div style="padding:20px; text-align:center; color:#94a3b8; font-size:12px;">메뉴를 불러올 수 없습니다.</div>';
            }
        });
    }

    // ── 서브메뉴 렌더링 ─────────────────────────────
    function renderSubmenu(items) {
        var listEl = document.getElementById('submenu-list');
        if (!listEl) return;

        // depth별 그룹화
        var groups = {};
        var groupOrder = [];
        var directItems = []; // depth=2인데 자식이 없는 항목

        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (parseInt(item.depth) === 2) {
                groups[item.id] = { name: item.name, icon: item.icon, link: item.link, children: [] };
                groupOrder.push(item.id);
            }
        }
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (parseInt(item.depth) === 3 && groups[item.parent_id]) {
                groups[item.parent_id].children.push(item);
            }
        }

        var html = '';
        var currentPath = window.location.pathname;

        for (var g = 0; g < groupOrder.length; g++) {
            var gid = groupOrder[g];
            var group = groups[gid];

            if (group.children.length === 0) {
                // 자식 없는 2depth = 직접 링크
                var isActive = group.link && currentPath.indexOf(group.link) >= 0;
                html += '<a href="' + (group.link || '#') + '" class="submenu-item' + (isActive ? ' active' : '') + '">'
                     + escapeHtml(group.name) + '</a>';
            } else {
                // 자식 있는 2depth = 그룹
                html += '<div class="submenu-group">';
                html += '<div class="submenu-group-title">' + escapeHtml(group.name) + '</div>';
                for (var c = 0; c < group.children.length; c++) {
                    var child = group.children[c];
                    var isActive = child.link && currentPath.indexOf(child.link) >= 0;
                    html += '<a href="' + child.link + '" class="submenu-item' + (isActive ? ' active' : '') + '">'
                         + escapeHtml(child.name) + '</a>';
                }
                html += '</div>';
            }
        }

        listEl.innerHTML = html || '<div style="padding:20px; text-align:center; color:#94a3b8; font-size:12px;">하위 메뉴가 없습니다.</div>';
    }

    // ── 서브메뉴 토글 ───────────────────────────────
    function toggleSubmenu() {
        var panel = document.getElementById('submenu-panel');
        if (!panel) return;

        _submenuOpen = !_submenuOpen;
        if (_submenuOpen) {
            panel.classList.add('open');
        } else {
            panel.classList.remove('open');
        }
    }

    // ── 현재 URL 기반 활성 메뉴 탐지 ────────────────
    function detectActiveMenu() {
        // 쿠키에서 마지막 선택된 mid 확인
        var savedMid = getCookie('mid');
        if (savedMid) {
            var el = document.querySelector('.icon-nav-item[data-mid="' + savedMid + '"]');
            if (el) {
                var name = el.querySelector('span') ? el.querySelector('span').textContent : '';
                selectGnb(el, savedMid, name);
                return;
            }
        }

        // 첫 번째 메뉴 자동 선택
        var firstItem = document.querySelector('.icon-nav-item[data-mid]');
        if (firstItem) {
            var mid = firstItem.getAttribute('data-mid');
            var name = firstItem.querySelector('span') ? firstItem.querySelector('span').textContent : '';
            selectGnb(firstItem, mid, name);
        }
    }

    // ── 레거시 지원 ─────────────────────────────────
    function initLegacySupport() {
        // 기존 HTML에서 사용하는 함수들 전역 등록

        // ListSort 호환
        if (typeof window.ListSort === 'undefined') {
            window.ListSort = function(el, ord) {
                if (!el) return;
                // 기존 정렬 로직 유지
            };
        }

        // setLabel 호환 (상태 배지 자동 색상)
        if (typeof window.setLabel === 'undefined') {
            window.setLabel = function() {
                var colors = {
                    "정상":"blue", "중지":"gray", "탈퇴":"purple", "노출":"blue", "숨김":"gray",
                    "휴면대상":"red", "최고관리자":"red", "운영자":"blue",
                    "과정운영자":"brown", "소속운영자":"purple",
                    "답변완료":"blue", "답변대기":"red",
                    "온라인":"sky", "집합":"red", "혼합":"green", "패키지":"brown",
                    "승인":"green", "대기":"sky", "거절":"red",
                    "활성":"green", "비활성":"gray", "완료":"green"
                };
                document.querySelectorAll('.label').forEach(function(el) {
                    var v = el.textContent.trim();
                    if (colors[v]) el.classList.add(colors[v]);
                });
            };
        }

        // AutoCheck 호환
        if (typeof window.AutoCheck === 'undefined') {
            window.AutoCheck = function(formName, chkName) {
                var form = document.forms[formName];
                if (!form) return;
                var chks = form.querySelectorAll('input[name="' + chkName + '"]');
                var allChecked = true;
                chks.forEach(function(c) { if (!c.checked) allChecked = false; });
                chks.forEach(function(c) { c.checked = !allChecked; });
            };
        }

        // initFilterChips 호환 (:has() 미지원 브라우저)
        if (typeof window.initFilterChips === 'undefined') {
            window.initFilterChips = function() {
                document.querySelectorAll('.t_td01 label input, .filter-chip input').forEach(function(input) {
                    if (input.checked) {
                        input.closest('label') && input.closest('label').classList.add('chip-active');
                        input.closest('.filter-chip') && input.closest('.filter-chip').classList.add('active');
                    }
                    input.addEventListener('change', function() {
                        var name = this.name;
                        document.querySelectorAll('input[name="' + name + '"]').forEach(function(i) {
                            var parent = i.closest('label') || i.closest('.filter-chip');
                            if (parent) parent.classList.remove('chip-active', 'active');
                        });
                        if (this.checked) {
                            var parent = this.closest('label') || this.closest('.filter-chip');
                            if (parent) parent.classList.add('chip-active', 'active');
                        }
                    });
                });
            };
        }

        // 페이지 로드 시 레거시 함수 실행
        $(function() {
            if (typeof setLabel === 'function') setLabel();
            if (typeof initFilterChips === 'function') initFilterChips();
            initFilterCompact();
        });
    }

    // ── 필터 → 컴팩트바 + 모달 자동 변환 ─────────
    // .filter-panel (신규) 및 .t_tb01 (레거시) 모두 자동 처리
    function initFilterCompact() {
        // 대상 찾기: .filter-panel 또는 첫 번째 .t_tb01 (대시보드 내부 제외)
        var panel = document.querySelector('.filter-panel');
        if (!panel) {
            var tables = document.querySelectorAll('.t_tb01');
            for (var i = 0; i < tables.length; i++) {
                // 대시보드(#dashboard01) 내부는 제외
                if (!tables[i].closest('#dashboard01')) { panel = tables[i]; break; }
            }
        }
        if (!panel) return;

        var form = panel.closest('form');
        if (!form) return;

        // 기존 키워드 input 찾기 (form 전체에서)
        var kwInput = form.querySelector('input[name="s_keyword"]');
        var kwValue = kwInput ? kwInput.value : '';

        // 기존 submit 버튼 찾기
        var submitBtn = panel.querySelector('button[type="submit"]')
                     || panel.querySelector('.bttn2.blue')
                     || panel.querySelector('.btn-primary');

        // 활성 필터 개수 세기
        function countActive() {
            var cnt = 0;
            panel.querySelectorAll('input[type=radio]:checked, input[type=checkbox]:checked').forEach(function(el) {
                if (el.value) cnt++;
            });
            panel.querySelectorAll('select[name^="s_"]').forEach(function(el) {
                if (el.value) cnt++;
            });
            if (kwValue) cnt++;
            return cnt;
        }

        // ① 컴팩트 바 생성
        var compact = document.createElement('div');
        compact.className = 'filter-compact';
        compact.innerHTML =
            '<button type="button" class="filter-compact-toggle" id="_fcToggle">'
          +   '<i class="fa fa-sliders"></i>'
          + '</button>'
          + '<div class="search-input-wrap" style="flex:1;">'
          +   '<i class="fa fa-search"></i>'
          +   '<input type="text" name="_fc_keyword" placeholder="검색어를 입력해 주세요" value="' + escapeHtml(kwValue) + '" style="width:100%;">'
          + '</div>'
          + '<button type="submit" class="filter-compact-search"><i class="fa fa-search"></i></button>';

        // ② 배경 딤
        var backdrop = document.createElement('div');
        backdrop.className = 'filter-modal-backdrop';
        backdrop.id = '_fcBackdrop';

        // ③ 모달
        var modal = document.createElement('div');
        modal.className = 'filter-modal';
        modal.id = '_fcModal';

        var cnt = countActive();
        var badge = cnt > 0 ? '<span class="filter-modal-badge">' + cnt + '</span>' : '';

        modal.innerHTML =
            '<div class="filter-modal-header">'
          +   '<h3>상세 검색 ' + badge + '</h3>'
          +   '<button type="button" id="_fcClose"><i class="fa fa-times"></i></button>'
          + '</div>'
          + '<div class="filter-modal-body"></div>'
          + '<div class="filter-modal-footer">'
          +   '<button type="submit" class="btn btn-primary btn-lg" style="min-width:180px;"><i class="fa fa-search"></i> 검색</button>'
          + '</div>';

        // 기존 패널 내용을 모달 body로 이동
        var modalBody = modal.querySelector('.filter-modal-body');
        while (panel.firstChild) {
            modalBody.appendChild(panel.firstChild);
        }

        // 모달 안의 기존 submit 버튼 숨김
        if (submitBtn) submitBtn.style.display = 'none';

        // 기존 panel 숨기고 컴팩트바/모달 삽입
        panel.style.display = 'none';
        panel.parentNode.insertBefore(compact, panel);
        document.body.appendChild(backdrop);
        document.body.appendChild(modal);

        // 토글 이벤트
        function openModal() {
            modal.classList.add('open');
            backdrop.classList.add('open');
        }
        function closeModal() {
            modal.classList.remove('open');
            backdrop.classList.remove('open');
        }

        document.getElementById('_fcToggle').addEventListener('click', function() {
            modal.classList.contains('open') ? closeModal() : openModal();
        });
        document.getElementById('_fcClose').addEventListener('click', closeModal);
        backdrop.addEventListener('click', closeModal);

        // submit 시 키워드 동기화
        form.addEventListener('submit', function() {
            var compactKw = compact.querySelector('input[name="_fc_keyword"]');
            if (kwInput && compactKw && compactKw.value && !modal.classList.contains('open')) {
                kwInput.value = compactKw.value;
            }
        });

        // 활성 필터 뱃지
        if (cnt > 0) {
            var toggleBtn = document.getElementById('_fcToggle');
            var b = document.createElement('span');
            b.className = 'filter-compact-badge';
            b.textContent = cnt;
            toggleBtn.appendChild(b);
        }
    }

    // ── Toast 알림 ──────────────────────────────────
    function showToast(message, type) {
        type = type || '';
        var container = document.getElementById('toast-container');
        if (!container) return;

        var toast = document.createElement('div');
        toast.className = 'toast ' + type;
        toast.innerHTML = '<span>' + message + '</span>';
        container.appendChild(toast);

        setTimeout(function() {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(12px)';
            toast.style.transition = 'all 0.3s ease';
            setTimeout(function() { toast.remove(); }, 300);
        }, 3000);
    }

    // ── 유틸리티 ────────────────────────────────────
    function escapeHtml(str) {
        if (!str) return '';
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function setCookie(name, value, days) {
        var d = new Date();
        d.setTime(d.getTime() + (days * 86400000));
        document.cookie = name + '=' + encodeURIComponent(value) + ';expires=' + d.toUTCString() + ';path=/';
    }

    function getCookie(name) {
        var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return match ? decodeURIComponent(match[2]) : '';
    }

    // ── Public API ──────────────────────────────────
    return {
        init: init,
        selectGnb: selectGnb,
        toggleSubmenu: toggleSubmenu,
        showToast: showToast,
        loadGnb: loadGnb,
        loadSubmenu: loadSubmenu
    };

})();
