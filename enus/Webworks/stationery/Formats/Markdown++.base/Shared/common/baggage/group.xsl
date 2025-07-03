<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Baggage-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwproject wwbaggage wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwbaggage" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwbaggage-files-by-pathtolower" match="wwbaggage:File" use="@pathtolower" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate Project Groups -->
   <!--                        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Get Group Files -->
    <!--                 -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarGroupFilesOfType" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupFilesOfType)), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Join Document Files -->
       <!--                     -->
       <xsl:variable name="VarJoinedBaggageFilesAsXML">
        <xsl:for-each select="$VarGroupFilesOfType">
         <xsl:variable name="VarGroupFileOfType" select="." />

         <xsl:variable name="VarDocumentBaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarGroupFileOfType/@path, false())/wwbaggage:Baggage" />

         <xsl:copy-of select="$VarDocumentBaggageFiles/wwbaggage:File" />
        </xsl:for-each>
       </xsl:variable>
       <xsl:variable name="VarJoinedBaggageFiles" select="msxsl:node-set($VarJoinedBaggageFilesAsXML)/wwbaggage:File" />

       <!-- Force Unique -->
       <!--              -->
       <wwbaggage:Baggage version="1.0">
        <xsl:for-each select="$VarJoinedBaggageFiles">
         <xsl:variable name="VarBaggageFile" select="." />

         <xsl:variable name="VarBaggageFilesWithPathToLower" select="key('wwbaggage-files-by-pathtolower', $VarBaggageFile/@pathtolower)" />
         <xsl:if test="count($VarBaggageFile | $VarBaggageFilesWithPathToLower[1]) = 1">
          <xsl:copy-of select="$VarBaggageFile" />
         </xsl:if>
        </xsl:for-each>
       </wwbaggage:Baggage>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupFilesOfType))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <xsl:for-each select="$VarGroupFilesOfType">
       <xsl:variable name="VarDocumentBaggageFile" select="." />

       <wwfiles:Depends path="{$VarDocumentBaggageFile/@path}" checksum="{$VarDocumentBaggageFile/@checksum}" groupID="{$VarDocumentBaggageFile/@groupID}" documentID="{$VarDocumentBaggageFile/@documentID}" />
      </xsl:for-each>
     </wwfiles:File>
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
