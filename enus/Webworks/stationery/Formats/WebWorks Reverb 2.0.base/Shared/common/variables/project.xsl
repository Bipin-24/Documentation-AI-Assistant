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

   <!-- Select child documents -->
   <!--                        -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarGroupVariablesFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <!-- Up to date? -->
    <!--             -->
    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupVariablesFiles)), '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <xsl:variable name="VarResultAsXML">
      <!-- Define project variables container -->
      <!--                                    -->
      <wwvars:Variables>
       <!-- Merge group variables -->
       <!--                       -->
       <xsl:for-each select="$VarGroupVariablesFiles">
        <xsl:variable name="VarGroupVariablesFile" select="." />

        <!-- Copy group variables -->
        <!--                      -->
        <xsl:variable name="VarGroupVariables" select="wwexsldoc:LoadXMLWithoutResolver($VarGroupVariablesFile/@path, false())" />
        <wwvars:Group position="{position()}">
         <xsl:copy-of select="$VarGroupVariables/wwvars:Variables/wwvars:Group/@*" />

         <xsl:copy-of select="$VarGroupVariables/wwvars:Variables/wwvars:Group/*" />
        </wwvars:Group>
       </xsl:for-each>
      </wwvars:Variables>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
    </xsl:if>

    <!-- Report generated file -->
    <!--                       -->
    <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupVariablesFiles))}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
     <xsl:for-each select="$VarGroupVariablesFiles">
      <xsl:variable name="VarGroupVariablesFile" select="." />

      <wwfiles:Depends path="{$VarGroupVariablesFile/@path}" checksum="{$VarGroupVariablesFile/@checksum}" groupID="{$VarGroupVariablesFile/@groupID}" documentID="{$VarGroupVariablesFile/@documentID}" />
     </xsl:for-each>
    </wwfiles:File>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
