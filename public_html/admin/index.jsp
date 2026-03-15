<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 관리자 권한 체크
if(!isLogin) {
    m.redirect("/member/login.jsp");
    return;
}

BoardDao board = new BoardDao();
ApplyDao apply = new ApplyDao();
UserDao user = new UserDao();

// 통계
p.setVar("total_member", String.valueOf(user.findCount("")));
p.setVar("total_board", String.valueOf(board.findCount("")));
p.setVar("pending_apply", String.valueOf(apply.findCount("status = ?", new Object[]{"pending"})));

// 최근 게시글
board.setOrderBy("id DESC");
DataSet boardList = board.find();
// 날짜 포맷 처리는 루프 내에서 템플릿이 처리

// 최근 신청
apply.setOrderBy("id DESC");
DataSet applyList = apply.find();

// 상단 유저 이니셜
String userName = auth.getString("name");
p.setVar("userInitial", userName.isEmpty() ? "A" : userName.substring(0, 1));

p.setLayout("admin");
p.setBody("admin.dashboard");
p.setVar("title", "대시보드");
p.setVar("userName", userName);
p.setLoop("boardList", boardList);
p.setLoop("applyList", applyList);
p.display();

%>
