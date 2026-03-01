<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 로그인 체크
if(!isLogin) {
    m.redirect("/member/login.jsp");
    return;
}

// 유효성 검증 규칙 설정
f.addElement("title", null, "required:'Y', minlength:2");
f.addElement("content", null, "required:'Y', minlength:10");

// POST 처리 (등록)
if(m.isPost() && f.validate()) {
    BoardDao board = new BoardDao();

    board.item("user_id", userId);
    board.item("title", f.get("title"));
    board.item("content", f.get("content"));
    board.item("hit", 0);
    board.item("reg_date", m.time());
    board.item("status", 1);

    if(board.insert()) {
        j.put("board_id", board.getInsertId());
        j.success("게시글이 등록되었습니다.");
    } else {
        j.error("등록 실패: " + board.getErrMsg());
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("main");
p.setBody("board.board_write");
p.setVar("title", "게시글 작성");
p.setVar("form_script", f.getScript());
p.display();

%>