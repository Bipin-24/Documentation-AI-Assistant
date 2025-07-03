<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwsplits wwdoc wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:key name="wwlocale-locales-by-name" match="wwlocale:Locale" use="@name" />
 <xsl:key name="wwlocale-strings-by-name" match="wwlocale:String" use="@name" />


 <xsl:template name="Locale-Select">
  <xsl:param name="ParamDefaultLocalesPath" />
  <xsl:param name="ParamFormatLocalesPath" />
  <xsl:param name="ParamRequestedLocaleName" />

  <!-- Load default locales -->
  <!--                      -->
  <xsl:variable name="VarDefaultLocales" select="wwexsldoc:LoadXMLWithoutResolver($ParamDefaultLocalesPath)" />

  <!-- Determine required strings -->
  <!--                            -->
  <xsl:variable name="VarRequiredStringsAsXML">
   <xsl:variable name="VarStrings" select="$VarDefaultLocales//wwlocale:Strings/wwlocale:String" />
   <xsl:for-each select="$VarStrings">
    <xsl:variable name="VarString" select="." />

    <xsl:variable name="VarStringsWithName" select="key('wwlocale-strings-by-name', $VarString/@name)" />

    <!-- First unique string name? -->
    <!--                           -->
    <xsl:if test="count($VarStringsWithName[1] | $VarString) = 1">
     <xsl:copy-of select="$VarString" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarRequiredStrings" select="msxsl:node-set($VarRequiredStringsAsXML)/wwlocale:String" />

  <!-- Format locale -->
  <!--               -->
  <xsl:variable name="VarFormatLocaleAsXML">
   <!-- Locales file exists? -->
   <!--                      -->
   <xsl:if test="wwfilesystem:FileExists($ParamFormatLocalesPath)">
    <!-- Load locales  -->
    <!--               -->
    <xsl:variable name="VarFormatLocales" select="wwexsldoc:LoadXMLWithoutResolver($ParamFormatLocalesPath)" />

    <xsl:call-template name="Locale-Find">
     <xsl:with-param name="ParamLocales" select="$VarFormatLocales" />
     <xsl:with-param name="ParamRequestedLocaleName" select="$ParamRequestedLocaleName" />
     <xsl:with-param name="ParamAllowFirst" select="false()" />
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarFormatLocale" select="msxsl:node-set($VarFormatLocaleAsXML)" />

  <!-- Final locale -->
  <!--              -->
  <xsl:variable name="VarFinalLocaleAsXML">
   <xsl:choose>
    <xsl:when test="count($VarFormatLocale/wwlocale:Locale[1]) = 1">
     <xsl:copy-of select="$VarFormatLocale/wwlocale:Locale" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="Locale-Find">
      <xsl:with-param name="ParamLocales" select="$VarDefaultLocales" />
      <xsl:with-param name="ParamRequestedLocaleName" select="$ParamRequestedLocaleName" />
      <xsl:with-param name="ParamAllowFirst" select="true()" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarFinalLocale" select="msxsl:node-set($VarFinalLocaleAsXML)/wwlocale:Locale" />

  <!-- Set required strings -->
  <!--                      -->
  <xsl:apply-templates select="$VarFinalLocale" mode="wwmode:locale-require-strings">
   <xsl:with-param name="ParamRequiredStrings" select="$VarRequiredStrings" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template name="Locale-Find">
  <xsl:param name="ParamLocales" />
  <xsl:param name="ParamRequestedLocaleName" />
  <xsl:param name="ParamAllowFirst" />

  <!-- Select locale -->
  <!--               -->
  <xsl:for-each select="$ParamLocales[1]">
   <xsl:variable name="VarRequestedLocale" select="key('wwlocale-locales-by-name', $ParamRequestedLocaleName)[1]" />
   <xsl:variable name="VarRequestedLanguageLocale" select="key('wwlocale-locales-by-name', substring($ParamRequestedLocaleName, 1, 2))[1]" />

   <xsl:choose>
    <xsl:when test="count($VarRequestedLocale) = 1">
     <!-- Requested locale found -->
     <!--                        -->
     <xsl:copy-of select="$VarRequestedLocale" />
    </xsl:when>

    <xsl:when test="count($VarRequestedLanguageLocale) = 1">
     <!-- Requested language found -->
     <!--                          -->
     <xsl:copy-of select="$VarRequestedLanguageLocale" />
    </xsl:when>

    <xsl:when test="$ParamAllowFirst">
     <!-- Use first available -->
     <!--                     -->
     <xsl:copy-of select="$ParamLocales/wwlocale:Locales/wwlocale:Locale[1]" />
    </xsl:when>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:locale-require-strings">
  <xsl:param name="ParamRequiredStrings" />
  <xsl:param name="ParamNode" select="." />

  <xsl:copy>
   <xsl:copy-of select="$ParamNode/@*" />

   <xsl:apply-templates mode="wwmode:locale-require-strings">
    <xsl:with-param name="ParamRequiredStrings" select="$ParamRequiredStrings" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text()" mode="wwmode:locale-require-strings">
  <xsl:param name="ParamRequiredStrings" />
  <xsl:param name="ParamText" select="." />

  <xsl:copy-of select="$ParamText" />
 </xsl:template>


 <xsl:template match="wwlocale:Strings" mode="wwmode:locale-require-strings">
  <xsl:param name="ParamRequiredStrings" />
  <xsl:param name="ParamStrings" select="." />

  <xsl:copy>
   <xsl:copy-of select="$ParamStrings/@*" />

   <!-- Insure all required strings are defined -->
   <!--                                         -->
   <xsl:for-each select="$ParamRequiredStrings">
    <xsl:variable name="VarRequiredString" select="." />

    <xsl:variable name="VarString" select="$ParamStrings/wwlocale:String[@name = $VarRequiredString/@name][1]" />

    <xsl:choose>
     <xsl:when test="count($VarString)">
      <xsl:copy-of select="$VarString" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:copy-of select="$VarRequiredString" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </xsl:copy>
 </xsl:template>
</xsl:stylesheet>
