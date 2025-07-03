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
 <xsl:param name="ParameterAllowBaggage" />
 <xsl:param name="ParameterAllowGroupToGroup" />
 <xsl:param name="ParameterAllowURL" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwformat:Transforms/reports.xsl" />
 <xsl:include href="wwtransform:common/accessibility/images.xsl" />
 <xsl:include href="wwtransform:common/accessibility/tables.xsl" />
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/links/resolve.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwbehaviors-frames-by-id" match="wwbehaviors:Frame" use="@id" />
 <xsl:key name="wwbehaviors-tables-by-id" match="wwbehaviors:Table" use="@id" />
 <xsl:key name="wwsplits-frames-by-id" match="wwsplits:Frame" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/links/resolve.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/links/resolve.xsl')))" />
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
 <xsl:variable name="GlobalAccessibilityImageAltTagsSeverity" select="wwprojext:GetFormatSetting('report-accessibility-image-alt-tags', 'warning')" />
 <xsl:variable name="GlobalAccessibilityImageMapAltTagsSeverity" select="wwprojext:GetFormatSetting('report-accessibility-image-map-alt-tags', 'warning')" />
 <xsl:variable name="GlobalAccessibilityImageLongDescriptionsSeverity" select="wwprojext:GetFormatSetting('report-accessibility-image-long-descriptions', 'warning')" />
 <xsl:variable name="GlobalAccessibilityTableSummariesSeverity" select="wwprojext:GetFormatSetting('report-accessibility-table-summaries', 'warning')" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-accessibility-generate', 'false') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="($VarGenerateReportSetting) or ($VarRequestedPipeline)" />

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
             <xsl:call-template name="Accessibility-Report">
              <xsl:with-param name="ParamLinks" select="$VarLinks" />
              <xsl:with-param name="ParamSplits" select="$VarSplits" />
              <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
           </xsl:if>

           <!-- Report generated files -->
           <!--                        -->
           <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'AccessibilityReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
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


 <xsl:template name="Accessibility-Report">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Load document -->
  <!--               -->
  <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentFile/@path, false())" />

  <!-- Load behaviors -->
  <!--                -->
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-documentid', $ParamDocumentFile/@documentID)[@type = $ParameterBehaviorsType][1]" />
   <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

   <!-- Generate report -->
   <!--                 -->
   <wwreport:Report version="1.0">

    <xsl:apply-templates select="$VarDocument/wwdoc:Document/wwdoc:Content" mode="wwmode:accessibility">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    </xsl:apply-templates>

   </wwreport:Report>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Process-Node">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamRuleType" />

  <!-- Retrieve context rule -->
  <!--                       -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule($ParamRuleType, $ParamNode/@stylename, $ParamDocumentFile/@documentID, $ParamNode/@id)" />

  <!-- Generate Option -->
  <!--                 -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />

  <!-- Generate? -->
  <!--           -->
  <xsl:if test="$VarGenerateOutput">
   <!-- Inside pass-through? -->
   <!--                      -->
   <xsl:variable name="VarPassThrough">
    <xsl:call-template name="Conditions-PassThrough">
     <xsl:with-param name="ParamConditions" select="$ParamNode/wwdoc:Conditions" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Process if not pass-through -->
   <!--                             -->
   <xsl:if test="$VarPassThrough != 'true'">
    <!-- Process node! -->
    <!--               -->
    <xsl:value-of select="true()" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Check-Table">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamTable" />

  <!-- Anything to report? -->
  <!--                     -->
  <xsl:if test="$GlobalAccessibilityTableSummariesSeverity != 'ignore'">
   <!-- Get table behavior -->
   <!--                    -->
   <xsl:for-each select="$ParamBehaviors[1]">
    <xsl:variable name="VarBehavior" select="key('wwbehaviors-tables-by-id', $ParamTable/@id)[1]" />

    <xsl:for-each select="$VarBehavior">
     <!-- Summary required? -->
     <!--                   -->
     <xsl:variable name="VarSummaryRequired">
      <xsl:call-template name="Tables-SummaryRequired">
       <xsl:with-param name="ParamTableBehavior" select="$VarBehavior" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:if test="$VarSummaryRequired = 'true'">
      <!-- Summary -->
      <!--         -->
      <xsl:variable name="VarSummary">
       <xsl:call-template name="Tables-Summary">
        <xsl:with-param name="ParamTableBehavior" select="$VarBehavior" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Summary exists? -->
      <!--                 -->
      <xsl:if test="string-length($VarSummary) = 0">
       <wwreport:Entry context="accessibility" type="missing-table-summary" severity="{$GlobalAccessibilityTableSummariesSeverity}">

        <wwreport:Description>
         <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'AccessibilityMissingTableSummary']/@value" />
        </wwreport:Description>

        <wwreport:Navigation context="source">
         <wwreport:Link protocol="adapter">
          <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
          <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
          <wwreport:Data key="ID" value="{$ParamTable/@id}" />
         </wwreport:Link>
        </wwreport:Navigation>

        <!-- Get output navigation link from format itself -->
        <!--                                               -->
        <xsl:variable name="VarLinkAsXML">
         <xsl:call-template name="Report-OutputLink">
          <xsl:with-param name="ParamProject" select="$GlobalProject" />
          <xsl:with-param name="ParamLinksContext" select="$ParamLinks" />
          <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
          <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
          <xsl:with-param name="ParamParagraphID" select="$ParamTable//wwdoc:Paragraph[1]/@id" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
        <xsl:if test="count($VarLink) = 1">
         <wwreport:Navigation context="output">
          <xsl:copy-of select="$VarLink" />
         </wwreport:Navigation>
        </xsl:if>

        <wwreport:Navigation context="details">
         <wwreport:Link protocol="wwh5api">
          <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
          <wwreport:Data key="Context" value="preparing" />
          <wwreport:Data key="Topic" value="tables_without_summaries" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>


 <xsl:template name="LinkInfo">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocumentLink" />

  <xsl:element name="LinkInfo" namespace="urn:WebWorks-Engine-Links-Schema">
   <xsl:if test="count($ParamDocumentLink) &gt; 0">
    <!-- Resolve link -->
    <!--              -->
    <xsl:variable name="VarResolvedLinkInfoAsXML">
     <xsl:call-template name="Links-Resolve">
      <xsl:with-param name="ParamAllowBaggage" select="$ParameterAllowBaggage" />
      <xsl:with-param name="ParamAllowGroupToGroup" select="$ParameterAllowGroupToGroup" />
      <xsl:with-param name="ParamAllowURL" select="$ParameterAllowURL" />
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType" />
      <xsl:with-param name="ParamProject" select="$GlobalProject" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamSplitGroupID" select="$ParamSplit/@groupID" />
      <xsl:with-param name="ParamSplitDocumentID" select="$ParamSplit/@documentID" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedLinkInfo" select="msxsl:node-set($VarResolvedLinkInfoAsXML)/wwlinks:ResolvedLink" />

    <xsl:choose>
     <!-- Baggage -->
     <!--         -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'baggage'">
      <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

      <xsl:attribute name="href">
       <xsl:value-of select="$VarRelativePath" />
      </xsl:attribute>
     </xsl:when>

     <!-- Document -->
     <!--          -->
     <xsl:when test="($VarResolvedLinkInfo/@type = 'document') or ($VarResolvedLinkInfo/@type = 'group') or ($VarResolvedLinkInfo/@type = 'project')">
      <xsl:attribute name="href">
       <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

       <xsl:value-of select="$VarRelativePath" />
       <xsl:if test="(string-length($ParamDocumentLink/@anchor) &gt; 0) and ($VarResolvedLinkInfo/@first != 'true') and (string-length($VarResolvedLinkInfo/@linkid) &gt; 0)">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$VarResolvedLinkInfo/@linkid" />
       </xsl:if>
      </xsl:attribute>
     </xsl:when>

     <!-- URL -->
     <!--     -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'url'">
      <xsl:attribute name="href">
       <xsl:value-of select="$VarResolvedLinkInfo/@url" />
      </xsl:attribute>
     </xsl:when>
    </xsl:choose>
   </xsl:if>
  </xsl:element>
 </xsl:template>


 <xsl:template name="Check-ImageMap">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamParentBehavior" />
  <xsl:param name="ParamSplit" />

  <!-- Process child frames first -->
  <!--                            -->
  <xsl:for-each select="$ParamFrame/wwdoc:Content//wwdoc:Frame[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]">
   <xsl:call-template name="Check-ImageMap">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamFrame" select="." />
    <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </xsl:for-each>

  <!-- Get link info -->
  <!--               -->
  <xsl:variable name="VarLinkInfoAsXML">
   <xsl:choose>
    <xsl:when test="count($ParamFrame/wwdoc:Link[1]) = 1">
     <!-- Resolve link -->
     <!--              -->
     <xsl:call-template name="LinkInfo">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamFrame/wwdoc:Link[1]" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarChildLinks" select="$ParamFrame/wwdoc:Content//wwdoc:Link[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]" />
     <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />

     <xsl:if test="$VarChildLinksCount &gt; 0">
      <!-- Resolve link -->
      <!--              -->
      <xsl:call-template name="LinkInfo">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamDocumentLink" select="$VarChildLinks[$VarChildLinksCount]" />
      </xsl:call-template>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:ResolvedLink" />

  <!-- Link exists! -->
  <!--              -->
  <xsl:if test="string-length($VarLinkInfo/@href) &gt; 0">
   <!-- Alt Text -->
   <!--          -->
   <xsl:variable name="VarAltText">
    <xsl:call-template name="Images-ImageAreaAltText">
     <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Alt Text exists? -->
   <!--                  -->
   <xsl:if test="string-length($VarAltText) = 0">
    <wwreport:Entry context="accessibility" type="missing-image-map-alt-text" severity="{$GlobalAccessibilityImageMapAltTagsSeverity}">

     <wwreport:Description>
      <xsl:variable name="VarURL">
       <xsl:value-of select="$VarLinkInfo/@href" />
       <xsl:if test="string-length($VarLinkInfo/@anchor) &gt; 0">
        <xsl:value-of select="$VarLinkInfo/@anchor" />
       </xsl:if>
      </xsl:variable>

      <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'AccessibilityMissingImageLinkAltText']/@value, $VarURL)" />
     </wwreport:Description>

     <wwreport:Navigation context="source">
      <wwreport:Link protocol="adapter">
       <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
       <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
       <wwreport:Data key="ID" value="{$ParamParentBehavior/@id}" />
      </wwreport:Link>
     </wwreport:Navigation>

     <!-- Get output navigation link from format itself -->
     <!--                                               -->
     <xsl:variable name="VarLinkAsXML">
      <xsl:call-template name="Report-OutputLink">
       <xsl:with-param name="ParamProject" select="$GlobalProject" />
       <xsl:with-param name="ParamLinksContext" select="$ParamLinks" />
       <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
       <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
       <xsl:with-param name="ParamParagraphID" select="$ParamFrame//ancestor::wwdoc:Paragraph[last()]/@id" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
     <xsl:if test="count($VarLink) = 1">
      <wwreport:Navigation context="output">
       <xsl:copy-of select="$VarLink" />
      </wwreport:Navigation>
     </xsl:if>

     <wwreport:Navigation context="details">
      <wwreport:Link protocol="wwh5api">
       <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
       <wwreport:Data key="Context" value="preparing" />
       <wwreport:Data key="Topic" value="image_links_without_alt_text" />
      </wwreport:Link>
     </wwreport:Navigation>
    </wwreport:Entry>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Check-Frame">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamFrame" />

  <!-- Anything to report? -->
  <!--                     -->
  <xsl:if test="($GlobalAccessibilityImageAltTagsSeverity != 'ignore') or ($GlobalAccessibilityImageMapAltTagsSeverity != 'ignore') or ($GlobalAccessibilityImageLongDescriptionsSeverity != 'ignore')">
   <!-- Get frame behavior -->
   <!--                    -->
   <xsl:for-each select="$ParamBehaviors[1]">
    <xsl:variable name="VarBehavior" select="key('wwbehaviors-frames-by-id', $ParamFrame/@id)[1]" />

    <xsl:for-each select="$VarBehavior">
     <!-- Get frame split -->
     <!--                 -->
     <xsl:for-each select="$ParamSplits[1]">
      <xsl:variable name="VarSplitsFrame" select="key('wwsplits-frames-by-id', $ParamFrame/@id)[@documentID = $ParamDocumentFile/@documentID][1]" />

      <xsl:for-each select="$VarSplitsFrame">
       <!-- Report on alt text? -->
       <!--                     -->
       <xsl:if test="$GlobalAccessibilityImageAltTagsSeverity != 'ignore'">
        <!-- Alt Text -->
        <!--          -->
        <xsl:variable name="VarAltText">
         <xsl:call-template name="Images-AltText">
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
          <xsl:with-param name="ParamBehaviorFrame" select="$VarBehavior" />
         </xsl:call-template>
        </xsl:variable>

        <!-- Alt Text exists? -->
        <!--                  -->
        <xsl:if test="string-length($VarAltText) = 0">
         <wwreport:Entry context="accessibility" type="missing-image-alt-text" severity="{$GlobalAccessibilityImageAltTagsSeverity}">

          <wwreport:Description>
           <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'AccessibilityMissingImageAltText']/@value" />
          </wwreport:Description>

          <wwreport:Navigation context="source">
           <wwreport:Link protocol="adapter">
            <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
            <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
            <wwreport:Data key="ID" value="{$ParamFrame/@id}" />
           </wwreport:Link>
          </wwreport:Navigation>

          <!-- Get output navigation link from format itself -->
          <!--                                               -->
          <xsl:variable name="VarLinkAsXML">
           <xsl:call-template name="Report-OutputLink">
            <xsl:with-param name="ParamProject" select="$GlobalProject" />
            <xsl:with-param name="ParamLinksContext" select="$ParamLinks" />
            <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
            <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
            <xsl:with-param name="ParamParagraphID" select="$ParamFrame//ancestor::wwdoc:Paragraph[last()]/@id" />
           </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
          <xsl:if test="count($VarLink) = 1">
           <wwreport:Navigation context="output">
            <xsl:copy-of select="$VarLink" />
           </wwreport:Navigation>
          </xsl:if>

          <wwreport:Navigation context="details">
           <wwreport:Link protocol="wwh5api">
            <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
            <wwreport:Data key="Context" value="preparing" />
            <wwreport:Data key="Topic" value="images_without_alt_text" />
           </wwreport:Link>
          </wwreport:Navigation>
         </wwreport:Entry>
        </xsl:if>
       </xsl:if>

       <!-- Report on image map alt text? -->
       <!--                               -->
       <xsl:if test="$GlobalAccessibilityImageMapAltTagsSeverity != 'ignore'">
        <!-- Image Map Alt Text -->
        <!--                    -->
        <xsl:call-template name="Check-ImageMap">
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
         <xsl:with-param name="ParamFrame" select="$ParamFrame" />
         <xsl:with-param name="ParamParentBehavior" select="$VarBehavior" />
         <xsl:with-param name="ParamSplit" select="$VarSplitsFrame/.." />
        </xsl:call-template>
       </xsl:if>

       <!-- Report on image long descriptions? -->
       <!--                                    -->
       <xsl:if test="$GlobalAccessibilityImageLongDescriptionsSeverity != 'ignore'">
        <!-- Long Description Required? -->
        <!--                            -->
        <xsl:variable name="VarLongDescriptionRequired">
         <xsl:call-template name="Images-LongDescriptionRequired">
          <xsl:with-param name="ParamBehaviorFrame" select="$VarBehavior" />
         </xsl:call-template>
        </xsl:variable>

        <xsl:if test="$VarLongDescriptionRequired = 'true'">
         <!-- Long Description -->
         <!--                  -->
         <xsl:variable name="VarLongDescription">
          <xsl:call-template name="Images-LongDescription">
           <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
           <xsl:with-param name="ParamBehaviorFrame" select="$VarBehavior" />
          </xsl:call-template>
         </xsl:variable>

         <!-- Long Description exists? -->
         <!--                          -->
         <xsl:if test="string-length($VarLongDescription) = 0">
          <wwreport:Entry context="accessibility" type="missing-image-long-description" severity="{$GlobalAccessibilityImageLongDescriptionsSeverity}">

           <wwreport:Description>
            <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'AccessibilityMissingImageLongDescription']/@value" />
           </wwreport:Description>

           <wwreport:Navigation context="source">
            <wwreport:Link protocol="adapter">
             <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
             <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
             <wwreport:Data key="ID" value="{$ParamFrame/@id}" />
            </wwreport:Link>
           </wwreport:Navigation>

           <!-- Get output navigation link from format itself -->
           <!--                                               -->
           <xsl:variable name="VarLinkAsXML">
            <xsl:call-template name="Report-OutputLink">
             <xsl:with-param name="ParamProject" select="$GlobalProject" />
             <xsl:with-param name="ParamLinksContext" select="$ParamLinks" />
             <xsl:with-param name="ParamGroupID" select="$ParamDocumentFile/@groupID" />
             <xsl:with-param name="ParamDocumentID" select="$ParamDocumentFile/@documentID" />
             <xsl:with-param name="ParamParagraphID" select="$ParamFrame//ancestor::wwdoc:Paragraph[last()]/@id" />
            </xsl:call-template>
           </xsl:variable>
           <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
           <xsl:if test="count($VarLink) = 1">
            <wwreport:Navigation context="output">
             <xsl:copy-of select="$VarLink" />
            </wwreport:Navigation>
           </xsl:if>

           <wwreport:Navigation context="details">
            <wwreport:Link protocol="wwh5api">
             <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
             <wwreport:Data key="Context" value="preparing" />
             <wwreport:Data key="Topic" value="images_without_long_desc" />
            </wwreport:Link>
           </wwreport:Navigation>
          </wwreport:Entry>
         </xsl:if>
        </xsl:if>
       </xsl:if>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:accessibility">
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Character'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <!-- Determine processing state -->
  <!--                            -->
  <xsl:variable name="VarProcessNode">
   <xsl:call-template name="Process-Node">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamNode" select="$ParamNode" />
    <xsl:with-param name="ParamRuleType" select="'Table'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Process node? -->
  <!--               -->
  <xsl:if test="$VarProcessNode = 'true'">
   <!-- Check table -->
   <!--             -->
   <xsl:call-template name="Check-Table">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamTable" select="$ParamNode" />
   </xsl:call-template>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:accessibility">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:accessibility">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" select="." />

  <xsl:if test="string-length($ParamNode/@id) &gt; 0">
   <!-- Determine processing state -->
   <!--                            -->
   <xsl:variable name="VarProcessNode">
    <xsl:call-template name="Process-Node">
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamNode" select="$ParamNode" />
     <xsl:with-param name="ParamRuleType" select="'Graphic'" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Process node? -->
   <!--               -->
   <xsl:if test="$VarProcessNode = 'true'">
    <xsl:call-template name="Check-Frame">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamFrame" select="$ParamNode" />
    </xsl:call-template>
   </xsl:if>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
