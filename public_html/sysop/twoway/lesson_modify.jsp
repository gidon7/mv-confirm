<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int lid = m.ri("id");
int cid = m.ri("cid");
if(lid == 0 || cid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseLessonDao courseLesson = new CourseLessonDao();
CourseDao course = new CourseDao();
LessonDao lesson = new LessonDao();

CourseTutorDao courseTutor = new CourseTutorDao();
TutorDao tutor = new TutorDao();
UserDao user = new UserDao();
MCal mcal = new MCal();
FileDao file = new FileDao();

DataSet courseInfo = course.find("site_id = " + siteId + " AND id = " + cid + " AND status = 1", "study_sdate, study_edate");
if(!courseInfo.next()) { m.jsError("해당 과정정보가 없습니다."); return; }

//정보
DataSet info = courseLesson.getTwowayLessonInfo(siteId, cid, lid);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//폼체크
String startDate = !"".equals(info.s("start_date")) ? Malgn.time("yyyy-MM-dd", info.s("start_date")) : Malgn.time("yyyy-MM-dd");
String endDate = !"".equals(info.s("end_date")) ? Malgn.time("yyyy-MM-dd", info.s("end_date")) : startDate;
String startHour = info.s("start_time").length() == 6 ? info.s("start_time").substring(0, 2) : "00";
String startMinute = info.s("start_time").length() == 6 ? info.s("start_time").substring(2, 4) : "00";
String endHour = info.s("end_time").length() == 6 ? info.s("end_time").substring(0, 2) : "23";
String endMinute = info.s("end_time").length() == 6 ? info.s("end_time").substring(2, 4) : "55";

f.addElement("room_type", info.s("start_url"), "hname:'강의실타입'");
f.addElement("lesson_nm", info.s("lesson_nm"), "hname:'교과목명', required:'Y'");
f.addElement("total_time", info.i("total_time"), "hname:'학습시간', option:'number'");
f.addElement("complete_time", info.i("complete_time"), "hname:'인정시간', option:'number'");
f.addElement("content_width", info.i("content_width"), "hname:'창넓이', option:'number'");
f.addElement("content_height", info.i("content_height"), "hname:'창높이', option:'number'");
if(!courseManagerBlock) f.addElement("manager_id", info.i("manager_id"), "hname:'담당자'");
f.addElement("status", info.i("status"), "hname:'상태', required:'Y'");
f.addElement("start_date", startDate, "hname:'시작일', required:'Y'");
f.addElement("end_date", endDate, "hname:'마감일', required:'Y'");
f.addElement("start_time_hour", startHour, "hname:'시작시', option:'number'");
f.addElement("start_time_min", startMinute, "hname:'시작분', option:'number'");
f.addElement("end_time_hour", endHour, "hname:'마감시', option:'number'");
f.addElement("end_time_min", endMinute, "hname:'마감분', option:'number'");
f.addElement("tutor_id", info.i("tutor_id"), "hname:'담임', required:'Y'");

//등록
if(m.isPost() && f.validate()) {

	String sdate = Malgn.time("yyyyMMdd", f.get("start_date"));
	String startTime = f.get("start_time_hour") + f.get("start_time_min") + "00";
	String endTime = f.get("end_time_hour") + f.get("end_time_min") + "59";

	if(1 > Malgn.diffDate("I", sdate + startTime, sdate + endTime)) { m.jsAlert("강의 시작시간이 종료시간을 초과했습니다."); return; }

	lesson.item("lesson_nm", f.get("lesson_nm"));
	lesson.item("total_time", f.getInt("total_time"));
	lesson.item("complete_time", f.getInt("complete_time"));
	lesson.item("content_width", f.getInt("content_width"));
	lesson.item("content_height", f.getInt("content_height"));
	lesson.item("manager_id", !courseManagerBlock ? f.getInt("manager_id") : userId);
	lesson.item("status", f.getInt("status"));
	if(!lesson.update("id = " + info.i("lesson_id") + " AND site_id = " + siteId)) { m.jsAlert("수정하는 중 오류가 발생했습니다[2]."); return; }

	courseLesson.item("tutor_id", f.getInt("tutor_id"));
	courseLesson.item("start_date", sdate);
	courseLesson.item("end_date", sdate);
	courseLesson.item("start_time", startTime);
	courseLesson.item("end_time", endTime);

	if(!courseLesson.update("lesson_id = " + lid + " AND course_id = " + cid)) { m.jsAlert("수정하는 중 오류가 발생했습니다[3]."); return; }
	m.js("try { parent.opener.location.href = parent.opener.location.href; } catch(e) { } parent.window.close();");
	return;
}

//포맷팅
info.put("lesson_type_conv", Malgn.getItem(info.s("lesson_type"), lesson.twowayTypes));
info.put("room_type_conv", boda.getTemplateName(SiteConfig.getArr("boda_template"), info.i("start_url")));
info.put("reg_date_conv", Malgn.time("yyyy.MM.dd HH:mm:ss", info.s("reg_date")));
info.put("start_time_hour", startHour);
info.put("start_time_min", startMinute);
info.put("end_time_hour", endHour);
info.put("end_time_min", endMinute);

//목록-교안
DataSet files = file.getFileList(lid, "lesson");
while(files.next()) {
	files.put("file_ext", file.getFileExt(files.s("filename")));
	try {
		files.put("filename_conv", Malgn.urlencode(Base64Coder.encode(files.s("filename"))));
	} catch (Exception e) {
		Malgn.errorLog("{twoway.lesson_modify} base encode error", e);
	}
	files.put("ext", file.getFileIcon(files.s("filename")));
	files.put("ek", Malgn.encrypt(files.s("id")));
	files.put("sep", !files.b("__last") ? "<br>" : "");
}

//목록-강사
DataSet tutors = courseTutor.query(
	"SELECT a.*, t.*, u.login_id "
	+ " FROM " + courseTutor.table + " a "
	+ " INNER JOIN " + tutor.table + " t ON t.user_id = a.user_id "
	+ " INNER JOIN " + user.table + " u ON t.user_id = u.id "
	+ " WHERE a.course_id = " + cid + ""
);

//출력
p.setLayout("pop");
p.setBody("twoway.lesson_insert");
p.setVar("p_title", "화상강의관리");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar(info);

p.setVar("modify", true);
p.setVar("study_sdate", courseInfo.s("study_sdate"));
p.setVar("study_edate", courseInfo.s("study_edate"));

p.setLoop("tutors", tutors);

p.setLoop("files", files);
p.setLoop("hours", mcal.getHours());
p.setLoop("minutes", mcal.getMinutes(5));

p.setLoop("status_list", Malgn.arr2loop(lesson.statusList));

p.display();

%>