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
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc wwdatetime"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSegmentsType" select="''" />
 <xsl:param name="ParameterSplitsType" />
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
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterDocumentPDFType" />
 <xsl:param name="ParameterGroupPDFType" />
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
 <xsl:include href="wwtransform:common/links/resolve.xsl" />
 <xsl:include href="wwtransform:common/pages/pages.xsl" />
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:common/tables/tables.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/content.xsl" />

 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />


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
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pages.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pages.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/tables/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/tables/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
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

 <!-- Project Splits -->
 <!--                -->
 <xsl:variable name="GlobalProjectSplitsPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectSplitsType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectSplits" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectSplitsPath)" />

 <!-- Connect Pages -->
 <!--               -->
 <xsl:variable name="GlobalEntryPagePath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwprojext:GetFormatSetting('connect-entry'))" />
 <xsl:variable name="GlobalSearchPagePath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'connect', 'search.html')" />


 <!-- PDF Settings -->
 <!--              -->
 <xsl:variable name="GlobalForceDownloadPDF" select="wwprojext:GetFormatSetting('pdf-force-download', 'false')='true'"/>

 <!-- PDF Project-wide path -->
 <!--                       -->
 <xsl:variable name="GlobalProjectPDFPath">
  <!-- Determine PDF target dependency -->
  <!--                                 -->
  <xsl:variable name="VarCopyPDFsFromTargetID" select="wwprojext:GetFormatSetting('pdf-target-dependency')" />

  <xsl:if test="string-length($VarCopyPDFsFromTargetID) &gt; 0">
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', $VarCopyPDFsFromTargetID)[1]" />
    <xsl:variable name="VarGenerateProjectResult" select="count($VarFormatConfiguration//wwproject:FormatSetting[(@Name = 'generate-project-result') and (@Value = 'true')][1]) = 1" />

    <xsl:if test="$VarGenerateProjectResult">
     <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />
     <xsl:variable name="VarProjectTitle">
      <xsl:choose>
       <xsl:when test="string-length($VarMergeSettings/@Title) &gt; 0">
        <xsl:value-of select="$VarMergeSettings/@Title" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$GlobalProject[1]/wwproject:Project/wwproject:Formats/wwproject:Format[@TargetID = $VarCopyPDFsFromTargetID][1]/@TargetName" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <xsl:variable name="VarReplacedProjectName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarProjectTitle" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), concat($VarReplacedProjectName, '.pdf'))" />
    </xsl:if>
   </xsl:for-each>
  </xsl:if>
 </xsl:variable>

 
 <xsl:variable name="GlobalSingleQuote">
  <xsl:text>'</xsl:text>
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:call-template name="DocumentsPages">
    <xsl:with-param name="ParamInput" select="$GlobalInput" />
    <xsl:with-param name="ParamProject" select="$GlobalProject" />
    <xsl:with-param name="ParamFiles" select="$GlobalFiles" />
    <xsl:with-param name="ParamLinksType" select="$ParameterLinksType" />
    <xsl:with-param name="ParamDependsType" select="$ParameterDependsType" />
    <xsl:with-param name="ParamSegmentsType" select="$ParameterSegmentsType" />
    <xsl:with-param name="ParamSplitsType" select="$ParameterSplitsType" />
    <xsl:with-param name="ParamBehaviorsType" select="$ParameterBehaviorsType" />
    <xsl:with-param name="ParamTOCDataType" select="$ParameterTOCDataType" />
   </xsl:call-template>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Page">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamContent" />

  <!-- Output directory path -->
  <!--                       -->
  <xsl:variable name="VarReplacedGroupName">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplit/@groupID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

  <!-- Page Rule -->
  <!--           -->
  <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $ParamSplit/@stylename)" />

  <!-- Behaviors for this split -->
  <!--                          -->
  <xsl:variable name="VarSplitBehaviors" select="$ParamBehaviors/wwbehaviors:Behaviors/wwbehaviors:Split[@id = $ParamSplit/@id]" />

  <!-- Split files -->
  <!--             -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarFileChildrenAsXML">
    <xsl:variable name="VarConditionsAsXML">
     <xsl:call-template name="PageTemplate-Conditions">
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
      <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
      <xsl:with-param name="ParamFilesDocumentNode" select="$ParamFilesDocumentNode" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamContent" select="$ParamContent" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

    <xsl:variable name="VarReplacementsAsXML">
     <xsl:call-template name="PageTemplate-Replacements">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
      <xsl:with-param name="ParamFilesDocumentNode" select="$ParamFilesDocumentNode" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamContent" select="$ParamContent" />
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

   <wwfiles:File path="{$ParamSplit/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplit/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplit/@groupID}" documentID="{$ParamSplit/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <xsl:copy-of select="$VarFileChildren" />
    <wwfiles:Depends path="{$ParamFilesDocumentNode/@path}" checksum="{$ParamFilesDocumentNode/@checksum}" groupID="{$ParamFilesDocumentNode/@groupID}" documentID="{$ParamFilesDocumentNode/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
   </wwfiles:File>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamContent" />

  <!-- Page Rule -->
  <!--           -->
  <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $ParamSplit/@stylename)" />

  <!-- Behaviors for this split -->
  <!--                          -->
  <xsl:variable name="VarSplitBehaviors" select="$ParamBehaviors/wwbehaviors:Behaviors/wwbehaviors:Split[@id = $ParamSplit/@id]" />

  <!-- Keywords Markers -->
  <!--                  -->
  <xsl:variable name="VarKeywordsMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'keywords']" />

  <!-- Description Markers -->
  <!--                     -->
  <xsl:variable name="VarDescriptionMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'description']" />

  <!-- Breadcrumbs -->
  <!--             -->
  <xsl:variable name="VarBreadcrumbsAsXML">
   <xsl:variable name="VarBreadcrumbsGenerateOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'breadcrumbs-generate']/@Value" />
   <xsl:if test="($VarBreadcrumbsGenerateOption = 'true') or (string-length($VarBreadcrumbsGenerateOption) = 0)">
    <xsl:call-template name="Breadcrumbs">
     <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarBreadcrumbs" select="msxsl:node-set($VarBreadcrumbsAsXML)" />

  <!-- Previous -->
  <!--          -->
  <xsl:variable name="VarPreviousSplit" select="$ParamSplit/preceding-sibling::wwsplits:Split[1]" />

  <!-- Next -->
  <!--      -->
  <xsl:variable name="VarNextSplit" select="$ParamSplit/following-sibling::wwsplits:Split[1]" />

  <!-- Skip Navigation Link -->
  <!--                      -->
  <xsl:variable name="VarSkipNavigationURI">
   <xsl:if test="wwprojext:GetFormatSetting('accessibility-skip-navigation-link', 'false') = 'true'">
    <xsl:text>#ww</xsl:text>
    <xsl:value-of select="$ParamSplit/@id" />
   </xsl:if>
  </xsl:variable>

  <!-- PDF Link -->
  <!--          -->
  <xsl:variable name="VarPDFLinkPath">
   <xsl:variable name="VarDocumentPDFPath">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarDocumentPDFFile" select="key('wwfiles-files-by-documentid', $ParamFilesDocumentNode/@documentID)[@type = $ParameterDocumentPDFType]" />

     <!-- PDF per document path -->
     <!--                       -->
     <xsl:for-each select="$VarDocumentPDFFile[1]">
      <xsl:value-of select="@path" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:variable>

   <!-- PDF per group path -->
   <!--                    -->
   <xsl:variable name="VarGroupPDFPath">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarGroupPDFFile" select="key('wwfiles-files-by-type', $ParameterGroupPDFType)[@groupID = $ParamSplit/@groupID]" />

     <xsl:for-each select="$VarGroupPDFFile[1]">
      <xsl:value-of select="@path" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="string-length($VarDocumentPDFPath) &gt; 0">
     <xsl:value-of select="$VarDocumentPDFPath" />
    </xsl:when>

    <xsl:when test="string-length($VarGroupPDFPath) &gt; 0">
     <xsl:value-of select="$VarGroupPDFPath" />
    </xsl:when>

    <xsl:when test="string-length($GlobalProjectPDFPath) &gt; 0">
     <xsl:value-of select="$GlobalProjectPDFPath" />
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarPDFLinkURI">
   <xsl:if test="string-length($VarPDFLinkPath) &gt; 0">
    <xsl:value-of select="wwuri:GetRelativeTo($VarPDFLinkPath, $ParamSplit/@path)" />
   </xsl:if>
  </xsl:variable>

  <!-- Markers -->
  <!--         -->
  <xsl:variable name="VarMarkers" select="$ParamContent//wwdoc:Marker"/>

  <!-- Conditions -->

  <xsl:variable name="VarInitialConditionsAsXML">
   <!-- Markers by name -->
   <!--                 -->
   <xsl:for-each select="$VarMarkers">
    <wwpage:Condition name="wwmarker:{./@name}" />
   </xsl:for-each>

   <!-- Mark of the Web (MOTW) -->
   <!--                        -->
   <xsl:if test="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'">
    <wwpage:Condition name="emit-mark-of-the-web" />
   </xsl:if>

   <!-- catalog-css -->
   <!--             -->
   <wwpage:Condition name="catalog-css" />

   <!-- document-css -->
   <!--              -->
   <xsl:if test="string-length($VarPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value) &gt; 0">
    <wwpage:Condition name="document-css" />
   </xsl:if>

   <!-- skip-navigation -->
   <!--                 -->
   <xsl:if test="string-length($VarSkipNavigationURI) &gt; 0">
    <wwpage:Condition name="skip-navigation" />
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

   <!-- pdf-exists -->
   <!--            -->
   <xsl:if test="string-length($VarPDFLinkURI) &gt; 0">
    <wwpage:Condition name="pdf-exists" />
   </xsl:if>
   <xsl:if test="string-length($VarPDFLinkURI) = 0">
    <wwpage:Condition name="pdf-not-exists" />
   </xsl:if>

   <!-- pdf-download -->
   <!--              -->
   <xsl:if test="$GlobalForceDownloadPDF">
    <wwpage:Condition name="pdf-download-exists" />
   </xsl:if>
   <xsl:if test="not($GlobalForceDownloadPDF)">
    <wwpage:Condition name="pdf-download-not-exists" />
   </xsl:if>

   <!-- page-dropdown-toggle -->
   <!--              -->
   <xsl:if test="wwprojext:GetFormatSetting('page-dropdown-toggle') = 'true'">
    <wwpage:Condition name="page-dropdown-toggle-enabled" />
   </xsl:if>

   <!-- breadcrumbs-exist -->
   <!--                   -->
   <xsl:if test="string-length($VarBreadcrumbsAsXML) &gt; 0">
    <wwpage:Condition name="breadcrumbs-exist" />
   </xsl:if>

   <!-- navigation-previous-exists -->
   <!--                            -->
   <xsl:if test="count($VarPreviousSplit) = 1">
    <wwpage:Condition name="navigation-previous-exists" />
   </xsl:if>

   <!-- navigation-next-exists -->
   <!--                        -->
   <xsl:if test="count($VarNextSplit) = 1">
    <wwpage:Condition name="navigation-next-exists" />
   </xsl:if>

   <!-- TOC -->
   <!--     -->
   <xsl:if test="wwprojext:GetFormatSetting('toc-generate') = 'true'">
    <wwpage:Condition name="toc-enabled" />
   </xsl:if>

   <!-- Helpful -->
   <!--         -->
   <xsl:if test="wwprojext:GetFormatSetting('page-helpful-buttons') = 'true'">
    <wwpage:Condition name="page-helpful-buttons-enabled" />
   </xsl:if>

   <!-- Index -->
   <!--       -->
   <xsl:if test="wwprojext:GetFormatSetting('index-generate') = 'true'">
    <wwpage:Condition name="index-enabled" />
   </xsl:if>

   <!-- Google Translation -->
   <!--                    -->
   <xsl:if test="wwprojext:GetFormatSetting('google-translate') = 'true'">
    <wwpage:Condition name="globe" />
    <wwpage:Condition name="google-translation-enabled" />
   </xsl:if>

   <!-- Twitter -->
   <!--         -->
   <xsl:if test="wwprojext:GetFormatSetting('social-twitter') = 'true'">
    <wwpage:Condition name="twitter-enabled" />
   </xsl:if>

   <!-- FaceBook -->
   <!--          -->
   <xsl:if test="wwprojext:GetFormatSetting('social-facebook-like') = 'true'">
    <wwpage:Condition name="facebook-like-enabled" />
   </xsl:if>

   <!-- LinkedIn -->
   <!--          -->
   <xsl:if test="wwprojext:GetFormatSetting('social-linkedin') = 'true'">
    <wwpage:Condition name="linkedin-share-enabled" />
   </xsl:if>

   <!-- Disqus -->
   <!--        -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('social-disqus-id')) &gt; 0">
    <wwpage:Condition name="disqus-enabled" />
   </xsl:if>
   <xsl:if test="wwprojext:GetFormatSetting('social-disqus-developer') = 'true'">
    <wwpage:Condition name="disqus-developer-enabled" />
   </xsl:if>

   <!-- Keywords? -->
   <!--           -->
   <xsl:if test="count($VarKeywordsMarkers[1]) = 1">
    <wwpage:Condition name="keywords-exist" />
   </xsl:if>

   <!-- Description? -->
   <!--              -->
   <xsl:if test="count($VarDescriptionMarkers[1]) = 1">
    <wwpage:Condition name="description-exists" />
   </xsl:if>

   <!-- Back to Top -->
   <!--             -->
   <xsl:if test="wwprojext:GetFormatSetting('file-processing-back-to-top-link') = 'true'">
    <wwpage:Condition name="back-to-top-enabled" />
   </xsl:if>

   <!-- Published/Last Modified Date -->
   <!--                              -->
   <xsl:if test="wwprojext:GetFormatSetting('page-publish-date') = 'true'">
    <wwpage:Condition name="display-page-publish-date" />
   </xsl:if>
   <xsl:if test="wwprojext:GetFormatSetting('document-last-modified-date') = 'true'">
    <wwpage:Condition name="display-document-last-modified-date" />
   </xsl:if>


   <!-- Company Info -->
   <!--              -->
   <xsl:call-template name="CompanyInfo-Conditions">
    <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarInitialConditions" select="msxsl:node-set($VarInitialConditionsAsXML)" />

  <!-- Copy existing as is -->
  <!--                     -->
  <xsl:for-each select="$VarInitialConditions/*">
   <xsl:copy-of select="." />
  </xsl:for-each>

  <xsl:for-each select="$VarInitialConditions[1]">
   <!-- social-enabled -->
   <!--                -->
   <xsl:if test="count(key('wwpage-conditions-by-name', 'facebook-like-enabled') | key('wwpage-conditions-by-name', 'twitter-enabled')) &gt; 0">
    <wwpage:Condition name="social-enabled" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="PageTemplate-Replacements">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamContent" />

  <!-- Page Rule -->
  <!--           -->
  <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $ParamSplit/@stylename)" />

  <!-- Behaviors for this split -->
  <!--                          -->
  <xsl:variable name="VarSplitBehaviors" select="$ParamBehaviors/wwbehaviors:Behaviors/wwbehaviors:Split[@id = $ParamSplit/@id]" />

  <!-- Keywords Markers -->
  <!--                  -->
  <xsl:variable name="VarKeywordsMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'keywords']" />

  <!-- Split Drop Downs -->
  <!--                  -->
  <xsl:variable name="VarSplitDropDownParagraphBehaviors" select="$VarSplitBehaviors//wwbehaviors:Paragraph[(@dropdown = 'start-open') or (@dropdown = 'start-closed')]" />

  <!-- Description Markers -->
  <!--                     -->
  <xsl:variable name="VarDescriptionMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'description']" />

  <!-- Breadcrumbs -->
  <!--             -->
  <xsl:variable name="VarBreadcrumbsAsXML">
   <xsl:variable name="VarBreadcrumbsGenerateOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'breadcrumbs-generate']/@Value" />
   <xsl:if test="($VarBreadcrumbsGenerateOption = 'true') or (string-length($VarBreadcrumbsGenerateOption) = 0)">
    <xsl:call-template name="Breadcrumbs">
     <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarBreadcrumbs" select="msxsl:node-set($VarBreadcrumbsAsXML)" />

  <!-- Previous -->
  <!--          -->
  <xsl:variable name="VarPreviousSplit" select="$ParamSplit/preceding-sibling::wwsplits:Split[1]" />

  <!-- Next -->
  <!--      -->
  <xsl:variable name="VarNextSplit" select="$ParamSplit/following-sibling::wwsplits:Split[1]" />

  <!-- Skip Navigation Link -->
  <!--                      -->
  <xsl:variable name="VarSkipNavigationURI">
   <xsl:if test="wwprojext:GetFormatSetting('accessibility-skip-navigation-link', 'false') = 'true'">
    <xsl:text>#ww</xsl:text>
    <xsl:value-of select="$ParamSplit/@id" />
   </xsl:if>
  </xsl:variable>

  <!-- PDF Link -->
  <!--          -->
  <xsl:variable name="VarPDFLinkPath">
   <xsl:variable name="VarDocumentPDFPath">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarDocumentPDFFile" select="key('wwfiles-files-by-documentid', $ParamFilesDocumentNode/@documentID)[@type = $ParameterDocumentPDFType]" />

     <xsl:for-each select="$VarDocumentPDFFile[1]">
      <xsl:value-of select="@path" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:variable>

   <xsl:variable name="VarGroupPDFPath">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarGroupPDFFile" select="key('wwfiles-files-by-type', $ParameterGroupPDFType)[@groupID = $ParamSplit/@groupID]" />

     <xsl:for-each select="$VarGroupPDFFile[1]">
      <xsl:value-of select="@path" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="string-length($VarDocumentPDFPath) &gt; 0">
     <xsl:value-of select="$VarDocumentPDFPath" />
    </xsl:when>

    <xsl:when test="string-length($VarGroupPDFPath) &gt; 0">
     <xsl:value-of select="$VarGroupPDFPath" />
    </xsl:when>

    <xsl:when test="string-length($GlobalProjectPDFPath) &gt; 0">
     <xsl:value-of select="$GlobalProjectPDFPath" />
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarPDFLinkURI">
   <xsl:if test="string-length($VarPDFLinkPath) &gt; 0">
    <xsl:value-of select="wwuri:GetRelativeTo($VarPDFLinkPath, $ParamSplit/@path)" />
   </xsl:if>
  </xsl:variable>

  <!-- Markers -->
  <!--         -->
  <xsl:variable name="VarMarkers" select="$ParamContent//wwdoc:Marker"/>

  <!-- Notes -->
  <!--       -->
  <xsl:variable name="VarNotes" select="$ParamContent//wwdoc:Note[not(ancestor::wwdoc:Table) and not(ancestor::wwdoc:Frame)]" />

  <!-- Note numbering -->
  <!--                -->
  <xsl:variable name="VarNoteNumberingAsXML">
   <xsl:call-template name="Notes-Number">
    <xsl:with-param name="ParamNotes" select="$VarNotes" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

  <!-- Cargo -->
  <!--       -->
  <xsl:variable name="VarCargo" select="$ParamBehaviors | $VarNoteNumbering" />

  <!-- Replacements -->

  <!-- Markers by name with value -->
  <!--                            -->
  <xsl:for-each select="$VarMarkers">
   <xsl:variable name="VarMarkerText">
    <xsl:for-each select=".//wwdoc:Text">
     <xsl:value-of select="@value" />
    </xsl:for-each>
   </xsl:variable>
   <wwpage:Replacement name="wwmarker:{./@name}" value="{$VarMarkerText}" />
  </xsl:for-each>

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

  <!-- redirect -->
  <!--          -->
  <xsl:variable name="VarRedirectToEntryURL">
   <xsl:call-template name="Connect-URI-GetRelativeTo">
    <xsl:with-param name="ParamDestinationURI" select="$GlobalEntryPagePath" />
    <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
   </xsl:call-template>
   <xsl:text>#page/</xsl:text>
   <xsl:value-of select="wwuri:GetRelativeTo($ParamSplit/@path, $GlobalEntryPagePath)" />
  </xsl:variable>

  <!-- page-onload-url -->
  <!--             -->
  <wwpage:Replacement name="page-onload-url">
   <xsl:value-of select="wwstring:Replace($VarRedirectToEntryURL, $GlobalSingleQuote, '%27')" />
  </wwpage:Replacement>

  <!-- body-id -->
  <!--         -->
  <xsl:variable name="VarPageIDComponents">
   <xsl:value-of select="$ParamSplit/@groupID" />
   <xsl:text>:</xsl:text>
   <xsl:value-of select="$ParamSplit/@documentID" />
   <xsl:text>:</xsl:text>
   <xsl:value-of select="wwfilesystem:GetRelativeTo($ParamSplit/@path, wwprojext:GetTargetOutputDirectoryPath())" />
  </xsl:variable>
  <xsl:variable name="VarPageID" select="wwstring:NCNAME(translate(wwstring:MD5Checksum($VarPageIDComponents), '=', ''))" />
  <wwpage:Replacement name="body-id" value="p{$VarPageID}" />

  <!-- dropdown-ids -->
  <!--               -->
  <wwpage:Replacement name="dropdown-ids">
   <xsl:variable name="VarDropDownIdsString">
    <xsl:for-each select="$VarSplitDropDownParagraphBehaviors">
     <xsl:variable name="VarParagraphBehavior" select="."/>
     <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
     </xsl:if>
     <xsl:text>ww</xsl:text>
     <xsl:value-of select="$VarParagraphBehavior/@id"/>
    </xsl:for-each>
   </xsl:variable>

   <xsl:value-of select="$VarDropDownIdsString"/>
  </wwpage:Replacement>

  <!-- body-class -->
  <!--            -->
  <wwpage:Replacement name="body-class">
   <xsl:attribute name="value">
    <!-- Skin class -->
    <!--            -->
    <xsl:text>ww_skin_page_body</xsl:text>

    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($VarPageRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
     <xsl:text> </xsl:text>
     <xsl:value-of select="$VarAdditionalCSSClassesOption" />
    </xsl:if>
   </xsl:attribute>
  </wwpage:Replacement>

  <!-- body-style -->
  <!--            -->
  <wwpage:Replacement name="body-style">
   <xsl:attribute name="value">
    <!-- CSS properties -->
    <!--                -->
    <xsl:variable name="VarCSSPropertiesAsXML">
     <xsl:call-template name="CSS-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarPageRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:attribute>
  </wwpage:Replacement>

  <!-- Preserve Unknown File Links -->
  <!--                             -->
  <wwpage:Replacement name="preserve-unknown-file-links" value="{wwprojext:GetFormatSetting('preserve-unknown-file-links')}"/>

  <xsl:if test="string-length($VarPDFLinkURI) &gt; 0">
   <wwpage:Replacement name="pdf-link" value="{$VarPDFLinkURI}" />
   <wwpage:Replacement name="pdf-download" value="{wwfilesystem:GetBaseName($VarPDFLinkPath)}" />
  </xsl:if>

  <wwpage:Replacement name="pdf-target" value="{wwprojext:GetFormatSetting('pdf-target')}" />

  <wwpage:Replacement name="skip-navigation-uri" value="{$VarSkipNavigationURI}" />

  <xsl:variable name="VarBrowserTabTitleSetting" select="wwprojext:GetFormatSetting('connect-browser-tab-title')" />
  <xsl:variable name="VarBrowserTabTitle">
   <xsl:choose>

    <xsl:when test="$VarBrowserTabTitleSetting = 'merge-title'">
     <xsl:variable name="VarFormatConfiguration" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID=wwprojext:GetFormatID()]" />
     <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

     <xsl:choose>

      <!-- Use Merge Title for all Page Browser Tab Titles -->
      <!--                                                 -->
      <xsl:when test="string-length($VarMergeSettings/@Title) &gt; 0">
       <xsl:value-of select="$VarMergeSettings/@Title" />
      </xsl:when>

      <!-- Use Format Name since no Merge Title has been configured -->
      <!--                                                          -->
      <xsl:otherwise>
       <xsl:value-of select="wwprojext:GetFormatName()" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Use Page Title for each Page Browser Tab Title -->
    <!--                                                -->
    <xsl:otherwise>
     <xsl:value-of select="$ParamSplit/@title" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="title" value="{$VarBrowserTabTitle}" />

  <wwpage:Replacement name="navigation-previous-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Previous']/@value}" />
  <wwpage:Replacement name="navigation-next-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Next']/@value}" />
  <wwpage:Replacement name="navigation-pdf-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PDF']/@value}" />
  <wwpage:Replacement name="navigation-print-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PrintLabel']/@value}" />
  <wwpage:Replacement name="navigation-email-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'EmailLabel']/@value}" />
  <wwpage:Replacement name="navigation-toc-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTabLabel']/@value}" />
  <wwpage:Replacement name="navigation-index-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTabLabel']/@value}" />
  <wwpage:Replacement name="navigation-search-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTabLabel']/@value}" />
  <wwpage:Replacement name="back-to-top-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BackToTopTitle']/@value}" />
  <wwpage:Replacement name="navigation-page-dropdown-toggle-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PageDropDownToggleLabel']/@value}" />
  <wwpage:Replacement name="helpful-button" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'HelpfulButton']/@value}" />
  <wwpage:Replacement name="unhelpful-button" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnhelpfulButton']/@value}" />

  <!-- Helpful Message -->
  <!--                 -->
  <wwpage:Replacement name="locales-helpful-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PageHelpfulMessage']/@value}" />

  <!-- No-JavaScript -->
  <!--               -->
  <wwpage:Replacement name="locales-no-javascript-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoJavaScriptMessage']/@value}" />

  <wwpage:Replacement name="catalog-css">
   <xsl:attribute name="value">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarCSSPath" select="key('wwfiles-files-by-documentid', $ParamFilesDocumentNode/@documentID)[@type = $ParameterStylesType]/@path" />
     <xsl:value-of select="wwuri:GetRelativeTo($VarCSSPath, $ParamSplit/@path)" />
    </xsl:for-each>
   </xsl:attribute>
  </wwpage:Replacement>

  <wwpage:Replacement name="document-css">
   <xsl:attribute name="value">
    <xsl:call-template name="URI-ResolveProjectFileURI">
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamURI" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'document-css']/@Value" />
    </xsl:call-template>
   </xsl:attribute>
  </wwpage:Replacement>

  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
  <wwpage:Replacement name="content-type" value="text/html;charset=utf-8" />

  <!-- Highlight requires whitespace set to false for always highlighting part of words -->
  <!--                                                                                  -->
  <wwpage:Replacement name="highlight-require-whitespace" value="false" />

  <xsl:if test="count($VarPreviousSplit) = 1">
   <wwpage:Replacement name="navigation-previous-link" value="{wwuri:GetRelativeTo($VarPreviousSplit/@path, $ParamSplit/@path)}" />
  </xsl:if>
  <xsl:if test="count($VarNextSplit) = 1">
   <wwpage:Replacement name="navigation-next-link" value="{wwuri:GetRelativeTo($VarNextSplit/@path, $ParamSplit/@path)}" />
  </xsl:if>

  <!-- Keywords -->
  <!--          -->
  <xsl:if test="count($VarKeywordsMarkers[1]) = 1">
   <xsl:variable name="VarKeywordText">
    <xsl:for-each select="$VarKeywordsMarkers">
     <xsl:variable name="VarKeywordMarker" select="." />

     <xsl:for-each select="$VarKeywordMarker//wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>
     <xsl:if test="position() != last()">
      <xsl:value-of select="','" />
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>

   <wwpage:Replacement name="meta-keywords" value="{$VarKeywordText}" />
  </xsl:if>

  <!-- Description -->
  <!--             -->
  <xsl:if test="count($VarDescriptionMarkers[1]) = 1">
   <xsl:variable name="VarDescriptionText">
    <xsl:for-each select="$VarDescriptionMarkers">
     <xsl:variable name="VarDescriptionMarker" select="." />

     <xsl:for-each select="$VarDescriptionMarker//wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>
     <xsl:if test="position() != last()">
      <xsl:value-of select="','" />
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>

   <wwpage:Replacement name="meta-description" value="{$VarDescriptionText}" />
  </xsl:if>

  <!-- Company Info -->
  <!--              -->
  <xsl:call-template name="CompanyInfo-Replacements">
   <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
   <xsl:with-param name="ParamPagePath" select="$ParamSplit/@path" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
  </xsl:call-template>

  <!-- Last Modified Date -->
  <!--                    -->

  <xsl:variable name= "VarModifiedDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'DocumentLastModifiedDateFormat']/@value"/>
  <xsl:variable name= "VarModifiedDate" select="wwdatetime:GetFileLastModified(wwprojext:GetDocumentPath($ParamSplit/@documentID), $VarModifiedDateFormat)"/>
  <xsl:variable name= "VarModifiedDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'DocumentLastModifiedDateLabel']/@value"/>
  <xsl:variable name= "VarDocumentLastModifiedDate" select="wwstring:Format($VarModifiedDateLabel, $VarModifiedDate)"/>
  <wwpage:Replacement name="document-last-modified-date" value="{$VarDocumentLastModifiedDate}"/>

  <!-- Published Date -->
  <!--                -->

  <xsl:variable name= "VarPublishDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>
  <xsl:variable name= "VarPublishDate" select="wwdatetime:GetGenerateStart($VarPublishDateFormat)"/>
  <xsl:variable name= "VarPublishDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateLabel']/@value"/>
  <xsl:variable name= "VarFormattedPublishDate" select="wwstring:Format($VarPublishDateLabel, $VarPublishDate)"/>
  <wwpage:Replacement name="publish-date" value="{$VarFormattedPublishDate}"/>

  <!-- Created Date -->
  <!--              -->

  <xsl:variable name= "VarCreatedDate" select="wwdatetime:GetFileCreated(wwprojext:GetDocumentPath($ParamSplit/@documentID), $VarModifiedDateFormat)"/>
  <wwpage:Replacement name="document-created-date" value="{$VarCreatedDate}"/>

  <!-- Breadcrumbs -->
  <!--             -->
  <wwpage:Replacement name="breadcrumbs">
   <xsl:copy-of select="$VarBreadcrumbs" />
  </wwpage:Replacement>

  <!-- Content -->
  <!--         -->
  <wwpage:Replacement name="content">
   <xsl:call-template name="Content-Content">
    <xsl:with-param name="ParamContent" select="$ParamContent" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$VarCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
   <xsl:call-template name="Content-Notes">
    <xsl:with-param name="ParamNotes" select="$VarNotes" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$VarCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </wwpage:Replacement>

  <!-- Related Topics -->
  <!--                -->
  <wwpage:Replacement name="RelatedTopics">
   <xsl:call-template name="Content-RelatedTopics">
    <xsl:with-param name="ParamContent" select="$ParamContent" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$VarCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </wwpage:Replacement>
 </xsl:template>
</xsl:stylesheet>
