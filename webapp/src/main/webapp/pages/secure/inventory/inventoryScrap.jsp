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
<%@ taglib prefix="sd" uri="/struts-dojo-tags"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%>
<%@taglib prefix="u" uri="/ui-ext"%>



<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<u:stylePicker fileName="yui/reset.css" common="true" />
<s:head theme="twms" />
<u:stylePicker fileName="common.css" />
<u:stylePicker fileName="warrantyForm.css" />
<u:stylePicker fileName="form.css" />
<%@ include file="/i18N_javascript_vars.jsp"%>	
<script type="text/javascript">
    dojo.require("dijit.layout.LayoutContainer");
    dojo.require("dijit.layout.ContentPane");
    dojo.require("twms.widget.TitlePane");
    dojo.require("dijit.form.ComboBox");
    dojo.require("twms.widget.Dialog");
    dojo.require("twms.widget.MultipleInventoryPicker"); 
</script>
<script type="text/javascript">
var confirmationDialog = null;

dojo.addOnLoad(function() {
	confirmationDialog = dijit.byId("confirmationDialog");
	dojo.byId("dialogBoxContainer").style.display = "block";
	dojo.connect(dojo.byId("scrapFormSubmitButton"), "onclick", function() {
			confirmationDialog.show();

        });
	dojo.connect(dojo.byId('confirmationSubmitButton'), "onclick", function(){
		var form = document.scrapform;
		form.submit();
	});
   dojo.connect(dojo.byId("cancelButton"), "onclick", closeMyTab);	
})
</script>

</head>
<u:body>
	<u:actionResults />
	<s:form action="scrapInventory.action" method="POST" theme="twms"
		validate="true" id="scrapform" name="scrapform">
		<s:hidden name="inventoryItem" value="%{inventoryItem.id}" />
<div dojoType="dijit.layout.LayoutContainer" style="width: 100%; height: 100%; overflow-x:hidden; overflow-y:scroll;" id="root" >
        <div id="dcap_pricing_title" class="section_header" style="margin-top:5px;margin-left:5px;margin-right:5px;">
            <s:text name="title.fleetmanagement.inventoryscrap"/>
      </div>
        <div dojoType="dijit.layout.ContentPane" style="background:#F3FBFE;margin:0px 5px 5px 5px;border:1px solid #EFEBF7; ">
		<div dojoType="twms.widget.MultipleInventoryPicker" searchHandlerUrl="searchInventories_fleetScrap.action"
				useInnerHTML="false" selectionHandlerUrl="show_inventories_forScrap.action"
				selectedItemsContentPane="fleetInventoryScrap"></div>
			<div dojoType="dojox.layout.ContentPane" executeScripts="true"
				scriptSeparation="false" id="fleetInventoryScrap" >
		<table class="grid" cellspacing="0" cellpadding="0">
			
			<tr>
				<td class="labelStyle" width="20%" nowrap="nowrap"><s:label value="%{getText('label.common.serialNumber')}" cssClass="labelStyle" /> :</td>
				<td><s:property value="inventoryItem.serialNumber" /></td>
                 <s:hidden name="id" value="%{inventoryItem.id}"/>
            </tr>
            <tr>
				<td class="labelStyle" nowrap="nowrap"><s:label value="%{getText('label.scrap.scrapDate')}" cssClass="labelStyle" /> :</td>
				<td>
				<div style="margin-left:-7px;">
				<sd:datetimepicker name='scrapDate' value='%{scrapDate}' id='scrapDate' />
				</div>
				</td>
			</tr>
			<tr>
				<td class="labelStyle" nowrap="nowrap"><s:label value="%{getText('label.common.comments')}" cssClass="labelStyle" /> :</td>
				<td><t:textarea id="scrapComments" label="ScrapComments" name="scrapComments"
					cols="60" rows="3"/>
				</td>
			</tr>
			<tr><td style="padding:0;margin:0 ">&nbsp;</td></tr>
            </table>
			</div>


        <div align="center">
        <table class="buttons">
            <tr>

				<td align="center"> <input id="cancelButton" class="buttonGeneric" type="button"
					value="<s:text name='button.common.cancel'/>" />
                 <input type="button" class="buttonGeneric"
					id="scrapFormSubmitButton"
					value="<s:text name="button.common.submit"/>" />

                </td>
		</tr>

        </table>
	</div>
</div>	
        <div id="dialogBoxContainer" style="display: none">
		    <div dojoType="twms.widget.Dialog" id="confirmationDialog" bgColor="white"
				bgOpacity="0.5" toggle="fade" toggleDuration="250" style="height: 120px; width: 310px; border: 1px solid #EFEBF7">
				<div class="dialogContent" dojoType="dijit.layout.LayoutContainer"
					style="height: 90px; width: 300px; ">
					<div dojoType="dijit.layout.ContentPane" layoutAlign="top" class="closableDialog" style="background: #F3FBFE;">
						<span class="TitleBar" style="font-size: 9pt; display: inline;background: #F3FBFE;"> 
						    <s:text name="label.scrap.confirmation"></s:text>
						</span>
					</div>					
					<div dojoType="dijit.layout.ContentPane" layoutAlign="client" >
					    <br><s:text name="message.scrap.confirmation" /> 
					    <br><br>
						<table width="60%" class="buttonWrapperPrimary">				
							<tr>
								<td align="center">
								    <input type="button" id="confirmationSubmitButton" name="Submit2"
										value="<s:text name="label.common.yes"/>" class="buttonGeneric" />				
								</td>
								<td align="center">
								    <input type="button" name="Submit3"	value="<s:text name="label.common.no"/>" class="buttonGeneric"
										onclick="confirmationDialog.hide();" />
								</td>
							</tr>
						</table>
					</div>
					
				</div>
			</div>
</div>
	</s:form>

</u:body>

</html>