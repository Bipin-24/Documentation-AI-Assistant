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
 <xsl:variable name="GlobalResultPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), 'reverb_footer.xml')" />

 <!-- Output directory path -->
 <!--                       -->
 <xsl:variable name="GlobalOutputDirectoryPath" select="wwfilesystem:GetDirectoryName($GlobalResultPath)" />


 <!-- Project Groups -->
 <!--                -->
 <xsl:variable name="GlobalProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />

 <!-- ProjectChecksum -->
 <!--                 -->
 <xsl:variable name="GlobalProjectChecksum">
  <xsl:value-of select="concat(count($GlobalProjectGroups), ':', $GlobalProjectFilesChecksum)" />
 </xsl:variable>

 <!-- Page Rule -->
 <!--           -->
 <xsl:variable name="GlobalPageRule" select="wwprojext:GetRule('Page', wwprojext:GetFormatSetting('reverb-2.0-page-style'))" />

 <!-- Connect Page -->
 <!--              -->
 <xsl:variable name="GlobalConnectPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwprojext:GetFormatSetting('connect-entry'))" />


 <xsl:template match="/">
  <xsl:variable name="VarFileChildrenAsXML">
   <xsl:variable name="VarConditionsAsXML">
    <xsl:call-template name="PageTemplate-Conditions" />
   </xsl:variable>
   <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

   <xsl:variable name="VarReplacementsAsXML">
    <xsl:call-template name="PageTemplate-Replacements" />
   </xsl:variable>
   <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

   <xsl:call-template name="PageTemplate-ProcessFragment">
    <xsl:with-param name="ParamGlobalProject" select="$GlobalProject"/>
    <xsl:with-param name="ParamGlobalFiles" select="$GlobalFiles"/>
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

   <wwfiles:Files version="1.0">
    <xsl:copy-of select="$VarFileChildren" />
   </wwfiles:Files>
  </xsl:template>


 <xsl:template name="PageTemplate-Conditions">

  <xsl:if test="wwprojext:GetFormatSetting('footer-generate') = 'true'">
   <wwpage:Condition name="footer-enabled"/>
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo') != 'none' or wwprojext:GetFormatSetting('footer-logo-override') != ''">
   <wwpage:Condition name="footer-logo-enabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo') = 'company-logo-src'">
   <wwpage:Condition name="company-logo-for-footer-logo" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo') = 'company-name'">
   <wwpage:Condition name="company-name-for-footer-logo" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo-override') != ''">
   <wwpage:Condition name="footer-logo-override-exists" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo-override') = ''">
   <wwpage:Condition name="footer-logo-override-not-exists" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo-linked') = 'true'">
   <wwpage:Condition name="linked-footer-logo-enabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo-linked') = 'false'">
   <wwpage:Condition name="linked-footer-logo-disabled" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-logo-link-address') != ''">
   <wwpage:Condition name="footer-logo-link-exists" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('footer-publish-date') = 'true'">
   <wwpage:Condition name="footer-publish-date-exists" />
  </xsl:if>

  <!-- Company Info -->
  <!--              -->
  <xsl:call-template name="CompanyInfo-Conditions">
   <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="PageTemplate-Replacements">
   <!-- Footer Logo -->
   <!--              -->
   <xsl:if test="wwprojext:GetFormatSetting('footer-logo-override') != ''">
    <wwpage:Replacement name="footer-logo-src">
     <xsl:attribute name="value">
      <xsl:call-template name="URI-ResolveProjectFileURI">
       <xsl:with-param name="ParamFromAbsoluteURI" select="$GlobalConnectPath" />
       <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
       <xsl:with-param name="ParamURI" select="wwprojext:GetFormatSetting('footer-logo-override')" />
      </xsl:call-template>
     </xsl:attribute>
    </wwpage:Replacement>
   </xsl:if>

   <!-- Footer Logo Link -->
   <!--                  -->
   <xsl:variable name="VarFooterLogoLink">
    <xsl:choose>
     <xsl:when test="wwprojext:GetFormatSetting('footer-logo-link-address') = 'company-link'">
      <xsl:value-of select="wwprojext:GetFormatSetting('company-link')"/>
     </xsl:when>
     <xsl:when test="wwprojext:GetFormatSetting('footer-logo-link-address') != 'button-home' and wwprojext:GetFormatSetting('footer-logo-link-address') != ''">
      <xsl:value-of select="wwprojext:GetFormatSetting('footer-logo-link-address')"/>
     </xsl:when>
     <!-- If it's Home or empty, we'll be  -->
     <!-- sending them to the Splash page. -->
     <xsl:otherwise>
      <xsl:text>#</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <wwpage:Replacement name="footer-logo-link" value="{$VarFooterLogoLink}"/>

   <xsl:variable name="VarFooterLogoLinkClass">
    <xsl:choose>
     <xsl:when test="wwprojext:GetFormatSetting('footer-logo-link-address') = 'company-link'">
      <xsl:text>ww_behavior_logo_link_external</xsl:text>
     </xsl:when>
     <xsl:when test="wwprojext:GetFormatSetting('footer-logo-link-address') != 'button-home' and wwprojext:GetFormatSetting('footer-logo-link-address') != ''">
      <xsl:text>ww_behavior_logo_link_external</xsl:text>
     </xsl:when>
     <!-- If it's Home or empty, we'll be  -->
     <!-- sending them to the Splash page. -->
     <xsl:otherwise>
      <xsl:text>ww_behavior_logo_link_home</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <wwpage:Replacement name="footer-logo-link-class" value="{$VarFooterLogoLinkClass}"/>

   <!-- Company Info -->
   <!--              -->
   <xsl:call-template name="CompanyInfo-Replacements">
    <xsl:with-param name="ParamPageRule" select="$GlobalPageRule" />
    <xsl:with-param name="ParamPagePath" select="$GlobalConnectPath" />
    <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesSplits" />
   </xsl:call-template>

   <wwpage:Replacement name="connect-with-us" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ConnectWithUsLabel']/@value}" />
   <wwpage:Replacement name="phone-label" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PhoneLabel']/@value}" />
   <wwpage:Replacement name="fax-label" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FaxLabel']/@value}" />
   <wwpage:Replacement name="email-label" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'EmailLabel']/@value}" />

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
  </xsl:template>
</xsl:stylesheet>