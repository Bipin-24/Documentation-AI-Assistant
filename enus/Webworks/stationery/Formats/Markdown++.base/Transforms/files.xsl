<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
                              xmlns:wwsass="urn:WebWorks-XSLT-Extension-Sass"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwbaggage wwpage wwlocale wwprogress wwlog 
                              wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwsass"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterBaggageType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterCopySplitFileType" />
 <xsl:param name="ParameterBaggageSplitFileType" />

 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:common/files/format.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-group-by-groupid" match="wwproject:Group" use="@GroupID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/format.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/format.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Page Template -->
 <!--               -->
 <xsl:variable name="GlobalPageTemplatePath" select="wwuri:AsFilePath($ParameterPageTemplateURI)" />
 <xsl:variable name="GlobalPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPageTemplatePath)" />


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
      <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:pagetemplate-files" />
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

     <!-- Get baggage files -->
     <!--                   -->
     <xsl:variable name="VarBaggageFilesFile" select="key('wwfiles-files-by-type', $ParameterBaggageType)[@groupID = $VarFilesDocument/@groupID][1]" />

     <!-- Determine group name -->
     <!--                      -->
     <xsl:variable name="VarReplacedGroupName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($VarFilesDocument/@groupID)" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Determine group output directory path -->
     <!--                                       -->
     <xsl:variable name="VarGroupOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

     <!-- Transform -->
     <!--           -->
     <xsl:variable name="VarProjectChecksum" select="concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarFormatFilesChecksum, ':', $VarPageTemplateFilesChecksum, ':', $VarProjectFilesChecksum)" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, $VarFilesDocument/@groupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path)" />

       <!-- Add files -->
       <!--           -->
       <xsl:call-template name="Files">
        <xsl:with-param name="ParamLocale" select="$VarLocale" />
        <xsl:with-param name="ParamGroupID" select="$VarFilesDocument/@groupID" />
        <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$VarGroupOutputDirectoryPath" />
        <xsl:with-param name="ParamFormatFiles" select="$VarFormatFiles" />
        <xsl:with-param name="ParamProjectFiles" select="$VarProjectFiles" />
        <xsl:with-param name="ParamPageTemplateFiles" select="$VarPageTemplateFiles" />
        <xsl:with-param name="ParamSplits" select="$VarSplits" />
        <xsl:with-param name="ParamBaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarBaggageFilesFile/@path)/wwbaggage:Baggage/wwbaggage:File" />
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
  <xsl:param name="ParamFormatFiles" />
  <xsl:param name="ParamProjectFiles" />
  <xsl:param name="ParamPageTemplateFiles" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBaggageFiles" />

  <!-- Copy splits with new file entries added -->
  <!--                                         -->
  <wwsplits:Splits>
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/@*" />

   <!-- Format Files -->
   <!--              -->
   <xsl:for-each select="$ParamFormatFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarFormatFile" select="." />

    <xsl:variable name="VarFormatFilePath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarFormatFile/@path)" />

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

    <xsl:variable name="VarSource" select="wwuri:AsFilePath(concat('wwformat:Pages/', $VarPageTemplateFile/@path))"/>
    <xsl:variable name="VarResultPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarPageTemplateFile/@path)"/>
    <xsl:variable name="VarSassFilePath" select="wwuri:AsFilePath(concat('wwformat:Pages/',wwfilesystem:GetDirectoryName($VarPageTemplateFile/@path), '/webworks.scss'))"/>
    <xsl:choose>
     <xsl:when test="wwprojext:GetFormatSetting('file-processing-use-sass', 'false') = 'true' and wwfilesystem:GetFileName($VarSource) = 'webworks.css' and wwfilesystem:FileExists($VarSassFilePath) = 'true'">
      <xsl:variable name="VarSassToCss" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), 'webworks.css')"/>
      <xsl:variable name="PythonResult" select="wwsass:SassToCss($VarSassFilePath, $VarSassToCss)"/>
      <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{$VarSassToCss}" path="{$VarResultPath}" title="" />
     </xsl:when>
     <xsl:otherwise>
      <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{$VarSource}" path="{$VarResultPath}" title="" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>


   <!-- Copy all existing split entries -->
   <!--                                 -->
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/wwsplits:*" />

   <!-- Baggage -->
   <!--         -->
   <xsl:for-each select="$ParamBaggageFiles">
    <xsl:variable name="VarBaggageFile" select="." />
    
    <xsl:variable name="VarPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'baggage', wwstring:ReplaceWithExpression(wwfilesystem:GetFileName($VarBaggageFile/@path), $GlobalInvalidPathCharactersExpression, '_'))" />

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterBaggageSplitFileType}" source="{$VarBaggageFile/@path}" path="{$VarPath}" title="" />
   </xsl:for-each>

   <!-- Flash Support -->
   <!--               -->
   <xsl:if test="count($ParamSplits/wwsplits:Splits/wwsplits:Split/wwsplits:Frame/wwsplits:Media[@media-type = 'webworks-video/x-flv']) &gt; 0">
    <xsl:variable name="VarFLVPlayerPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'media', 'player_flv_maxi.swf')" />

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="wwhelper:video/player_flv_maxi.swf" path="{$VarFLVPlayerPath}" title="" />
   </xsl:if>
  </wwsplits:Splits>
 </xsl:template>
</xsl:stylesheet>
