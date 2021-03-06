<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="authz" uri="authz"%>
<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<%--
  @author aniruddha.chaturvedi
--%>

<html>
<head>
    <title><s:text name="title.newClaim.claimInboxView"/></title>
    <s:head theme="twms"/>
    <u:stylePicker fileName="SummaryTable.css"/>
    <script type="text/javascript">
        dojo.require("dijit.layout.LayoutContainer");
        dojo.require("dojox.layout.ContentPane");
    </script>

    <script type="text/javascript" src="scripts/ui-ext/common/tabs.js"></script>

    <script type="text/javascript">
    
        var pageUrl = "claims.action";
    	function getPageUrl(){
    		var folderName="<s:property value="folderName"/>";
    		pageUrl = "claims.action?"+"folderName="+folderName;
    		return pageUrl;
    	}
    
        function refreshIt() {
            publishEvent(SUMMARY_TABLE_UTIL.getRefreshFullTopic("claimTable"));
        }
       
        function createClaim(event, dataId) {
        	var thisTabLabel = getMyTabLabel();
            parent.publishEvent("/tab/open", {
            						label: i18N.new_claim,
            						url: "showNewClaimForm.action",
            						decendentOf: thisTabLabel,
            						forceNewTab: true
            						});
        }
       
	 <s:if test="inboxViewId!=null && !inboxViewId.trim().equals('')">
		    var extraParams = {
				inboxViewId : <s:property value="inboxViewId"/>
		    };
		</s:if> 
       
        function exportToExcel(){
        var folderName="<s:property value="folderName"/>";
        if(folderName == "Pending Recovery Initiation"){
            exportExcel("/claim/populateCriteria","exportPendingRecClaimToExcel.action");
        } else{
               exportExcel("/claim/populateCriteria","exportClaimToExcel.action");
        }
        }

    </script>
    <u:stylePicker fileName="base.css"/>
    <u:stylePicker fileName="yui/reset.css" common="true"/>
    <u:stylePicker fileName="layout.css" common="true"/>
    <%@include file="/i18N_javascript_vars.jsp"%>
  </head>
  <u:body>
  <s:hidden name="context" value="ClaimSearches"/>
  <div dojoType="dijit.layout.LayoutContainer" style="width: 100%; height: 100%">
    <div dojoType="dijit.layout.ContentPane" layoutAlign="top" class="buttonContainer"  style="height:32px;">
        
        <u:summaryTableButton id="refreshButton" label="button.common.refresh" onclick="refreshIt" align="right" cssClass="refresh_button" summaryTableId="claimTable"/>
        
        <u:summaryTableButton id="downloadListing" label="button.common.downloadToExcel" onclick="exportToExcel"
               align="right" cssClass="download_to_excel_button" summaryTableId="claimTable"/>
        <authz:ifUserInRole roles="dealerWarrantyAdmin,processor">
	        <authz:ifCondition condition="!folderName.equals('Pending Recovery Initiation')">
		        <u:summaryTableButton id="warrantyRegButton" label="button.newClaim.createClaim" onclick="createClaim" summaryTableId="claimTable" cssClass="create_claim_button"/>
		    </authz:ifCondition>
        </authz:ifUserInRole>
        
      <s:if test="!folderName.equals('Pending Recovery Initiation')">
           <%@ include file="../common/inboxViewForm.jsp"%>
        </s:if> 
        
        <s:if test="folderName.equals('Draft Claim')  ">
			<span id="draftInboxMsg" tabindex="0" >
				<img src="image/warning.gif" width="16" height="15" />
			</span>
			<span dojoType="dijit.Tooltip" connectId="draftInboxMsg" >
				<s:iterator value="loggedInUser.businessUnits" status="userBUs">					
						<s:if test="getDateToUseForDraftClaimDeletionBU(name).equals('updatedOn')">
							<s:text name="message.claim.warningByDateLastModified" >							
								<s:param><s:property value="getDraftClaimWindowPeriodForBU(name)"/></s:param>
							</s:text>
						</s:if>
						<s:else>
							<s:text name="message.claim.warningByDateCreated" >							
								<s:param><s:property value="getDraftClaimWindowPeriodForBU(name)"/></s:param>
							</s:text>
						</s:else>						
					<br/>			
				</s:iterator>					
			</span>
		</s:if>
		
		<s:if test="folderName.equals('Forwarded') ">
			<span id="forwardedInboxMsg" tabindex="0" >
				<img src="image/warning.gif" width="16" height="15" />
			</span>
			<span dojoType="dijit.Tooltip" connectId="forwardedInboxMsg" >
				<s:iterator value="loggedInUser.businessUnits" status="userBUs">
							<s:text name="message.claim.forwardedClaim" >							
								<s:param><s:property value="getForwardedClaimDenialWindowPeridoForBU(name)"/></s:param>
							</s:text>					
					<br/>			
				</s:iterator>					
			</span>
		</s:if>
        
    </div>
    <s:if test="!folderName.equals('Pending Recovery Initiation')">
    <div dojoType="dijit.layout.SplitContainer" layoutAlign="client" orientation="vertical" sizerWidth="4" activeSizing="false" id="split" persist="false">
        <u:stylePicker fileName="SummaryTableButton.css" />
        <u:summaryTable eventHandlerClass="tavant.twms.summaryTable.BasicTwmsEventHandler" id="claimTable"
                        bodyUrl="claimsBody.action" folderName="%{folderName}" previewUrl="claim_preview.action"
                        previewPaneId="preview" detailUrl="claim_detail.action" parentSplitContainerId="split"
                        populateCriteriaDataOn="/claim/populateCriteria">
            <s:iterator value="tableHeadData">
            <s:if test="imageColumn ">
            		<script type="text/javascript" src="scripts/tst_commonExt/ImageRenderer.js"></script>
            		<u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}"
            			rendererClass="tavant.twms.summaryTableExt.ImageRenderer"	labelColumn="%{labelColumn}"
            			hidden="%{hidden}" disableFiltering="%{disableFiltering}" disableSorting="%{disableSorting}"/>
            	</s:if>
            	<s:else>
                <u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}" labelColumn="%{labelColumn}" hidden="%{hidden}" disableFiltering="%{disableFiltering}" disableSorting="%{disableSorting}"/>
                </s:else>
            </s:iterator>
        <script type="text/javascript" src="scripts/SummaryTableTagEventHandler.js"></script></u:summaryTable>
        <div dojoType="dojox.layout.ContentPane" id="preview">
        </div>
    </div>
    </s:if>
    <s:else>    	
    	<div dojoType="dijit.layout.SplitContainer" layoutAlign="client" orientation="vertical" sizerWidth="4" activeSizing="false" id="split" persist="false">
        <u:stylePicker fileName="SummaryTableButton.css" />
        <u:summaryTable eventHandlerClass="tavant.twms.summaryTable.BasicTwmsEventHandler" id="claimTable"
                        bodyUrl="recoveryClaimsBody.action" folderName="%{folderName}"
                        previewPaneId="preview" detailUrl="specify_supplier_contract.action" parentSplitContainerId="split"
                        populateCriteriaDataOn="/claim/populateCriteria">
            <s:iterator value="tableHeadData">
            <s:if test="imageColumn ">
            		<script type="text/javascript" src="scripts/tst_commonExt/ImageRenderer.js"></script>
            		<u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}"
            			rendererClass="tavant.twms.summaryTableExt.ImageRenderer"	labelColumn="%{labelColumn}"
            			hidden="%{hidden}" disableFiltering="%{disableFiltering}" disableSorting="%{disableSorting}"/>
            	</s:if>
            	<s:else>
                <u:summaryTableColumn id="%{id}" label="%{title}" width="%{widthPercent}" idColumn="%{idColumn}" labelColumn="%{labelColumn}" hidden="%{hidden}" disableFiltering="%{disableFiltering}" disableSorting="%{disableSorting}"/>
                </s:else>
            </s:iterator>
        <script type="text/javascript" src="scripts/SummaryTableTagEventHandler.js"></script></u:summaryTable>
        <div dojoType="dojox.layout.ContentPane" id="preview">
        </div>    
    </s:else>
  </div>
  
  <table cellspacing="0" border="0" cellpadding="0">
  <tr></tr>
  <tr>
  <td>
  <table cellspacing="0" border="0" cellpadding="0">
  <tr>
  <td>
  <jsp:include flush="true" page="../common/ExcelDowloadDialog.jsp"></jsp:include>
  </td>
  </tr></table>
  </tr>
  </table>
  <script>
    var obj=document.getElementsByName("inboxViewId")[0];
    var selectedValue;
    if (obj != undefined) {
    	var opts=obj.options;        
        for(var i=0;i<opts.length;i++)
        {
        	if(opts[i].selected)
        	{
        		selectedValue=opts[i].value;
        		break;
        	}
        }
    }
	        
  	summaryTableVars.claimTable.extraParamsVar={
    			"inboxViewId" : selectedValue
    		};
  </script>
    </u:body>
</html>
