<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

ApplyDao applyDao = new ApplyDao();

f.addElement("apply_nm", null, "hname:'신청서명', required:'Y'");
f.addElement("apply_cd", null, "hname:'코드', required:'Y'");
f.addElement("apply_text", null, "hname:'상단 텍스트', allowhtml:'Y'");
f.addElement("etc_field", null, "hname:'신청서내용'");

if(m.isPost() && f.validate()) {

    String applyText = f.get("apply_text");
    int bytes = applyText.replace("\r\n", "\n").getBytes("UTF-8").length;
    if(60000 < bytes) { m.jsAlert(f.get("apply_text") + " 내용은 60000바이트를 초과해 작성하실 수 없습니다.\\n(현재 " + bytes + "바이트)"); return; }

    Json j = new Json(Json.encode(m.reqMap("etc_")));

    int newId = applyDao.getSequence();

    applyDao.item("id", newId);
    applyDao.item("site_id", siteId);
    applyDao.item("apply_nm", f.get("apply_nm"));
    applyDao.item("apply_cd", f.get("apply_cd"));
    applyDao.item("apply_text", applyText);
    applyDao.item("apply_sdate", Malgn.time("yyyyMMdd", f.get("apply_sdate")));
    applyDao.item("apply_edate", Malgn.time("yyyyMMdd", f.get("apply_edate")));
    applyDao.item("reg_date", sysNow);
    applyDao.item("etc_field", j.toString());
    applyDao.item("status", 1);

    if(!applyDao.insert()) { m.jsAlert("등록하는 중 오류가 발생했습니다."); return; }

    m.jsReplace("apply_modify.jsp?id=" + newId, "parent");
    return;
}


p.setLayout("sysop");
p.setBody("apply.apply_insert");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.display();

%>