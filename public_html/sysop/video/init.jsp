<%@ include file="../init.jsp" %><%@ page import="org.apache.commons.net.ftp.*" %><%

String ch = "sysop";

%><%!
public int loginValidate(FTPClient ftp, Malgn m, String ftpId, String ftpPw) throws Exception {
    String cookName = "OFNISSECCAPTFNDC";
    String cookie = m.getCookie(cookName);
    String currentTime = m.time("yyyyMMddHHmmss");
    String prevTime = "";
    int loginFailCount = 0;

    // 최대 허용 실패 횟수 및 차단 시간(분)
    int maxFailCount = 5;
    int blockMinutes = 5;

    if(!"".equals(cookie)) {
        cookie = Base64Coder.decode(cookie);
        String[] arr = cookie.split("\\|");
        loginFailCount = m.parseInt(arr[0]);
        prevTime = (arr.length == 2 ? (!"".equals(arr[1]) ? arr[1] : "") : "");


        // 현재시간이 이전시간보다 5분 이상 이면 로그인 실패 횟수와 시간을 초기화 해준다.
        if (!"".equals(prevTime) && blockMinutes <= m.diffDate("I", prevTime, currentTime)) {
            loginFailCount = 0;
            prevTime = "";
        }
    }

    //실패횟수가 5회보다 많으면 로그인 실패 횟수와 시간이 초기화되기 전까지 로그인을 제한한다.
    if(maxFailCount <= loginFailCount && !"".equals(prevTime)) {
        if(blockMinutes > m.diffDate("I", prevTime, currentTime)) {
            return -1; // 5분 이내에 로그인 실패가 5회 이상일 경우 차단
        }
    }

    //로그인 실패 검사
    if (!ftp.login(ftpId, ftpPw)) {
        loginFailCount++;

        // 로그인 실패가 5회 이상이면 prevTime을 갱신하여 차단 시간을 적용
        if (loginFailCount >= maxFailCount && "".equals(prevTime)) {
            prevTime = currentTime; // 최초 실패 시점 기록
        }

        // 브라우저에 방문 정보 쿠키를 굽는다.
        String cookieValue = Base64Coder.encode(loginFailCount + "|" + (maxFailCount <= loginFailCount && "".equals(prevTime) ? currentTime : prevTime));
        m.setCookie(cookName, cookieValue);

        return -2;

    } else {
        m.delCookie(cookName);
    }

    return 1;
}
%>