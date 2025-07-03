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
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwfiles" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:pdf/generate.xsl" />	


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwsplits-files-by-documentid" match="wwsplits:File" use="@documentID" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />


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
     <xsl:call-template name="CopyPDFs">
      <xsl:with-param name="ParamCopyPDFsFromTargetID" select="$VarCopyPDFsFromTargetID" />
     </xsl:call-template>
    </xsl:when>

    <xsl:when test="wwprojext:GetFormatSetting('pdf-per-document') = 'true'">
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

     <!-- Process group input documents -->
     <!--                               -->
     <xsl:for-each select="$GlobalInput[1]">
      <!-- Define Adapter link info -->
      <!--                          -->
      <xsl:variable name="VarAdapterGroupFiles" select="$GlobalFiles/wwmode:Empty" />

      <!-- Define link info -->
      <!--                  -->
      <xsl:variable name="VarLinkInfoAsXML">
       <!-- Create entries for all PDF document files -->
       <!--                                           -->
       <xsl:for-each select="$VarSplits/wwsplits:Splits/wwsplits:File[@type = $ParameterPDFSplitFileType]">
        <xsl:variable name="VarSplitPDFFile" select="." />

        <xsl:if test="(string-length($VarSplitPDFFile/@documentID) &gt; 0) and (string-length($VarSplitPDFFile/@path) &gt; 0)">
         <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:GetWithExtensionReplaced(wwprojext:GetDocumentPath($VarSplitPDFFile/@documentID), 'pdf')" />

         <!-- Record link info with original file path and .pdf file path -->
         <!--                                                             -->
         <wwimaging:LinkInfo source="{wwprojext:GetDocumentPath($VarSplitPDFFile/@documentID)}" target="{$VarSplitPDFFile/@path}" />
         <wwimaging:LinkInfo source="{$VarSourceDocumentPath}" target="{$VarSplitPDFFile/@path}" />
        </xsl:if>
       </xsl:for-each>

       <!-- Create entries for all non-document files -->
       <!--                                           -->
       <xsl:for-each select="$VarSplits/wwsplits:Splits/wwsplits:File[@documentID = '']">
        <xsl:variable name="VarSplitFile" select="." />

        <xsl:if test="(string-length($VarSplitFile/@source) &gt; 0) and (string-length($VarSplitFile/@path) &gt; 0)">
         <wwimaging:LinkInfo source="{wwuri:AsFilePath($VarSplitFile/@source)}" target="{$VarSplitFile/@path}" />
        </xsl:if>
       </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwimaging:LinkInfo" />

      <!-- Iterate input documents -->
      <!--                         -->
      <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />
      <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarFilesByType))" />
      <xsl:for-each select="$VarFilesByType">
       <xsl:variable name="VarDocument" select="." />

       <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <!-- Define document PDF file path -->
        <!--                               -->
        <xsl:variable name="VarDocumentPDFFilePath">
         <xsl:for-each select="$VarSplits[1]">
          <xsl:variable name="VarDocumentPDFSplitsFile" select="key('wwsplits-files-by-documentid', $VarDocument/@documentID)[@type = $ParameterPDFSplitFileType]" />
          <xsl:value-of select="$VarDocumentPDFSplitsFile/@path" />
         </xsl:for-each>
        </xsl:variable>

        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarOutputPath" select="$VarDocumentPDFFilePath" />
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarOutputPath, $GlobalProject/wwproject:Project/@ChangeID, $VarDocument/@groupID, $VarDocument/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <!-- Generate PDF -->
         <!--              -->
         <xsl:variable name="VarOriginalDocumentPath" select="wwprojext:GetDocumentPath($VarDocument/@documentID)" />
         <xsl:variable name="VarTempPDFPath" select="wwfilesystem:GetTempFileName()" />
         <xsl:call-template name="PDF-Generate">
          <xsl:with-param name="ParamOriginalDocumentPath" select="$VarOriginalDocumentPath" />
          <xsl:with-param name="ParamDocumentPath" select="$VarDocument/@path" />
          <xsl:with-param name="ParamSingleFile" select="true()" />
          <xsl:with-param name="ParamTOCStyles" select="$VarTOCStyles" />
          <xsl:with-param name="ParamAdapterGroupFiles" select="$VarAdapterGroupFiles" />
          <xsl:with-param name="ParamPDFPath" select="$VarTempPDFPath" />
         </xsl:call-template>

         <!-- Map PDF Links -->
         <!--               -->
         <xsl:variable name="VarMapPDFLinks" select="wwimaging:MapPDFLinks($VarLinkInfo, $VarTempPDFPath, $VarOutputPath, $VarOriginalDocumentPath, $VarOutputPath, false())" />
         <xsl:variable name="VarDeleteTempPDF" select="wwfilesystem:DeleteFile($VarTempPDFPath)" />
        </xsl:if>

        <!-- Track PDF file -->
        <!--                -->
        <wwfiles:File path="{$VarOutputPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarOutputPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocument/@groupID}" documentID="{$VarDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
         <wwfiles:Depends path="{$VarDocument/@path}" checksum="{$VarDocument/@checksum}" groupID="{$VarDocument/@groupID}" documentID="{$VarDocument/@documentID}" />
        </wwfiles:File>
       </xsl:if>

       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
      </xsl:for-each>

      <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
 </xsl:template>


 <xsl:template name="CopyPDFs">
  <xsl:param name="ParamCopyPDFsFromTargetID" />

  <!-- Load target files -->
  <!--                   -->
  <xsl:variable name="VarTargetFiles" select="wwexsldoc:LoadXMLWithoutResolver(wwprojext:GetTargetFilesInfoPath($ParamCopyPDFsFromTargetID), false())" />

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

     <!-- Process group documents -->
     <!--                               -->
     <xsl:for-each select="$VarSplits[1]">
      <!-- Iterate documents -->
      <!--                   -->
      <xsl:variable name="VarDocumentPDFSplitsFiles" select="key('wwsplits-files-by-type', $ParameterPDFSplitFileType)" />
      <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarDocumentPDFSplitsFiles))" />
      <xsl:for-each select="$VarDocumentPDFSplitsFiles">
       <xsl:variable name="VarDocumentPDFSplitsFile" select="." />

       <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <xsl:for-each select="$VarTargetFiles[1]">
         <!-- Locate source PDF -->
         <!--                   -->
         <xsl:for-each select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterType))[@documentID = $VarDocumentPDFSplitsFile/@documentID][1]">
          <xsl:variable name="VarSourcePDFFile" select="." />

          <!-- Up-to-date? -->
          <!--             -->
          <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarDocumentPDFSplitsFile/@path, $GlobalProject/wwproject:Project/@ChangeID, $VarDocumentPDFSplitsFile/@groupID, $VarDocumentPDFSplitsFile/@documentID, $GlobalActionChecksum)" />
          <xsl:if test="not($VarUpToDate)">
           <!-- Copy PDF -->
           <!--          -->
           <xsl:variable name="VarCopyPDF" select="wwfilesystem:CopyFile($VarSourcePDFFile/@path, $VarDocumentPDFSplitsFile/@path)" />
          </xsl:if>

          <!-- Track PDF file -->
          <!--                -->
          <wwfiles:File path="{$VarDocumentPDFSplitsFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarDocumentPDFSplitsFile/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentPDFSplitsFile/@groupID}" documentID="{$VarDocumentPDFSplitsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
           <wwfiles:Depends path="{$VarSourcePDFFile/@path}" checksum="{$VarSourcePDFFile/@checksum}" groupID="{$VarSourcePDFFile/@groupID}" documentID="{$VarSourcePDFFile/@documentID}" />
          </wwfiles:File>
         </xsl:for-each>
        </xsl:for-each>
       </xsl:if>

       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
      </xsl:for-each>

      <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
 </xsl:template>
</xsl:stylesheet>
