<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

int id = m.ri("id");

if(id == 0) {
    m.jsError("잘못된 접근입니다.");
    return;
}

BoardDao board = new BoardDao();

// 조회수 증가
board.increaseHit(id);

// 게시글 조회 (작성자 정보 포함)
DataSet info = board.getWithUser(id);

if(!info.next()) {
    m.jsError("게시글을 찾을 수 없습니다.");
    return;
}

// 날짜 포맷 (info 객체에 직접 추가)
info.put("reg_date_format", m.time("yyyy-MM-dd HH:mm", info.s("reg_date")));
info.put("mod_date_format", m.time("yyyy-MM-dd HH:mm", info.s("mod_date")));

// 작성자 본인 여부
info.put("is_author", info.i("user_id") == userId);

p.setLayout("main");
p.setBody("board.board_view");
p.setVar(info);
p.setVar("title", info.s("title"));
p.display();

%>