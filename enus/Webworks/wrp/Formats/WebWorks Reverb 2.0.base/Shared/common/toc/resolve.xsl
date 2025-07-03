<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwlinks wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwtoc" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-paragraphs-by-id" match="wwlinks:Paragraph" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Load project links -->
   <!--                    -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:for-each select="key('wwfiles-files-by-type', $ParameterLinksType)[1]">
     <xsl:variable name="VarFilesProjectLinks" select="." />

     <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesProjectLinks/@path, false())" />

     <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

     <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

     <!-- Iterate input documents -->
     <!--                         -->
     <xsl:for-each select="$VarFilesByType">
      <xsl:variable name="VarFilesTOC" select="." />

      <xsl:value-of select="wwprogress:Start(1)" />

      <!-- Call template -->
      <!--               -->
      <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesTOC/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, @groupID, @documentID, $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Load document -->
        <!--               -->
        <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesTOC/@path, false())" />

        <xsl:call-template name="Resolve">
         <xsl:with-param name="ParamLinks" select="$VarLinks" />
         <xsl:with-param name="ParamGroupID" select="$VarFilesTOC/@groupID" />
         <xsl:with-param name="ParamTOC" select="$VarTOC" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'UTF-8', 'xml', '1.0', 'yes')" />
      </xsl:if>

      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesTOC/@groupID}" documentID="{$VarFilesTOC/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarFilesProjectLinks/@path}" checksum="{$VarFilesProjectLinks/@checksum}" groupID="{$VarFilesProjectLinks/@groupID}" documentID="{$VarFilesProjectLinks/@documentID}" />
       <wwfiles:Depends path="{$VarFilesTOC/@path}" checksum="{$VarFilesTOC/@checksum}" groupID="{$VarFilesTOC/@groupID}" documentID="{$VarFilesTOC/@documentID}" />
      </wwfiles:File>

      <xsl:value-of select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:value-of select="wwprogress:End()" />

    </xsl:for-each>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Resolve">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamTOC" />

  <wwtoc:TableOfContents>
   <xsl:copy-of select="$ParamTOC/wwtoc:TableOfContents/@*" />

   <xsl:apply-templates select="$ParamTOC/wwtoc:TableOfContents/wwtoc:Entry" mode="wwmode:tocentry">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
   </xsl:apply-templates>
  </wwtoc:TableOfContents>
 </xsl:template>


 <xsl:template match="wwtoc:Entry" mode="wwmode:tocentry">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamGroupID" />

  <xsl:variable name="VarEntry" select="." />

  <xsl:for-each select="$ParamLinks[1]">
   <xsl:variable name="VarParagraphLink" select="key('wwlinks-paragraphs-by-id', $VarEntry/@id)[../@documentID = $VarEntry/@documentID]" />

   <!-- Get link info -->
   <!--               -->
   <xsl:variable name="VarPath">
    <xsl:for-each select="$VarParagraphLink[1]">
     <xsl:value-of select="$VarParagraphLink/../@path" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarLinkID">
    <xsl:for-each select="$VarParagraphLink[1]">
     <xsl:value-of select="$VarParagraphLink/@linkid" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarFilePosition">
    <xsl:for-each select="$VarParagraphLink[1]">
     <xsl:value-of select="$VarParagraphLink/../@fileposition" />
    </xsl:for-each>
   </xsl:variable>

   <!-- Emit entry -->
   <!--            -->
   <wwtoc:Entry>
    <xsl:copy-of select="$VarEntry/@*" />
    <xsl:if test="string-length($VarPath) &gt; 0">
     <xsl:attribute name="path">
      <xsl:value-of select="$VarPath" />
     </xsl:attribute>
    </xsl:if>
    <xsl:if test="string-length($VarLinkID) &gt; 0">
     <xsl:attribute name="linkid">
      <xsl:value-of select="$VarLinkID" />
     </xsl:attribute>
    </xsl:if>
    <xsl:if test="string-length($VarFilePosition) &gt; 0">
     <xsl:attribute name="fileposition">
      <xsl:value-of select="$VarFilePosition" />
     </xsl:attribute>
    </xsl:if>
    <xsl:if test="string-length($VarParagraphLink/@first) &gt; 0">
     <xsl:attribute name="first">
      <xsl:value-of select="$VarParagraphLink/@first" />
     </xsl:attribute>
    </xsl:if>

    <!-- Preserve paragraph -->
    <!--                    -->
    <xsl:copy-of select="$VarEntry/wwdoc:Paragraph | $VarEntry/wwbehaviors:Paragraph | $VarEntry/text()" />

    <xsl:apply-templates select="$VarEntry/wwtoc:Entry" mode="wwmode:tocentry">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
    </xsl:apply-templates>
   </wwtoc:Entry>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
