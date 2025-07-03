<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterSplashPageTemplateURI" />
 <xsl:param name="ParameterNotFoundPageTemplateURI" />
 <xsl:param name="ParameterParcelPageTemplateURI" />
 <xsl:param name="ParameterConnectPageTemplateURI" />
 <xsl:param name="ParameterSearchPageTemplateURI" />
 <xsl:param name="ParameterIndexPageTemplateURI" />
 <xsl:param name="ParameterUnsupportedTemplateURI" />
 <xsl:param name="ParameterHeaderTemplateURI" />
 <xsl:param name="ParameterFooterTemplateURI" />



 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/connect_utilities.xsl" />
 <xsl:include href="wwformat:Transforms/connect_files.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwpage-files-by-folder-path" match="wwpage:File" use="concat(@folder, ':', @path)" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterSplashPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterSplashPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterNotFoundPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterNotFoundPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterParcelPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterParcelPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterConnectPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterConnectPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterSearchPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterSearchPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterIndexPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterIndexPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterUnsupportedTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterUnsupportedTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterHeaderTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterHeaderTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterFooterTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterFooterTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/connect_files.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/connect_files.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Splash Page Template -->
 <!--                      -->
 <xsl:variable name="GlobalSplashPageTemplatePath" select="wwuri:AsFilePath($ParameterSplashPageTemplateURI)" />
 <xsl:variable name="GlobalSplashPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalSplashPageTemplatePath)" />

 <!-- NotFound Page Template -->
 <!--                        -->
 <xsl:variable name="GlobalNotFoundPageTemplatePath" select="wwuri:AsFilePath($ParameterNotFoundPageTemplateURI)" />
 <xsl:variable name="GlobalNotFoundPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalNotFoundPageTemplatePath)" />

 <!-- Parcel Page Template -->
 <!--                      -->
 <xsl:variable name="GlobalParcelPageTemplatePath" select="wwuri:AsFilePath($ParameterParcelPageTemplateURI)" />
 <xsl:variable name="GlobalParcelPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalParcelPageTemplatePath)" />

 <!-- Connect Page Template -->
 <!--                       -->
 <xsl:variable name="GlobalConnectPageTemplatePath" select="wwuri:AsFilePath($ParameterConnectPageTemplateURI)" />
 <xsl:variable name="GlobalConnectPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalConnectPageTemplatePath)" />

 <!-- Search Page Template -->
 <!--                      -->
 <xsl:variable name="GlobalSearchPageTemplatePath" select="wwuri:AsFilePath($ParameterSearchPageTemplateURI)" />
 <xsl:variable name="GlobalSearchPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalSearchPageTemplatePath)" />

 <!-- Index Page Template -->
 <!--                     -->
 <xsl:variable name="GlobalIndexPageTemplatePath" select="wwuri:AsFilePath($ParameterIndexPageTemplateURI)" />
 <xsl:variable name="GlobalIndexPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalIndexPageTemplatePath)" />

 <!-- Unsupported Template -->
 <!--                      -->
 <xsl:variable name="GlobalUnsupportedTemplatePath" select="wwuri:AsFilePath($ParameterUnsupportedTemplateURI)" />
 <xsl:variable name="GlobalUnsupportedTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUnsupportedTemplatePath)" />

 <!-- Header Template -->
 <!--                 -->
 <xsl:variable name="GlobalHeaderTemplatePath" select="wwuri:AsFilePath($ParameterHeaderTemplateURI)" />
 <xsl:variable name="GlobalHeaderTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalHeaderTemplatePath)" />

 <!-- Footer Template -->
 <!--                 -->
 <xsl:variable name="GlobalFooterTemplatePath" select="wwuri:AsFilePath($ParameterFooterTemplateURI)" />
 <xsl:variable name="GlobalFooterTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalFooterTemplatePath)" />

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

 
 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Combine all page template files -->
   <!--                                 -->
   <xsl:variable name="VarPageTemplateFilesAsXML">
    <xsl:apply-templates select="$GlobalSplashPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalNotFoundPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalParcelPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalConnectPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalSearchPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalIndexPageTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalUnsupportedTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalHeaderTemplate" mode="wwmode:pagetemplate-files"/>
    <xsl:apply-templates select="$GlobalFooterTemplate" mode="wwmode:pagetemplate-files"/>
   </xsl:variable>
   <xsl:variable name="VarPageTemplateFiles" select="msxsl:node-set($VarPageTemplateFilesAsXML)" />

   <xsl:call-template name="PageTemplate-CopyDependentFiles">
    <xsl:with-param name="ParamPageTemplateFiles" select="$VarPageTemplateFiles"/>
    <xsl:with-param name="ParamActionChecksum" select="$GlobalActionChecksum"/>
    <xsl:with-param name="ParamType" select="$ParameterType"/>
    <xsl:with-param name="ParamDeploy" select="$ParameterDeploy"/>
   </xsl:call-template>

   <xsl:call-template name="CopyProjectFilesToRoot" />

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="CopyProjectFilesToRoot">
  <!-- Copy "Files" folder files to root of output folder -->
  <!--                                                    -->
  <xsl:for-each select="$GlobalProjectFilesSplits//wwsplits:File">
   <xsl:variable name="VarSplitsFile" select="." />

   <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSplitsFile/@source)" />

   <xsl:variable name="VarProjectFileUpToDate" select="wwfilesext:UpToDate($VarSplitsFile/@path, '', '', '', '')" />
   <xsl:if test="not($VarProjectFileUpToDate)">
    <xsl:variable name="VarIgnore" select="wwfilesystem:CopyFile($VarSourcePath, $VarSplitsFile/@path)" />
   </xsl:if>

   <wwfiles:File path="{$VarSplitsFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSplitsFile/@path)}" projectchecksum="" groupID="" documentID="" actionchecksum="" category="" use="" deploy="{$ParameterDeploy}">
    <wwfiles:Depends path="{$VarSourcePath}" checksum="{wwfilesystem:GetChecksum($VarSourcePath)}" groupID="" documentID="" />
   </wwfiles:File>
  </xsl:for-each>
 </xsl:template>

</xsl:stylesheet>
