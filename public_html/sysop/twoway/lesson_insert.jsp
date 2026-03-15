<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int cid = m.ri("cid");
if(cid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseLessonDao courseLesson = new CourseLessonDao();
CourseDao course = new CourseDao();
LessonDao lesson = new LessonDao();
CourseTutorDao courseTutor = new CourseTutorDao();
TutorDao tutor = new TutorDao();
UserDao user = new UserDao();
MCal mcal = new MCal();
FileDao file = new FileDao();//파일

DataSet courseInfo = course.find("site_id = " + siteId + " AND id = " + cid + " AND status = 1", "study_sdate, study_edate");
if(!courseInfo.next()) { m.jsError("해당 과정정보가 없습니다."); return; }

//폼체크
f.addElement("lesson_type", isBodaYn ? "16" : "15", "hname:'강의타입', required:'Y'");
f.addElement("room_type", isBodaYn ? "140" : "H", "hname:'강의실타입', required:'Y'");
f.addElement("lesson_nm", null, "hname:'교과목명', required:'Y'");
f.addElement("total_time", 0, "hname:'학습시간', option:'number'");
f.addElement("complete_time", 0, "hname:'인정시간', option:'number'");
f.addElement("content_width", 1980, "hname:'창넓이', option:'number'");
f.addElement("content_height", 1080, "hname:'창높이', option:'number'");
if(!courseManagerBlock) f.addElement("manager_id", -99, "hname:'담당자'");
f.addElement("status", 1, "hname:'상태', required:'Y'");
f.addElement("host_num", 1, "hname:'강의실'");
f.addElement("tutor_id", 0, "hname:'강사명', required:'Y'");
f.addElement("start_date", Malgn.time("yyyy-MM-dd"), "hname:'시작일', required:'Y'");
f.addElement("end_date", Malgn.time("yyyy-MM-dd"), "hname:'마감일', required:'Y'");
f.addElement("start_time_hour", "00", "hname:'시작시', option:'number'");
f.addElement("start_time_min", "00", "hname:'시작분', option:'number'");
f.addElement("end_time_hour", "23", "hname:'마감시', option:'number'");
f.addElement("end_time_min", "55", "hname:'마감분', option:'number'");

//등록
if(m.isPost() && f.validate()) {

	String lessonType = f.get("lesson_type");

	String sdate = Malgn.time("yyyyMMdd", f.get("start_date"));
	String startTime = f.get("start_time_hour") + f.get("start_time_min") + "00";
	String endTime = f.get("end_time_hour") + f.get("end_time_min") + "59";

	if(1 > Malgn.diffDate("I", sdate + startTime, sdate + endTime)) { m.jsAlert("강의 시작시간이 종료시간을 초과했습니다."); return; }

	//랜선에듀 강의실 생성 API 호출
	String twowayUrl = "";
	int hostNum = f.getInt("host_num");
	String tutorNm = user.getOne("SELECT CONCAT(user_nm, '(', login_id, ')') FROM " + user.table + " WHERE id = " + f.getInt("tutor_id") + " AND site_id = " + siteId + " AND status = 1");

	int newId = lesson.getSequence();
	lesson.item("id", newId);
	lesson.item("site_id", siteId);
	lesson.item("lesson_nm", f.get("lesson_nm"));
	lesson.item("onoff_type", "T"); //오프라인
	lesson.item("lesson_type", lessonType);
	lesson.item("start_url", f.get("room_type"));
	lesson.item("lesson_hour", f.getDouble("lesson_hour"));
	lesson.item("total_time", f.getInt("total_time"));
	lesson.item("complete_time", f.getInt("complete_time"));
	lesson.item("content_width", f.getInt("content_width"));
	lesson.item("content_height", f.getInt("content_height"));
	lesson.item("manager_id", !courseManagerBlock ? f.getInt("manager_id") : userId);
	lesson.item("reg_date", sysNow);
	lesson.item("status", f.getInt("status"));

	if(!lesson.insert()) { m.jsAlert("등록하는 중 오류가 발생했습니다[2]."); return; }

	//임시로 올려진 파일들의 게시물 아이디 지정
	file.updateTempFile(f.getInt("temp_id"), newId, "lesson");

	int maxChapter = courseLesson.getOneInt("SELECT MAX(chapter) FROM " + courseLesson.table + " WHERE course_id = " + cid);

	courseLesson.item("course_id", cid);
	courseLesson.item("site_id", siteId);
	courseLesson.item("start_day", 0);
	courseLesson.item("period", 0);
	courseLesson.item("tutor_id", f.getInt("tutor_id"));
	courseLesson.item("twoway_url", twowayUrl);
	courseLesson.item("start_date", sdate);
	courseLesson.item("end_date", sdate);
	courseLesson.item("start_time", startTime);
	courseLesson.item("end_time", endTime);

	courseLesson.item("progress_yn", "Y");
	courseLesson.item("status", 1);
	courseLesson.item("lesson_id", newId);
	courseLesson.item("chapter", ++maxChapter);
	courseLesson.item("host_num", hostNum);

	if(!courseLesson.insert()) { m.jsAlert("등록하는 중 오류가 발생했습니다[3]."); return; }

	courseLesson.autoSort(cid);
	m.js("try { parent.opener.location.href = parent.opener.location.href; } catch(e) { } parent.window.close();");
	return;
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

p.setVar("modify", false);
p.setVar("study_sdate", courseInfo.s("study_sdate"));
p.setVar("study_edate", courseInfo.s("study_edate"));
p.setVar("lesson_id", Malgn.getRandInt(-2000000, 1990000));

p.setLoop("tutors", tutors);
p.setLoop("managers", user.getManagers(siteId));

p.setLoop("hours", mcal.getHours());
p.setLoop("minutes", mcal.getMinutes(5));

p.setLoop("status_list", Malgn.arr2loop(lesson.statusList));
p.setLoop("lesson_types", Malgn.arr2loop(lesson.twowayTypes));

p.setLoop("boda_template_nums", boda.getTemplates(SiteConfig.getArr("boda_template")));

p.display();

%>