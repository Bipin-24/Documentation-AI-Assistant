<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              exclude-result-prefixes="xsl html wwreport"
>
 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />


 <xsl:template match="/">
  <xsl:apply-templates />
 </xsl:template>


 <xsl:template match="wwreport:Report">
  <html:html>
   <html:head>
    <html:title>
     Title
    </html:title>
   </html:head>

   <html:body>
    <html:h2>
     Title
    </html:h2>

    <html:table border="1">
     <html:thead>
      <html:tr>
       <!-- Severity -->
       <!--          -->
       <html:th>
        Severity
       </html:th>

       <!-- Document -->
       <!--          -->
       <html:th>
        Document
       </html:th>

       <!-- Description -->
       <!--             -->
       <html:th>
        Description
       </html:th>

       <!-- Links -->
       <!--       -->
       <html:th>
        Links
       </html:th>
      </html:tr>
     </html:thead>

     <html:tbody>
      <xsl:apply-templates />
     </html:tbody>
    </html:table>
   </html:body>
  </html:html>
 </xsl:template>


 <xsl:template match="wwreport:Entry">
  <xsl:param name="ParamEntry" select="." />

  <xsl:variable name="VarBackgroundColor">
   <xsl:choose>
    <xsl:when test="$ParamEntry/@severity = 'warning'">
     <xsl:text>yellow</xsl:text>
    </xsl:when>

    <xsl:when test="$ParamEntry/@severity = 'error'">
     <xsl:text>red</xsl:text>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <html:tr>
   <xsl:if test="string-length($VarBackgroundColor) &gt; 0">
    <xsl:attribute name="style">
     <xsl:text>background-color: </xsl:text>
     <xsl:value-of select="$VarBackgroundColor" />
    </xsl:attribute>
   </xsl:if>

   <!-- Severity -->
   <!--          -->
   <html:td>
    <xsl:value-of select="$ParamEntry/@severity" />
   </html:td>

   <!-- Document -->
   <!--          -->
   <html:td>
    <xsl:variable name="VarDocumentPath">
     <xsl:apply-templates select="$ParamEntry" mode="document-path" />
    </xsl:variable>
    <xsl:variable name="VarDocumentUri">
     <xsl:apply-templates select="$ParamEntry/wwreport:Navigation[@context = 'source']/wwreport:Link[@protocol = 'adapter']" mode="navigation-uri-links" />
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
    <xsl:apply-templates select="$ParamEntry" mode="navigation-uri-links" />
   </html:td>
  </html:tr>
 </xsl:template>


 <xsl:template match="*">
  <xsl:apply-templates />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction">
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
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links" />
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">Source</html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation[@context = 'output']" mode="navigation-uri-links">
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links" />
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <xsl:text>, </xsl:text>

   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">Output</html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation[@context = 'uri']" mode="navigation-uri-links">
  <xsl:param name="ParamNavigation" select="." />

  <xsl:variable name="VarURI">
   <xsl:apply-templates mode="navigation-uri-links" />
  </xsl:variable>

  <xsl:if test="string-length($VarURI) &gt; 0">
   <xsl:text>, </xsl:text>

   <html:a target="{$ParamNavigation/@context}" href="{$VarURI}">URI</html:a>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Navigation" mode="navigation-uri-links">
  <xsl:param name="ParamNavigation" select="." />

  <!-- Ignore all other naviation links -->
  <!--                                  -->
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'adapter']" mode="navigation-uri-links">
  <xsl:param name="ParamLink" select="." />

  <xsl:variable name="VarDocumentPath" select="$ParamLink/wwreport:Data[@key = 'Path']/@value" />
  <xsl:if test="string-length($VarDocumentPath) &gt; 0">
   <xsl:variable name="VarDocumentPath_Translate_1" select="translate($VarDocumentPath, '\', '/')" />
   <xsl:variable name="VarDocumentUri" select="concat('file:///', $VarDocumentPath_Translate_1)" />

   <xsl:value-of select="$VarDocumentUri" />
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'uri']" mode="navigation-uri-links">
  <xsl:param name="ParamLink" select="." />

  <xsl:variable name="VarURI" select="$ParamLink/wwreport:Data[@key = 'URI']/@value" />

  <xsl:value-of select="$VarURI" />
 </xsl:template>


 <xsl:template match="wwreport:Link[@protocol = 'wwh5api']" mode="navigation-uri-links">
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
  <xsl:apply-templates mode="navigation-uri-links" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction" mode="navigation-uri-links">
  <!-- Do nothing! -->
  <!--             -->
 </xsl:template>
</xsl:stylesheet>
