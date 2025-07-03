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
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterStylesType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterTOCDataType" />
 <xsl:param name="ParameterThumbnailType" />
 <xsl:param name="ParameterAllowBaggage" />
 <xsl:param name="ParameterAllowGroupToGroup" />
 <xsl:param name="ParameterAllowURL" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterProjectSplitsType" />


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
 <xsl:include href="wwtransform:common/images/wrappers.xsl" />
 <xsl:include href="wwtransform:common/links/resolve.xsl" />
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:common/tables/tables.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/content.xsl" />


 <xsl:key name="wwdoc-frames-by-id" match="wwdoc:Frame" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/wrappers.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/wrappers.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/links/resolve.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/links/resolve.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/tables/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/tables/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/content.xsl')))" />
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


 <!-- Mapping Entry Sets -->
 <!--                    -->
 <xsl:variable name="GlobalMapEntrySetsPath" select="wwuri:AsFilePath('wwtransform:html/mapentrysets.xml')" />
 <xsl:variable name="GlobalMapEntrySets" select="wwexsldoc:LoadXMLWithoutResolver($GlobalMapEntrySetsPath)" />


 <!-- Page Template -->
 <!--               -->
 <xsl:variable name="GlobalPageTemplatePath" select="wwuri:AsFilePath($ParameterPageTemplateURI)" />
 <xsl:variable name="GlobalPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPageTemplatePath)" />


 <!-- Page template include files -->
 <!--                             -->
 <xsl:variable name="GlobalPageTemplateIncludeFilesAsXML">
  <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:pagetemplate-include-files">
   <xsl:with-param name="ParamPageTemplateURI" select="$ParameterPageTemplateURI" />
  </xsl:apply-templates>
 </xsl:variable>
 <xsl:variable name="GlobalPageTemplateIncludeFiles" select="msxsl:node-set($GlobalPageTemplateIncludeFilesAsXML)" />


 <!-- Project Splits -->
 <!--                -->
 <xsl:variable name="GlobalProjectSplitsPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectSplitsType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectSplits" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectSplitsPath)" />


 <!-- Project variables -->
 <!--                   -->
 <xsl:variable name="GlobalProjectVariablesPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectVariablesType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectVariables" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectVariablesPath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:call-template name="Wrappers">
    <xsl:with-param name="ParamInput" select="$GlobalInput" />
    <xsl:with-param name="ParamProject" select="$GlobalProject" />
    <xsl:with-param name="ParamFiles" select="$GlobalFiles" />
    <xsl:with-param name="ParamLinksType" select="$ParameterLinksType" />
    <xsl:with-param name="ParamDependsType" select="$ParameterDependsType" />
    <xsl:with-param name="ParamSplitsType" select="$ParameterSplitsType" />
    <xsl:with-param name="ParamBehaviorsType" select="$ParameterBehaviorsType" />
    <xsl:with-param name="ParamTOCDataType" select="$ParameterTOCDataType" />
    <xsl:with-param name="ParamThumbnailType" select="$ParameterThumbnailType" />
   </xsl:call-template>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Wrapper">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamDocument" />

  <!-- Output -->
  <!--        -->
  <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($ParamSplitsFrame/wwsplits:Wrapper/@path, $GlobalProject/wwproject:Project/@ChangeID, $ParamSplitsFrame/wwsplits:Wrapper/@groupID, $ParamSplitsFrame/wwsplits:Wrapper/@documentID, $GlobalActionChecksum)" />
  <xsl:if test="not($VarUpToDate)">
   <xsl:variable name="VarResultAsXML">
    <!-- Get document frame -->
    <!--                    -->
    <xsl:for-each select="$ParamDocument[1]">
     <xsl:variable name="VarFrame" select="key('wwdoc-frames-by-id', $ParamSplitsFrame/@id)" />

     <!-- Output directory path -->
     <!--                       -->
     <xsl:variable name="VarReplacedGroupName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplitsFrame/wwsplits:Wrapper/@groupID)" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

     <!-- Page Rule -->
     <!--           -->
     <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $ParamSplitsFrame/wwsplits:Wrapper/@stylename)" />

     <!-- Breadcrumbs -->
     <!--             -->
     <xsl:variable name="VarBreadcrumbsAsXML">
      <xsl:variable name="VarBreadcrumbsGenerateOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'breadcrumbs-generate']/@Value" />
      <xsl:if test="($VarBreadcrumbsGenerateOption = 'true') or (string-length($VarBreadcrumbsGenerateOption) = 0)">
       <xsl:call-template name="Breadcrumbs">
        <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
        <xsl:with-param name="ParamSplit" select="$ParamSplitsFrame" />
        <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
       </xsl:call-template>
      </xsl:if>
     </xsl:variable>
     <xsl:variable name="VarBreadcrumbs" select="msxsl:node-set($VarBreadcrumbsAsXML)" />

     <!-- Split files -->
     <!--             -->
     <xsl:for-each select="$ParamSplits[1]">
      <!-- Cargo -->
      <!--       -->
      <xsl:variable name="VarCargo" select="$ParamBehaviors" />

      <!-- Conditions -->
      <!--            -->
      <xsl:variable name="VarInitialConditionsAsXML">
       <!-- wrapper -->
       <!--         -->
       <wwpage:Condition name="wrapper" />

       <!-- catalog-css -->
       <!--             -->
       <wwpage:Condition name="catalog-css" />

       <!-- document-css -->
       <!--              -->
       <xsl:if test="string-length($VarPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value) &gt; 0">
        <wwpage:Condition name="document-css" />
       </xsl:if>

       <!-- breadcrumbs-exist -->
       <!--                   -->
       <xsl:if test="string-length($VarBreadcrumbsAsXML) &gt; 0">
        <wwpage:Condition name="breadcrumbs-exist" />
       </xsl:if>

       <!-- button-print -->
       <!--              -->
       <xsl:if test="wwprojext:GetFormatSetting('button-print') = 'true'">
        <wwpage:Condition name="print-enabled" />
       </xsl:if>

       <!-- feedback-email -->
       <!--              -->
       <xsl:if test="string-length(wwprojext:GetFormatSetting('feedback-email')) &gt; 0">
        <wwpage:Condition name="feedback-email" />
       </xsl:if>

       <!-- navigation-previous-exists -->
       <!--                            -->
       <wwpage:Condition name="navigation-previous-exists" />

       <!-- navigation-next-exists -->
       <!--                        -->
       <wwpage:Condition name="navigation-next-exists" />

       <!-- Company Info -->
       <!--              -->
       <xsl:call-template name="CompanyInfo-Conditions">
        <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarInitialConditions" select="msxsl:node-set($VarInitialConditionsAsXML)" />

      <!-- Set header/footer conditions -->
      <!--                              -->
      <xsl:variable name="VarConditionsAsXML">
       <!-- Copy existing as is -->
       <!--                     -->
       <xsl:for-each select="$VarInitialConditions/*">
        <xsl:copy-of select="." />
       </xsl:for-each>

       <xsl:for-each select="$VarInitialConditions[1]">
        <!-- No new conditions to report -->
        <!--                             -->
       </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

      <!-- Replacements -->
      <!--              -->
      <xsl:variable name="VarReplacementsAsXML">
       <xsl:variable name="VarRelativeRootURIWithDummyComponent" select="wwuri:GetRelativeTo(wwfilesystem:Combine($VarOutputDirectoryPath, 'dummy.component'), $ParamSplitsFrame/wwsplits:Wrapper/@path)" />
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

       <!-- body-style -->
       <!--            -->
       <wwpage:Replacement name="body-style">
        <xsl:attribute name="value">
         <!-- CSS properties -->
         <!--                -->
         <xsl:variable name="VarCSSPropertiesAsXML">
          <xsl:call-template name="CSS-TranslateProjectProperties">
           <xsl:with-param name="ParamProperties" select="$VarPageRule/wwproject:Properties/wwproject:Property" />
           <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplitsFrame/wwsplits:Wrapper/@path" />
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

         <xsl:call-template name="CSS-InlineProperties">
          <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
         </xsl:call-template>
        </xsl:attribute>
       </wwpage:Replacement>

       <wwpage:Replacement name="title" value="{$ParamSplitsFrame/wwsplits:Wrapper/@title}" />
       <wwpage:Replacement name="navigation-previous-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Previous']/@value}" />
       <wwpage:Replacement name="navigation-next-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Next']/@value}" />
       <wwpage:Replacement name="navigation-pdf-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PDF']/@value}" />
       <wwpage:Replacement name="navigation-print-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PrintLabel']/@value}" />
       <wwpage:Replacement name="navigation-email-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'EmailLabel']/@value}" />
       <wwpage:Replacement name="navigation-toc-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTabLabel']/@value}" />
       <wwpage:Replacement name="navigation-index-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTabLabel']/@value}" />
       <wwpage:Replacement name="navigation-search-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTabLabel']/@value}" />

       <!-- No-JavaScript -->
       <!--               -->
       <wwpage:Replacement name="locales-no-javascript-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoJavaScriptMessage']/@value}" />

       <wwpage:Replacement name="catalog-css">
        <xsl:attribute name="value">
         <xsl:for-each select="$GlobalFiles[1]">
          <xsl:variable name="VarCSSPath" select="key('wwfiles-files-by-documentid', $ParamFilesDocumentNode/@documentID)[@type = $ParameterStylesType]/@path" />
          <xsl:value-of select="wwuri:GetRelativeTo($VarCSSPath, $ParamSplitsFrame/wwsplits:Wrapper/@path)" />
         </xsl:for-each>
        </xsl:attribute>
       </wwpage:Replacement>

       <wwpage:Replacement name="document-css">
        <xsl:attribute name="value">
         <xsl:call-template name="URI-ResolveProjectFileURI">
          <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplitsFrame/wwsplits:Wrapper/@path" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamURI" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value" />
         </xsl:call-template>
        </xsl:attribute>
       </wwpage:Replacement>

       <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
       <wwpage:Replacement name="content-type" value="text/html;charset=utf-8" />

       <xsl:variable name="VarAnchor">
        <xsl:variable name="VarParagraph" select="$VarFrame/ancestor::wwdoc:Paragraph[1]" />
        <xsl:choose>
         <xsl:when test="count($VarParagraph) = 1">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$VarFrame/ancestor::wwdoc:Paragraph[1]/@id" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="''" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>
       <wwpage:Replacement name="navigation-previous-link" value="{concat(wwuri:GetRelativeTo($ParamSplitsFrame/../@path, $ParamSplitsFrame/wwsplits:Wrapper/@path), $VarAnchor)}" />
       <wwpage:Replacement name="navigation-next-link" value="{concat(wwuri:GetRelativeTo($ParamSplitsFrame/../@path, $ParamSplitsFrame/wwsplits:Wrapper/@path), $VarAnchor)}" />

       <!-- Company Info -->
       <!--              -->
       <xsl:call-template name="CompanyInfo-Replacements">
        <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
        <xsl:with-param name="ParamPagePath" select="$ParamSplitsFrame/wwsplits:Wrapper/@path" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       </xsl:call-template>

       <!-- Breadcrumbs -->
       <!--             -->
       <wwpage:Replacement name="breadcrumbs">
        <xsl:copy-of select="$VarBreadcrumbs" />
       </wwpage:Replacement>

       <!-- Content -->
       <!--         -->
       <wwpage:Replacement name="content">
        <xsl:call-template name="Frame-Markup">
         <xsl:with-param name="ParamFrame" select="$VarFrame" />
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$VarCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplitsFrame/wwsplits:Wrapper" />
         <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
         <xsl:with-param name="ParamThumbnail" select="false()" />
        </xsl:call-template>
       </wwpage:Replacement>

       <!-- Variables -->
       <!--           -->
       <xsl:variable name="VarSplitGlobalVariablesAsXML">
        <xsl:call-template name="Variables-Globals-Split">
         <xsl:with-param name="ParamProjectVariables" select="$GlobalProjectVariables" />
         <xsl:with-param name="ParamSplit" select="$ParamSplitsFrame/ancestor::wwsplits:Split[1]" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarSplitGlobalVariables" select="msxsl:node-set($VarSplitGlobalVariablesAsXML)/wwvars:Variable" />
       <xsl:call-template name="Variables-Page-String-Replacements">
        <xsl:with-param name="ParamVariables" select="$VarSplitGlobalVariables" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

      <!-- Map common characters -->
      <!--                       -->
      <wwexsldoc:MappingContext>
       <xsl:copy-of select="$GlobalMapEntrySets/wwexsldoc:MapEntrySets/wwexsldoc:MapEntrySet[@name = 'common']/wwexsldoc:MapEntry" />

       <!-- Invoke page template -->
       <!--                      -->
       <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:pagetemplate">
        <xsl:with-param name="ParamPageTemplateURI" select="$ParameterPageTemplateURI" />
        <xsl:with-param name="ParamOutputDirectoryPath" select="$VarOutputDirectoryPath" />
        <xsl:with-param name="ParamOutputPath" select="$ParamSplitsFrame/wwsplits:Wrapper/@path" />
        <xsl:with-param name="ParamConditions" select="$VarConditions" />
        <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
       </xsl:apply-templates>
      </wwexsldoc:MappingContext>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:variable>

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
    <xsl:variable name="VarPrettyPrint">
     <xsl:choose>
      <xsl:when test="wwprojext:GetFormatSetting('file-processing-pretty-print') = 'true'">
       <xsl:text>yes</xsl:text>
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>no</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $ParamSplitsFrame/wwsplits:Wrapper/@path, 'utf-8', 'xhtml', '5.0', $VarPrettyPrint, 'yes', 'no', 'urn:WebWorks_DOCTYPE_ElementOnly', '')" />
   </xsl:if>
  </xsl:if>

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Record files -->
   <!--              -->
   <wwfiles:File path="{$ParamSplitsFrame/wwsplits:Wrapper/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplitsFrame/wwsplits:Wrapper/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplitsFrame/wwsplits:Wrapper/@groupID}" documentID="{$ParamSplitsFrame/wwsplits:Wrapper/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <wwfiles:Depends path="{$GlobalLocalePath}" checksum="{wwfilesystem:GetChecksum($GlobalLocalePath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalMapEntrySetsPath}" checksum="{wwfilesystem:GetChecksum($GlobalMapEntrySetsPath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPageTemplatePath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalProjectVariablesPath}" checksum="{wwfilesystem:GetChecksum($GlobalProjectVariablesPath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$ParamFilesDocumentNode/@path}" checksum="{$ParamFilesDocumentNode/@checksum}" groupID="{$ParamFilesDocumentNode/@groupID}" documentID="{$ParamFilesDocumentNode/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />

    <!-- Page Template Include Files -->
    <!--                             -->
    <xsl:for-each select="$GlobalPageTemplateIncludeFiles">
     <xsl:variable name="VarFile" select="." />

     <wwfiles:Depends path="{$VarFile/@path}" checksum="{wwfilesystem:GetChecksum($VarFile/@path)}" groupID="" documentID="" />
    </xsl:for-each>
   </wwfiles:File>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
