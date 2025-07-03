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
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterSplitFileType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-files-by-groupid-type" match="wwsplits:File" use="concat(@groupID, ':', @type)" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <!-- Baggage Settings -->
 <!--                  -->
 <xsl:variable name="GlobalCreateStandaloneGroup" select="wwprojext:GetFormatSetting('create-standalone-group')" />

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Copy the files only if the StandaloneGroup is OFF (and if it's ON then make sure we don't copy the baggage files) -->
   <!--                                                                                                                   -->
   <xsl:if test="not($GlobalCreateStandaloneGroup = 'true') or not($ParameterSplitFileType = 'baggage')">
    <!-- Get splits info -->
    <!--                 -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

     <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

     <xsl:for-each select="$VarFilesByType">
      <xsl:variable name="VarFilesNode" select="." />

      <xsl:value-of select="wwprogress:Start(1)" />

      <!-- Load splits -->
      <!--             -->
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesNode/@path, false())" />

      <xsl:for-each select="$VarSplits[1]">
       <!-- Copy files -->
       <!--            -->
       <xsl:variable name="VarCopyFiles" select="key('wwsplits-files-by-groupid-type', concat($VarFilesNode/@groupID, ':', $ParameterSplitFileType))" />
       <xsl:value-of select="wwprogress:Start(count($VarCopyFiles))" />
       <xsl:for-each select="$VarCopyFiles">
        <xsl:variable name="VarCopyFile" select="." />

        <xsl:value-of select="wwprogress:Start(1)" />

        <!-- Get source and destination paths -->
        <!--                                  -->
        <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarCopyFile/@source)" />
        <xsl:variable name="VarDestinationPath" select="string($VarCopyFile[1]/@path)" />

        <!-- Copy -->
        <!--      -->
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarDestinationPath, '', $VarFilesNode/@groupID, '', concat($GlobalActionChecksum, ':', $VarSourcePath))" />
        <xsl:if test="not($VarUpToDate)">
         <xsl:variable name="VarIgnore" select="wwfilesystem:CopyFile($VarSourcePath, $VarDestinationPath)" />
        </xsl:if>

        <!-- Report Files -->
        <!--              -->
        <wwfiles:File path="{$VarDestinationPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarDestinationPath)}" projectchecksum="" groupID="{$VarFilesNode/@groupID}" documentID="" actionchecksum="{concat($GlobalActionChecksum, ':', $VarSourcePath)}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <wwfiles:Depends path="{$VarSourcePath}" checksum="{wwfilesystem:GetChecksum($VarSourcePath)}" groupID="{$VarFilesNode/@groupID}" documentID="" />
        </wwfiles:File>

        <xsl:value-of select="wwprogress:End()" />
       </xsl:for-each>
       <xsl:value-of select="wwprogress:End()" />

      </xsl:for-each>

      <xsl:value-of select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>
   </xsl:if>
  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
