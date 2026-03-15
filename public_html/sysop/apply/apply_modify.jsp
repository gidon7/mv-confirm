<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정하여야 합니다."); return; }

ApplyDao applyDao = new ApplyDao();
ApplyUserDao applyUserDao = new ApplyUserDao();

DataSet info = applyDao.find("id = ? AND site_id = ? AND status != -1", new Object[] { id, siteId });
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }
info.put("apply_sdate", Malgn.time("yyyy-MM-dd", info.s("apply_sdate")));
info.put("apply_edate", Malgn.time("yyyy-MM-dd", info.s("apply_edate")));

f.addElement("apply_nm", info.s("apply_nm"), "hname:'신청서명', required:'Y'");
f.addElement("apply_sdate", info.s("apply_sdate"), "hname:'신청기간시작일', required:'Y'");
f.addElement("apply_edate", info.s("apply_edate"), "hname:'신청기간종료일', required:'Y'");
f.addElement("apply_cd", info.s("apply_cd"), "hname:'코드', required:'Y'");
f.addElement("apply_text", null, "hname:'상단 텍스트', allowhtml:'Y'");
f.addElement("etc_field", info.s("etc_field"), "hname:'필드'");
f.addElement("status", info.s("status"), "hname:'상태'");

if(m.isPost() && f.validate()) {

    String applyText = f.get("apply_text");
    int bytes = applyText.replace("\r\n", "\n").getBytes("UTF-8").length;
    if(60000 < bytes) { m.jsAlert(f.get("apply_text") + " 내용은 60000바이트를 초과해 작성하실 수 없습니다.\\n(현재 " + bytes + "바이트)"); return; }

    Json j = new Json(Json.encode(m.reqMap("etc_")));

    applyDao.item("site_id", siteId);
    applyDao.item("apply_nm", f.get("apply_nm"));
    applyDao.item("apply_cd", f.get("apply_cd"));
    applyDao.item("apply_text", applyText);
    applyDao.item("apply_sdate", Malgn.time("yyyyMMdd", f.get("apply_sdate")));
    applyDao.item("apply_edate", Malgn.time("yyyyMMdd", f.get("apply_edate")));
    applyDao.item("etc_field", j.toString());
    applyDao.item("status", f.get("status", "0"));

    if(!applyDao.update("id = " + id)) { m.jsAlert("등록하는 중 오류가 발생했습니다."); return; }

    m.jsAlert("성공적으로 수정했습니다.");
    m.jsReplace("apply_modify.jsp?" + m.qs(), "parent");
    return;
}

if(!"".equals(info.s("etc_field"))) {
    HashMap<String, Object> sub = Json.toMap(info.s("etc_field"));
    for(String key : sub.keySet()) {
        info.put(key, sub.get(key).toString());
        f.addElement(key, sub.get(key).toString(), null);
    }
}


p.setLayout("sysop");
p.setBody("apply.apply_insert");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar(info);
p.setVar("modify", true);

p.setVar("apply_user_block", 1 > applyUserDao.findCount("apply_id = " + id + " AND status != -1"));

p.display();

%>