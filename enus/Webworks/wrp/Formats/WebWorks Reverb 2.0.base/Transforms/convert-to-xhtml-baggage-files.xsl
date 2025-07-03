<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Baggage-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              xmlns:wwfilteredbaggage="urn:WebWorks-Filtered-Baggage-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwproject wwbaggage wwfilteredbaggage wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwlocale"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsGroupType" /><!-- baggage:group -->
 <xsl:param name="ParameterDependsFilteredGroupType" /><!-- baggage:filter -->
 <xsl:param name="ParameterType" /><!-- baggage:xhtml -->
 <xsl:param name="ParameterInternalType" /><!--"internal"-->
 <xsl:param name="ParameterExternalType" /><!--"external"-->
 <xsl:param name="ParameterUILocaleType" /><!--uilocale:project-->


 <xsl:namespace-alias stylesheet-prefix="wwbaggage" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />

 <xsl:variable name="VarTidyPath" select="wwuri:AsFilePath('wwhelper:tidy/tidy.exe')" />
 <xsl:variable name="VarTidyConfigFilePath" select="wwuri:AsFilePath('wwhelper:tidy/config.txt')" />
 <xsl:variable name="GlobalCopyBaggageFileDependents" select="wwprojext:GetFormatSetting('copy-baggage-file-dependents')" />

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Get Filtered Files -->
   <!--                     -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFileteredFiles" select="key('wwfiles-files-by-type', $ParameterDependsFilteredGroupType)" />
    <xsl:for-each select="$VarFileteredFiles">
     <xsl:variable name="VarFileteredFile" select="." />

     <xsl:variable name="VarGroupID" select="$VarFileteredFile/@groupID"/>
     <xsl:variable name="VarDataGroupPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(),$VarGroupID)"/>
     <xsl:variable name="BaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarFileteredFile/@path)/wwfilteredbaggage:Baggage/wwfilteredbaggage:File" />

     <xsl:call-template name="Analyze-Baggage-Files-In-Group">
      <xsl:with-param name="ParamBaggageFiles" select="$BaggageFiles"/>
      <xsl:with-param name="ParamDataGroupPath" select="$VarDataGroupPath"/>
      <xsl:with-param name="ParamBaggageFilesCount" select="count($BaggageFiles)"/>
      <xsl:with-param name="ParamGroupID" select="$VarGroupID"/>
     </xsl:call-template>

    </xsl:for-each>
   </xsl:for-each>
  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Analyze-Baggage-Files-In-Group">
  <xsl:param name="ParamBaggageFiles"/>
  <xsl:param name="ParamDataGroupPath"/>
  <xsl:param name="ParamBaggageFilesCount"/>
  <xsl:param name="ParamGroupID"/>

  <xsl:for-each select="$ParamBaggageFiles[$GlobalCopyBaggageFileDependents='true' or @index='true']">
   <xsl:variable name="BaggageFile" select="." />

   <xsl:if test="wwfilesystem:FileExists($BaggageFile/@source) and ((wwfilesystem:GetExtension($BaggageFile/@source)='.html') or (wwfilesystem:GetExtension($BaggageFile/@source)='.htm') or (wwfilesystem:GetExtension($BaggageFile/@source)='.shtml') or (wwfilesystem:GetExtension($BaggageFile/@source)='.shtm') or (wwfilesystem:GetExtension($BaggageFile/@source)='.xhtml') or (wwfilesystem:GetExtension($BaggageFile/@source)='.xhtm'))">
    <xsl:variable name="TempXHTMLFilePath" select="concat(wwfilesystem:Combine($ParamDataGroupPath, wwfilesystem:GetFileName($BaggageFile/@source)),'.xhtml.temp')"/>
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($TempXHTMLFilePath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', $ParamBaggageFilesCount), $ParamGroupID, '', $GlobalActionChecksum)" />

    <xsl:variable name="VarTidyOutputResult">
     <xsl:if test="not($VarUpToDate)">
      <!-- Create XHTML File from the HTML baggage file -->
      <!--                                              -->
      <xsl:value-of select="wwexec:ExecuteCommand($VarTidyPath, '-config', $VarTidyConfigFilePath, '-o', $TempXHTMLFilePath, $BaggageFile/@source)" />
     </xsl:if>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="string-length(normalize-space($VarTidyOutputResult)) &gt; 0">
      <!-- File doesn't exist -->
      <!--                    -->
      <xsl:variable name="VarPath">
       <xsl:choose>
        <xsl:when test="$BaggageFile/@type = $ParameterInternalType">
         <xsl:value-of select="$BaggageFile/@source"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="$BaggageFile/@url"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <!-- Tidy failed to process the file -->
      <!--                                 -->
      <xsl:variable name="VarUnableToProcessFile" select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogUnableToProcessFile']/@value, $VarPath, $VarTidyOutputResult)"/>
      <xsl:variable name="UnableToProcessFile" select="wwlog:Warning($VarUnableToProcessFile)"/>
     </xsl:when>
     <xsl:otherwise>
      <wwfiles:File path="{$TempXHTMLFilePath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($TempXHTMLFilePath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', $ParamBaggageFilesCount)}" groupID="{$ParamGroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="" use="">
       <wwfiles:Depends path="{$BaggageFile/@source}" checksum="{wwfilesystem:GetChecksum($BaggageFile/@source)}" groupID="{$BaggageFile/@groupID}" documentID="{$BaggageFile/@documentID}" />
      </wwfiles:File>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>

  </xsl:for-each>

 </xsl:template>
</xsl:stylesheet>
