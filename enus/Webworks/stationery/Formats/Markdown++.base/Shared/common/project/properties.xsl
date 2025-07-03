<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
 <xsl:key name="wwproject-properties-by-name" match="wwproject:Property" use="@Name" />

 <xsl:variable name="GlobalValidListProperties" select="wwexsldoc:LoadXMLWithoutResolver('wwtransform:html/list_properties.xml', false())" />

 <xsl:template name="Property-FromDocument">
  <xsl:param name="ParamName" />
  <xsl:param name="ParamValue" />
  <xsl:param name="ParamSource" />

  <xsl:variable name="VarValue">
   <xsl:choose>
    <!-- Insure font family names are surrounded by quotes -->
    <!--                                                   -->
    <xsl:when test="$ParamName = 'font-family'">
     <xsl:choose>
      <xsl:when test="contains($ParamValue, ' ')">
       <xsl:text>&quot;</xsl:text>
       <xsl:value-of select="$ParamValue" />
       <xsl:text>&quot;</xsl:text>
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$ParamValue" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamValue" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:if test="string-length($VarValue) &gt; 0">
   <wwproject:Property Name="{$ParamName}" Value="{$VarValue}" Source="{$ParamSource}" />
  </xsl:if>
 </xsl:template>


 <xsl:template name="Property-Source-Equals">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamName" />

  <!-- Use property source -->
  <!--                     -->
  <xsl:variable name="VarProperties" select="$ParamProperties[@Name = $ParamName]" />

  <xsl:choose>
   <!-- Use property source -->
   <!--                     -->
   <xsl:when test="count($VarProperties) &gt; 0">
    <xsl:value-of select="$VarProperties[1]/@Source" />
   </xsl:when>

   <!-- Default to 'Paragraph' -->
   <!--                        -->
   <xsl:otherwise>
    <xsl:value-of select="'Paragraph'" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Properties-ResolveRule">
  <xsl:param name="ParamDocumentContext" />
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamStyleType" />

  <!-- Explicit -->
  <!--          -->
  <xsl:for-each select="$ParamProperties[@Source = 'Explicit']">
   <xsl:variable name="VarProperty" select="." />

   <xsl:if test="string-length($VarProperty/@Value) &gt; 0">
    <xsl:copy-of select="$VarProperty" />
   </xsl:if>
  </xsl:for-each>

  <!-- List Style Properies -->
  <!--                      -->
  <xsl:variable name="VarListOrListItemElement" select="$ParamDocumentContext//wwdoc:List[@stylename = $ParamStyleName] | $ParamDocumentContext//wwdoc:ListItem[@stylename = $ParamStyleName]" />
  <xsl:if test="count($VarListOrListItemElement) &gt; 0">
   <xsl:variable name="VarBulletImage" select="$ParamProperties[@Name = 'bullet-image']/@Value"/>
   <xsl:variable name="VarBulletCharacter" select="$ParamProperties[@Name = 'bullet-character']/@Value"/>
   <xsl:variable name="VarBulletSeparator" select="$ParamProperties[@Name = 'bullet-separator']/@Value"/>

   <!-- List Style Property Name -->
   <!--                          -->
   <xsl:variable name="VarListStyleName">
    <xsl:choose>
     <xsl:when test="string-length($VarBulletImage) &gt; 0">
      <xsl:value-of select="'list-style-image'"/>
     </xsl:when>
     <xsl:when test="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletSeparator) &gt; 0)">
      <xsl:value-of select="'list-style-type'"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="''"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- List Style Property Value -->
   <!--                           -->
   <xsl:variable name="VarListStyleValue">
    <xsl:choose>
     <xsl:when test="string-length($VarBulletImage) &gt; 0">
      <!-- TODO: may need path param to support other outputs; -->
      <!--       currently configured to work with Reverb 2.0  -->
      <xsl:text>url("../</xsl:text>
      <xsl:value-of select="$VarBulletImage"/>
      <xsl:text>")</xsl:text>
     </xsl:when>
     <xsl:when test="count($GlobalValidListProperties//*[@name = $VarBulletCharacter]) &gt; 0">
      <xsl:value-of select="$VarBulletCharacter"/>
     </xsl:when>
     <xsl:when test="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletSeparator) &gt; 0)">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$VarBulletCharacter"/>
      <xsl:value-of select="$VarBulletSeparator"/>
      <xsl:text>"</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="''"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:if test="(string-length($VarListStyleName) &gt; 0) and (string-length($VarListStyleValue) &gt; 0)">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarListStyleName" />
     <xsl:with-param name="ParamValue" select="$VarListStyleValue" />
     <xsl:with-param name="ParamSource" select="'Explicit'" />
    </xsl:call-template>
   </xsl:if>
  </xsl:if>

  <!-- Catalog Style -->
  <!--               -->
  <xsl:variable name="VarDocumentElement" select="$ParamDocumentContext/wwdoc:Document | $ParamDocumentContext/ancestor::wwdoc:Document" />
  <xsl:variable name="VarCatalogStyles" select="$VarDocumentElement/wwdoc:Styles/wwdoc:*[starts-with(local-name(node()), $ParamStyleType)]" />
  <xsl:variable name="VarCatalogStyle" select="$VarCatalogStyles/wwdoc:*[@name = $ParamStyleName]/wwdoc:Style" />

  <!-- Catalog or Paragraph -->
  <!--                      -->
  <xsl:for-each select="$VarCatalogStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="($VarSource = 'Catalog') or ($VarSource = 'Paragraph')">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
     <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
     <xsl:with-param name="ParamSource" select="$VarSource" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-ResolveContextRule">
  <xsl:param name="ParamDocumentContext" />
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamStyleType" />
  <xsl:param name="ParamContextStyle" />

  <!-- Explicit -->
  <!--          -->
  <xsl:for-each select="$ParamProperties[@Source = 'Explicit']">
   <xsl:variable name="VarProperty" select="." />

   <xsl:if test="string-length($VarProperty/@Value) &gt; 0">
    <xsl:copy-of select="$VarProperty" />
   </xsl:if>
  </xsl:for-each>

  <!-- Paragraph -->
  <!--           -->
  <xsl:for-each select="$ParamContextStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="$VarSource = 'Paragraph'">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
     <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
     <xsl:with-param name="ParamSource" select="$VarSource" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>

  <!-- Catalog Style -->
  <!--               -->
  <xsl:variable name="VarDocumentElement" select="$ParamDocumentContext/wwdoc:Document | $ParamDocumentContext/ancestor::wwdoc:Document" />
  <xsl:variable name="VarCatalogStyles" select="$VarDocumentElement/wwdoc:Styles/wwdoc:*[starts-with(local-name(node()), $ParamStyleType)]" />
  <xsl:variable name="VarCatalogStyle" select="$VarCatalogStyles/wwdoc:*[@name = $ParamStyleName]/wwdoc:Style" />

  <!-- Catalog -->
  <!--         -->
  <xsl:for-each select="$VarCatalogStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Already emitted? -->
   <!--                  -->
   <xsl:if test="($VarSource != 'Paragraph') or (count($ParamContextStyle/wwdoc:Attribute[@name = $VarAttribute/@name]) = 0)">
    <!-- Emit? -->
    <!--       -->
    <xsl:if test="($VarSource = 'Catalog') or ($VarSource = 'Paragraph')">
     <xsl:call-template name="Property-FromDocument">
      <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
      <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
      <xsl:with-param name="ParamSource" select="$VarSource" />
     </xsl:call-template>
    </xsl:if>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-ResolveOverrideRule">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamContextStyle" />
  <xsl:param name="ParamStyleType" select="''" />

  <!-- Explicit -->
  <!--          -->
  <xsl:for-each select="$ParamProperties[@Source = 'Explicit']">
   <xsl:variable name="VarProperty" select="." />

   <xsl:if test="string-length($VarProperty/@Value) &gt; 0">
    <xsl:copy-of select="$VarProperty" />
   </xsl:if>
  </xsl:for-each>

  <!-- Paragraph -->
  <!--           -->
  <xsl:for-each select="$ParamContextStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="$VarSource = 'Paragraph'">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
     <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
     <xsl:with-param name="ParamSource" select="$VarSource" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-Table-Section-ResolveContextRule">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamDocumentContext" />
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamSection" />

  <!-- Filter properties -->
  <!--                   -->
  <xsl:variable name="VarFilteredPropertiesAsXML">
   <xsl:call-template name="Properties-Table-Section-FilterProperties">
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
    <xsl:with-param name="ParamSection" select="$ParamSection" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFilteredProperties" select="msxsl:node-set($VarFilteredPropertiesAsXML)/wwproject:Property" />

  <!-- Catalog Style -->
  <!--               -->
  <xsl:variable name="VarDocumentElement" select="$ParamDocumentContext/wwdoc:Document | $ParamDocumentContext/ancestor::wwdoc:Document" />
  <xsl:variable name="VarCatalogStyles" select="$VarDocumentElement/wwdoc:Styles/wwdoc:*[starts-with(local-name(node()), 'Table')]" />
  <xsl:variable name="VarCatalogStyle" select="$VarCatalogStyles/wwdoc:*[@name = $ParamTable/@stylename]/wwdoc:Style" />

  <!-- Resolve section properties -->
  <!--                            -->
  <xsl:choose>
   <!-- Table Head -->
   <!--            -->
   <xsl:when test="local-name($ParamSection) = 'TableHead'">
    <xsl:variable name="VarCatalogSectionStyle" select="$VarCatalogStyle/wwdoc:TableHead/wwdoc:Style" />
    <xsl:variable name="VarSectionStyle" select="$ParamTable/wwdoc:Style/wwdoc:TableHead/wwdoc:Style" />

    <xsl:call-template name="Properties-Table-Section-ResolveContextProperties">
     <xsl:with-param name="ParamProperties" select="$VarFilteredProperties" />
     <xsl:with-param name="ParamCatalogSectionStyle" select="$VarCatalogSectionStyle" />
     <xsl:with-param name="ParamSectionStyle" select="$VarSectionStyle" />
    </xsl:call-template>
   </xsl:when>

   <!-- Table Footer -->
   <!--              -->
   <xsl:when test="local-name($ParamSection) = 'TableFoot'">
    <xsl:variable name="VarCatalogSectionStyle" select="$VarCatalogStyle/wwdoc:TableFoot/wwdoc:Style" />
    <xsl:variable name="VarSectionStyle" select="$ParamTable/wwdoc:Style/wwdoc:TableFoot/wwdoc:Style" />

    <xsl:call-template name="Properties-Table-Section-ResolveContextProperties">
     <xsl:with-param name="ParamProperties" select="$VarFilteredProperties" />
     <xsl:with-param name="ParamCatalogSectionStyle" select="$VarCatalogSectionStyle" />
     <xsl:with-param name="ParamSectionStyle" select="$VarSectionStyle" />
    </xsl:call-template>
   </xsl:when>

   <!-- Table Body -->
   <!--            -->
   <xsl:otherwise>
    <xsl:variable name="VarCatalogSectionStyle" select="$VarCatalogStyle/wwdoc:TableBody/wwdoc:Style" />
    <xsl:variable name="VarSectionStyle" select="$ParamTable/wwdoc:Style/wwdoc:TableBody/wwdoc:Style" />

    <xsl:call-template name="Properties-Table-Section-ResolveContextProperties">
     <xsl:with-param name="ParamProperties" select="$VarFilteredProperties" />
     <xsl:with-param name="ParamCatalogSectionStyle" select="$VarCatalogSectionStyle" />
     <xsl:with-param name="ParamSectionStyle" select="$VarSectionStyle" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Properties-Table-Section-FilterProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamSection" />

  <!-- Determine filter -->
  <!--                  -->
  <xsl:variable name="VarFilter">
   <xsl:choose>
    <xsl:when test="local-name($ParamSection) = 'TableHead'">
     <xsl:value-of select="'thead-'" />
    </xsl:when>

    <xsl:when test="local-name($ParamSection) = 'TableFoot'">
     <xsl:value-of select="'tfoot-'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'tbody-'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Filter properties -->
  <!--                   -->
  <xsl:for-each select="$ParamProperties">
   <xsl:variable name="VarProperty" select="." />

   <xsl:if test="starts-with($VarProperty/@Name, $VarFilter)">
    <wwproject:Property Name="{substring-after($VarProperty/@Name, $VarFilter)}" Value="{$VarProperty/@Value}" Source="{$VarProperty/@Source}" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-Table-Section-ResolveContextProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamCatalogSectionStyle" />
  <xsl:param name="ParamSectionStyle" />

  <!-- DoNotEmit -->
  <!--           -->
  <xsl:copy-of select="$ParamProperties[@Source = 'DoNotEmit']" />

  <!-- Explicit -->
  <!--          -->
  <xsl:for-each select="$ParamProperties[@Source = 'Explicit']">
   <xsl:variable name="VarProperty" select="." />

   <xsl:if test="string-length($VarProperty/@Value) &gt; 0">
    <xsl:copy-of select="$VarProperty" />
   </xsl:if>
  </xsl:for-each>

  <!-- Section -->
  <!--         -->
  <xsl:for-each select="$ParamSectionStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="($VarSource = 'Catalog') or ($VarSource = 'Paragraph')">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
     <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
     <xsl:with-param name="ParamSource" select="$VarSource" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>

  <!-- Catalog -->
  <!--         -->
  <xsl:for-each select="$ParamCatalogSectionStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$ParamProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="($VarSource = 'Catalog') or ($VarSource = 'Paragraph')">
    <!-- Already emitted? -->
    <!--                  -->
    <xsl:if test="count($ParamSectionStyle/wwdoc:Attribute[@name = $VarAttribute/@name]) = 0">
     <xsl:call-template name="Property-FromDocument">
      <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
      <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
      <xsl:with-param name="ParamSource" select="$VarSource" />
     </xsl:call-template>
    </xsl:if>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-Table-Cell-ResolveProperties">
  <xsl:param name="ParamSectionProperties" />
  <xsl:param name="ParamCellStyle" />
  <xsl:param name="ParamRowIndex" />
  <xsl:param name="ParamColumnIndex" />

  <!-- Background filter -->
  <!--                   -->
  <xsl:variable name="VarBackgroundFilter">
   <xsl:call-template name="Properties-Table-Cell-DetermineBackgroundFilter">
    <xsl:with-param name="ParamSectionProperties" select="$ParamSectionProperties" />
    <xsl:with-param name="ParamRowIndex" select="$ParamRowIndex" />
    <xsl:with-param name="ParamColumnIndex" select="$ParamColumnIndex" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Filter section properties -->
  <!--                           -->
  <xsl:variable name="VarFilteredSectionPropertiesAsXML">
   <xsl:for-each select="$ParamSectionProperties">
    <xsl:variable name="VarProperty" select="." />

    <xsl:choose>
     <xsl:when test="starts-with($VarProperty/@Name, 'background-')">
      <xsl:if test="$VarBackgroundFilter = 'normal'">
       <xsl:copy-of select="$VarProperty" />
      </xsl:if>
     </xsl:when>

     <xsl:when test="starts-with($VarProperty/@Name, 'alternate-background-')">
      <xsl:if test="$VarBackgroundFilter = 'alternate'">
       <wwproject:Property Name="{substring-after($VarProperty/@Name, 'alternate-')}" Value="{$VarProperty/@Value}" Source="{$VarProperty/@Source}" />
      </xsl:if>
     </xsl:when>

     <xsl:otherwise>
      <xsl:copy-of select="$VarProperty" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarFilteredSectionProperties" select="msxsl:node-set($VarFilteredSectionPropertiesAsXML)/wwproject:Property" />

  <!-- Paragraph -->
  <!--           -->
  <xsl:for-each select="$ParamCellStyle/wwdoc:Attribute">
   <xsl:variable name="VarAttribute" select="." />

   <!-- Determine source -->
   <!--                  -->
   <xsl:variable name="VarSource">
    <xsl:call-template name="Property-Source-Equals">
     <xsl:with-param name="ParamProperties" select="$VarFilteredSectionProperties" />
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="$VarSource = 'Paragraph'">
    <xsl:call-template name="Property-FromDocument">
     <xsl:with-param name="ParamName" select="$VarAttribute/@name" />
     <xsl:with-param name="ParamValue" select="$VarAttribute/@value" />
     <xsl:with-param name="ParamSource" select="$VarSource" />
    </xsl:call-template>
   </xsl:if>
  </xsl:for-each>

  <!-- Section -->
  <!--         -->
  <xsl:for-each select="$VarFilteredSectionProperties[@Source != 'DoNotEmit']">
   <xsl:variable name="VarProperty" select="." />

   <!-- Already emitted? -->
   <!--                  -->
   <xsl:if test="($VarProperty/@Source != 'Paragraph') or (count($ParamCellStyle/wwdoc:Attribute[@name = $VarProperty/@Name]) = 0)">
    <xsl:copy-of select="$VarProperty" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Properties-Table-Cell-DetermineBackgroundFilter">
  <xsl:param name="ParamSectionProperties" />
  <xsl:param name="ParamRowIndex" />
  <xsl:param name="ParamColumnIndex" />

  <!-- Determine shading index -->
  <!--                         -->
  <xsl:variable name="VarIndex">
   <xsl:choose>
    <xsl:when test="$ParamSectionProperties[@Name = 'alternate-background-context']/@Value = 'column'">
     <xsl:value-of select="$ParamColumnIndex" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamRowIndex" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Determine shading periods -->
  <!--                           -->
  <xsl:variable name="VarBackgroundPeriod">
   <xsl:call-template name="Properties-Table-Cell-BackgroundPeriod">
    <xsl:with-param name="ParamProperties" select="$ParamSectionProperties" />
    <xsl:with-param name="ParamPeriodAttributeName" select="'background-period'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarAlternateBackgroundPeriod">
   <xsl:call-template name="Properties-Table-Cell-BackgroundPeriod">
    <xsl:with-param name="ParamProperties" select="$ParamSectionProperties" />
    <xsl:with-param name="ParamPeriodAttributeName" select="'alternate-background-period'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Background filter -->
  <!--                   -->
  <xsl:choose>
   <xsl:when test="$VarBackgroundPeriod &gt; 0">
    <xsl:variable name="VarPeriodSum" select="number($VarBackgroundPeriod) + number($VarAlternateBackgroundPeriod)" />
    <xsl:variable name="VarPositionModSum" select="(number($VarIndex) - 1) mod number($VarPeriodSum)" />
    <xsl:choose>
     <xsl:when test="number($VarPositionModSum) &lt; number($VarBackgroundPeriod)">
      <xsl:value-of select="'normal'" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="'alternate'" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="'normal'" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Properties-Table-Cell-BackgroundPeriod">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamPeriodAttributeName" />

  <xsl:variable name="VarPeriodProperty" select="$ParamProperties[@Name = $ParamPeriodAttributeName]" />

  <xsl:choose>
   <xsl:when test="count($VarPeriodProperty) &gt; 0">
    <xsl:choose>
     <xsl:when test="$VarPeriodProperty/@Value &gt; 0">
      <xsl:value-of select="round($VarPeriodProperty/@Value)" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="0" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="0" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Property-Normalize">
  <xsl:param name="ParamProperty"/>
  <xsl:param name="ParamDefault"/>

  <xsl:choose>
   <xsl:when test="string-length($ParamProperty) = 0">
    <xsl:value-of select="$ParamDefault"/>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="$ParamProperty"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
