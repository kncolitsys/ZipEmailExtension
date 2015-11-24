<cfparam name="ideeventinfo">

<cfset packet = xmlParse(ideeventinfo)>
<cfset event = packet.event>

<!--- Translate inputs to a struct --->
<cfset user = {}>
<cfloop index="x" from="1" to="#arrayLen(event.user.input)#">
	<cfset name = event.user.input[x].xmlAttributes.name>
	<cfset value = event.user.input[x].xmlAttributes.value>
	<cfset user[name] = value>
</cfloop>

<cfset ziplocation = user.folder & "/" & user.filename>

<!--- 
Ok, did we pick a folder, a file, or a selection, and if a selection, determine if he picked
something, cuz if not, we read in the whole file as text. 
--->

<!--- either project view... --->
<cfif structKeyExists(event.ide, "projectview")>
	<cfzip action="zip" file="#ziplocation#" source="#event.ide.projectview.resource.xmlAttributes.path#" recurse="yes" overwrite="true">		
<!--- or editor view --->
<cfelse>
	<!--- if we have text (selection), use that and save to temp, otherwise use the file --->
	<cfset thefile = event.ide.editor.file.xmlAttributes.location>
	<cfset text = event.ide.editor.selection.text.xmlText>
	<cfif text is "">
		<cfzip action="zip" file="#ziplocation#" source="#thefile#" overwrite="true">		
	<cfelse>
		<!--- technically lock isn't needed - this is single user --->
		<cflock type="exclusive" name="zipemailfilelock" timeout="10">
			<cfset tempfile = expandPath("./snippet.txt")>
			<cfset fileWrite(tempfile, text)>
			<cfzip action="zip" file="#ziplocation#" source="#tempfile#" overwrite="true">		
			<cfset fileDelete(tempfile)>
		</cflock>
	</cfif>
</cfif>

<!--- did we email? --->
<cfset mailsent = false>
<cfif len(user.email) and isValid("email", user.email) and len(user.from) and isValid("email", user.from)>
	<cfmail to="#user.email#" from="#user.from#" subject="Code Sample">
The attached code sample was sent to you via the ColdFusion Builder Extension: Zip/Email, 
created by Raymond Camden (ray@camdenfamily.com)
		<cfmailparam file="#ziplocation#">
	</cfmail>
	<cfset mailsent = true>
</cfif>

<!--- cfheader is critical --->
<cfheader name="Content-Type" value="text/xml">
<cfoutput> 
<response showresponse="true"> 
<ide>
<dialog width="500" height="250" />
<body> 
<![CDATA[ 
<cfoutput>
The zip was created and saved to #ziplocation#. 
<cfif mailsent>
It was also emailed to #user.email#
</cfif>
</cfoutput>
]]> 
</body> 
</ide> 
</response>
</cfoutput>