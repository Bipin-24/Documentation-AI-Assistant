<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
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
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterBrowserXSLType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-documents-by-filename" match="wwproject:Document" use="@FileName" />


 <xsl:include href="wwtransform:reports/printable_html.xsl"/>

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:reports/printable_html.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:reports/printable_html.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:reports/printable_html.css'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:reports/printable_html.css')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocalePathChecksum" select="wwfilesystem:GetChecksum($GlobalUILocalePath)" />
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


 <!-- Construct list of project documents using filename -->
 <!--                                                    -->
 <xsl:variable name="GlobalProjectDocumentsAsXML">
  <xsl:apply-templates select="$GlobalProject" mode="wwmode:project-group-document-filenames" />
 </xsl:variable>
 <xsl:variable name="GlobalProjectDocuments" select="msxsl:node-set($GlobalProjectDocumentsAsXML)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarReportsDirectoryPath" select="wwprojext:GetProjectReportsDirectoryPath()"/><!-- if we want the Assets folder to be on a per-target level, we can use 'GetTargetReportsDirectoryPath() instead. -->
   <xsl:variable name="VarAssestsDirectoryPath" select="wwfilesystem:Combine($VarReportsDirectoryPath, 'Assets')"/>
   
   <!-- Create Assets folder -->
   <!--                      -->   
   <xsl:if test="not(wwfilesystem:DirectoryExists($VarAssestsDirectoryPath))">
    <xsl:variable name="VarCreateAssetsDirectory" select="wwfilesystem:CreateDirectory($VarAssestsDirectoryPath)"/>
   </xsl:if>
   
   <!-- Copy over CSS stylesheet -->
   <!--                          -->
   <xsl:variable name="VarSourceStylesheetPath" select="wwuri:AsFilePath('wwtransform:reports/printable_html.css')" />
   <xsl:variable name="VarTargetStylesheetPath" select="wwfilesystem:Combine($VarAssestsDirectoryPath, wwfilesystem:GetFileName($VarSourceStylesheetPath))" />
   <xsl:if test="wwfilesystem:GetChecksum($VarTargetStylesheetPath) != wwfilesystem:GetChecksum($VarSourceStylesheetPath)">
    <xsl:variable name="VarCopyFile" select="wwfilesystem:CopyFile($VarSourceStylesheetPath, $VarTargetStylesheetPath)" />
   </xsl:if>
   <wwfiles:File path="{$VarTargetStylesheetPath}" type="{$ParameterBrowserXSLType}" checksum="{wwfilesystem:GetChecksum($VarTargetStylesheetPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="" category="" use="" deploy="">
    <wwfiles:Depends path="{$VarSourceStylesheetPath}" checksum="{wwfilesystem:GetChecksum($VarSourceStylesheetPath)}" groupID="" documentID="" />
   </wwfiles:File>

   <!-- Copy over font-awesome-5.15.4 -->
   <!--                               -->
   <xsl:variable name="VarSourceFontAwesomePath" select="wwuri:AsFilePath('wwhelper:font-awesome-5.15.4')" />
   <xsl:variable name="VarTargetFontAwesomePath" select="wwfilesystem:Combine($VarAssestsDirectoryPath, 'font-awesome')" />
   
   <xsl:if test="not(wwfilesystem:DirectoryExists($VarTargetFontAwesomePath))">
    <xsl:variable name="VarCopyDirectoryFiles" select="wwfilesystem:CopyDirectoryFiles($VarSourceFontAwesomePath, $VarTargetFontAwesomePath)" />
   </xsl:if>
   
   <!-- Access localized display name format -->
   <!--                                      -->
   <xsl:variable name="VarPrintableReportDisplayNameFormat" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PrintableReportDisplayNameFormat']/@value" />
   <xsl:variable name="VarXMLReportDisplayNameFormat" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'XMLReportDisplayNameFormat']/@value" />
   
   <!-- Select files to process -->
   <!--                         -->
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarFilesOfType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesOfType))" />

    <xsl:for-each select="$VarFilesOfType">
     <xsl:variable name="VarFileOfType" select="." />

     <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Determine path -->
      <!--                -->
      <xsl:variable name="VarPathHTML">
       <xsl:apply-templates select="$VarFileOfType" mode="wwmode:xhtml-report-file-path">
        <xsl:with-param name="ParamExtensionType" select="'.html'"/>
       </xsl:apply-templates>
      </xsl:variable>
      
      <xsl:variable name="VarPathXML">
       <xsl:apply-templates select="$VarFileOfType" mode="wwmode:xhtml-report-file-path">
        <xsl:with-param name="ParamExtensionType" select="'.xml'"/>
       </xsl:apply-templates>
      </xsl:variable>

      <!-- Valid path? (HTML) -->
      <!--                    -->
      <xsl:if test="string-length($VarPathHTML) &gt; 0">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPathHTML, '', $VarFileOfType/@groupID, $VarFileOfType/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsTreeFragment">
         <!-- Load report -->
         <!--             -->
         <xsl:variable name="VarReport" select="wwexsldoc:LoadXMLWithoutResolver($VarFileOfType/@path, false())" />

         <!-- Copy HTML -->
         <!--           -->
         <xsl:apply-templates select="$VarReport" mode="html-report">
          <xsl:with-param name="ParamPath" select="$VarPathHTML" />
         </xsl:apply-templates>
         
        </xsl:variable>
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPathHTML, 'utf-8', 'xhtml', '5', 'yes')" />
       </xsl:if>

       <!-- Report generated files -->
       <!--                        -->
       <wwfiles:File path="{$VarPathHTML}" displayname="{wwstring:Format($VarPrintableReportDisplayNameFormat, $VarFileOfType/@displayname)}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPathHTML)}" projectchecksum="" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
        <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
        <wwfiles:Depends path="{$VarFileOfType/@path}" checksum="{$VarFileOfType/@checksum}" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" />
       </wwfiles:File>
      </xsl:if>
      
      <!-- Valid path? (XML) -->
      <!--                   -->
      <xsl:if test="string-length($VarPathXML) &gt; 0">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPathXML, '', $VarFileOfType/@groupID, $VarFileOfType/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsTreeFragment">
         <!-- Load report -->
         <!--             -->
         <xsl:variable name="VarReport" select="wwexsldoc:LoadXMLWithoutResolver($VarFileOfType/@path, false())" />

         <!-- Copy XML -->
         <!--          -->
         <xsl:apply-templates select="$VarReport" mode="wwmode:copy-xml" />
        </xsl:variable>
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPathXML, 'utf-8', 'xml', '1.0', 'yes')" />
       </xsl:if>

       <!-- Report generated files -->
       <!--                        -->
       <!-- Make a new report category... parameterize the 'type' and 'category' attributes -->
       <wwfiles:File path="{$VarPathXML}" displayname="{wwstring:Format($VarXMLReportDisplayNameFormat, $VarFileOfType/@displayname)}" type="reports:styles:document:xml" checksum="{wwfilesystem:GetChecksum($VarPathXML)}" projectchecksum="" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="report-xml" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
        <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
        <wwfiles:Depends path="{$VarFileOfType/@path}" checksum="{$VarFileOfType/@checksum}" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" />
       </wwfiles:File>
      </xsl:if>
     </xsl:if>

     <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <!-- project-group-document-filenames -->
 <!--                                  -->

 <xsl:template match="wwproject:Groups" mode="wwmode:project-group-document-filenames">
  <xsl:apply-templates mode="wwmode:group-document-filenames" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:project-group-document-filenames">
  <xsl:apply-templates mode="wwmode:project-group-document-filenames" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="wwmode:project-group-document-filenames">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- group-document-filenames -->
 <!--                          -->

 <xsl:template match="wwproject:Group" mode="wwmode:group-document-filenames">
  <xsl:param name="ParamGroup" />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:document-filenames" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:group-document-filenames">
  <xsl:apply-templates mode="wwmode:group-document-filenames" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="wwmode:group-document-filenames">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- document-filenames -->
 <!--                    -->

 <xsl:template match="wwproject:Document" mode="wwmode:document-filenames">
  <xsl:param name="ParamDocument" select="." />

  <wwproject:Document DocumentID="{$ParamDocument/@DocumentID}" FileName="{translate(wwfilesystem:GetFileName($ParamDocument/@Path), '.', '_')}" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:document-filenames">
  <xsl:apply-templates mode="wwmode:document-filenames" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="wwmode:document-filenames">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- xhtml-report-file-path -->
 <!--                        -->

 <xsl:template match="wwfiles:File" mode="wwmode:xhtml-report-file-path">
  <xsl:param name="ParamFile" select="." />
  <xsl:param name="ParamExtensionType" />

  <!-- Report Group Directory Path -->
  <!--                             -->
  <xsl:variable name="VarReportGroupDirectoryPath">
   <!-- Group context defined? -->
   <!--                        -->
   <xsl:variable name="VarGroupName">
    <xsl:if test="string-length($ParamFile/@groupID) &gt; 0">
     <xsl:value-of select="wwprojext:GetGroupName($ParamFile/@groupID)" />
    </xsl:if>
   </xsl:variable>

   <!-- Emit Report Group Directory Path -->
   <!--                                  -->
   <xsl:if test="string-length($VarGroupName) &gt; 0">
    <xsl:choose>
     <xsl:when test="$ParamExtensionType = '.xml'">
      <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetReportsDirectoryPath(), wwfilesystem:MakeValidFileName($VarGroupName), 'XML')" />
     </xsl:when>
     <xsl:when test="$ParamExtensionType = '.html'">
      <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetReportsDirectoryPath(), wwfilesystem:MakeValidFileName($VarGroupName), 'Printable')" />
     </xsl:when>
     <xsl:otherwise>
      <!-- do nothing -->
      <!--            -->
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:variable>

  <!-- Report Document Directory Path -->
  <!--                                -->
  <xsl:variable name="VarReportDocumentDirectoryPath">
   <!-- Group report directory path defined? -->
   <!--                                      -->
   <xsl:if test="string-length($VarReportGroupDirectoryPath) &gt; 0">
    <!-- Document context defined? -->
    <!--                           -->
    <xsl:if test="string-length($ParamFile/@documentID) &gt; 0">
     <!-- Get document file name -->
     <!--                        -->
     <xsl:variable name="VarDocumentFileName" select="translate(wwfilesystem:GetFileName(wwprojext:GetDocumentPath($ParamFile/@documentID)), '.', '_')" />

     <!-- Unique file name -->
     <!--                  -->
     <xsl:variable name="VarUniqueDocumentFileName">
      <xsl:value-of select="$VarDocumentFileName" />

      <xsl:for-each select="$GlobalProjectDocuments[1]">
       <xsl:variable name="VarGroupDocumentsWithFileName" select="key('wwproject-documents-by-filename', $VarDocumentFileName)[../@GroupID = $ParamFile/@groupID]" />

       <!-- Qualifier -->
       <!--           -->
       <xsl:for-each select="$VarGroupDocumentsWithFileName">
        <xsl:variable name="VarGroupDocumentWithFileName" select="." />

        <!-- Only qualify if not the first document -->
        <!--                                        -->
        <xsl:if test="position() &gt; 1">
         <xsl:variable name="VarGroupDocumentWithFileNameGroupID" select="$VarGroupDocumentWithFileName/ancestor::wwproject:Group/@GroupID" />
         <xsl:if test="($VarGroupDocumentWithFileNameGroupID = $ParamFile/@groupID) and ($VarGroupDocumentWithFileName/@DocumentID = $ParamFile/@documentID)">
          <!-- Emit qualifier -->
          <!--                -->
          <xsl:text>_</xsl:text>
          <xsl:value-of select="position()" />
         </xsl:if>
        </xsl:if>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:variable>

     <!-- Emit Report Document Directory Path -->
     <!--                                     -->
     <xsl:if test="string-length($VarUniqueDocumentFileName) &gt; 0">
      <xsl:choose>
       <xsl:when test="$ParamExtensionType = '.xml'">
        <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetReportsDirectoryPath(), wwprojext:GetDocumentGroupPath($ParamFile/@documentID), 'XML', wwfilesystem:MakeValidFileName($VarUniqueDocumentFileName))" />
       </xsl:when>
       <xsl:when test="$ParamExtensionType = '.html'">
        <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetReportsDirectoryPath(), wwprojext:GetDocumentGroupPath($ParamFile/@documentID), 'Printable', wwfilesystem:MakeValidFileName($VarUniqueDocumentFileName))" />
       </xsl:when>
       <xsl:otherwise>
        <!-- do nothing -->
        <!--            -->
       </xsl:otherwise>
      </xsl:choose>
     </xsl:if>
    </xsl:if>
   </xsl:if>
  </xsl:variable>

  <!-- Determine directory path -->
  <!--                          -->
  <xsl:variable name="VarDirectoryPath">
   <xsl:choose>
    <xsl:when test="string-length($VarReportDocumentDirectoryPath) &gt; 0">
     <!-- Document Directory -->
     <!--                    -->
     <xsl:value-of select="$VarReportDocumentDirectoryPath" />
    </xsl:when>

    <xsl:when test="string-length($VarReportGroupDirectoryPath) &gt; 0">
     <!-- Group Directory -->
     <!--                 -->
     <xsl:value-of select="$VarReportGroupDirectoryPath" />
    </xsl:when>

    <xsl:otherwise>
     <!-- Base Directory -->
     <!--                -->
     <xsl:value-of select="wwprojext:GetTargetReportsDirectoryPath()" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Determine file path -->
  <!--                     -->
  <xsl:choose>
   <xsl:when test="$ParamExtensionType = '.html'">
    <xsl:variable name="VarFileName" select="wwfilesystem:GetWithExtensionReplaced(wwfilesystem:GetFileName($ParamFile/@path), '.html')" />
    <xsl:variable name="VarFilePath" select="wwfilesystem:Combine($VarDirectoryPath, $VarFileName)" />
    <xsl:value-of select="$VarFilePath" />
   </xsl:when>
   <xsl:when test="$ParamExtensionType = '.xml'">
    <xsl:variable name="VarFilePath" select="wwfilesystem:Combine($VarDirectoryPath, wwfilesystem:GetFileName($ParamFile/@path))" />
    <xsl:value-of select="$VarFilePath" />
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:xhtml-report-file-path">
  <xsl:apply-templates mode="wwmode:xhtml-report-file-path" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="wwmode:xhtml-report-file-path">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- copy-xml -->
 <!--          -->

 <xsl:template match="*" mode="wwmode:copy-xml">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:copy-xml" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="wwmode:copy-xml">
  <xsl:copy />
 </xsl:template>


 <xsl:template match="processing-instruction" mode="wwmode:copy-xml">
  <!-- Suppress all processing instuctions -->
  <!--                                     -->
 </xsl:template>
</xsl:stylesheet>
