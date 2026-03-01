<%@ page contentType="application/json; charset=utf-8" %><%@ page import="java.util.*,java.io.*,malgnsoft.db.*,malgnsoft.util.*,malgnsoft.json.*,dao.*" %><%

// Malgn 객체 생성
Malgn m = new Malgn(request, response, out);

// Form 객체 생성
Form f = new Form();
f.setRequest(request);

// Json 객체 생성
Json j = new Json(out);

// RestAPI 객체 생성
RestAPI api = new RestAPI(request, response);

// CORS 설정 (모든 도메인 허용)
api.cors();

// OPTIONS 요청 (preflight) 처리
if(api.handlePreflight()) return;

// 퍼블릭 라우팅 설정 (인증 불필요한 API)
api.publicRoute(
	"/api/auth/*",          // 인증 API (로그인, 회원가입)
	"/api/apply",           // 신청 폼
	"/api/board/list",      // 게시판 목록
	"/api/board/view/*"     // 게시글 상세
);

// JWT 토큰 인증 (퍼블릭 라우팅은 자동 스킵)
if(!api.auth()) return;

// 인증된 사용자 정보 (JWT 토큰에서 자동 로드)
int userId = api.getDataInt("user_id");
String userName = api.getData("user_name");
int userLevel = api.getDataInt("user_level");
boolean isLogin = (userId > 0);

%>
