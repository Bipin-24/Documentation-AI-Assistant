<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwmultisere="urn:WebWorks-XSLT-Extension-MultiSearchReplace"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc wwexec wwenv wwlocale wwmultisere"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Generate WebWorks Help compatible API files? -->
   <!--                                              -->
   <xsl:variable name="VarConnectAPIWWHelpSetting" select="wwprojext:GetFormatSetting('connect-api-wwhelp')" />
   <xsl:if test="$VarConnectAPIWWHelpSetting = 'true'">
    <!-- Mark of the Web (MOTW) -->
    <!--                        -->
    <xsl:variable name="VarEnableMOTW" select="wwprojext:GetFormatSetting('file-processing-mark-of-the-web') = 'true'" />

    <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
    <xsl:variable name="VarProgressGroupsAndMergeStart" select="wwprogress:Start(count($VarProjectGroups) + 1)" />

    <!-- Locate template -->
    <!--                 -->
    <xsl:variable name="VarAPITemplatePath" select="wwuri:AsFilePath('wwformat:API/wwhelp/wwhimpl/api.htm')" />
    <xsl:variable name="VarAPIJSTemplatePath" select="wwuri:AsFilePath('wwformat:API/wwhelp/wwhimpl/api.js')" />
    <xsl:variable name="VarCommonTemplatePath" select="wwuri:AsFilePath('wwformat:API/wwhelp/wwhimpl/common/html/wwhelp.htm')" />
    <xsl:variable name="VarJSTemplatePath" select="wwuri:AsFilePath('wwformat:API/wwhelp/wwhimpl/js/html/wwhelp.htm')" />

    <!-- Create entry point per group -->
    <!--                              -->
    <xsl:for-each select="$VarProjectGroups">
     <xsl:variable name="VarProjectGroup" select="." />

     <xsl:variable name="VarProgressGroupStart" select="wwprogress:Start(1)" />

     <!-- Determine group name -->
     <!--                      -->
     <xsl:variable name="VarGroupName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($VarProjectGroup/@GroupID)" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Determine group output directory path -->
     <!--                                       -->
     <xsl:variable name="VarGroupOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarAPIPath" select="wwfilesystem:Combine($VarGroupOutputDirectoryPath, 'wwhelp', 'wwhimpl', 'api.htm')" />
     <xsl:variable name="VarAPIUpToDate" select="wwfilesext:UpToDate($VarAPIPath, $GlobalProject/wwproject:Project/@ChangeID, $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarAPIUpToDate)">
      <xsl:call-template name="API-WWHelp">
       <xsl:with-param name="ParamAPITemplatePath" select="$VarAPITemplatePath" />
       <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../', wwprojext:GetFormatSetting('connect-entry'))" />
       <xsl:with-param name="ParamAPITargetPath" select="$VarAPIPath" />
       <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
      </xsl:call-template>
     </xsl:if>
     <xsl:variable name="VarAPIJSPath" select="wwfilesystem:Combine($VarGroupOutputDirectoryPath, 'wwhelp', 'wwhimpl', 'api.js')" />
     <xsl:variable name="VarAPIJSUpToDate" select="wwfilesext:UpToDate($VarAPIJSPath, $GlobalProject/wwproject:Project/@ChangeID, $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarAPIJSUpToDate)">
      <xsl:call-template name="API-WWHelp">
       <xsl:with-param name="ParamAPITemplatePath" select="$VarAPIJSTemplatePath" />
       <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../', wwprojext:GetFormatSetting('connect-entry'))" />
       <xsl:with-param name="ParamAPITargetPath" select="$VarAPIJSPath" />
       <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
      </xsl:call-template>
     </xsl:if>
     <xsl:variable name="VarCommonPath" select="wwfilesystem:Combine($VarGroupOutputDirectoryPath, 'wwhelp', 'wwhimpl', 'common', 'html', 'wwhelp.htm')" />
     <xsl:variable name="VarCommonUpToDate" select="wwfilesext:UpToDate($VarCommonPath, $GlobalProject/wwproject:Project/@ChangeID, $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarCommonUpToDate)">
      <xsl:call-template name="API-WWHelp">
       <xsl:with-param name="ParamAPITemplatePath" select="$VarCommonTemplatePath" />
       <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../../../', wwprojext:GetFormatSetting('connect-entry'))" />
       <xsl:with-param name="ParamAPITargetPath" select="$VarCommonPath" />
       <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
      </xsl:call-template>
     </xsl:if>
     <xsl:variable name="VarJSPath" select="wwfilesystem:Combine($VarGroupOutputDirectoryPath, 'wwhelp', 'wwhimpl', 'js', 'html', 'wwhelp.htm')" />
     <xsl:variable name="VarJSUpToDate" select="wwfilesext:UpToDate($VarJSPath, $GlobalProject/wwproject:Project/@ChangeID, $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarJSUpToDate)">
      <xsl:call-template name="API-WWHelp">
       <xsl:with-param name="ParamAPITemplatePath" select="$VarJSTemplatePath" />
       <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../../../', wwprojext:GetFormatSetting('connect-entry'))" />
       <xsl:with-param name="ParamAPITargetPath" select="$VarJSPath" />
       <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
      </xsl:call-template>
     </xsl:if>

     <wwfiles:File path="{$VarAPIPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarAPIPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarAPITemplatePath}" checksum="{wwfilesystem:GetChecksum($VarAPITemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>
     <wwfiles:File path="{$VarAPIJSPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarAPIPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarAPIJSTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarAPIJSTemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>
     <wwfiles:File path="{$VarCommonPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarCommonPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarCommonTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarCommonTemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>
     <wwfiles:File path="{$VarJSPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarJSPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarJSTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarJSTemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>

     <xsl:variable name="VarProgressGroupEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <!-- Create entry point for combined output -->
    <!--                                        -->
    <xsl:variable name="VarProgressMergeStart" select="wwprogress:Start(1)" />

    <!-- Up to date? -->
    <!--             -->
    <xsl:variable name="VarMergeAPIPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'wwhelp', 'wwhimpl', 'api.htm')" />
    <xsl:variable name="VarMergeAPIUpToDate" select="wwfilesext:UpToDate($VarMergeAPIPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarMergeAPIUpToDate)">
     <xsl:call-template name="API-WWHelp">
      <xsl:with-param name="ParamAPITemplatePath" select="$VarAPITemplatePath" />
      <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../', wwprojext:GetFormatSetting('connect-entry'))" />
      <xsl:with-param name="ParamAPITargetPath" select="$VarMergeAPIPath" />
      <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
     </xsl:call-template>
    </xsl:if>
    <xsl:variable name="VarMergeAPIJSPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'wwhelp', 'wwhimpl', 'api.js')" />
    <xsl:variable name="VarMergeAPIJSUpToDate" select="wwfilesext:UpToDate($VarMergeAPIJSPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarMergeAPIJSUpToDate)">
     <xsl:call-template name="API-WWHelp">
      <xsl:with-param name="ParamAPITemplatePath" select="$VarAPIJSTemplatePath" />
      <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../', wwprojext:GetFormatSetting('connect-entry'))" />
      <xsl:with-param name="ParamAPITargetPath" select="$VarMergeAPIJSPath" />
      <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
     </xsl:call-template>
    </xsl:if>
    <xsl:variable name="VarMergeCommonPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'wwhelp', 'wwhimpl', 'common', 'html', 'wwhelp.htm')" />
    <xsl:variable name="VarMergeCommonUpToDate" select="wwfilesext:UpToDate($VarMergeCommonPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarMergeCommonUpToDate)">
     <xsl:call-template name="API-WWHelp">
      <xsl:with-param name="ParamAPITemplatePath" select="$VarCommonTemplatePath" />
      <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../../', wwprojext:GetFormatSetting('connect-entry'))" />
      <xsl:with-param name="ParamAPITargetPath" select="$VarMergeCommonPath" />
      <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
     </xsl:call-template>
    </xsl:if>
    <xsl:variable name="VarMergeJSPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'wwhelp', 'wwhimpl', 'js', 'html', 'wwhelp.htm')" />
    <xsl:variable name="VarMergeJSUpToDate" select="wwfilesext:UpToDate($VarMergeJSPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarMergeJSUpToDate)">
     <xsl:call-template name="API-WWHelp">
      <xsl:with-param name="ParamAPITemplatePath" select="$VarJSTemplatePath" />
      <xsl:with-param name="ParamRelativeEntryPath" select="concat('../../../../', wwprojext:GetFormatSetting('connect-entry'))" />
      <xsl:with-param name="ParamAPITargetPath" select="$VarMergeJSPath" />
      <xsl:with-param name="ParamEnableMOTW" select="$VarEnableMOTW" />
     </xsl:call-template>
    </xsl:if>

    <wwfiles:File path="{$VarMergeAPIPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarMergeAPIPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
     <wwfiles:Depends path="{$VarAPITemplatePath}" checksum="{wwfilesystem:GetChecksum($VarAPITemplatePath)}" groupID="" documentID="" />
    </wwfiles:File>
    <wwfiles:File path="{$VarMergeAPIJSPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarMergeAPIJSPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
     <wwfiles:Depends path="{$VarAPIJSTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarAPIJSTemplatePath)}" groupID="" documentID="" />
    </wwfiles:File>
    <wwfiles:File path="{$VarMergeCommonPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarMergeCommonPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
     <wwfiles:Depends path="{$VarCommonTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarCommonTemplatePath)}" groupID="" documentID="" />
    </wwfiles:File>
    <wwfiles:File path="{$VarMergeJSPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarMergeJSPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
     <wwfiles:Depends path="{$VarJSTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarJSTemplatePath)}" groupID="" documentID="" />
    </wwfiles:File>

    <xsl:variable name="VarProgressMergeEnd" select="wwprogress:End()" />

    <xsl:variable name="VarProgressGroupsAndMergeEnd" select="wwprogress:End()" />
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="API-WWHelp">
  <xsl:param name="ParamAPITemplatePath" />
  <xsl:param name="ParamRelativeEntryPath" />
  <xsl:param name="ParamAPITargetPath" />
  <xsl:param name="ParamEnableMOTW" />

  <xsl:variable name="VarReplacementsAsXML">
   <xsl:if test="$ParamEnableMOTW">
    <wwmultisere:Entry match=" MOTW-DISABLED saved from url=(0014)about:internet " replacement=" saved from url=(0016)http://localhost " />
   </xsl:if>
   <wwmultisere:Entry match="../../index.html" replacement="{$ParamRelativeEntryPath}" />
   <wwmultisere:Entry match="../../../../index.html" replacement="{$ParamRelativeEntryPath}" />
  </xsl:variable>
  <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)/*" />
  <xsl:value-of select="wwmultisere:ReplaceAllInFile('UTF-8', $ParamAPITemplatePath, 'utf-8', $ParamAPITargetPath, $VarReplacements)" />
 </xsl:template>
</xsl:stylesheet>

