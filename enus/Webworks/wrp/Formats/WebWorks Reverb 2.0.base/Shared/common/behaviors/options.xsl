<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwtoc wwlinks wwmode wwfiles wwdoc wwbehaviors wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>

 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />

 <xsl:template name="Behaviors-Options-OptionMarker">
  <xsl:param name="ParamContainer" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamOption" />
  
  <xsl:variable name="VarOptionHint" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = $ParamOption]/@Value" />
  
  <xsl:if test="$VarOptionHint = 'true'">
   <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
    <xsl:variable name="VarBehaviorsParagraphs" select="key('wwbehaviors-paragraphs-by-id', $ParamParagraphID)" />
    
    <xsl:for-each select="$VarBehaviorsParagraphs[1]">
     <xsl:variable name="VarBehaviorsParagraph" select="." />
     
     <xsl:variable name="VarOptionMarkers" select="$VarBehaviorsParagraph/wwbehaviors:Marker[@behavior = $ParamOption]" />
     <xsl:variable name="VarContainerMarkers" select="$ParamContainer//wwdoc:Marker" />
     <xsl:if test="count($VarOptionMarkers) &gt; 0">
     <xsl:call-template name="Behaviors-Options-OptionMarker-Process">
      <xsl:with-param name="ParamOptionMarkers" select="$VarOptionMarkers" />
      <xsl:with-param name="ParamContainerMarkers" select="$VarContainerMarkers" />
      <xsl:with-param name="ParamIndex" select="count($VarContainerMarkers)" />
     </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Behaviors-Options-OptionMarker-Process">
  <xsl:param name="ParamOptionMarkers" />
  <xsl:param name="ParamContainerMarkers" />
  <xsl:param name="ParamIndex" />

  <!-- Find last container marker with the behavior we require -->
  <!--                                                         -->
  <xsl:if test="$ParamIndex &gt; 0">
   <xsl:variable name="VarContainerMarker" select="$ParamContainerMarkers[$ParamIndex]" />

   <xsl:variable name="VarOptionMarker" select="$ParamOptionMarkers[./wwdoc:Marker/@id = $VarContainerMarker/@id][1]" />
   <xsl:choose>
    <!-- Found our marker! -->
    <!--                   -->
    <xsl:when test="count($VarOptionMarker) = 1">
     <xsl:for-each select="$VarContainerMarker/wwdoc:TextRun/wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>
    </xsl:when>

    <!-- Keep looking -->
    <!--              -->
    <xsl:otherwise>
     <xsl:call-template name="Behaviors-Options-OptionMarker-Process">
      <xsl:with-param name="ParamOptionMarkers" select="$ParamOptionMarkers" />
      <xsl:with-param name="ParamContainerMarkers" select="$ParamContainerMarkers" />
      <xsl:with-param name="ParamIndex" select="$ParamIndex - 1" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
