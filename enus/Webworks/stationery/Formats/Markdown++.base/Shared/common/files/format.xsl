<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:key name="wwfiles-files-by-path" match="wwfiles:File" use="@path" />


 <xsl:template name="Files-Format-GetRelativeFilesInPath">
  <xsl:param name="ParamPath" />

  <xsl:choose>
   <!-- Files directory exists? -->
   <!--                         -->
   <xsl:when test="wwfilesystem:DirectoryExists($ParamPath)">
    <xsl:copy-of select="wwfilesystem:GetRelativeFiles($ParamPath)/wwfiles:Files[1]" />
   </xsl:when>

   <!-- Return empty files list -->
   <!--                         -->
   <xsl:otherwise>
    <wwfiles:Files version="1.0" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Files-Format-GetRelativeFiles">
  <xsl:param name="ParamRelativeURIPath" />

  <!-- Get possible format files directories -->
  <!--                                       -->
  <xsl:variable name="VarPossibleFormatFileUris" select="wwuri:PossibleResolvedUris(concat('wwformat:', $ParamRelativeURIPath))/wwuri:Uris/wwuri:Uri" />

  <!-- Union -->
  <!--       -->
  <wwfiles:Files version="1.0">
   <xsl:variable name="VarFilesAsXML">
    <xsl:for-each select="$VarPossibleFormatFileUris">
     <xsl:variable name="VarUri" select="." />

     <xsl:variable name="VarPath" select="wwuri:AsFilePath($VarUri/@value)" />

     <xsl:call-template name="Files-Format-GetRelativeFilesInPath">
      <xsl:with-param name="ParamPath" select="$VarPath" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarFiles" select="msxsl:node-set($VarFilesAsXML)/wwfiles:Files/wwfiles:File" />

   <!-- Return only unique relative file paths -->
   <!--                                        -->
   <xsl:for-each select="$VarFiles">
    <xsl:variable name="VarFile" select="." />

    <!-- Return first unique path found -->
    <!--                                -->
    <xsl:if test="count(key('wwfiles-files-by-path', $VarFile/@path)[1] | $VarFile) = 1">
     <xsl:copy-of select="$VarFile" />
    </xsl:if>
   </xsl:for-each>
  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
