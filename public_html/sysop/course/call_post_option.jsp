<%@ page contentType="text/html; charset=utf-8" %><%@ page import="malgnsoft.json.*" %><%@ include file="init.jsp" %><%

//기본키
String code = m.rs("code", "review");
int id = m.ri("id");
int bid = m.ri("bid");
if(id == 0 || bid == 0 || "".equals(code)) { out.print("기본키는 반드시 지정하여야 합니다."); return; }

//객체
ClPostDao post = new ClPostDao();
ClBoardDao board = new ClBoardDao();
CourseDao course = new CourseDao();
UserDao user = new UserDao();
UserDeptDao userDept = new UserDeptDao();

//변수
String mode = m.rs("mode");

//정보-게시판
DataSet binfo = board.find("id = " + bid + " AND status != -1");
if(!binfo.next()) { out.print("해당 게시판 정보가 없습니다."); return; }

//정보-게시물
DataSet info = post.query(
	"SELECT a.*, b.board_nm, b.board_type, b.code, c.course_nm, u.login_id "
	+ " FROM " + post.table + " a "
	+ " INNER JOIN " + board.table + " b ON a.board_id = b.id "
	+ " LEFT JOIN " + course.table + " c ON a.course_id = c.id AND b.course_id = c.id "
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id " + (deptManagerBlock ? " AND u.dept_id IN (" + userDept.getSubIdx(siteId, userDeptId) + ") " : "")
	+ " WHERE a.status != -1 AND a.id = " + id + " "
	+ ("C".equals(userKind) ? " AND a.course_id IN (" + manageCourses + ") " : "")
);
if(!info.next()) { out.print("해당 게시물 정보가 없습니다."); return; }

if(m.isPost() && "main_yn".equals(mode)) {
	post.item("main_yn", f.get("main_yn", "N"));
	if(!post.update("id = " + info.i("id") + "")) {
		out.print("메인 노출 여부를 수정하는 중 오류가 발생 했습니다.");
		return;
	}

	out.print("success");
	return;
}

%>