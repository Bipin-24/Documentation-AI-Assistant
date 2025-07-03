<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Variables-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwvars wwfilesext wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwvars" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


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

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Select child documents -->
     <!--                        -->
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarDocumentVariablesFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)[(@groupID = $VarProjectGroup/@GroupID)]" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'),'.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarDocumentVariablesFiles)), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsXML">
         <!-- Define group variables container -->
         <!--                                  -->
         <wwvars:Variables>
          <wwvars:Group groupID="{$VarProjectGroup/@GroupID}">

           <!-- Process in document order -->
           <!--                           -->
           <xsl:variable name="VarProgressProjectDocumentsStart" select="wwprogress:Start(count($VarProjectGroup//wwproject:Document))" />
           <xsl:for-each select="$VarProjectGroup//wwproject:Document">
            <xsl:variable name="VarProjectDocument" select="." />

            <xsl:variable name="VarDocumentPosition" select="position()" />

            <xsl:variable name="VarProgressProjectDocumentStart" select="wwprogress:Start(1)" />

            <!-- Merge document variables -->
            <!--                          -->
            <xsl:for-each select="$VarDocumentVariablesFiles[@documentID = $VarProjectDocument/@DocumentID]">
             <xsl:variable name="VarDocumentVariablesFile" select="." />

             <!-- Copy document variables -->
             <!--                         -->
             <xsl:variable name="VarDocumentVariables" select="wwexsldoc:LoadXMLWithoutResolver($VarDocumentVariablesFile/@path, false())" />
             <wwvars:Document position="{$VarDocumentPosition}">
              <xsl:copy-of select="$VarDocumentVariables/wwvars:Variables/wwvars:Document/@*" />

              <xsl:copy-of select="$VarDocumentVariables/wwvars:Variables/wwvars:Document/*" />
             </wwvars:Document>
            </xsl:for-each>

            <xsl:variable name="VarProgressProjectDocumentEnd" select="wwprogress:End()" />
           </xsl:for-each>
           <xsl:variable name="VarProgressProjectDocumentsEnd" select="wwprogress:End()" />

          </wwvars:Group>
         </wwvars:Variables>
        </xsl:variable>
        <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
       </xsl:if>

       <!-- Report generated file -->
       <!--                       -->
       <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarDocumentVariablesFiles))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
        <xsl:for-each select="$VarDocumentVariablesFiles">
         <xsl:variable name="VarDocumentVariablesFile" select="." />

         <wwfiles:Depends path="{$VarDocumentVariablesFile/@path}" checksum="{$VarDocumentVariablesFile/@checksum}" groupID="{$VarDocumentVariablesFile/@groupID}" documentID="{$VarDocumentVariablesFile/@documentID}" />
        </xsl:for-each>
       </wwfiles:File>
      </xsl:if>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
