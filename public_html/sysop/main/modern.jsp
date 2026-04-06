<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

// 1depth 메뉴 조회 (top.jsp 와 동일)
MenuLocaleDao menuLocale = new MenuLocaleDao();
DataSet list = Menu.query(
	"SELECT b.id, MAX(b.menu_type) type, MAX(b.parent_id) parent_id, MAX(COALESCE(ml.menu_locale_nm, b.menu_nm)) name, MAX(b.sort) sort, MAX(b.link) link, MAX(b.depth) depth, MAX(b.target) target, MAX(b.icon) icon "
	+ " FROM " + new UserMenuDao().table + " a "
	+ " INNER JOIN " + Menu.table + " b ON a.menu_id = b.id AND b.status = 1 AND b.menu_type = 'ADMIN' AND b.id > 0 "
	+ " INNER JOIN " + SiteMenu.table + " sm ON a.menu_id = sm.menu_id AND sm.site_id = " + siteId
	+ " LEFT JOIN " + menuLocale.table + " ml ON b.id = ml.menu_id AND ml.locale_cd = 'default' "
	+ " WHERE b.parent_id = 0 AND b.display_yn = 'Y' "
	+ (!"S".equals(userKind) ? " AND a.user_id = " + userId : "")
	+ " GROUP BY b.id "
	+ " ORDER BY MAX(b.sort) ASC"
);
if(list.size() == 0) {
	m.jsAlert("접근 허용된 관리메뉴가 없습니다.\\n관리자에게 문의하세요.");
	m.jsReplace("../main/logout.jsp", "top");
	return;
}

p.setLayout("modern");
p.setBody("main.modern_body");
p.setVar("user_name", userName);
p.setLoop("list", list);
p.display();

%>