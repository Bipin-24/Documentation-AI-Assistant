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
                              xmlns:wwstageinfo="urn:WebWorks-XSLT-Extension-StageInfo"
                              xmlns:wwhttprequest="urn:WebWorks-HTTP-Request-Script"
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv wwstageinfo wwhttprequest"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSegmentsType" select="''" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterSplitsType" />
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
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/links/resolve.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
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
 <xsl:variable name="GlobalLinksBaggageFileSeverity" select="wwprojext:GetFormatSetting('report-links-baggage-file', 'message')" />
 <xsl:variable name="GlobalLinksExternalURLSeverity" select="wwprojext:GetFormatSetting('report-links-external-url', 'message')" />
 <xsl:variable name="GlobalLinksUnresolvedToFileSeverity" select="wwprojext:GetFormatSetting('report-links-unresolved-to-file', 'warning')" />
 <xsl:variable name="GlobalLinksUnresolvedToAnchorSeverity" select="wwprojext:GetFormatSetting('report-links-unresolved-to-anchor', 'warning')" />
 <xsl:variable name="GlobalLinksUnresolvedToDocumentSeverity" select="wwprojext:GetFormatSetting('report-links-unresolved-to-document', 'warning')" />
 <xsl:variable name="GlobalLinksUnresolvedToAnchorInDocumentSeverity" select="wwprojext:GetFormatSetting('report-links-unresolved-to-anchor-in-document', 'warning')" />
 <xsl:variable name="GlobalLinksUnsupportedBaggageFileSeverity" select="wwprojext:GetFormatSetting('report-links-unsupported-baggage-file', 'warning')" />
 <xsl:variable name="GlobalLinksUnsupportedGroupToGroupSeverity" select="wwprojext:GetFormatSetting('report-links-unsupported-group-to-group', 'warning')" />
 <xsl:variable name="GlobalLinksUnsupportedExternalURLSeverity" select="wwprojext:GetFormatSetting('report-links-unsupported-external-url', 'warning')" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-links-generate', 'true') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="($VarGenerateReportSetting) or ($VarRequestedPipeline)" />

   <xsl:if test="$VarGenerateReport">
    <!-- Configure stage info -->
    <!--                      -->
    <xsl:if test="string-length(wwstageinfo:Get('document-position')) = 0">
     <xsl:variable name="VarInitDocumentPosition" select="wwstageinfo:Set('document-position', '0')" />
    </xsl:if>

    <!-- Determine restart position -->
    <!--                            -->
    <xsl:variable name="VarLastDocumentPosition" select="number(wwstageinfo:Get('document-position'))" />

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
          <xsl:variable name="VarDocumentPosition" select="position()" />

          <xsl:variable name="VarProgressGroupDocumentStart" select="wwprogress:Start(1)" />

          <!-- Handle restart -->
          <!--                -->
          <xsl:if test="$VarDocumentPosition &gt; $VarLastDocumentPosition">
           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <!-- Up-to-date? -->
            <!--             -->
            <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
            <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarDocumentFile/@groupID, $VarDocumentFile/@documentID, $GlobalActionChecksum)" />
            <xsl:if test="not($VarUpToDate)">
             <xsl:variable name="VarResultAsTreeFragment">
              <xsl:call-template name="Links-Report">
               <xsl:with-param name="ParamLinks" select="$VarLinks" />
               <xsl:with-param name="ParamSplits" select="$VarSplits" />
               <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
              </xsl:call-template>
             </xsl:variable>
             <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
            </xsl:if>

            <!-- Update stage info -->
            <!--                   -->
            <xsl:if test="not(wwprogress:Abort())">
             <xsl:variable name="VarUpdateDocumentPosition" select="wwstageinfo:Set('document-position', string($VarDocumentPosition))" />
            </xsl:if>

            <!-- Report generated files -->
            <!--                        -->
            <xsl:if test="not(wwprogress:Abort())">
             <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LinksReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
              <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
              <wwfiles:Depends path="{$VarLinksFileInfo/@path}" checksum="{$VarLinksFileInfo/@checksum}" groupID="{$VarLinksFileInfo/@groupID}" documentID="{$VarLinksFileInfo/@documentID}" />
              <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
              <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
             </wwfiles:File>
            </xsl:if>
           </xsl:if>
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


 <xsl:template name="Links-Report">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Segments -->
  <!--          -->
  <xsl:variable name="VarSegmentsAsXML">
   <xsl:choose>
    <!-- Use defined segments -->
    <!--                      -->
    <xsl:when test="string-length($ParameterSegmentsType) &gt; 0">
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarSegmentsFile" select="key('wwfiles-files-by-documentid', $ParamDocumentFile/@documentID)[@type = $ParameterSegmentsType][1]" />
      <xsl:variable name="VarSegments" select="wwexsldoc:LoadXMLWithoutResolver($VarSegmentsFile/@path, false())" />
      <xsl:copy-of select="$VarSegments/wwsplits:Segments/wwsplits:Segment" />
     </xsl:for-each>
    </xsl:when>

    <!-- Synthesize segment for WIF file -->
    <!--                                 -->
    <xsl:otherwise>
     <wwsplits:Segment position="1" documentstartposition="1" path="{$ParamDocumentFile/@path}" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarSegments" select="msxsl:node-set($VarSegmentsAsXML)/wwsplits:Segment" />

  <!-- Generate report -->
  <!--                 -->
  <wwreport:Report version="1.0">

   <!-- Call template -->
   <!--               -->
   <xsl:call-template name="Segments">
    <xsl:with-param name="ParamSegments" select="$VarSegments" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="0" />
   </xsl:call-template>

  </wwreport:Report>
 </xsl:template>


 <xsl:template name="Segments">
  <xsl:param name="ParamSegments" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Iterate segments -->
  <!--                  -->
  <xsl:variable name="VarProgressSegmentsStart" select="wwprogress:Start(count($ParamSegments))" />
  <xsl:for-each select="$ParamSegments">
   <xsl:sort select="@position" order="ascending" data-type="number" />
   <xsl:variable name="VarSegment" select="." />

   <xsl:variable name="VarProgressSegmentStart" select="wwprogress:Start(1)" />

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <!-- Determine segment start/end positions -->
    <!--                                       -->
    <xsl:variable name="VarSegmentDocumentStartPosition" select="number($VarSegment/@documentstartposition)" />
    <xsl:variable name="VarSegmentDocumentEndPosition">
     <xsl:variable name="VarNextSegment" select="$VarSegment/following-sibling::wwsplits:Segment[1]" />
     <xsl:choose>
      <xsl:when test="count($VarNextSegment) = 1">
       <xsl:value-of select="number($VarNextSegment/@documentstartposition) - 1" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="-1" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Load segment -->
    <!--              -->
    <xsl:variable name="VarDocumentSegment" select="wwexsldoc:LoadXMLWithoutResolver($VarSegment/@path, false())" />

    <!-- Content -->
    <!--         -->
    <xsl:apply-templates select="$VarDocumentSegment" mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$VarSegmentDocumentStartPosition" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$VarSegmentDocumentEndPosition" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="0" />
    </xsl:apply-templates>
   </xsl:if>

   <xsl:variable name="VarProgressSegmentEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressSegmentsEnd" select="wwprogress:End()" />
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


 <xsl:template match="wwlinks:ResolvedLink" mode="wwmode:report-links">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamDocumentLink" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamResolvedLinkInfo" select="." />

  <xsl:choose>
   <!-- Baggage -->
   <!--         -->
   <xsl:when test="$ParamResolvedLinkInfo/@type = 'baggage'">
    <!-- Regular baggage file -->
    <!--                      -->
    <xsl:if test="$GlobalLinksBaggageFileSeverity != 'ignore'">
     <wwreport:Entry context="links" type="baggage-file" severity="{$GlobalLinksBaggageFileSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BaggageFile']/@value, wwfilesystem:GetFileName($ParamResolvedLinkInfo/@target))" />
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
      <xsl:if test="count($VarLink) = 1">
       <wwreport:Navigation context="output">
        <xsl:copy-of select="$VarLink" />
       </wwreport:Navigation>
      </xsl:if>

      <wwreport:Navigation context="output">
       <wwreport:Link protocol="uri">
        <wwreport:Data key="URI" value="{$ParamDocumentLink/@target}" />
       </wwreport:Link>
      </wwreport:Navigation>

      <wwreport:Navigation context="details">
       <wwreport:Link protocol="wwh5api">
        <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
        <wwreport:Data key="Context" value="preparing" />
        <wwreport:Data key="Topic" value="baggage_files" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>

   <!-- External URL -->
   <!--              -->
   <xsl:when test="$ParamResolvedLinkInfo/@type = 'url'">
    <xsl:if test="$GlobalLinksExternalURLSeverity != 'ignore'">

     <xsl:variable name="ConditionForValidating" select="$GlobalLinksExternalURLSeverity='validate' and (starts-with($ParamResolvedLinkInfo/@url, 'http://') or starts-with($ParamResolvedLinkInfo/@url, 'https://'))"/>
     <xsl:variable name="VarStatusCode">
      <xsl:if test="$ConditionForValidating">
       <xsl:value-of select="wwhttprequest:RemoteURLResponseCode($ParamResolvedLinkInfo/@url)" />
      </xsl:if>
     </xsl:variable>
     <xsl:variable name="VarSeverity">
      <xsl:choose>
       <xsl:when test="$ConditionForValidating">
        <!-- Modify severity based on status code -->
        <!--                                      -->
        <xsl:choose>
         <!-- Status OK -->
         <!--             -->
         <xsl:when test="$VarStatusCode = 200">
          <xsl:text>message</xsl:text>
         </xsl:when>

         <!-- Status Redirect -->
         <!--                 -->
         <xsl:when test="($VarStatusCode = 301) or ($VarStatusCode = 302)">
          <xsl:text>warning</xsl:text>
         </xsl:when>

         <!-- Bad stuff! -->
         <!--            -->
         <xsl:otherwise>
          <xsl:text>error</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="$GlobalLinksExternalURLSeverity"/>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <wwreport:Entry context="links" type="external-url" severity="{$VarSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ExternalURL']/@value, $ParamResolvedLinkInfo/@url)" />
       <xsl:if test="$ConditionForValidating">
        <xsl:text> (status code == </xsl:text>
        <xsl:value-of select="$VarStatusCode" />
        <xsl:text>)</xsl:text>
       </xsl:if>
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarLink" select="msxsl:node-set($VarLinkAsXML)/wwreport:Link[1]" />
      <xsl:if test="count($VarLink) = 1">
       <wwreport:Navigation context="output">
        <xsl:copy-of select="$VarLink" />
       </wwreport:Navigation>
      </xsl:if>

      <wwreport:Navigation context="uri">
       <wwreport:Link protocol="uri">
        <wwreport:Data key="URI" value="{$ParamResolvedLinkInfo/@url}" />
       </wwreport:Link>
      </wwreport:Navigation>

      <wwreport:Navigation context="details">
       <wwreport:Link protocol="wwh5api">
        <wwreport:Data key="BaseURI" value="{wwenv:ApplicationBaseHelpURI()}" />
        <wwreport:Data key="Context" value="preparing" />
        <wwreport:Data key="Topic" value="external_URLs" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwlinks:UnresolvedLink" mode="wwmode:report-links">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamDocumentLink" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamUnresolvedLinkInfo" select="." />

  <xsl:choose>
   <!-- Unresolved baggage files -->
   <!--                          -->
   <xsl:when test="$ParamUnresolvedLinkInfo/@type = 'baggage'">
    <xsl:if test="$GlobalLinksUnresolvedToFileSeverity != 'ignore'">
     <xsl:variable name="VarProjectSourceDocumentPath" select="wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)" />
     <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamDocumentFile/@documentID), wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />

     <wwreport:Entry context="links" type="unresolved" severity="{$GlobalLinksUnresolvedToFileSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnresolvedLinkToMissingTarget']/@value, wwfilesystem:GetFileName($VarSourceDocumentPath), $ParamUnresolvedLinkInfo/@target)" />
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
        <wwreport:Data key="Topic" value="unresolved_link_missing_file" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>

   <!-- Unresolved document links -->
   <!--                           -->
   <xsl:when test="$ParamUnresolvedLinkInfo/@type = 'document'">
    <xsl:variable name="VarProjectSourceDocumentPath" select="wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)" />
    <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamDocumentFile/@documentID), wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />

    <xsl:variable name="VarTargetDocumentPath" select="wwuri:AsFilePath($ParamDocumentLink/@url)" />

    <xsl:choose>
     <!-- Internal link -->
     <!--               -->
     <xsl:when test="(string-length($ParamDocumentLink/@url) = 0) and (string-length($ParamDocumentLink/@anchor) &gt; 0)">
      <xsl:if test="$GlobalLinksUnresolvedToAnchorSeverity != 'ignore'">
       <wwreport:Entry context="links" type="unresolved" severity="{$GlobalLinksUnresolvedToAnchorSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnresolvedLinkToAnchorInsideDocument']/@value, $ParamUnresolvedLinkInfo/@anchor, wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />
        </wwreport:Description>

        <wwreport:Navigation context="source">
         <wwreport:Link protocol="adapter">
          <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
          <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
          <wwreport:Data key="ID" value="{$ParamID}" />
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
          <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
          <wwreport:Data key="Topic" value="unresolved_link_within_document" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:when>

     <!-- Document link -->
     <!--               -->
     <xsl:when test="(string-length($ParamDocumentLink/@url) &gt; 0) and (string-length($ParamDocumentLink/@anchor) = 0)">
      <xsl:if test="$GlobalLinksUnresolvedToDocumentSeverity != 'ignore'">
       <wwreport:Entry context="links" type="unresolved" severity="{$GlobalLinksUnresolvedToDocumentSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnresolvedLinkToTargetDocument']/@value, wwfilesystem:GetFileName($VarSourceDocumentPath), wwfilesystem:GetFileName($VarTargetDocumentPath))" />
        </wwreport:Description>

        <wwreport:Navigation context="source">
         <wwreport:Link protocol="adapter">
          <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
          <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
          <wwreport:Data key="ID" value="{$ParamID}" />
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
          <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
          <wwreport:Data key="Topic" value="unresolved_link_other_documents" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:when>

     <!-- Document link with anchor -->
     <!--                           -->
     <xsl:when test="(string-length($ParamDocumentLink/@url) &gt; 0) and (string-length($ParamDocumentLink/@anchor) &gt; 0)">
      <xsl:if test="$GlobalLinksUnresolvedToAnchorInDocumentSeverity != 'ignore'">
       <wwreport:Entry context="links" type="unresolved" severity="{$GlobalLinksUnresolvedToAnchorInDocumentSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnresolvedLinkToAnchorInTargetDocument']/@value, wwfilesystem:GetFileName($VarSourceDocumentPath), $ParamUnresolvedLinkInfo/@anchor, wwfilesystem:GetFileName($VarTargetDocumentPath))" />
        </wwreport:Description>

        <wwreport:Navigation context="source">
         <wwreport:Link protocol="adapter">
          <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
          <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
          <wwreport:Data key="ID" value="{$ParamID}" />
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
          <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
          <wwreport:Data key="Topic" value="unresolved_link_other_documents" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:when>
    </xsl:choose>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwlinks:UnsupportedLink" mode="wwmode:report-links">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamDocumentLink" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamUnsupportedLinkInfo" select="." />

  <xsl:choose>
   <!-- Unsupported baggage files -->
   <!--                           -->
   <xsl:when test="$ParamUnsupportedLinkInfo/@type = 'baggage'">
    <xsl:if test="$GlobalLinksUnsupportedBaggageFileSeverity != 'ignore'">
     <xsl:variable name="VarProjectSourceDocumentPath" select="wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)" />
     <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamDocumentFile/@documentID), wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />

     <wwreport:Entry context="links" type="unsupported" severity="{$GlobalLinksUnsupportedBaggageFileSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BaggageFilesNotSupported']/@value, wwfilesystem:GetFileName($VarSourceDocumentPath), $ParamUnsupportedLinkInfo/@target)" />
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
        <wwreport:Data key="Topic" value="unsupported_baggage_files" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>

   <!-- Unsupported group-to-group linking -->
   <!--                                    -->
   <xsl:when test="$ParamUnsupportedLinkInfo/@type = 'project'">
    <xsl:if test="$GlobalLinksUnsupportedGroupToGroupSeverity != 'ignore'">
     <xsl:variable name="VarProjectSourceDocumentPath" select="wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)" />
     <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamDocumentFile/@documentID), wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />

     <xsl:variable name="VarProjectTargetDocumentPath" select="wwprojext:GetDocumentPath($ParamUnsupportedLinkInfo/@documentID)" />
     <xsl:variable name="VarTargetDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamUnsupportedLinkInfo/@documentID), wwfilesystem:GetFileName($VarProjectTargetDocumentPath))" />

     <wwreport:Entry context="links" type="unsupported" severity="{$GlobalLinksUnsupportedGroupToGroupSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'GroupToGroupLinkingNotSupported']/@value, wwfilesystem:GetFileName($VarSourceDocumentPath), wwfilesystem:GetFileName($VarTargetDocumentPath))" />
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
        <wwreport:Data key="Topic" value="unsupported_group_links" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>

   <!-- Unsupported URL -->
   <!--                 -->
   <xsl:when test="$ParamUnsupportedLinkInfo/@type = 'url'">
    <xsl:if test="$GlobalLinksUnsupportedExternalURLSeverity != 'ignore'">
     <wwreport:Entry context="links" type="unsupported" severity="{$GlobalLinksUnsupportedExternalURLSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnsupportedExternalURL']/@value, $ParamUnsupportedLinkInfo/@url)" />
      </wwreport:Description>

      <wwreport:Navigation context="source">
       <wwreport:Link protocol="adapter">
        <wwreport:Data key="Path" value="{wwprojext:GetDocumentPath($ParamDocumentFile/@documentID)}" />
        <wwreport:Data key="DocumentID" value="{$ParamDocumentFile/@documentID}" />
        <wwreport:Data key="ID" value="{$ParamID}" />
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
        <xsl:with-param name="ParamParagraphID" select="$ParamID" />
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
        <wwreport:Data key="Topic" value="unsupported_external_URLs" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Link-Check">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamDocumentLink" />

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
    <xsl:with-param name="ParamSplitGroupID" select="$ParamDocumentFile/@groupID" />
    <xsl:with-param name="ParamSplitDocumentID" select="$ParamDocumentFile/@documentID" />
    <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedLinkInfo" select="msxsl:node-set($VarResolvedLinkInfoAsXML)/wwlinks:*" />

  <!-- Report -->
  <!--        -->
  <xsl:apply-templates select="$VarResolvedLinkInfo" mode="wwmode:report-links">
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamNode" select="$ParamNode" />
   <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
   <xsl:with-param name="ParamID" select="$ParamID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="/" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="$ParamID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:links">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="$ParamID" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Document" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="$ParamID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Content" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="$ParamID" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:List" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:TextRun" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <!-- Check link -->
    <!--            -->
    <xsl:variable name="VarDocumentLink" select="$ParamNode/wwdoc:Link[1]" />
    <xsl:if test="count($VarDocumentLink) = 1">
     <xsl:call-template name="Link-Check">
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamID" select="$ParamID" />
      <xsl:with-param name="ParamNode" select="$ParamNode" />
      <xsl:with-param name="ParamDocumentLink" select="$VarDocumentLink" />
     </xsl:call-template>
    </xsl:if>

    <!-- Process children -->
    <!--                  -->
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamID" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <!-- Process children -->
    <!--                  -->
    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
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
    <!-- Determine source link ID -->
    <!--                          -->
    <xsl:variable name="VarID">
     <xsl:choose>
      <xsl:when test="string-length($ParamNode/@id) &gt; 0">
       <xsl:value-of select="$ParamNode/@id" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$ParamID" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Check link -->
    <!--            -->
    <xsl:variable name="VarDocumentLink" select="$ParamNode/wwdoc:Link[1]" />
    <xsl:choose>
     <xsl:when test="count($VarDocumentLink) = 1">
      <xsl:call-template name="Link-Check">
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
       <xsl:with-param name="ParamID" select="$VarID" />
       <xsl:with-param name="ParamNode" select="$ParamNode" />
       <xsl:with-param name="ParamDocumentLink" select="$VarDocumentLink" />
      </xsl:call-template>
     </xsl:when>

     <xsl:otherwise>
      <xsl:variable name="VarChildLinks" select="$ParamNode/wwdoc:Content//wwdoc:Link[count($ParamNode | ancestor::wwdoc:Frame[1]) = 1]" />
      <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
      <xsl:if test="$VarChildLinksCount &gt; 0">
       <xsl:call-template name="Link-Check">
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
        <xsl:with-param name="ParamID" select="$VarID" />
        <xsl:with-param name="ParamNode" select="$ParamNode" />
        <xsl:with-param name="ParamDocumentLink" select="$VarChildLinks[$VarChildLinksCount]" />
       </xsl:call-template>
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>

    <!-- Process child frames -->
    <!--                      -->
    <xsl:apply-templates select="$ParamNode/wwdoc:Content/wwdoc:Frame" mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$VarID" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <msxsl:script language="C#" implements-prefix="wwhttprequest">
  <![CDATA[
    public int RemoteURLResponseCode(string param_url)
    {
      try
      {
        System.Net.HttpWebRequest request;
        System.Net.HttpWebResponse response;

        // Create request
        //
        request = System.Net.WebRequest.Create(param_url) as System.Net.HttpWebRequest;
        request.Method = "HEAD";
        request.AllowAutoRedirect = false;

        // Get response
        //
        response = request.GetResponse() as System.Net.HttpWebResponse;
        response.Close();

        return (int)response.StatusCode;
      }
      catch
      {
        return 500;
      }
    }
  ]]>
 </msxsl:script>
</xsl:stylesheet>
