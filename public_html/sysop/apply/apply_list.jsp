<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

ApplyDao applyDao = new ApplyDao();
ApplyUserDao applyUserDao = new ApplyUserDao();

f.addElement("s_keyword", null, null);
f.addElement("s_field", null, null);
f.addElement("s_status", null, null);

ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum(20);
lm.setTable(applyDao.table + " a ");
lm.setFields("a.*"
    + ", (SELECT COUNT(*) FROM " + applyUserDao.table + " WHERE apply_id = a.id AND status = 1) apply_user_cnt");
lm.addWhere("a.status != -1");
lm.addWhere("a.site_id = " + siteId);
lm.addSearch("a.status", f.get("s_status"));
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else if("".equals(f.get("s_field")) && !"".equals(f.get("s_keyword"))) {
    lm.addSearch("a.code, a.apply_nm", f.get("s_keyword"), "LIKE");
}
lm.setOrderBy(!"".equals(m.rs("ord")) ? m.rs("ord") : "a.reg_date DESC, a.id DESC");

DataSet list = lm.getDataSet();
while(list.next()) {
    list.put("apply_nm_conv", Malgn.htt(list.s("apply_nm")));
    list.put("reg_date_conv", Malgn.time("yyyy.MM.dd", list.s("reg_date")));
    list.put("status_conv", Malgn.getItem(list.s("status"), applyDao.statusList));
    list.put("apply_date_conv", Malgn.time("yyyy.MM.dd", list.s("apply_sdate")) + " - " + Malgn.time("yyyy.MM.dd", list.s("apply_edate")));
}

p.setLayout(ch);
p.setBody("apply.apply_list");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);

p.setLoop("status_list", Malgn.arr2loop(applyDao.statusList));

p.display();

%>