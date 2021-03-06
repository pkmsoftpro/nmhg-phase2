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
<%@taglib prefix="s" uri="/struts-tags" %>
<%@taglib prefix="html" uri="/struts-tags" %>
<%@ taglib prefix="sd" uri="/struts-dojo-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<%@ taglib prefix="authz" uri="authz" %>
<%
	response.setHeader("Pragma", "no-cache");
	response.addHeader("Cache-Control", "must-revalidate");
	response.addHeader("Cache-Control", "no-cache");
	response.addHeader("Cache-Control", "no-store");
	response.setDateHeader("Expires", 0);
%>
<html>
<head>
    <meta http-equiv="Context-Type" content="text/html; charset=ISO-8859-1"/>
    <title><s:text name="title.stateMandates"/></title>
    <s:head theme="twms"/>
    <!-- Scripts and stylesheet for the Calendar -->
    <script type="text/javascript" src="scripts/jscalendar/calendar.js"></script>
    <script type="text/javascript" src="scripts/jscalendar/lang/calendar-en.js"></script>
    <script type="text/javascript" src="scripts/jscalendar/calendar-setup.js"></script>

    <link href="scripts/jscalendar/calendar-brown.css" rel="stylesheet" type="text/css">
    <u:stylePicker fileName="adminPayment.css"/>
    <!-- End of scripts and stylesheet for the Calendar -->

    <!-- Javascripts and stylesheets for Admin section -->
    <script type="text/javascript" src="scripts/RepeatTable.js"></script>
    <script type="text/javascript" src="scripts/AdminToggle.js"></script>
    <script type="text/javascript">
        function validate(inputComponent) {

        }
    </script>
</head>
<u:body>
<s:form name="baseForm" id="baseFormId" theme="twms">
<u:actionResults/>
<s:hidden name="stateMandates.id" />
<div class="admin_section_div" style="margin:5px;width:99%">
    <div class="admin_section_heading"><s:text name="label.stateMandates.details" /></div>
    
        <table class="grid" width="100%" style="margin-top:10px;">
            <tr>
            <td nowrap="nowrap">
                  <label class="labelStyle"><s:text name="label.stateMandates.state"/>:</label>
              </td>
              <td  width="60%" nowrap="nowrap">
              	<s:select name="stateMandates.state"
							cssClass="processor_decesion"
							list="fetchCountryStates('US')"
							listKey="state" listValue="state"
							cssStyle="width:400px;" theme="twms" headerKey=""
							headerValue="%{getText('label.common.selectHeader')}" />
                  
              </td>
            </tr>
            <tr>
            <td nowrap="nowrap">
             <label class="labelStyle"><s:text name="label.stateMandates.effectiveDate"/>:</label>
            </td>
            <td>
             <sd:datetimepicker cssStyle='width:145px;' name='stateMandates.effectiveDate' id='dateOfFailure' />
            </td>
            </tr>
            
               <tr>
              <td nowrap="nowrap">
                  <label class="labelStyle"><s:text name="label.stateMandates.oemParts"/>:</label>
              </td>
              <td>
                  <s:textfield name="stateMandates.oemPartsPercent"/>
              </td>
            </tr>   
            
             <tr>
              <td nowrap="nowrap">
                  <label class="labelStyle"><s:text name="label.stateMandates.laborRateType"/>:</label>
              </td>
              <td>
                  <s:select name="stateMandates.laborRateType" id="laborRateType"
						cssClass="processor_decesion"
						list="getLaborRateTypes('LaborRateType')"
						theme="twms" listKey="code"
						listValue="description" cssStyle="width:400px;" headerKey=""
						headerValue="%{getText('label.common.selectHeader')}" />
						<script type="text/javascript">
		         dojo.addOnLoad(function(){
		     		<s:if test="stateMandates.laborRateType !=null">
					dijit.byId('laborRateType').setValue("<s:property value="stateMandates.laborRateType.code"/>");							              
				</s:if>
		           	dijit.byId("laborRateType").setDisabled(false);
		         });
		         </script>
              </td>
            </tr>
            
         <!-- State mandate Cost categories  -->
            <s:iterator value="costCategoryList" status="status">
            <tr nowrap="nowrap">
            <td><label class="labelStyle">
            <s:text name="%{getMessageKey(name)}"/>
            :</label> </td>
            
            <td>
            <input type="radio" name="stateMandates.stateMandateCostCatgs[<s:property value="%{#status.index}"/>].mandatory" value="true"><s:text name="label.yes"/>
            <input type="radio" name="stateMandates.stateMandateCostCatgs[<s:property value="%{#status.index}"/>].mandatory" value="false" checked="checked"><s:text name="label.no" />
            <s:hidden name="stateMandates.stateMandateCostCatgs[%{#status.index}].costCategory" value="%{costCategoryList[#status.index]}"></s:hidden>
            </td>
             </tr>
             </s:iterator>
             
             <s:iterator value="otherCategories" status="stat">
              <tr>
             <td nowrap="nowrap">
                  <label class="labelStyle"><s:property/>:</label>
                  <s:hidden name="stateMandateOtherCategory[%{#stat.index}].others" value="%{otherCategories[#stat.index]}" />
              </td>
              <td>
               <input type="radio" name="stateMandateOtherCategory[<s:property value="%{#stat.index}"/>].mandatory" value="true"><s:text name="label.yes"/>
            	<input type="radio" name="stateMandateOtherCategory[<s:property value="%{#stat.index}"/>].mandatory" value="false" checked="checked"><s:text name="label.no" />
              </td>
             </tr>
             </s:iterator>
          
             <tr>
               <td><label class="labelStyle"><s:text name="label.warrantyAdmin.comments"/>:</label></td>
  				<td><s:textarea name="stateMandateComments" cols="100" rows="6"/></td>
             </tr>
        </table>
     </div>
    <div align="center" style="margin:10px 0px 0px 0px;">
	  <input id="cancel_btn" class="buttonGeneric" type="button" value="<s:text name='button.common.cancel'/>"
				onclick="javascript:closeTab(getTabHavingLabel(getMyTabLabel()));" />
      <s:submit cssClass="buttonGeneric" value="%{getText('button.common.submit')}"  action="create_state_mandate"/>
    </div>
</s:form>
</u:body>
<authz:ifPermitted resource="warrantyAdminManageStateMandatesReadOnlyView">
	<script type="text/javascript">
	    dojo.addOnLoad(function() {
	        for ( var i = 0; i < dojo.query("input, button, textarea, select, text", dojo.byId('baseFormId')).length; i++) {
	            dojo.query("input, button, textarea, select, text", dojo.byId('baseFormId'))[i].disabled=true;
	        }
	    });
	</script>
</authz:ifPermitted>
</html>
