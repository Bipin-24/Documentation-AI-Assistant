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
                              exclude-result-prefixes="xsl wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-splitpriority-by-outputposition" match="wwsplits:SplitPriority" use="@outputposition" />


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

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName(@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', @groupID, @documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarSplitPriorities" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />

       <xsl:call-template name="Collapse">
        <xsl:with-param name="ParamSplitPriorities" select="$VarSplitPriorities" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{@groupID}" documentID="{@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Collapse">
  <xsl:param name="ParamSplitPriorities" />

  <wwsplits:Splits version="1.0">
   <!-- Split Behavior -->
   <!--                -->
   <xsl:variable name="VarSplitHandling" select="wwprojext:GetFormatSetting('file-split-handling', 'combine')" />
   <xsl:choose>
    <xsl:when test="$VarSplitHandling = 'never'">
     <!-- Never -->
     <!--       -->
     <xsl:for-each select="$ParamSplitPriorities/wwsplits:SplitPriorities/wwsplits:SplitPriority[1]">
      <xsl:variable name="VarSplit" select="." />

      <wwsplits:Split id="{$VarSplit/@id}" documentposition="{$VarSplit/@documentposition}" />
     </xsl:for-each>
    </xsl:when>

    <xsl:when test="$VarSplitHandling = 'always'">
     <!-- Always -->
     <!--        -->
     <xsl:for-each select="$ParamSplitPriorities/wwsplits:SplitPriorities/wwsplits:SplitPriority">
      <xsl:variable name="VarSplit" select="." />

      <wwsplits:Split id="{$VarSplit/@id}" documentposition="{$VarSplit/@documentposition}" />
     </xsl:for-each>
    </xsl:when>

    <xsl:when test="$VarSplitHandling = 'if-not-previous'">
     <!-- Split if previous paragraph did not -->
     <!--                                     -->
     <xsl:for-each select="$ParamSplitPriorities/wwsplits:SplitPriorities/wwsplits:SplitPriority">
      <xsl:variable name="VarSplit" select="." />

      <xsl:variable name="VarPreviousSplitPriority" select="key('wwsplits-splitpriority-by-outputposition', $VarSplit/@outputposition - 1)" />

      <xsl:if test="(count($VarPreviousSplitPriority[1]) = 0) or ($VarSplit/@splitpriority &lt; $VarPreviousSplitPriority/@splitpriority)">
       <wwsplits:Split id="{$VarSplit/@id}" documentposition="{$VarSplit/@documentposition}" />
      </xsl:if>
     </xsl:for-each>
    </xsl:when>

    <xsl:otherwise>
     <!-- Combine -->
     <!--         -->
     <xsl:for-each select="$ParamSplitPriorities/wwsplits:SplitPriorities/wwsplits:SplitPriority">
      <xsl:variable name="VarSplit" select="." />

      <xsl:variable name="VarPreviousSplitPriority" select="key('wwsplits-splitpriority-by-outputposition', $VarSplit/@outputposition - 1)" />

      <xsl:if test="(count($VarPreviousSplitPriority[1]) = 0) or ($VarSplit/@splitpriority &lt;= $VarPreviousSplitPriority/@splitpriority)">
       <wwsplits:Split id="{$VarSplit/@id}" documentposition="{$VarSplit/@documentposition}" />
      </xsl:if>
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </wwsplits:Splits>
 </xsl:template>
</xsl:stylesheet>
