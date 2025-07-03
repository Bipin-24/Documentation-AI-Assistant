<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviorsscript="urn:WebWorks-Behaviors-Finalize-Script"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwbehaviors wwbehaviorsscript wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwbehaviors" result-prefix="#default" />
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

   <!-- Splits -->
   <!--        -->
   <xsl:value-of select="wwprogress:Start(1)" />
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarDocumentBehaviorsFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarDocumentBehaviorsFiles))" />

    <xsl:for-each select="$VarDocumentBehaviorsFiles">
     <xsl:variable name="VarDocumentBehaviorsFile" select="." />

     <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

     <!-- Up-to-date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentBehaviorsFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentBehaviorsFile/@groupID, $VarDocumentBehaviorsFile/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Minimize">
        <xsl:with-param name="ParamDocumentBehaviorsFile" select="$VarDocumentBehaviorsFile" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <!-- Record file -->
     <!--             -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarDocumentBehaviorsFile/@path}" checksum="{$VarDocumentBehaviorsFile/@checksum}" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Minimize">
  <xsl:param name="ParamDocumentBehaviorsFile" />

  <!-- Load document behaviors -->
  <!--                         -->
  <xsl:variable name="VarDocumentBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentBehaviorsFile/@path, false())" />

  <xsl:apply-templates select="$VarDocumentBehaviors" mode="wwmode:minimize" />
 </xsl:template>


 <!-- wwmode:minimize -->
 <!--                 -->

 <xsl:template match="wwbehaviors:Paragraph" mode="wwmode:minimize">
  <xsl:param name="ParamParagraphBehavior" select="." />

  <!-- Empty paragraph? -->
  <!--                  -->
  <xsl:choose>
   <xsl:when test="count($ParamParagraphBehavior/wwbehaviors:*[1]) = 1">
    <xsl:copy>
     <xsl:copy-of select="@*" />

     <xsl:apply-templates mode="wwmode:minimize" />
    </xsl:copy>
   </xsl:when>

   <xsl:when test="count($ParamParagraphBehavior/@*[(name() != 'id') and (name() != 'documentposition') and (name() != 'splitpriority')]) &gt; 0">
    <xsl:copy>
     <xsl:copy-of select="@*" />

     <xsl:apply-templates mode="wwmode:minimize" />
    </xsl:copy>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:minimize">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:minimize" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:minimize">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
