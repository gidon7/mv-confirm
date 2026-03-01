<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 유효성 검증 규칙 설정
f.addElement("name", null, "required:'Y', minlength:2");
f.addElement("email", null, "required:'Y', type:'email'");
f.addElement("phone", null, "required:'Y'");
f.addElement("company", null, null);
f.addElement("position", null, null);
f.addElement("content", null, "required:'Y', minlength:10");

// POST 처리 (신청)
if(m.isPost() && f.validate()) {
    ApplyDao apply = new ApplyDao();

    apply.item("name", f.get("name"));
    apply.item("email", f.get("email"));
    apply.item("phone", f.get("phone"));
    apply.item("company", f.get("company"));
    apply.item("position", f.get("position"));
    apply.item("content", f.get("content"));
    apply.item("status", "pending");
    apply.item("reg_date", m.time());

    if(apply.insert()) {
        j.success("신청이 완료되었습니다. 빠른 시일 내에 연락드리겠습니다.");
    } else {
        j.error("신청 실패: " + apply.getErrMsg());
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("main");
p.setBody("main.apply");
p.setVar("title", "신청하기");
p.setVar("form_script", f.getScript());
p.display();

%>