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
 <xsl:key name="wwlinks-paragraphs-by-signature" match="wwlinks:Paragraph" use="@signature" />
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

    <xsl:for-each select="$VarFilesByType[1]">
     <xsl:variable name="VarFilesEntry" select="." />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <!-- Up to date? -->
     <!--             -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, wwprojext:GetDocumentsToGenerateChecksum(), '', '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesEntry/@path, false())" />

       <wwlinks:Links version="1.0">
        <xsl:for-each select="$VarLinks/wwlinks:Links/wwlinks:File">
         <xsl:variable name="VarLinksFile" select="." />

         <xsl:copy>
          <xsl:copy-of select="@*" />

          <xsl:apply-templates select="$VarLinksFile/*" mode="wwmode:paragraph-links">
           <xsl:with-param name="ParamLinksFile" select="$VarLinksFile" />
          </xsl:apply-templates>
         </xsl:copy>
        </xsl:for-each>
       </wwlinks:Links>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
      </xsl:if>
     </xsl:if>

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Single links file for the whole project -->
      <!--                                         -->
      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{wwprojext:GetDocumentsToGenerateChecksum()}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarFilesEntry/@path}" checksum="{$VarFilesEntry/@checksum}" groupID="{$VarFilesEntry/@groupID}" documentID="{$VarFilesEntry/@documentID}" />
      </wwfiles:File>
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:paragraph-links -->
 <!--                        -->

 <xsl:template match="/" mode="wwmode:paragraph-links">
  <xsl:param name="ParamLinksFile" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:paragraph-links">
   <xsl:with-param name="ParamLinksFile" select="$ParamLinksFile" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwlinks:Paragraph" mode="wwmode:paragraph-links">
  <xsl:param name="ParamParagraphLink" select="." />
  <xsl:param name="ParamLinksFile" />

  <!-- Address issues related to duplicate link entries in DITA sourced links -->
  <!--                                                                        -->
  <xsl:variable name="VarFirstUniqueLinkParagraph" select="count(key('wwlinks-paragraphs-by-signature', $ParamParagraphLink/@signature)[1] | $ParamParagraphLink) = 1" />
  <xsl:choose>
   <!-- First unique link paragraph with this signature -->
   <!--                                                 -->
   <xsl:when test="$VarFirstUniqueLinkParagraph">
    <!-- Emit paragraph link entry -->
    <!--                           -->
    <wwlinks:Paragraph>
     <!-- Duplicate existing attributes, except topic and signature -->
     <!--                                                           -->
     <xsl:copy-of select="@*[(local-name() != 'topic') and (local-name() != 'signature')]" />

     <!-- Emit last unique topic -->
     <!--                        -->
     <xsl:if test="string-length($ParamParagraphLink/@topic) &gt; 0">
      <xsl:variable name="VarLinksParagraphsWithTopic" select="key('wwlinks-paragraphs-by-topic', $ParamParagraphLink/@topic)" />
      <xsl:variable name="VarLinksGroupParagraphsWithTopic" select="$VarLinksParagraphsWithTopic[./ancestor::wwlinks:File[1]/@groupID = $ParamLinksFile/@groupID]" />

      <xsl:choose>
       <!-- Last unique topic alias -->
       <!--                         -->
       <xsl:when test="count($ParamParagraphLink | $VarLinksGroupParagraphsWithTopic[count($VarLinksGroupParagraphsWithTopic)]) = 1">
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
     </xsl:if>
    </wwlinks:Paragraph>
   </xsl:when>

   <!-- Topic alias to preserve? -->
   <!--                          -->
   <xsl:when test="string-length($ParamParagraphLink/@topic) &gt; 0">
    <xsl:variable name="VarLinksParagraphsWithTopic" select="key('wwlinks-paragraphs-by-topic', $ParamParagraphLink/@topic)" />
    <xsl:variable name="VarLinksGroupParagraphsWithTopic" select="$VarLinksParagraphsWithTopic[./ancestor::wwlinks:File[1]/@groupID = $ParamLinksFile/@groupID]" />

    <!-- Emit paragraph link entry -->
    <!--                           -->
    <wwlinks:Paragraph>
     <!-- Duplicate existing attributes, except topic and signature -->
     <!--                                                           -->
     <xsl:copy-of select="@*[(local-name() != 'topic') and (local-name() != 'signature')]" />

     <xsl:choose>
      <!-- Last unique topic alias -->
      <!--                         -->
      <xsl:when test="count($ParamParagraphLink | $VarLinksGroupParagraphsWithTopic[count($VarLinksGroupParagraphsWithTopic)]) = 1">
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
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:paragraph-links">
  <xsl:param name="ParamLinksFile" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:copy>
    <xsl:copy-of select="@*" />

    <!-- Process children -->
    <!--                  -->
    <xsl:apply-templates mode="wwmode:paragraph-links">
     <xsl:with-param name="ParamLinksFile" select="$ParamLinksFile" />
    </xsl:apply-templates>
   </xsl:copy>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:paragraph-links">
  <xsl:param name="ParamLinksFile" />

  <!-- Nothing to do! -->
  <!--                -->
 </xsl:template>
</xsl:stylesheet>
