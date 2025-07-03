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


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Get document specific files -->
   <!--                             -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <!-- Get group documents in project order -->
    <!--                                      -->
    <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />

    <!-- Up to date? -->
    <!--             -->
    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType)), '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <xsl:variable name="VarResultAsXML">
      <!-- Index -->
      <!--       -->
      <wwindex:Index version="1.0">

       <!-- Combine document index entries using project group order -->
       <!--                                                          -->
       <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
       <xsl:for-each select="$VarProjectGroups">
        <xsl:variable name="VarProjectGroup" select="." />

        <!-- Files -->
        <!--       -->
        <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />
        <xsl:for-each select="$GlobalFiles[1]">
         <xsl:variable name="VarFiles" select="$VarFilesByType[@groupID = $VarProjectGroup/@GroupID]" />

         <xsl:for-each select="$VarFiles[1]">
          <xsl:variable name="VarFile" select="." />

          <!-- Process -->
          <!--         -->
          <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path, false())" />
          <xsl:copy-of select="$VarDocument/wwindex:Index/* | $VarDocument/wwindex:Index/text()" />
         </xsl:for-each>
        </xsl:for-each>

        <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
       </xsl:for-each>

       <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
      </wwindex:Index>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
    </xsl:if>

    <!-- Record Files -->
    <!--              -->
    <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesByType))}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
     <xsl:for-each select="$VarFilesByType">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </xsl:for-each>
    </wwfiles:File>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
