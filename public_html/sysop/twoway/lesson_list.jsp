<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
CourseLessonDao courseLesson = new CourseLessonDao();
LessonDao lesson = new LessonDao();
UserDao user = new UserDao(isBlindUser);
CourseDao course = new CourseDao();

//폼체크
f.addElement("s_listnum", null, null);
f.addElement("start_date", Malgn.time("yyyy-MM-dd"), null);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? sysExcelCnt : f.getInt("s_listnum", 20));
lm.setTable(
	courseLesson.table + " a "
		+ "INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id AND l.site_id = " + siteId + " AND l.status = 1 "
		+ "INNER JOIN " + user.table + " u ON a.tutor_id = u.id AND u.status = 1 AND u.site_id = " + siteId + " "
		+ "INNER JOIN " + course.table + " c on a.course_id = c.id AND c.site_id = " + siteId + " "
);
lm.setFields("a.chapter, a.start_date, a.start_time, a.end_date, a.end_time, a.host_num, a.course_id, a.lesson_id, l.start_url, l.lesson_nm, u.id user_id, u.user_nm, u.login_id, c.course_nm");
lm.addWhere("a.status != -1");
lm.addWhere("a.site_id = " + siteId + "");
lm.addWhere("l.lesson_type IN ('15', '16')");
lm.addSearch("a.start_date", Malgn.time("yyyyMMdd", f.get("start_date", sysNow)));
lm.setOrderBy("a.start_date asc, a.start_time asc, a.end_date asc, a.end_time asc");

//포멧팅
DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("start_date_conv", Malgn.time("yyyy.MM.dd HH:mm", list.s("start_date") + list.s("start_time")));
	list.put("end_date_conv", Malgn.time("yyyy.MM.dd HH:mm", list.s("end_date") + list.s("end_time")));
	list.put("lesson_nm_conv", Malgn.cutString(list.s("lesson_nm"), 100));

	user.maskInfo(list);
}

//기록-개인정보조회
if("".equals(m.rs("mode")) && list.size() > 0 && !isBlindUser) _log.add("L", Menu.menuNm, list.size(), "이러닝 운영", list);

//엑셀
if("excel".equals(m.rs("mode"))) {
	if(list.size() > 0 && !isBlindUser) _log.add("E", Menu.menuNm, list.size(), inquiryPurpose, list);

	ExcelWriter ex = new ExcelWriter(response, "화상강의관리(" + Malgn.time("yyyy-MM-dd") + ").xls");
	ex.setData(list, new String[] { "__ord=>No", "course_nm=>과정명", "lesson_nm=>강의명", "chapter=>차시", "twoway_type_conv=>강의실유형", "start_date_conv=>시작시간", "end_date_conv=>종료시간", "login_id=>강사", "host_num=>호스트" }, "화상강의관리(" + Malgn.time("yyyy-MM-dd") + ")");
	ex.write();
	return;
}

//출력
p.setLayout("pop");
p.setBody("twoway.lesson_list");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("list_total", lm.getTotalString());
p.setVar("list_total_num", Malgn.nf(lm.getTotalNum()));
p.setVar("pagebar", lm.getPaging());

p.display();

%>