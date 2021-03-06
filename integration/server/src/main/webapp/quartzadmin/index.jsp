<%-- 
    Document   : listSchedulers
    Created on : 16 Dec, 2011, 1:50:31 PM
    Author     : prasad.r
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
        <title>Integration Server :: Quartz Scheduler</title>
		<link href="<s:url includeParams='none' value='/stylesheet/master.css' encode='false'/>" rel="stylesheet" type="text/css">
		<link href="<s:url includeParams='none' value='/stylesheet/style.css' encode='false'/>" rel="stylesheet" type="text/css">

<link rel="stylesheet" type="text/css" media="all" href="<s:url includeParams='none' value='/scripts/jqGrid/css/ui.jqgrid.css' encode='false'/>"/>
<link rel="stylesheet" type="text/css" media="all"	href="<s:url includeParams='none' value='/scripts/jqGrid/css/cupertino/jquery-ui-1.7.2.custom.css' encode='false'/>"/>

<script src="<s:url includeParams='none' value='/scripts/jqGrid/js/jquery-1.5.2.min.js' encode='false'/>" type="text/javascript"></script>
<script src="<s:url includeParams='none' value='/scripts/jqGrid/js/i18n/grid.locale-en.js' encode='false'/>" type="text/javascript"></script>
<script src="<s:url includeParams='none' value='/scripts/jqGrid/js/jquery.jqGrid.min.js' encode='false'/>" type="text/javascript"></script>
    </head>
    <body>
		<div align="center"><b>Integration Server</b> </div>
		<div align="left"><a href='<s:url action="Home"/>' style="color: navy;"> Home </a> &gt; Scheduler List</div>
        <div align="right" style="padding-right: 25px"><a href='<s:url action="Home!logout"/>' style="color: navy;"> Logout </a></div>
        <hr>
        <table id="list" style="width:90%;"></table>
        <div id="pager"></div>
    </body>
    <script lang="javascript">
            jQuery(document).ready(function() {
                    jQuery("#list").jqGrid({
                    datatype: 'json',
                    url:"listSchedulers.action",
                    mtype: 'GET',
                    colNames:['Schedular Name','Started', 'Jobs Count', 'Running Since'],
                    colModel:[
                        {name:'scheduler.name',label:'scheduler.name', editable: false, sortable:true, search:false, formatter:'showlink', formatoptions:{baseLinkUrl:'schedulerDetail.action'}},
                        {name:'started',label:'Started', editable: false, sortable:false, search:false},
                        {name:'jobs.count',label:'Jobs Count', editable: false, sortable:false, search:false},
                        {name:'runningSince',label:'runningSince', editable: false, sortable:false, search:false}                
                    ],
                    pager: '#pager',
                    rowNum:-1,
                    height:'125px',
                    imgpath: 'css/smoothness/images',
                    sortname: 'scheduler.name',
                    sortorder: 'asc',
                    jsonReader: {
                        repeatitems : false,
                        cell:"",
                        id: "0"
                    },
                    viewrecords: true,
                    autowidth:true,
                    caption: 'Schedulers List'
                });
//                jQuery("#list").filterToolbar({useparammap:true,searchOnEnter:false});
            });
    </script>
</html>
