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
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec wwenv wwstageinfo"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSegmentsType" select="''" />
 <xsl:param name="ParameterLinksType" />
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
 <xsl:key name="wwproject-rulescontainer-by-type" match="wwproject:Rules" use="@Type" />
 <xsl:key name="wwproject-rules-by-key" match="wwproject:Rule" use="@Key" />


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
 <xsl:variable name="GlobalStylesNonStandardStyleSeverity" select="wwprojext:GetFormatSetting('report-styles-non-standard-style', 'warning')" />
 <xsl:variable name="GlobalStylesOverrideSeverity" select="wwprojext:GetFormatSetting('report-styles-override', 'warning')" />


 <!-- Project rules -->
 <!--               -->
 <xsl:variable name="GlobalProjectRulesOfTypeCountsAsXML">
  <xsl:for-each select="$GlobalProject/wwproject:Project/wwproject:GlobalConfiguration/wwproject:Rules | $GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfigurations/wwproject:Rules">
   <xsl:variable name="VarRulesOfTypeCollection" select="." />

   <xsl:variable name="VarRulesOfTypeCollections" select="key('wwproject-rulescontainer-by-type', $VarRulesOfTypeCollection/@Type)" />
   <xsl:if test="count($VarRulesOfTypeCollection | $VarRulesOfTypeCollections[1]) = 1">
    <xsl:variable name="VarRulesOfType" select="$VarRulesOfTypeCollections/wwproject:Rule[@Key != '{WWDefaultRule}']" />

    <wwproject:Rules id="{$VarRulesOfTypeCollection/@Type}" count="{count($VarRulesOfType)}" />
   </xsl:if>
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectRulesOfTypeCounts" select="msxsl:node-set($GlobalProjectRulesOfTypeCountsAsXML)/*" />

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarGenerateReportSetting" select="wwprojext:GetFormatSetting('report-styles-generate', 'true') = 'true'" />
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

     <!-- Iterate input documents -->
     <!--                         -->
     <xsl:for-each select="$GlobalInput[1]">
      <!-- Documents -->
      <!--           -->
      <xsl:variable name="VarDocumentFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />
      <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarDocumentFiles))" />
      <xsl:for-each select="$VarDocumentFiles">
       <xsl:variable name="VarDocumentFile" select="." />
       <xsl:variable name="VarDocumentPosition" select="position()" />

       <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

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
           <xsl:call-template name="Style-Report">
            <xsl:with-param name="ParamLinks" select="$VarLinks" />
            <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
           </xsl:call-template>
          </xsl:variable>
          <xsl:if test="not(wwprogress:Abort())">
           <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
          </xsl:if>
         </xsl:if>

         <!-- Update stage info -->
         <!--                   -->
         <xsl:if test="not(wwprogress:Abort())">
          <xsl:variable name="VarUpdateDocumentPosition" select="wwstageinfo:Set('document-position', string($VarDocumentPosition))" />
         </xsl:if>

         <!-- Report generated files -->
         <!--                        -->
         <xsl:if test="not(wwprogress:Abort())">
          <wwfiles:File path="{$VarPath}" displayname="{$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'StylesReportTitle']/@value}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
           <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />
           <wwfiles:Depends path="{$VarLinksFileInfo/@path}" checksum="{$VarLinksFileInfo/@checksum}" groupID="{$VarLinksFileInfo/@groupID}" documentID="{$VarLinksFileInfo/@documentID}" />
           <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
          </wwfiles:File>
         </xsl:if>
        </xsl:if>
       </xsl:if>

       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
      </xsl:for-each>
      <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Style-Report">
  <xsl:param name="ParamLinks" />
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
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   </xsl:call-template>

  </wwreport:Report>
 </xsl:template>


 <xsl:template name="Segments">
  <xsl:param name="ParamSegments" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />

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
    <xsl:apply-templates select="$VarDocumentSegment" mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$VarSegmentDocumentStartPosition" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$VarSegmentDocumentEndPosition" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    </xsl:apply-templates>
   </xsl:if>

   <xsl:variable name="VarProgressSegmentEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressSegmentsEnd" select="wwprogress:End()" />
 </xsl:template>


 <xsl:template name="Style-Check">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamStyleOverridesExist" />
  <xsl:param name="ParamRuleType" />

  <!-- Style name defined? -->
  <!--                     -->
  <xsl:if test="string-length($ParamStyleName) &gt; 0">
   <!-- Match against project styles -->
   <!--                              -->
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarProjectRules" select="key('wwproject-rules-by-key', $ParamStyleName)[../@Type = $ParamRuleType]" />

    <!-- Match found? -->
    <!--              -->
    <xsl:if test="count($VarProjectRules) = 0">
     <!-- Report non-compliant style (if there are any scanned styles for this type) -->
     <!--                                                                            -->
     <xsl:if test="($GlobalStylesNonStandardStyleSeverity != 'ignore') and ($GlobalProjectRulesOfTypeCounts[@id = $ParamRuleType]/@count > 0)">
      <wwreport:Entry context="styles" type="non-standard-style" severity="{$GlobalStylesNonStandardStyleSeverity}">
       <wwreport:Description>
        <xsl:variable name="VarLocalizedStyleType" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = concat('StyleType-', $ParamRuleType)]/@value" />
        <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'NonStandardStyleInUse']/@value, $ParamStyleName, $VarLocalizedStyleType)" />
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
         <wwreport:Data key="Topic" value="nonstandard_styles" />
        </wwreport:Link>
       </wwreport:Navigation>
      </wwreport:Entry>
     </xsl:if>
    </xsl:if>
   </xsl:for-each>
  </xsl:if>

  <!-- Style overrides exist? -->
  <!--                        -->
  <xsl:if test="$ParamStyleOverridesExist">
   <!-- Report override style -->
   <!--                       -->
   <xsl:if test="$GlobalStylesOverrideSeverity != 'ignore'">
    <wwreport:Entry context="styles" type="overrides-exist" severity="{$GlobalStylesOverrideSeverity}">
     <wwreport:Description>
      <xsl:variable name="VarLocalizedStyleType" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = concat('StyleType-', $ParamRuleType)]/@value" />

      <!-- Handle case where style name is undefined -->
      <!--                                           -->
      <xsl:choose>
       <xsl:when test="string-length($ParamStyleName) &gt; 0">
        <xsl:value-of select="wwstring:Format($GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'StyleOverridesExist']/@value, $ParamStyleName, $VarLocalizedStyleType)" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'UnnamedStyleOverridesExist']/@value" />
       </xsl:otherwise>
      </xsl:choose>
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
       <wwreport:Data key="Topic" value="style_overrides" />
      </wwreport:Link>
     </wwreport:Navigation>
    </wwreport:Entry>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="/" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <xsl:apply-templates mode="wwmode:styles">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="0" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <xsl:apply-templates mode="wwmode:styles">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="0" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Document" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <xsl:apply-templates mode="wwmode:styles">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="0" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Content" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />

  <xsl:apply-templates mode="wwmode:styles">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamID" select="0" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="Style-Check">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
     <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
     <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
     <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="Style-Check">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
     <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
     <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
     <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="Style-Check">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
     <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
     <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
     <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="Style-Check">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
     <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
     <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
     <xsl:with-param name="ParamRuleType" select="'Paragraph'" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <xsl:variable name="VarHasContent" select="count($ParamNode/wwdoc:*[(local-name() != 'Style') and (local-name() != 'Link') and (local-name() != 'Conditions')][1]) &gt; 0" />

   <xsl:call-template name="Style-Check">
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="$ParamID" />
    <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
    <xsl:with-param name="ParamStyleOverridesExist" select="(count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0) and ($VarHasContent)" />
    <xsl:with-param name="ParamRuleType" select="'Character'" />
   </xsl:call-template>

   <xsl:apply-templates mode="wwmode:styles">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="$ParamID" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="Style-Check">
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
     <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
     <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute[@Name != 'width']) &gt; 0" />
     <xsl:with-param name="ParamRuleType" select="'Table'" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:styles">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
     <xsl:with-param name="ParamID" select="$ParamNode/@id" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <!-- Top level frame? -->
    <!--                  -->
    <xsl:if test="string-length($ParamNode/@id) &gt; 0">
     <xsl:call-template name="Style-Check">
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamID" select="$ParamNode/@id" />
      <xsl:with-param name="ParamStyleName" select="$ParamNode/@stylename" />
      <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
      <xsl:with-param name="ParamRuleType" select="'Graphic'" />
     </xsl:call-template>
    </xsl:if>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:styles">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamNode" select="." />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <xsl:choose>
    <!-- Page style marker -->
    <!--                   -->
    <xsl:when test="$ParamNode/@name = 'PageStyle'">
     <xsl:variable name="VarStyleName">
      <xsl:for-each select="$ParamNode/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:variable>

     <xsl:call-template name="Style-Check">
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamID" select="$ParamID" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
      <xsl:with-param name="ParamRuleType" select="'Page'" />
     </xsl:call-template>
    </xsl:when>

    <!-- Regular marker -->
    <!--                -->
    <xsl:otherwise>
     <xsl:call-template name="Style-Check">
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamID" select="$ParamID" />
      <xsl:with-param name="ParamStyleName" select="$ParamNode/@name" />
      <xsl:with-param name="ParamStyleOverridesExist" select="count($ParamNode/wwdoc:Style/wwdoc:Attribute) &gt; 0" />
      <xsl:with-param name="ParamRuleType" select="'Marker'" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>

   <xsl:apply-templates mode="wwmode:styles">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamID" select="$ParamID" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
