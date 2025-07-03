<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwalinks="urn:WebWorks-ALinks-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwreport wwlinks wwalinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:include href="wwtransform:common/files/utils.xsl" />

 <xsl:key name="wwreport-wwlinks-paragraphs-by-id" match="wwlinks:Paragraph" use="@id" />
 <xsl:key name="wwreport-wwlinks-files-by-documentid" match="wwlinks:File" use="@documentID" />


 <xsl:template name="Report-OutputLink">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamLinksContext" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamParagraphID" />

  <!-- Locate link -->
  <!--             -->
  <xsl:for-each select="$ParamLinksContext[1]">
   <xsl:variable name="VarLinkParagraph" select="key('wwreport-wwlinks-paragraphs-by-id', $ParamParagraphID)[(../@groupID = $ParamGroupID) and (../@documentID = $ParamDocumentID)][1]" />
   <xsl:variable name="VarLinkFile" select="key('wwreport-wwlinks-files-by-documentid', $ParamDocumentID)[@groupID = $ParamGroupID][1]" />

   <xsl:choose>
    <xsl:when test="count($VarLinkParagraph) = 1">
     <xsl:variable name="VarParagraphLinkFile" select="$VarLinkParagraph/.." />

     <!-- Emit link info -->
     <!--                -->
     <wwreport:Link protocol="uri">
      <wwreport:Data key="URI" value="{wwuri:AsURI($VarParagraphLinkFile/@path)}#{$VarLinkParagraph/@linkid}" />
     </wwreport:Link>
    </xsl:when>

    <xsl:when test="count($VarLinkFile) = 1">
     <!-- Emit link info -->
     <!--                -->
     <wwreport:Link protocol="uri">
      <wwreport:Data key="URI" value="{wwuri:AsURI($VarLinkFile/@path)}" />
     </wwreport:Link>
    </xsl:when>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Report-TopicLink">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamLinksContext" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTopic" />

  <!-- Format does not support topic links -->
  <!--                                     -->
 </xsl:template>
</xsl:stylesheet>
