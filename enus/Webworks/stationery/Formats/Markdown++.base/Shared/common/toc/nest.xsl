<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwmode wwfiles wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwtoc" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwtoc-entry-by-id" match="wwtoc:Entry" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName(@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', @groupID, @documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />
       <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver(./wwfiles:Depends/@path, false())" />

       <xsl:call-template name="Next">
        <xsl:with-param name="ParamDocument" select="$VarDocument" />
        <xsl:with-param name="ParamTOC" select="$VarTOC" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{@groupID}" documentID="{@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Next">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamTOC" />

  <wwtoc:TableOfContents version="1.0">
   <xsl:for-each select="$ParamDocument/wwtoc:TableOfContents/wwtoc:Entry">
    <xsl:call-template name="Entry">
     <xsl:with-param name="ParamNode" select="." />
     <xsl:with-param name="ParamTOC" select="$ParamTOC" />
    </xsl:call-template>
   </xsl:for-each>
  </wwtoc:TableOfContents>
 </xsl:template>


 <xsl:template name="Entry">
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamTOC" />

  <!-- Entry -->
  <!--       -->
  <wwtoc:Entry>
   <xsl:copy-of select="@*" />

   <!-- Paragraph -->
   <!--           -->
   <xsl:for-each select="$ParamTOC[1]">
    <xsl:copy-of select="key('wwtoc-entry-by-id', $ParamNode/@id)[@documentID = $ParamNode/@documentID]/*" />
   </xsl:for-each>

   <!-- Children -->
   <!--          -->
   <xsl:for-each select="$ParamNode/wwtoc:Entry">
    <xsl:call-template name="Entry">
     <xsl:with-param name="ParamNode" select="." />
     <xsl:with-param name="ParamTOC" select="$ParamTOC" />
    </xsl:call-template>
   </xsl:for-each>
  </wwtoc:Entry>
 </xsl:template>
</xsl:stylesheet>
