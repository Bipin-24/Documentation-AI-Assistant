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
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />

 <xsl:namespace-alias stylesheet-prefix="wwgloss" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwbehaviors-markers-by-behavior" match="wwbehaviors:Marker" use="@behavior" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate documents -->
   <!--                        -->
   <xsl:for-each select="$GlobalFiles[1]">

    <!-- Documents -->
    <!--           -->
    <xsl:variable name="VarFilesDocuments" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarFilesDocuments))" />

    <xsl:for-each select="$VarFilesDocuments">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

     <xsl:for-each select="$GlobalFiles[1]">
      <!-- Behaviors -->
      <!--           -->
      <xsl:variable name="VarFilesBehavior" select="key('wwfiles-files-by-documentid', $VarFilesDocument/@documentID)[@type = $ParameterBehaviorsType]" />

      <!-- Path -->
      <!--      -->
      <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarFilesDocument/@groupID), $VarFilesDocument/@documentID, concat(translate($ParameterType, ':', '_'), '.xml'))" />

      <!-- Up to date -->
      <!--            -->
      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <!-- Not up to date, load the files -->
       <!--                                -->
       <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />
       <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesBehavior/@path, false())" />
       
       <xsl:variable name="VarResultAsXML">
        <wwgloss:Glossary version="1.0">
         <xsl:call-template name="GlossaryDocument">
          <xsl:with-param name="ParamDocument" select="$VarDocument" />
          <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
          <xsl:with-param name="ParamDocumentID" select="$VarFilesDocument/@documentID" />
         </xsl:call-template>
        </wwgloss:Glossary>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes', 'no', '', '', '', '', 'text/xml')" />
      </xsl:if>

      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
       <wwfiles:Depends path="{$VarFilesBehavior/@path}" checksum="{$VarFilesBehavior/@checksum}" groupID="{$VarFilesBehavior/@groupID}" documentID="{$VarFilesBehavior/@documentID}" />
      </wwfiles:File>

     </xsl:for-each>

     <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />

   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="GlossaryDocument">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentID" />

  <xsl:variable name="VarDocumentParagraphs" select="$ParamDocument/wwdoc:Document/wwdoc:Content//wwdoc:Paragraph" />

  <xsl:for-each select="$VarDocumentParagraphs">
   <xsl:variable name="VarParagraph" select="." />

   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamDocumentID, $VarParagraph/@id)" />
   <xsl:variable name="VarGlossaryBehavior" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'glossary-behavior']/@Value" />

   <xsl:choose>
    <!-- Paragraph behaviors -->
    <!--                     -->
    <xsl:when test="starts-with($VarGlossaryBehavior, 'glossary-term')">
     <xsl:variable name="VarGlossaryTermValue">
      <xsl:for-each select="$VarParagraph//wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:variable>

     <!-- Glossary basename -->
     <!--                   -->
     <xsl:variable name="VarGlossaryBasename">
      <xsl:call-template name="GlossaryBasename">
       <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
       <xsl:with-param name="ParamGlossaryTermValue" select="$VarGlossaryTermValue" />
      </xsl:call-template>
     </xsl:variable>

     <wwgloss:Term value="{$VarGlossaryTermValue}" basename="{$VarGlossaryBasename}">
      <xsl:call-template name="GlossaryDefinitionParagraphs">
       <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
       <xsl:with-param name="ParamGlossaryParagraph" select="$VarParagraph" />
      </xsl:call-template>
     </wwgloss:Term>
    </xsl:when>

    <!-- Marker behaviors -->
    <!--                  -->    
    <xsl:otherwise>
     <xsl:for-each select="$ParamBehaviors[1]">
      <xsl:variable name="VarMarkerBehavior" select="key('wwbehaviors-markers-by-behavior', 'glossary-term')[../@id = $VarParagraph/@id][1]" />

      <xsl:for-each select="$VarMarkerBehavior">
       <xsl:variable name="VarGlossaryTermValue">
        <xsl:for-each select="$VarMarkerBehavior/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
         <xsl:value-of select="@value" />
        </xsl:for-each>
       </xsl:variable>

       <!-- Glossary basename -->
       <!--                   -->
       <xsl:variable name="VarGlossaryBasename">
        <xsl:call-template name="GlossaryBasename">
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
         <xsl:with-param name="ParamGlossaryTermValue" select="$VarGlossaryTermValue" />
        </xsl:call-template>
       </xsl:variable>

       <wwgloss:Term value="{$VarGlossaryTermValue}" basename="{$VarGlossaryBasename}">
        <xsl:copy-of select="$VarParagraph" />
       </wwgloss:Term>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="GlossaryDefinitionParagraphs">
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamGlossaryParagraph" />

  <xsl:variable name="VarParagraph" select="$ParamGlossaryParagraph/following-sibling::wwdoc:Paragraph[1]" />
  <xsl:for-each select="$VarParagraph">
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamDocumentID, $VarParagraph/@id)" />

   <xsl:variable name="VarGlossaryBehavior" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'glossary-behavior']/@Value" />
   <xsl:if test="starts-with($VarGlossaryBehavior, 'glossary-definition')">
    <xsl:copy-of select="$VarParagraph" />

    <xsl:call-template name="GlossaryDefinitionParagraphs">
     <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
     <xsl:with-param name="ParamGlossaryParagraph" select="$VarParagraph" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="GlossaryBasename">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamGlossaryTermValue" />

  <!-- Use term for basename -->
  <!--                       -->
  <xsl:value-of select="wwfilesystem:MakeValidFileName(wwstring:Replace($ParamGlossaryTermValue, '#', '_'))" />
 </xsl:template>
</xsl:stylesheet>
