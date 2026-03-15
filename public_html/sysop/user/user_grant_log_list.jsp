<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.util.regex.*, jxl.write.*" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(142, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
ActionLogDao actionLog = new ActionLogDao();
UserDao user = new UserDao(isBlindUser);

//폼체크
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);
f.addElement("s_listnum", null, null);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 20000 : f.getInt("s_listnum", 20));
lm.setTable(
    actionLog.table + " a "
    + " INNER JOIN " + user.table + " u ON a.module_id = u.id "
    + " INNER JOIN " + user.table + " m ON a.user_id = m.id "
);
lm.setFields("a.*, u.user_nm, u.login_id, m.user_nm manager_nm, m.login_id manager_login_id");
lm.addWhere("a.status != -1");
lm.addWhere("a.site_id = " + siteId);
lm.addWhere("a.module = 'user_grant'");
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else lm.addSearch("u.user_nm,m.user_nm", f.get("s_keyword"), "LIKE");
lm.setOrderBy("a.id DESC");

//포멧팅
DataSet list = lm.getDataSet();
while(list.next()) {
    list.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm:ss", list.s("reg_date")));
    list.put("before_info_conv", m.cutString(list.s("before_info"), 50));
    list.put("after_info_conv", m.cutString(list.s("after_info"), 50));
    user.maskInfo(list);
}

DataSet data = new DataSet();
WritableCellFormat cellFormat = new WritableCellFormat();
cellFormat.setBackground(jxl.format.Colour.GREY_25_PERCENT);
WritableCellFormat cellFormat2 = new WritableCellFormat();
cellFormat2.setBackground(jxl.format.Colour.ICE_BLUE);
//엑셀
if("excel".equals(m.rs("mode"))) {

    DataSet exList = actionLog.query(
            " SELECT b.id, u.user_nm, u.user_kind, u.login_id, m.user_nm manager_nm, m.login_id manager_login_id , b.REG_DATE, '변경전' vtype, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[0].menu_nm')) bf0, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[1].menu_nm')) bf1, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[2].menu_nm')) bf2, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[3].menu_nm')) bf3, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[4].menu_nm')) bf4, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[5].menu_nm')) bf5, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[6].menu_nm')) bf6, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[7].menu_nm')) bf7, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[8].menu_nm')) bf8, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[9].menu_nm')) bf9, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[10].menu_nm')) bf10, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[11].menu_nm')) bf11, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[12].menu_nm')) bf12, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[13].menu_nm')) bf13, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[14].menu_nm')) bf14, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[15].menu_nm')) bf15, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[16].menu_nm')) bf16, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[17].menu_nm')) bf17, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[18].menu_nm')) bf18, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[19].menu_nm')) bf19, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[20].menu_nm')) bf20, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[21].menu_nm')) bf21, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[22].menu_nm')) bf22, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[23].menu_nm')) bf23, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[24].menu_nm')) bf24, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[25].menu_nm')) bf25, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[26].menu_nm')) bf26, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[27].menu_nm')) bf27, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[28].menu_nm')) bf28, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[29].menu_nm')) bf29, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[30].menu_nm')) bf30, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[31].menu_nm')) bf31, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[32].menu_nm')) bf32, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[33].menu_nm')) bf33, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[34].menu_nm')) bf34, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[35].menu_nm')) bf35, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[36].menu_nm')) bf36, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[37].menu_nm')) bf37, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[38].menu_nm')) bf38, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[39].menu_nm')) bf39, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[40].menu_nm')) bf40, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[41].menu_nm')) bf41, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[42].menu_nm')) bf42, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[43].menu_nm')) bf43, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[44].menu_nm')) bf44, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[45].menu_nm')) bf45, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[46].menu_nm')) bf46, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[47].menu_nm')) bf47, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[48].menu_nm')) bf48, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[49].menu_nm')) bf49, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[50].menu_nm')) bf50, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[51].menu_nm')) bf51, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[52].menu_nm')) bf52, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[53].menu_nm')) bf53, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[54].menu_nm')) bf54, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[55].menu_nm')) bf55, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[56].menu_nm')) bf56, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[57].menu_nm')) bf57, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[58].menu_nm')) bf58, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[59].menu_nm')) bf59, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[60].menu_nm')) bf60, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[61].menu_nm')) bf61, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[62].menu_nm')) bf62, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[63].menu_nm')) bf63, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[64].menu_nm')) bf64, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[65].menu_nm')) bf65, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[66].menu_nm')) bf66, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[67].menu_nm')) bf67, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[68].menu_nm')) bf68, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[69].menu_nm')) bf69, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[70].menu_nm')) bf70, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[71].menu_nm')) bf71, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[72].menu_nm')) bf72, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[73].menu_nm')) bf73, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[74].menu_nm')) bf74, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[75].menu_nm')) bf75, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[76].menu_nm')) bf76, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[77].menu_nm')) bf77, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[78].menu_nm')) bf78, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[79].menu_nm')) bf79, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[80].menu_nm')) bf80, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[81].menu_nm')) bf81, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[82].menu_nm')) bf82, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[83].menu_nm')) bf83, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[84].menu_nm')) bf84, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[85].menu_nm')) bf85, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[86].menu_nm')) bf86, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[87].menu_nm')) bf87, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[88].menu_nm')) bf88, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[89].menu_nm')) bf89, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[90].menu_nm')) bf90, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[91].menu_nm')) bf91, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[92].menu_nm')) bf92, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[93].menu_nm')) bf93, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[94].menu_nm')) bf94, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(b.before_info), b.before_info, '[]'), '$[95].menu_nm')) bf95 "
            + " FROM TB_ACTION_LOG b "
            + " INNER JOIN TB_USER u ON b.module_id = u.id "
            + " INNER JOIN TB_USER m ON b.user_id = m.id "
            + " WHERE b.status != -1 AND b.site_id = 1 AND b.module = 'user_grant' "
            + " UNION ALL "
            + " SELECT a.ID, '','','','','','', '변경후' vtype, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[0].menu_nm')) af0, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[1].menu_nm')) af1, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[2].menu_nm')) af2, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[3].menu_nm')) af3, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[4].menu_nm')) af4, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[5].menu_nm')) af5, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[6].menu_nm')) af6, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[7].menu_nm')) af7, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[8].menu_nm')) af8, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[9].menu_nm')) af9, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[10].menu_nm')) af10, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[11].menu_nm')) af11, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[12].menu_nm')) af12, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[13].menu_nm')) af13, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[14].menu_nm')) af14, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[15].menu_nm')) af15, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[16].menu_nm')) af16, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[17].menu_nm')) af17, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[18].menu_nm')) af18, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[19].menu_nm')) af19, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[20].menu_nm')) af20, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[21].menu_nm')) af21, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[22].menu_nm')) af22, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[23].menu_nm')) af23, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[24].menu_nm')) af24, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[25].menu_nm')) af25, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[26].menu_nm')) af26, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[27].menu_nm')) af27, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[28].menu_nm')) af28, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[29].menu_nm')) af29, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[30].menu_nm')) af30, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[31].menu_nm')) af31, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[32].menu_nm')) af32, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[33].menu_nm')) af33, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[34].menu_nm')) af34, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[35].menu_nm')) af35, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[36].menu_nm')) af36, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[37].menu_nm')) af37, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[38].menu_nm')) af38, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[39].menu_nm')) af39, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[40].menu_nm')) af40, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[41].menu_nm')) af41, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[42].menu_nm')) af42, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[43].menu_nm')) af43, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[44].menu_nm')) af44, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[45].menu_nm')) af45, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[46].menu_nm')) af46, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[47].menu_nm')) af47, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[48].menu_nm')) af48, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[49].menu_nm')) af49, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[50].menu_nm')) af50, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[51].menu_nm')) af51, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[52].menu_nm')) af52, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[53].menu_nm')) af53, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[54].menu_nm')) af54, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[55].menu_nm')) af55, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[56].menu_nm')) af56, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[57].menu_nm')) af57, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[58].menu_nm')) af58, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[59].menu_nm')) af59, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[60].menu_nm')) af60, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[61].menu_nm')) af61, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[62].menu_nm')) af62, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[63].menu_nm')) af63, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[64].menu_nm')) af64, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[65].menu_nm')) af65, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[66].menu_nm')) af66, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[67].menu_nm')) af67, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[68].menu_nm')) af68, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[69].menu_nm')) af69, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[70].menu_nm')) af70, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[71].menu_nm')) af71, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[72].menu_nm')) af72, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[73].menu_nm')) af73, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[74].menu_nm')) af74, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[75].menu_nm')) af75, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[76].menu_nm')) af76, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[77].menu_nm')) af77, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[78].menu_nm')) af78, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[79].menu_nm')) af79, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[80].menu_nm')) af80, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[81].menu_nm')) af81, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[82].menu_nm')) af82, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[83].menu_nm')) af83, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[84].menu_nm')) af84, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[85].menu_nm')) af85, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[86].menu_nm')) af86, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[87].menu_nm')) af87, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[88].menu_nm')) af88, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[89].menu_nm')) af89, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[90].menu_nm')) af90, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[91].menu_nm')) af91, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[92].menu_nm')) af92, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[93].menu_nm')) af93, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[94].menu_nm')) af94, "
            + " JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(a.after_info), a.after_info, '[]'), '$[95].menu_nm')) af95 "
            + " FROM TB_ACTION_LOG a "
            + " WHERE a.status != -1 AND a.site_id = 1 AND a.module = 'user_grant' "
            + " ORDER BY id DESC, login_id DESC "
    );
    ExcelWriter ex = new ExcelWriter(response, "관리자권한이력관리(" + m.time("yyyy-MM-dd") + ").xls");
    ex.setData(data,
       new String[] { "__ord=>No", "vtype=>변경전후","user_kind=>유형", "user_nm=>회원", "login_id=>로그인아이디",
        "manager_nm=>실행자", "manager_login_id=>실행자로그인아이디", "reg_date=>등록일",
        "항목1","항목2","항목3","항목4","항목5","항목6","항목7","항목8","항목9","항목10",
        "항목11","항목12","항목13","항목14","항목15","항목16","항목17","항목18","항목19","항목20",
        "항목21","항목22","항목23","항목24","항목25","항목26","항목27","항목28","항목29","항목30",
        "항목31","항목32","항목33","항목34","항목35","항목36","항목37","항목38","항목39","항목40",
        "항목41","항목42","항목43","항목44","항목45","항목46","항목47","항목48","항목49","항목50",
        "항목51","항목52","항목53","항목54","항목55","항목56","항목57","항목58","항목59","항목60",
        "항목61","항목62","항목63","항목64","항목65","항목66","항목67","항목68","항목69","항목70",
        "항목71","항목72","항목73","항목74","항목75","항목76","항목77","항목78","항목79","항목80",
        "항목81","항목82","항목83","항목84","항목85","항목86","항목87","항목88","항목89","항목90",
        "항목91","항목92","항목93","항목94","항목95"
    }, "개인정보조회기록(" + m.time("yyyy-MM-dd") + ")");
    data.clear();

    int startY = 3;
    String beforeYn = "Y";
    while(exList.next()){
        if("Y".equals(beforeYn)) {

            ex.put(0, startY, exList.s("__ord"), cellFormat);
            ex.put(1, startY, exList.s("vtype"), cellFormat);
            ex.put(2, startY, m.getItem(exList.s("user_kind"), user.kinds), cellFormat);
            ex.put(3, startY, exList.s("user_nm"), cellFormat);
            ex.put(4, startY, exList.s("login_id"), cellFormat);
            ex.put(5, startY, exList.s("manager_nm"), cellFormat);
            ex.put(6, startY, exList.s("manager_login_id"), cellFormat);
            ex.put(7, startY, exList.s("reg_date"), cellFormat);
//            ex.merge(1,startY,1,startY + 1); 색깔이나 정렬 문제로 머지해봐야 보기 안좋음
//            ex.merge(2,startY,2,startY + 1);
//            ex.merge(3,startY,3,startY + 1);
//            ex.merge(4,startY,4,startY + 1);
//            ex.merge(5,startY,5,startY + 1);
//            ex.merge(6,startY,6,startY + 1);
//            ex.merge(7,startY,7,startY + 1);
            ex.put(8, startY, exList.s("bf0"), cellFormat);
            ex.put(9, startY, exList.s("bf1"), cellFormat);
            ex.put(10, startY, exList.s("bf2"), cellFormat);
            ex.put(11, startY, exList.s("bf3"), cellFormat);
            ex.put(12, startY, exList.s("bf4"), cellFormat);
            ex.put(13, startY, exList.s("bf5"), cellFormat);
            ex.put(14, startY, exList.s("bf6"), cellFormat);
            ex.put(15, startY, exList.s("bf7"), cellFormat);
            ex.put(16, startY, exList.s("bf8"), cellFormat);
            ex.put(17, startY, exList.s("bf9"), cellFormat);
            ex.put(18, startY, exList.s("bf10"), cellFormat);
            ex.put(19, startY, exList.s("bf11"), cellFormat);
            ex.put(20, startY, exList.s("bf12"), cellFormat);
            ex.put(21, startY, exList.s("bf13"), cellFormat);
            ex.put(22, startY, exList.s("bf14"), cellFormat);
            ex.put(23, startY, exList.s("bf15"), cellFormat);
            ex.put(24, startY, exList.s("bf16"), cellFormat);
            ex.put(25, startY, exList.s("bf17"), cellFormat);
            ex.put(26, startY, exList.s("bf18"), cellFormat);
            ex.put(27, startY, exList.s("bf19"), cellFormat);
            ex.put(28, startY, exList.s("bf20"), cellFormat);
            ex.put(29, startY, exList.s("bf21"), cellFormat);
            ex.put(30, startY, exList.s("bf22"), cellFormat);
            ex.put(31, startY, exList.s("bf23"), cellFormat);
            ex.put(32, startY, exList.s("bf24"), cellFormat);
            ex.put(33, startY, exList.s("bf25"), cellFormat);
            ex.put(34, startY, exList.s("bf26"), cellFormat);
            ex.put(35, startY, exList.s("bf27"), cellFormat);
            ex.put(36, startY, exList.s("bf28"), cellFormat);
            ex.put(37, startY, exList.s("bf29"), cellFormat);
            ex.put(38, startY, exList.s("bf30"), cellFormat);
            ex.put(39, startY, exList.s("bf31"), cellFormat);
            ex.put(40, startY, exList.s("bf32"), cellFormat);
            ex.put(41, startY, exList.s("bf33"), cellFormat);
            ex.put(42, startY, exList.s("bf34"), cellFormat);
            ex.put(43, startY, exList.s("bf35"), cellFormat);
            ex.put(44, startY, exList.s("bf36"), cellFormat);
            ex.put(45, startY, exList.s("bf37"), cellFormat);
            ex.put(46, startY, exList.s("bf38"), cellFormat);
            ex.put(47, startY, exList.s("bf39"), cellFormat);
            ex.put(48, startY, exList.s("bf40"), cellFormat);
            ex.put(49, startY, exList.s("bf41"), cellFormat);
            ex.put(50, startY, exList.s("bf42"), cellFormat);
            ex.put(51, startY, exList.s("bf43"), cellFormat);
            ex.put(52, startY, exList.s("bf44"), cellFormat);
            ex.put(53, startY, exList.s("bf45"), cellFormat);
            ex.put(54, startY, exList.s("bf46"), cellFormat);
            ex.put(55, startY, exList.s("bf47"), cellFormat);
            ex.put(56, startY, exList.s("bf48"), cellFormat);
            ex.put(57, startY, exList.s("bf49"), cellFormat);
            ex.put(58, startY, exList.s("bf50"), cellFormat);
            ex.put(59, startY, exList.s("bf51"), cellFormat);
            ex.put(60, startY, exList.s("bf52"), cellFormat);
            ex.put(61, startY, exList.s("bf53"), cellFormat);
            ex.put(62, startY, exList.s("bf54"), cellFormat);
            ex.put(63, startY, exList.s("bf55"), cellFormat);
            ex.put(64, startY, exList.s("bf56"), cellFormat);
            ex.put(65, startY, exList.s("bf57"), cellFormat);
            ex.put(66, startY, exList.s("bf58"), cellFormat);
            ex.put(67, startY, exList.s("bf59"), cellFormat);
            ex.put(68, startY, exList.s("bf60"), cellFormat);
            ex.put(69, startY, exList.s("bf61"), cellFormat);
            ex.put(70, startY, exList.s("bf62"), cellFormat);
            ex.put(71, startY, exList.s("bf63"), cellFormat);
            ex.put(72, startY, exList.s("bf64"), cellFormat);
            ex.put(73, startY, exList.s("bf65"), cellFormat);
            ex.put(74, startY, exList.s("bf66"), cellFormat);
            ex.put(75, startY, exList.s("bf67"), cellFormat);
            ex.put(76, startY, exList.s("bf68"), cellFormat);
            ex.put(77, startY, exList.s("bf69"), cellFormat);
            ex.put(78, startY, exList.s("bf70"), cellFormat);
            ex.put(79, startY, exList.s("bf71"), cellFormat);
            ex.put(80, startY, exList.s("bf72"), cellFormat);
            ex.put(81, startY, exList.s("bf73"), cellFormat);
            ex.put(82, startY, exList.s("bf74"), cellFormat);
            ex.put(83, startY, exList.s("bf75"), cellFormat);
            ex.put(84, startY, exList.s("bf76"), cellFormat);
            ex.put(85, startY, exList.s("bf77"), cellFormat);
            ex.put(86, startY, exList.s("bf78"), cellFormat);
            ex.put(87, startY, exList.s("bf79"), cellFormat);
            ex.put(88, startY, exList.s("bf80"), cellFormat);
            ex.put(89, startY, exList.s("bf81"), cellFormat);
            ex.put(90, startY, exList.s("bf82"), cellFormat);
            ex.put(91, startY, exList.s("bf83"), cellFormat);
            ex.put(92, startY, exList.s("bf84"), cellFormat);
            ex.put(93, startY, exList.s("bf85"), cellFormat);
            ex.put(94, startY, exList.s("bf86"), cellFormat);
            ex.put(95, startY, exList.s("bf87"), cellFormat);
            ex.put(96, startY, exList.s("bf88"), cellFormat);
            ex.put(97, startY, exList.s("bf89"), cellFormat);
            ex.put(98, startY, exList.s("bf90"), cellFormat);
            ex.put(99, startY, exList.s("bf91"), cellFormat);
            ex.put(100, startY, exList.s("bf92"), cellFormat);
            ex.put(101, startY, exList.s("bf93"), cellFormat);
            ex.put(102, startY, exList.s("bf94"), cellFormat);
            beforeYn = "N";
            startY++;
        } else {
            ex.put(0, startY, exList.s("__ord"), cellFormat2);
            ex.put(1, startY, exList.s("vtype"), cellFormat2);
            ex.put(2, startY, m.getItem(exList.s("user_kind"), user.kinds) , cellFormat2);
            ex.put(3, startY, exList.s("user_nm"), cellFormat2);
            ex.put(4, startY, exList.s("login_id"), cellFormat2);
            ex.put(5, startY, exList.s("manager_nm"), cellFormat2);
            ex.put(6, startY, exList.s("manager_login_id"), cellFormat2);
            ex.put(7, startY, exList.s("reg_date"), cellFormat2);
            ex.put(8, startY, exList.s("bf0"), cellFormat2);
            ex.put(9, startY, exList.s("bf1"), cellFormat2);
            ex.put(10, startY, exList.s("bf2"), cellFormat2);
            ex.put(11, startY, exList.s("bf3"), cellFormat2);
            ex.put(12, startY, exList.s("bf4"), cellFormat2);
            ex.put(13, startY, exList.s("bf5"), cellFormat2);
            ex.put(14, startY, exList.s("bf6"), cellFormat2);
            ex.put(15, startY, exList.s("bf7"), cellFormat2);
            ex.put(16, startY, exList.s("bf8"), cellFormat2);
            ex.put(17, startY, exList.s("bf9"), cellFormat2);
            ex.put(18, startY, exList.s("bf10"), cellFormat2);
            ex.put(19, startY, exList.s("bf11"), cellFormat2);
            ex.put(20, startY, exList.s("bf12"), cellFormat2);
            ex.put(21, startY, exList.s("bf13"), cellFormat2);
            ex.put(22, startY, exList.s("bf14"), cellFormat2);
            ex.put(23, startY, exList.s("bf15"), cellFormat2);
            ex.put(24, startY, exList.s("bf16"), cellFormat2);
            ex.put(25, startY, exList.s("bf17"), cellFormat2);
            ex.put(26, startY, exList.s("bf18"), cellFormat2);
            ex.put(27, startY, exList.s("bf19"), cellFormat2);
            ex.put(28, startY, exList.s("bf20"), cellFormat2);
            ex.put(29, startY, exList.s("bf21"), cellFormat2);
            ex.put(30, startY, exList.s("bf22"), cellFormat2);
            ex.put(31, startY, exList.s("bf23"), cellFormat2);
            ex.put(32, startY, exList.s("bf24"), cellFormat2);
            ex.put(33, startY, exList.s("bf25"), cellFormat2);
            ex.put(34, startY, exList.s("bf26"), cellFormat2);
            ex.put(35, startY, exList.s("bf27"), cellFormat2);
            ex.put(36, startY, exList.s("bf28"), cellFormat2);
            ex.put(37, startY, exList.s("bf29"), cellFormat2);
            ex.put(38, startY, exList.s("bf30"), cellFormat2);
            ex.put(39, startY, exList.s("bf31"), cellFormat2);
            ex.put(40, startY, exList.s("bf32"), cellFormat2);
            ex.put(41, startY, exList.s("bf33"), cellFormat2);
            ex.put(42, startY, exList.s("bf34"), cellFormat2);
            ex.put(43, startY, exList.s("bf35"), cellFormat2);
            ex.put(44, startY, exList.s("bf36"), cellFormat2);
            ex.put(45, startY, exList.s("bf37"), cellFormat2);
            ex.put(46, startY, exList.s("bf38"), cellFormat2);
            ex.put(47, startY, exList.s("bf39"), cellFormat2);
            ex.put(48, startY, exList.s("bf40"), cellFormat2);
            ex.put(49, startY, exList.s("bf41"), cellFormat2);
            ex.put(50, startY, exList.s("bf42"), cellFormat2);
            ex.put(51, startY, exList.s("bf43"), cellFormat2);
            ex.put(52, startY, exList.s("bf44"), cellFormat2);
            ex.put(53, startY, exList.s("bf45"), cellFormat2);
            ex.put(54, startY, exList.s("bf46"), cellFormat2);
            ex.put(55, startY, exList.s("bf47"), cellFormat2);
            ex.put(56, startY, exList.s("bf48"), cellFormat2);
            ex.put(57, startY, exList.s("bf49"), cellFormat2);
            ex.put(58, startY, exList.s("bf50"), cellFormat2);
            ex.put(59, startY, exList.s("bf51"), cellFormat2);
            ex.put(60, startY, exList.s("bf52"), cellFormat2);
            ex.put(61, startY, exList.s("bf53"), cellFormat2);
            ex.put(62, startY, exList.s("bf54"), cellFormat2);
            ex.put(63, startY, exList.s("bf55"), cellFormat2);
            ex.put(64, startY, exList.s("bf56"), cellFormat2);
            ex.put(65, startY, exList.s("bf57"), cellFormat2);
            ex.put(66, startY, exList.s("bf58"), cellFormat2);
            ex.put(67, startY, exList.s("bf59"), cellFormat2);
            ex.put(68, startY, exList.s("bf60"), cellFormat2);
            ex.put(69, startY, exList.s("bf61"), cellFormat2);
            ex.put(70, startY, exList.s("bf62"), cellFormat2);
            ex.put(71, startY, exList.s("bf63"), cellFormat2);
            ex.put(72, startY, exList.s("bf64"), cellFormat2);
            ex.put(73, startY, exList.s("bf65"), cellFormat2);
            ex.put(74, startY, exList.s("bf66"), cellFormat2);
            ex.put(75, startY, exList.s("bf67"), cellFormat2);
            ex.put(76, startY, exList.s("bf68"), cellFormat2);
            ex.put(77, startY, exList.s("bf69"), cellFormat2);
            ex.put(78, startY, exList.s("bf70"), cellFormat2);
            ex.put(79, startY, exList.s("bf71"), cellFormat2);
            ex.put(80, startY, exList.s("bf72"), cellFormat2);
            ex.put(81, startY, exList.s("bf73"), cellFormat2);
            ex.put(82, startY, exList.s("bf74"), cellFormat2);
            ex.put(83, startY, exList.s("bf75"), cellFormat2);
            ex.put(84, startY, exList.s("bf76"), cellFormat2);
            ex.put(85, startY, exList.s("bf77"), cellFormat2);
            ex.put(86, startY, exList.s("bf78"), cellFormat2);
            ex.put(87, startY, exList.s("bf79"), cellFormat2);
            ex.put(88, startY, exList.s("bf80"), cellFormat2);
            ex.put(89, startY, exList.s("bf81"), cellFormat2);
            ex.put(90, startY, exList.s("bf82"), cellFormat2);
            ex.put(91, startY, exList.s("bf83"), cellFormat2);
            ex.put(92, startY, exList.s("bf84"), cellFormat2);
            ex.put(93, startY, exList.s("bf85"), cellFormat2);
            ex.put(94, startY, exList.s("bf86"), cellFormat2);
            ex.put(95, startY, exList.s("bf87"), cellFormat2);
            ex.put(96, startY, exList.s("bf88"), cellFormat2);
            ex.put(97, startY, exList.s("bf89"), cellFormat2);
            ex.put(98, startY, exList.s("bf90"), cellFormat2);
            ex.put(99, startY, exList.s("bf91"), cellFormat2);
            ex.put(100, startY, exList.s("bf92"), cellFormat2);
            ex.put(101, startY, exList.s("bf93"), cellFormat2);
            ex.put(102, startY, exList.s("bf94"), cellFormat2);
            beforeYn = "Y";
            startY++;
        }
    }

    ex.write();
    return;
}

//출력
p.setBody("user.user_grant_log_list");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("pagebar", lm.getPaging());
p.setVar("list_total", lm.getTotalString());

p.display();

%>