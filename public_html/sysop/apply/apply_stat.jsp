<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정하여야 합니다."); return; }

//객체
ApplyDao applyDao = new ApplyDao();
ApplyUserDao applyUserDao = new ApplyUserDao();
UserDao userDao = new UserDao(isBlindUser);

//정보
DataSet info = applyDao.find("id = " + id + " AND status != -1 AND site_id = " + siteId);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//폼체크
f.addElement("etc_field", info.s("etc_field"), "hname:'필드'");
if(!"".equals(info.s("etc_field"))) {
    HashMap<String, Object> sub = Json.toMap(info.s("etc_field"));
    for(String key : sub.keySet()) {
        info.put(key, sub.get(key).toString());
    }
}

if(m.isPost()){

    int delCount = 0;
    String[] idx = f.getArr("idx");
    if(-1 == applyUserDao.execute(
        "UPDATE " + applyUserDao.table + " SET status = -1 WHERE id IN (" + Malgn.join(",", idx) + ")"
    )) {
        m.jsError("삭제에 실패하였습니다.");
        return;
    }

    m.jsReplace("apply_stat.jsp?" + m.qs("idx"));
    return;
}

//정보-문항키
ArrayList<String> kv = new ArrayList<String>();
ArrayList<String> keys = new ArrayList<String>();
DataSet temp = new DataSet();
temp.unserialize("[" + info.s("etc_field") + "]");
String[] fieldArr = temp.getKeys();
//Arrays.sort(fieldArr);
//for(int i = 0; i < fieldArr.length; i++) {
//    if(-1 < fieldArr[i].indexOf("etc_subject") && !"".equals(temp.s(m.replace(fieldArr[i], "etc_subject", "etc_type")))) {
//        kv.add(m.replace(fieldArr[i], "etc_subject", "answer_value") + "=>" + temp.s(fieldArr[i]));
//        keys.add(m.replace(fieldArr[i], "etc_subject", "answer_value"));
//    }
//}
Map<Integer, String> sortedMap = new TreeMap<>();
for (String key : temp.getKeys()) {
    if (key.contains("etc_subject")) {
        try {
            int num = Integer.parseInt(key.replaceAll("\\D", ""));
            sortedMap.put(num, key);
        } catch (NumberFormatException e) {
            m.errorLog("Exception : 숫자 변환 오류", e);
        }
    }
}

for (String field : sortedMap.values()) {
    if (!"".equals(temp.s(m.replace(field, "etc_subject", "etc_type")))) {
        kv.add(m.replace(field, "etc_subject", "answer_value") + "=>" + temp.s(field));
        keys.add(m.replace(field, "etc_subject", "answer_value"));
    }
}

String[] keysArr = keys.toArray(new String[0]);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 20000 : f.getInt("s_listnum", 20));
lm.setTable(
    applyUserDao.table + " a "
    + " INNER JOIN " + applyDao.table + " ap ON a.apply_id = ap.id "
    + " LEFT JOIN " + userDao.table + " u ON a.user_id = u.id "
);
lm.setFields("a.*, ap.apply_nm, ap.etc_field, u.login_id");
lm.addWhere("a.status = 1");
lm.addWhere("a.apply_id = " + id);
lm.setOrderBy("a.reg_date DESC");

//포맷팅
DataSet list = lm.getDataSet();
while(list.next()) {
    list.put("reg_date_conv", Malgn.time("yyyy-MM-dd", list.s("reg_date")));
    list.put("mobile_conv", "-");
    list.put("mobile_conv", !"".equals(list.s("mobile")) ? list.s("mobile") : "" );
    userDao.maskInfo(list);

    DataSet answer = Json.decode(list.s("answer"));
    if(answer.next()) {
        for(int i = 0; i < keysArr.length; i++) {
            list.put(keysArr[i], answer.s(keysArr[i]));
        }
    }
}

//기록-개인정보조회
if("".equals(m.rs("mode")) && list.size() > 0 && !isBlindUser) _log.add("L", "신청자관리", list.size(), inquiryPurpose, list);

//엑셀
if("excel".equals(m.rs("mode"))) {
    if(list.size() > 0 && !isBlindUser) _log.add("E", "신청자관리", list.size(), inquiryPurpose, list);

    ArrayList<String> excelList = new ArrayList<String>(Arrays.asList("__ord=>No", "apply_nm=>신청서명", "login_id=>로그인아이디", "user_nm=>신청자명", "email=>이메일", "mobile_conv=>휴대전화번호"));
    excelList.addAll(kv);
    excelList.add("reg_date_conv=>등록일");

    ExcelWriter ex = new ExcelWriter(response, "신청서내용(" + m.time("yyyy-MM-dd") + ").xls");
    ex.setData(list, excelList.toArray(new String[0]), "신청서내용(" + m.time("yyyy-MM-dd") + ")");
    ex.write();
    return;
}

//출력
p.setLayout(ch);
p.setBody("apply.apply_stat");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);

p.display();

%>