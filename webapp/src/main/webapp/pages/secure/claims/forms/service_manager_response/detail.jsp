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

<%@ taglib prefix="s" uri="/struts-tags" %>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<%@taglib prefix="authz" uri="authz"%>
<html>
<head>
    <u:stylePicker fileName="yui/reset.css" common="true"/>
    <s:head theme="twms"/>
    <u:stylePicker fileName="common.css"/>
    <u:stylePicker fileName="form.css"/>
    <u:stylePicker fileName="claimForm.css"/>
    <meta http-equiv="Context-Type" content="text/html; charset=ISO-8859-1">
    <title><s:text name="title.viewClaim.smResponseDetail"/></title>
    <script type="text/javascript">
		dojo.require("dijit.layout.ContentPane");
        dojo.require("dijit.layout.LayoutContainer");
      	dojo.require("twms.widget.TitlePane");
      	dojo.require("twms.widget.Select");
      	dojo.require("dijit.layout.BorderContainer");
      	

    </script>
 <script type="text/javascript" src="scripts/claimUtilities.js"></script>
</head>

<u:body>
	<div dojoType="dijit.layout.LayoutContainer"  id="root">
	<div dojoType="dijit.layout.ContentPane" layoutAlign="client">
	<u:actionResults/>
	<s:form  method="post" theme="twms" validate="true" id="claim_form"
        name="claim_submit" action="claim_submit.action">
			<s:hidden name="id"/>

		       <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.history"/>"
		            labelNodeClass="section_header">
		            <s:push value="task">
		                <jsp:include flush="true" page="../common/read/userCommentHistory.jsp"/>
		            </s:push>
		       </div>
				<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.claimDetails" />"
					labelNodeClass="section_header">
					<s:push value="task">
						<jsp:include flush="true" page="../common/read/header.jsp"/>
					</s:push> 		
				</div>
			 <s:if test="task.claim.type.type== 'Campaign'">
			    <div dojoType="twms.widget.TitlePane" title="<s:text name="label.warrantyAdmin.campaignCode"/>" id="campaign_header"
			             labelNodeClass="section_header" >
			    	<s:push value="task.claim.campaign">
					<jsp:include page="/pages/secure/admin/campaign/read/campaignDetails.jsp" flush="true" />
					</s:push>
					<s:if test="!getJSONifiedCampaignAttachmentList().equals('[]')">
									<jsp:include page="/pages/secure/admin/campaign/read/campaignAttachments.jsp" flush="true"/>				
                    </s:if>	
				</div>
			</s:if>
			
			<s:if test="claimSpecificAttributes != null && ! claimSpecificAttributes.empty">
	 		<div>
	
       			 <div dojoType="twms.widget.TitlePane" title="<s:text name="label.viewClaim.ClaimAttributes"/>" id="attr_details"
             			labelNodeClass="section_header"  open="true">
             			  <s:push value="task">
             	    	<jsp:include flush="true" page="../common/read/claimSpecificAttributes.jsp"/>  
             	    	 </s:push>
                 </div> 
    		</div>  
    	</s:if> 
			
                <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.servicingLocation"/>"
                    labelNodeClass="section_header">
                    <s:push value="task">
                        <jsp:include flush="true" page="../common/read/servicingLocation.jsp"/>
                    </s:push>
                </div>
    <s:if test="task.partsClaim && task.claim.partItemReference.serialized">    
        <div class="policy_section_div">
            <div class="section_header"><s:text name="title.viewClaim.PartDetails"/></div>
            <s:push value="task">
                <jsp:include flush="true" page="../common/read/serializedPart.jsp"/>
            </s:push>
        </div>
    </s:if>
	<s:if test="task.claim.type.type != 'Parts' || (task.claim.partInstalled && (task.claim.competitorModelBrand == null || task.claim.competitorModelBrand.isEmpty()))">	    
				<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.equipmentDetails"/>"
					labelNodeClass="section_header">
					<s:push value="task">	
						<jsp:include flush="true" page="../common/read/equipment.jsp"/>
						<s:if test="claim.claimedItems[0].itemReference.referredInventoryItem.type.type.equals('RETAIL')">
				           <table>
							<tbody>
								<tr>
									<s:if test="claim.matchReadInfo!=null && claim.matchReadInfo.ownerName!=null">
										<td >
											<s:text name="label.warrantyAdmin.ownerName"/>:
										</td>
										<td id = "viewLink" >
											<a id="show_entered_owner_info" class="link">				
								          		<s:property value="claim.matchReadInfo.ownerName"/>  		
											</a>						
										</td>						
									</s:if>
								</tr>
							</tbody>
						</table>
						   <s:if test="claim.matchReadInfo!=null && claim.matchReadInfo.ownerName!=null"> 
						      <jsp:include flush="true" page="../common/read/enteredOwnerInfo.jsp"/>
						    </s:if>	   		
				        </s:if>	
					</s:push>	
				</div>
	</s:if>	
			<s:if test="task.claim.type.type != 'Campaign'">
		    	<jsp:include flush="true" page="../common/read/availablePoliciesPopup.jsp"/>
					<div dojoType="twms.widget.TitlePane" title="<s:text name="label.claim.failureDetails" />"
							labelNodeClass="section_header">
						<s:push value="task">	
							<jsp:include flush="true" page="../common/read/failure.jsp"/>
						</s:push>	
					</div>
			</s:if>	
			<s:if test="isAlarmCodesSectionVisible()" >
			<div >
	  	       <div dojoType="twms.widget.TitlePane" title="<s:text name="title.required.alarmCode"/>" id="alarmcode_details"
		           labelNodeClass="section_header">
                     <s:push value="task">
                         <jsp:include flush="true" page="../common/read/claimAlarmCodeView.jsp" />
                     </s:push>

		      </div>
		    </div>
		</s:if>
		<s:if test="task.claim.laborConfig">
			<s:if test="task.claim.type.type == 'Parts' && (!task.claim.partInstalled || task.claim.competitorModelBrand!=null)">
					<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.laborInformation"/>"
						labelNodeClass="section_header">
						<s:push value="task">
							<jsp:include flush="true" page="../common/read/labor_detail_part.jsp"/>
						</s:push>
					</div>
			</s:if>
			<s:elseif test="!(task.claim.type.type == 'Parts') || (task.claim.partInstalled && (task.claim.competitorModelBrand == null || task.claim.competitorModelBrand.isEmpty()))">
					<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.serviceDetails"/>"
						labelNodeClass="section_header">
						<s:push value="task">
							<jsp:include flush="true" page="../common/read/service_detail.jsp"/>
						</s:push>	
					</div>
			</s:elseif></s:if>
			
			<s:if test="!partsReplacedInstalledSectionVisible" >
				<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.componentsReplaced"/>"
					labelNodeClass="section_header">
					<s:push value="task">
						<jsp:include flush="true" page="../common/read/component.jsp"/>
					</s:push>	
				</div>
		</s:if>
		<s:elseif test="buPartReplaceableByNonBUPart">
		    <div >
		        <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.componentsReplaced"/>" id="parts_replaced_installed"
		             labelNodeClass="section_header">
		             <s:push value="task">
			            <jsp:include flush="true" page="../common/read/replacedInstalledOEMParts.jsp"/>           
			         </s:push>   
		        </div>
		 	</div>
	 	</s:elseif>
	 	<s:else> 		 
		    <div>
		        <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.componentsReplaced"/>" id="parts_replaced_installed"
		             labelNodeClass="section_header">
		             <s:push value="task">
			            <jsp:include flush="true" page="../common/read/replacedInstalledOnlyOEMParts.jsp"/>     
			            <jsp:include flush="true" page="../common/read/component.jsp"/>     
			         </s:push>   
		        </div>
		 	</div>
	 	</s:else>
 	
				<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.travelDetails"/>"
	                labelNodeClass="section_header">
					<s:push value="task">
	                    <jsp:include flush="true" page="../common/read/travelDetails.jsp"/>
					</s:push>
	            </div>
	            <s:if test="incidentalsAvaialable"> 
	            <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.miscellaneous"/>"
	                labelNodeClass="section_header">
					<s:push value="task">
	                    <jsp:include flush="true" page="../common/read/otherIncidentals.jsp"/>
					</s:push>
	            </div>
	            </s:if>
				<div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.comments"/>"
					labelNodeClass="section_header">
					<s:push value="task">
						<jsp:include flush="true" page="../common/read/comment.jsp"/>
					</s:push>	
				</div>
                <div dojoType="twms.widget.TitlePane" title="<s:text name="label.partReturnAudit.PartHistory"/>"
                     labelNodeClass="section_header" open="false">
                    <s:push value="task">
                         <jsp:include flush="true" page="../common/read/partsAuditHistory.jsp"/>
                    </s:push>
                </div>
	            <div dojoType="twms.widget.TitlePane" title="<s:text name="title.newClaim.supportDocs"/>" id="supportDocs"
	                 labelNodeClass="section_header">
	                	<jsp:include flush="true" page="../common/write/uploadAttachments.jsp"/>
	            </div>
            <jsp:include page="../common/write/fileUploadDialog.jsp"/>
			    <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.paymentDetails"/>" id="payment"
			         labelNodeClass="section_header">
			        <s:push value="task"> 
			        	<jsp:include flush="true" page="../common/read/payment.jsp"/>
			        </s:push>
			    </div>
			<authz:ifNotPermitted resource="readOnlyAccesstoSLMS">
		    <div dojoType="twms.widget.TitlePane" title="<s:text name="title.viewClaim.actions"/>" id="actions"
		         labelNodeClass="section_header">
				<jsp:include flush="true" page="../common/actions.jsp"/>
		    </div>
		    </authz:ifNotPermitted>
		</s:form>
	<div align="center">
		<a id="claimPrint" href="#"><s:text name="link.print.claim"/></a>
		<script type="text/javascript">
			dojo.addOnLoad(function() {
				dojo.connect(dojo.byId("claimPrint"), "onclick", function(event){
					var claim = '<s:property value="task.claim"/>';
					var thisTabLabel = getMyTabLabel();
                    parent.publishEvent("/tab/open", {
					                    label: "Print Claim",
					                    url: "printClaim.action?claim="+claim, 
					                    decendentOf: thisTabLabel,
					                    forceNewTab: true
                                       });
                });
			});	
		</script>
	 </div>
	</div>
	</div>		

</u:body>
</html>
