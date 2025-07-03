<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
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
 <xsl:template name="CompanyInfo-Conditions">
  <xsl:param name="ParamPageRule" />

  <!-- Collect individual conditions -->
  <!--                               -->
  <xsl:variable name="VarCompanyInfoConditionsAsXML">
   <!-- company-link-exists     -->
   <!-- company-link-not-exists -->
   <!--                         -->
   <xsl:choose>
    <xsl:when test="string-length(wwprojext:GetFormatSetting('company-link', '')) &gt; 0">
     <wwpage:Condition name="company-link-exists" />
    </xsl:when>

    <xsl:otherwise>
     <wwpage:Condition name="company-link-not-exists" />
    </xsl:otherwise>
   </xsl:choose>

   <!-- company-logo-src-exists -->
   <!--                         -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-logo-src', '')) &gt; 0">
    <wwpage:Condition name="company-logo-src-exists" />
   </xsl:if>

   <!-- company-name-exists -->
   <!--                     -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-name', '')) &gt; 0">
    <wwpage:Condition name="company-name-exists" />
   </xsl:if>

   <!-- company-email-exists -->
   <!--                      -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-email', '')) &gt; 0">
    <wwpage:Condition name="company-email-exists" />
   </xsl:if>

   <!-- company-fax-exists -->
   <!--                    -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-fax', '')) &gt; 0">
    <wwpage:Condition name="company-fax-exists" />
   </xsl:if>

   <!-- company-phone-exists -->
   <!--                      -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-phone', '')) &gt; 0">
    <wwpage:Condition name="company-phone-exists" />
   </xsl:if>
   
   <!-- company-copyright-exists -->
   <!--                      -->
   <xsl:if test="string-length(wwprojext:GetFormatSetting('company-copyright', '')) &gt; 0">
    <wwpage:Condition name="company-copyright-exists" />
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarCompanyInfoConditions" select="msxsl:node-set($VarCompanyInfoConditionsAsXML)/wwpage:Condition" />

  <!-- Report individual conditions -->
  <!--                              -->
  <xsl:copy-of select="$VarCompanyInfoConditions" />

  <!-- Company Info defined? -->
  <!--                       -->
  <xsl:if test="count($VarCompanyInfoConditions[@name != 'company-link-not-exists']) &gt; 0">
   <!-- company-info-exists -->
   <!--                     -->
   <wwpage:Condition name="company-info-exists" />

   <!-- company-info-top -->
   <!--                  -->
   <xsl:if test="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'company-info-top-generate']/@Value = 'true'">
    <wwpage:Condition name="company-info-top" />
   </xsl:if>

   <!-- company-info-bottom -->
   <!--                     -->
   <xsl:if test="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'company-info-bottom-generate']/@Value = 'true'">
    <wwpage:Condition name="company-info-bottom" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="CompanyInfo-Replacements">
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamPagePath" />
  <xsl:param name="ParamSplits" />

  <!-- company-info-top-alignment -->
  <!--                            -->
  <xsl:variable name="VarCompanyInfoTopAlignmentOption" select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'company-info-top-alignment']/@Value" />
  <xsl:variable name="VarCompanyInfoTopAlignment">
   <xsl:choose>
    <xsl:when test="string-length($VarCompanyInfoTopAlignmentOption) &gt; 0">
     <xsl:value-of select="$VarCompanyInfoTopAlignmentOption" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'left'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="company-info-top-alignment" value="{$VarCompanyInfoTopAlignment}" />

  <!-- company-info-bottom-alignment -->
  <!--                               -->
  <xsl:variable name="VarCompanyInfoBottomAlignmentOption" select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'company-info-bottom-alignment']/@Value" />
  <xsl:variable name="VarCompanyInfoBottomAlignment">
   <xsl:choose>
    <xsl:when test="string-length($VarCompanyInfoBottomAlignmentOption) &gt; 0">
     <xsl:value-of select="$VarCompanyInfoBottomAlignmentOption" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'right'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="company-info-bottom-alignment" value="{$VarCompanyInfoBottomAlignment}" />

  <!-- company-info-top-style -->
  <!--                        -->
  <xsl:variable name="VarCompanyInfoTopStyle">
   <xsl:choose>
    <xsl:when test="$VarCompanyInfoTopAlignmentOption = 'center'">
     <xsl:value-of select="'margin-left: auto;'" />
     <xsl:value-of select="' margin-right: auto;'" />
    </xsl:when>

    <xsl:when test="$VarCompanyInfoTopAlignmentOption = 'right'">
     <xsl:value-of select="'margin-left: auto;'" />
     <xsl:value-of select="' margin-right: 0em;'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'margin-left: 0em;'" />
     <xsl:value-of select="' margin-right: auto;'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="company-info-top-style" value="{$VarCompanyInfoTopStyle}" />

  <!-- company-info-bottom-style -->
  <!--                           -->
  <xsl:variable name="VarCompanyInfoBottomStyle">
   <xsl:choose>
    <xsl:when test="$VarCompanyInfoBottomAlignmentOption = 'center'">
     <xsl:value-of select="'margin-left: auto;'" />
     <xsl:value-of select="' margin-right: auto;'" />
    </xsl:when>

    <xsl:when test="$VarCompanyInfoBottomAlignmentOption = 'left'">
     <xsl:value-of select="'margin-left: 0em;'" />
     <xsl:value-of select="' margin-right: auto;'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'margin-left: auto;'" />
     <xsl:value-of select="' margin-right: 0em;'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <wwpage:Replacement name="company-info-bottom-style" value="{$VarCompanyInfoBottomStyle}" />

  <!-- company-link -->
  <!--              -->
  <wwpage:Replacement name="company-link" value="{wwprojext:GetFormatSetting('company-link')}" />

  <!-- company-logo-src -->
  <!--                  -->
  <wwpage:Replacement name="company-logo-src">
   <xsl:attribute name="value">
    <xsl:call-template name="URI-ResolveProjectFileURI">
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamPagePath" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamURI" select="wwprojext:GetFormatSetting('company-logo-src')" />
    </xsl:call-template>
   </xsl:attribute>
  </wwpage:Replacement>

  <!-- company-name -->
  <!--              -->
  <wwpage:Replacement name="company-name" value="{wwprojext:GetFormatSetting('company-name')}" />

  <!-- company-email      -->
  <!-- company-email-href -->
  <!--                    -->
  <wwpage:Replacement name="company-email" value="{wwprojext:GetFormatSetting('company-email', '')}" />
  <wwpage:Replacement name="company-email-href" value="{concat('mailto:', wwprojext:GetFormatSetting('company-email', ''))}" />

  <!-- company-fax -->
  <!--             -->
  <wwpage:Replacement name="company-fax" value="{wwprojext:GetFormatSetting('company-fax')}" />

  <!-- company-phone -->
  <!--               -->
  <wwpage:Replacement name="company-phone" value="{wwprojext:GetFormatSetting('company-phone')}" />
  
  <!-- company-copyright -->
  <!--               -->
  <wwpage:Replacement name="company-copyright" value="{wwprojext:GetFormatSetting('company-copyright')}" />
 </xsl:template>
</xsl:stylesheet>
