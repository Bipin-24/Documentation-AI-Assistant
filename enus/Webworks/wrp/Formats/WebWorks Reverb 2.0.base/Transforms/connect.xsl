<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwsplitpriorities="urn:WebWorks-Engine-Split-Priorities-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
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
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwmultisere="urn:WebWorks-XSLT-Extension-MultiSearchReplace"
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              exclude-result-prefixes="xsl msxsl wwsplits wwsplitpriorities wwmode wwfiles wwdoc wwproject wwvars wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc wwmultisere wwdatetime"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterParcelType" />
 <xsl:param name="ParameterCopyType" />
 <xsl:param name="ParameterStandaloneParcelType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterSplitsProjectType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />


 <xsl:include href="wwtransform:common/companyinfo/companyinfo_content.xsl" />
 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/connect_files.xsl" />


 <xsl:key name="wwproject-group-by-groupid" match="wwproject:Group" use="@GroupID" />
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
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
 <xsl:variable name="GlobalResultPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwprojext:GetFormatSetting('connect-entry'))" />

 <!-- Output directory path -->
 <!--                       -->
 <xsl:variable name="GlobalOutputDirectoryPath" select="wwfilesystem:GetDirectoryName($GlobalResultPath)" />

 <!-- Splits in Project -->
 <!--                   -->
 <xsl:variable name="GlobalSplitsProjectPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterSplitsProjectType, ':', '_'),'.xml'))" />
 <xsl:variable name="GlobalSplitsProject" select="wwexsldoc:LoadXMLWithoutResolver($GlobalSplitsProjectPath)" />

 <!-- Project Groups -->
 <!--                -->
 <xsl:variable name="GlobalProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />

 <!-- Number of Groups -->
 <!--                  -->
 <xsl:variable name="GlobalNumberOfGroups">
  <xsl:value-of select="count($GlobalProjectGroups)"/>
 </xsl:variable>

 <!-- ProjectChecksum -->
 <!--                 -->
 <xsl:variable name="GlobalProjectChecksum">
  <xsl:value-of select="concat(count($GlobalProjectGroups), ':', $GlobalProjectFilesChecksum)" />
 </xsl:variable>

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

 <!-- FooterEndOfLayout -->
 <!--                   -->
 <xsl:variable name="GlobalFooterEndOfLayout">
  <xsl:choose>
   <xsl:when test="wwprojext:GetFormatSetting('footer-location') = 'end-of-page'">
    <xsl:text>false</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>true</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>

 <!-- Page Rule -->
 <!--           -->
 <xsl:variable name="GlobalPageRule" select="wwprojext:GetRule('Page', wwprojext:GetFormatSetting('reverb-2.0-page-style'))" />


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

   <xsl:call-template name="ConfigureScripts" />
  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <!-- Toolbar Tabs -->
  <!--              -->
  <xsl:if test="wwprojext:GetFormatSetting('toolbar-tabs') = 'true'">
   <wwpage:Condition name="toolbar-tabs-enabled" />
  </xsl:if>

  <!-- Mark of the Web (MOTW) -->
  <!--                        -->
  <xsl:if test="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'">
   <wwpage:Condition name="emit-mark-of-the-web" />
  </xsl:if>

  <!-- favicon -->
  <!--         -->
  <xsl:if test="wwprojext:GetFormatSetting('connect-browser-tab-icon') != ''">
   <wwpage:Condition name="favicon-enabled" />
  </xsl:if>

  <!-- Home -->
  <!--      -->
  <xsl:if test="wwprojext:GetFormatSetting('button-home') = 'true'">
   <wwpage:Condition name="home-enabled" />
  </xsl:if>

  <!-- TOC -->
  <!--     -->
  <xsl:if test="wwprojext:GetFormatSetting('toc-generate') = 'true'">
   <wwpage:Condition name="toc-enabled" />
  </xsl:if>

  <!-- Menu Initial State -->
  <!--                    -->
  <xsl:choose>
   <xsl:when test="wwprojext:GetFormatSetting('menu-initial-state') = 'close'">
    <wwpage:Condition name="menu-initial-state-closed" />
   </xsl:when>
   <xsl:otherwise>
    <wwpage:Condition name="menu-initial-state-open" />
   </xsl:otherwise>
  </xsl:choose>

  <!-- Toolbar Logo -->
  <!--              -->

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo') != 'none' or wwprojext:GetFormatSetting('toolbar-logo-override') != ''">
   <wwpage:Condition name="toolbar-logo-enabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo') = 'none' and wwprojext:GetFormatSetting('toolbar-logo-override') = ''">
   <wwpage:Condition name="toolbar-logo-disabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo') = 'company-logo-src'">
   <wwpage:Condition name="company-logo-for-toolbar-logo" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo') = 'company-name'">
   <wwpage:Condition name="company-name-for-toolbar-logo" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-override') != ''">
   <wwpage:Condition name="toolbar-logo-override-exists" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-override') = ''">
   <wwpage:Condition name="toolbar-logo-override-not-exists" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-linked') = 'true'">
   <wwpage:Condition name="linked-toolbar-logo-enabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-linked') = 'false'">
   <wwpage:Condition name="linked-toolbar-logo-disabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-link-address') != ''">
   <wwpage:Condition name="toolbar-logo-link-exists" />
  </xsl:if>

  <!-- Menu -->
  <!--      -->
  <xsl:if test="wwprojext:GetFormatSetting('menu-generate') = 'true'">
   <wwpage:Condition name="menu-enabled"/>
  </xsl:if>

  <!-- Index -->
  <!--       -->
  <xsl:if test="wwprojext:GetFormatSetting('index-generate') = 'true'">
   <wwpage:Condition name="index-enabled" />
  </xsl:if>

  <!-- Search -->
  <!--        -->
  <xsl:if test="wwprojext:GetFormatSetting('search-scope-enabled') = 'true'">
   <wwpage:Condition name="search-scope-enabled" />
  </xsl:if>

  <xsl:if test="$GlobalNumberOfGroups &gt; 1">
   <wwpage:Condition name="more-than-one-group" />
  </xsl:if>

  <!-- Footer -->
  <!--        -->
  <xsl:if test="wwprojext:GetFormatSetting('footer-location') = 'end-of-page'">
   <wwpage:Condition name="footer-location-page-end" />
  </xsl:if>
  <xsl:if test="wwprojext:GetFormatSetting('footer-location') = 'end-of-layout'">
   <wwpage:Condition name="footer-location-layout-end" />
  </xsl:if>

  <!-- Google Translation -->
  <!--                    -->
  <xsl:if test="wwprojext:GetFormatSetting('google-translate') = 'true'">
   <wwpage:Condition name="globe" />
   <wwpage:Condition name="google-translation-enabled" />
  </xsl:if>

  <!-- Google Analytics -->
  <!--                  -->
  <xsl:if test="wwprojext:GetFormatSetting('google-analytics-id') != ''">
   <wwpage:Condition name="google-analytics-enabled" />
  </xsl:if>

  <!-- Back to Top -->
  <!--             -->
  <xsl:if test="wwprojext:GetFormatSetting('file-processing-back-to-top-link') = 'true'">
   <wwpage:Condition name="back-to-top-enabled" />
  </xsl:if>

  <!-- Company Info -->
  <!--              -->
  <xsl:call-template name="CompanyInfo-Conditions">
   <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="PageTemplate-Replacements">
  <!-- Toolbar Group Tabs -->
  <!--                    -->
  <wwpage:Replacement name="toolbar-tabs">
   <xsl:variable name="VarProjectGroupsAsXML" select="$GlobalSplitsProject/wwsplits:Splits/wwsplits:File[@type='parcel']"/>

   <xsl:variable name="VarConnectPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwprojext:GetFormatSetting('connect-entry'))" />

   <xsl:for-each select="$VarProjectGroupsAsXML">
    <xsl:variable name="VarGroupID" select="./@groupID"/>
    <xsl:variable name="VarGroupFirstSplitPath" select="$GlobalSplitsProject/wwsplits:Splits/wwsplits:Split[@groupID=$VarGroupID][1]/@path"/>
    <xsl:variable name="VarTabHref" select="wwuri:GetRelativeTo($VarGroupFirstSplitPath, $VarConnectPath)"/>
    <xsl:variable name="VarTabTitle" select="./@title"/>

    <html:li>
     <html:div id="tab:{$VarGroupID}" class="ww_skin_toolbar_tab">
      <html:a href="{$VarTabHref}" title="{$VarTabTitle}">
       <xsl:value-of select="$VarTabTitle"/>
      </html:a>
     </html:div>
    </html:li>
   </xsl:for-each>
  </wwpage:Replacement>

  <!-- Mark of the Web (MOTW) -->
  <!--                        -->
  <wwpage:Replacement name="mark-of-the-web">
   <xsl:comment> saved from url=(0016)http://localhost </xsl:comment>
  </wwpage:Replacement>

  <!-- favicon -->
  <!--         -->
  <xsl:if test="wwprojext:GetFormatSetting('connect-browser-tab-icon') != ''">
   <wwpage:Replacement name="favicon-src">
    <xsl:attribute name="value">
     <xsl:call-template name="URI-ResolveProjectFileURI">
      <xsl:with-param name="ParamFromAbsoluteURI" select="$GlobalResultPath" />
      <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
      <xsl:with-param name="ParamURI" select="wwprojext:GetFormatSetting('connect-browser-tab-icon')" />
     </xsl:call-template>
    </xsl:attribute>
   </wwpage:Replacement>
  </xsl:if>

  <!-- body-class -->
  <!--            -->
  <wwpage:Replacement name="body-class">
   <xsl:attribute name="value">
    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($GlobalPageRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:value-of select="concat('preload', $VarAdditionalCSSClassesOption)" />
   </xsl:attribute>
  </wwpage:Replacement>

  <wwpage:Replacement name="presentation-div-initial-class">
   <xsl:attribute name="value">
    <xsl:choose>
     <xsl:when test="wwprojext:GetFormatSetting('menu-initial-state') = 'close'">
      <xsl:text>menu_initial menu_closed</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>menu_initial menu_open</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
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

  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
  <wwpage:Replacement name="content-type" value="{string('text/html;charset=utf-8')}" />

  <!-- Title -->
  <!--       -->
  <wwpage:Replacement name="title" value="{$GlobalMergeTitle}" />

  <!-- Back to Top -->
  <!--             -->
  <wwpage:Replacement name="back-to-top-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BackToTopTitle']/@value}" />

  <!-- Company Info -->
  <!--              -->
  <xsl:call-template name="CompanyInfo-Replacements">
   <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
   <xsl:with-param name="ParamPagePath" select="$GlobalResultPath" />
   <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
  </xsl:call-template>

  <!-- Date Replacements -->
  <!--                    -->
  <xsl:variable name= "VarDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'DateFormat']/@value"/>

  <!-- Published/Generated dated Date -->
  <!--                                -->
  <xsl:variable name= "VarPublishDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>
  <xsl:variable name= "VarPublishDate" select="wwdatetime:GetGenerateStart($VarPublishDateFormat)"/>
  <xsl:variable name= "VarPublishDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateLabel']/@value"/>
  <xsl:variable name= "VarFormattedPublishDate" select="wwstring:Format($VarPublishDateLabel, $VarPublishDate)"/>
  <wwpage:Replacement name="publish-date" value="{$VarFormattedPublishDate}"/>

  <!-- Toolbar Logo -->
  <!--              -->
  <xsl:if test="wwprojext:GetFormatSetting('toolbar-logo-override') != ''">
   <wwpage:Replacement name="toolbar-logo-src">
    <xsl:attribute name="value">
     <xsl:call-template name="URI-ResolveProjectFileURI">
      <xsl:with-param name="ParamFromAbsoluteURI" select="$GlobalResultPath" />
      <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
      <xsl:with-param name="ParamURI" select="wwprojext:GetFormatSetting('toolbar-logo-override')" />
     </xsl:call-template>
    </xsl:attribute>
   </wwpage:Replacement>
  </xsl:if>

  <!-- Toolbar Logo Link -->
  <!--                   -->
  <xsl:variable name="VarToolbarLogoLink">
   <xsl:choose>
    <xsl:when test="wwprojext:GetFormatSetting('toolbar-logo-link-address') = 'company-link'">
     <xsl:value-of select="wwprojext:GetFormatSetting('company-link')"/>
    </xsl:when>
    <xsl:when test="wwprojext:GetFormatSetting('toolbar-logo-link-address') != 'button-home' and wwprojext:GetFormatSetting('toolbar-logo-link-address') != ''">
     <xsl:value-of select="wwprojext:GetFormatSetting('toolbar-logo-link-address')"/>
    </xsl:when>
    <!-- If it's Home or empty, we'll be  -->
    <!-- sending them to the Splash page. -->
    <xsl:otherwise>
     <xsl:text>#</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="toolbar-logo-link" value="{$VarToolbarLogoLink}"/>

  <xsl:variable name="VarToolbarLogoLinkClass">
   <xsl:choose>
    <xsl:when test="wwprojext:GetFormatSetting('toolbar-logo-link-address') = 'company-link'">
     <xsl:text>ww_behavior_logo_link_external</xsl:text>
    </xsl:when>
    <xsl:when test="wwprojext:GetFormatSetting('toolbar-logo-link-address') != 'button-home' and wwprojext:GetFormatSetting('toolbar-logo-link-address') != ''">
     <xsl:text>ww_behavior_logo_link_external</xsl:text>
    </xsl:when>
    <!-- If it's Home or empty, we'll be  -->
    <!-- sending them to the Splash page. -->
    <xsl:otherwise>
     <xsl:text>ww_behavior_logo_link_home</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="toolbar-logo-link-class" value="{$VarToolbarLogoLinkClass}"/>

  <xsl:variable name="VarTOCContentClass">
   <xsl:variable name="VarTOCIconPosition" select="wwprojext:GetFormatSetting('toc-icon-position')"/>
   <xsl:choose>
    <xsl:when test="$VarTOCIconPosition = 'right'">
     <xsl:text>toc_icons_right</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>toc_icons_left</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="toc-content-class" value="{$VarTOCContentClass}"/>


  <!-- Search Input Placeholder -->
  <!--                          -->
  <wwpage:Replacement name="search-input-placeholder" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchInputPlaceholder']/@value}" />

  <!-- Toolbar Button Titles -->
  <!--                       -->
  <wwpage:Replacement name="home-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'HomeTabLabel']/@value}" />
  <wwpage:Replacement name="toc-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTabLabel']/@value}" />
  <wwpage:Replacement name="index-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTabLabel']/@value}" />
  <wwpage:Replacement name="search-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTabLabel']/@value}" />
  <wwpage:Replacement name="menu-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'MenuTabLabel']/@value}"/>
  <wwpage:Replacement name="previous-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Previous']/@value}" />
  <wwpage:Replacement name="next-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'Next']/@value}" />
  <wwpage:Replacement name="print-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PrintLabel']/@value}" />
  <wwpage:Replacement name="email-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'EmailLabel']/@value}" />
  <wwpage:Replacement name="pdf-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PDF']/@value}" />
  <wwpage:Replacement name="translate-button-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TranslateLabel']/@value}" />

  <!-- No-Cookies -->
  <!--            -->
  <wwpage:Replacement name="locales-no-cookies-title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoCookiesTitle']/@value}" />
  <wwpage:Replacement name="locales-no-cookies-body" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoCookiesBody']/@value}" />
  <wwpage:Replacement name="locales-no-cookies-button" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoCookiesButton']/@value}" />

  <!-- No-JavaScript -->
  <!--               -->
  <wwpage:Replacement name="locales-no-javascript-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NoJavaScriptMessage']/@value}" />

  <!-- Parcels -->
  <!--         -->
  <wwpage:Replacement name="parcels">
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
    <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />
    <xsl:call-template name="Parcels">
     <xsl:with-param name="ParamPath" select="$GlobalResultPath" />
     <xsl:with-param name="ParamMergeSettings" select="$VarMergeSettings" />
    </xsl:call-template>
   </xsl:for-each>
  </wwpage:Replacement>

  <!-- Header -->
  <!--        -->
  <xsl:variable name="VarHeaderXMLFilePath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), 'reverb_header.xml')"/>
  <xsl:variable name="VarHeaderExists" select="wwfilesystem:Exists($VarHeaderXMLFilePath)"/>

  <wwpage:Replacement name="header-content">
   <xsl:if test="$VarHeaderExists = 'true'">
    <xsl:variable name="VarHeaderAsXML" select="wwexsldoc:LoadXMLWithoutResolver($VarHeaderXMLFilePath)"/>
    <xsl:variable name="VarHeaderHTMLFragment" select="msxsl:node-set($VarHeaderAsXML)/html:body/child::*" />

    <xsl:copy-of select="$VarHeaderHTMLFragment"/>
   </xsl:if>
  </wwpage:Replacement>

  <!-- Footer -->
  <!--        -->
  <xsl:variable name="VarFooterXMLFilePath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), 'reverb_footer.xml')"/>
  <xsl:variable name="VarFooterExists" select="wwfilesystem:Exists($VarFooterXMLFilePath)"/>

  <wwpage:Replacement name="footer-content">
   <xsl:if test="$VarFooterExists = 'true'">
    <xsl:variable name="VarFooterAsXML" select="wwexsldoc:LoadXMLWithoutResolver($VarFooterXMLFilePath)"/>
    <xsl:variable name="VarFooterHTMLFragment" select="msxsl:node-set($VarFooterAsXML)/html:body/child::*" />

    <xsl:copy-of select="$VarFooterHTMLFragment"/>
   </xsl:if>
  </wwpage:Replacement>

  <!-- Unsupported Browser -->
  <!--                     -->
  <xsl:variable name="VarUnsupportedBrowserXMLFilePath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), 'reverb_unsupported_browser.xml')"/>
  <xsl:variable name="VarUnsupportedBrowserExists" select="wwfilesystem:Exists($VarUnsupportedBrowserXMLFilePath)"/>

  <wwpage:Replacement name="unsupported-browser-content">
   <xsl:if test="$VarUnsupportedBrowserExists = 'true'">
    <xsl:variable name="VarUnsupportedBrowserAsXML" select="wwexsldoc:LoadXMLWithoutResolver($VarUnsupportedBrowserXMLFilePath)"/>
    <xsl:variable name="VarUnsupportedBrowserHTMLFragment" select="msxsl:node-set($VarUnsupportedBrowserAsXML)/html:body/child::*" />

    <xsl:copy-of select="$VarUnsupportedBrowserHTMLFragment"/>
   </xsl:if>
  </wwpage:Replacement>
 </xsl:template>

 <xsl:template name="ConfigureScripts">
  <xsl:variable name="VarAnalyticsJSInputPath" select="wwuri:AsFilePath('wwformat:Pages/scripts/analytics.js')"/>
  <xsl:variable name="VarConnectJSInputPath" select="wwuri:AsFilePath('wwformat:Pages/scripts/connect.js')"/>
  <xsl:variable name="VarAnalyticsJSOutputPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'scripts', 'analytics.js')" />
  <xsl:variable name="VarConnectJSOutputPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'scripts', 'connect.js')" />

  <xsl:variable name="VarScriptReplacementsAsXML">
   <xsl:if test="wwprojext:GetFormatSetting('google-analytics-id') != ''">
    <wwmultisere:Entry match="var GLOBAL_GA_TRACKING_ID = '';" replacement="var GLOBAL_GA_TRACKING_ID = '{wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('google-analytics-id'))}';" />
   </xsl:if>
   <xsl:if test="wwprojext:GetFormatSetting('google-analytics-default-url') != ''">
    <wwmultisere:Entry match="var GLOBAL_GA_DEFAULT_URL = '';" replacement="var GLOBAL_GA_DEFAULT_URL = '{wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('google-analytics-default-url'))}';" />
   </xsl:if>
   <wwmultisere:Entry match="var GLOBAL_SHOW_FIRST_DOCUMENT = false;" replacement="var GLOBAL_SHOW_FIRST_DOCUMENT = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('show-first-document'))};" />
   <wwmultisere:Entry match="var GLOBAL_NAVIGATION_MIN_PAGE_WIDTH = 800;" replacement="var GLOBAL_NAVIGATION_MIN_PAGE_WIDTH = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('reverb-2.0-minimum-page-width'))};" />
   <wwmultisere:Entry match="var GLOBAL_LIGHTBOX_LARGE_IMAGES = false;" replacement="var GLOBAL_LIGHTBOX_LARGE_IMAGES = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('connect-lightbox-large-images'))};" />
   <wwmultisere:Entry match="var GLOBAL_DISQUS_ID = '';" replacement="var GLOBAL_DISQUS_ID = '{wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('social-disqus-id'))}';" />
   <wwmultisere:Entry match="var GLOBAL_EMAIL = '';" replacement="var GLOBAL_EMAIL = '{wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('feedback-email'))}';" />
   <wwmultisere:Entry match="var GLOBAL_EMAIL_MESSAGE = '';" replacement="var GLOBAL_EMAIL_MESSAGE = '{wwprojext:GetFormatSetting('feedback-email-message')}';" />
   <wwmultisere:Entry match="var GLOBAL_FOOTER_END_OF_LAYOUT = true;" replacement="var GLOBAL_FOOTER_END_OF_LAYOUT = {wwstring:JavaScriptEncoding($GlobalFooterEndOfLayout)};" />
   <wwmultisere:Entry match="var GLOBAL_SEARCH_TITLE = 'Search';" replacement="var GLOBAL_SEARCH_TITLE = '{wwstring:JavaScriptEncoding($GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTitle']/@value)}';" />
   <wwmultisere:Entry match="var GLOBAL_SEARCH_SCOPE_ALL_LABEL = 'All';" replacement="var GLOBAL_SEARCH_SCOPE_ALL_LABEL = '{wwstring:JavaScriptEncoding($GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchScopeAllLabel']/@value)}';" />
   <wwmultisere:Entry match="var GLOBAL_SEARCH_QUERY_MIN_LENGTH = 4;" replacement="var GLOBAL_SEARCH_QUERY_MIN_LENGTH = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('search-query-minimum-character-amount'))};" />
   <wwmultisere:Entry match="var GLOBAL_PROGRESSIVE_SEARCH_ENABLED = true;" replacement="var GLOBAL_PROGRESSIVE_SEARCH_ENABLED = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('progressive-search-enabled'))};" />
   <wwmultisere:Entry match="var GLOBAL_USE_MERGED_INDEX = true;" replacement="var GLOBAL_USE_MERGED_INDEX = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('index-combined-enabled'))};" />
   <wwmultisere:Entry match="var GLOBAL_NOT_FOUND_PAGE_ENABLED = true;" replacement="var GLOBAL_NOT_FOUND_PAGE_ENABLED = {wwstring:JavaScriptEncoding(wwprojext:GetFormatSetting('not-found-page-enabled'))};" />
  </xsl:variable>
  <xsl:variable name="VarScriptReplacements" select="msxsl:node-set($VarScriptReplacementsAsXML)/*" />

  <xsl:variable name="VarEncoding" select="string('utf-8')" />
  <xsl:variable name="VarReplaceAllInAnalyticsJSFile" select="wwmultisere:ReplaceAllInFile($VarEncoding, $VarAnalyticsJSInputPath, $VarEncoding, $VarAnalyticsJSOutputPath, $VarScriptReplacements)" />
  <xsl:variable name="VarReplaceAllInConnectJSFile" select="wwmultisere:ReplaceAllInFile($VarEncoding, $VarConnectJSInputPath, $VarEncoding, $VarConnectJSOutputPath, $VarScriptReplacements)" />

  <!-- Report Files -->
  <!--              -->
  <wwfiles:File path="{$VarAnalyticsJSOutputPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarAnalyticsJSOutputPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="" category="" use="" deploy="{$ParameterDeploy}">
   <wwfiles:Depends path="{$VarAnalyticsJSInputPath}" checksum="{wwfilesystem:GetChecksum($VarAnalyticsJSInputPath)}" groupID="" documentID="" />
  </wwfiles:File>
  <wwfiles:File path="{$VarConnectJSOutputPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarConnectJSOutputPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="" category="" use="" deploy="{$ParameterDeploy}">
   <wwfiles:Depends path="{$VarConnectJSInputPath}" checksum="{wwfilesystem:GetChecksum($VarConnectJSInputPath)}" groupID="" documentID="" />
  </wwfiles:File>
 </xsl:template>

 <xsl:template name="Parcels">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamMergeSettings" />

  <!-- Process merge settings -->
  <!--                        -->
  <xsl:variable name="VarParcelsAsXML">
   <html:ul>
    <xsl:apply-templates select="$ParamMergeSettings" mode="wwmode:parcels">
     <xsl:with-param name="ParamPath" select="$ParamPath" />
    </xsl:apply-templates>
   </html:ul>
  </xsl:variable>
  <xsl:variable name="VarParcels" select="msxsl:node-set($VarParcelsAsXML)" />

  <!-- Filter empty parcels -->
  <!--                      -->
  <xsl:apply-templates select="$VarParcels" mode="wwmode:filter-parcels" />
 </xsl:template>


 <xsl:template name="VerifyGroup">
  <xsl:param name="ParamMergeGroup" />

  <xsl:for-each select="$GlobalProject[1]">
   <xsl:variable name="VarGroup" select="key('wwproject-group-by-groupid', $ParamMergeGroup/@GroupID)" />
   <xsl:variable name="VarGroupDocuments" select="$VarGroup/descendant::wwproject:Document" />

   <xsl:value-of select="count($VarGroupDocuments[1]) &gt; 0" />
  </xsl:for-each>
 </xsl:template>


 <!-- wwmode:parcels -->
 <!--                -->

 <xsl:template match="/" mode="wwmode:parcels">
  <xsl:param name="ParamPath" />

  <xsl:apply-templates mode="wwmode:parcels">
   <xsl:with-param name="ParamPath" select="$ParamPath" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwproject:TOC" mode="wwmode:parcels">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamTOC" select="." />

  <xsl:variable name="VarMergeGroups" select="$ParamTOC/*" />

  <xsl:variable name="VarGroupIDsWithSeparator">
   <xsl:for-each select="$VarMergeGroups">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./@GroupID"/>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarGroupAndIDs" select="concat('group', $VarGroupIDsWithSeparator)" />

  <html:li>
   <xsl:if test="not($VarGroupAndIDs = 'group')">
    <xsl:attribute name="id">
     <xsl:value-of select="$VarGroupAndIDs" />
    </xsl:attribute>
    <xsl:attribute name="data-group-title">
     <xsl:value-of select="$ParamTOC/@Name" />
    </xsl:attribute>
   </xsl:if>

   <html:div class="ww_skin_toc_entry ww_skin_toc_folder">
    <!-- No break -->
    <!--          -->
    <wwexsldoc:NoBreak />

    <html:div class="ww_skin_toc_entry_indent"></html:div>

    <xsl:variable name="VarTOCIconPosition" select="wwprojext:GetFormatSetting('toc-icon-position')"/>

    <xsl:if test="$VarTOCIconPosition = 'left'">
     <html:div class="ww_skin_toc_entry_icon">
      <html:span class="ww_skin ww_skin_toc_dropdown ww_skin_toc_dropdown_closed">
       <html:i class="fa"></html:i>
      </html:span>
     </html:div>
    </xsl:if>

    <html:span class="ww_skin_toc_entry_title" title="{$ParamTOC/@Name}">
     <xsl:value-of select="$ParamTOC/@Name" />
    </html:span>

    <xsl:if test="$VarTOCIconPosition = 'right'">
     <html:div class="ww_skin_toc_entry_icon">
      <html:span class="ww_skin ww_skin_toc_dropdown ww_skin_toc_dropdown_closed">
       <html:i class="fa"></html:i>
      </html:span>
     </html:div>
    </xsl:if>
   </html:div>

   <html:ul>
    <xsl:apply-templates mode="wwmode:parcels">
     <xsl:with-param name="ParamPath" select="$GlobalResultPath" />
    </xsl:apply-templates>
   </html:ul>
  </html:li>
 </xsl:template>


 <xsl:template match="wwproject:MergeGroup" mode="wwmode:parcels">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamMergeGroup" select="." />

  <xsl:variable name="VarIncludeGroup">
   <xsl:call-template name="VerifyGroup">
    <xsl:with-param name="ParamMergeGroup" select="$ParamMergeGroup" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$VarIncludeGroup = 'true'">
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarGroupName" select="wwprojext:GetGroupName($ParamMergeGroup/@GroupID)" />

    <!-- Determine parcel title -->
    <!--                        -->
    <xsl:variable name="VarGroupTitle">
     <xsl:choose>
      <xsl:when test="string-length($ParamMergeGroup/@Title) &gt; 0">
       <xsl:value-of select="$ParamMergeGroup/@Title" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$VarGroupName" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <html:li id="group:{$ParamMergeGroup/@GroupID}" data-group-title="{$VarGroupTitle}">
     <html:div class="ww_skin_toc_entry ww_skin_toc_folder">
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

      <!-- Determine parcel context -->
      <!--                          -->
      <xsl:variable name="VarParcelContext">
       <xsl:call-template name="Connect-Context">
        <xsl:with-param name="ParamProject" select="$GlobalProject" />
        <xsl:with-param name="ParamGroupID" select="$ParamMergeGroup/@GroupID" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Locate parcel page path -->
      <!--                         -->
      <xsl:for-each select="$GlobalFiles[1]">
       <xsl:variable name="VarParcelFile" select="key('wwfiles-files-by-type', $ParameterParcelType)[@groupID = $ParamMergeGroup/@GroupID]" />
       <html:a class="ww_skin_toc_entry_title" id="{$VarParcelContext}:{$ParamMergeGroup/@GroupID}" href="{wwuri:GetRelativeTo($VarParcelFile/@path, $GlobalResultPath)}" target="_self" title="{$VarGroupTitle}">
        <xsl:value-of select="$VarGroupTitle" />
       </html:a>
      </xsl:for-each>

      <xsl:if test="$VarTOCIconPosition = 'right'">
       <html:div class="ww_skin_toc_entry_icon">
        <html:span class="ww_skin ww_skin_toc_dropdown ww_skin_toc_dropdown_closed">
         <html:i class="fa"></html:i>
        </html:span>
       </html:div>
      </xsl:if>
     </html:div>
    </html:li>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:parcels">
  <xsl:param name="ParamPath" />

  <xsl:apply-templates mode="wwmode:parcels">
   <xsl:with-param name="ParamPath" select="$GlobalResultPath" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:parcels">
  <xsl:param name="ParamPath" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:filter-parcels -->
 <!--                       -->

 <xsl:template match="/" mode="wwmode:filter-parcels">
  <xsl:apply-templates mode="wwmode:filter-parcels" />
 </xsl:template>


 <xsl:template match="html:ul" mode="wwmode:filter-parcels">
  <xsl:param name="ParamList" select="." />

  <!-- Contains child links? -->
  <!--                       -->
  <xsl:variable name="VarContainsChildLinks" select="count($ParamList//html:a[1]) &gt; 0" />

  <!-- Keep it? -->
  <!--          -->
  <xsl:if test="$VarContainsChildLinks">
   <xsl:copy>
    <xsl:copy-of select="@*" />

    <xsl:apply-templates mode="wwmode:filter-parcels" />
   </xsl:copy>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:filter-parcels">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:filter-parcels" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:filter-parcels">
  <xsl:copy />
 </xsl:template>
</xsl:stylesheet>
