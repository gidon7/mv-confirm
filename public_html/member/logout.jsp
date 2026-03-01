<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

auth.delete();

m.jsAlert("로그아웃되었습니다.");
m.jsReplace("/");

%>