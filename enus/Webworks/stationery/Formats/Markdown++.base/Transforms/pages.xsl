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
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc wwdatetime html"
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
 <xsl:param name="ParameterAllowBaggage" />
 <xsl:param name="ParameterAllowGroupToGroup" />
 <xsl:param name="ParameterAllowURL" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:variable name="GlobalDefaultNamespace" select="'http://www.w3.org/1999/xhtml'" />


 <xsl:output method="html" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/accessibility/images.xsl"/>
 <xsl:include href="wwtransform:common/accessibility/tables.xsl"/>
 <xsl:include href="wwtransform:common/behaviors/options.xsl"/>
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
 <xsl:include href="wwformat:Transforms/content.xsl" />
 <xsl:include href="wwtransform:markdown/markdown_output.xsl" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl')))" />
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
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:markdown/markdown_output.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:markdown/markdown_output.xsl')))" />
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


 <!-- Project variables -->
 <!--                   -->
 <xsl:variable name="GlobalProjectVariablesPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectVariablesType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectVariables" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectVariablesPath, false())" />


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
   </xsl:call-template>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Page">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamContent" />

  <!-- Output -->
  <!--        -->
  <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($ParamSplit/@path, $GlobalProject/wwproject:Project/@ChangeID, $ParamSplit/@groupID, $ParamSplit/@documentID, $GlobalActionChecksum)" />
  <xsl:if test="not($VarUpToDate)">
   <xsl:variable name="VarResultAsXML">
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

    <!-- Keywords Markers -->
    <!--                  -->
    <xsl:variable name="VarKeywordsMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'keywords']" />

    <!-- Description Markers -->
    <!--                     -->
    <xsl:variable name="VarDescriptionMarkers" select="$VarSplitBehaviors//wwbehaviors:Marker[@behavior = 'description']" />

    <!-- Split files -->
    <!--             -->
    <xsl:for-each select="$ParamSplits[1]">

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

     <!-- Project Variables -->
     <!--                   -->
     <xsl:variable name="VarProjectVariablesAsXML" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID=wwprojext:GetFormatID()]/wwproject:Variables/wwproject:Variable"/>

     <!-- Conditions -->
     <!--            -->
     <xsl:variable name="VarInitialConditionsAsXML">
      <!-- Project Variables -->
      <!--                   -->
      <xsl:for-each select="$VarProjectVariablesAsXML">
       <wwpage:Condition name="projvars:{./@Name}"/>
      </xsl:for-each>

      <!-- Markers by name -->
      <!--                 -->
      <xsl:for-each select="$VarMarkers">
       <wwpage:Condition name="wwmarker:{./@name}" />
      </xsl:for-each>

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

      <!-- publish-date-exists -->
      <!--                    -->
      <xsl:variable name="VarPublishDateBottomGenerateOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'publish-date-bottom-generate']/@Value" />
      <xsl:if test="$VarPublishDateBottomGenerateOption = 'true'">
       <wwpage:Condition name="publish-date-exists" />
      </xsl:if>

     </xsl:variable>
     <xsl:variable name="VarInitialConditions" select="msxsl:node-set($VarInitialConditionsAsXML)" />

     <xsl:variable name="VarConditionsAsXML">
      <!-- Copy existing as is -->
      <!--                     -->
      <xsl:for-each select="$VarInitialConditions/*">
       <xsl:copy-of select="." />
      </xsl:for-each>


      <xsl:variable name="VarSplitGlobalVariablesAsXML">
       <xsl:call-template name="Variables-Globals-Split">
        <xsl:with-param name="ParamProjectVariables" select="$GlobalProjectVariables" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarSplitGlobalVariables" select="msxsl:node-set($VarSplitGlobalVariablesAsXML)/wwvars:Variable" />
      <xsl:call-template name="Variables-Page-Conditions">
       <xsl:with-param name="ParamVariables" select="$VarSplitGlobalVariables" />
      </xsl:call-template>

     </xsl:variable>
     <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

     <!-- Replacements -->
     <!--              -->
     <xsl:variable name="VarReplacementsAsXML">
      <xsl:variable name="VarRelativeRootURIWithDummyComponent" select="wwuri:GetRelativeTo(wwfilesystem:Combine($VarOutputDirectoryPath, 'dummy.component'), $ParamSplit/@path)" />
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

      <!-- Project Variables -->
      <!--                   -->
      <xsl:for-each select="$VarProjectVariablesAsXML">
       <wwpage:Replacement name="projvars:{./@Name}" value="{./@Value}"/>
      </xsl:for-each>

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


      <wwpage:Replacement name="title" value="{$ParamSplit/@title}" />

      <wwpage:Replacement name="locale" value="{wwprojext:GetFormatSetting('locale', 'en')}" />
      <wwpage:Replacement name="content-type" value="{concat('text/html;charset=', wwprojext:GetFormatSetting('encoding', 'utf-8'))}" />


      <!-- Publish Date -->
      <!--              -->
      <xsl:variable name="VarPublishDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>
      <xsl:variable name="VarPublishDate" select="wwdatetime:GetGenerateStart($VarPublishDateFormat)"/>
      <xsl:variable name="VarPublishDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateLabel']/@value"/>
      <xsl:variable name="VarFormattedPublishDate" select="wwstring:Format($VarPublishDateLabel, $VarPublishDate)"/>
      <wwpage:Replacement name="publish-date" value="{$VarFormattedPublishDate}"/>


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

      
      <!-- Content -->
      <!--         -->
      <wwpage:Replacement name="content">
       <xsl:call-template name="Content-Content">
        <xsl:with-param name="ParamContent" select="$ParamContent" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       </xsl:call-template>
       <xsl:call-template name="Content-Notes">
        <xsl:with-param name="ParamNotes" select="$VarNotes" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamUseHTML" select="false()" />
       </xsl:call-template>
      </wwpage:Replacement>

      <!-- Variables -->
      <!--           -->
      <xsl:variable name="VarSplitGlobalVariablesAsXML">
       <xsl:call-template name="Variables-Globals-Split">
        <xsl:with-param name="ParamProjectVariables" select="$GlobalProjectVariables" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
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
       <xsl:with-param name="ParamOutputPath" select="$ParamSplit/@path" />
       <xsl:with-param name="ParamConditions" select="$VarConditions" />
       <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
      </xsl:apply-templates>
     </wwexsldoc:MappingContext>
    </xsl:for-each>
   </xsl:variable>

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $ParamSplit/@path, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'fragment', '1.0', 'yes', 'yes', 'no')" />
   </xsl:if>
  </xsl:if>

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Record files -->
   <!--              -->
   <wwfiles:File path="{$ParamSplit/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplit/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplit/@groupID}" documentID="{$ParamSplit/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <wwfiles:Depends path="{$GlobalLocalePath}" checksum="{wwfilesystem:GetChecksum($GlobalLocalePath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalMapEntrySetsPath}" checksum="{wwfilesystem:GetChecksum($GlobalMapEntrySetsPath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPageTemplatePath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$GlobalProjectVariablesPath}" checksum="{wwfilesystem:GetChecksum($GlobalProjectVariablesPath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$ParamFilesDocumentNode/@path}" checksum="{$ParamFilesDocumentNode/@checksum}" groupID="{$ParamFilesDocumentNode/@groupID}" documentID="{$ParamFilesDocumentNode/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
   </wwfiles:File>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
