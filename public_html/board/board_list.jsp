<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 검색 폼 필드 설정
f.addElement("keyword", null, null);

// ListManager를 사용한 페이징 목록
ListManager lm = new ListManager();
lm.setRequest(request);
lm.setListNum(10);
lm.setTable("tb_board b LEFT JOIN tb_user u ON b.user_id = u.id");
lm.setFields("b.*, u.name as user_name");

// 검색 조건
lm.addSearch("b.title,b.content", f.get("keyword"), "LIKE");

lm.setOrderBy("b.id DESC");

DataSet list = lm.getDataSet();

// 날짜 포맷 추가
while(list.next()) {
    list.put("reg_date_format", m.time("yyyy-MM-dd HH:mm", list.s("reg_date")));
}

p.setLayout("main");
p.setBody("board.board_list");
p.setLoop("list", list);
p.setVar("title", "게시판");
p.setVar("total", lm.getTotalNum());
p.setVar("pager", lm.getPaging());
p.setVar("form_script", f.getScript());
p.display();

%>