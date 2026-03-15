<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//권한체크
if(!Menu.accessible(810, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
UserDao user = new UserDao(isBlindUser);
SensSMS sens = new SensSMS();

//변수
String pattern = "(\\d{3})(\\d{3,4})(\\d{4})";
String requestId = m.rs("request_id");
if("".equals(requestId)) { m.jsError("잘못된 접근입니다."); return; }

//제한
DataSet info = sens.find("request_id = '" + requestId + "'");
if(!info.next()) { m.jsError("잘못된 접근입니다."); return; }

DataSet messages = sms.getSendResult(requestId);

//포맷팅
messages.put("status_conv", m.getItem(messages.s("status"), sens.statusList));
messages.put("status_name_conv", m.getItem(messages.s("status_name"), sens.statusNameList));
messages.put("dest_phone", messages.s("to").replaceAll(pattern, "$1-$2-$3"));
if("0".equals(messages.s("status_code"))) { messages.put("status_code", false); }

user.maskInfo(messages);

//출력
p.setLayout("pop");
p.setBody("sms.senssms_result");
p.setVar("request_id", requestId);
p.setVar("messages", messages);
p.display();

%>