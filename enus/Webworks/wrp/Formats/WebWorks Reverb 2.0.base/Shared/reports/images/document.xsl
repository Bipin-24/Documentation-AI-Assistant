<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Reports-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwbehaviors wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwformat:Transforms/reports.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-frames-by-documentid" match="wwsplits:Frame" use="@documentID" />
 <xsl:key name="wwdoc-frames-by-id" match="wwdoc:Frame" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
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


 <!-- Severities -->
 <!--            -->
 <xsl:variable name="GlobalImagesByRefSourceMissingSeverity" select="wwprojext:GetFormatSetting('report-images-byref-source-missing')" />
 <xsl:variable name="GlobalImagesInTableCells" select="wwprojext:GetFormatSetting('report-images-in-table-cells')" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-images-generate', 'true') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="(($VarGenerateReportSetting) or ($VarRequestedPipeline)) and ($GlobalImagesByRefSourceMissingSeverity != 'ignore')" />

   <xsl:if test="$VarGenerateReport">
    <!-- Load project links -->
    <!--                    -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarLinksFileInfo" select="key('wwfiles-files-by-type', $ParameterLinksType)" />
     <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksFileInfo/@path, false())" />

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
       <xsl:for-each select="$GlobalFiles[1]">
        <!-- Group Splits -->
        <!--              -->
        <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
        <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

        <!-- Iterate input documents -->
        <!--                         -->
        <xsl:for-each select="$GlobalInput[1]">
         <!-- Documents -->
         <!--           -->
         <xsl:variable name="VarGroupDocumentFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />
         <xsl:variable name="VarProgressGroupDocumentsStart" select="wwprogress:Start(count($VarGroupDocumentFiles))" />
         <xsl:for-each select="$VarGroupDocumentFiles">
          <xsl:variable name="VarDocumentFile" select="." />

          <xsl:variable name="VarProgressGroupDocumentStart" select="wwprogress:Start(1)" />

          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <!-- Up-to-date? -->
           <!--             -->
           <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
           <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarDocumentFile/@groupID, $VarDocumentFile/@documentID, $GlobalActionChecksum)" />
           <xsl:if test="not($VarUpToDate)">
            <xsl:variable name="VarResultAsTreeFragment">
             <xsl:call-template name="Images-Report">
              <xsl:with-param name="ParamLinks" select="$VarLinks" />
              <xsl:with-param name="ParamSplits" select="$VarSplits" />
              <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
           </xsl:if>

           <!-- Report generated files -->
           <!--                        -->
           <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ImagesReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
            <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
            <wwfiles:Depends path="{$VarLinksFileInfo/@path}" checksum="{$VarLinksFileInfo/@checksum}" groupID="{$VarLinksFileInfo/@groupID}" documentID="{$VarLinksFileInfo/@documentID}" />
            <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
            <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
           </wwfiles:File>
          </xsl:if>

          <xsl:variable name="VarProgressGroupDocumentEnd" select="wwprogress:End()" />
         </xsl:for-each>
         <xsl:variable name="VarProgressGroupDocumentsEnd" select="wwprogress:End()" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:if>

      <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
    </xsl:for-each>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Images-Report">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Load document -->
  <!--               -->
  <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentFile/@path, false())" />

  <!-- Generate report -->
  <!--                 -->
  <wwreport:Report version="1.0">
   <!-- Report missing by-reference sources -->
   <!--                                     -->
   <xsl:if test="$GlobalImagesByRefSourceMissingSeverity != 'ignore'">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$ParamSplits[1]">
      <xsl:apply-templates select="key('wwsplits-frames-by-documentid', $ParamDocumentFile/@documentID)" mode="wwmode:byref-source-missing">
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
      </xsl:apply-templates>
     </xsl:for-each>
    </xsl:if>
   </xsl:if>

   <!-- Report missing by-reference sources -->
   <!--                                     -->
   <xsl:if test="$GlobalImagesInTableCells != 'ignore'">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$ParamSplits[1]">
      <xsl:apply-templates select="key('wwsplits-frames-by-documentid', $ParamDocumentFile/@documentID)" mode="wwmode:images-in-table-cells">
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
      </xsl:apply-templates>
     </xsl:for-each>
    </xsl:if>
   </xsl:if>
  </wwreport:Report>
 </xsl:template>

 <xsl:template name="Navigation-Output-Destination">
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <xsl:variable name="VarLinkAsXML">
   <!-- Determine paragraph ID -->
   <!--                        -->
   <xsl:variable name="VarParagraphID">
    <xsl:for-each select="$ParamDocument[1]">
     <xsl:variable name="VarDocumentFrame" select="key('wwdoc-frames-by-id', $ParamSplitsFrame/@id)" />

     <xsl:choose>
      <!-- Use parent paragraph -->
      <!--                      -->
      <xsl:when test="string-length($VarDocumentFrame/ancestor::wwdoc:Paragraph[1]/@id) &gt; 0">
       <xsl:value-of select="$VarDocumentFrame/ancestor::wwdoc:Paragraph[1]/@id" />
      </xsl:when>

      <!-- Use preceding paragraph -->
      <!--                         -->
      <xsl:when test="string-length($VarDocumentFrame/preceding-sibling::wwdoc:Paragraph[1]/@id) &gt; 0">
       <xsl:value-of select="$VarDocumentFrame/preceding-sibling::wwdoc:Paragraph[1]/@id" />
      </xsl:when>

      <!-- Give up -->
      <!--         -->
      <xsl:otherwise>
       <xsl:value-of select="''" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:variable>

   <!-- Determined paragraph ID? -->
   <!--                          -->
   <xsl:if test="string-length($VarParagraphID) &gt; 0">
    <xsl:call-template name="Report-OutputLink">
     <xsl:with-param name="ParamProject" select="$GlobalProject" />
     <xsl:with-param name="ParamLinksContext" select="$ParamLinks" />
     <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
     <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
     <xsl:with-param name="ParamParagraphID" select="$VarParagraphID" />
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
  <xsl:if test="count($VarLink) = 1">
   <wwreport:Navigation context="output">
    <xsl:copy-of select="$VarLink" />
   </wwreport:Navigation>
  </xsl:if>
 </xsl:template>


 <!-- wwmode:byref-source-missing -->
 <!--                             -->

 <xsl:template match="wwsplits:Frame[string-length(@byref-source-missing) &gt; 0]" mode="wwmode:byref-source-missing">
  <xsl:param name="ParamSplitsFrame" select="." />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Graphic Rule -->
   <!--              -->
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Report! -->
    <!--         -->
    <wwreport:Entry context="images" type="byref-source-missing" severity="{$GlobalImagesByRefSourceMissingSeverity}">
     <wwreport:Description>
      <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ImagesByRefSourceMissing']/@value, $ParamSplitsFrame/@byref-source-missing, $ParamSplitsFrame/@path)" />
     </wwreport:Description>

     <wwreport:Navigation context="source">
      <wwreport:Link protocol="adapter">
       <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
       <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
       <wwreport:Data key="ID" value="{$ParamSplitsFrame/@id}" />
      </wwreport:Link>
     </wwreport:Navigation>

     <!-- Navigate to output destination -->
     <!--                                -->
     <xsl:call-template name="Navigation-Output-Destination">
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
     </xsl:call-template>

     <wwreport:Navigation context="details">
      <wwreport:Link protocol="wwh5api">
       <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
       <wwreport:Data key="Context" value="preparing" />
       <wwreport:Data key="Topic" value="images_byref_source_missing" />
      </wwreport:Link>
     </wwreport:Navigation>
    </wwreport:Entry>
   </xsl:if>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:byref-source-missing">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:byref-source-missing">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:byref-source-missing">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="comment() | processing-instruction() | text()" mode="wwmode:byref-source-missing">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- images-in-table-cells -->
 <!--                       -->

 <xsl:template match="wwsplits:Frame" mode="wwmode:images-in-table-cells">
  <xsl:param name="ParamSplitsFrame" select="." />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Graphic Rule -->
   <!--              -->
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <xsl:for-each select="$ParamDocument[1]">
     <xsl:variable name="VarDocumentFrame" select="key('wwdoc-frames-by-id', $ParamSplitsFrame/@id)" />

     <!-- Within table? -->
     <!--               -->
     <xsl:for-each select="$VarDocumentFrame/ancestor::wwdoc:Table[1]">
      <xsl:variable name="VarTable" select="." />

      <!-- Emit table as table? -->
      <!--                      -->
      <xsl:variable name="VarTableContextRule" select="wwprojext:GetContextRule('Table', $VarTable/@stylename, $ParamDocumentFile/@documentID, $VarTable/@id)" />
      <xsl:variable name="VarEmitAsTableOption" select="$VarTableContextRule/wwproject:Options/wwproject:Option[@Name = 'table-as-table']/@Value" />
      <xsl:variable name="VarEmitAsTable" select="($VarEmitAsTableOption = 'true') or ($VarEmitAsTableOption = '')" />
      <xsl:if test="$VarEmitAsTable">
       <!-- Report! -->
       <!--         -->
       <wwreport:Entry context="images" type="image-in-table-cell" severity="{$GlobalImagesByRefSourceMissingSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ImagesInTableCell']/@value, $ParamSplitsFrame/@path)" />
        </wwreport:Description>

        <wwreport:Navigation context="source">
         <wwreport:Link protocol="adapter">
          <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
          <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
          <wwreport:Data key="ID" value="{$ParamSplitsFrame/@id}" />
         </wwreport:Link>
        </wwreport:Navigation>

        <!-- Navigate to output destination -->
        <!--                                -->
        <xsl:call-template name="Navigation-Output-Destination">
         <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
        </xsl:call-template>

        <wwreport:Navigation context="details">
         <wwreport:Link protocol="wwh5api">
          <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
          <wwreport:Data key="Context" value="preparing" />
          <wwreport:Data key="Topic" value="images_in_table_cell" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:images-in-table-cells">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:images-in-table-cells">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:images-in-table-cells">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="comment() | processing-instruction() | text()" mode="wwmode:images-in-table-cells">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamDocument" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
