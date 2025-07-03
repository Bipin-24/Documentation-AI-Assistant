<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              exclude-result-prefixes="xsl msxsl"
>
 <xsl:template name="Files-Filter-Allow">
  <xsl:param name="ParamPath" />

  <!-- Include -->
  <!--         -->
  <xsl:variable name="VarInclude">
   <xsl:call-template name="Files-Filter-Include">
    <xsl:with-param name="ParamPath" select="$ParamPath" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Exclude -->
  <!--         -->
  <xsl:variable name="VarExclude">
   <xsl:call-template name="Files-Filter-Exclude">
    <xsl:with-param name="ParamPath" select="$ParamPath" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Allow -->
  <!--       -->
  <xsl:value-of select="($VarInclude = 'true') and ($VarExclude = 'false')" />
 </xsl:template>


 <xsl:template name="Files-Filter-Include">
  <xsl:param name="ParamPath" />

  <!-- Include filter -->
  <!--                -->
  <xsl:choose>
   <!-- PLACEHOLDER -->
   <!--             -->
   <xsl:when test="false()">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- Include all files -->
   <!--                   -->
   <xsl:otherwise>
    <xsl:value-of select="true()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Files-Filter-Exclude">
  <xsl:param name="ParamPath" />

  <!-- Exclude filter -->
  <!--                -->
  <xsl:choose>
   <!-- Exclude CVS directories -->
   <!--                         -->
   <xsl:when test="contains($ParamPath, '\CVS\')">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- Exclude .svn directories -->
   <!--                          -->
   <xsl:when test="contains($ParamPath, '\.svn\')">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- Exclude no files -->
   <!--                  -->
   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
