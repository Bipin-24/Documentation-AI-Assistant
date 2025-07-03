<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwtrait="urn:WebWorks-Engine-FormatTraitInfo-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwbehaviors wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterAnchorsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwlinks" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-anchors-by-value" match="wwlinks:Anchor" use="@value" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:for-each select="$GlobalFiles[1]">
    <!-- Locate project links -->
    <!--                      -->
    <xsl:variable name="VarLinksFile" select="key('wwfiles-files-by-type', $ParameterDependsType)[1]" />

    <!-- Locate project anchors -->
    <!--                        -->
    <xsl:variable name="VarAnchorsFile" select="key('wwfiles-files-by-type', $ParameterAnchorsType)[1]" />

    <!-- Up to date? -->
    <!--             -->
    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarLinksFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarLinksFile/@groupID, $VarLinksFile/@documentID, $GlobalActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <xsl:variable name="VarResultAsTreeFragment">
      <!-- Load project links -->
      <!--                    -->
      <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksFile/@path, false())" />

      <!-- Load project anchors -->
      <!--                      -->
      <xsl:variable name="VarAnchors" select="wwexsldoc:LoadXMLWithoutResolver($VarAnchorsFile/@path, false())" />

      <!-- Minimize links -->
      <!--                -->
      <xsl:apply-templates select="$VarLinks" mode="wwmode:minimize">
       <xsl:with-param name="ParamAnchors" select="$VarAnchors" />
      </xsl:apply-templates>
     </xsl:variable>

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>
    </xsl:if>

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarLinksFile/@groupID}" documentID="{$VarLinksFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarLinksFile/@path}" checksum="{$VarLinksFile/@checksum}" groupID="{$VarLinksFile/@groupID}" documentID="{$VarLinksFile/@documentID}" />
      <wwfiles:Depends path="{$VarAnchorsFile/@path}" checksum="{$VarAnchorsFile/@checksum}" groupID="{$VarAnchorsFile/@groupID}" documentID="{$VarAnchorsFile/@documentID}" />
     </wwfiles:File>
    </xsl:if>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:minimize -->
 <!--                 -->

 <xsl:template match="/" mode="wwmode:minimize">
  <xsl:param name="ParamAnchors" />

  <xsl:apply-templates mode="wwmode:minimize">
   <xsl:with-param name="ParamAnchors" select="$ParamAnchors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:minimize">
  <xsl:param name="ParamAnchors" />

  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:minimize">
    <xsl:with-param name="ParamAnchors" select="$ParamAnchors" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="wwlinks:File" mode="wwmode:minimize">
  <xsl:param name="ParamAnchors" />

  <xsl:variable name="VarChildElementAsXML">
   <xsl:apply-templates mode="wwmode:minimize">
    <xsl:with-param name="ParamAnchors" select="$ParamAnchors" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarChildElements" select="msxsl:node-set($VarChildElementAsXML)/*" />

  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:if test="count($VarChildElements[1]) = 1">
    <!-- Copy child elements -->
    <!--                     -->
    <xsl:apply-templates select="$VarChildElements" mode="wwmode:copy" />
   </xsl:if>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:minimize">
  <xsl:param name="ParamAnchors" />
  <xsl:param name="ParamParagraph" select="." />

  <!-- Preserve? -->
  <!--           -->
  <xsl:variable name="VarPrecedingParagraphCount" select="count($ParamParagraph/preceding-sibling::wwlinks:Paragraph[1])" />
  <xsl:variable name="VarAnchorCount">
   <xsl:for-each select="$ParamAnchors[1]">
    <xsl:variable name="VarAnchor" select="key('wwlinks-anchors-by-value', $ParamParagraph/@id)[1]" />

    <xsl:value-of select="count($VarAnchor)" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPreserve" select="($VarPrecedingParagraphCount = 0) or ($VarAnchorCount = 1)" />
  <xsl:if test="$VarPreserve">
   <!-- Preserve -->
   <!--          -->
   <xsl:copy>
    <xsl:copy-of select="@*" />

    <xsl:apply-templates mode="wwmode:minimize">
     <xsl:with-param name="ParamAnchors" select="$ParamAnchors" />
    </xsl:apply-templates>
   </xsl:copy>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:minimize">
  <xsl:param name="ParamAnchors" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:copy -->
 <!--             -->

 <xsl:template match="/" mode="wwmode:copy">
  <xsl:apply-templates mode="wwmode:copy" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:copy">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:copy" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:copy">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
