<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%
int sysopMenuId = m.ri("smid");
String qs = (0 < sysopMenuId ? "?smid=" + sysopMenuId : "");
if(isNewUI) {
	// 신버전: 대시보드로 바로 이동
	response.sendRedirect("/sysop/main/index.jsp" + qs);
} else {
	// 구버전: frameset 진입점
	String InitPage = "./main/index.jsp";
	if(0 < sysopMenuId) {
		String pageLink = Menu.getOne("SELECT link FROM " + Menu.table + " WHERE id = ? AND link != '' AND depth = 3 AND display_yn = 'Y' AND status = 1", new Integer[] {sysopMenuId});
		if(!"".equals(pageLink)) InitPage = m.replace(pageLink, "../", "./") + (!"".equals(m.qs("smid")) ? "?" + m.qs("smid") : "");
	}
%><!DOCTYPE html>
<html lang="ko">
<head>
<title><%= winTitle %></title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<% if(isDevServer) { %><link rel="shortcut icon" href="/sysop/favicon_devsysop.ico" />
<% } else { %><link rel="shortcut icon" href="/sysop/favicon_servicesysop.ico" /><% } %>
<script src="/common/js/jquery-1.7.2.min.js" charset="utf-8"></script>
<script>
$(window).resize(function() { try { _Main.resizeLayer($("#_Main").width(), $("#_Main").height()); } catch(e) {} });
</script>
</head>
<frameset id="_TFRM" rows="60,*" frameborder="no" border="0">
    <frame src="./main/top.jsp" name="_Top" marginwidth="0" marginheight="0" scrolling="no" frameborder="no" border="0" noresize>
    <frameset id="_MFRM" cols="250,*" frameborder="no" border="0">
        <frame src="about:blank" name="_Menu" marginwidth="0" marginheight="0" scrolling="auto" frameborder="no" border="0" noresize>
        <frame src="<%= InitPage %>" name="_Main" id="_Main" marginwidth="0" marginheight="0" scrolling="auto" frameborder="no" border="0">
    </frameset>
</frameset>
</html><%
}
%>