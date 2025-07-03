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
 <xsl:template name="Images-LongDescriptionRequired">
  <xsl:param name="ParamBehaviorFrame" />

  <xsl:variable name="VarImageLongDescriptionNotRequiredBehaviorMarkers" select="$ParamBehaviorFrame//wwbehaviors:Marker[@behavior = 'image-long-description-not-required']" />

  <xsl:choose>
   <xsl:when test="count($VarImageLongDescriptionNotRequiredBehaviorMarkers[1]) = 1">
    <xsl:value-of select="false()" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="true()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-LongDescription">
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamBehaviorFrame" />

  <xsl:variable name="VarLongDescription">
   <!-- Handle ByRef first -->
   <!--                    -->
   <xsl:variable name="VarImageLongDescriptionByRefMarkers" select="$ParamBehaviorFrame//wwbehaviors:Marker[(@behavior = 'image-long-description-by-reference')]" />
   <xsl:variable name="VarImageLongDescriptionByRefMarkerCount" select="count($VarImageLongDescriptionByRefMarkers)" />

   <xsl:choose>
    <xsl:when test="$VarImageLongDescriptionByRefMarkerCount &gt; 0">
     <xsl:for-each select="$VarImageLongDescriptionByRefMarkers[$VarImageLongDescriptionByRefMarkerCount]/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarImageLongDescriptionTextMarkers" select="$ParamBehaviorFrame//wwbehaviors:Marker[(@behavior = 'image-long-description-text')]" />
     <xsl:variable name="VarImageLongDesctiptionTextMarkerCount" select="count($VarImageLongDescriptionTextMarkers)" />

     <xsl:choose>
      <xsl:when test="$VarImageLongDesctiptionTextMarkerCount &gt; 0">
       <xsl:variable name="VarSplit" select="$ParamSplitsFrame/.." />

       <xsl:variable name="VarDescriptionPath" select="$ParamSplitsFrame/wwsplits:Description/@path" />
       <xsl:variable name="VarRelativeDescriptionPath" select="wwuri:GetRelativeTo($VarDescriptionPath, $VarSplit/@path)" />

       <xsl:value-of select="$VarRelativeDescriptionPath" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="''" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="normalize-space($VarLongDescription)" />
 </xsl:template>


 <xsl:template name="Images-AltText">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamBehaviorFrame" />

  <xsl:variable name="VarAltText">
   <xsl:variable name="VarDescriptionText">
    <xsl:for-each select="$ParamFrame/wwdoc:Description/wwdoc:Paragraph">
     <xsl:variable name="VarParagraph" select="." />

     <xsl:for-each select="$VarParagraph//wwdoc:TextRun/wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>

     <!-- Emit space between paragraphs -->
     <!--                               -->
     <xsl:if test="position() != last()">
      <xsl:text> </xsl:text>
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="string-length($VarDescriptionText) &gt; 0">
     <xsl:value-of select="$VarDescriptionText"/>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarImageAltTextMarkers" select="$ParamBehaviorFrame//wwbehaviors:Marker[@behavior = 'image-alt-text']" />
     <xsl:variable name="VarImageAltTextMarkerCount" select="count($VarImageAltTextMarkers)" />

     <xsl:choose>
      <xsl:when test="$VarImageAltTextMarkerCount &gt; 0">
       <xsl:for-each select="$VarImageAltTextMarkers[$VarImageAltTextMarkerCount]/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
        <xsl:value-of select="@value" />
       </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="''" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="normalize-space($VarAltText)" />
 </xsl:template>


 <xsl:template name="Images-ImageAreaAltTextFromMarkers">
  <xsl:param name="ParamFrameParagraphs" />
  <xsl:param name="ParamParentBehavior" />
  <xsl:param name="ParamPosition" />

  <xsl:variable name="VarContextParagraph" select="$ParamFrameParagraphs[$ParamPosition]" />

  <xsl:if test="count($VarContextParagraph) &gt; 0">
   <xsl:variable name="VarBehaviorParagraph" select="$ParamParentBehavior//wwbehaviors:Paragraph[@id = $VarContextParagraph/@id]" />

   <xsl:if test="count($VarBehaviorParagraph) &gt; 0">
    <xsl:variable name="VarImageAreaAltTextBehaviorMarkers" select="$VarBehaviorParagraph/wwbehaviors:Marker[@behavior = 'image-area-alt-text']" />

    <xsl:choose>
     <xsl:when test="count($VarImageAreaAltTextBehaviorMarkers[1]) = 1">
      <xsl:for-each select="$VarImageAreaAltTextBehaviorMarkers[1]/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Images-ImageAreaAltTextFromMarkers">
       <xsl:with-param name="ParamFrameParagraphs" select="$ParamFrameParagraphs" />
       <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
       <xsl:with-param name="ParamPosition" select="$ParamPosition + 1" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Images-ImageAreaAltText">
  <xsl:param name="ParamParentBehavior" />
  <xsl:param name="ParamFrame" />

  <xsl:variable name="VarAltText">
   <xsl:variable name="VarDescriptionText">
    <xsl:for-each select="$ParamFrame/wwdoc:Description/wwdoc:Paragraph">
     <xsl:variable name="VarParagraph" select="." />

     <xsl:for-each select="$VarParagraph//wwdoc:TextRun/wwdoc:Text">
      <xsl:value-of select="@value" />
     </xsl:for-each>

     <!-- Emit space between paragraphs -->
     <!--                               -->
     <xsl:if test="position() != last()">
      <xsl:text> </xsl:text>
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="string-length($VarDescriptionText) &gt; 0">
     <xsl:value-of select="$VarDescriptionText"/>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarImageAreaAltTextFromMarkers">
      <xsl:call-template name="Images-ImageAreaAltTextFromMarkers">
       <xsl:with-param name="ParamFrameParagraphs" select="$ParamFrame/wwdoc:Content/wwdoc:Paragraph" />
       <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
       <xsl:with-param name="ParamPosition" select="1" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:choose>
      <xsl:when test="string-length($VarImageAreaAltTextFromMarkers) &gt; 0">
       <xsl:value-of select="$VarImageAreaAltTextFromMarkers" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="''"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="normalize-space($VarAltText)" />
 </xsl:template>
</xsl:stylesheet>
