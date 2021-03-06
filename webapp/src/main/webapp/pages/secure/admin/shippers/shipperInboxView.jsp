<%--

   Copyright (c)2006 Tavant Technologies
   All Rights Reserved.

   This software is furnished under a license and may be used and copied
   only  in  accordance  with  the  terms  of such  license and with the
   inclusion of the above copyright notice. This software or  any  other
   copies thereof may not be provided or otherwise made available to any
   other person. No title to and ownership of  the  software  is  hereby
   transferred.

   The information in this software is subject to change without  notice
   and  should  not be  construed as a commitment  by Tavant Technologies.

--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<%@ taglib prefix="authz" uri="authz" %>


<html>
<head>
    <title><s:text name="title.manageShipper"/></title>
    <s:head theme="twms"/>
    <u:stylePicker fileName="SummaryTable.css"/>

    <script type="text/javascript" src="scripts/ui-ext/common/tabs.js"></script>
    
    <script type="text/javascript">

        dojo.require("dojox.layout.ContentPane");
        
       
        function refreshIt() {
            publishEvent(SUMMARY_TABLE_UTIL.getRefreshFullTopic(
                    "shipperTable"));
        }
       
        function createShipper(evt) {
            parent.publishEvent("/tab/open", {
                label: i18N.create_shipper,
                decendentOf: getMyTabLabel(),
                url: "create_shipper.action",
                forceNewTab: true
            });
        }
		function exportToExcel(){
         exportExcel("/shipper/populateCriteria","export_shipper_to_excel.action");
        }

    </script>
    <u:stylePicker fileName="base.css"/>
    <u:stylePicker fileName="yui/reset.css" common="true"/>
    <u:stylePicker fileName="layout.css" common="true"/>
    <%@include file="/i18N_javascript_vars.jsp"%>
  </head>
  <u:body>
  <div dojoType="dijit.layout.LayoutContainer" style="width: 100%; height: 100%">
    <div dojoType="dijit.layout.ContentPane" layoutAlign="top" class="buttonContainer" id="buttonsDiv">
       
        <u:summaryTableButton id="refreshButton" label="button.common.refresh"
                    onclick="refreshIt" align="right" cssClass="refresh_button"
                    summaryTableId="shipperTable"/>
        <u:summaryTableButton id="createShipperButton"
                    label="button.manageShipper.createShipper"
                    onclick="createShipper"
                    summaryTableId="shipperTable"
                    cssClass="create_shipper_button"/>
        <u:summaryTableButton id="downloadListing"
                    label="button.common.downloadToExcel"
                    onclick="exportToExcel"
                    align="right"
                    cssClass="download_to_excel_button"
                    summaryTableId="shipperTable"/>
    </div>
    <div dojoType="dijit.layout.SplitContainer" layoutAlign="client"
         orientation="vertical" sizerWidth="4" activeSizing="false" id="split"
         persist="false">
        <%-- We don't need folder name info. Hence just setting some junk value
        here --%>
        <u:stylePicker fileName="SummaryTableButton.css" /> <u:summaryTable eventHandlerClass="tavant.twms.summaryTable.BasicTwmsEventHandler" id="shipperTable"
                          bodyUrl="get_shipper_body.action"
                          folderName="SHIPPER"
                          previewUrl="view_shipper_preview.action"
                          detailUrl="manage_shipper.action"
                          previewPaneId="preview"
                          parentSplitContainerId="split"
                          populateCriteriaDataOn="/shipper/populateCriteria">
            <s:iterator value="tableHeadData">
                <u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}"
                            idColumn="%{idColumn}" labelColumn="%{labelColumn}"
                            hidden="%{hidden}"/>
            </s:iterator>
        <script type="text/javascript" src="scripts/SummaryTableTagEventHandler.js"></script></u:summaryTable>
        <div dojoType="dojox.layout.ContentPane" id="preview">
        </div>
    </div>
  </div>
  <jsp:include flush="true" page="../../common/ExcelDowloadDialog.jsp"></jsp:include>
  </u:body>
<authz:ifPermitted resource="warrantyAdminManageFreight/ShippersReadOnlyView">
	<script type="text/javascript">
		dojo.addOnLoad(function() {
			document.getElementById("buttonsDiv").style.display="none";
		});
	</script>
</authz:ifPermitted>
</html>