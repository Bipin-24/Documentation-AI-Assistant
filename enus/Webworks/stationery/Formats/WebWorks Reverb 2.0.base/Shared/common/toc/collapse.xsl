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
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
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

     <xsl:variable name="VarFilesDocument" select="." />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />

       <xsl:call-template name="Collapse">
        <xsl:with-param name="ParamTOC" select="$VarTOC" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Collapse">
  <xsl:param name="ParamTOC" />

  <wwtoc:TableOfContents>
   <xsl:copy-of select="$ParamTOC/wwtoc:TableOfContents/@*" />

   <xsl:variable name="VarTOCCollapse" select="wwprojext:GetFormatSetting('toc-collapse')" />

   <!-- Choose collapse behavior -->
   <!--                          -->
   <xsl:choose>
    <xsl:when test="$VarTOCCollapse = 'none'">
     <!-- No Collapse -->
     <!--             -->
     <xsl:call-template name="NoCollapse">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
     </xsl:call-template>
    </xsl:when>

    <xsl:when test="$VarTOCCollapse = 'relabel'">
     <!-- Relabel No Collapse -->
     <!--                     -->
     <xsl:call-template name="RelabelNoCollapse">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
     </xsl:call-template>
    </xsl:when>

    <xsl:when test="$VarTOCCollapse = 'full'">
     <!-- Full Collapse -->
     <!--               -->
     <xsl:call-template name="FullCollapse">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <!-- Smart Collapse -->
     <!--                -->
     <xsl:call-template name="SmartCollapse">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </wwtoc:TableOfContents>
 </xsl:template>


 <xsl:template name="NoCollapse">
  <xsl:param name="ParamParent" />

  <xsl:copy-of select="$ParamParent/wwtoc:Entry" />
 </xsl:template>


 <xsl:template name="GetLabel">
  <xsl:param name="ParamEntry" />

  <xsl:choose>
   <xsl:when test="count($ParamEntry/wwdoc:Paragraph[1]) = 0">
    <!-- Pull up paragraph -->
    <!--                   -->
    <xsl:for-each select="$ParamEntry/wwtoc:Entry[1]">
     <xsl:call-template name="GetLabel">
      <xsl:with-param name="ParamEntry" select="." />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:when>

   <xsl:otherwise>
    <!-- Use existing paragraph -->
    <!--                        -->
    <xsl:copy-of select="$ParamEntry/wwdoc:Paragraph" />

    <!-- Copy Behaviors -->
    <!--                -->
    <xsl:copy-of select="$ParamEntry/wwbehaviors:Paragraph"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="RelabelNoCollapse">
  <xsl:param name="ParamParent" />

  <xsl:for-each select="$ParamParent/wwtoc:Entry">
   <xsl:variable name="VarEntry" select="." />

   <wwtoc:Entry>
    <xsl:copy-of select="$VarEntry/@*" />

    <!-- Get label -->
    <!--           -->
    <xsl:call-template name="GetLabel">
     <xsl:with-param name="ParamEntry" select="$VarEntry" />
    </xsl:call-template>

    <!-- Children -->
    <!--          -->
    <xsl:call-template name="RelabelNoCollapse">
     <xsl:with-param name="ParamParent" select="$VarEntry" />
    </xsl:call-template>
   </wwtoc:Entry>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="FullCollapse">
  <xsl:param name="ParamParent" />

  <xsl:for-each select="$ParamParent/wwtoc:Entry">
   <xsl:variable name="VarEntry" select="." />

   <xsl:choose>
    <xsl:when test="count($VarEntry/wwdoc:Paragraph) = 0">
     <!-- Ignore entry and pull children up a level -->
     <!--                                           -->
     <xsl:call-template name="FullCollapse">
      <xsl:with-param name="ParamParent" select="$VarEntry" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <!-- Keep entry -->
     <!--            -->
     <wwtoc:Entry>
      <xsl:copy-of select="$VarEntry/@*" />

      <xsl:copy-of select="$VarEntry/wwdoc:Paragraph" />

      <!-- Copy Behaviors -->
      <!--                -->
      <xsl:copy-of select="$VarEntry/wwbehaviors:Paragraph"/>

      <!-- Children -->
      <!--          -->
      <xsl:call-template name="FullCollapse">
       <xsl:with-param name="ParamParent" select="$VarEntry" />
      </xsl:call-template>
     </wwtoc:Entry>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="SmartCollapse">
  <xsl:param name="ParamParent" />

  <xsl:variable name="VarNextNonEmptyLevel">
   <xsl:call-template name="GetNextNonEmptyLevel">
    <xsl:with-param name="ParamParent" select="$ParamParent" />
    <xsl:with-param name="ParamLevel" select="1" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$VarNextNonEmptyLevel &gt; 0">
   <xsl:call-template name="SmartCollapseRecurse">
    <xsl:with-param name="ParamParent" select="$ParamParent" />
    <xsl:with-param name="ParamLevel" select="1" />
    <xsl:with-param name="ParamNextNonEmptyLevel" select="$VarNextNonEmptyLevel" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="SmartCollapseRecurse">
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamLevel" />
  <xsl:param name="ParamNextNonEmptyLevel" />

  <xsl:for-each select="$ParamParent/wwtoc:Entry">
   <xsl:variable name="VarEntry" select="." />

   <xsl:choose>
    <xsl:when test="$ParamLevel = $ParamNextNonEmptyLevel">
     <wwtoc:Entry>
      <xsl:copy-of select="$VarEntry/@*" />

      <!-- Get label -->
      <!--           -->
      <xsl:call-template name="GetLabel">
       <xsl:with-param name="ParamEntry" select="$VarEntry" />
      </xsl:call-template>

      <!-- Find next non-empty level -->
      <!--                           -->
      <xsl:variable name="VarNextNonEmptyLevel">
       <xsl:call-template name="GetNextNonEmptyLevel">
        <xsl:with-param name="ParamParent" select="$VarEntry" />
        <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Children -->
      <!--          -->
      <xsl:if test="$VarNextNonEmptyLevel &gt; 0">
       <xsl:call-template name="SmartCollapseRecurse">
        <xsl:with-param name="ParamParent" select="$VarEntry" />
        <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
        <xsl:with-param name="ParamNextNonEmptyLevel" select="$VarNextNonEmptyLevel" />
       </xsl:call-template>
      </xsl:if>
     </wwtoc:Entry>
    </xsl:when>

    <xsl:otherwise>
     <!-- Ignore entry and pull children up a level -->
     <!--                                           -->
     <xsl:call-template name="SmartCollapseRecurse">
      <xsl:with-param name="ParamParent" select="$VarEntry" />
      <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
      <xsl:with-param name="ParamNextNonEmptyLevel" select="$ParamNextNonEmptyLevel" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="GetNextNonEmptyLevel">
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamLevel" />

  <xsl:variable name="VarEntries" select="$ParamParent/wwtoc:Entry" />
  <xsl:choose>
   <xsl:when test="count($VarEntries[1]) = 1">
    <xsl:variable name="VarParagraphs" select="$VarEntries/wwdoc:Paragraph" />
    <xsl:choose>
     <xsl:when test="count($VarParagraphs[1]) = 1">
      <xsl:value-of select="$ParamLevel" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="GetNextNonEmptyLevel">
       <xsl:with-param name="ParamParent" select="$VarEntries" />
       <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="0" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
