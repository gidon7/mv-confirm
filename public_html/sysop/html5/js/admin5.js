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
        });
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
