﻿<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.ccthanking.framework.common.User"%>
<%@ page import="com.ccthanking.framework.Globals"%>
<%@ page import="com.ccthanking.framework.util.*"%>
<%@ page import="com.ccthanking.framework.common.DBUtil"%>
<%@ page import="com.ccthanking.framework.coreapp.aplink.*"%>

<%
	User user = (User) session.getAttribute(Globals.USER_KEY);
	//java.util.Date nowDate = DateTimeUtil.getNow();
	String sjbh = request.getParameter("sjbh");
	String sqlquery = "select t.cjrxm,to_char(t.cjsj, 'YYYY-MM-DD HH24:MI'),t.dbryid,to_char(t.wcsj, 'YYYY-MM-DD HH24:MI'),"+
       		"t.result,t.resultdscr,to_char(t.shedule_time, 'YYYY-MM-DD'),t.yxbs,t.rwlx from ap_task_schedule t, AP_PROCESSDETAIL d "+
			" where t.sjbh = '"+sjbh+"' and t.spbh = d.processoid(+) and t.stepsequence = d.stepsequence(+) order by cjsj";
	String[][] taskListq = DBUtil.query(sqlquery);
	String sql_info = "select PROCESSOID,to_char(createtime,'yyyy-mm-dd hh24:mi') as createtime,cjrid,value4 from ap_processinfo where  EVENTID='"+sjbh+"'";
	String[][] processinfo =  DBUtil.query(sql_info);
%>

<HTML>
<HEAD>
<TITLE> 审批意见 </TITLE>
<%@ taglib uri="/tld/base.tld" prefix="app"%>
<app:base />
</HEAD>
<BODY>

		<div class="B-small-from-table-auto">
				
			
            <table width="100%" class="table-hover table-activeTd B-table" id="DT1" type="single">
                <thead>
                    <tr>	
                    		<th name="XH" id="_XH" style="font-size:14px;">&nbsp;#&nbsp;</th>
							
							<th fieldname="CJSJ" style="font-size:14px;">&nbsp;审批时限&nbsp;</th>
							<th fieldname="WCRXM" style="font-size:14px;">&nbsp;办理人&nbsp;</th>
							<th fieldname="WCSJ" style="font-size:14px;">&nbsp;办理时间&nbsp;</th>
							<th fieldname="SPJG" style="font-size:14px;">&nbsp;办理结果&nbsp;</th>
							<th fieldname="SPYJ" style="font-size:14px;width:30%;">&nbsp;办理意见&nbsp;</th>
							<th fieldname="CJRXM" style="font-size:14px;">&nbsp;送办人&nbsp;</th>
							<th fieldname="CJSJ" style="font-size:14px;">&nbsp;送办时间&nbsp;</th>
					</tr>
					</thead>
					<tbody>
					
					 <tr>
							<th align="center" style="font-size:14px;">1</th>

							<td align="center" style="font-size:14px;"></td>
							<td align="center" style="font-size:14px;"><%=Pub.getUserNameByLoginId(processinfo[0][2])%></td>
							<td align="center" style="font-size:14px;"><%=processinfo[0][1]%></td>
							<td align="center" style="font-size:14px;">已发起</td>
							<td align="left" style="font-size:14px;width:30%;word-break:break-all;"><%=processinfo[0][3]%></td>
							<td align="center" style="font-size:14px;"></td>
							<td align="center" style="font-size:14px;"></td>
						</tr>
						<%
							for(int k=0;k<taskListq.length;k++)
							{

						%>
						<tr>
							<th align="center" style="font-size:14px;"><%=k+2%></th>

							<td align="center" style="font-size:14px;" ><%=(taskListq[k][6]==null||"".equals(taskListq[k][6]))?"无":(taskListq[k][6])%></td>
							<td align="center" style="font-size:14px;"><%=Pub.getUserNameByLoginId(taskListq[k][2])%><%if("0".equals(taskListq[k][7])) out.print("(抄送)");%></td>
							<td align="center" style="font-size:14px;<%if((taskListq[k][3]!=null&&(taskListq[k][3].length()>0))&&(taskListq[k][6]!=null&&(taskListq[k][6].length()>0))&&DateTimeUtil.parse(taskListq[k][3],"yyyy-MM-dd").after(DateTimeUtil.parse(taskListq[k][6],"yyyy-MM-dd"))) out.print("color:red;"); %>"><%=taskListq[k][3]%></td>
							<td align="center" style="font-size:14px;">
							<%if(taskListq[k][4]!=null&&taskListq[k][4].length()>0)
							  {
								 if("3".equals(taskListq[k][4]))
									out.print("<font color='red'>"+Pub.getDictValueByCode("SPJG",taskListq[k][4])+"</font>");
								 else if("4".equals(taskListq[k][4]))
									out.print("<font color='blue'>"+Pub.getDictValueByCode("SPJG",taskListq[k][4])+"</font>");
								 else if("1".equals(taskListq[k][4]))
									out.print("<font color='green'>"+Pub.getDictValueByCode("SPJG",taskListq[k][4])+"</font>"); 
								 else if("8".equals(taskListq[k][4]))
									out.print("<font color='red'>"+Pub.getDictValueByCode("SPJG",taskListq[k][4])+"</font>"); 
							  }else if("1".equals(taskListq[k][8])){
								  if(taskListq[k][3]==null||"".equals(taskListq[k][3])){
									  out.print("<font color='grey'>未归档</font>");
								  }else{
									  out.print("<font color='grey'>已归档</font>");
								  }
								  
							  }else {
								 out.print("<font color='grey'>未处理</font>");
							  }
							%></td>
							<td align="left" style="font-size:14px;width:30%;word-break:break-all;"><%=taskListq[k][5].replaceAll("\n","<br>")%></td>
							<td align="center" style="font-size:14px;"><%=taskListq[k][0]%></td>
							<td align="center" style="font-size:14px;"><%=taskListq[k][1]%></td>
						</tr>
						<%
							}
						%>
                	</tbody>
				</table>
			</div>
</BODY>
</HTML>