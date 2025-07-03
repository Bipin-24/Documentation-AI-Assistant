<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Files-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwadapter="urn:WebWorks-XSLT-Extension-Adapter"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwadapter wwimaging wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterPDFSplitFileType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwfiles" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:pdf/generate.xsl" />	


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-files-by-documentid" match="wwsplits:File" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:pdf/generate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:pdf/generate.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Determine PDF target dependency -->
   <!--                                 -->
   <xsl:variable name="VarCopyPDFsFromTargetID" select="wwprojext:GetFormatSetting('pdf-target-dependency')" />

   <!-- Generate PDF files? -->
   <!--                     -->
   <xsl:choose>
    <xsl:when test="string-length($VarCopyPDFsFromTargetID) &gt; 0">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <xsl:when test="wwprojext:GetFormatSetting('pdf-per-group') = 'true'">
     <xsl:call-template name="CreatePDFs" />
    </xsl:when>
   </xsl:choose>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="CreatePDFs">
  <!-- Define TOC styles -->
  <!--                   -->
  <xsl:variable name="VarTOCStylesAsXML">
   <xsl:variable name="VarParagraphRules" select="$GlobalProject/wwproject:Project/wwproject:GlobalConfiguration/wwproject:Rules[@Type = 'Paragraph']/wwproject:Rule" />
   <xsl:for-each select="$VarParagraphRules">
    <xsl:variable name="VarParagraphRule" select="." />

    <xsl:variable name="VarRule" select="wwprojext:GetRule('Paragraph', $VarParagraphRule/@Key)" />
    <xsl:variable name="VarTOCLevelOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'toc-level']/@Value" />
    <xsl:if test="(string-length($VarTOCLevelOption) &gt; 0) and (number($VarTOCLevelOption) &gt; 0)">
     <wwadapter:TOC stylename="{$VarParagraphRule/@Key}" level="{$VarTOCLevelOption}" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarTOCStyles" select="msxsl:node-set($VarTOCStylesAsXML)/wwadapter:TOC" />

  <!-- Groups -->
  <!--        -->
  <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
  <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
  <xsl:for-each select="$VarProjectGroups">
   <xsl:variable name="VarProjectGroup" select="." />

   <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <!-- Load splits -->
    <!--             -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterSplitsType))[1]" />
     <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

     <!-- Identify group documents -->
     <!--                          -->
     <xsl:variable name="VarGroupDependsFilesAsXML">
      <xsl:for-each select="$VarProjectGroup//wwproject:Document">
       <xsl:variable name="VarProjectDocument" select="." />

       <xsl:for-each select="$GlobalFiles[1]">
        <xsl:variable name="VarDocumentDependsFiles" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterDependsType]" />

        <xsl:for-each select="$VarDocumentDependsFiles">
         <xsl:variable name="VarDocumentDependsFile" select="." />

         <xsl:copy-of select="$VarDocumentDependsFile" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarGroupDependsFiles" select="msxsl:node-set($VarGroupDependsFilesAsXML)/wwfiles:File" />

     <!-- Define Adapter link info -->
     <!--                          -->
     <xsl:variable name="VarAdapterGroupFiles" select="$GlobalFiles/wwmode:Empty" />

     <!-- Create PostScript files for PDFs -->
     <!--                                  -->
     <xsl:variable name="VarProgressPostScriptGroupStart" select="wwprogress:Start(count($VarGroupDependsFiles))" />
     <xsl:for-each select="$VarGroupDependsFiles">
      <xsl:variable name="VarDocumentDependsFile" select="." />

      <xsl:variable name="VarProgressPostScriptDocumentStart" select="wwprogress:Start(1)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Determine PDF PostScript file path -->
       <!--                                    -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentDependsFile/@path), concat(translate($ParameterType, ':', '_'),'.pdf'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupDependsFiles)), $VarDocumentDependsFile/@groupID, $VarDocumentDependsFile/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <!-- Generate PDF -->
        <!--              -->
        <xsl:variable name="VarOriginalDocumentPath" select="wwprojext:GetDocumentPath($VarDocumentDependsFile/@documentID)" />
        <xsl:call-template name="PDF-Generate">
         <xsl:with-param name="ParamOriginalDocumentPath" select="$VarOriginalDocumentPath" />
         <xsl:with-param name="ParamDocumentPath" select="$VarDocumentDependsFile/@path" />
         <xsl:with-param name="ParamSingleFile" select="false()" />
         <xsl:with-param name="ParamTOCStyles" select="$VarTOCStyles" />
         <xsl:with-param name="ParamAdapterGroupFiles" select="$VarAdapterGroupFiles" />
         <xsl:with-param name="ParamPDFPath" select="$VarPath" />
        </xsl:call-template>
       </xsl:if>

       <!-- Track PDF PostScript file -->
       <!--                           -->
       <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupDependsFiles))}" groupID="{$VarDocumentDependsFile/@groupID}" documentID="{$VarDocumentDependsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
        <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />

        <!-- All group PDF documents are dependant on each other due to page number offsets -->
        <!--                                                                                -->
        <xsl:for-each select="$VarGroupDependsFiles">
         <xsl:variable name="VarDependency" select="." />

         <wwfiles:Depends path="{$VarDependency/@path}" checksum="{$VarDependency/@checksum}" groupID="{$VarDependency/@groupID}" documentID="{$VarDependency/@documentID}" />
        </xsl:for-each>
       </wwfiles:File>
      </xsl:if>

      <xsl:variable name="VarProgressPostScriptDocumentEnd" select="wwprogress:End()" />
     </xsl:for-each>
     <xsl:variable name="VarProgressPostScriptGroupEnd" select="wwprogress:End()" />
    </xsl:for-each>
   </xsl:if> 

   <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
 </xsl:template>
</xsl:stylesheet>
