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
 <xsl:param name="ParameterTOCInfoType" />
 <xsl:param name="ParameterPDFSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwfiles" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-files-by-groupid-type" match="wwsplits:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwtoc-entries-by-documentid" match="wwtoc:Entry" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
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

    <xsl:when test="wwprojext:GetFormatSetting('pdf-per-group') = 'true'">
     <xsl:call-template name="CreatePDFs" />
    </xsl:when>
   </xsl:choose>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="CreatePDFs">
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
    <xsl:for-each select="$GlobalInput[1]">
     <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterSplitsType))[1]" />
     <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

     <!-- Load group TOC info -->
     <!--                     -->
     <xsl:variable name="VarTOCInfoFile" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterTOCInfoType))[1]" />
     <xsl:variable name="VarTOCInfo" select="wwexsldoc:LoadXMLWithoutResolver($VarTOCInfoFile/@path, false())" />

     <!-- Determine group output path -->
     <!--                             -->
     <xsl:for-each select="$VarSplits[1]">
      <xsl:variable name="VarGroupPDFFile" select="key('wwsplits-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterPDFSplitFileType))[1]" />

      <!-- Locate group files to process -->
      <!--                               -->
      <xsl:variable name="VarGroupPDFMergeFilesAsXML">
       <!-- Process in project order -->
       <!--                          -->
       <xsl:for-each select="$VarProjectGroup//wwproject:Document">
        <xsl:variable name="VarProjectDocument" select="." />

        <xsl:for-each select="$GlobalInput[1]">
         <xsl:variable name="VarDependsFiles" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterDependsType]" />

         <xsl:for-each select="$VarDependsFiles">
          <xsl:variable name="VarDependsFile" select="." />

          <xsl:copy-of select="$VarDependsFile" />
         </xsl:for-each>
        </xsl:for-each>
       </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="VarGroupPDFMergeFiles" select="msxsl:node-set($VarGroupPDFMergeFilesAsXML)/wwfiles:File" />

      <!-- Join PDF files -->
      <!--                -->
      <xsl:variable name="VarGroupPDFMergeFilesCount" select="count($VarGroupPDFMergeFiles)" />
      <xsl:if test="$VarGroupPDFMergeFilesCount &gt; 0">
       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarProjectChecksum" select="concat($GlobalProject/@ChangeID, ':', $VarGroupPDFMergeFilesCount)" />
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarGroupPDFFile/@path, $VarProjectChecksum, $VarGroupPDFFile/@groupID, $VarGroupPDFFile/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <!-- Define link info -->
         <!--                  -->
         <xsl:variable name="VarLinkInfoAsXML">
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


         <!-- Define list of PDFs to merge -->
         <!--                              -->
         <xsl:variable name="VarPDFFileListAsXML">
          <xsl:for-each select="$VarGroupPDFMergeFiles">
           <xsl:variable name="VarGroupPDFMergeFile" select="." />

           <xsl:variable name="VarReferencePath" select="wwfilesystem:GetWithExtensionReplaced(wwprojext:GetDocumentPath($VarGroupPDFMergeFile/@documentID), 'pdf')" />
           <xsl:variable name="VarTOCLevel">
            <xsl:for-each select="$VarTOCInfo[1]">
             <xsl:variable name="VarDocumentTOCEntries" select="key('wwtoc-entries-by-documentid', $VarGroupPDFMergeFile/@documentID)" />
             <xsl:for-each select="$VarDocumentTOCEntries[1]">
              <xsl:variable name="VarDocumentTOCEntry" select="." />

              <xsl:value-of select="count($VarDocumentTOCEntry/ancestor-or-self::wwtoc:Entry[string-length(@level) &gt; 0])"/>
             </xsl:for-each>
            </xsl:for-each>
           </xsl:variable>

           <wwimaging:File path="{$VarGroupPDFMergeFile/@path}" reference-path="{$VarReferencePath}" toclevel="{$VarTOCLevel}"/>
          </xsl:for-each>
         </xsl:variable>
         <xsl:variable name="VarPDFFileList" select="msxsl:node-set($VarPDFFileListAsXML)/wwimaging:File" />

         <!-- Merge PDFs -->
         <!--            -->
         <xsl:variable name="VarPDFJobSettings" select="wwprojext:GetFormatSetting('pdf-job-settings', 'default')" />
         <xsl:variable name="VarMergePDFs" select="wwimaging:MergePDFs($VarPDFFileList, $VarLinkInfo, $VarGroupPDFFile/@path)" />
        </xsl:if>

        <!-- Track PDF file -->
        <!--                -->
        <wwfiles:File path="{$VarGroupPDFFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarGroupPDFFile/@path)}" projectchecksum="{$VarProjectChecksum}" groupID="{$VarGroupPDFFile/@groupID}" documentID="{$VarGroupPDFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <!-- Dependencies -->
         <!--              -->
         <xsl:for-each select="$VarGroupPDFMergeFiles">
          <xsl:variable name="VarGroupPDFMergeFile" select="." />

          <wwfiles:Depends path="{$VarGroupPDFMergeFile/@path}" checksum="{$VarGroupPDFMergeFile/@checksum}" groupID="{$VarGroupPDFMergeFile/@groupID}" documentID="{$VarGroupPDFMergeFile/@documentID}" />
         </xsl:for-each>
        </wwfiles:File>
       </xsl:if>
      </xsl:if>
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

     <!-- Determine group output path -->
     <!--                             -->
     <xsl:for-each select="$VarSplits[1]">
      <xsl:variable name="VarGroupPDFFile" select="key('wwsplits-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterPDFSplitFileType))[1]" />

      <xsl:for-each select="$VarTargetFiles[1]">
       <!-- Locate source PDF -->
       <!--                   -->
       <xsl:for-each select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterType))[1]">
        <xsl:variable name="VarSourcePDFFile" select="." />

        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarGroupPDFFile/@path, $GlobalProject/@ChangeID, $VarGroupPDFFile/@groupID, $VarGroupPDFFile/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <!-- Copy PDF -->
         <!--          -->
         <xsl:variable name="VarCopyPDF" select="wwfilesystem:CopyFile($VarSourcePDFFile/@path, $VarGroupPDFFile/@path)" />
        </xsl:if>

        <!-- Track PDF file -->
        <!--                -->
        <wwfiles:File path="{$VarGroupPDFFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarGroupPDFFile/@path)}" projectchecksum="{$GlobalProject/@ChangeID}" groupID="{$VarGroupPDFFile/@groupID}" documentID="{$VarGroupPDFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <wwfiles:Depends path="{$VarSourcePDFFile/@path}" checksum="{$VarSourcePDFFile/@checksum}" groupID="{$VarSourcePDFFile/@groupID}" documentID="{$VarSourcePDFFile/@documentID}" />
        </wwfiles:File>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
 </xsl:template>
</xsl:stylesheet>
