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
<%response.setHeader( "Pragma", "no-cache" );
response.addHeader( "Cache-Control", "must-revalidate" );
response.addHeader( "Cache-Control", "no-cache" );
response.addHeader( "Cache-Control", "no-store" );
response.setDateHeader("Expires", 0); %>

<script type="text/javascript">
    dojo.require("dijit.Tooltip")
</script>

<style type="text/css">
    .policyErrorIndicator {
        background-image: url("image/alerts.gif");
        background-position: center;
        background-repeat: no-repeat;
        height: 16px;
        width: 100%;
    }
</style>
<span id="one" tabindex="0" style="color:red">
<s:text name="error.message.policy"/>
</span>

<span dojoType="dijit.Tooltip" connectId="one">
		<s:fielderror theme="twms"/>
  		<s:actionerror theme="twms"/>
</span>


