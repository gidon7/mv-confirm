<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8" %><%@ include file="init.jsp" %><%

//객체
SensSMS sensSms = new SensSMS();

//변수
String now = m.time("yyyy-MM-dd HH:mm:ss");
String requestId = m.rs("request_id");

//제한
if("".equals(requestId)) {
    out.print("{\"success\":false, \"message\":\"잘못된 접근입니다.\"}");
    return;
}

//정보
DataSet info = sensSms.query(
    "SELECT * FROM " + sensSms.table +
    " WHERE request_id = ? AND send_type = 'R' AND reserve_time > ? " ,
    new Object[]{ requestId, now }
);

if(!info.next()) {
    out.print("{\"success\":false, \"message\":\"이미 예약 시간이 지났거나 취소할 수 없는 상태입니다.\"}");
    return;
}

//취소
boolean result = sms.cancelReserveSend(requestId);

//저장
if(result) {
    sensSms.item("send_type", "C");

    if(sensSms.update("request_id = '" + requestId + "'")) {
        out.print("{\"success\":true, \"message\":\"예약이 취소되었습니다.\"}");
    } else {
        out.print("{\"success\":false, \"message\":\"DB 업데이트 실패\"}");
    }

} else {
    out.print("{\"success\":false, \"message\":\"예약 취소 실패\"}");
}

%>