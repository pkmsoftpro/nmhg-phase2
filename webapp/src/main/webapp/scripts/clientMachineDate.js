/*

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

*/
function getPrintDate(){
	 var date = new Date(); 
	 var dates=date.getDate();
	if(dates<10)
		dates="0"+dates;
	 var month=date.getMonth()+1;
	 if(month<10)
		 month="0"+month;
	 var year=date.getFullYear(); 
	 var time=date.toTimeString(); 
	 var oTime=time.split(" ")[0];			
	 var dateTime=dates+"-"+month+"-"+year+" "+oTime+"."+date.getMilliseconds();
	 return dateTime;

}
    
    
