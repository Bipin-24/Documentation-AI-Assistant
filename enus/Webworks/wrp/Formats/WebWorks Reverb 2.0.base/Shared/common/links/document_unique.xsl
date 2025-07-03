<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwtrait="urn:WebWorks-Engine-FormatTraitInfo-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwbehaviors wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="no" />
 <xsl:namespace-alias stylesheet-prefix="wwlinks" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-paragraphs-by-id" match="wwlinks:Paragraph" use="@id" />


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

    <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFile" select="." />

     <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFile/@groupID, $VarFile/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsTreeFragment">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarDocumentLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path, false())" />

       <!-- Copy unique ids -->
       <!--                 -->
       <xsl:apply-templates select="$VarDocumentLinks" mode="wwmode:unique_id" />
      </xsl:variable>

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
      </xsl:if>
     </xsl:if>

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarFile/@path}" checksum="{$VarFile/@checksum}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
      </wwfiles:File>
     </xsl:if>

     <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:unique_id -->
 <!--                  -->

 <xsl:template match="/" mode="wwmode:unique_id">
  <xsl:apply-templates mode="wwmode:unique_id" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:unique_id">
  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:copy>
    <xsl:copy-of select="@*" />

    <xsl:apply-templates mode="wwmode:unique_id" />
   </xsl:copy>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:unique_id">
  <xsl:param name="ParamParagraphLink" select="." />

  <!-- Address issues related to duplicate link entries in DITA sourced links -->
  <!--                                                                        -->
  <xsl:if test="string-length($ParamParagraphLink/@id) &gt; 0">
   <xsl:variable name="VarFirstUniqueLink" select="count(key('wwlinks-paragraphs-by-id', $ParamParagraphLink/@id)[1] | $ParamParagraphLink) = 1" />
   <xsl:if test="($VarFirstUniqueLink) or (string-length($ParamParagraphLink/@topic) &gt; 0)">
    <!-- Emit paragraph link entry -->
    <!--                           -->
    <wwlinks:Paragraph>
     <!-- Duplicate existing attributes -->
     <!--                               -->
     <xsl:copy-of select="$ParamParagraphLink/@*" />
    </wwlinks:Paragraph>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:unique_id">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
