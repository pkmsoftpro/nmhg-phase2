<%--

   Copyright (c)2006 Tavant Technologies All Rights Reserved.

   This software is furnished under a license and may be used and copied
   only  in  accordance  with  the  terms  of such  license and with the
   inclusion of the above copyright notice. This software or  any  other
   copies thereof may not be provided or otherwise made available to any
   other person. No title to and ownership of  the  software  is  hereby
   transferred.

   The information in this software is subject to change without  notice
   and  should  not be  construed as a commitment  by Tavant Technologies.

--%>

<%@ taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%><%@taglib prefix="u" uri="/ui-ext"%>
<s:if test="reportType == 'processingEngineEfficiency'">
<div class="snap">
<div id="separator"></div>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="bgColor">
	<tr>
		<td colspan="4" class="sectionTitle"><s:text name="label.report.description"/></td>
	</tr>
	<tr>
		<td colspan="4" nowrap="nowrap" class="labelNormalTop"><s:text name="label.report.processingEngineEfficiencyDescription"/></td>
	</tr>
</table>
<div id="separator"></div>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="bgColor">
	<tr>
		<td colspan="4" class="sectionTitle"><s:text name="label.report.specifyReportParameters"/></td>
	</tr>
	<tr>
		<td colspan="4" nowrap="nowrap" height="3"></td>
	</tr>
	  			 <tr>
               	  <td class="label" width="7%"><s:text name="label.report.format" /></td>
		          <td><s:select label="label" name="taskName"
	          				list="reportTypes" required="true"/></td>
		          <td class="label">&nbsp;</td>
		          <td>&nbsp;</td>
	        </tr>
	  
	</table>
	<div class="buttonWrapperPrimary">
	<s:submit cssClass="buttonGeneric" action="processingEfficiencyReport" value="%{getText('button.report.generate')}"/>
	</div>
</div>
</s:if>
