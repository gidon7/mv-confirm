<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(33, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 있어야 합니다."); return; }

//객체
CourseDao course = new CourseDao();
CourseModuleDao courseModule = new CourseModuleDao();
CourseUserDao courseUser = new CourseUserDao();
CoursePrecedeDao coursePrecede = new CoursePrecedeDao();
CourseLessonDao courseLesson = new CourseLessonDao();
UserDao user = new UserDao();

//정보
DataSet info = course.find(
	"id = " + id + " AND status != -1 AND site_id = " + siteId + ""
	+ ("C".equals(userKind) ? " AND id IN (" + manageCourses + ") " : "")
);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

if(!"P".equals(info.s("onoff_type"))) {
	//제한
	if(0 < courseUser.getOneInt(
		" SELECT COUNT(*) FROM " + courseUser.table + " a "
		+ " INNER JOIN " + user.table + " u ON a.user_id = u.id "
		+ " WHERE a.course_id = " + id + " AND a.status != -1 "
	)) {
		m.jsError("해당 과정의 수강생 정보가 있습니다. 삭제할 수 없습니다."); return;
	}

	//제한
	if(0 < coursePrecede.findCount("precede_id = " + id + "")) {
		m.jsError("해당 과정이 선행과정으로 지정되어 있습니다. 삭제할 수 없습니다."); return;
	}

	//제한-평가모듈
	DataSet cmlist = courseModule.find("course_id = " + id + "", "module", "module");
	while(cmlist.next()) {
		if("exam".equals(cmlist.s("module"))) { m.jsError("해당 과정에 [시험]이 포함되어 있어 과정을 삭제할 수 없습니다.\\n[시험] 먼저 삭제 해주시길 바랍니다."); return; }
		else if("forum".equals(cmlist.s("module"))) { m.jsError("해당 과정에 [토론]이 포함되어 있어 과정을 삭제할 수 없습니다.\\n[토론] 먼저 삭제 해주시길 바랍니다."); return; }
		else if("homework".equals(cmlist.s("module"))) { m.jsError("해당 과정에 [과제]가 포함되어 있어 과정을 삭제할 수 없습니다.\\n[과제] 먼저 삭제 해주시길 바랍니다."); return; }
		else if("survey".equals(cmlist.s("module"))) { m.jsError("해당 과정에 [설문]이 포함되어 있어 과정을 삭제할 수 없습니다.\\n[설문] 먼저 삭제 해주시길 바랍니다."); return; }
	}
}

//삭제
course.item("course_file", "");
course.item("status", -1);
if(!course.update("id = " + id + "")) { m.jsError("삭제하는 중 오류가 발생했습니다."); return; }

//액션로그
ActionLogDao alog = new ActionLogDao(siteId, "course");
if(!alog.add(userId, info.i("id"), "D", "과정삭제", info.serialize(), "")) {
	Malgn.errorLog("{course.course_modify} actionLog add error : site_id = " + siteId + ", user_id = " + userId + ", course_id = " + id);
}

if(!"P".equals(info.s("onoff_type"))) {
	//삭제
	if(!coursePrecede.delete("course_id = " + id + "")) { m.jsError("선행과정을 삭제하는 중 오류가 발생했습니다."); return; }

	//삭제
	courseLesson.item("status", -1);
	if(!courseLesson.update("course_id = " + id + "")) { m.jsError("과정의 강의를 삭제하는 중 오류가 발생했습니다."); return; }
}

//삭제-파일
if(!"".equals(info.s("course_file"))) m.delFileRoot(m.getUploadPath(info.s("course_file")));

m.jsReplace("course_list.jsp?" + m.qs("id"));

%>