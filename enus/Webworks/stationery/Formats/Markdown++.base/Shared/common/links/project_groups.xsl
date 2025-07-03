<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwlinks" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-paragraphs-by-topic" match="wwlinks:Paragraph" use="@topic" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />

    <!-- Up to date? -->
    <!--             -->
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', wwprojext:GetDocumentsToGenerateChecksum(), ':', count(VarFilesByType)), '', '', $GlobalActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <xsl:variable name="VarResultAsTreeFragment">
      <!-- Merge group links -->
      <!--                   -->
      <wwlinks:Links version="1.0">
       <xsl:for-each select="$VarFilesByType">
        <xsl:variable name="VarFilesEntry" select="." />

        <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesEntry/@path, false())" />
        <xsl:apply-templates select="$VarLinks" mode="wwmode:project-links" />
       </xsl:for-each>
      </wwlinks:Links>
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
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', wwprojext:GetDocumentsToGenerateChecksum(), ':', count($VarFilesByType))}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <xsl:for-each select="$VarFilesByType[1]">
       <xsl:variable name="VarFilesEntry" select="." />

       <wwfiles:Depends path="{$VarFilesEntry/@path}" checksum="{$VarFilesEntry/@checksum}" groupID="{$VarFilesEntry/@groupID}" documentID="{$VarFilesEntry/@documentID}" />
      </xsl:for-each>
     </wwfiles:File>
    </xsl:if>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:project-links -->
 <!--                      -->

 <xsl:template match="/" mode="wwmode:project-links">

  <xsl:apply-templates mode="wwmode:project-links" />
 </xsl:template>


 <xsl:template match="wwlinks:Links" mode="wwmode:project-links">
  <xsl:apply-templates mode="wwmode:project-links" />
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:project-links">
  <xsl:param name="ParamParagraphLink" select="." />

  <xsl:choose>
   <!-- Topic alias to preserve? -->
   <!--                          -->
   <xsl:when test="string-length($ParamParagraphLink/@topic) &gt; 0">
    <xsl:variable name="VarLinksParagraphsWithTopic" select="key('wwlinks-paragraphs-by-topic', $ParamParagraphLink/@topic)" />

    <!-- Emit paragraph link entry -->
    <!--                           -->
    <wwlinks:Paragraph>
     <!-- Duplicate existing attributes, except topic -->
     <!--                                             -->
     <xsl:copy-of select="@*[local-name() != 'topic']" />

     <xsl:choose>
      <!-- Last unique topic alias -->
      <!--                         -->
      <xsl:when test="count($ParamParagraphLink | $VarLinksParagraphsWithTopic[count($VarLinksParagraphsWithTopic)]) = 1">
       <xsl:attribute name="topic">
        <xsl:value-of select="$ParamParagraphLink/@topic" />
       </xsl:attribute>
      </xsl:when>

      <!-- Duplicate topic aliases -->
      <!--                         -->
      <xsl:otherwise>
       <xsl:attribute name="duplicate-topic">
        <xsl:value-of select="$ParamParagraphLink/@topic" />
       </xsl:attribute>
      </xsl:otherwise>
     </xsl:choose>
    </wwlinks:Paragraph>
   </xsl:when>

   <xsl:otherwise>
    <!-- Preserve as is -->
    <!--                -->
    <wwlinks:Paragraph>
     <xsl:copy-of select="@*" />
    </wwlinks:Paragraph>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:project-links">
  <xsl:param name="ParamLinksFile" />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:project-links" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:project-links">
  <!-- Nothing to do! -->
  <!--                -->
 </xsl:template>
</xsl:stylesheet>
