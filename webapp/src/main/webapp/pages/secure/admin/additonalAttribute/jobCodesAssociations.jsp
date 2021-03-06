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

<%@taglib prefix="s" uri="/struts-tags"%>
<%@taglib prefix="authz" uri="authz"%>
<%@taglib prefix="u" uri="/ui-ext"%>
<u:stylePicker fileName="batterytestsheet.css"/>

<div dojoType="dijit.layout.ContentPane" layoutAlign="client" style="margin: 2px; padding: 3px;">
    <table class="grid borderForTable" border="0" cellspacing="0" cellpadding="0" width="100%">
        <thead>
            <tr class="row_head">
                <th colspan="7"><s:text name="title.manageAdditionalAttributes.associatedAttributes"/></th>
            </tr>
           
	        <tr class="row_head">
	        	<th width="15%"><s:text name="columnTitle.common.product"/></th>
	        	<th width="15%"><s:text name="columnTitle.common.model"/></th>
	        	<th width="30%"><s:text name="label.common.jobCode"/></th>
	        	<th width="30%"><s:text name="columnTitle.duePartsInspection.faultcode"/></th>
	        </tr>
    	</thead>
        
        <tbody>
        	
            <s:iterator value="claimedItemAttrList" status="status">
                <tr>
                        <td>
                            <s:property value="claimedItemAttrList[#status.index].product.name" />
                        </td>
                        <td>
                            <s:property value="claimedItemAttrList[#status.index].itemGroup.name" />
                        </td>
                        <td>
                            <s:property value="claimedItemAttrList[#status.index].serviceProcedure.definition.code" />
                        </td>
                        <td>
                            <s:property value="claimedItemAttrList[#status.index].faultCode.definition.code" />
                        </td>
                    
			</tr>
			</s:iterator>
                    
        </tbody>
    </table>
</div>

