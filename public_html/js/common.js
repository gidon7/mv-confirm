// 맑은프레임워크 공통 JavaScript

// 페이지 로드 시 실행
document.addEventListener('DOMContentLoaded', function() {
    // 현재 페이지 네비게이션 활성화
    highlightCurrentNav();

    // 테이블 행 클릭 이벤트
    initTableRowClick();

    // AJAX 폼 처리
    initAjaxForms();
});

// 현재 페이지 네비게이션 하이라이트
function highlightCurrentNav() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.navbar-nav .nav-link');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href && currentPath.includes(href) && href !== '/') {
            link.classList.add('active');
        }
        if (href === '/' && currentPath === '/') {
            link.classList.add('active');
        }
    });
}

// 테이블 행 클릭 시 상세 페이지로 이동
function initTableRowClick() {
    const tableRows = document.querySelectorAll('.table tbody tr');

    tableRows.forEach(row => {
        row.addEventListener('click', function(e) {
            // 링크를 직접 클릭한 경우는 제외
            if (e.target.tagName === 'A') {
                return;
            }

            const link = this.querySelector('a');
            if (link) {
                window.location.href = link.getAttribute('href');
            }
        });
    });
}

// AJAX 폼 처리
function initAjaxForms() {
    const ajaxForms = document.querySelectorAll('form[data-ajax="true"]');

    ajaxForms.forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();

            const submitBtn = this.querySelector('button[type="submit"]');
            const originalText = submitBtn ? submitBtn.innerHTML : '';

            // 로딩 상태
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>처리 중...';
            }

            // FormData 생성
            const formData = new FormData(this);

            // AJAX 요청
            fetch(this.action || window.location.href, {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success === true) {
                    // 성공 메시지
                    showToast(data.message || '처리되었습니다.', 'success');

                    // 커스텀 성공 핸들러 (우선순위 1)
                    const successHandler = form.getAttribute('data-success');
                    if (successHandler && typeof window[successHandler] === 'function') {
                        window[successHandler](data, form);
                    }
                    // data-redirect 속성으로 리다이렉트 (우선순위 2)
                    else {
                        const redirectUrl = form.getAttribute('data-redirect');
                        if (redirectUrl) {
                            setTimeout(() => {
                                window.location.href = redirectUrl;
                            }, 1000);
                        }
                    }
                } else {
                    // 에러 메시지
                    showToast(data.message || '오류가 발생했습니다.', 'danger');

                    // 폼 복구
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = originalText;
                    }

                    // 커스텀 에러 핸들러
                    const errorHandler = form.getAttribute('data-error');
                    if (errorHandler && typeof window[errorHandler] === 'function') {
                        window[errorHandler](data);
                    }
                }
            })
            .catch(error => {
                console.error('AJAX Error:', error);
                showToast('네트워크 오류가 발생했습니다.', 'danger');

                // 폼 복구
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = originalText;
                }
            });
        });
    });
}

// Toast 메시지 표시
function showToast(message, type = 'info') {
    // Toast 컨테이너 확인/생성
    let toastContainer = document.querySelector('.toast-container');
    if (!toastContainer) {
        toastContainer = document.createElement('div');
        toastContainer.className = 'toast-container position-fixed top-0 end-0 p-3';
        toastContainer.setAttribute('aria-live', 'polite');
        toastContainer.setAttribute('aria-atomic', 'true');
        document.body.appendChild(toastContainer);
    }

    // Toast 요소 생성
    const toastId = 'toast-' + Date.now();
    const bgClass = type === 'success' ? 'bg-success' :
                    type === 'danger' ? 'bg-danger' :
                    type === 'warning' ? 'bg-warning' : 'bg-info';

    const toastHtml = `
        <div id="${toastId}" class="toast align-items-center text-white ${bgClass} border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    `;

    toastContainer.insertAdjacentHTML('beforeend', toastHtml);

    // Toast 표시
    const toastElement = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastElement, {
        autohide: true,
        delay: 3000
    });

    toast.show();

    // Toast 제거
    toastElement.addEventListener('hidden.bs.toast', function() {
        this.remove();
    });
}

// 유틸리티 함수들

// 날짜 포맷팅
function formatDate(dateStr) {
    if (!dateStr || dateStr.length < 8) return dateStr;

    const year = dateStr.substring(0, 4);
    const month = dateStr.substring(4, 6);
    const day = dateStr.substring(6, 8);

    if (dateStr.length >= 14) {
        const hour = dateStr.substring(8, 10);
        const minute = dateStr.substring(10, 12);
        return `${year}-${month}-${day} ${hour}:${minute}`;
    }

    return `${year}-${month}-${day}`;
}

// 숫자 포맷팅 (천단위 콤마)
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// 쿠키 설정
function setCookie(name, value, days) {
    let expires = "";
    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
}

// 쿠키 가져오기
function getCookie(name) {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

// 쿠키 삭제
function deleteCookie(name) {
    document.cookie = name + '=; Max-Age=-99999999;';
}

// 게시글 작성/수정 성공 핸들러
function handleBoardFormSuccess(data, form) {
    const boardId = data.data && data.data.board_id;
    if (boardId) {
        setTimeout(() => {
            window.location.href = 'board_view.jsp?id=' + boardId;
        }, 1000);
    } else {
        setTimeout(() => {
            window.location.href = 'board_list.jsp';
        }, 1000);
    }
}
