<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwfilteredbaggage="urn:WebWorks-Filtered-Baggage-Schema"
                              exclude-result-prefixes="html xsl msxsl wwfiles wwsplits wwprogress wwlog wwfilesystem wwstring wwexsldoc wwfilteredbaggage"
		>

 <!-- Template for copying the dependences of the baggage files -->
 <!--                                                           -->
 <xsl:template name="Copy-Resource-To-Output">
  <xsl:param name="ParamResourceRelativePath"/>
  <xsl:param name="ParamBaggageFolderPathOfResources"/>
  <xsl:param name="ParamGroupOutputDirectoryPath"/>
  <xsl:param name="ParamBaggageSplitFileType"/>
  <xsl:param name="ParamBaggageGroupID"/>

  <!-- Getting the absolute resource source path -->
  <!--                                           -->
  <xsl:variable name="ParamResourceRelativeFilePath" select="wwstring:Replace($ParamResourceRelativePath, '%20', ' ')"/>
  <xsl:variable name="SourceDirectoryPath" select="wwfilesystem:Combine($ParamBaggageFolderPathOfResources, $ParamResourceRelativeFilePath)"/>

  <xsl:variable name="BaggageOutputFolderPathPrefix" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'baggage')"/>

  <xsl:variable name="ResourcePathInOutput" select="wwfilesystem:Combine($BaggageOutputFolderPathPrefix, $ParamResourceRelativeFilePath)"/>

  <wwsplits:File groupID="{$ParamBaggageGroupID}" documentID="" id="" type="{$ParamBaggageSplitFileType}" source="{$SourceDirectoryPath}" path="{$ResourcePathInOutput}" title="" />

  <xsl:if test="not(wwfilesystem:FileExists($ResourcePathInOutput))">
   <xsl:variable name="FileCopied" select="wwfilesystem:CopyFile($SourceDirectoryPath, $ResourcePathInOutput)"/>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Copy-Baggage-Files-And-Dependents">
  <xsl:param name="ParameterBaggageFiles"/>
  <xsl:param name="ParameterGroupOutputDirectoryPath"/>
  <xsl:param name="ParameterFilesByBaggageXHTMLType"/>
  <xsl:param name="ParameterGroupID"/>
  <xsl:param name="ParameterFilteredBaggagePathsFiles"/>

  <xsl:for-each select="$ParameterBaggageFiles">
   <xsl:variable name="current" select="."/>

   <!-- Getting the filtered baggage information from the FilteredBaggageFile -->
   <!--                                                                       -->
   <xsl:variable name="VarBaggageFile" select="$ParameterFilteredBaggagePathsFiles[@source=$current/@path][1]" />

   <xsl:variable name="VarPath" select="$VarBaggageFile/@output"/>

   <!-- Copying all the dependences only if the setting copy-baggage-file-dependents is Enabled -->
   <!-- and it's an HTML file and it's not an external file (URL)                               -->
   <xsl:if test="$GlobalCopyBaggageFileDependents='true' and not(wwfilesystem:GetExtension($VarBaggageFile/@sourcetolower)='.pdf') and not($VarBaggageFile/@type = $ParameterExternalType)">

    <!-- Load XHTML Content from temp file -->
    <!--                                   -->
    <xsl:variable name="TempXHTMLFilePath" select="$ParameterFilesByBaggageXHTMLType[child::wwfiles:Depends/@path=$VarBaggageFile/@source][1]/@path" />

    <xsl:variable name="VarBaggageFileContent" select="wwexsldoc:LoadXMLWithoutResolver($TempXHTMLFilePath)" />

    <xsl:variable name="BaggageFolderPathOfResources" select="wwfilesystem:Combine($VarBaggageFile/@source, '..')"/>

    <!-- Identify links in head -->
    <!--                        -->
    <xsl:variable name="VarLinksPaths" select="$VarBaggageFileContent/html:html/html:head/html:link/@href[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:link/@href=.)]" />
    <xsl:for-each select="$VarLinksPaths">
     <xsl:variable name="VarLinkPath" select="."/>
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarLinkPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify scripts in head and body -->
    <!--                                   -->
    <xsl:variable name="VarScriptsPaths" select="$VarBaggageFileContent/html:html/*//html:script/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:script/@src=.)]" />
    <xsl:for-each select="$VarScriptsPaths">
     <xsl:variable name="VarScriptPath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarScriptPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify images -->
    <!--                 -->
    <xsl:variable name="VarImagesPaths" select="$VarBaggageFileContent/html:html/*//html:img/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:img/@src=.)]" />
    <xsl:for-each select="$VarImagesPaths">
     <xsl:variable name="VarImagePath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarImagePath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify inputs -->
    <!--                 -->
    <xsl:variable name="VarInputsPaths" select="$VarBaggageFileContent/html:html/*//html:input/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:input/@src=.)]" />
    <xsl:for-each select="$VarInputsPaths">
     <xsl:variable name="VarInputPath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarInputPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify iframes -->
    <!--                 -->
    <xsl:variable name="VarIFramesPaths" select="$VarBaggageFileContent/html:html/*//html:iframe/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:iframe/@src=.)]" />
    <xsl:for-each select="$VarIFramesPaths">
     <xsl:variable name="VarIFramePath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarIFramePath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify videos -->
    <!--                 -->
    <!--It can appear as an attribute src in the tag <video> or as a child tag <source>-->
    <xsl:variable name="VarVideosPaths" select="$VarBaggageFileContent/html:html/*//html:video/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:source/@src=.)][not(preceding::html:video/@src=.)]|$VarBaggageFileContent/html:html/*//html:video/html:source/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:source/@src=.)][not(preceding::html:video/@src=.)][not(ancestor::html:video/@src=.)]" />
    <xsl:for-each select="$VarVideosPaths">
     <xsl:variable name="VarVideoPath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarVideoPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify audios -->
    <!--                 -->
    <!--It can appear as an attribute src in the tag <audio> or as a child tag <source>-->
    <xsl:variable name="VarAudiosPaths" select="$VarBaggageFileContent/html:html/*//html:audio/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:source/@src=.)][not(preceding::html:audio/@src=.)]|$VarBaggageFileContent/html:html/*//html:audio/html:source/@src[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:source/@src=.)][not(preceding::html:audio/@src=.)][not(ancestor::html:audio/@src=.)]" />
    <xsl:for-each select="$VarAudiosPaths">
     <xsl:variable name="VarAudioPath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarAudioPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

    <!-- Identify objects -->
    <!--                  -->
    <!--It should be inside the body-->
    <xsl:variable name="VarObjectsPaths" select="$VarBaggageFileContent/html:html/html:body/*//html:object/@data[not(starts-with(., 'http'))][not(starts-with(., 'javascript:'))][not(preceding::html:object/@data=.)]" />
    <xsl:for-each select="$VarObjectsPaths">
     <xsl:variable name="VarObjectPath" select="." />
     <xsl:call-template name="Copy-Resource-To-Output">
      <xsl:with-param name="ParamResourceRelativePath" select="$VarObjectPath"/>
      <xsl:with-param name="ParamBaggageFolderPathOfResources" select="$BaggageFolderPathOfResources"/>
      <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$ParameterGroupOutputDirectoryPath"/>
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType"/>
      <xsl:with-param name="ParamBaggageGroupID" select="$ParameterGroupID"/>
     </xsl:call-template>
    </xsl:for-each>

   </xsl:if>
  </xsl:for-each>
 </xsl:template>

</xsl:stylesheet>
