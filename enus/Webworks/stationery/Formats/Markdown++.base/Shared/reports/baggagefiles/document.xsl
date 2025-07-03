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
                              xmlns:wwwarning="urn:WebWorks-Warning-Schema"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwbehaviors wwdoc wwproject wwprogress wwlog wwfilesystem
		wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv wwwarning wwbaggage"
		>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />
 <xsl:param name="ParameterBaggageDocumentType" />
 <xsl:param name="ParameterBaggageWarningsType" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwformat:Transforms/reports.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/reports.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/reports.xsl')))" />
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
 <xsl:variable name="GlobalBaggageFilesWithoutTitleSeverity" select="wwprojext:GetFormatSetting('report-baggagefiles-without-title', 'warning')" />
 <xsl:variable name="GlobalBaggageFilesWithoutSummarySeverity" select="wwprojext:GetFormatSetting('report-baggagefiles-without-summary', 'warning')" />


 <!-- Baggage Settings -->
 <!--                  -->
 <xsl:variable name="GlobalCreateStandaloneGroup" select="wwprojext:GetFormatSetting('create-standalone-group')" />
 <!-- create-standalone-group -->


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-baggagefiles-generate', 'true') = 'true'" />
   <xsl:variable name="VarRequestedPipeline" select="wwenv:RequestedPipeline($GlobalPipelineName)" />
   <xsl:variable name="VarGenerateReport" select="($VarGenerateReportSetting) or ($VarRequestedPipeline)" />

   <xsl:if test="$VarGenerateReport">
    <!-- Load project links -->
    <!--                    -->
    <xsl:for-each select="$GlobalFiles[1]">

     <!-- Groups -->
     <!--        -->
     <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
     <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
     <xsl:for-each select="$VarProjectGroups">
      <xsl:variable name="VarProjectGroup" select="." />

      <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

      <xsl:variable name="VarBaggageWarningInfoTemp">
       <xsl:for-each select="$GlobalFiles[1]">
        <xsl:choose>
         <xsl:when test="$GlobalCreateStandaloneGroup='true'">
          <xsl:copy-of select="key('wwfiles-files-by-type', $ParameterBaggageWarningsType)[1]" />
         </xsl:when>
         <xsl:otherwise>
          <xsl:copy-of select="key('wwfiles-files-by-type', $ParameterBaggageWarningsType)[@groupID = $VarProjectGroup/@GroupID][1]" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="VarBaggageWarningInfo" select="msxsl:node-set($VarBaggageWarningInfoTemp)/*" />
      <xsl:variable name="VarBaggageWarnings" select="wwexsldoc:LoadXMLWithoutResolver($VarBaggageWarningInfo/@path, false())" />

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
             <xsl:call-template name="Baggage-Files-Report">
              <xsl:with-param name="ParamBaggageWarnings" select="$VarBaggageWarnings" />
              <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
           </xsl:if>

           <!-- Report generated files -->
           <!--                        -->
           <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BaggageFilesReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
            <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
            <wwfiles:Depends path="{$VarBaggageWarningInfo/@path}" checksum="{$VarBaggageWarningInfo/@checksum}" groupID="{$VarBaggageWarningInfo/@groupID}" documentID="{$VarBaggageWarningInfo/@documentID}" />
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


 <xsl:template name="Write-Entry">
  <xsl:param name="ParamType" />
  <xsl:param name="ParamDescription" />
  <xsl:param name="ParamPath" />

  <xsl:variable name="VarSeverity">
   <xsl:choose>
    <xsl:when test="$ParamType = 'notitle'">
     <xsl:value-of select="$GlobalBaggageFilesWithoutTitleSeverity"/>
    </xsl:when>
    <xsl:when test="$ParamType = 'nosummary'">
     <xsl:value-of select="$GlobalBaggageFilesWithoutSummarySeverity"/>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>
  <xsl:if test="$VarSeverity != 'ignore'">
   <!-- Report override style -->
   <!--                       -->
   <wwreport:Entry context="baggagefiles" type="{$ParamType}" severity="{$VarSeverity}">
    <wwreport:Description>
     <xsl:value-of select="$ParamDescription" />
    </wwreport:Description>

    <wwreport:Navigation context="source">
     <wwreport:Link protocol="uri">
      <wwreport:Data key="URI" value="{$ParamPath}" />
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

 </xsl:template>


 <xsl:template name="Baggage-Files-Report">
  <xsl:param name="ParamBaggageWarnings" />
  <xsl:param name="ParamDocumentFile" />

  <xsl:variable name="VarBaggageDocumentPath" select="key('wwfiles-files-by-type', $ParameterBaggageDocumentType)[@documentID = $ParamDocumentFile/@documentID][1]/@path"/>
  <xsl:variable name="VarBaggageDocument" select="msxsl:node-set(wwexsldoc:LoadXMLWithoutResolver($VarBaggageDocumentPath, false()))/wwbaggage:Baggage/wwbaggage:File" />
  <!-- Generate report -->
  <!--                 -->
  <wwreport:Report version="1.0">

   <!-- Examine each Warning -->
   <!--                      -->
   <xsl:for-each select="msxsl:node-set($ParamBaggageWarnings)/wwwarning:Warnings/wwwarning:Warning">
    <xsl:variable name="VarWarning" select="."/>

    <xsl:if test="count($VarBaggageDocument[@path=$VarWarning/@path]) > 0">
     <xsl:call-template name="Write-Entry">
      <xsl:with-param name="ParamType" select="@type" />
      <xsl:with-param name="ParamDescription" select="@description" />
      <xsl:with-param name="ParamPath" select="@path" />
     </xsl:call-template>
    </xsl:if>

   </xsl:for-each>

  </wwreport:Report>

 </xsl:template>
</xsl:stylesheet>
