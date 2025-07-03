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
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterProjectSplitsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterStylesType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterTOCDataType" />
 <xsl:param name="ParameterAllowBaggage" />
 <xsl:param name="ParameterAllowGroupToGroup" />
 <xsl:param name="ParameterAllowURL" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterTOCSplitFileType" />
 <xsl:param name="ParameterIndexSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />

 <xsl:key name="wwdoc-elements-by-id" match="wwdoc:Paragraph | wwdoc:List | wwdoc:Block | wwdoc:Table" use="@id" />

 <xsl:variable name="GlobalDefaultNamespace" select="'http://www.w3.org/1999/xhtml'" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />


 <xsl:include href="wwtransform:common/accessibility/images.xsl"/>
 <xsl:include href="wwtransform:common/accessibility/tables.xsl"/>
 <xsl:include href="wwtransform:common/behaviors/options.xsl"/>
 <xsl:include href="wwtransform:common/companyinfo/companyinfo_content.xsl" />
 <xsl:include href="wwtransform:common/images/utilities.xsl" />
 <xsl:include href="wwtransform:common/links/resolve.xsl" />
 <xsl:include href="wwtransform:common/pages/popups.xsl" />
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:common/tables/tables.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/content.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/links/resolve.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/links/resolve.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/popups.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/popups.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/tables/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/tables/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
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

 <!-- Project Splits -->
 <!--                -->
 <xsl:variable name="GlobalProjectSplitsPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectSplitsType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectSplits" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectSplitsPath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:call-template name="Popups">
    <xsl:with-param name="ParamInput" select="$GlobalInput" />
    <xsl:with-param name="ParamProject" select="$GlobalProject" />
    <xsl:with-param name="ParamFiles" select="$GlobalFiles" />
    <xsl:with-param name="ParamLinksType" select="$ParameterLinksType" />
    <xsl:with-param name="ParamDependsType" select="$ParameterDependsType" />
    <xsl:with-param name="ParamSplitsType" select="$ParameterSplitsType" />
    <xsl:with-param name="ParamBehaviorsType" select="$ParameterBehaviorsType" />
    <xsl:with-param name="ParamTOCDataType" select="$ParameterTOCDataType" />
   </xsl:call-template>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Popup">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplitsPopup" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamPopupBehaviorParagraphs" />

  <!-- Output directory path -->
  <!--                       -->
  <xsl:variable name="VarReplacedGroupName">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplitsPopup/@groupID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

  <!-- Page Rule -->
  <!--           -->
  <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $ParamSplitsPopup/@stylename)" />

  <!-- Split files -->
  <!--             -->
  <xsl:for-each select="$ParamSplits[1]">
   <!-- TOC -->
   <!--     -->
   <xsl:variable name="VarTOCSplitFile" select="key('wwsplits-files-by-groupid-type', concat($ParamSplitsPopup/@groupID, ':', $ParameterTOCSplitFileType))[1]" />

   <!-- Index -->
   <!--       -->
   <xsl:variable name="VarIndexSplitFile" select="key('wwsplits-files-by-groupid-type', concat($ParamSplitsPopup/@groupID, ':', $ParameterIndexSplitFileType))[1]" />

   <!-- Popup page -->
   <!--            -->
   <xsl:variable name="VarPopupPageAsXML">
    <wwbehaviors:PopupPage />
   </xsl:variable>
   <xsl:variable name="VarPopupPage" select="msxsl:node-set($VarPopupPageAsXML)" />

   <!-- Cargo -->
   <!--       -->
   <xsl:variable name="VarCargo" select="$ParamBehaviors | $VarPopupPage" />

   <xsl:variable name="VarFileChildrenAsXML">
    <xsl:variable name="VarConditionsAsXML">
     <xsl:call-template name="PageTemplate-Conditions">
      <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

    <xsl:variable name="VarReplacementsAsXML">
     <xsl:call-template name="PageTemplate-Replacements">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamSplitsPopup" select="$ParamSplitsPopup" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamFilesDocumentNode" select="$ParamFilesDocumentNode" />
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamPopupBehaviorParagraphs" select="$ParamPopupBehaviorParagraphs" />
      <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
      <xsl:with-param name="ParamOutputDirectoryPath" select="$VarOutputDirectoryPath" />
      <xsl:with-param name="ParamCargo" select="$VarCargo" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

    <xsl:call-template name="PageTemplate-Process">
     <xsl:with-param name="ParamGlobalProject" select="$GlobalProject"/>
     <xsl:with-param name="ParamGlobalFiles" select="$GlobalFiles"/>
     <xsl:with-param name="ParamType" select="$ParameterType" />
     <xsl:with-param name="ParamPageTemplateURI" select="$ParameterPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$VarOutputDirectoryPath" />
     <xsl:with-param name="ParamResultPath" select="$ParamSplitsPopup/@path" />
     <xsl:with-param name="ParamConditions" select="$VarConditions" />
     <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
     <xsl:with-param name="ParamActionChecksum" select="$GlobalActionChecksum" />
     <xsl:with-param name="ParamProjectChecksum" select="''" />
     <xsl:with-param name="ParamLocaleType" select="$ParameterLocaleType" />
     <xsl:with-param name="ParamProjectVariablesType" select="$ParameterProjectVariablesType"/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFileChildren" select="msxsl:node-set($VarFileChildrenAsXML)" />

   <wwfiles:File path="{$ParamSplitsPopup/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplitsPopup/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplitsPopup/@groupID}" documentID="{$ParamSplitsPopup/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <xsl:copy-of select="$VarFileChildren" />
    <wwfiles:Depends path="{$ParamFilesDocumentNode/@path}" checksum="{$ParamFilesDocumentNode/@checksum}" groupID="{$ParamFilesDocumentNode/@groupID}" documentID="{$ParamFilesDocumentNode/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
   </wwfiles:File>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <xsl:param name="ParamPageRule" />
  <!-- catalog-css -->
  <!--             -->
  <wwpage:Condition name="catalog-css" />

  <!-- document-css -->
  <!--              -->
  <xsl:if test="string-length($ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value) &gt; 0">
   <wwpage:Condition name="document-css" />
  </xsl:if>
 </xsl:template>

 <xsl:template name="PageTemplate-Replacements">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplitsPopup" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamPopupBehaviorParagraphs" />
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamCargo" />

  <xsl:variable name="VarRelativeRootURIWithDummyComponent" select="wwuri:GetRelativeTo(wwfilesystem:Combine($ParamOutputDirectoryPath, 'dummy.component'), $ParamSplitsPopup/@path)" />
  <xsl:variable name="VarRelativeRootURI">
   <xsl:variable name="VarStringLengthDifference" select="string-length($VarRelativeRootURIWithDummyComponent) - string-length('dummy.component')" />
   <xsl:choose>
    <xsl:when test="$VarStringLengthDifference &lt;= 0">
     <xsl:value-of select="''" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="substring($VarRelativeRootURIWithDummyComponent, 1, $VarStringLengthDifference)" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Preserve Unknown File Links -->
  <!--                             -->
  <wwpage:Replacement name="preserve-unknown-file-links" value="{wwprojext:GetFormatSetting('preserve-unknown-file-links')}"/>

  <wwpage:Replacement name="title" value="{$ParamSplitsPopup/@title}" />

  <wwpage:Replacement name="catalog-css">
   <xsl:attribute name="value">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarCSSPath" select="key('wwfiles-files-by-documentid', $ParamFilesDocumentNode/@documentID)[@type = $ParameterStylesType]/@path" />
     <xsl:value-of select="wwuri:GetRelativeTo($VarCSSPath, $ParamSplitsPopup/@path)" />
    </xsl:for-each>
   </xsl:attribute>
  </wwpage:Replacement>

  <wwpage:Replacement name="document-css">
   <xsl:attribute name="value">
    <xsl:call-template name="URI-ResolveProjectFileURI">
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplitsPopup/@path" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamURI" select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value" />
    </xsl:call-template>
   </xsl:attribute>
  </wwpage:Replacement>

  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
  <wwpage:Replacement name="content-type" value="{concat('text/html;charset=', wwprojext:GetFormatSetting('encoding', 'utf-8'))}" />

  <!-- Content -->
  <!--         -->
  <wwpage:Replacement name="content">
   <!-- Paragraphs -->
   <!--            -->
   <xsl:for-each select="$ParamPopupBehaviorParagraphs">
    <xsl:variable name="VarPopupBehaviorParagraph" select="." />

    <xsl:for-each select="$ParamDocument[1]">
     <xsl:variable name="VarDocumentNodes" select="key('wwdoc-elements-by-id', $VarPopupBehaviorParagraph/@id)" />

     <xsl:apply-templates select="$VarDocumentNodes" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamSplit" select="$ParamSplitsPopup" />
     </xsl:apply-templates>
    </xsl:for-each>
   </xsl:for-each>

  </wwpage:Replacement>
 </xsl:template>
</xsl:stylesheet>
