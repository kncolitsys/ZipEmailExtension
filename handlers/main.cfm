
<cfheader name="Content-Type" value="text/xml">
<cfoutput>
<response showresponse="true">
<ide handlerfile="action.cfm">
<dialog title="Zip/Email" height="340" width="420">
<input name="folder" type="dir" label="Zip Location" tooltip="Select location for zip" required="true" />
<input name="filename" label="File Name" tooltip="Enter the file name" required="true" default="code.zip" />
<input name="email" label="Email Address" tooltip="Enter an email address" required="false" />
<input name="from" label="From Email" tooltip="Enter your email address" required="false" />
</dialog>
</ide>
</response></cfoutput>
