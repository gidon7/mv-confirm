<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(810, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
SensSMS sensSms = new SensSMS();
UserDao user = new UserDao(isBlindUser);

//폼체크
f.addElement("s_req_sdate", null, null);
f.addElement("s_req_edate", null, null);
f.addElement("s_send_sdate", null, null);
f.addElement("s_send_edate", null, null);
f.addElement("s_send_type", null, null);
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//목록
ListManager lm = new ListManager();
//lm.setDebug(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 20000 : 20);
lm.setTable(sensSms.table + " a");
lm.setFields("a.request_id, DATE_FORMAT(a.request_time, '%Y-%m-%d %T') request_time, a.group_id, a.mobile, a.content, a.send_type, DATE_FORMAT(a.reserve_time, '%Y-%m-%d %T') reserve_time");

if(!"".equals(f.get("s_req_sdate"))) lm.addWhere("a.request_time >= '" + m.time("yyyy-MM-dd 00:00:00", f.get("s_req_sdate")) + "'");
if(!"".equals(f.get("s_req_edate"))) lm.addWhere("a.request_time <= '" + m.time("yyyy-MM-dd 23:59:59", f.get("s_req_edate")) + "'");
if(!"".equals(f.get("s_send_sdate"))) lm.addWhere("a.reserve_time >= '" + m.time("yyyy-MM-dd 00:00:00", f.get("s_send_sdate")) + "'");
if(!"".equals(f.get("s_send_edate"))) lm.addWhere("a.reserve_time <= '" + m.time("yyyy-MM-dd 23:59:59", f.get("s_send_edate")) + "'");
lm.addSearch("a.send_type", f.get("s_send_type"));
lm.addSearch("a.group_id, a.mobile, a.content", f.get("s_keyword"), "LIKE");
lm.setOrderBy("a.request_time desc, a.group_id desc");

//포맷팅
DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("request_id_conv", m.cutString(list.s("request_id"), 14));
    list.put("group_id", list.i("group_id") != 0 ? list.i("group_id") : "-");
    list.put("content_conv", m.cutString(list.s("content"), 60));
    list.put("send_type_conv", !"I".equals(list.s("send_type")) ? "예약" : "-");
    list.put("request_time_conv", list.s("request_time"));
    list.put("reserve_time_conv", !"".equals(list.s("reserve_time")) ? list.s("reserve_time") : "-");
    list.put("dest_phone", list.s("mobile"));
    user.maskInfo(list);
}

//기록-개인정보조회
if("".equals(m.rs("mode")) && list.size() > 0 && !isBlindUser) _log.add("L", Menu.menuNm, list.size(), inquiryPurpose, list);

//엑셀
if("excel".equals(m.rs("mode"))) {
    if(list.size() > 0 && !isBlindUser) _log.add("E", Menu.menuNm, list.size(), inquiryPurpose, list);

    ExcelWriter ex = new ExcelWriter(response, "SMS발신로그(" + m.time("yyyy-MM-dd") + ").xls");
    ex.setData(list, new String[] { "__ord=>No", "request_id=>고유값", "group_id=>그룹번호", "mobile=>수신번호", "content=>내용", "send_type=>발신상태(R:예약, I:즉시, C:취소)",
    "request_time_conv=>등록일시", "reserve_time_conv=>예약일시"}, "SMS발신로그(" + m.time("yyyy-MM-dd") + ")");
    ex.write();
    return;
}

//출력
p.setBody("sms.senssms_list");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("pagebar", lm.getPaging());
p.setVar("list_total", lm.getTotalString());

p.display();

%>