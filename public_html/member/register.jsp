<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 유효성 검증 규칙 설정
f.addElement("email", null, "required:'Y', type:'email'");
f.addElement("passwd", null, "required:'Y', minlength:6");
f.addElement("passwd_confirm", null, "required:'Y', minlength:6");
f.addElement("name", null, "required:'Y', minlength:2");
f.addElement("phone", null, "required:'Y'");

// POST 처리 (회원가입)
if(m.isPost() && f.validate()) {
    // 비밀번호 확인 (비교가 필요한 경우만 변수화)
    String passwd = f.get("passwd");
    if(!passwd.equals(f.get("passwd_confirm"))) {
        j.error("비밀번호가 일치하지 않습니다.");
        return;
    }

    UserDao user = new UserDao();

    // 이메일 중복 체크 (메소드 호출에 필요한 경우만 변수화)
    String email = f.get("email");
    if(user.isDuplicateEmail(email)) {
        j.error("이미 등록된 이메일입니다.");
        return;
    }

    // 회원 정보 저장
    user.item("email", email);
    user.item("passwd", Malgn.sha256(passwd));
    user.item("name", f.get("name"));
    user.item("phone", f.get("phone"));
    user.item("reg_date", m.time());
    user.item("status", 1);

    if(user.insert()) {
        j.success("회원가입이 완료되었습니다.");
    } else {
        j.error("회원가입 실패: " + user.getErrMsg());
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("auth");
p.setBody("member.register");
p.setVar("title", "회원가입");
p.setVar("form_script", f.getScript());
p.display();

%>