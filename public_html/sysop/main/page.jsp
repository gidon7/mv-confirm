<%@ page contentType="text/html; charset=utf-8" %><%@ include file="./init.jsp" %><%

//변수
String code = m.rs("code");
String date = m.rs("d");
String file = code + (!"".equals(date) ? "_" + date : "");
HashMap<String, String> titles = new HashMap<String, String>(){{
    put("clause", "이용약관");
    put("privacy", "개인정보처리방침");
    put("purpose", "개인정보 조회사유 입력");
}};

//출력
p.setLayout("pop");
p.setBody("page." + file);
p.setVar("p_title", titles.get(code));
p.display();

%>