<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:template name="Connect-Project-Files-As-Splits">
  <xsl:param name="ParamProjectFiles" />

  <wwsplits:Splits>
   <xsl:variable name="VarProjectFilesDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), 'dummy.component')" />
   <xsl:variable name="VarConnectTargetDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'connect')" />
   <xsl:for-each select="$ParamProjectFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarProjectFile" select="." />

    <xsl:variable name="VarRelativePath" select="wwfilesystem:GetRelativeTo($VarProjectFile/@path, $VarProjectFilesDirectoryPath)" />
    <xsl:variable name="VarRelativeURI" select="wwuri:GetRelativeTo($VarProjectFile/@path, 'wwprojfile:dummy.component')" />
    <xsl:variable name="VarConnectRelativePath">
     <xsl:call-template name="Connect-File-Path">
      <xsl:with-param name="ParamPath" select="$VarRelativePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarProjectFilePath" select="wwfilesystem:Combine($VarConnectTargetDirectoryPath, $VarConnectRelativePath)" />

    <!-- Allow? -->
    <!--        -->
    <xsl:variable name="VarAllow">
     <xsl:call-template name="Files-Filter-Allow">
      <xsl:with-param name="ParamPath" select="$VarProjectFilePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$VarAllow = 'true'">
     <!-- Emit -->
     <!--      -->
     <wwsplits:File groupID="" documentID="" id="" type="" source="wwprojfile:{$VarRelativeURI}" source-lowercase="wwprojfile:{wwstring:ToLower($VarRelativeURI)}" path="{$VarProjectFilePath}" path-lowercase="{wwstring:ToLower($VarProjectFilePath)}" title="" />
    </xsl:if>
   </xsl:for-each>
  </wwsplits:Splits>
 </xsl:template>
</xsl:stylesheet>
