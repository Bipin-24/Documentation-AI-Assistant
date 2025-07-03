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
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-splits-by-id" match="wwsplits:Split" use="@id" />
 <xsl:key name="wwsplits-frames-by-id" match="wwsplits:Frame" use="@id" />


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
 <xsl:variable name="GlobalFilenamesUsedSeverity" select="wwprojext:GetFormatSetting('report-filenames-used', 'message')" />
 <xsl:variable name="GlobalFilenamesIgnoredSeverity" select="wwprojext:GetFormatSetting('report-filenames-ignored', 'warning')" />
 <xsl:variable name="GlobalFilenamesRenamedSeverity" select="wwprojext:GetFormatSetting('report-filenames-renamed', 'warning')" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-filenames-generate', 'true') = 'true'" />
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
             <xsl:call-template name="Filenames-Report">
              <xsl:with-param name="ParamLinks" select="$VarLinks" />
              <xsl:with-param name="ParamSplits" select="$VarSplits" />
              <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
           </xsl:if>

           <!-- Report generated files -->
           <!--                        -->
           <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FilenamesReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
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


 <xsl:template name="Filenames-CheckHint">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamBehaviorsMarker" />
  <xsl:param name="ParamLast" />

  <!-- Determine filename hint after applying filenaming settings -->
  <!--                                                            -->
  <xsl:variable name="VarFileNameHint">
   <xsl:for-each select="$ParamBehaviorsMarker/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
    <xsl:value-of select="@value" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarNormalizeSpaceFileNameHint" select="normalize-space($VarFileNameHint)" />
  <xsl:variable name="VarCasedFileNameHint">
   <xsl:call-template name="ConvertNameTo">
    <xsl:with-param name="ParamText" select="$VarNormalizeSpaceFileNameHint" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarNormalizedFileNameHint">
   <xsl:call-template name="ReplaceFileNameSpacesWith">
    <xsl:with-param name="ParamText" select="$VarCasedFileNameHint" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <!-- Hint processed -->
   <!--                -->
   <xsl:when test="$ParamLast">
    <!-- Get hint used -->
    <!--               -->
    <xsl:variable name="VarHintUsed" select="wwfilesystem:GetFileNameWithoutExtension($ParamPath)" />

    <xsl:choose>
     <!-- Hint matches used name -->
     <!--                        -->
     <xsl:when test="$VarNormalizedFileNameHint = $VarHintUsed">
      <xsl:if test="$GlobalFilenamesUsedSeverity != 'ignore'">
       <wwreport:Entry context="filenames" type="hint-used" severity="{$GlobalFilenamesUsedSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FilenamesUsed']/@value, $VarFileNameHint, wwfilesystem:GetFileName($ParamPath))" />
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
          <wwreport:Data key="Topic" value="file_named_by_marker" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:when>

     <!-- Hint was not unique -->
     <!--                     -->
     <xsl:otherwise>
      <xsl:if test="$GlobalFilenamesRenamedSeverity != 'ignore'">
       <wwreport:Entry context="filenames" type="hint-renamed" severity="{$GlobalFilenamesRenamedSeverity}">
        <wwreport:Description>
         <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FilenamesRenamed']/@value, $VarFileNameHint, $VarHintUsed, wwfilesystem:GetFileName($ParamPath))" />
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
          <wwreport:Data key="Topic" value="filename_marker_collision" />
         </wwreport:Link>
        </wwreport:Navigation>
       </wwreport:Entry>
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <!-- Hint ignored -->
   <!--              -->
   <xsl:otherwise>
    <xsl:if test="$GlobalFilenamesIgnoredSeverity != 'ignore'">
     <wwreport:Entry context="filenames" type="hint-ignored" severity="{$GlobalFilenamesIgnoredSeverity}">
      <wwreport:Description>
       <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FilenamesIgnored']/@value, $VarFileNameHint)" />
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
        <wwreport:Data key="Topic" value="filename_marker_ignored" />
       </wwreport:Link>
      </wwreport:Navigation>
     </wwreport:Entry>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Filenames-Report">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentFile" />

  <!-- Load behaviors -->
  <!--                -->
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-documentid', $ParamDocumentFile/@documentID)[@type = $ParameterBehaviorsType][1]" />
   <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

   <!-- Generate report -->
   <!--                 -->
   <wwreport:Report version="1.0">

    <!-- Examine each split -->
    <!--                    -->
    <xsl:for-each select="$VarBehaviors/wwbehaviors:Behaviors/wwbehaviors:Split">
     <xsl:variable name="VarBehaviorsSplit" select="." />

     <!-- Check split filename -->
     <!--                      -->
     <xsl:for-each select="$ParamSplits[1]">
      <xsl:variable name="VarSplitsSplit" select="key('wwsplits-splits-by-id', $VarBehaviorsSplit/@id)[@documentID = $ParamDocumentFile/@documentID]" />

      <!-- Locate split filename markers -->
      <!--                               -->
      <xsl:for-each select="$VarBehaviorsSplit//wwbehaviors:Marker[not(ancestor::wwbehaviors:Frame) and ((@behavior = 'filename') or (@behavior = 'filename-and-topic'))]">
       <xsl:variable name="VarBehaviorsMarker" select="." />

       <!-- Last filename hint? -->
       <!--                     -->
       <xsl:variable name="VarLastFileNameHint" select="position() = last()" />

       <xsl:call-template name="Filenames-CheckHint">
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
        <xsl:with-param name="ParamID" select="$VarSplitsSplit/@id" />
        <xsl:with-param name="ParamPath" select="$VarSplitsSplit/@path" />
        <xsl:with-param name="ParamBehaviorsMarker" select="$VarBehaviorsMarker" />
        <xsl:with-param name="ParamLast" select="position() = last()" />
       </xsl:call-template>
      </xsl:for-each>
     </xsl:for-each>

     <!-- Examine each frame -->
     <!--                    -->
     <xsl:for-each select="$VarBehaviorsSplit/wwbehaviors:Frame">
      <xsl:variable name="VarBehaviorsFrame" select="." />

      <!-- Check frame filename -->
      <!--                      -->
      <xsl:for-each select="$ParamSplits[1]">
       <xsl:variable name="VarSplitsFrame" select="key('wwsplits-frames-by-id', $VarBehaviorsFrame/@id)[@documentID = $ParamDocumentFile/@documentID]" />

       <!-- Locate frame filename markers -->
       <!--                               -->
       <xsl:for-each select="$VarBehaviorsFrame//wwbehaviors:Marker[(@behavior = 'filename') or (@behavior = 'filename-and-topic')]">
        <xsl:variable name="VarBehaviorsMarker" select="." />

        <!-- Last filename hint? -->
        <!--                     -->
        <xsl:variable name="VarLastFileNameHint" select="position() = last()" />

        <xsl:call-template name="Filenames-CheckHint">
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
         <xsl:with-param name="ParamID" select="$VarSplitsFrame/@id" />
         <xsl:with-param name="ParamPath" select="$VarSplitsFrame/@path" />
         <xsl:with-param name="ParamBehaviorsMarker" select="$VarBehaviorsMarker" />
         <xsl:with-param name="ParamLast" select="position() = last()" />
        </xsl:call-template>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:for-each>

   </wwreport:Report>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
