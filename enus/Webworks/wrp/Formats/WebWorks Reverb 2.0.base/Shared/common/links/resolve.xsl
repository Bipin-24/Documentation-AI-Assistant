<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:key name="wwlinks-paragraphs-by-id" match="wwlinks:Paragraph" use="@id" />
 <xsl:key name="wwlinks-files-by-documentpath-lowercase" match="wwlinks:File" use="@documentpath-lowercase" />
 <xsl:key name="wwsplits-files-by-source-lowercase" match="wwsplits:File" use="@source-lowercase" />


 <xsl:template match="wwdoc:Text" mode="wwmode:text-only">
  <xsl:param name="ParamNode" select="." />

  <!-- Emit text -->
  <!--           -->
  <xsl:value-of select="$ParamNode/@value" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:text-only">
  <!-- Recurse -->
  <!--         -->
  <xsl:apply-templates mode="wwmode:text-only" />
 </xsl:template>


 <xsl:template match="text() | processing-instruction() | comment()" mode="wwmode:text-only">
  <!-- Do not process -->
  <!--                -->
 </xsl:template>


 <xsl:template name="Link-Description-As-Title-Attribute">
  <xsl:param name="ParamDocumentLink" />

  <!-- Link description marker provided? -->
  <!--                                   -->
  <xsl:variable name="VarLinkDescription">
   <xsl:for-each select="$ParamDocumentLink/parent::wwdoc:Paragraph//wwdoc:TextRun/wwdoc:Marker | $ParamDocumentLink/parent::wwdoc:TextRun/wwdoc:Marker">
    <xsl:variable name="VarMarker" select="." />

    <!-- Determine marker behavior -->
    <!--                           -->
    <xsl:variable name="VarRule" select="wwprojext:GetRule('Marker', $VarMarker/@name)" />
    <xsl:variable name="VarMarkerTypeOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'marker-type'][1]/@Value" />
    <xsl:if test="$VarMarkerTypeOption = 'link-title'">
     <xsl:apply-templates select="$VarMarker/wwdoc:TextRun" mode="wwmode:text-only" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <!-- Emit if defined -->
  <!--                 -->
  <xsl:if test="string-length($VarLinkDescription) &gt; 0">
   <xsl:attribute name="title">
    <xsl:value-of select="$VarLinkDescription" />
   </xsl:attribute>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Links-Resolve-Baggage">
  <xsl:param name="ParamAllowBaggage" />
  <xsl:param name="ParamBaggageSplitFileType" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamDocumentLink" />

  <xsl:variable name="VarDocumentLinkUrlToLower" select="wwstring:ToLower($ParamDocumentLink/@url)" />

  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarDocumentLinkUrlToLowerAsFilePath" select="wwstring:ToLower(wwuri:AsFilePath($ParamDocumentLink/@url))" />
   <xsl:variable name="VarBaggageFiles" select="key('wwsplits-files-by-source-lowercase', $VarDocumentLinkUrlToLower)[@type = $ParamBaggageSplitFileType] | key('wwsplits-files-by-source-lowercase', $VarDocumentLinkUrlToLowerAsFilePath)[@type = $ParamBaggageSplitFileType]" />

   <xsl:for-each select="$VarBaggageFiles[1]">
    <xsl:variable name="VarBaggageFile" select="." />

    <xsl:variable name="VarTargetDocumentPath" select="wwuri:AsFilePath($ParamDocumentLink/@url)" />

    <xsl:choose>
     <!-- Baggage allowed -->
     <!--                 -->
     <xsl:when test="$ParamAllowBaggage = 'true'">
      <xsl:choose>
       <!-- Baggage file exists! -->
       <!--                      -->
       <xsl:when test="wwfilesystem:FileExists($VarBaggageFile/@source)">
        <wwlinks:ResolvedLink type="baggage">
         <xsl:copy-of select="$VarBaggageFile/@*" />

         <xsl:attribute name="target">
          <xsl:value-of select="$VarTargetDocumentPath" />
         </xsl:attribute>

         <!-- @title attribute -->
         <!--                  -->
         <xsl:call-template name="Link-Description-As-Title-Attribute">
          <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
         </xsl:call-template>
        </wwlinks:ResolvedLink>
       </xsl:when>

       <!-- Missing baggage file? -->
       <!--                       -->
       <xsl:otherwise>
        <wwlinks:UnresolvedLink type="baggage">
         <xsl:attribute name="target">
          <xsl:value-of select="$VarTargetDocumentPath" />
         </xsl:attribute>
        </wwlinks:UnresolvedLink>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <!-- No baggage allowed -->
     <!--                    -->
     <xsl:otherwise>
      <wwlinks:UnsupportedLink type="baggage">
       <xsl:attribute name="target">
        <xsl:value-of select="$VarTargetDocumentPath" />
       </xsl:attribute>
      </wwlinks:UnsupportedLink>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Links-ResolvedLink-Element">
  <xsl:param name="ParamDocumentLink" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamParagraphLink" />
  <xsl:param name="ParamType" />

  <wwlinks:ResolvedLink type="{$ParamType}">
   <xsl:copy-of select="$ParamParagraphLink/../@*" />
   <xsl:copy-of select="$ParamParagraphLink/@*" />

   <!-- Add linkid attributes -->
   <!--                       -->
   <xsl:if test="$ParamParagraphLink/@id != $ParamParagraphLink/@linkid">
    <xsl:for-each select="$ParamLinks[1]">
     <xsl:variable name="VarLinkIDParagraphLink" select="key('wwlinks-paragraphs-by-id', $ParamParagraphLink/@linkid)[../@documentID = $ParamParagraphLink/../@documentID][1]" />

     <xsl:for-each select="$VarLinkIDParagraphLink/@*">
      <xsl:variable name="VarLinkIDParagraphLinkAttribute" select="." />
      <xsl:variable name="VarEmittedAttribute" select="$ParamParagraphLink/@*[name() = name($VarLinkIDParagraphLinkAttribute)]" />

      <xsl:if test="count($VarEmittedAttribute) = 0">
       <xsl:copy-of select="$VarLinkIDParagraphLinkAttribute" />
      </xsl:if>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

   <!-- @title attribute -->
   <!--                  -->
   <xsl:call-template name="Link-Description-As-Title-Attribute">
    <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
   </xsl:call-template>
  </wwlinks:ResolvedLink>
 </xsl:template>


 <xsl:template name="Links-Unsupported-Element">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamParagraphLink" />
  <xsl:param name="ParamType" />

  <wwlinks:UnsupportedLink type="{$ParamType}">
   <xsl:copy-of select="$ParamParagraphLink/../@*" />
   <xsl:copy-of select="$ParamParagraphLink/@*" />

   <!-- Add linkid attributes -->
   <!--                       -->
   <xsl:if test="$ParamParagraphLink/@id != $ParamParagraphLink/@linkid">
    <xsl:for-each select="$ParamLinks[1]">
     <xsl:variable name="VarLinkIDParagraphLink" select="key('wwlinks-paragraphs-by-id', $ParamParagraphLink/@linkid)[../@documentID = $ParamParagraphLink/../@documentID][1]" />

     <xsl:for-each select="$VarLinkIDParagraphLink/@*">
      <xsl:variable name="VarLinkIDParagraphLinkAttribute" select="." />
      <xsl:variable name="VarEmittedAttribute" select="$ParamParagraphLink/@*[name() = name($VarLinkIDParagraphLinkAttribute)]" />

      <xsl:if test="count($VarEmittedAttribute) = 0">
       <xsl:copy-of select="$VarLinkIDParagraphLinkAttribute" />
      </xsl:if>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>
  </wwlinks:UnsupportedLink>
 </xsl:template>


 <xsl:template name="Links-Resolve-Project">
  <xsl:param name="ParamAllowGroupToGroup" />
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplitGroupID" />
  <xsl:param name="ParamSplitDocumentID" />
  <xsl:param name="ParamDocumentLink" />

  <xsl:for-each select="$ParamLinks[1]">
   <xsl:variable name="VarDocumentLinkUrlToLower" select="wwstring:ToLower($ParamDocumentLink/@url)" />

   <!-- Inside Same Document -->
   <!--                      -->
   <xsl:variable name="VarSameDocumentParagraphKeyAsXML">
    <xsl:if test="string-length($ParamDocumentLink/@url) = 0">
     <wwlinks:Key documentID="{$ParamSplitDocumentID}" id="{$ParamDocumentLink/@anchor}" />
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarSameDocumentParagraphKey" select="msxsl:node-set($VarSameDocumentParagraphKeyAsXML)/wwlinks:Key" />

   <!-- Inside Same Document Group -->
   <!--                            -->
   <xsl:variable name="VarGroupDocumentParagraphKeyAsXML">
    <xsl:if test="string-length($ParamDocumentLink/@url) &gt; 0">
     <xsl:variable name="VarGroupDocumentParagraphWithAnchor" select="key('wwlinks-paragraphs-by-id', $ParamDocumentLink/@anchor)[(../@groupID = $ParamSplitGroupID) and (../@documentpath-lowercase = $VarDocumentLinkUrlToLower)]" />

     <xsl:choose>
      <xsl:when test="count($VarGroupDocumentParagraphWithAnchor[1]) = 1">
       <wwlinks:Key documentID="{$VarGroupDocumentParagraphWithAnchor[1]/../@documentID}" id="{$VarGroupDocumentParagraphWithAnchor/@id}" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:variable name="VarGroupDocumentFile" select="key('wwlinks-files-by-documentpath-lowercase', $VarDocumentLinkUrlToLower)[@groupID = $ParamSplitGroupID]" />
       <xsl:if test="count($VarGroupDocumentFile[1]) = 1">
        <wwlinks:Key documentID="{$VarGroupDocumentFile[1]/@documentID}" id="{$VarGroupDocumentFile[1]/wwlinks:Paragraph[1]/@id}" />
       </xsl:if>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarGroupDocumentParagraphKey" select="msxsl:node-set($VarGroupDocumentParagraphKeyAsXML)/wwlinks:Key" />

   <!-- Inside Same Project -->
   <!--                     -->
   <xsl:variable name="VarProjectDocumentParagraphKeyAsXML">
    <xsl:if test="string-length($ParamDocumentLink/@url) &gt; 0">
     <xsl:variable name="VarProjectDocumentParagraphWithAnchor" select="key('wwlinks-paragraphs-by-id', $ParamDocumentLink/@anchor)[../@documentpath-lowercase = $VarDocumentLinkUrlToLower]" />
     <xsl:choose>
      <xsl:when test="count($VarProjectDocumentParagraphWithAnchor[1]) = 1">
       <wwlinks:Key documentID="{$VarProjectDocumentParagraphWithAnchor[1]/../@documentID}" id="{$VarProjectDocumentParagraphWithAnchor/@id}" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:variable name="VarProjectDocumentFile" select="key('wwlinks-files-by-documentpath-lowercase', $VarDocumentLinkUrlToLower)" />
       <xsl:if test="count($VarProjectDocumentFile[1]) = 1">
        <wwlinks:Key documentID="{$VarProjectDocumentFile[1]/@documentID}" id="{$VarProjectDocumentFile[1]/wwlinks:Paragraph[1]/@id}" />
       </xsl:if>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarProjectDocumentParagraphKey" select="msxsl:node-set($VarProjectDocumentParagraphKeyAsXML)/wwlinks:Key" />

   <!-- Return key -->
   <!--            -->
   <xsl:variable name="VarSameDocumentParagraphLink" select="key('wwlinks-paragraphs-by-id', $VarSameDocumentParagraphKey/@id)[../@documentID = $VarSameDocumentParagraphKey/@documentID][1]" />
   <xsl:variable name="VarGroupDocumentParagraphLink" select="key('wwlinks-paragraphs-by-id', $VarGroupDocumentParagraphKey/@id)[../@documentID = $VarGroupDocumentParagraphKey/@documentID][1]" />
   <xsl:variable name="VarProjectDocumentParagraphLink" select="key('wwlinks-paragraphs-by-id', $VarProjectDocumentParagraphKey/@id)[../@documentID = $VarProjectDocumentParagraphKey/@documentID][1]" />
   <xsl:choose>
    <xsl:when test="count($VarSameDocumentParagraphLink) = 1">
     <xsl:call-template name="Links-ResolvedLink-Element">
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamParagraphLink" select="$VarSameDocumentParagraphLink" />
      <xsl:with-param name="ParamType" select="'document'" />
     </xsl:call-template>
    </xsl:when>

    <xsl:when test="count($VarGroupDocumentParagraphLink) = 1">
     <xsl:call-template name="Links-ResolvedLink-Element">
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamParagraphLink" select="$VarGroupDocumentParagraphLink" />
      <xsl:with-param name="ParamType" select="'group'" />
     </xsl:call-template>
    </xsl:when>

    <xsl:when test="count($VarProjectDocumentParagraphLink) = 1">
     <xsl:choose>
      <!-- Group to group links allowed? -->
      <!--                               -->
      <xsl:when test="$ParamAllowGroupToGroup = 'true'">
       <xsl:call-template name="Links-ResolvedLink-Element">
        <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamParagraphLink" select="$VarProjectDocumentParagraphLink" />
        <xsl:with-param name="ParamType" select="'project'" />
       </xsl:call-template>
      </xsl:when>

      <!-- Group to group disabled -->
      <!--                         -->
      <xsl:otherwise>
       <xsl:call-template name="Links-Unsupported-Element">
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamParagraphLink" select="$VarProjectDocumentParagraphLink" />
        <xsl:with-param name="ParamType" select="'project'" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Unresolved link -->
    <!--                 -->
    <xsl:otherwise>
     <xsl:choose>
      <!-- Internal document link -->
      <!--                        -->
      <xsl:when test="(string-length($ParamDocumentLink/@url) = 0) and (string-length($ParamDocumentLink/@anchor &gt; 0))">
       <wwlinks:UnresolvedLink type="document">
        <xsl:attribute name="anchor">
         <xsl:value-of select="$ParamDocumentLink/@anchor" />
        </xsl:attribute>
       </wwlinks:UnresolvedLink>
      </xsl:when>

      <!-- External document link -->
      <!--                        -->
      <xsl:when test="wwuri:IsFile($ParamDocumentLink/@url)">
       <!-- Known document extension? -->
       <!--                           -->
       <xsl:variable name="VarTargetDocumentPath" select="wwuri:AsFilePath($ParamDocumentLink/@url)" />

       <xsl:for-each select="$ParamProject[1]">
        <xsl:variable name="VarProjectSourceDocumentPath" select="wwprojext:GetDocumentPath($ParamSplitDocumentID)" />
        <xsl:variable name="VarSourceDocumentPath" select="wwfilesystem:Combine(wwprojext:GetDocumentGroupPath($ParamSplitDocumentID), wwfilesystem:GetFileName($VarProjectSourceDocumentPath))" />

        <!-- Project thinks the file should be a document in the project -->
        <!--                                                             -->
        <xsl:if test="wwprojext:DocumentExtension(wwfilesystem:GetExtension($VarTargetDocumentPath))">
         <wwlinks:UnresolvedLink type="document">
          <xsl:attribute name="target">
           <xsl:value-of select="$VarTargetDocumentPath" />
          </xsl:attribute>

          <xsl:if test="string-length($ParamDocumentLink/@anchor) &gt; 0">
           <xsl:attribute name="anchor">
            <xsl:value-of select="$ParamDocumentLink/@anchor" />
           </xsl:attribute>
          </xsl:if>
         </wwlinks:UnresolvedLink>
        </xsl:if>
       </xsl:for-each>
      </xsl:when>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Links-Resolve">
  <xsl:param name="ParamAllowBaggage" />
  <xsl:param name="ParamAllowGroupToGroup" />
  <xsl:param name="ParamAllowURL" />
  <xsl:param name="ParamBaggageSplitFileType" />
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplitGroupID" />
  <xsl:param name="ParamSplitDocumentID" />
  <xsl:param name="ParamDocumentLink" />

  <!-- File or not? -->
  <!--              -->
  <xsl:choose>
   <xsl:when test="(string-length($ParamDocumentLink/@url) = 0) or (wwuri:IsFile($ParamDocumentLink/@url))">
    <xsl:variable name="VarDocumentLinkUrlToLower" select="wwstring:ToLower($ParamDocumentLink/@url)" />

    <!-- Baggage File? -->
    <!--               -->
    <xsl:variable name="VarBaggageLinkAsXML">
     <xsl:call-template name="Links-Resolve-Baggage">
      <xsl:with-param name="ParamAllowBaggage" select="$ParamAllowBaggage" />
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParamBaggageSplitFileType" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarBaggageLink" select="msxsl:node-set($VarBaggageLinkAsXML)/*" />

    <xsl:choose>
     <!-- Baggage file? -->
     <!--               -->
     <xsl:when test="count($VarBaggageLink) &gt; 0">
      <xsl:copy-of select="$VarBaggageLink" />
     </xsl:when>

     <!-- Project link? -->
     <!--               -->
     <xsl:otherwise>
      <xsl:call-template name="Links-Resolve-Project">
       <xsl:with-param name="ParamAllowGroupToGroup" select="$ParamAllowGroupToGroup" />
       <xsl:with-param name="ParamProject" select="$GlobalProject" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplitGroupID" select="$ParamSplitGroupID" />
       <xsl:with-param name="ParamSplitDocumentID" select="$ParamSplitDocumentID" />
       <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <!-- Not a file -->
    <!--            -->
    <xsl:choose>
     <xsl:when test="$ParamAllowURL = 'true'">
      <wwlinks:ResolvedLink type="url">
       <xsl:attribute name="url">
        <xsl:value-of select="$ParamDocumentLink/@url" />

        <xsl:if test="string-length($ParamDocumentLink/@anchor) &gt; 0">
         <xsl:text>#</xsl:text>
         <xsl:value-of select="$ParamDocumentLink/@anchor" />
        </xsl:if>
       </xsl:attribute>

       <!-- @title attribute -->
       <!--                  -->
       <xsl:call-template name="Link-Description-As-Title-Attribute">
        <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
       </xsl:call-template>
      </wwlinks:ResolvedLink>
     </xsl:when>

     <xsl:otherwise>
      <wwlinks:UnsupportedLink type="url">
       <xsl:attribute name="url">
        <xsl:value-of select="$ParamDocumentLink/@url" />

        <xsl:if test="string-length($ParamDocumentLink/@anchor) &gt; 0">
         <xsl:text>#</xsl:text>
         <xsl:value-of select="$ParamDocumentLink/@anchor" />
        </xsl:if>
       </xsl:attribute>
      </wwlinks:UnsupportedLink>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
