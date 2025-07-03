<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
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
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwfilteredbaggage="urn:WebWorks-Filtered-Baggage-Schema"
                              exclude-result-prefixes="html xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwbaggage wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwfilteredbaggage"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterBaggageType" />
 <xsl:param name="ParameterDependsFilteredGroupType" /><!--"baggage:filter"-->
 <xsl:param name="ParameterSearchBaggageUniqueType" /><!--"search:baggage:unique"-->
 <xsl:param name="ParameterXHTMLBaggageType" /><!--"baggage:xhtml"-->
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterPopupPageTemplateURI" />
 <xsl:param name="ParameterCopySplitFileType" />
 <xsl:param name="ParameterBaggageSplitFileType" /><!--"baggage"-->
 <xsl:param name="ParameterSplashSplitFileType" />
 <xsl:param name="ParameterParcelInfoSplitFileType" />
 <xsl:param name="ParameterIndexSplitFileType" />
 <xsl:param name="ParameterSearchSplitFileType" />
 <xsl:param name="ParameterCSSSplitFileType" />
 <xsl:param name="ParameterInternalType" /><!--"internal"-->
 <xsl:param name="ParameterExternalType" /><!--"external"-->
 <xsl:param name="ParameterSASSType" /><!--"sass:css"-->


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:common/files/format.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/baggage-files.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPopupPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPopupPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/format.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/format.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/baggage-files.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/baggage-files.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Baggage Settings -->
 <!--                  -->
 <xsl:variable name="GlobalCopyBaggageFileDependents" select="wwprojext:GetFormatSetting('copy-baggage-file-dependents')" />

 <!-- Page Template -->
 <!--               -->
 <xsl:variable name="GlobalPageTemplatePath" select="wwuri:AsFilePath($ParameterPageTemplateURI)" />
 <xsl:variable name="GlobalPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPageTemplatePath)" />

 <!-- Popup Page Template -->
 <!--                      -->
 <xsl:variable name="GlobalPopupPageTemplatePath" select="wwuri:AsFilePath($ParameterPopupPageTemplateURI)" />
 <xsl:variable name="GlobalPopupPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPopupPageTemplatePath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <!-- Load locale -->
    <!--             -->
    <xsl:variable name="VarFilesLocale" select="key('wwfiles-files-by-type', $ParameterLocaleType)" />
    <xsl:variable name="VarLocale" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesLocale/@path)" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <!-- Get format files -->
     <!--                  -->
     <xsl:variable name="VarFormatFilesAsXML">
      <xsl:call-template name="Files-Format-GetRelativeFiles">
       <xsl:with-param name="ParamRelativeURIPath" select="'Files'" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarFormatFiles" select="msxsl:node-set($VarFormatFilesAsXML)" />
     <xsl:variable name="VarFormatFilesPaths">
      <xsl:for-each select="$VarFormatFiles/wwfiles:Files/wwfiles:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarFormatFilesChecksum" select="wwstring:MD5Checksum($VarFormatFilesPaths)" />

     <!-- Get page template files -->
     <!--                         -->
     <xsl:variable name="VarPageTemplateFilesAsXML">
      <!-- Combine all page template files -->
      <!--                                 -->
      <xsl:variable name="VarPageTemplateFilesWithDuplicatesAsXML">
       <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:pagetemplate-files" />
       <xsl:apply-templates select="$GlobalPopupPageTemplate" mode="wwmode:pagetemplate-files" />
      </xsl:variable>
      <xsl:variable name="VarPageTemplateFilesWithDuplicates" select="msxsl:node-set($VarPageTemplateFilesWithDuplicatesAsXML)" />

      <!-- Eliminate duplicates -->
      <!--                      -->
      <xsl:for-each select="$VarPageTemplateFilesWithDuplicates/wwpage:File">
       <xsl:variable name="VarPageTemplateFile" select="." />

       <xsl:variable name="VarPageTemplateFilesWithPath" select="key('wwpage-files-by-path', $VarPageTemplateFile/@path)" />
       <xsl:if test="count($VarPageTemplateFilesWithPath[1] | $VarPageTemplateFile) = 1">
        <xsl:copy-of select="$VarPageTemplateFile" />
       </xsl:if>
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarPageTemplateFiles" select="msxsl:node-set($VarPageTemplateFilesAsXML)" />
     <xsl:variable name="VarPageTemplateFilesPaths">
      <xsl:for-each select="$VarPageTemplateFiles/wwpage:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarPageTemplateFilesChecksum" select="wwstring:MD5Checksum($VarPageTemplateFilesPaths)" />

     <!-- Get project files -->
     <!--                   -->
     <xsl:variable name="VarProjectFiles" select="wwfilesystem:GetFiles(wwprojext:GetProjectFilesDirectoryPath())" />
     <xsl:variable name="VarProjectFilesPaths">
      <xsl:for-each select="$VarProjectFiles/wwfiles:Files/wwfiles:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarProjectFilesChecksum" select="wwstring:MD5Checksum($VarProjectFilesPaths)" />
     <xsl:variable name="VarProjectChecksum" select="concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarFormatFilesChecksum, ':', $VarPageTemplateFilesChecksum, ':', $VarProjectFilesChecksum)" />

     <!-- Get baggage files -->
     <!--                   -->
     <xsl:variable name="VarBaggageFilesFile" select="key('wwfiles-files-by-type', $ParameterBaggageType)[@groupID = $VarFilesDocument/@groupID][1]" />

     <!-- Determine group name -->
     <!--                      -->
     <xsl:variable name="VarGroupName" select="wwprojext:GetGroupName($VarFilesDocument/@groupID)" />

     <!-- Determine group output directory path -->
     <!--                                       -->
     <xsl:variable name="VarReplacedGroupName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarGroupName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarGroupOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

     <!-- Transform -->
     <!--           -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, $VarFilesDocument/@groupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path)" />
       <xsl:variable name="VarParamBaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarBaggageFilesFile/@path)/wwbaggage:Baggage/wwbaggage:File" />

       <!-- Add files -->
       <!--           -->
       <xsl:call-template name="Files">
        <xsl:with-param name="ParamLocale" select="$VarLocale" />
        <xsl:with-param name="ParamGroupID" select="$VarFilesDocument/@groupID" />
        <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$VarGroupOutputDirectoryPath" />
        <xsl:with-param name="ParamGroupName" select="$VarGroupName" />
        <xsl:with-param name="ParamFormatFiles" select="$VarFormatFiles" />
        <xsl:with-param name="ParamProjectFiles" select="$VarProjectFiles" />
        <xsl:with-param name="ParamPageTemplateFiles" select="$VarPageTemplateFiles" />
        <xsl:with-param name="ParamSplits" select="$VarSplits" />
        <xsl:with-param name="ParamBaggageFiles" select="$VarParamBaggageFiles" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <!-- Report Files -->
     <!--              -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$VarProjectChecksum}" groupID="{$VarFilesDocument/@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="" use="">
      <wwfiles:Depends path="{$VarFilesLocale/@path}" checksum="{$VarFilesLocale/@checksum}" groupID="{$VarFilesLocale/@groupID}" documentID="{$VarFilesLocale/@documentID}" />
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
      <wwfiles:Depends path="{$VarBaggageFilesFile/@path}" checksum="{$VarBaggageFilesFile/@checksum}" groupID="{$VarBaggageFilesFile/@groupID}" documentID="{$VarBaggageFilesFile/@documentID}" />
      <wwfiles:Depends path="{$GlobalPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPageTemplatePath)}" groupID="" documentID="" />
      <wwfiles:Depends path="{$GlobalPopupPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPopupPageTemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Files">
  <xsl:param name="ParamLocale" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamGroupOutputDirectoryPath" />
  <xsl:param name="ParamGroupName" />
  <xsl:param name="ParamFormatFiles" />
  <xsl:param name="ParamProjectFiles" />
  <xsl:param name="ParamPageTemplateFiles" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBaggageFiles" />

  <!-- Book title -->
  <!--            -->
  <xsl:variable name="VarBookTitle">
   <xsl:call-template name="Connect-BookTitle">
    <xsl:with-param name="ParamProject" select="$GlobalProject" />
    <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarFilesByBaggageXHTMLType" select="key('wwfiles-files-by-type', $ParameterXHTMLBaggageType)" />
  <xsl:variable name="VarPageTemplateSASSFiles" select="key('wwfiles-files-by-type', $ParameterSASSType)" />

  <!-- Copy splits with new file entries added -->
  <!--                                         -->
  <wwsplits:Splits>
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/@*" />

   <!-- Format Files -->
   <!--              -->
   <xsl:for-each select="$ParamFormatFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarFormatFile" select="." />

    <xsl:variable name="VarConnectRelativeFormatFilePath">
     <xsl:call-template name="Connect-File-Path">
      <xsl:with-param name="ParamPath" select="$VarFormatFile/@path" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarFormatFilePath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarConnectRelativeFormatFilePath)" />

    <!-- Allow? -->
    <!--        -->
    <xsl:variable name="VarAllow">
     <xsl:call-template name="Files-Filter-Allow">
      <xsl:with-param name="ParamPath" select="$VarFormatFilePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$VarAllow = 'true'">
     <!-- Emit -->
     <!--      -->
     <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{wwuri:MakeAbsolute('wwformat:Files/', $VarFormatFile/@path)}" path="{$VarFormatFilePath}" title="" />
    </xsl:if>
   </xsl:for-each>

   <!-- Page Template Files -->
   <!--                     -->
   <xsl:for-each select="$ParamPageTemplateFiles/wwpage:File">
    <xsl:variable name="VarPageTemplateFile" select="." />

    <xsl:variable name="VarConnectRelativePageTemplateFilePath">
     <xsl:call-template name="Connect-File-Path">
      <xsl:with-param name="ParamPath" select="$VarPageTemplateFile/@path" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="VarSourcePath">
     <xsl:variable name="VarMatchedFilePath" select="$VarPageTemplateSASSFiles[wwfilesystem:GetFileName(@path)=wwfilesystem:GetFileName($VarPageTemplateFile/@path)]/@path" />
     <xsl:choose>
      <xsl:when test="not($VarMatchedFilePath)">
       <xsl:value-of select="concat('wwformat:Pages/', $VarPageTemplateFile/@path)"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$VarMatchedFilePath"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <xsl:variable name="VarOutputPath">
     <xsl:choose>
      <xsl:when test="./@output-relative = 'root'">
       <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), $VarConnectRelativePageTemplateFilePath)"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarConnectRelativePageTemplateFilePath)"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{$VarSourcePath}" path="{$VarOutputPath}" title="" />
   </xsl:for-each>

   <!-- Parcel Info -->
   <!--             -->
   <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterParcelInfoSplitFileType}" source="" path="{$ParamGroupOutputDirectoryPath}.html" title="{$VarBookTitle}" />

   <!-- Reprocess existing split entries -->
   <!--                                  -->
   <xsl:apply-templates select="$ParamSplits/wwsplits:Splits/wwsplits:*" mode="wwmode:reprocess-splits">
    <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParamGroupOutputDirectoryPath" />
   </xsl:apply-templates>

   <!-- Index -->
   <!--       -->
   <xsl:if test="wwprojext:GetFormatSetting('index-generate', 'true') = 'true'">
    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterIndexSplitFileType}" source="" path="{$ParamGroupOutputDirectoryPath}_ix.html" title="{$ParamLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTitle']/@value}" />
   </xsl:if>

   <!-- Search -->
   <!--        -->
   <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterSearchSplitFileType}" source="" path="{$ParamGroupOutputDirectoryPath}_sx.js" />


   <!-- Project Files -->
   <!--               -->
   <xsl:variable name="VarProjectFilesDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), 'dummy.component')" />
   <xsl:for-each select="$ParamProjectFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarProjectFile" select="." />

    <xsl:variable name="VarRelativePath" select="wwfilesystem:GetRelativeTo($VarProjectFile/@path, $VarProjectFilesDirectoryPath)" />
    <xsl:variable name="VarRelativeURI" select="wwuri:GetRelativeTo($VarProjectFile/@path, 'wwprojfile:dummy.component')" />
    <xsl:variable name="VarConnectRelativePath">
     <xsl:call-template name="Connect-File-Path">
      <xsl:with-param name="ParamPath" select="$VarRelativePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarProjectFilePath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarConnectRelativePath)" />

    <!-- Allow? -->
    <!--        -->
    <xsl:variable name="VarAllow">
     <xsl:call-template name="Files-Filter-Allow">
      <xsl:with-param name="ParamPath" select="$VarProjectFilePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$VarAllow = 'true'">
     <!-- Emit -->
     <!--      -->
     <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{concat('wwprojfile:', $VarRelativeURI)}" path="{$VarProjectFilePath}" title="" />
    </xsl:if>
   </xsl:for-each>

   <!-- CSS Stylesheets -->
   <!--                 -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDocumentType)[@groupID = $ParamGroupID]" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocumentNode" select="." />

     <!-- CSS Path -->
     <!--          -->
     <xsl:variable name="VarReplacedDocumentGroupPath">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($VarFilesDocumentNode/@documentID)" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarOutputDocumentDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedDocumentGroupPath, $GlobalInvalidPathCharactersExpression, '_'))" />

     <xsl:variable name="VarRelativePath" select="wwfilesystem:GetRelativeTo($VarOutputDocumentDirectoryPath, wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'dummy.file'))" />
     <xsl:variable name="VarConnectRelativePath">
      <xsl:call-template name="Connect-File-Path">
       <xsl:with-param name="ParamPath" select="$VarRelativePath" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarConnectRelativePath)" />

     <xsl:variable name="VarBaseFileName" select="wwfilesystem:GetFileNameWithoutExtension(wwprojext:GetDocumentPath($VarFilesDocumentNode/@documentID))" />
     <xsl:variable name="VarConnectBaseFileName">
      <xsl:call-template name="Connect-File-Path">
       <xsl:with-param name="ParamPath" select="$VarBaseFileName" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:variable name="VarCasedBaseFileName">
      <xsl:call-template name="ConvertNameTo">
       <xsl:with-param name="ParamText" select="$VarConnectBaseFileName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarReplacedConnectBaseFileName">
      <xsl:call-template name="ReplaceFileNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarCasedBaseFileName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'css', concat(wwstring:ReplaceWithExpression($VarReplacedConnectBaseFileName, $GlobalInvalidPathCharactersExpression, '_'), '.css'))" />

     <wwsplits:File groupID="{$ParamGroupID}" documentID="{$VarFilesDocumentNode/@documentID}" id="" type="{$ParameterCSSSplitFileType}" source="" path="{$VarPath}" title="" />
    </xsl:for-each>
   </xsl:for-each>

   <!-- Baggage -->
   <!--         -->
   <xsl:variable name="VarFilteredFilePath" select="key('wwfiles-files-by-type', $ParameterDependsFilteredGroupType)[@groupID=$ParamGroupID][1]/@path" />
   <xsl:variable name="VarFilteredBaggagePathsFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarFilteredFilePath)/wwfilteredbaggage:Baggage/wwfilteredbaggage:File" />

   <!-- Despite if Standalone-Group is On or Off we need to add the baggage entries to the split files -->
   <!-- so it can be seen in the Output of every split                                                 -->
   <xsl:for-each select="$ParamBaggageFiles">
    <xsl:variable name="VarBaggageFile" select="." />
    <xsl:variable name="VarBaggageFilteredFile" select="$VarFilteredBaggagePathsFiles[@source=$VarBaggageFile/@path][1]" />
    <xsl:if test="$VarBaggageFilteredFile/@output and not($ParameterExternalType = $VarBaggageFilteredFile/@type)">
     <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterBaggageSplitFileType}" source="{$VarBaggageFile/@path}" path="{$VarBaggageFilteredFile/@output}" title="" />
    </xsl:if>
   </xsl:for-each>

   <!-- Copy all the dependents of the baggage files to every corresponding group -->
   <!--                                                                           -->
   <xsl:call-template name="Copy-Baggage-Files-And-Dependents">
    <xsl:with-param name="ParameterBaggageFiles" select="$ParamBaggageFiles"/>
    <xsl:with-param name="ParameterGroupOutputDirectoryPath" select="$ParamGroupOutputDirectoryPath"/>
    <xsl:with-param name="ParameterFilesByBaggageXHTMLType" select="$VarFilesByBaggageXHTMLType"/>
    <xsl:with-param name="ParameterGroupID" select="$ParamGroupID"/>
    <xsl:with-param name="ParameterFilteredBaggagePathsFiles" select="$VarFilteredBaggagePathsFiles"/>
   </xsl:call-template>

   <!-- Flash Support -->
   <!--               -->
   <xsl:if test="count($ParamSplits/wwsplits:Splits/wwsplits:Split/wwsplits:Frame/wwsplits:Media[@media-type = 'webworks-video/x-flv']) &gt; 0">
    <xsl:variable name="VarFLVPlayerPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'media', 'player_flv_maxi.swf')" />

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="wwhelper:video/player_flv_maxi.swf" path="{$VarFLVPlayerPath}" title="" />
   </xsl:if>
  </wwsplits:Splits>
 </xsl:template>


 <!-- wwmode:reprocess-splits -->
 <!--                         -->

 <xsl:template match="wwsplits:*" mode="wwmode:reprocess-splits">
  <xsl:param name="ParamSplitsEntry" select="." />
  <xsl:param name="ParamGroupOutputDirectoryPath" />

  <!-- Reset output path -->
  <!--                   -->
  <xsl:variable name="VarOutputPath">
   <xsl:variable name="VarRelativePath" select="wwfilesystem:GetRelativeTo($ParamSplitsEntry/@path, wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'dummy.file'))" />
   <xsl:variable name="VarConnectRelativePath">
    <xsl:call-template name="Connect-File-Path">
     <xsl:with-param name="ParamPath" select="$VarRelativePath" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:value-of select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarConnectRelativePath)" />
  </xsl:variable>

  <!-- Emit element with updated path -->
  <!--                                -->
  <xsl:copy>
   <xsl:copy-of select="$ParamSplitsEntry/@*[local-name() != 'path']" />
   <xsl:attribute name="path">
    <xsl:value-of select="$VarOutputPath" />
   </xsl:attribute>

   <!-- Search pairs file -->
   <!--                   -->
   <xsl:if test="local-name($ParamSplitsEntry) = 'Split'">
    <xsl:variable name="VarSplitSearchPairsPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, concat('pairs\pair', $ParamSplitsEntry/@position, '.js'))" />

    <wwsplits:SearchPairs path="{$VarSplitSearchPairsPath}" />
   </xsl:if>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:reprocess-splits">
    <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParamGroupOutputDirectoryPath" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:reprocess-splits">
  <xsl:param name="ParamGroupOutputDirectoryPath" />

  <!-- Preserve as is -->
  <!--                -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:reprocess-splits">
    <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParamGroupOutputDirectoryPath" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:reprocess-splits">
  <xsl:param name="ParamGroupOutputDirectoryPath" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
