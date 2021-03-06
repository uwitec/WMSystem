<!DOCTYPE html>
<html>
<head>
<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri= "/tld/base.tld" prefix="app" %>
<%@ page import="com.ccthanking.framework.common.User"%>
<%@ page import="com.ccthanking.framework.common.OrgDept"%>
<%@ page import="com.ccthanking.framework.Globals"%>
<%@ page import="com.ccthanking.framework.util.Pub"%>
<app:base/>
<title>提请款-维护</title>
<%
	String type=request.getParameter("type");
	//获取当前用户信息
	User user = (User) request.getSession().getAttribute(Globals.USER_KEY);
	OrgDept dept = user.getOrgDept();
	String deptId = dept.getDeptID();
	String deptName = dept.getDept_Name();
	String userid = user.getAccount();
	String username = user.getName();
	String sysdate = Pub.getDate("yyyy-MM-dd");
%>
<script src="${pageContext.request.contextPath }/js/common/xWindow.js"></script>
<script type="text/javascript" charset="utf-8">
//请求路径，对应后台RequestMapping
var controllername= "${pageContext.request.contextPath }/zjgl/gcZjglTqkController.do";
var controllernameTqkMx= "${pageContext.request.contextPath }/zjgl/gcZjglTqkmxController.do";
var controllernameTqkBmMx= "${pageContext.request.contextPath }/zjgl/gcZjglTqkbmmxController.do";
var type ="<%=type%>";
var xmrowValues;
//页面初始化
$(function() {
	init();
	//按钮绑定事件（查询）
	$("#btnQuery").click(function() {
		//生成json串
		var data = combineQuery.getQueryCombineData(queryFormMx,frmPost,gcZjglTqkmxList);
		//调用ajax插入
		defaultJson.doQueryJsonList(controllernameTqkMx+"?query",data,gcZjglTqkmxList);
	});
	//按钮绑定事件(保存)
	$("#btnSave").click(function() {
		if($("#gcZjglTqkForm").validationButton())
		{
		    //生成json串
		    var data = Form2Json.formToJSON(gcZjglTqkForm);
		  	//组成保存json串格式
		    var data1 = defaultJson.packSaveJson(data);
		  	//调用ajax插入
		    if($("#ID").val() == "" || $("#ID").val() == null){
		    	var success=defaultJson.doInsertJson(controllername + "?insert", data1);
		    	if(success==true)
				{
					var obj=$("#resultXML").val();
					var subresultmsgobj1=defaultJson.dealResultJson(obj);
					$("#gcZjglTqkForm").setFormValues(subresultmsgobj1);
					$("#QTQKID").val($("#ID").val());
<%--					$("#btnInsert").attr("disabled", false);--%>
					$("#btnInsert_Sel").attr("disabled", false);
					
					$("#btnClear_Bins").remove();
				}
    			//$("#gcZjglTqkForm").clearFormResult();
    		}else{
    			defaultJson.doUpdateJson(controllername + "?update", data1);
    		}
		}else{
			requireFormMsg();
		  	return;
		}
	});
	
	//批量保存
	$("#btnUpdateMxSave").click(function() {
		//var indexarry = new Array();
		var indexarry = new Array();
		indexarry = $("#gcZjglTqkmxList").getChangeRows();
		if(indexarry == "")
		{
			xInfoMsg('请至少修改一条记录！',"");
			return
 		}
			var url = controllernameTqkBmMx + "?updatebatchdata&opttype=cwb&tqkid="+$("#QID").val();
			//获取表格表头的数组,按照表格显示的顺序
			var tharrays = new Array();
			var comprisesData;
			//indexarry = new Array();
			//indexarry = $("#gcZjglTqkmxList").getAllRowsJOSNString();
			tharrays = $("#gcZjglTqkmxList").getTableThArrays();
			if(tharrays != null){
				comprisesData = $("#gcZjglTqkmxList").comprisesData(indexarry,tharrays);
<%--				alert(comprisesData);--%>
<%--				var xx = convertJson.simplejson2string(comprisesData);--%>
<%--				alert(xx);--%>
<%--				$("#txtXML").val(xx);--%>
				var success  = defaultJson.doUpdateBatchJson(url, comprisesData,null,indexarry);
				//$(window).manhuaDialog.getParentObj().queryList();

			}
		
	});
	
	$("#btnDelete").click(function() {
		var rowindex=$("#gcZjglTqkmxList").getSelectedRowIndex();//获得选中行的索引
		if(rowindex==-1)
		 {
			requireSelectedOneRow();
		    return
		 }
		var rowValue=$("#gcZjglTqkmxList").getSelectedRow();//获得选中行的json对象
		var tempJson = convertJson.string2json1(rowValue);
		
		//表单赋值
		var data = combineQuery.getQueryCombineData(queryForm,frmPost);
		var data1 = {
			msg : data
		};
		$.ajax({
			url : controllernameTqkMx+"?delete&opttype=delonly&ids="+tempJson.ID,
			data : data1,
			cache : false,
			async :	false,
			dataType : "json",  
			type : 'post',
			success : function(response) {
				//$("#btnQuery").click();
				
				$("#gcZjglTqkmxList").removeResult(rowindex);
			}
		});
	});
	
	//按钮绑定事件（新增）
    $("#btnClear_Bins").click(function() {
        $("#gcZjglTqkForm").clearFormResult();
        $("#gcZjglTqkForm").cancleSelected();
        
        
        getNd();
    	$("#SQDW").val('<%=deptId%>');
    	$("#BZRQ").val('<%=sysdate%>');
        $("#ID").val("");
    });
	
	//按钮绑定事件（清空）
    $("#btnClear").click(function() {
        $("#queryForm").clearFormResult();
    });
    
  	//按钮绑定事件(新增)
	$("#btnInsert").click(function() {
		$(window).manhuaDialog({"title":"提请款明细>新增","type":"text","content":"${pageContext.request.contextPath }/jsp/business/zjgl/tqkmx-add.jsp?type=insert","modal":"2"});
	});
  	//修改明细
	$("#btnUpdateMx").click(function() {
		if($("#gcZjglTqkmxList").getSelectedRowIndex()==-1)
		 {
			requireSelectedOneRow();
		    return
		 }
		$(window).manhuaDialog({"title":"提请款明细>修改","type":"text","content":"${pageContext.request.contextPath }/jsp/business/zjgl/tqkmx-add.jsp?type=update","modal":"2"});
	});
	
	$("#btnHtView").click(function(){
		  var values = "";
		   if($("#gcZjglTqkmxList").getSelectedRowIndex()==-1)
		      {
		       requireSelectedOneRow();
		       return
		      }
		   values = $("#gcZjglTqkmxList").getSelectedRow();
		  
		  $("#resultXML").val(values);
		  //var rowValue = $("#DT1").getSelectedRow();
		  //var tempJson = convertJson.string2json1(values);
		   //var idvar = tempJson.ID;
		  $(window).manhuaDialog({"title":"提请款管理>合同详细信息","type":"text","content":"${pageContext.request.contextPath }/jsp/business/zjgl/ht-view-tqkmx.jsp?type=detail","modal":"1"});
		     
	});
	  	
    <%
    if(type.equals("detail")){
	%>
	//置所有input 为disabled
	$(":input").each(function(i){
	   $(this).attr("disabled", "true");
	 });
	<%
		}
	%>
	
	$("#btnInsert_Sel").click(function() {
		$(window).manhuaDialog({"title":"提请款明细>选择部门明细","type":"text","content":"${pageContext.request.contextPath }/jsp/business/zjgl/tqkbmmx-more.jsp","modal":"2"});
	});
	
});
//页面默认参数
function init(){
	if(type == "insert"){
		getNd();
		$("#SQDW").val('<%=deptId%>');
		$("#BZRQ").val('<%=sysdate%>');
	}else if(type == "update" || type == "detail"){
		var parentmain=$(this).manhuaDialog.getParentObj();	
		var rowValue = parentmain.$("#resultXML").val();
		var tempJson = convertJson.string2json1(rowValue);
		
		$("#QTQKID").val(tempJson.ID);
		$("#QID").val(tempJson.ID);
		
		//alert(JSON.stringify(tempJson));
		//查询记录数
		
		//表单赋值
		var data = combineQuery.getQueryCombineData(queryForm,frmPost);
		var data1 = {
			msg : data
		};
		$.ajax({
			url : controllername+"?query",
			data : data1,
			cache : false,
			async :	false,
			dataType : "json",  
			type : 'post',
			success : function(response) {
				$("#resultXML").val(response.msg);
				var resultobj = defaultJson.dealResultJson(response.msg);
				$("#gcZjglTqkForm").setFormValues(resultobj);
				$("#RZZT").attr("code",resultobj.RZZT);
				$("#RZZT").val(resultobj.DICT_NAME);
				if(resultobj.QKLX!='16'){
					$("#sygt").remove();
				}
			}
		});
		
		
		//查询明细
		var dataMx = combineQuery.getQueryCombineData(queryFormMx,frmPost,gcZjglTqkmxList);
		//调用ajax插入
		defaultJson.doQueryJsonList(controllernameTqkMx+"?query",dataMx,gcZjglTqkmxList);
		
		$("#btnInsert_Sel").attr("disabled", false);
	}
}

function setTqkName(){
	var subName ="工程用款申请表";
	var fullName = $("#QKNF").val()+"年第";
	if($("#GCPC").val()!="")
		fullName += $("#GCPC").val()+"批"+subName;
	if($("#QKLX").val()!=""){
		//fullName += $("#QKLX").text();
		fullName += $("#QKLX").find("option:selected").text();
	}
	$("#QKMC").val(fullName);
}

//点击行事件
function tr_click(obj,tabListid){
	//alert(JSON.stringify(obj));
	//$("#gcZjglTqkForm").setFormValues(obj);
	if(tabListid='gcZjglTqkmxList'){
		$("#QMXID").val(obj.ID);
		$("#btnUpdateMx").attr("disabled", false);
		$("#btnDelete").attr("disabled", false);
		$("#btnHtView").attr("disabled", false);
			
	}
}

//默认年度
function getNd(){
	//年度信息，里修改
	var y = new Date().getFullYear();
	$("#QKNF option").each(function(){
		if(this.value == y){
		 	$(this).attr("selected", true);
		 	return true;
		}
	});
}

//选中项目名称弹出页
function selectXm(){
	$(window).manhuaDialog({"title":"","type":"text","content":"${pageContext.request.contextPath }/jsp/business/zjgl/xmcx.jsp","modal":"2"});
}
//弹出区域回调
getWinData = function(data){
	$("#XMMC").val(JSON.parse(data).XMMC);
	$("#XMBH").val(JSON.parse(data).XMBH);
	$("#GC_TCJH_XMXDK_ID").val(JSON.parse(data).GC_TCJH_XMXDK_ID);
};

function closeNowCloseFunction(){
	return true;
}

function closeParentCloseFunction(){
	//刷新
	$("#btnQuery").click();
}

//详细信息
function rowView(index){
	var obj = $("#gcZjglTqkList").getSelectedRowJsonByIndex(index);
	var xmbh = eval("("+obj+")").XMBH;
	$(window).manhuaDialog(xmscUrl(xmbh));
}

function saveMX(){
	//生成json串
	  var data = Form2Json.formToJSON(gcZjglTqkForm);
	  //组成保存json串格式
	  var data1 = defaultJson.packSaveJson(data);
	  //调用ajax插入
	  defaultJson.doInsertJson(controllernameTqkMx + "?insert&opttype=iinto&id="+$("#ID").val()+"&ids="+$("#jhsjids").val(), data1,null);
	  var data3 = $("#frmPost").find("#resultXML").val();
	  
	  xmrowValues = "";
	  $("#jhsjids").val("");
	 
}

//子页面调用
function fanhuixiangm(rowValues,ids)
{
	 //清空列表
	// $("#gcZjglTqkmxList").find("tbody").children().remove();
	// alert(rowValues.length);
	 xmrowValues=rowValues;
	 //for(var i=0;i<rowValues.length;i++)
	 //{
	 //  $("#gcZjglTqkmxList").insertResult(rowValues[i],gcZjglTqkmxList,1);
	 //}
	 $("#jhsjids").val(ids);
	 saveMX();
}
function getArr()
{
	 return xmrowValues;
}

function doDWMC(obj){
	if(obj.DWMC==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.DWMC;
	}
}
function doXMMCNR(obj){
	if(obj.XMMCNR==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.XMMCNR;
	}
}
function doHTBM(obj){
	if(obj.HTBM==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.HTBM;
	}
}
function doYBF(obj){
	if(obj.YBF==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.YBF_SV;
	}
}
function doLJBF(obj){
	if(obj.LJBF==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.LJBF_SV;
	}
}
function doAHTBFB(obj){
	if(obj.AHTBFB==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.AHTBFB_SV;
	}
}
function doCWSHZ(obj){
	if(obj.CWSHZ==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.CWSHZ_SV;
	}
}
function doJCHDZ(obj){
	if(obj.JCHDZ==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.JCHDZ_SV;
	}
}
function doBZ(obj){
	if(obj.BZ==''){
		return '<div style="text-align:center">—</div>';
	}else{
		return obj.BZ;
	}
}

</script>      
</head>
<body>
<app:dialogs/>
<div class="container-fluid">
<div class="row-fluid">
	<div class="B-small-from-table-autoConcise" style="display:black;">
	<input type="hidden" id="jhsjids" name="jhsjids"/>
     <form method="post" id="queryForm"  >
      <table class="B-table" width="100%">
      <!--可以再此处加入hidden域作为过滤条件 -->
      	<TR  style="display:none;">
			<TD class="right-border bottom-border">
				<input class="span12" type="text" id="QID" name="ID"  fieldname="ID" value="" operation="=" >
			</TD>
        </TR>
      </table>
      </form>
	</div>
	
	<div style="height:5px;"></div>
	<div class="B-small-from-table-autoConcise">
      <h4 class="title">提请款
      	<span class="pull-right">
      		<%
		    	if(!type.equals("detail")){
			%>
      		<button id="btnClear_Bins" class="btn" type="button" style="font-family:SimYou,Microsoft YaHei;font-weight:bold;">清空</button>
	  		<button id="btnSave" class="btn" type="button" style="font-family:SimYou,Microsoft YaHei;font-weight:bold;">保存</button>
	  		<%
				}
			%>
      	</span>
      </h4>

     <form method="post" id="gcZjglTqkForm"  >
      <table class="B-table" width="100%" >
      	<input type="hidden" id="ID" fieldname="ID" name = "ID"/></TD>
      	<input type="hidden" id="TQKZT" fieldname="TQKZT" name = "TQKZT" value="0"/></TD>
		
		<tr>
			<th width="8%" class="right-border bottom-border text-right disabledTh">申请部门</th>
			<td width="17%" class="right-border bottom-border">
				<select type="text" class="span12"  fieldname="SQDW" name="SQDW" id="SQDW" kind="dic" src="T#VIEW_YW_ORG_DEPT:ROW_ID:DEPT_NAME" disabled></select>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">请款类型</th>
			<td width="17%" class="right-border bottom-border">
				<select onchange="setTqkName();"  id="QKLX"    placeholder="必填" check-type="required" class="span12"  name="QKLX" fieldname="QKLX"  operation="=" kind="dic" src="QKLX"  defaultMemo="-请选择-" disabled>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">批次</th>
			<td width="17%" class="right-border bottom-border">
					<input id="GCPC" onchange="setTqkName();" type="number" style="width:60%;text-align:right;" title="工程批次"   placeholder="必填" check-type="required" class="span12" check-type="maxlength" maxlength="40"  name="GCPC" fieldname="GCPC" disabled/>
			</td>
		</tr>
		<tr>
			<th width="8%" class="right-border bottom-border text-right disabledTh">请款年份</th>
			<td width="17%" class="right-border bottom-border">
				<select  id="QKNF"   placeholder="必填" check-type="required" class="span12"  name="QKNF" fieldname="QKNF"  operation="=" kind="dic" src="XMNF" defaultMemo="-请选择-" disabled>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">请款月份</th>
			<td width="17%" class="right-border bottom-border">
				<select id="YF"   class="span12"  name="YF" fieldname="YF" kind="dic" src="YF"  defaultMemo="-请选择-" disabled>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">融资主体</th>
			<td width="17%" class="right-border bottom-border">
				<input id="RZZT" class="span12" check-type="maxlength" maxlength="200"  name="RZZT" fieldname="RZZT" type="text" disabled/>
			</td>
		</tr>
		<tr>
			<th width="8%" class="right-border bottom-border text-right disabledTh">请款名称</th>
			<td width="17%" class="right-border bottom-border">
				<input id="QKMC"   placeholder="必填" check-type="required" class="span12" check-type="maxlength" maxlength="100"  name="QKMC" fieldname="QKMC" type="text" disabled/>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">编制日期</th>
			<td width="17%" class="right-border bottom-border">
				<input id="BZRQ"  class="span9" fieldtype="date" fieldformat="YYYY-MM-DD"  placeholder="必填" check-type="required"  name="BZRQ" fieldname="BZRQ" type="date" disabled/>
			</td>
			<th width="8%" class="right-border bottom-border text-right disabledTh">编制人</th>
			<td width="17%" class="right-border bottom-border">
				<input id="CWBLRID"  class="span12" check-type="maxlength" maxlength="36"  name="CWBLRID" fieldname="CWBLRID" type="text" disabled/>
			</td>
		</tr>
		<tr>
			<th width="8%" class="right-border bottom-border text-right disabledTh">备注</th>
	        <td  width="17%" class="bottom-border right-border" colspan="5">
	        	<textarea class="span12"  id="BZ" check-type="maxlength" maxlength="4000" fieldname="BZ" name="BZ"></textarea>
	        </td>
		</tr>
      </table>
      </form>
      
      
      <div style="height:5px;"></div>
      
      <h4 class="title">提请款明细
      	<span class="pull-right">
      		<button id="btnHtView" class="btn" type="button" style="font-family:SimYou,Microsoft YaHei;font-weight:bold;" disabled="disabled">合同信息</button>
      	</span>
      	 <form method="post" id="queryFormMx">
				<table class="B-table" width="100%">
					<!--可以再此处加入hidden域作为过滤条件 -->
					<TR style="display: none;">
						<TD class="right-border bottom-border"></TD>
						<TD class="right-border bottom-border">
							<input class="span12" type="text" id="QTQKID" name="TQKID"  fieldname="t.TQKID" value="" operation="=" >
						</TD>
					</TR>
					<!--可以再此处加入hidden域作为过滤条件 -->
				</table>
	</form>
      </h4>
     
    <div class="overFlowX">
    <input type="hidden" id="QMXID">
	<table class="table-hover table-activeTd B-table" id="gcZjglTqkmxList" width="100%" pageNum="10" type="single" noPage="true">
		<thead>
			<tr>
 			    <th  name="XH" id="_XH" style="width:10px" colindex=1 tdalign="center">&nbsp;#&nbsp;</th>
				<th fieldname="DWMC" colindex=2 tdalign="center" maxlength="30" CustomFunction="doDWMC">&nbsp;收款单位&nbsp;</th>
				<th fieldname="XMMCNR" colindex=3 tdalign="center" maxlength="30" CustomFunction="doXMMCNR">&nbsp;项目名称内容&nbsp;</th>
				<th fieldname="HTBM" colindex=4 tdalign="center" maxlength="30" CustomFunction="doHTBM">&nbsp;合同编码&nbsp;</th>
				<th fieldname="ZXHTJ" colindex=5 tdalign="right" >&nbsp;最新合同价(元)&nbsp;</th>
				<th id="sygt" fieldname="JZQR" colindex=7 tdalign="right">&nbsp;监理确认计量款(元)&nbsp;</th>
				<th fieldname="YBF" colindex=8 tdalign="right" CustomFunction="doYBF">&nbsp;已拔付(元)&nbsp;</th>
				<th fieldname="BCSQ" colindex=9 tdalign="right" >&nbsp;部门申请值(元)&nbsp;</th>
				<th fieldname="LJBF" colindex=10 tdalign="right" CustomFunction="doLJBF">&nbsp;累计拔付(元)&nbsp;</th>
				<th fieldname="AHTBFB" colindex=11 tdalign="right" CustomFunction="doAHTBFB">&nbsp;按合同付款比例(%)&nbsp;</th>
				<th fieldname="CWSHZ" colindex=12 tdalign="right" type="text" CustomFunction="doCWSHZ">&nbsp;财务确认申请值(元)&nbsp;</th>
				<th fieldname="JCHDZ" colindex=13 tdalign="right" type="text" CustomFunction="doJCHDZ">&nbsp;计财审定值(元)&nbsp;</th>
				<th fieldname="BZ" colindex=14 tdalign="center" maxlength="30" CustomFunction="doBZ">&nbsp;备注&nbsp;</th>
             </tr>
		</thead>
		<tbody>
           </tbody>
	</table>
	</div>
    </div>
   </div>
  </div>
  <div align="center">
 	<FORM name="frmPost" method="post" style="display:none" target="_blank">
		 <!--系统保留定义区域-->
         <input type="hidden" name="queryXML" id = "queryXML">
         <input type="hidden" name="txtXML" id = "txtXML">
         <input type="hidden" name="txtFilter"  order="asc" fieldname = "rownum" id = "txtFilter">
         <input type="hidden" name="resultXML" id = "resultXML">
       		 <!--传递行数据用的隐藏域-->
         <input type="hidden" name="rowData">
		
 	</FORM>
 </div>
</body>
<script>
</script>
</html>