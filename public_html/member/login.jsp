<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

// 이미 로그인된 경우 메인으로 이동
if(isLogin) {
    m.jsAlert("이미 로그인되어 있습니다.");
    m.jsReplace("/");
    return;
}

// 유효성 검증 규칙 설정
f.addElement("email", null, "required:'Y', type:'email'");
f.addElement("passwd", null, "required:'Y'");

// POST 처리 (로그인)
if(m.isPost() && f.validate()) {
    UserDao user = new UserDao();
    DataSet info = user.checkLogin(f.get("email"), Malgn.sha256(f.get("passwd")));

    if(info.next()) {
        // 로그인 성공 - Auth에 정보 저장
        auth.put("user_id", info.i("id"));
        auth.put("user_name", info.s("name"));
        auth.put("user_email", info.s("email"));
        auth.save();

        j.success(info.s("name") + "님 환영합니다!");
    } else {
        j.error("이메일 또는 비밀번호가 올바르지 않습니다.");
    }
    return;
}

// GET 처리 (폼 표시)
p.setLayout("auth");
p.setBody("member.login");
p.setVar("title", "로그인");
p.setVar("form_script", f.getScript());
p.display();

%>