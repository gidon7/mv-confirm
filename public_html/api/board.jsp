<%@ include file="/api/init.jsp" %><%

// Base path 설정 (선택사항 - 생략하면 자동으로 /api/board 사용)
api.setBasePath("/api/board");

// 게시판 목록 조회
api.get("/list", () -> {
	String keyword = m.rs("keyword");
	int page = m.ri("page");
	int pageSize = m.ri("page_size");

	if(page == 0) page = 1;
	if(pageSize == 0) pageSize = 10;

	BoardDao board = new BoardDao();
	ListManager lm = new ListManager();
	lm.setRequest(request);
	lm.setDao(board);
	lm.setPageRow(pageSize);
	lm.setTable("tb_board b LEFT JOIN tb_user u ON b.user_id = u.id");
	lm.setFields("b.id, b.title, b.hit, b.reg_date, u.name as user_name");
	lm.setWhere("b.status = 1");
	lm.addSearch("b.title,b.content", keyword, "LIKE");
	lm.setOrderBy("b.id DESC");

	DataSet list = lm.getDataSet();

	while(list.next()) {
		list.put("reg_date_format", m.time("yyyy-MM-dd HH:mm", list.s("reg_date")));
	}

	DataSet pagination = new DataSet();
	pagination.addRow();
	pagination.put("total", lm.getTotalNum());
	pagination.put("page", page);
	pagination.put("page_size", pageSize);
	pagination.put("total_pages", (int)Math.ceil((double)lm.getTotalNum() / pageSize));

	api.put("pagination", pagination);
	api.put("items", list);
	api.success("목록 조회 성공");
});

// 게시글 상세 조회
api.get("/view/:id", () -> {
	int id = api.paramInt("id");

	if(id == 0) {
		api.error("INVALID_PARAMETER", "게시글 ID가 필요합니다.");
		return;
	}

	BoardDao board = new BoardDao();
	DataSet info = board.getWithUser(id);

	if(!info.next()) {
		api.error("NOT_FOUND", "게시글을 찾을 수 없습니다.");
		return;
	}

	board.update("hit = hit + 1", "id = ?", new Object[]{id});

	info.put("reg_date_format", m.time("yyyy-MM-dd HH:mm", info.s("reg_date")));
	info.put("mod_date_format", m.time("yyyy-MM-dd HH:mm", info.s("mod_date")));
	info.put("is_author", info.i("user_id") == userId);

	api.put("board", info);
	api.success("조회 성공");
});

// 게시글 작성
api.post("/write", () -> {
	if(!isLogin) {
		api.error("UNAUTHORIZED", "로그인이 필요합니다.");
		return;
	}

	f.addElement("title", "required", "제목을 입력하세요.");
	f.addElement("content", "required", "내용을 입력하세요.");

	if(!f.validate()) {
		api.error("VALIDATION_FAILED", f.getErrorMessage());
		return;
	}

	BoardDao board = new BoardDao();
	board.item("user_id", userId);
	board.item("title", f.get("title"));
	board.item("content", f.get("content"));
	board.item("hit", 0);
	board.item("status", 1);
	board.item("reg_date", m.time("yyyyMMddHHmmss"));

	if(board.insert()) {
		api.put("board_id", board.id);
		api.success("게시글이 등록되었습니다.");
	} else {
		api.error("INSERT_FAILED", "게시글 등록에 실패했습니다.");
	}
});

// 게시글 수정
api.put("/update/:id", () -> {
	if(!isLogin) {
		api.error("UNAUTHORIZED", "로그인이 필요합니다.");
		return;
	}

	int id = api.paramInt("id");

	if(id == 0) {
		api.error("INVALID_PARAMETER", "게시글 ID가 필요합니다.");
		return;
	}

	BoardDao board = new BoardDao();
	DataSet info = board.get(id);

	if(!info.next()) {
		api.error("NOT_FOUND", "게시글을 찾을 수 없습니다.");
		return;
	}

	if(info.i("user_id") != userId) {
		api.error("FORBIDDEN", "수정 권한이 없습니다.");
		return;
	}

	f.addElement("title", "required", "제목을 입력하세요.");
	f.addElement("content", "required", "내용을 입력하세요.");

	if(!f.validate()) {
		api.error("VALIDATION_FAILED", f.getErrorMessage());
		return;
	}

	board.item("title", f.get("title"));
	board.item("content", f.get("content"));
	board.item("mod_date", m.time("yyyyMMddHHmmss"));

	if(board.update("id = ?", new Object[]{id})) {
		api.success("게시글이 수정되었습니다.");
	} else {
		api.error("UPDATE_FAILED", "게시글 수정에 실패했습니다.");
	}
});

// 게시글 삭제
api.delete("/delete/:id", () -> {
	if(!isLogin) {
		api.error("UNAUTHORIZED", "로그인이 필요합니다.");
		return;
	}

	int id = api.paramInt("id");

	if(id == 0) {
		api.error("INVALID_PARAMETER", "게시글 ID가 필요합니다.");
		return;
	}

	BoardDao board = new BoardDao();
	DataSet info = board.get(id);

	if(!info.next()) {
		api.error("NOT_FOUND", "게시글을 찾을 수 없습니다.");
		return;
	}

	if(info.i("user_id") != userId) {
		api.error("FORBIDDEN", "삭제 권한이 없습니다.");
		return;
	}

	if(board.delete("id = ?", new Object[]{id})) {
		api.success("게시글이 삭제되었습니다.");
	} else {
		api.error("DELETE_FAILED", "게시글 삭제에 실패했습니다.");
	}
});

%>
