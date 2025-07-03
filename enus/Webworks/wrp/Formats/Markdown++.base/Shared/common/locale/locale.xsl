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
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterType" />


 <xsl:strip-space elements="*" />
 <xsl:namespace-alias stylesheet-prefix="wwlocale" result-prefix="#default" />


 <xsl:include href="wwtransform:common/locale/select.xsl"/>


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:common/locale/select.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/locale/select.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">
   <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />

   <xsl:variable name="VarDefaultLocalesPath" select="wwuri:AsFilePath('wwtransform:common/locale/locales.xml')" />
   <xsl:variable name="VarFormatLocalesPath" select="wwuri:AsFilePath('wwformat:Transforms/locales.xml')" />

   <!-- Up to date? -->
   <!--             -->
   <xsl:variable name="VarProjectChecksum">
    <xsl:value-of select="$GlobalProject/wwproject:Project/@ChangeID" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$VarDefaultLocalesPath" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$VarFormatLocalesPath" />
   </xsl:variable>
   <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, '', '', $GlobalActionChecksum)" />
   <xsl:if test="not($VarUpToDate)">
    <!-- Select locale -->
    <!--               -->
    <xsl:variable name="VarLocaleAsXML">
     <xsl:call-template name="Locale-Select">
      <xsl:with-param name="ParamDefaultLocalesPath" select="$VarDefaultLocalesPath" />
      <xsl:with-param name="ParamFormatLocalesPath" select="$VarFormatLocalesPath" />
      <xsl:with-param name="ParamRequestedLocaleName" select="wwprojext:GetFormatSetting('locale', 'en')" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarLocale" select="msxsl:node-set($VarLocaleAsXML)/wwlocale:Locale" />

    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarLocale, $VarPath, 'UTF-8', 'xml', '1.0', 'yes')" />
   </xsl:if>

   <!-- Single locale file for the whole project -->
   <!--                                          -->
   <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$VarProjectChecksum}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
    <wwfiles:Depends path="{$VarDefaultLocalesPath}" checksum="{wwfilesystem:GetChecksum($VarDefaultLocalesPath)}" groupID="" documentID="" />
    <xsl:if test="wwfilesystem:FileExists($VarFormatLocalesPath)">
     <wwfiles:Depends path="{$VarFormatLocalesPath}" checksum="{wwfilesystem:GetChecksum($VarFormatLocalesPath)}" groupID="" documentID="" />
    </xsl:if>
   </wwfiles:File>
  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
