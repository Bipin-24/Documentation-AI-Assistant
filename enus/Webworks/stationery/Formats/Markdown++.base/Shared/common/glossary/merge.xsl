<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Glossary-Schema"
                              xmlns:wwgloss="urn:WebWorks-Glossary-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwtoc wwlinks wwmode wwfiles wwdoc wwbehaviors wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>

 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />

 <xsl:namespace-alias stylesheet-prefix="wwgloss" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwgloss-terms-by-value" match="wwgloss:Term" use="@value" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesGlossaryDocuments" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressGlossaryDocumentsStart" select="wwprogress:Start(count($VarFilesGlossaryDocuments))" />

    <!-- Iterate Glossary documents -->
    <!--                            -->
    <xsl:for-each select="$VarFilesGlossaryDocuments">
     <xsl:variable name="VarFilesGlossaryDocument" select="." />

      <xsl:variable name="VarProgressGlossaryDocumentStart" select="wwprogress:Start(1)" />

     <xsl:variable name="VarGlossaryDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesGlossaryDocument/@path, false())" />

     <!-- Path -->
     <!--      -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarFilesGlossaryDocument/@groupID), concat(translate($ParameterType, ':', '_'), '.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesGlossaryDocuments)), $VarFilesGlossaryDocument/@groupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <wwgloss:Glossary version="1.0">
        <xsl:call-template name="GlossaryMerge">
         <xsl:with-param name="ParamGlossaryDocument" select="$VarGlossaryDocument" />
        </xsl:call-template>
       </wwgloss:Glossary>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes', 'no', '', '', '', '', 'text/xml')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarFilesGlossaryDocuments))}" groupID="{$VarFilesGlossaryDocument/@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesGlossaryDocument/@path}" checksum="{$VarFilesGlossaryDocument/@checksum}" groupID="{$VarFilesGlossaryDocument/@groupID}" documentID="{$VarFilesGlossaryDocument/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarProgressGlossaryDocumentEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressGlossaryDocumentsEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="GlossaryMerge">
  <xsl:param name="ParamGlossaryDocument" />

  <xsl:variable name="VarGlossaryTerms" select="$ParamGlossaryDocument/wwgloss:Glossary/wwgloss:Term" />

  <!-- Process in alphabetical order -->
  <!--                               -->
  <xsl:for-each select="$VarGlossaryTerms[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarGlossaryTerms">
    <!-- Go ahead and sort the terms -->
    <!--                             -->
    <xsl:sort order="ascending" data-type="text" select="@value" />
    <xsl:variable name="VarGlossaryTerm" select="." />

    <!-- Find all terms with value -->
    <!--                           -->
    <xsl:variable name="VarGlossaryTermsWithValue" select="key('wwgloss-terms-by-value', $VarGlossaryTerm/@value)" />

    <!-- First unique term value? -->
    <!--                          -->
    <xsl:if test="count($VarGlossaryTerm | $VarGlossaryTermsWithValue[1]) = 1">
     <!-- Extract all definitions for the given term -->
     <!--                                            -->
     <wwgloss:Term id="glossary_{wwstring:NCNAME($VarGlossaryTerm/@value)}">
      <xsl:copy-of select="$VarGlossaryTerm/@*" />

      <!-- Process all terms with value -->
      <!--                              -->
      <xsl:for-each select="$VarGlossaryTermsWithValue">
       <xsl:variable name="VarGlossaryTermWithValue" select="." />

       <xsl:copy-of select="$VarGlossaryTermWithValue/wwdoc:Paragraph" />
      </xsl:for-each>
     </wwgloss:Term>
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
