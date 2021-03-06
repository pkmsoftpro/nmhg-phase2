<%--
  Created by IntelliJ IDEA.
  User: vikas.sasidharan
  Date: 20 Nov, 2007
  Time: 2:28:01 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="t" uri="twms"%>
<%@taglib prefix="u" uri="/ui-ext"%>

<script type="text/javascript">  
 
</script>
<u:body >
<u:actionResults/>
<s:if test="searchedDealers.empty">
	<table  cellspacing="0" cellpadding="0" id="equipment_details_table" width="95%" class="grid" style="clear: both; margin:5px;">
		<tr>
        	<td align="center" colspan="9"><s:text name="error.retailMachineTransfer.noDealer" /></td>
        </tr> 	
    </table>    
</s:if>
<s:else>
<s:form method="post" id="multipleDealersForm" name="multipleDealersForm" action="showD2DConfirmation.action">
<s:if test="selectedInventoryItems!=null && selectedInventoryItems.size > 0">
	<s:iterator value="selectedInventoryItems" status="selectedInventoryItemsIter">
		<input type="hidden" name="selectedInventoryItems[<s:property value='%{#selectedInventoryItemsIter.index}'/>].inventoryItem" 
		       value='<s:property value="inventoryItem.id"/>'/>      
	</s:iterator>
</s:if>

<div id="warranty_machine_info_title" class="section_header"><s:text name="label.retailMachineTransfer.searchedDealers"/></div>
<table  cellspacing="0" cellpadding="0" id="equipment_details_table" width="96%" class="grid borderForTable" style="clear: both; margin:5px;">
    <thead>
        <tr>
            <th class="warColHeader" width="10%" class="non_editable"><s:text name="button.common.addLabel"/></th>
            <th class="warColHeader" width="10%" class="non_editable"><s:text name="columnTitle.common.dealerName"/></th>
            <th class="warColHeader" width="10%" class="non_editable"><s:text name="label.retailMachineTransfer.dealerAddress"/></th>
            <th class="warColHeader" width="10%"><s:text name="label.common.dealerNumber"/></th>                    
        </tr>
    </thead>
    <tbody>     
        <s:iterator value="searchedDealers" status="searchedDealersItr">
        <tr>
        	<td align="center" valign="middle">
        	 <s:if test="#searchedDealersItr.first">            	  
                <input type=radio id="dealer_<s:property value='{#searchedDealersItr.index}'/>" checked="checked"
                        name="selectedDealerForD2D.name" value="<s:property value="name"/>" />
             </s:if>
             <s:else>
             	<input type=radio id="dealer_<s:property value='{#searchedDealersItr.index}'/>"
                        name="selectedDealerForD2D.name" value="<s:property value="name"/>" />
             </s:else>                        
            </td>     
            <td>
            	<s:property value="name"/>             
            </td>
            <td>
                <s:property value="address.city"/> 
                <s:property value="address.state"/>
                <s:property value="address.country"/>
                <s:property value="address.zipCode"/>
            </td>
            <td>
                <s:property value="dealerNumber" />
            </td>
            
        </tr>
       </s:iterator>   
   </tbody>
</table>
<s:if test="!searchedDealers.empty">
<table width="100%">
	<tr>
		<td align="center" class="buttons">
			<s:submit id="selectDealerButton" value="%{getText('label.retailMachineTransfer.selectDealer')}"/>
		</td>
	</tr>
</table>
</s:if>
</s:form>
</s:else>
</u:body>