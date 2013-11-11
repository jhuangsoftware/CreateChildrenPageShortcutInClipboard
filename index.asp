<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>TagIt</title>
	<style type="text/css">
		body
		{
			padding-top: 60px;
		}
	</style>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script id="page-template" type="text/x-handlebars-template">
		<div class="alert alert-info page" data-page-guid="{{guid}}">
			{{name}}
		</div>
	</script>
	<script type="text/javascript">
		var _EditLinkGuid = '<%= session("EltGuid") %>';
		var _UserGuid = '<%= session("UserGuid") %>';
		var _ProjectGuid = '<%= session("ProjectGuid") %>';
		
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
	
		$( document ).ready(function() {
			InitEditLinkGuid();

			LoadConnectedPages(_EditLinkGuid);
		});
		
		function InitEditLinkGuid()
		{
			if(_EditLinkGuid != '')
				return;
		
			var WindowOpenerLocation = window.opener.document.location;

			_EditLinkGuid = GetUrlVars(WindowOpenerLocation)['GUID'];
		}
		
		function GetUrlVars(SourceUrl)
		{
			if(SourceUrl == undefined)
			{
				SourceUrl = window.location.href;
			}
			SourceUrl = new String(SourceUrl);
			var vars = [], hash;
			var hashes = SourceUrl.slice(SourceUrl.indexOf('?') + 1).split('&');
			for(var i = 0; i < hashes.length; i++)
			{
				hash = hashes[i].split('=');
				vars.push(hash[0]);
				vars[hash[0]] = hash[1];
			}
	
			return vars;
		}
		
		function LoadConnectedPages(LinkGuid)
		{
			var strRQLXML = '<LINK action="load" guid="' + LinkGuid + '"><PAGES action="list"/></LINK>';
			// send RQL XML
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				// create display areas for each category
				$(data).find('PAGE').each(function(){
					var PageGuid = $(this).attr('guid');
					var PageName = $(this).attr('headline');
					AddPage(PageGuid, PageName);
				});
			});
		}
		
		function SaveToClipboard(UserGuid, ProjectGuid)
		{
			$('#saving').modal('show');
		
			var strRQLXML = '';
			strRQLXML += '<ADMINISTRATION><USER guid="' + UserGuid + '"><CLIPBOARDDATA action="add" projectguid="' + ProjectGuid + '">';
			
			$('.page').each(function(){
				strRQLXML += '<DATA guid="' + $(this).attr('data-page-guid') + '" type="page" />'
			});
			
			strRQLXML += '</CLIPBOARDDATA></USER></ADMINISTRATION>';
			
			// send RQL XML
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				$('#saving').modal('hide');
				
				Close(true);
			});
		}
		
		function Close(Refresh)
		{
			if(Refresh)
			{
				if (window.opener.name == 'ioTop')
				{
					// Launched from SmartEdit Mode Toolbar
					window.opener.ReloadEditedPage();
				}
				else if (window.opener.name == 'ioMain')
				{
					// Launched from Custom RedDot
					window.opener.location.reload();
				}
				else if (window.opener.name == 'Preview')
				{
					// Launched from Custom RedDot
					//window.opener.location.reload();
					
					var objClipBoard = window.opener.parent.document;
					$(objClipBoard).find('#RD__Clipboard_reload').click();
				}
				else if (window.opener.ReloadTreeSegment!=null)
				{
					// Launched from SmartTree
					window.opener.ReloadTreeSegment();
				}
			}
		
			window.opener = '';
			self.close();
		}
		
		function AddPage(PageGuid, PageName)
		{
			var PageObject = new Object();
			PageObject.name = PageName;
			PageObject.guid = PageGuid;
			
			var source = $("#page-template").html();
			var template = Handlebars.compile(source);
			var html = template(PageObject);
			$('#results').append(html);
		}
	</script>
</head>
<body>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<div class="pull-right">
					<button class="btn" type="button" onclick="Close(false);">Close</button>
					<button class="btn btn-success" href="#" onclick="SaveToClipboard(_UserGuid, _ProjectGuid);"><i class="icon-plus-sign icon-white"></i> Save To Clipboard</button>
				</div>
			</div>
		</div>
	</div>
	<div id="saving" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3>Saving</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
	<div class="container">
		<div id="results">
		</div>
	</div>
</body>
</html>