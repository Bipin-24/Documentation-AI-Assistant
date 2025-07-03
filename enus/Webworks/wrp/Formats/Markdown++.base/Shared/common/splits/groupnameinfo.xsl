<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
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
                              exclude-result-prefixes="xsl msxsl wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />

 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:value-of select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:value-of select="wwprogress:Start(1)" />

    <xsl:variable name="VarProjectDocuments" select="$VarProjectGroup//wwproject:Document" />

    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'),'.xml'))" />

    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesDependsTypeInGroup" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />
     <xsl:variable name="VarFilesDependsTypeInGroupCount" select="count($VarFilesDependsTypeInGroup)" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat(wwprojext:GetDocumentsToGenerateChecksum(), '_', $VarFilesDependsTypeInGroupCount), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <!-- Documents -->
      <!--           -->
      <xsl:value-of select="wwprogress:Start(count($VarProjectDocuments))" />
      <xsl:variable name="VarResultAsXML">
       <wwsplits:Splits version="1.0">
        <xsl:for-each select="$VarProjectDocuments">
         <xsl:variable name="VarProjectDocument" select="." />

         <!-- Splits -->
         <!--        -->
         <xsl:value-of select="wwprogress:Start(1)" />
         <xsl:for-each select="$GlobalFiles[1]">
          <xsl:variable name="VarFilesNameInfo" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterDependsType]" />

          <xsl:for-each select="$VarFilesNameInfo[1]">
           <!-- Load splits -->
           <!--             -->
           <xsl:variable name="VarNameInfo" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />

           <xsl:copy-of select="$VarNameInfo/wwsplits:Splits/*" />
          </xsl:for-each>
         </xsl:for-each>
         <xsl:value-of select="wwprogress:End()" />
        </xsl:for-each>
       </wwsplits:Splits>
      </xsl:variable>
      <xsl:value-of select="wwprogress:End()" />
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <!-- Track files -->
     <!--             -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{wwprojext:GetDocumentsToGenerateChecksum()}_{$VarFilesDependsTypeInGroupCount}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <xsl:for-each select="$VarProjectDocuments">
       <xsl:variable name="VarProjectDocument" select="." />

       <xsl:for-each select="$GlobalFiles[1]">
        <xsl:variable name="VarFilesNameInfo" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterDependsType]" />

        <xsl:for-each select="$VarFilesNameInfo[1]">
         <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </wwfiles:File>
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:value-of select="wwprogress:End()" />
  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
