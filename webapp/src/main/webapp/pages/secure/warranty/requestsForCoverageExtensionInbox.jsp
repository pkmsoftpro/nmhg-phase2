<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>

<html>
<head>
<title>Pending Extension Requests</title>
<s:head theme="twms" />
<u:stylePicker fileName="SummaryTable.css" />

<script type="text/javascript" src="scripts/domainUtility.js"></script>
<script type="text/javascript" src="scripts/ui-ext/common/tabs.js"></script>

<script type="text/javascript">
        dojo.require("dijit.layout.LayoutContainer");
        dojo.require("dojox.layout.ContentPane");
        function refreshIt() {
            publishEvent(SUMMARY_TABLE_UTIL.getRefreshFullTopic("coverageRequestsTableDealer"));
        }                                
        function exportToExcel() {
        	exportExcel("/notification/populateCriteria","downloadCoverageRequestsToExcel.action");
        }                
	    var extraParams = {	    	
	    	view :'<s:property value="view" />'
	    };
</script>
<u:stylePicker fileName="base.css" />
<u:stylePicker fileName="yui/reset.css" common="true" />
<u:stylePicker fileName="layout.css" common="true" />
<%@include file="/i18N_javascript_vars.jsp"%>
</head>
<u:body smudgeAlert="false">
	<u:actionResults wipeMessages="false" />
	<div dojoType="dijit.layout.LayoutContainer"
		style="width: 100%; height: 100%">
	<div dojoType="dijit.layout.ContentPane" layoutAlign="top"
		class="buttonContainer">
	<u:summaryTableButton id="refreshButton" label="button.common.refresh" 
		onclick="refreshIt" align="right" cssClass="refresh_button" summaryTableId="coverageRequestsTableDealer" /> 
	<u:summaryTableButton id="downloadListing" label="button.common.downloadToExcel"
		onclick="exportToExcel" align="right" cssClass="download_to_excel_button" 
		summaryTableId="coverageRequestsTableDealer" />
	</div>

	<div dojoType="dijit.layout.SplitContainer" layoutAlign="client"
		orientation="vertical" sizerWidth="4" activeSizing="false" id="split"
		persist="false"><u:stylePicker fileName="SummaryTableButton.css" />
	<s:if test="view.equals('AdminView')">	
	<u:summaryTable
		eventHandlerClass="tavant.twms.summaryTable.BasicTwmsEventHandler"
		id="coverageRequestsTableDealer" bodyUrl="fetchRequestsForCoverageExtensionBody.action"
		folderName="%{folderName}" previewUrl="adminReducedCoverageOnInventoryPreview.action"
		detailUrl="adminReducedCoverageOnInventoryDetail.action" extraParamsVar="extraParams"
		previewPaneId="preview" parentSplitContainerId="split"
		populateCriteriaDataOn="/notification/populateCriteria">
		<s:iterator value="tableHeadData">          
            	<u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}" labelColumn="%{labelColumn}" hidden="%{hidden}"/>          
       	</s:iterator>
		<script type="text/javascript"
			src="scripts/SummaryTableTagEventHandler.js"></script>
	</u:summaryTable>
	</s:if>
	<s:else>
	<u:summaryTable
		eventHandlerClass="tavant.twms.summaryTable.BasicTwmsEventHandler"
		id="coverageRequestsTableDealer" bodyUrl="fetchRequestsForCoverageExtensionBody.action"
		folderName="%{folderName}" previewUrl="adminReducedCoverageOnInventoryPreview.action"
		detailUrl="dealerReducedCoverageOnInventoryDetail.action" extraParamsVar="extraParams"
		previewPaneId="preview" parentSplitContainerId="split"
		populateCriteriaDataOn="/notification/populateCriteria">
		<s:iterator value="tableHeadData">          
            	<u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}" labelColumn="%{labelColumn}" hidden="%{hidden}"/>          
       	</s:iterator>
		<script type="text/javascript"
			src="scripts/SummaryTableTagEventHandler.js"></script>
	</u:summaryTable>		
	</s:else>
	<div dojoType="dojox.layout.ContentPane" id="preview"></div>
	</div>
	</div>
	<jsp:include flush="true" page="../common/ExcelDowloadDialog.jsp"></jsp:include>
</u:body>
</html>
