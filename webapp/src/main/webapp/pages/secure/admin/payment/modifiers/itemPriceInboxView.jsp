<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<%@ taglib prefix="authz" uri="authz" %>
<%--
  @author janmejay.singh
--%>

<html>
<head>
    <title><s:text name="title.manageRates.inventoryInbox"/></title>
    <s:head theme="twms"/>
    <u:stylePicker fileName="SummaryTable.css"/>

    <script type="text/javascript" src="scripts/ui-ext/common/tabs.js"></script>
    
    <script type="text/javascript">

        dojo.require("dojox.layout.ContentPane");
        
        function refreshIt() {
            publishEvent(SUMMARY_TABLE_UTIL.getRefreshFullTopic("itemPriceConfigTable"));
        }
       
        function createItemPriceConfig(event, dataId) {
			var thisTabLabel = getMyTabLabel();
			var url = "create_item_price_modifier.action";
			parent.publishEvent("/tab/open", {
												label: i18N.create_item_price_modifier,
												url: url,
												decendentOf: thisTabLabel,
												forceNewTab: true
												 });
        }
       
        function exportToExcel(){
         exportExcel("/itemPriceConfig/populateCriteria","export_item_price_configuration_to_excel.action");
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
        
        <u:summaryTableButton id="refreshButton" label="button.common.refresh" onclick="refreshIt" align="right" cssClass="refresh_button" summaryTableId="itemPriceConfigTable"/>

        <u:summaryTableButton id="warrantyRegButton" label="button.manageRates.createItemPriceModifier" onclick="createItemPriceConfig" summaryTableId="itemPriceConfigTable" cssClass="new_warranty_registration_button"/>
        <u:summaryTableButton id="downloadListing"
               		label="button.common.downloadToExcel"
               		onclick="exportToExcel"
               		align="right"
               		cssClass="download_to_excel_button"
               		summaryTableId="itemPriceConfigTable"/>
    </div>
    <div dojoType="dijit.layout.SplitContainer" layoutAlign="client" orientation="vertical" sizerWidth="4" activeSizing="false" id="split" persist="false">
        <u:stylePicker fileName="SummaryTableButton.css" /> <u:summaryTable eventHandlerClass="tavant.twms.supplierRecovery.summaryTable.EventHandler" id="itemPriceConfigTable" bodyUrl="get_item_price_modifier_body.action" folderName="%{folderName}" previewUrl="preview_item_price_modifier.action" detailUrl="view_item_price_modifier.action"
                          previewPaneId="preview" parentSplitContainerId="split"
                          populateCriteriaDataOn="/itemPriceConfig/populateCriteria">
            <s:iterator value="tableHeadData">
                <u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}" labelColumn="%{labelColumn}" hidden="%{hidden}"/>
            </s:iterator>
        <script type="text/javascript" src="scripts/SummaryTableTagEventHandler.js"></script>
        </u:summaryTable>
        <div dojoType="dojox.layout.ContentPane" id="preview"></div>
    </div>
     <script type="text/javascript">
    dojo.declare("tavant.twms.supplierRecovery.summaryTable.EventHandler", tavant.twms.summaryTable.MultiSelectTwmsEventHandler,{
    	onRowDblClick : function(event) {
    		
    		var url = this._getDetailUrl(event.folder, event.dataId);
    		if(url != null) {
    			var tab = getTabHavingId(getTabDetailsForIframe().tabId);
                var self = this;
                parent.publishEvent("/tab/open", {label: event.labelPrefix + "Id " + event.dataId,
                    url: url,
                    decendentOf: tab.title,
                    feedbackTabRef : function(childTab) {
                        self._setSummaryTableDetailsOnFrame(
                            childTab.domNode.getElementsByTagName("iframe")[0],
                            false
                        );
                    }});
                delete tab;
    		}
    	}	
    });			
</script>
<authz:ifPermitted resource="warrantyAdminItemPriceModifiersReadOnlyView">
	<script type="text/javascript">
		dojo.addOnLoad(function() {
			document.getElementById("buttonsDiv").style.display="none";
		});
	</script>
</authz:ifPermitted>  
  </div>
  <jsp:include flush="true" page="../../../common/ExcelDowloadDialog.jsp"></jsp:include>
  </u:body>
</html>