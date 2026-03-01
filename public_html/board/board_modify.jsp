<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 로그인 체크
if(!isLogin) {
    m.redirect("/member/login.jsp");
    return;
}

int id = m.ri("id");

BoardDao board = new BoardDao();
DataSet info = board.find("id = ?", new Object[]{id});

if(!info.next()) {
    m.jsError("게시글을 찾을 수 없습니다.");
    return;
}

// 작성자 본인 확인
if(info.i("user_id") != userId) {
    m.jsError("수정 권한이 없습니다.");
    return;
}

// 유효성 검증 규칙 설정
f.addElement("title", info.s("title"), "required:'Y', minlength:2");
f.addElement("content", info.s("content"), "required:'Y', minlength:10");

// POST 처리 (수정)
if(m.isPost() && f.validate()) {
    board.item("title", f.get("title"));
    board.item("content", f.get("content"));
    board.item("mod_date", m.time());

    if(board.update("id = ?", new Object[]{id})) {
        j.put("board_id", id);
        j.success("게시글이 수정되었습니다.");
    } else {
        j.error("수정 실패: " + board.getErrMsg());
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("main");
p.setBody("board.board_modify");
p.setVar("title", "게시글 수정");
p.setVar("board_id", id);
p.setVar("form_script", f.getScript());
p.display();

%>