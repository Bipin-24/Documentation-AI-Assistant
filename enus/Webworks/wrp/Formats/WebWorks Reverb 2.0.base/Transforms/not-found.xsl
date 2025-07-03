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
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterCopyType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />


 <xsl:include href="wwtransform:common/companyinfo/companyinfo_content.xsl" />
 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/connect_files.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_files.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_files.xsl')))" />
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

 <!-- Project files -->
 <!--               -->
 <xsl:variable name="GlobalProjectFiles" select="wwfilesystem:GetFiles(wwprojext:GetProjectFilesDirectoryPath())" />
 <xsl:variable name="GlobalProjectFilesPaths">
  <xsl:for-each select="$GlobalProjectFiles/wwfiles:Files/wwfiles:File">
   <xsl:value-of select="@path" />
   <xsl:value-of select="':'" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectFilesChecksum" select="wwstring:MD5Checksum($GlobalProjectFilesPaths)" />

 <!-- Project files as splits -->
 <!--                         -->
 <xsl:variable name="GlobalProjectFilesSplitsAsXML">
  <xsl:call-template name="Connect-Project-Files-As-Splits">
   <xsl:with-param name="ParamProjectFiles" select="$GlobalProjectFiles" />
  </xsl:call-template>
 </xsl:variable>
 <xsl:variable name="GlobalProjectFilesSplits" select="msxsl:node-set($GlobalProjectFilesSplitsAsXML)" />

 <!-- Result Page -->
 <!--             -->
 <xsl:variable name="GlobalResultPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'connect', 'not-found.html')" />

 <!-- Output directory path -->
 <!--                       -->
 <xsl:variable name="GlobalOutputDirectoryPath" select="wwfilesystem:GetDirectoryName($GlobalResultPath)" />

 <!-- Page Rule -->
 <!--           -->
 <xsl:variable name="GlobalPageRule" select="wwprojext:GetRule('Page', wwprojext:GetFormatSetting('not-found-page-style'))" />

 <!-- Merge Title -->
 <!--             -->
 <xsl:variable name="GlobalMergeTitle">
  <xsl:for-each select="$GlobalProject[1]">
   <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
   <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

   <xsl:choose>
    <xsl:when test="string-length($VarMergeSettings/@Title) &gt; 0">
     <xsl:value-of select="$VarMergeSettings/@Title" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="wwprojext:GetFormatName()" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:variable>

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

   <xsl:variable name="VarFileChildrenAsXML">
    <xsl:variable name="VarConditionsAsXML">
     <xsl:call-template name="PageTemplate-Conditions" />
    </xsl:variable>
    <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

    <xsl:variable name="VarReplacementsAsXML">
     <xsl:call-template name="PageTemplate-Replacements" />
    </xsl:variable>
    <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

    <xsl:call-template name="PageTemplate-Process">
     <xsl:with-param name="ParamGlobalProject" select="$GlobalProject"/>
     <xsl:with-param name="ParamGlobalFiles" select="$GlobalFiles"/>
     <xsl:with-param name="ParamType" select="$ParameterType" />
     <xsl:with-param name="ParamPageTemplateURI" select="$ParameterPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$GlobalOutputDirectoryPath" />
     <xsl:with-param name="ParamResultPath" select="$GlobalResultPath" />
     <xsl:with-param name="ParamConditions" select="$VarConditions" />
     <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
     <xsl:with-param name="ParamActionChecksum" select="$GlobalActionChecksum" />
     <xsl:with-param name="ParamProjectChecksum" select="$GlobalProjectFilesChecksum" />
     <xsl:with-param name="ParamLocaleType" select="$ParameterLocaleType" />
     <xsl:with-param name="ParamProjectVariablesType" select="$ParameterProjectVariablesType"/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFileChildren" select="msxsl:node-set($VarFileChildrenAsXML)" />

   <wwfiles:File path="{$GlobalResultPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($GlobalResultPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', $GlobalProjectFilesChecksum)}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <xsl:copy-of select="$VarFileChildren" />
   </wwfiles:File>
  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <!-- PDF Link -->
  <!--          -->
  <xsl:variable name="VarPDFLinkPath">
   <xsl:if test="string-length($GlobalProjectPDFPath) &gt; 0">
    <xsl:value-of select="$GlobalProjectPDFPath" />
   </xsl:if>
  </xsl:variable>

  <xsl:variable name="VarPDFLinkURI">
   <xsl:if test="string-length($VarPDFLinkPath) &gt; 0">
    <xsl:value-of select="wwuri:GetRelativeTo($VarPDFLinkPath, $GlobalResultPath)" />
   </xsl:if>
  </xsl:variable>

  <!-- Initial -->
  <!--         -->
  <xsl:variable name="VarInitialConditionsAsXML">
   <!-- Mark of the Web (MOTW) -->
   <!--                        -->
   <xsl:if test="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'">
    <wwpage:Condition name="emit-mark-of-the-web" />
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

   <!-- Back to Top -->
   <!--             -->
   <xsl:if test="wwprojext:GetFormatSetting('file-processing-back-to-top-link') = 'true'">
    <wwpage:Condition name="back-to-top-enabled" />
   </xsl:if>

   <!-- Google Translation -->
   <!--                    -->
   <xsl:if test="wwprojext:GetFormatSetting('google-translate') = 'true'">
    <wwpage:Condition name="google-translation-enabled" />
   </xsl:if>

   <!-- Company Info -->
   <!--              -->
   <xsl:call-template name="CompanyInfo-Conditions">
    <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
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
  <!-- PDF Link -->
  <!--          -->
  <xsl:variable name="VarPDFLinkPath">
   <xsl:if test="string-length($GlobalProjectPDFPath) &gt; 0">
    <xsl:value-of select="$GlobalProjectPDFPath" />
   </xsl:if>
  </xsl:variable>

  <xsl:variable name="VarPDFLinkURI">
   <xsl:if test="string-length($VarPDFLinkPath) &gt; 0">
    <xsl:value-of select="wwuri:GetRelativeTo($VarPDFLinkPath, $GlobalResultPath)" />
   </xsl:if>
  </xsl:variable>

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
    <xsl:with-param name="ParamSourceURI" select="$GlobalResultPath" />
   </xsl:call-template>
  </xsl:variable>

  <!-- page-onload-url -->
  <!--             -->
  <wwpage:Replacement name="page-onload-url">
   <xsl:value-of select="wwstring:Replace($VarRedirectToEntryURL, $GlobalSingleQuote, '%27')" />
  </wwpage:Replacement>

  <!-- body-class -->
  <!--            -->
  <wwpage:Replacement name="body-class">
   <xsl:attribute name="value">
    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($GlobalPageRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:value-of select="$VarAdditionalCSSClassesOption" />
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
      <xsl:with-param name="ParamProperties" select="$GlobalPageRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamFromAbsoluteURI" select="$GlobalResultPath" />
      <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:attribute>
  </wwpage:Replacement>

  <!-- Locale -->
  <!--        -->
  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />

  <!-- Content Type -->
  <!--              -->
  <wwpage:Replacement name="content-type" value="text/html;charset=utf-8" />

  <!-- Title -->
  <!--       -->
  <wwpage:Replacement name="title" value="{$GlobalMergeTitle}" />
  <wwpage:Replacement name="navigation-previous-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Previous']/@value}" />
  <wwpage:Replacement name="navigation-next-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Next']/@value}" />
  <wwpage:Replacement name="navigation-pdf-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PDF']/@value}" />
  <wwpage:Replacement name="navigation-print-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PrintLabel']/@value}" />
  <wwpage:Replacement name="navigation-email-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'EmailLabel']/@value}" />
  <wwpage:Replacement name="navigation-toc-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTabLabel']/@value}" />
  <wwpage:Replacement name="navigation-index-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTabLabel']/@value}" />
  <wwpage:Replacement name="navigation-search-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTabLabel']/@value}" />
  <wwpage:Replacement name="back-to-top-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BackToTopTitle']/@value}" />
  <wwpage:Replacement name="file-not-found-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FileNotFoundMessage']/@value}" />

  <wwpage:Replacement name="navigation-toc-link" value="#" />
  <wwpage:Replacement name="navigation-index-link" value="#" />
  <wwpage:Replacement name="navigation-search-link">
   <xsl:call-template name="Connect-URI-GetRelativeTo">
    <xsl:with-param name="ParamDestinationURI" select="$GlobalSearchPagePath" />
    <xsl:with-param name="ParamSourceURI" select="$GlobalResultPath" />
   </xsl:call-template>
  </wwpage:Replacement>

  <!-- Company Info -->
  <!--              -->
  <xsl:call-template name="CompanyInfo-Replacements">
   <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
   <xsl:with-param name="ParamPagePath" select="$GlobalResultPath" />
   <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
  </xsl:call-template>

  <!-- Date Replacements -->
  <!--                    -->
  <xsl:variable name= "VarDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>

  <!-- Published/Generated dated Date -->
  <!--                                -->
  <xsl:variable name= "VarPublishDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>
  <xsl:variable name= "VarPublishDate" select="wwdatetime:GetGenerateStart($VarPublishDateFormat)"/>
  <xsl:variable name= "VarPublishDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateLabel']/@value"/>
  <xsl:variable name= "VarFormattedPublishDate" select="wwstring:Format($VarPublishDateLabel, $VarPublishDate)"/>
  <wwpage:Replacement name="publish-date" value="{$VarFormattedPublishDate}"/>

  <!-- Preserve Unknown File Links -->
  <!--                             -->
  <wwpage:Replacement name="preserve-unknown-file-links" value="{wwprojext:GetFormatSetting('preserve-unknown-file-links')}"/>

  <!-- PDF Link -->
  <!--          -->
  <xsl:if test="string-length($VarPDFLinkURI) &gt; 0">
   <wwpage:Replacement name="pdf-link" value="{$VarPDFLinkURI}" />
   <wwpage:Replacement name="pdf-download" value="{wwfilesystem:GetBaseName($VarPDFLinkPath)}" />
  </xsl:if>
  <wwpage:Replacement name="pdf-target" value="{wwprojext:GetFormatSetting('pdf-target')}" />

  <!-- No-JavaScript -->
  <!--               -->
  <wwpage:Replacement name="locales-no-javascript-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoJavaScriptMessage']/@value}" />

 </xsl:template>
</xsl:stylesheet>
