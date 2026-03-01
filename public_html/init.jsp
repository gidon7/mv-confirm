<%@ page import="java.util.*,java.io.*,malgnsoft.db.*,malgnsoft.util.*,malgnsoft.json.*,dao.*" %><%

Malgn m = new Malgn(request, response, out);

Form f = new Form();
f.setRequest(request);

Page p = new Page();
p.setRequest(request);
p.setPageContext(pageContext);
p.setWriter(out);

Json j = new Json(out);

int userId = 0;
String userName = "";
boolean isLogin = false;

Auth auth = new Auth(request, response);
if(auth.isValid()) {
	userId = auth.getInt("user_id");
	userName = auth.getString("user_name");
	isLogin = true;
}

p.setVar("userId", userId);
p.setVar("userName", userName);
p.setVar("isLogin", isLogin);

%>