<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//MANAGEMENT

//접근권한
if(!Menu.accessible(75, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseModuleDao courseModule = new CourseModuleDao();
CourseUserDao courseUser = new CourseUserDao();
CourseDao course = new CourseDao();
SurveyUserDao surveyUser = new SurveyUserDao();
SurveyDao survey = new SurveyDao();
SurveyItemDao surveyItem = new SurveyItemDao();
SurveyResultDao surveyResult = new SurveyResultDao();
SurveyQuestionDao surveyQuestion = new SurveyQuestionDao();
UserDao user = new UserDao();
UserDeptDao userDept = new UserDeptDao();


//=============================================================
// 1. 전체 합계용 통계
//=============================================================
DataSet totalList = surveyItem.query(
	"SELECT a.question_id, a.sort, b.* "
	+ " FROM " + surveyItem.table + " a "
	+ " INNER JOIN " + surveyQuestion.table + " b ON a.question_id = b.id "
	+ " WHERE a.status = 1 AND a.survey_id = " + id + " "
	+ " ORDER BY a.sort ASC "
);

while(totalList.next()) {
	DataSet answers = new DataSet();
	totalList.put("choice_block", "1".equals(totalList.s("question_type")) || "M".equals(totalList.s("question_type")));

	if("1".equals(totalList.s("question_type")) || "M".equals(totalList.s("question_type"))) {
		DataSet result = surveyResult.query(
			"SELECT a.answer, COUNT(*) cnt "
			+ " FROM " + surveyResult.table + " a "
			+ " INNER JOIN " + courseUser.table + " b ON a.course_user_id = b.id AND b.status IN (1,3) "
			+ " INNER JOIN " + surveyUser.table + " su ON a.survey_id = su.survey_id AND a.course_user_id = su.course_user_id AND su.status = 1 "
			+ " INNER JOIN " + user.table + " u ON u.id = b.user_id " + (deptManagerBlock ? " AND u.dept_id IN (" + userDept.getSubIdx(siteId, userDeptId) + ") " : "")
			+ " WHERE a.status = 1 AND a.survey_id = " + id + " AND a.survey_question_id = " + totalList.i("question_id") + " "
			+ " AND a.answer IS NOT NULL AND a.answer != '' "
			+ " GROUP BY a.answer "
		);

		Hashtable<String, Integer> tmpCount = new Hashtable<String, Integer>();
		int total = 0;
		while(result.next()) {
			String[] tmpArr = m.split("||", result.s("answer"));
			for(int i = 0; i < tmpArr.length; i++) {
				tmpCount.put(tmpArr[i], (tmpCount.containsKey(tmpArr[i]) ? tmpCount.get(tmpArr[i]) : 0) + result.i("cnt"));
			}
			total += result.i("cnt");
		}

		for(int i = 1; i <= totalList.i("item_cnt"); i++) {
			answers.addRow();
			answers.put("id", i);
			answers.put("name", totalList.s("item" + i));
			answers.put("s_cnt", total);
			answers.put("sel_cnt", tmpCount.containsKey(i + "") ? tmpCount.get(i + "").intValue() : 0);
			answers.put("sel_cnt_conv", m.nf(answers.i("sel_cnt")));
			answers.put("percent", total > 0 ? m.round(answers.d("sel_cnt") / answers.d("s_cnt") * 100, 2) : 0);
		}
	} else {
		DataSet result = surveyResult.query(
			"SELECT a.answer_text, c.course_nm "
			+ " FROM " + surveyResult.table + " a "
			+ " INNER JOIN " + courseUser.table + " b ON a.course_user_id = b.id AND b.status IN (1,3) "
			+ " INNER JOIN " + course.table + " c ON b.course_id = c.id "
			+ " INNER JOIN " + surveyUser.table + " su ON a.survey_id = su.survey_id AND a.course_user_id = su.course_user_id AND su.status = 1 "
			+ " INNER JOIN " + user.table + " u ON u.id = b.user_id " + (deptManagerBlock ? " AND u.dept_id IN (" + userDept.getSubIdx(siteId, userDeptId) + ") " : "")
			+ " WHERE a.status = 1 AND a.survey_id = " + id + " AND a.survey_question_id = " + totalList.i("question_id") + " "
			+ " AND a.answer_text IS NOT NULL AND a.answer_text != '' "
			+ " ORDER BY c.course_nm "
		);
		int i = 1;
		while(result.next()) {
			answers.addRow();
			answers.put("id", i++);
			answers.put("answer", result.s("answer_text"));
			answers.put("course_nm", result.s("course_nm"));
		}
	}
	totalList.put(".sub", answers);
}


//=============================================================
// 2. 과정별 통계 (2단계 평면화: 과정+문항을 하나의 list로)
//=============================================================
DataSet courseListOrigin = course.query(
	"SELECT DISTINCT c.id, c.course_nm "
	+ " FROM " + course.table + " c "
	+ " INNER JOIN " + courseModule.table + " cm ON c.id = cm.course_id AND cm.module_id = " + id + " "
	+ " WHERE c.status IN (1,3) "
	+ " ORDER BY c.id DESC "
);

DataSet list = new DataSet();
int prevCourseId = -1;

while(courseListOrigin.next()) {
	int currentCourseId = courseListOrigin.i("id");
	String currentCourseName = courseListOrigin.s("course_nm");

	DataSet questions = surveyItem.query(
		"SELECT a.question_id, a.sort, b.* "
		+ " FROM " + surveyItem.table + " a "
		+ " INNER JOIN " + surveyQuestion.table + " b ON a.question_id = b.id "
		+ " WHERE a.status = 1 AND a.survey_id = " + id + " "
		+ " ORDER BY a.sort ASC "
	);
	m.p(questions);

	while(questions.next()) {
		list.addRow();
		list.put("course_id", currentCourseId);
		list.put("course_nm", currentCourseName);
		list.put("is_first", prevCourseId != currentCourseId);
		list.put("sort", questions.i("sort"));
		list.put("question", questions.s("question"));
		list.put("choice_block", "1".equals(questions.s("question_type")) || "M".equals(questions.s("question_type")));

		DataSet answers = new DataSet();

		if("1".equals(questions.s("question_type")) || "M".equals(questions.s("question_type"))) {
			DataSet result = surveyResult.query(
				"SELECT a.answer "
				+ " FROM " + surveyResult.table + " a "
				+ " INNER JOIN " + courseUser.table + " b ON a.course_user_id = b.id AND b.status IN (1,3) AND b.course_id = " + currentCourseId + " "
				+ " INNER JOIN " + surveyUser.table + " su ON a.survey_id = su.survey_id AND a.course_user_id = su.course_user_id AND su.status = 1 "
				+ " INNER JOIN " + user.table + " u ON u.id = b.user_id " + (deptManagerBlock ? " AND u.dept_id IN (" + userDept.getSubIdx(siteId, userDeptId) + ") " : "")
				+ " WHERE a.status = 1 AND a.survey_id = " + id + " AND a.survey_question_id = " + questions.i("question_id") + " "
				+ " AND a.answer IS NOT NULL AND a.answer != '' "
				+ " GROUP BY a.answer "
			);
			

			Hashtable<String, Integer> tmpCount = new Hashtable<String, Integer>();
			int total = 0;
//			while(result.next()) {
//				String[] tmpArr = m.split("||", result.s("answer"));
//				for(int i = 0; i < tmpArr.length; i++) {
//					tmpCount.put(tmpArr[i], (tmpCount.containsKey(tmpArr[i]) ? tmpCount.get(tmpArr[i]) : 0) + result.i("cnt"));
//				}
//				total += result.i("cnt");
//			}

			while(result.next()) {
				String[] ansArr = m.split("||", result.s("answer")); // 각 선택지를 분리
				for(String ans : ansArr) {
					tmpCount.put(ans, tmpCount.getOrDefault(ans, 0) + 1); // 각 선택지 누적
					total++; // 전체 선택 수 누적
				}
			}

			for(int i = 1; i <= questions.i("item_cnt"); i++) {
				answers.addRow();
				answers.put("id", i);
				answers.put("name", questions.s("item" + i));
				answers.put("s_cnt", total);
				answers.put("sel_cnt", tmpCount.containsKey(i + "") ? tmpCount.get(i + "").intValue() : 0);
				answers.put("sel_cnt_conv", m.nf(answers.i("sel_cnt")));
				answers.put("percent", total > 0 ? m.round(answers.d("sel_cnt") / answers.d("s_cnt") * 100, 2) : 0);
			}
			m.p(answers);

		} else {
			DataSet result = surveyResult.query(
				"SELECT a.answer_text "
				+ " FROM " + surveyResult.table + " a "
				+ " INNER JOIN " + courseUser.table + " b ON a.course_user_id = b.id AND b.status IN (1,3) AND b.course_id = " + currentCourseId + " "
				+ " INNER JOIN " + surveyUser.table + " su ON a.survey_id = su.survey_id AND a.course_user_id = su.course_user_id AND su.status = 1 "
				+ " INNER JOIN " + user.table + " u ON u.id = b.user_id " + (deptManagerBlock ? " AND u.dept_id IN (" + userDept.getSubIdx(siteId, userDeptId) + ") " : "")
				+ " WHERE a.status = 1 AND a.survey_id = " + id + " AND a.survey_question_id = " + questions.i("question_id") + " "
				+ " AND a.answer_text IS NOT NULL AND a.answer_text != '' "
			);
			int i = 1;
			while(result.next()) {
				answers.addRow();
				answers.put("id", i++);
				answers.put("answer", result.s("answer_text"));
			}
		}
		list.put(".test", answers);
		prevCourseId = currentCourseId;
	}
}

//response.setHeader("Content-Disposition","attachment;filename=survey_result.xls");
//response.setHeader("Content-Description", "JSP Generated Excel");
//response.setContentType("application/vnd.ms-excel; charset=euc-kr");

//출력
p.setLayout(null);
p.setBody("survey.survey_view_excel");
p.setLoop("totalList", totalList);
p.setLoop("list", list);
p.display();

%>