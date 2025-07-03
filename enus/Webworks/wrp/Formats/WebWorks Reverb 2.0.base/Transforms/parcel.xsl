<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwbehaviors wwsplits wwvars wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterStandaloneParcelType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterDependsFilteredGroupType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterParcelInfoSplitFileType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/companyinfo/companyinfo_content.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />
 <xsl:key name="wwtoc-entries-by-path" match="wwtoc:Entry" use="@path" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <!-- Locale -->
 <!--        -->
 <xsl:variable name="GlobalLocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterLocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLocalePath)" />


 <!-- Links -->
 <!--        -->
 <xsl:variable name="GlobalLinksPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterLinksType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLinks" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLinksPath)" />


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

     <!-- Load splits -->
     <!--             -->
     <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarFilesDocument/@groupID][1]" />
     <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path)" />

     <xsl:for-each select="$VarSplits[1]">
      <!-- Split -->
      <!--       -->
      <xsl:variable name="VarSplit" select="key('wwsplits-files-by-type', $ParameterParcelInfoSplitFileType)[@groupID = $VarFilesDocument/@groupID][1]" />

      <xsl:call-template name="Parcel">
       <xsl:with-param name="ParamFilesSplits" select="$VarFilesSplits" />
       <xsl:with-param name="ParamSplits" select="$VarSplits" />
       <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
       <xsl:with-param name="ParamSplit" select="$VarSplit" />
      </xsl:call-template>
     </xsl:for-each>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:value-of select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Parcel">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamFilesDocument" />
  <xsl:param name="ParamSplit" />

  <!-- TOC -->
  <!--     -->
  <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path)" />

  <!-- Output directory path -->
  <!--                       -->
  <xsl:variable name="VarReplacedGroupName">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplit/@groupID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

  <!-- Split files -->
  <!--             -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarFileChildrenAsXML">
    <xsl:variable name="VarConditionsAsXML">
     <xsl:call-template name="PageTemplate-Conditions" />
    </xsl:variable>
    <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

    <xsl:variable name="VarReplacementsAsXML">
     <xsl:call-template name="PageTemplate-Replacements">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamTOC" select="$VarTOC" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

    <xsl:call-template name="PageTemplate-Process">
     <xsl:with-param name="ParamGlobalProject" select="$GlobalProject"/>
     <xsl:with-param name="ParamGlobalFiles" select="$GlobalFiles"/>
     <xsl:with-param name="ParamType" select="$ParameterType" />
     <xsl:with-param name="ParamPageTemplateURI" select="$ParameterPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$VarOutputDirectoryPath" />
     <xsl:with-param name="ParamResultPath" select="$ParamSplit/@path" />
     <xsl:with-param name="ParamConditions" select="$VarConditions" />
     <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
     <xsl:with-param name="ParamActionChecksum" select="$GlobalActionChecksum" />
     <xsl:with-param name="ParamProjectChecksum" select="''" />
     <xsl:with-param name="ParamLocaleType" select="$ParameterLocaleType" />
     <xsl:with-param name="ParamProjectVariablesType" select="$ParameterProjectVariablesType"/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFileChildren" select="msxsl:node-set($VarFileChildrenAsXML)" />

   <wwfiles:File path="{$ParamSplit/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplit/@path)}" projectchecksum="" groupID="{$ParamFilesDocument/@groupID}" documentID="{$ParamFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <xsl:copy-of select="$VarFileChildren" />
    <wwfiles:Depends path="{$GlobalLinksPath}" checksum="{wwfilesystem:GetChecksum($GlobalLinksPath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesDocument/@path}" checksum="{$ParamFilesDocument/@checksum}" groupID="{$ParamFilesDocument/@groupID}" documentID="{$ParamFilesDocument/@documentID}" />
   </wwfiles:File>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <!-- Mark of the Web (MOTW) -->
  <!--                        -->
  <xsl:if test="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'">
   <wwpage:Condition name="emit-mark-of-the-web" />
  </xsl:if>
 </xsl:template>

 <xsl:template name="PageTemplate-Replacements">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOC" />

  <!-- Mark of the Web (MOTW) -->
  <!--                        -->
  <wwpage:Replacement name="mark-of-the-web">
   <xsl:variable name="VarPrettyPrint" select="wwprojext:GetFormatSetting('file-processing-pretty-print') = 'true'" />
   <xsl:if test="not($VarPrettyPrint)">
    <xsl:text>
</xsl:text>
   </xsl:if>
   <xsl:comment> saved from url=(0016)http://localhost </xsl:comment>
   <xsl:if test="not($VarPrettyPrint)">
    <xsl:text>
</xsl:text>
   </xsl:if>
  </wwpage:Replacement>

  <wwpage:Replacement name="title" value="{$ParamSplit/@title}" />

  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
  <wwpage:Replacement name="content-type" value="text/html;charset=utf-8" />

  <!-- body-id -->
  <!--         -->
  <wwpage:Replacement name="body-id" value="id:{$ParamSplit/@groupID}" />

  <!-- toc-id -->
  <!--        -->
  <wwpage:Replacement name="toc-id" value="toc:{$ParamSplit/@groupID}" />

  <!-- topics-id -->
  <!--           -->
  <wwpage:Replacement name="data-id" value="data:{$ParamSplit/@groupID}" />

  <!-- No-JavaScript -->
  <!--               -->
  <wwpage:Replacement name="locales-no-javascript-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoJavaScriptMessage']/@value}" />

  <!-- TOC -->
  <!--     -->
  <wwpage:Replacement name="toc">
   <xsl:if test="wwprojext:GetFormatSetting('toc-generate') = 'true'">
    <xsl:apply-templates select="$ParamTOC" mode="wwmode:toc">
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
   </xsl:if>
  </wwpage:Replacement>

  <!-- Prev/Next -->
  <!--           -->
  <wwpage:Replacement name="prev-next">
   <xsl:variable name="VarSplitElements" select="$ParamSplits/wwsplits:Splits/wwsplits:Split" />
   <xsl:for-each select="$VarSplitElements">
    <xsl:variable name="VarSplit" select="." />
    <xsl:variable name="VarPageIDComponents">
     <xsl:value-of select="$VarSplit/@groupID"/>
     <xsl:text>:</xsl:text>
     <xsl:value-of select="$VarSplit/@documentID" />
     <xsl:text>:</xsl:text>
     <xsl:value-of select="wwfilesystem:GetRelativeTo($VarSplit/@path, wwprojext:GetTargetOutputDirectoryPath())" />
    </xsl:variable>
    <xsl:variable name="VarPageID" select="wwstring:NCNAME(translate(wwstring:MD5Checksum($VarPageIDComponents), '=', ''))" />
    <xsl:variable name="VarPositionName">
     <xsl:choose>
      <xsl:when test="position() = 1">
       <xsl:text>first</xsl:text>
      </xsl:when>
      <xsl:when test="position() = last()">
       <xsl:text>last</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="position()"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="VarHref">
     <xsl:call-template name="Connect-URI-GetRelativeTo">
      <xsl:with-param name="ParamDestinationURI" select="$VarSplit/@path" />
      <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
     </xsl:call-template>
    </xsl:variable>

    <html:div id="page:{$ParamSplit/@groupID}:{$VarPositionName}">
     <html:a id="p{$VarPageID}:{$VarPositionName}" href="{$VarHref}">
      <xsl:value-of select="$VarSplit/@title" />
     </html:a>
    </html:div>

    <xsl:if test="(position() = last()) and (position() = 1)">
     <html:div id="page:{$ParamSplit/@groupID}:last">
      <html:a id="p{$VarPageID}:last" href="{$VarHref}">
       <xsl:value-of select="$VarSplit/@title" />
      </html:a>
     </html:div>
    </xsl:if>
   </xsl:for-each>
  </wwpage:Replacement>

  <!-- Topics -->
  <!--        -->
  <wwpage:Replacement name="topics">
   <xsl:apply-templates select="$GlobalLinks" mode="wwmode:topics">
    <xsl:with-param name="ParamParcelPath" select="$ParamSplit/@path" />
    <xsl:with-param name="ParamGroupID" select="$ParamSplit/@groupID" />
   </xsl:apply-templates>
  </wwpage:Replacement>
 </xsl:template>

 <xsl:template name="Paragraph">
  <xsl:param name="ParamParagraph" />

  <xsl:variable name="VarText">
   <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
  </xsl:variable>
  <xsl:value-of select="normalize-space($VarText)" />
 </xsl:template>

 <!-- Process all valid text in TextRuns and nested TextRuns (depth first, in order). -->
 <!--                                                                                 -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun_text">
  <xsl:variable name="VarTextRun" select="."/>
  <!-- Recurse to find nested TextRuns, Text, and LineBreaks -->
  <!--                                                       -->
  <xsl:apply-templates select="$VarTextRun/*" mode="wwmode:textrun_text"/>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:textrun_text">
  <xsl:value-of select="./@value"/>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun_text">
  <!-- Replace LineBreaks with a single space -->
  <!--                                        -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="* |text() | comment() | processing-instruction()" mode="wwmode:textrun_text">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <!-- wwmode:toc -->
 <!--            -->

 <xsl:template match="/" mode="wwmode:toc">
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates mode="wwmode:toc">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwtoc:TableOfContents" mode="wwmode:toc">
  <xsl:param name="ParamSplit" />

  <!-- Process child entries -->
  <!--                       -->
  <xsl:if test="count(./wwtoc:Entry[1]) = 1">
   <html:ul>
    <xsl:apply-templates mode="wwmode:toc">
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
   </html:ul>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwtoc:Entry" mode="wwmode:toc">
  <xsl:param name="ParamEntry" select="." />
  <xsl:param name="ParamSplit" />

  <!-- Has child entries? -->
  <!--                    -->
  <xsl:variable name="VarTOCDisplay" select="$ParamEntry/@display"/>
  <xsl:variable name="VarHasChildEntries" select="count(./wwtoc:Entry[1]) = 1" />
  <xsl:variable name="VarHasLink" select="string-length($ParamEntry/@path) &gt; 0" />
  <xsl:variable name="VarHasTOCFolder" select="count(./wwtoc:Entry[@display = 'true']) &gt; 0" />

  <!-- TOC Class -->
  <!--           -->
  <xsl:variable name="VarTOCClassRaw">
   <xsl:variable name="VarTOCClassMarkers" select="$ParamEntry/wwbehaviors:Paragraph/wwbehaviors:Marker[@behavior = 'toc-entry-class']" />
   <xsl:if test="count($VarTOCClassMarkers) &gt; 0">
    <xsl:variable name="VarTOCClassMarker" select="$VarTOCClassMarkers[count($VarTOCClassMarkers)]" />
    <xsl:for-each select="$VarTOCClassMarker//wwdoc:TextRun/wwdoc:Text">
     <xsl:value-of select="@value" />
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarTOCClass" select="normalize-space($VarTOCClassRaw)" />

  <html:li>

   <!-- Emit TOC class -->
   <!--                -->
   <xsl:if test="(string-length($VarTOCClass) &gt; 0) or ($VarTOCDisplay != 'true')">
    <xsl:attribute name="class">
     <xsl:variable name="VarTOCClassValue">
      <xsl:if test="string-length($VarTOCClass) &gt; 0">
       <xsl:value-of select="wwstring:CSSClassName($VarTOCClass)" />
      </xsl:if>
      <!-- Is TOC display disabled? -->
      <!--                          -->
      <xsl:if test="$VarTOCDisplay != 'true'">
       <xsl:text> ww_skin_toc_entry_hidden</xsl:text>
      </xsl:if>
     </xsl:variable>
     <xsl:value-of select="$VarTOCClassValue" />
    </xsl:attribute>
   </xsl:if>

   <html:div>

    <!-- Determine page ID -->
    <!--                   -->
    <xsl:variable name="VarPageIDComponents">
     <xsl:value-of select="$ParamSplit/@groupID" />
     <xsl:text>:</xsl:text>
     <xsl:value-of select="$ParamEntry/@documentID" />
     <xsl:text>:</xsl:text>
     <xsl:value-of select="wwfilesystem:GetRelativeTo($ParamEntry/@path, wwprojext:GetTargetOutputDirectoryPath())" />
    </xsl:variable>
    <xsl:variable name="VarPageID" select="wwstring:NCNAME(translate(wwstring:MD5Checksum($VarPageIDComponents), '=', ''))" />

    <!-- Identify first TOC link to a page -->
    <!--                                   -->
    <xsl:for-each select="$ParamEntry">
     <xsl:variable name="VarFirstLinkToPage" select="count(key('wwtoc-entries-by-path', $ParamEntry/@path)[1] | $ParamEntry ) = 1" />
     <xsl:if test="$VarFirstLinkToPage">
      <xsl:attribute name="id">
       <xsl:text>p</xsl:text>
       <xsl:value-of select="$VarPageID" />
      </xsl:attribute>
     </xsl:if>
    </xsl:for-each>

    <!-- Folder or document? -->
    <!--                     -->
    <xsl:attribute name="class">
     <xsl:text>ww_skin_toc_entry</xsl:text>
     <xsl:choose>
      <xsl:when test="$VarHasTOCFolder">
       <xsl:text> ww_skin_toc_folder</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <xsl:text> ww_skin_toc_child</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>

    <!-- No break -->
    <!--          -->
    <wwexsldoc:NoBreak />

    <!-- Expand/collapse -->
    <!--                 -->
    <html:div class="ww_skin_toc_entry_indent"></html:div>

    <xsl:variable name="VarTOCIconPosition" select="wwprojext:GetFormatSetting('toc-icon-position')"/>

    <xsl:if test="$VarTOCIconPosition = 'left'">
     <html:div class="ww_skin_toc_entry_icon">
      <html:span class="ww_skin ww_skin_toc_dropdown ww_skin_toc_dropdown_closed">
       <html:i class="fa"></html:i>
      </html:span>
     </html:div>
    </xsl:if>

    <!-- Entry -->
    <!--       -->
    <xsl:choose>
     <xsl:when test="$VarHasLink">
      <!-- Determine TOC Entry ID -->
      <!--                        -->
      <xsl:variable name="VarTOCEntryID">
       <xsl:text>p</xsl:text>
       <xsl:value-of select="$VarPageID" />
       <xsl:text>:</xsl:text>
       <xsl:text>ww</xsl:text>
       <xsl:value-of select="$ParamEntry/@linkid" />
      </xsl:variable>

      <!-- Get link -->
      <!--          -->
      <xsl:variable name="VarRelativeLinkPath">
       <xsl:call-template name="Connect-URI-GetRelativeTo">
        <xsl:with-param name="ParamDestinationURI" select="$ParamEntry/@path" />
        <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
       </xsl:call-template>
      </xsl:variable>

      <html:a id="{$VarTOCEntryID}" class="ww_skin_toc_entry_title">
       <xsl:attribute name="href">
        <xsl:value-of select="$VarRelativeLinkPath" />
        <xsl:text>#</xsl:text>
        <xsl:if test="$ParamEntry/@first != 'true'">
         <xsl:text>ww</xsl:text>
         <xsl:value-of select="$ParamEntry/@linkid" />
        </xsl:if>
       </xsl:attribute>

       <xsl:call-template name="Paragraph">
        <xsl:with-param name="ParamParagraph" select="$ParamEntry/wwdoc:Paragraph" />
       </xsl:call-template>
      </html:a>
     </xsl:when>

     <xsl:otherwise>
      <html:div class="ww_skin_toc_entry_title">
       <xsl:call-template name="Paragraph">
        <xsl:with-param name="ParamParagraph" select="$ParamEntry/wwdoc:Paragraph" />
       </xsl:call-template>
      </html:div>
     </xsl:otherwise>
    </xsl:choose>

    <!-- Expand/collapse -->
    <!--                 -->
    <xsl:if test="$VarTOCIconPosition = 'right'">
     <html:div class="ww_skin_toc_entry_icon">
      <html:span class="ww_skin ww_skin_toc_dropdown ww_skin_toc_dropdown_closed">
       <html:i class="fa"></html:i>
      </html:span>
     </html:div>
    </xsl:if>
   </html:div>

   <!-- Process child entries -->
   <!--                       -->
   <xsl:if test="$VarHasChildEntries">
    <html:ul>
     <xsl:apply-templates mode="wwmode:toc">
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:apply-templates>
    </html:ul>
   </xsl:if>
  </html:li>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:toc">
  <xsl:param name="ParamSplit" />

  <!-- Process child entries -->
  <!--                       -->
  <xsl:apply-templates mode="wwmode:toc">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:toc">
  <xsl:param name="ParamSplit" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:topics -->
 <!--               -->

 <xsl:template match="/" mode="wwmode:topics">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:topics">
   <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
   <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwlinks:File" mode="wwmode:topics">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamLinkFile" select="." />

  <!-- Matches group? -->
  <!--                -->
  <xsl:if test="$ParamLinkFile/@groupID = $ParamGroupID">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:topics-paragraph">
    <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
    <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
    <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:topics">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:topics">
   <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
   <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:topics">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:topics-paragraph -->
 <!--                         -->

 <xsl:template match="/" mode="wwmode:topics-paragraph">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamLinkFile" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:topics-paragraph">
   <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
   <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
   <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:topics-paragraph">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamLinkFile" />
  <xsl:param name="ParamLinkParagraph" select="." />

  <!-- Topic? -->
  <!--        -->
  <xsl:if test="string-length($ParamLinkParagraph/@topic) &gt; 0">
   <!-- Resolve link -->
   <!--              -->
   <xsl:variable name="VarHREF">
    <xsl:value-of select="wwuri:GetRelativeTo($ParamLinkFile/@path, $ParamParcelPath)" />
    <xsl:text>#</xsl:text>
    <xsl:if test="$ParamLinkParagraph/@first = 'false'">
     <xsl:text>ww</xsl:text>
     <xsl:value-of select="$ParamLinkParagraph/@linkid" />
    </xsl:if>
   </xsl:variable>

   <!-- Emit topic -->
   <!--            -->
   <html:div>
    <html:a id="topic:{$ParamGroupID}:{wwstring:WebWorksHelpContextOrTopic($ParamLinkParagraph/@topic)}" href="{$VarHREF}">
     <xsl:value-of select="$ParamLinkParagraph/@topic" />
    </html:a>
   </html:div>
  </xsl:if>

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:topics-paragraph">
   <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
   <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
   <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:topics-paragraph">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamLinkFile" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:topics-paragraph">
   <xsl:with-param name="ParamParcelPath" select="$ParamParcelPath" />
   <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
   <xsl:with-param name="ParamLinkFile" select="$ParamLinkFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:topics-paragraph">
  <xsl:param name="ParamParcelPath" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamLinkFile" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
