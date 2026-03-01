<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 로그인 체크
if(!isLogin) {
    m.redirect("/member/login.jsp");
    return;
}

if(m.isPost()) {
    int id = m.ri("id");

    BoardDao board = new BoardDao();
    DataSet info = board.find("id = ?", new Object[]{id});

    if(!info.next()) {
        m.jsError("게시글을 찾을 수 없습니다.");
        return;
    }

    // 작성자 본인 확인
    if(info.i("user_id") != userId) {
        m.jsError("삭제 권한이 없습니다.");
        return;
    }

    if(board.delete("id = ?", new Object[]{id})) {
        m.jsAlert("게시글이 삭제되었습니다.");
        m.jsReplace("board_list.jsp");
    } else {
        m.jsError("삭제 실패: " + board.getErrMsg());
    }
    return;
}

m.jsError("잘못된 접근입니다.");

%>