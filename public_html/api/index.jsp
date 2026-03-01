<%@ page contentType="application/json; charset=utf-8" %><%@ page import="java.util.*, malgnsoft.util.*" %><%

RestAPI router = new RestAPI(request, response);

// CORS 설정 (모든 도메인 허용)
router.cors();

// OPTIONS 요청 (preflight) 처리
if(router.handlePreflight()) return;

// 라우팅 그룹 등록
router.use("/api/auth", "/api/auth.jsp");
router.use("/api/apply", "/api/apply.jsp");
router.use("/api/board", "/api/board.jsp");

// 등록된 라우트로 자동 포워딩
router.forward();

%>
