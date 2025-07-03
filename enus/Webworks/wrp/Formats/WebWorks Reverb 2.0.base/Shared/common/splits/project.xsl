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
 <xsl:strip-space elements="" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, count($VarFilesByType), '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <xsl:variable name="VarResultAsXML">
      <wwsplits:Splits version="1.0">

      <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />
      <xsl:for-each select="$VarFilesByType">
       <xsl:variable name="VarSplitsFile" select="." />

       <xsl:value-of select="wwprogress:Start(1)" />

       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />

       <xsl:copy-of select="$VarSplits/wwsplits:Splits/*" />

       <xsl:value-of select="wwprogress:End()" />
      </xsl:for-each>
      <xsl:value-of select="wwprogress:End()" />

      </wwsplits:Splits>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
    </xsl:if>

    <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{count($VarFilesByType)}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
     <xsl:for-each select="$VarFilesByType">
      <xsl:variable name="VarSplitsFile" select="." />

      <wwfiles:Depends path="{$VarSplitsFile/@path}" checksum="{$VarSplitsFile/@checksum}" groupID="{$VarSplitsFile/@groupID}" documentID="{$VarSplitsFile/@documentID}" />
     </xsl:for-each>
    </wwfiles:File>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
