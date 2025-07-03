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
                              xmlns:wwmultisere="urn:WebWorks-XSLT-Extension-MultiSearchReplace"
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc wwmultisere wwdatetime"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />


 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
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

 <!-- Result Page -->
 <!--             -->
 <xsl:variable name="GlobalResultPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'connect', 'search.html')" />

 <!-- Output directory path -->
 <!--                       -->
 <xsl:variable name="GlobalOutputDirectoryPath" select="wwfilesystem:GetDirectoryName($GlobalResultPath)" />

 <!-- Number of Groups -->
 <!--                  -->
 <xsl:variable name="GlobalNumberOfGroups">
  <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
  <xsl:value-of select="count($VarProjectGroups)"/>
 </xsl:variable>

 <!-- Connect Pages -->
 <!--               -->
 <xsl:variable name="GlobalEntryPagePath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwprojext:GetFormatSetting('connect-entry'))" />

 <xsl:variable name="GlobalSingleQuote">
  <xsl:text>'</xsl:text>
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Search Page -->
   <!--             -->
   <xsl:variable name="VarProgressSearchStart" select="wwprogress:Start(1)" />

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <!-- Create search page -->
    <!--                    -->
    <xsl:call-template name="Search">
    </xsl:call-template>
   </xsl:if>

   <xsl:variable name="VarProgressSearchEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Search">
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
    <xsl:with-param name="ParamProjectChecksum" select="''" />
    <xsl:with-param name="ParamLocaleType" select="$ParameterLocaleType" />
    <xsl:with-param name="ParamProjectVariablesType" select="$ParameterProjectVariablesType"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFileChildren" select="msxsl:node-set($VarFileChildrenAsXML)" />

  <wwfiles:File path="{$GlobalResultPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($GlobalResultPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
   <xsl:copy-of select="$VarFileChildren" />
  </wwfiles:File>

  <xsl:call-template name="ConfigureScript" />

 </xsl:template>


 <xsl:template name="PageTemplate-Conditions">
  <!-- Mark of the Web (MOTW) -->
  <!--                        -->
  <xsl:if test="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'">
   <wwpage:Condition name="emit-mark-of-the-web" />
  </xsl:if>

  <!-- Search Scope -->
  <!--              -->
  <xsl:if test="wwprojext:GetFormatSetting('search-scope-enabled') = 'true'">
   <wwpage:Condition name="search-scope-enabled" />
  </xsl:if>

  <xsl:if test="$GlobalNumberOfGroups &gt; 1">
   <wwpage:Condition name="more-than-one-group" />
  </xsl:if>

  <xsl:if test="wwprojext:GetFormatSetting('search-result-count') = 'true'">
   <wwpage:Condition name="include-search-result-count"/>
  </xsl:if>

  <!-- Search Helpful -->
  <!--                -->
  <xsl:if test="wwprojext:GetFormatSetting('search-helpful-buttons') = 'true'">
   <wwpage:Condition name="search-helpful-buttons-enabled" />
  </xsl:if>
 </xsl:template>

 <xsl:template name="PageTemplate-Replacements">
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

  <!-- Helpful Message -->
  <!--                 -->
  <wwpage:Replacement name="locales-search-helpful-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchHelpfulMessage']/@value}" />

  <!-- redirect -->
  <!--          -->
  <xsl:variable name="VarRedirectToEntryURL">
   <xsl:call-template name="Connect-URI-GetRelativeTo">
    <xsl:with-param name="ParamDestinationURI" select="$GlobalEntryPagePath" />
    <xsl:with-param name="ParamSourceURI" select="$GlobalResultPath" />
   </xsl:call-template>
   <xsl:text>#search/</xsl:text>
  </xsl:variable>

  <!-- search-onload-url -->
  <!--             -->
  <wwpage:Replacement name="search-onload-url">
   <xsl:value-of select="wwstring:Replace($VarRedirectToEntryURL, $GlobalSingleQuote, '%27')" />
  </wwpage:Replacement>

  <!-- Locale -->
  <!--        -->
  <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />

  <!-- Content Type -->
  <!--              -->
  <wwpage:Replacement name="content-type" value="{string('text/html;charset=utf-8')}" />

  <!-- Highlight requires whitespace set to false for always highlighting part of words -->
  <!--                                                                                  -->
  <!--<wwpage:Replacement name="highlight-require-whitespace" value="{string(number($GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:MinimumWordLength/@value) > 1)}" />-->
  <wwpage:Replacement name="highlight-require-whitespace" value="false" />

  <!-- Title -->
  <!--       -->
  <wwpage:Replacement name="title" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchTabLabel']/@value}" />

  <wwpage:Replacement name="filter-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchFilterMessage']/@value}"/>

  <wwpage:Replacement name="results-count-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchResultsFound']/@value}"/>

  <wwpage:Replacement name="results-loading-message" value="{$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchResultsLoading']/@value}"/>

  <!-- Date Replacements -->
  <!--                    -->
  <xsl:variable name= "VarDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'DateFormat']/@value"/>

  <!-- Generated Date -->
  <!--                -->
  <xsl:variable name= "VarPublishDate" select="wwdatetime:GetGenerateStart($VarDateFormat)"/>
  <wwpage:Replacement name="publish-date" value="{$VarPublishDate}"/>
 </xsl:template>

 <xsl:template name="ConfigureScript">
  <!-- Configure script variables -->
  <!--                            -->
  <xsl:variable name="VarSearchJSInputPath" select="wwuri:AsFilePath('wwformat:Pages/scripts/search.js')"/>
  <xsl:variable name="VarSearchJSOutputPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'scripts', 'search.js')" />

  <xsl:variable name="VarScriptReplacementsAsXML">
   <!-- Search configuraiton -->
   <!--                      -->
   <wwmultisere:Entry match="var GLOBAL_MINIMUM_WORD_LENGTH = 0;" replacement="var GLOBAL_MINIMUM_WORD_LENGTH = {wwstring:JavaScriptEncoding($GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:MinimumWordLength/@value)};" />
   <wwmultisere:Entry match="var GLOBAL_STOP_WORDS_ARRAY = 'and or'.split(' ');" replacement="var GLOBAL_STOP_WORDS_ARRAY = '{wwstring:JavaScriptEncoding(normalize-space($GlobalLocale/wwlocale:Locale/wwlocale:Search/wwlocale:StopWords/text()))}'.split(' ');" />

   <!-- Search labels and messages -->
   <!--                            -->
   <wwmultisere:Entry match="var GLOBAL_NO_SEARCH_RESULTS_CONTAINER_HTML = '&lt;div&gt;No results for you!&lt;/div&gt;';" replacement="var GLOBAL_NO_SEARCH_RESULTS_CONTAINER_HTML = '&lt;div&gt;{wwstring:EscapeForXMLAttribute($GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'SearchNoResultsMessage']/@value)}&lt;/div&gt;';" />
  </xsl:variable>
  <xsl:variable name="VarScriptReplacements" select="msxsl:node-set($VarScriptReplacementsAsXML)/*" />

  <xsl:variable name="VarEncoding" select="string('utf-8')" />
  <xsl:variable name="VarReplaceAllInFile" select="wwmultisere:ReplaceAllInFile($VarEncoding, $VarSearchJSInputPath, $VarEncoding, $VarSearchJSOutputPath, $VarScriptReplacements)" />

  <wwfiles:File path="{$VarSearchJSOutputPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSearchJSOutputPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
   <wwfiles:Depends path="{$VarSearchJSInputPath}" checksum="{wwfilesystem:GetChecksum($VarSearchJSInputPath)}" groupID="" documentID="" />
  </wwfiles:File>
 </xsl:template>
</xsl:stylesheet>
