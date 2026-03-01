<%@ include file="/api/init.jsp" %><%

// Base path 설정 (선택사항)
api.setBasePath("/api/apply");

// POST /api/apply - 신청 정보 등록
api.post("/", () -> {
	// 유효성 검증
	f.addElement("name", "required", "이름을 입력하세요.");
	f.addElement("email", "required&email", "올바른 이메일을 입력하세요.");
	f.addElement("phone", "required", "전화번호를 입력하세요.");
	f.addElement("content", "required", "내용을 입력하세요.");

	if(!f.validate()) {
		api.error("VALIDATION_FAILED", f.getErrorMessage());
		return;
	}

	// 신청 정보 저장
	ApplyDao apply = new ApplyDao();
	apply.item("name", f.get("name"));
	apply.item("email", f.get("email"));
	apply.item("phone", f.get("phone"));
	apply.item("company", f.get("company"));
	apply.item("position", f.get("position"));
	apply.item("content", f.get("content"));
	apply.item("status", "pending");
	apply.item("reg_date", m.time("yyyyMMddHHmmss"));

	if(apply.insert()) {
		api.put("apply_id", apply.id);
		api.success("신청이 완료되었습니다.");
	} else {
		api.error("INSERT_FAILED", "신청 처리 중 오류가 발생했습니다.");
	}
});

%>
