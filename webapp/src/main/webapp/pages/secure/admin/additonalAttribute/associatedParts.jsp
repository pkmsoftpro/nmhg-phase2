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
                <th colspan="7"><s:text name="title.additionalAtrribute.associateParts"/></th>
            </tr>
            <tr class="row_head">
                <th><s:text name="label.common.partNumber"/></th>
                <th><s:text name="columnTitle.shipmentGenerated.description"/></th>
            </tr>
        </thead>
        <tbody>
        	
            <s:iterator value="itemAtrrList" status="status">
                <tr>
                        <td>
                            <s:property value="itemAtrrList[#status.index].item.number" />
                        </td>
                        <td>
                            <s:property value="itemAtrrList[#status.index].item.description" />
                        </td>
                    
			</tr>
			</s:iterator>
                    
        </tbody>
    </table>
</div>

