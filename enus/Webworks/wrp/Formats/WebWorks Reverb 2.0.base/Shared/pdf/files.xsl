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
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSinglePDFSplitFileType" />
 <xsl:param name="ParameterGroupPDFSplitFileType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-group-by-groupid" match="wwproject:Group" use="@GroupID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <!-- Project Group -->
     <!--               -->
     <xsl:for-each select="$GlobalProject[1]">
      <xsl:variable name="VarProjectGroup" select="key('wwproject-group-by-groupid', $VarFilesDocument/@groupID)" />

      <!-- Transform -->
      <!--           -->
      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocument/@groupID, '', $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Load document -->
        <!--               -->
        <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />

        <!-- Add files -->
        <!--           -->
        <xsl:call-template name="Files">
         <xsl:with-param name="ParamProjectGroup" select="$VarProjectGroup" />
         <xsl:with-param name="ParamSplits" select="$VarSplits" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
      </xsl:if>

      <!-- Report Files -->
      <!--              -->
      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocument/@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="" use="">
       <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
      </wwfiles:File>
     </xsl:for-each>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Files">
  <xsl:param name="ParamProjectGroup" />
  <xsl:param name="ParamSplits" />

  <!-- Copy splits with new file entries added -->
  <!--                                         -->
  <wwsplits:Splits>
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/@*" />

   <!-- Copy all existing split entries -->
   <!--                                 -->
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/wwsplits:*" />

   <!-- Determine PDF target dependency -->
   <!--                                 -->
   <xsl:variable name="VarCopyPDFsFromTargetID" select="wwprojext:GetFormatSetting('pdf-target-dependency')" />

   <!-- Group PDF Path -->
   <!--                -->
   <xsl:if test="(string-length($VarCopyPDFsFromTargetID) &gt; 0) or (wwprojext:GetFormatSetting('pdf-per-group') = 'true')">
    <xsl:variable name="VarGroupName" select="wwprojext:GetGroupName($ParamProjectGroup/@GroupID)" />
    <xsl:variable name="VarReplacedGroupName">
     <xsl:call-template name="ReplaceGroupNameSpacesWith">
      <xsl:with-param name="ParamText" select="$VarGroupName" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />
    <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, concat(wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'), '.pdf'))" />

    <wwsplits:File groupID="{$ParamProjectGroup/@GroupID}" documentID="" id="" type="{$ParameterGroupPDFSplitFileType}" source="" path="{$VarPath}" title="" />
   </xsl:if>

   <!-- Group Documents -->
   <!--                 -->
   <xsl:if test="(string-length($VarCopyPDFsFromTargetID) &gt; 0) or (wwprojext:GetFormatSetting('pdf-per-document') = 'true')">
    <xsl:for-each select="$ParamProjectGroup//wwproject:Document">
     <xsl:variable name="VarProjectDocument" select="." />

     <!-- PDF Path -->
     <!--          -->
     <xsl:variable name="VarReplacedDocumentGroupPath">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($VarProjectDocument/@DocumentID)" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedDocumentGroupPath, $GlobalInvalidPathCharactersExpression, '_'))" />
     <xsl:variable name="VarBaseFileName" select="wwfilesystem:GetFileNameWithoutExtension($VarProjectDocument/@Path)" />
     
     <xsl:variable name="VarCasedBaseFileName">
      <xsl:call-template name="ConvertNameTo">
       <xsl:with-param name="ParamText" select="$VarBaseFileName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarReplacedBaseFileName">
      <xsl:call-template name="ReplaceFileNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarCasedBaseFileName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, concat(wwstring:ReplaceWithExpression($VarReplacedBaseFileName, $GlobalInvalidPathCharactersExpression, '_'), '.pdf'))" />

     <wwsplits:File groupID="{$ParamProjectGroup/@GroupID}" documentID="{$VarProjectDocument/@DocumentID}" id="" type="{$ParameterSinglePDFSplitFileType}" source="" path="{$VarPath}" title="" />
    </xsl:for-each>
   </xsl:if>
  </wwsplits:Splits>
 </xsl:template>
</xsl:stylesheet>
