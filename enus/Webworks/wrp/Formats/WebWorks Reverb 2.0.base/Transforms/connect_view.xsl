<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc wwexec wwenv wwlocale"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocalePathChecksum" select="wwfilesystem:GetChecksum($GlobalUILocalePath)" />
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Up to date? -->
   <!--             -->
   <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.vbs'))" />
   <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
   <xsl:if test="not($VarUpToDate)">
    <xsl:variable name="VarResultAsXML">
     <xsl:call-template name="View-Command">
      <xsl:with-param name="ParamEntryName">
       <xsl:value-of select="wwprojext:GetProjectName()" />
       <xsl:text> - </xsl:text>
       <xsl:value-of select="wwfilesystem:GetFileName(wwprojext:GetTargetOutputDirectoryPath())" />
      </xsl:with-param>
      <xsl:with-param name="ParamEntryPath" select="wwprojext:GetTargetOutputDirectoryPath()" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'text')" />
   </xsl:if>

   <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ViewOutput']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
   </wwfiles:File>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="View-Command">
  <xsl:param name="ParamEntryName" />
  <xsl:param name="ParamEntryPath" />

  <xsl:variable name="VarPort" select="9292" />

  <xsl:text>' view.vbs
'

' Constants
'
Const TEMP_FOLDER = 2
Const ENTRY_NAME = "</xsl:text><xsl:value-of select="$ParamEntryName" /><xsl:text>"
Const ENTRY_PATH = "</xsl:text><xsl:value-of select="$ParamEntryPath" /><xsl:text>"

' Instantiate objects
'
Set fileSystemObject = CreateObject("Scripting.FileSystemObject")
Set tempDirectory = fileSystemObject.GetSpecialFolder(TEMP_FOLDER)
Set shell = CreateObject("WScript.Shell")

' Configure
'
configuration_path = fileSystemObject.BuildPath(tempDirectory, "WebWorks")
If (Not fileSystemObject.FolderExists(configuration_path)) Then
  fileSystemObject.CreateFolder(configuration_path)
End If
configuration_path = fileSystemObject.BuildPath(configuration_path, "localhost")
If (Not fileSystemObject.FolderExists(configuration_path)) Then
  fileSystemObject.CreateFolder(configuration_path)
End If
configuration_path = fileSystemObject.BuildPath(configuration_path, ENTRY_NAME &amp; ".txt")
Set configuration = fileSystemObject.CreateTextFile(configuration_path, True, False)
configuration.WriteLine(ENTRY_PATH)
configuration.Close()

' Launch server
'
command = """</xsl:text><xsl:value-of select="wwuri:AsFilePath('wwhelper:localhost/WebWorks localhost.exe')" /><xsl:text>"" </xsl:text><xsl:value-of select="$VarPort" /><xsl:text>"
result = shell.Run(command, 1, False)

' Launch URI
'
command = """http://localhost:</xsl:text><xsl:value-of select="$VarPort" /><xsl:text>/" &amp; ENTRY_NAME &amp; "/"""
result = shell.Run(command, 1, False)
</xsl:text>
 </xsl:template>
</xsl:stylesheet>

