<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title><%= winTitle %></title>
<% if(isDevServer) { %><link rel="shortcut icon" href="/sysop/favicon_devsysop.ico"><% } else { %><link rel="shortcut icon" href="/sysop/favicon_servicesysop.ico"><% } %>
<style>
html, body {
	margin: 0; padding: 0;
	width: 100%; height: 100%;
	overflow: hidden;
	background: #f8fafc;
}
#_BODY {
	box-sizing: border-box;
	width: 100%; height: 100%;
	border: 0;
	padding-right: 300px;
}
#_CS {
	box-sizing: border-box;
	position: absolute;
	width: 300px; height: 45px;
	top: 0; right: 0;
	z-index: 99997;
	overflow: hidden;
	border: 0;
	background: #fff;
	border-left: 1px solid #e2e8f0;
	box-shadow: -2px 0 8px rgba(0,0,0,0.06);
}
</style>
</head>
<body>
<iframe src="../crm/course_list.jsp?uid=<%=uid%>" name="_BODY" id="_BODY" frameborder="0"></iframe>
<iframe src="../crm/memo_list.jsp?uid=<%=uid%>" name="_CS" id="_CS" scrolling="no" frameborder="0"></iframe>
</body>
</html>
