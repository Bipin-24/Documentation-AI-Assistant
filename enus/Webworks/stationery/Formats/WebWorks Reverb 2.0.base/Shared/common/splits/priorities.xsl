<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
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
                              exclude-result-prefixes="xsl wwmode wwsplits wwbehaviors wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
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
     <xsl:variable name="VarDocumentBehaviorsFile" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentBehaviorsFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentBehaviorsFile/@groupID, $VarDocumentBehaviorsFile/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarDocumentBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarDocumentBehaviorsFile/@path, false())" />

       <xsl:call-template name="Priorities">
        <xsl:with-param name="ParamDocumentBehaviors" select="$VarDocumentBehaviors" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarDocumentBehaviorsFile/@path}" checksum="{$VarDocumentBehaviorsFile/@checksum}" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Priorities">
  <xsl:param name="ParamDocumentBehaviors" />

  <wwsplits:SplitPriorities version="1.0">
   <xsl:for-each select="$ParamDocumentBehaviors/wwbehaviors:Behaviors/wwbehaviors:Paragraph | $ParamDocumentBehaviors/wwbehaviors:Behaviors/wwbehaviors:Table">
    <xsl:variable name="VarBehaviorsNode" select="." />

    <xsl:choose>
     <xsl:when test="position() = 1">
      <!-- Assign split priority of 1 to first element -->
      <!--                                             -->
      <wwsplits:SplitPriority id="{$VarBehaviorsNode/@id}" documentposition="{$VarBehaviorsNode/@documentposition}" splitpriority="1" outputposition="1" />
     </xsl:when>

     <xsl:when test="(position() &gt; 1) and ($VarBehaviorsNode/@splitpriority != 'none') and ($VarBehaviorsNode/@splitpriority &gt; 0)">
      <!-- Copy if split priority is valid -->
      <!--                                 -->
      <wwsplits:SplitPriority id="{$VarBehaviorsNode/@id}" documentposition="{$VarBehaviorsNode/@documentposition}" splitpriority="{$VarBehaviorsNode/@splitpriority}" outputposition="{position()}" />
     </xsl:when>
    </xsl:choose>
   </xsl:for-each>
  </wwsplits:SplitPriorities>
 </xsl:template>
</xsl:stylesheet>
