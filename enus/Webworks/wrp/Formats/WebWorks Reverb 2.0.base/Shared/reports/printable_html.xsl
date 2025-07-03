<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwproject="urn:WebWorks-XSLT-Extension-Project"
                              exclude-result-prefixes="xsl html wwlocale wwreport wwuri wwlog wwproject"
>
 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />

 <xsl:template match="/" mode="html-report">
  <xsl:param name="ParamPath" />

  <xsl:apply-templates mode="html-report">
   <xsl:with-param name="ParamPath" select="$ParamPath" />
  </xsl:apply-templates>
 </xsl:template>
 
 <!-- Report Title Names From Locale -->
 <!-- 								 -->
 <xsl:variable name="VarReportTitleStyles" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'StylesReportTitle']/@value" />
 <xsl:variable name="VarReportTitleLinks" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LinksReportTitle']/@value" />
 <xsl:variable name="VarReportTitleImages" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ImagesReportTitle']/@value" />
 <xsl:variable name="VarReportTitleFilenames" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'FilenamesReportTitle']/@value" />
 <xsl:variable name="VarReportTitleTopics" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TopicsReportTitle']/@value" />
 <xsl:variable name="VarReportTitleConditions" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ConditionsReportTitle']/@value" />
 <xsl:variable name="VarReportTitleBaggageFiles" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'BaggageFilesReportTitle']/@value" />

<!-- Reports Directory Path as an absolute URI -->
<!--                                           -->
 <xsl:variable name="VarReportsDirectoryURI" select="wwuri:AsURI(wwproject:GetProjectReportsDirectoryPath())"/>

 <!-- Assigning Title for Use In Variable -->
 <!-- 									  -->
 <xsl:variable name="VarReportTitle">
  <xsl:choose>
	  <xsl:when test="$GlobalPipelineName = 'Report-Styles'">
	   <xsl:value-of select="$VarReportTitleStyles" />
	  </xsl:when>
	  <xsl:when test="$GlobalPipelineName = 'Report-Links'">
	   <xsl:value-of select="$VarReportTitleLinks" />
	  </xsl:when>
	  <xsl:when test="$GlobalPipelineName = 'Report-Filenames'">
	   <xsl:value-of select="$VarReportTitleFilenames" />
	  </xsl:when>
	  <xsl:when test="$GlobalPipelineName = 'Report-Images'">
	   <xsl:value-of select="$VarReportTitleImages" />
	  </xsl:when>
      <xsl:when test="$GlobalPipelineName = 'Report-Topics'">
	   <xsl:value-of select="$VarReportTitleTopics" />
	  </xsl:when>
      <xsl:when test="$GlobalPipelineName = 'Report-Conditions'">
       <xsl:value-of select="$VarReportTitleConditions" />
      </xsl:when>
      <xsl:when test="$GlobalPipelineName = 'Report-Baggage-Files'">
       <xsl:value-of select="$VarReportTitleBaggageFiles" />
      </xsl:when>
	 </xsl:choose>
 </xsl:variable>

 <xsl:template match="wwreport:Report" mode="html-report">
  <xsl:param name="ParamPath" />

  <xsl:variable name="VarParamURI" select="wwuri:AsURI($ParamPath)" />
  <xsl:variable name="VarRelativeURI" select="wwuri:GetRelativeTo($VarReportsDirectoryURI, $VarParamURI)" />
  <xsl:variable name="VarFontAwesomePath" select="concat($VarRelativeURI, '/Assets/font-awesome/css/all.min.css')" />
  <xsl:variable name="VarCSSStylesheetPath" select="concat($VarRelativeURI, '/Assets/printable_html.css')" />
  
  <html:html>
   <html:head>
    <html:title>
     <xsl:value-of select="$VarReportTitle" />
    </html:title>
    <html:link rel="stylesheet" type="text/css" href="{$VarFontAwesomePath}" />
    <html:link rel="stylesheet" type="text/css" href="{$VarCSSStylesheetPath}" />
   </html:head>
   <html:body>
    <html:h1 class="ww-report-title">
     <xsl:value-of select="$VarReportTitle" />
    </html:h1>

    <html:div class="ww-report-entry-count">
     <xsl:text>Number of Entries: </xsl:text>
     <xsl:variable name="VarEntryCount" select="count(./wwreport:Entry)"/>
     <xsl:value-of select="$VarEntryCount" />
    </html:div>
	
    <html:table border="1">
     <html:thead>
      <html:tr class="ww-report-table-row-header">
       <!-- Severity -->
       <!--          -->
       <html:th>
        <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsSeverity']/@value" />
       </html:th>

       <!-- Document -->
       <!--          -->
       <html:th>
        <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsDocument']/@value" />
       </html:th>

       <!-- Description -->
       <!--             -->
       <html:th>
        <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsDescription']/@value" />
       </html:th>

       <!-- Links -->
       <!--       -->
       <html:th>
        <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsLinks']/@value" />
       </html:th>
      </html:tr>
     </html:thead>

     <html:tbody>
      <xsl:apply-templates mode="html-report">
       <xsl:with-param name="ParamPath" select="$ParamPath" />
      </xsl:apply-templates>
     </html:tbody>
    </html:table>
   </html:body>
  </html:html>
 </xsl:template>


 <xsl:template match="wwreport:Entry" mode="html-report">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamEntry" select="." />

  <!-- Class Name Assignment -->
  <!-- 						 -->
  <xsl:variable name="VarRowClassName">
   <xsl:choose>
    <xsl:when test="$ParamEntry/@severity = 'message'">
	 <xsl:text>ww-report-table-row-message</xsl:text>
	</xsl:when>
	<xsl:when test="$ParamEntry/@severity = 'warning'">
	 <xsl:text>ww-report-table-row-warning</xsl:text>
	</xsl:when>
	<xsl:when test="$ParamEntry/@severity = 'error'">
	 <xsl:text>ww-report-table-row-error</xsl:text>
	</xsl:when>
   </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="VarSeverityIcon">
   <xsl:choose>
    <xsl:when test="$ParamEntry/@severity = 'message'">
	 <xsl:text>fa-check</xsl:text>
	</xsl:when>
	<xsl:when test="$ParamEntry/@severity = 'warning'">
	 <xsl:text>fa-exclamation-triangle</xsl:text>
	</xsl:when>
	<xsl:when test="$ParamEntry/@severity = 'error'">
	 <xsl:text>fa-times</xsl:text>
	</xsl:when>
   </xsl:choose>
  </xsl:variable>
  
  <html:tr>
   <xsl:if test="string-length() &gt; 0">
	<xsl:attribute name="class">
	 <xsl:value-of select="$VarRowClassName" />
	</xsl:attribute>
   </xsl:if>

   <!-- Severity -->
   <!--          -->
   <html:td class="ww-report-table-cell-severity">
	<html:i>
	 <xsl:attribute name="title">
	  <xsl:value-of select="$ParamEntry/@severity" />
	 </xsl:attribute>
	 <xsl:attribute name="class">
	  <xsl:text>fa </xsl:text>
	  <xsl:value-of select="$VarSeverityIcon" />
	 </xsl:attribute>
	</html:i>
   </html:td>

   <!-- Document -->
   <!--          -->
   <html:td>
    <xsl:variable name="VarDocumentPath">
     <xsl:apply-templates select="$ParamEntry" mode="document-path" />
    </xsl:variable>
    <xsl:variable name="VarDocumentUri">
     <xsl:apply-templates select="$ParamEntry/wwreport:Navigation[@context = 'source']/wwreport:Link[@protocol = 'adapter']" mode="navigation-uri-links">
      <xsl:with-param name="ParamPath" select="$ParamPath" />
     </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="VarDocumentFileName">
     <xsl:call-template name="Last-Path-Component">
      <xsl:with-param name="ParamPath" select="$VarDocumentPath" />
      <xsl:with-param name="ParamComponentDelimiter" select="'\'" />
     </xsl:call-template>
    </xsl:variable>

    <html:a target="source" href="{$VarDocumentUri}"><xsl:value-of select="$VarDocumentFileName" /></html:a>
   </html:td>

   <!-- Description -->
   <!--             -->
   <html:td>
    <xsl:for-each select="$ParamEntry/wwreport:Description/text()">
     <xsl:copy />
    </xsl:for-each>
   </html:td>

   <!-- Links -->
   <!--       -->
   <html:td>
    <xsl:apply-templates select="$ParamEntry" mode="navigation-uri-links">
     <xsl:with-param name="ParamPath" select="$ParamPath" />
    </xsl:apply-templates>
   </html:td>
  </html:tr>
 </xsl:template>


 <xsl:template match="*" mode="html-report">
  <xsl:param name="ParamPath" />

  <xsl:apply-templates mode="html-report">
   <xsl:with-param name="ParamPath" select="$ParamPath" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="html-report">
  <xsl:param name="ParamPath" />

  <!-- Do nothing! -->
  <!--             -->
 </xsl:template>


 <!-- Call Templates -->
 <!--                -->

 <xsl:template name="Last-Path-Component">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamComponentDelimiter" />

  <!-- Path contains delimiter? -->
  <!--                          -->
  <xsl:choose>
   <!-- More components to process -->
   <!--                            -->
   <xsl:when test="contains($ParamPath, $ParamComponentDelimiter)">
    <xsl:variable name="VarRemainingPath" select="substring-after($ParamPath, $ParamComponentDelimiter)" />

    <xsl:call-template name="Last-Path-Component">
     <xsl:with-param name="ParamPath" select="$VarRemainingPath" />
     <xsl:with-param name="ParamComponentDelimiter" select="$ParamComponentDelimiter" />
    </xsl:call-template>
   </xsl:when>

   <!-- Last component -->
   <!--                -->
   <xsl:otherwise>
    <xsl:value-of select="$ParamPath" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- document-path -->
 <!--               -->

 <xsl:template match="wwreport:Navigation[@context = 'source']" mode="document-path">
  <xsl:param name="ParamNavigation" select="." />

  <xsl:apply-templates mode="document-path" />
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'adapter']" mode="document-path">
  <xsl:param name="ParamLink" select="." />

  <xsl:variable name="VarDocumentPath" select="$ParamLink/wwreport:Data[@key = 'Path']/@value" />

  <xsl:value-of select="$VarDocumentPath" />
 </xsl:template>


 <xsl:template match="*" mode="document-path">
  <xsl:apply-templates mode="document-path" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="document-path">
  <!-- Do nothing! -->
  <!--             -->
 </xsl:template>


 <!-- navigation-uri-links -->
 <!--                      -->

 <xsl:template match="wwreport:Navigation[@context = 'source']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links">
    <xsl:with-param name="ParamPath" select="$ParamPath" />
   </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">
    <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsSource']/@value" />
   </html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation[@context = 'output']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links">
    <xsl:with-param name="ParamPath" select="$ParamPath" />
   </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <xsl:text>, </xsl:text>

   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">
    <xsl:value-of select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportsOutput']/@value" />
   </html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation[@context = 'uri']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links">
    <xsl:with-param name="ParamPath" select="$ParamPath" />
   </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <xsl:text>, </xsl:text>

   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">URI</html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamNavigation" select="." />

  <!-- Ignore all other naviation links -->
  <!--                                  -->
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'adapter']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamLink" select="." />

  <xsl:variable name="VarDocumentPath" select="$ParamLink/wwreport:Data[@key = 'Path']/@value" />
  <xsl:if test="string-length($VarDocumentPath) &gt; 0">
   <xsl:variable name="VarRelativeDocumentUri" select="wwuri:GetRelativeTo($VarDocumentPath, $ParamPath)" />

   <xsl:value-of select="$VarRelativeDocumentUri" />
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'uri']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamLink" select="." />

  <!-- Make file paths relative? -->
  <!--                           -->
  <xsl:choose>
   <!-- Make file URLs relative to report file -->
   <!--                                        -->
   <xsl:when test="wwuri:IsFile($ParamLink/wwreport:Data[@key = 'URI']/@value)">
    <xsl:variable name="VarRelativeDocumentUri" select="wwuri:GetRelativeTo($ParamLink/wwreport:Data[@key = 'URI']/@value, $ParamPath)" />

    <xsl:value-of select="$VarRelativeDocumentUri" />
   </xsl:when>

   <!-- Emit URL as is -->
   <!--                -->
   <xsl:otherwise>
    <xsl:value-of select="$ParamLink/wwreport:Data[@key = 'URI']/@value" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'wwh5api']" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamLink" select="." />

  <!-- Construct WWHelp URI -->
  <!--                      -->
  <xsl:variable name="VarURI">
   <xsl:value-of select="$ParamLink/wwreport:Data[@key = 'BaseURI']/@value" />
   <xsl:text>/wwhelp/wwhimpl/api.htm</xsl:text>
   <xsl:text>?single=true</xsl:text>
   <xsl:text>&amp;context=</xsl:text>
   <xsl:value-of select="$ParamLink/wwreport:Data[@key = 'Context']/@value" />
   <xsl:text>&amp;topic=</xsl:text>
   <xsl:value-of select="$ParamLink/wwreport:Data[@key = 'Topic']/@value" />
  </xsl:variable>

  <xsl:value-of select="$VarURI" />
 </xsl:template>


 <xsl:template match="*" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />

  <xsl:apply-templates mode="navigation-uri-links">
   <xsl:with-param name="ParamPath" select="$ParamPath" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="navigation-uri-links">
  <xsl:param name="ParamPath" />

  <!-- Do nothing! -->
  <!--             -->
 </xsl:template>
</xsl:stylesheet>
