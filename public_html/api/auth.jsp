<%@ include file="/api/init.jsp" %><%

// Base path 설정
api.setBasePath("/api/auth");

// POST /api/auth/login - 로그인
api.post("/login", () -> {
	// 유효성 검증
	f.addElement("email", "required&email", "올바른 이메일을 입력하세요.");
	f.addElement("password", "required", "비밀번호를 입력하세요.");

	if(!f.validate()) {
		api.error("VALIDATION_FAILED", f.getErrorMessage());
		return;
	}

	String email = f.get("email");
	String password = f.get("password");

	// 사용자 인증 확인
	UserDao user = new UserDao();
	DataSet info = user.getByEmail(email);

	if(!info.next()) {
		api.error("INVALID_CREDENTIALS", "이메일 또는 비밀번호가 일치하지 않습니다.");
		return;
	}

	// 비밀번호 확인 (SHA-256 해시)
	String hashedPassword = m.sha256(password);
	if(!hashedPassword.equals(info.s("password"))) {
		api.error("INVALID_CREDENTIALS", "이메일 또는 비밀번호가 일치하지 않습니다.");
		return;
	}

	// RestAPI 객체에 사용자 정보 저장
	api.setData("user_id", info.i("id"));
	api.setData("user_name", info.s("name"));
	api.setData("user_level", info.i("level"));

	// JWT 토큰 생성 (60분 유효)
	String token = api.generateToken(60);

	api.put("token", token);
	api.put("user_id", info.i("id"));
	api.put("user_name", info.s("name"));
	api.put("user_level", info.i("level"));
	api.success("로그인되었습니다.");
});

// POST /api/auth/register - 회원가입
api.post("/register", () -> {
	// 유효성 검증
	f.addElement("email", "required&email", "올바른 이메일을 입력하세요.");
	f.addElement("password", "required&min[4]", "비밀번호는 4자 이상이어야 합니다.");
	f.addElement("name", "required", "이름을 입력하세요.");

	if(!f.validate()) {
		api.error("VALIDATION_FAILED", f.getErrorMessage());
		return;
	}

	String email = f.get("email");
	String password = f.get("password");
	String name = f.get("name");

	// 이메일 중복 확인
	UserDao user = new UserDao();
	DataSet existing = user.getByEmail(email);
	if(existing.next()) {
		api.error("EMAIL_EXISTS", "이미 사용중인 이메일입니다.");
		return;
	}

	// 비밀번호 해시 (SHA-256)
	String hashedPassword = m.sha256(password);

	// 사용자 등록
	user.item("email", email);
	user.item("password", hashedPassword);
	user.item("name", name);
	user.item("level", 1);
	user.item("status", 1);
	user.item("reg_date", m.time("yyyyMMddHHmmss"));

	if(user.insert()) {
		api.put("user_id", user.id);
		api.success("회원가입이 완료되었습니다.");
	} else {
		api.error("INSERT_FAILED", "회원가입에 실패했습니다.");
	}
});

%>
