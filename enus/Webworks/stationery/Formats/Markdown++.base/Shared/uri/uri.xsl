<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwsplitpriorities="urn:WebWorks-Engine-Split-Priorities-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwsplits wwsplitpriorities wwmode wwfiles wwdoc wwproject wwpage wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
 <xsl:key name="wwsplits-files-by-source-lowercase" match="wwsplits:File" use="@source-lowercase" />


 <xsl:template name="URI-ResolveProjectFileToAbsolutePath">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamURI" />

  <xsl:choose>
   <xsl:when test="string-length($ParamURI) &gt; 0">
    <!-- Resolve project file -->
    <!--                      -->
    <xsl:variable name="VarAbsoluteURI" select="wwuri:MakeAbsolute('wwprojfile:dummy.component', $ParamURI)" />
    <xsl:variable name="VarAbsoluteURIToLower" select="wwstring:ToLower($VarAbsoluteURI)" />
    <xsl:choose>
     <!-- Absolute URI -->
     <!--              -->
     <xsl:when test="string-length($VarAbsoluteURI) &gt; 0">
      <!-- Absolute URI in splits? -->
      <!--                         -->
      <xsl:for-each select="$ParamSplits[1]">
       <xsl:variable name="VarSplitFile" select="key('wwsplits-files-by-source-lowercase', $VarAbsoluteURIToLower)[1]" />
       <xsl:choose>
        <!-- Get URI relative to location -->
        <!--                              -->
        <xsl:when test="count($VarSplitFile) = 1">
         <xsl:value-of select="$VarSplitFile/@path" />
        </xsl:when>

        <!-- Use URI as is -->
        <!--               -->
        <xsl:otherwise>
         <!-- Not found! -->
         <!--            -->
         <xsl:text></xsl:text>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>
     </xsl:when>

     <!-- Use URI as is -->
     <!--               -->
     <xsl:otherwise>
      <!-- Not found! -->
      <!--            -->
      <xsl:text></xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
   <!-- Not found! -->
    <!--            -->
    <xsl:text></xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="URI-ResolveProjectFileURI">
  <xsl:param name="ParamFromAbsoluteURI" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamURI" />


  <!-- Determine absolute path -->
  <!--                         -->
  <xsl:variable name="VarAbsolutePath">
   <xsl:call-template name="URI-ResolveProjectFileToAbsolutePath">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamURI" select="$ParamURI" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <!-- Get URI relative to location -->
   <!--                              -->
   <xsl:when test="string-length($VarAbsolutePath) &gt; 0">
    <xsl:value-of select="wwuri:GetRelativeTo($VarAbsolutePath, $ParamFromAbsoluteURI)" />
   </xsl:when>

   <!-- Use URI as is -->
   <!--               -->
   <xsl:otherwise>
    <xsl:value-of select="$ParamURI" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
