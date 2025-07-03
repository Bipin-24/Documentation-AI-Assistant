<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Index-Schema"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwmode msxsl wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwindex" result-prefix="#default" />
 <xsl:strip-space elements="*" />


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
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Get document specific files -->
    <!--                             -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />

     <!-- Get group documents in project order -->
     <!--                                      -->
     <xsl:variable name="VarProjectGroupDocuments" select="$VarProjectGroup//wwproject:Document" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType)), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Index -->
       <!--       -->
       <wwindex:Index version="1.0">

        <!-- Combine document index entries using project document order -->
        <!--                                                             -->
        <xsl:variable name="VarProgressProjectGroupDocumentsStart" select="wwprogress:Start(count($VarProjectGroupDocuments))" />
        <xsl:for-each select="$VarProjectGroupDocuments">
         <xsl:variable name="VarProjectGroupDocument" select="." />

         <!-- Files -->
         <!--       -->
         <xsl:variable name="VarProgressProjectGroupDocumentStart" select="wwprogress:Start(1)" />
         <xsl:for-each select="$GlobalFiles[1]">
          <xsl:variable name="VarFiles" select="key('wwfiles-files-by-documentid', $VarProjectGroupDocument/@DocumentID)[@type = $ParameterDependsType]" />

          <xsl:for-each select="$VarFiles[1]">
           <xsl:variable name="VarFile" select="." />

           <!-- Process -->
           <!--         -->
           <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path, false())" />
           <xsl:copy-of select="$VarDocument/wwindex:Index/* | $VarDocument/wwindex:Index/text()" />
          </xsl:for-each>
         </xsl:for-each>

         <xsl:variable name="VarProgressProjectGroupDocumentEnd" select="wwprogress:End()" />
        </xsl:for-each>

        <xsl:variable name="VarProgressProjectGroupDocumentsEnd" select="wwprogress:End()" />
       </wwindex:Index>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <!-- Record Files -->
     <!--              -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <!-- Documents -->
      <!--           -->
      <xsl:for-each select="$VarProjectGroupDocuments">
       <xsl:variable name="VarProjectGroupDocument" select="." />

       <xsl:for-each select="$GlobalFiles[1]">
        <xsl:variable name="VarFiles" select="key('wwfiles-files-by-documentid', $VarProjectGroupDocument/@DocumentID)[@type = $ParameterDependsType]" />

        <xsl:for-each select="$VarFiles[1]">
         <xsl:variable name="VarFile" select="." />

         <wwfiles:Depends path="{$VarFile/@path}" checksum="{$VarFile/@checksum}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </wwfiles:File>
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>
   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
