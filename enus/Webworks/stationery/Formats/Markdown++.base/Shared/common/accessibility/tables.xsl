<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
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
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:template name="Tables-SummaryRequired">
  <xsl:param name="ParamTableBehavior" />

  <xsl:variable name="VarTableSummaryNotRequiredBehaviorMarkers" select="$ParamTableBehavior//wwbehaviors:Marker[@behavior = 'table-summary-not-required']" />

  <xsl:choose>
   <xsl:when test="count($VarTableSummaryNotRequiredBehaviorMarkers[1]) = 1">
    <xsl:value-of select="false()" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="true()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Tables-Summary">
  <xsl:param name="ParamTableBehavior" />

  <xsl:variable name="VarTableSummary">
   <xsl:variable name="VarTableSummaryMarkers" select="$ParamTableBehavior//wwbehaviors:Marker[@behavior = 'table-summary']" />
   <xsl:variable name="VarTableSummaryMarkerCount" select="count($VarTableSummaryMarkers)" />

   <xsl:choose>
    <xsl:when test="$VarTableSummaryMarkerCount &gt; 0">
     <xsl:for-each select="$VarTableSummaryMarkers[$VarTableSummaryMarkerCount]/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="''" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="normalize-space($VarTableSummary)" />
 </xsl:template>
</xsl:stylesheet>
