<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwindex wwlinks wwmode wwfiles wwdoc wwsplits wwvars wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterIndexSplitFileType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwsplits-files-by-groupid-type" match="wwsplits:File" use="concat(@groupID, ':', @type)" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
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


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Generate Index? -->
   <!--                 -->
   <xsl:if test="wwprojext:GetFormatSetting('index-generate', 'true') = 'true'">
    <!-- Iterate input documents -->
    <!--                         -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

     <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

     <xsl:for-each select="$VarFilesByType">
      <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

      <xsl:variable name="VarFilesDocument" select="." />

      <!-- Load splits -->
      <!--             -->
      <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-groupid-type', concat($VarFilesDocument/@groupID, ':', $ParameterSplitsType))[1]" />
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path)" />

      <xsl:for-each select="$VarSplits[1]">
       <!-- Split -->
       <!--       -->
       <xsl:variable name="VarSplit" select="key('wwsplits-files-by-groupid-type', concat($VarFilesDocument/@groupID, ':', $ParameterIndexSplitFileType))[1]" />

       <xsl:call-template name="Index">
        <xsl:with-param name="ParamFilesSplits" select="$VarFilesSplits" />
        <xsl:with-param name="ParamSplits" select="$VarSplits" />
        <xsl:with-param name="ParamSplit" select="$VarSplit" />
        <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
       </xsl:call-template>
      </xsl:for-each>

      <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
    </xsl:for-each>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Index">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFilesDocument" />

  <!-- Index -->
  <!--       -->
  <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path)" />

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
      <xsl:with-param name="ParamIndex" select="$VarIndex" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
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
  <xsl:param name="ParamIndex" />
  <xsl:param name="ParamSplit" />

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
  <wwpage:Replacement name="content-type" value="{concat('text/html;charset=', 'utf-8')}" />

  <!-- body-id -->
  <!--         -->
  <wwpage:Replacement name="body-id" value="id:{$ParamSplit/@groupID}" />

  <!-- index-id -->
  <!--          -->
  <wwpage:Replacement name="index-id" value="index:{$ParamSplit/@groupID}" />

  <!-- Content -->
  <!--         -->
  <wwpage:Replacement name="content">
   <xsl:call-template name="Index-JSON">
    <xsl:with-param name="ParamContent" select="$ParamIndex" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </wwpage:Replacement>
 </xsl:template>


 <xsl:template name="Index-JSON">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplit" />

  <xsl:text>&#10;</xsl:text>
  <xsl:text>{</xsl:text>

  <xsl:call-template name="Sections">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamIndex" select="$ParamContent/wwindex:Index" />
  </xsl:call-template>

  <xsl:text>&#10;</xsl:text>
  <xsl:text>}</xsl:text>

 </xsl:template>


 <xsl:template name="Sections">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamIndex" />

  <xsl:for-each select="$ParamIndex/wwindex:Section">
   <xsl:variable name="VarSection" select="." />

   <xsl:call-template name="Groups">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamSection" select="$VarSection" />
    <xsl:with-param name="ParamPosition" select="position()" />
   </xsl:call-template>

  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Groups">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSection" />
  <xsl:param name="ParamPosition" />

  <xsl:for-each select="$ParamSection/wwindex:Group">
   <xsl:variable name="VarGroup" select="." />
   <xsl:variable name="VarGroupName" select="$VarGroup/@name" />

   <xsl:if test="($ParamPosition &gt; 1) or (position() &gt; 1)">
    <xsl:text>,</xsl:text>
   </xsl:if>

   <!-- Write section property name and open containing object -->
   <!-- ex: "A": {                                             -->
   <xsl:text>&#10;</xsl:text>
   <xsl:text>"</xsl:text>
   <xsl:value-of select="$VarGroupName" />
   <xsl:text>": [</xsl:text>

   <xsl:call-template name="Entries">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamParent" select="$VarGroup" />
   </xsl:call-template>

   <xsl:text>]</xsl:text>

  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Entries">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParent" />

  <xsl:for-each select="$ParamParent/wwindex:Entry">
   <xsl:variable name="VarEntry" select="." />
   <xsl:variable name="VarEntryName" select="$VarEntry/@name" />
   <xsl:variable name="VarEntrySort" select="$VarEntry/@sort" />

   <xsl:if test="position() &gt; 1">
    <xsl:text>,</xsl:text>
   </xsl:if>

   <!-- emit entry label and containing object -->
   <!--                                        -->
   <xsl:text>{</xsl:text>

   <!-- emit entry name -->
   <!--                 -->
   <xsl:text>"name": "</xsl:text>
   <xsl:value-of select="$VarEntryName" />
   <xsl:text>"</xsl:text>

   <!-- emit entry sort -->
   <!--                 -->
   <xsl:text>,</xsl:text>
   <xsl:text>"sort": "</xsl:text>
   <xsl:value-of select="$VarEntrySort" />
   <xsl:text>"</xsl:text>

   <!-- emit entry text content -->
   <!--                         -->
   <xsl:call-template name="Content">
    <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
   </xsl:call-template>

   <!-- emit entry id -->
   <!--               -->
   <xsl:if test="$VarEntry/@id">
    <xsl:text>,</xsl:text>
    <xsl:text>"id": "ww:</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$VarEntry/@id" />
    <xsl:text>"</xsl:text>
   </xsl:if>

   <!-- emit entry type -->
   <!--                 -->
   <xsl:variable name="VarSee" select="$VarEntry/wwindex:See[1]" />
   <xsl:variable name="VarIsSee" select="count($VarSee) = 1" />
   <xsl:choose>
    <xsl:when test="$VarIsSee">
     <xsl:text>,</xsl:text>
     <xsl:text>"type": "see"</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>,</xsl:text>
     <xsl:text>"type": "entry"</xsl:text>
    </xsl:otherwise>
   </xsl:choose>

   <!-- emit entry links -->
   <!--                  -->
   <xsl:text>,</xsl:text>
   <xsl:text>"links": [</xsl:text>

   <xsl:call-template name="Entry-Links">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamEntry" select="$VarEntry" />
   </xsl:call-template>

   <xsl:text>]</xsl:text>

   <!-- emit entry children -->
   <!--                     -->
   <xsl:text>,</xsl:text>
   <xsl:text>"children": [</xsl:text>

   <xsl:call-template name="Entries">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamParent" select="$VarEntry" />
   </xsl:call-template>

   <xsl:text>]</xsl:text>
   <xsl:text>}</xsl:text>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="Entry-Links">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamEntry" />

  <xsl:variable name="VarLinks" select="$ParamEntry/wwindex:Link" />
  <xsl:if test="count($VarLinks) &gt; 0">
   <xsl:for-each select="$VarLinks">
    <xsl:variable name="VarLink" select="." />

    <xsl:if test="position() &gt; 1">
     <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>{</xsl:text>

    <xsl:variable name="VarLinkSee" select="$VarLink/wwdoc:See[1]" />
    <xsl:variable name="VarIsLinkSee" select="count($VarLinkSee) = 1" />
    <xsl:variable name="VarEntrySee" select="$ParamEntry/wwindex:See[1]" />
    <xsl:variable name="VarIsEntrySee" select="count($VarEntrySee) = 1" />
    <xsl:choose>
     <xsl:when test="$VarIsLinkSee">
      <xsl:text>"href": "#ww:</xsl:text>
      <xsl:value-of select="$ParamSplit/@groupID" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$VarLinkSee/@entryID" />
      <xsl:text>"</xsl:text>
     </xsl:when>

     <xsl:when test="$VarIsEntrySee">
      <xsl:text>"href": "#ww:</xsl:text>
      <xsl:value-of select="$ParamSplit/@groupID" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$VarEntrySee/@entryID" />
      <xsl:text>"</xsl:text>
     </xsl:when>

     <xsl:otherwise>
      <xsl:variable name="VarRelativeLinkPath">
       <xsl:call-template name="Connect-URI-GetRelativeTo">
        <xsl:with-param name="ParamDestinationURI" select="$VarLink/@href" />
        <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
       </xsl:call-template>
      </xsl:variable>

      <xsl:text>"href": "</xsl:text>
      <xsl:value-of select="$VarRelativeLinkPath" />
      <xsl:if test="$VarLink/@first != 'true'">
       <xsl:text>#ww</xsl:text>
       <xsl:value-of select="$VarLink/@anchor" />
      </xsl:if>
      <xsl:text>"</xsl:text>
     </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="count($VarLink/wwdoc:Content[1]) = 1">
     <xsl:call-template name="Content">
      <xsl:with-param name="ParamContent" select="$VarLink/wwdoc:Content[1]" />
     </xsl:call-template>
    </xsl:if>

    <xsl:text>}</xsl:text>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Content">
  <xsl:param name="ParamContent" />

  <!-- Simple processing for now -->
  <!--                           -->
  <xsl:text>,</xsl:text>
  <xsl:text>"content": "</xsl:text>
  <xsl:for-each select="$ParamContent/wwdoc:TextRun/wwdoc:Text">
   <xsl:value-of select="@value" />
  </xsl:for-each>
  <xsl:text>"</xsl:text>
 </xsl:template>
</xsl:stylesheet>
