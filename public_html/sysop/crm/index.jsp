<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title><%= winTitle %></title>
<% if(isDevServer) { %><link rel="shortcut icon" href="/sysop/favicon_devsysop.ico"><% } else { %><link rel="shortcut icon" href="/sysop/favicon_servicesysop.ico"><% } %>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
html, body {
	margin: 0; padding: 0;
	width: 100%; height: 100%;
	overflow: hidden;
	background: #0c4a6e;
}
#_BODY {
	box-sizing: border-box;
	width: 100%; height: 100%;
	border: 0;
	padding-right: 0;
	transition: padding-right 0.2s;
}
#_CS {
	box-sizing: border-box;
	position: fixed;
	width: 300px; height: 0;
	top: 0; right: 0;
	z-index: 99997;
	overflow: hidden;
	border: 0;
	background: #fff;
	border-left: 1px solid #e2e8f0;
	box-shadow: -2px 0 8px rgba(0,0,0,0.06);
	transition: height 0.2s;
}
#cs-btn {
	position: fixed;
	top: 0; right: 0;
	height: 50px;
	padding: 0 16px;
	z-index: 99999;
	background: transparent;
	border: none;
	border-left: 1px solid rgba(255,255,255,0.1);
	color: rgba(255,255,255,0.8);
	font-size: 13px;
	font-family: "Pretendard", "Malgun Gothic", sans-serif;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 6px;
	letter-spacing: -0.3px;
	transition: background 0.15s, color 0.15s;
}
#cs-btn:hover { background: rgba(255,255,255,0.1); color: #fff; }
</style>
</head>
<body>
<iframe src="../crm/course_list.jsp?uid=<%=uid%>" name="_BODY" id="_BODY" frameborder="0"></iframe>
<iframe src="../crm/memo_list.jsp?uid=<%=uid%>" name="_CS" id="_CS" scrolling="no" frameborder="0"></iframe>
<button id="cs-btn" onclick="openMemoPanel()">
	<i class="fa fa-comments-o"></i> 상담이력
</button>
<script>
function openMemoPanel() {
	document.getElementById("cs-btn").style.display = "none";
	document.getElementById("_CS").style.height = "100%";
	document.getElementById("_BODY").style.paddingRight = "300px";
	try {
		var csWin = document.getElementById("_CS").contentWindow;
		if(csWin.memo_status !== undefined) csWin.memo_status = "open";
		csWin.$(".fa-angle-down").removeClass("fa-angle-down").addClass("fa-angle-up");
	} catch(e) {}
}
</script>
</body>
</html>
