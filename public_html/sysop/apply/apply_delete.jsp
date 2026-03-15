<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 있어야 합니다."); return; }

//객체
ApplyDao applyDao = new ApplyDao();

//정보
DataSet info = applyDao.find("id = " + id + " AND status != -1 AND site_id = " + siteId + "");
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//삭제
applyDao.item("status", -1);
if(!applyDao.update("id = " + id + "")) { m.jsError("삭제하는 중 오류가 발생했습니다."); return; }

m.jsReplace("apply_list.jsp?" + m.qs("id"));

%>