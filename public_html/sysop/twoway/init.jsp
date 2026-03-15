<%@ include file="../init.jsp" %><%
//채널
String ch = m.rs("ch", "sysop");

//변수
boolean isBodaYn = "Y".equals(SiteConfig.s("boda_yn"));

//제한
if(!("B".equals(SiteConfig.s("lanedu_type")) || isBodaYn)) {
	m.jsAlert("화상강의 서비스를 신청하셔야 이용할 수 있습니다.");
	return;
}

//객체
BodaDao boda = new BodaDao(siteId);

//보다 세팅
if(!"".equals(SiteConfig.s("boda_company_id")) && !"".equals(SiteConfig.s("boda_company_auth_cd"))) {
	boda.setCompanyInfo(SiteConfig.s("boda_company_id"), SiteConfig.s("boda_company_auth_cd"));
	p.setVar("boda_block", true);
}

//정보-보다 정보
DataSet binfo = boda.getBaseInfo();
p.setVar("boda", binfo);

%>