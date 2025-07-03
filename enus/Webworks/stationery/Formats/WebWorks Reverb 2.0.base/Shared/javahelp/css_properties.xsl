<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprops="urn:WebWorks-Properties-Schema"
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
 <xsl:key name="wwprops-property-by-name" match="wwprops:Property" use="@name" />


 <xsl:variable name="GlobalValidCSSProperties" select="wwexsldoc:LoadXMLWithoutResolver('wwtransform:javahelp/css_properties.xml', false())" />


 <xsl:template name="CSS-TranslateProjectProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamFromAbsoluteURI" />
  <xsl:param name="ParamSplits" />

  <!-- JavaHelp CSS Properties Info                                           -->
  <!-- http://java.sun.com/j2se/1.5.0/docs/api/javax/swing/text/html/CSS.html -->

  <!-- background-position -->
  <!--                     -->
  <xsl:for-each select="$GlobalValidCSSProperties[1]">
   <xsl:for-each select="key('wwprops-property-by-name', 'background-position')[1]">
    <xsl:variable name="VarBackgroundPositionHorizontal" select="$ParamProperties[@Name = 'background-position-horizontal']/@Value" />
    <xsl:variable name="VarBackgroundPositionVertical" select="$ParamProperties[@Name = 'background-position-vertical']/@Value" />
    <xsl:if test="(string-length($VarBackgroundPositionHorizontal) &gt; 0) or (string-length($VarBackgroundPositionVertical) &gt; 0)">
     <xsl:variable name="VarBackgroundPosition">
      <xsl:choose>
       <xsl:when test="string-length($VarBackgroundPositionHorizontal) &gt; 0">
        <xsl:value-of select="$VarBackgroundPositionHorizontal" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="'left'" />
       </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="string-length($VarBackgroundPositionVertical) &gt; 0">
       <xsl:text> </xsl:text>
       <xsl:value-of select="$VarBackgroundPositionVertical" />
      </xsl:if>
     </xsl:variable>

     <xsl:if test="string-length($VarBackgroundPosition) &gt; 0">
      <wwproject:Property Name="background-position" Value="{$VarBackgroundPosition}" />
     </xsl:if>
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>

  <!-- text-decoration -->
  <!--                 -->
  <xsl:for-each select="$GlobalValidCSSProperties[1]">
   <xsl:for-each select="key('wwprops-property-by-name', 'text-decoration')[1]">
    <xsl:variable name="VarTextDecoration">
     <!-- blink -->
     <!--       -->
     <xsl:for-each select="$ParamProperties[@Name = 'text-decoration-blink']">
      <xsl:if test="@Value = 'true'">
       <xsl:value-of select="'blink '" />
      </xsl:if>
     </xsl:for-each>

     <!-- line-through -->
     <!--              -->
     <xsl:for-each select="$ParamProperties[@Name = 'text-decoration-line-through']">
      <xsl:if test="(@Value = 'single') or (@Value = 'double')">
       <xsl:value-of select="'line-through '" />
      </xsl:if>
     </xsl:for-each>

     <!-- overline -->
     <!--          -->
     <xsl:for-each select="$ParamProperties[@Name = 'text-decoration-overline']">
      <xsl:if test="(@Value = 'single') or (@Value = 'double')">
       <xsl:value-of select="'overline '" />
      </xsl:if>
     </xsl:for-each>

     <!-- underline -->
     <!--           -->
     <xsl:for-each select="$ParamProperties[@Name = 'text-decoration-underline']">
      <xsl:if test="(@Value = 'single') or (@Value = 'double')">
       <xsl:value-of select="'underline '" />
      </xsl:if>
     </xsl:for-each>
    </xsl:variable>
    <xsl:if test="string-length($VarTextDecoration) &gt; 0">
     <wwproject:Property Name="text-decoration" Value="{substring($VarTextDecoration, 1, string-length($VarTextDecoration) - 1)}" />
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>

  <!-- border-style -->
  <!--              -->
  <xsl:for-each select="$GlobalValidCSSProperties[1]">
   <xsl:for-each select="key('wwprops-property-by-name', 'border-style')[1]">
    <xsl:variable name="VarBorderLeftStyle" select="$ParamProperties[@Name = 'border-left-style']/@Value" />
    <xsl:variable name="VarBorderRightStyle" select="$ParamProperties[@Name = 'border-right-style']/@Value" />
    <xsl:variable name="VarBorderTopStyle" select="$ParamProperties[@Name = 'border-top-style']/@Value" />
    <xsl:variable name="VarBorderBottomStyle" select="$ParamProperties[@Name = 'border-bottom-style']/@Value" />

    <xsl:if test="(string-length($VarBorderLeftStyle) &gt; 0) or (string-length($VarBorderRightStyle) &gt; 0) or (string-length($VarBorderTopStyle) &gt; 0) or (string-length($VarBorderBottomStyle) &gt; 0)">
     <xsl:variable name="VarBorderStyle">
      <xsl:choose>
       <xsl:when test="($VarBorderLeftStyle != 'none') and (string-length($VarBorderLeftStyle) &gt; 0)">
        <xsl:value-of select="$VarBorderLeftStyle" />
       </xsl:when>

       <xsl:when test="($VarBorderRightStyle != 'none') and (string-length($VarBorderRightStyle) &gt; 0)">
        <xsl:value-of select="$VarBorderRightStyle" />
       </xsl:when>

       <xsl:when test="($VarBorderTopStyle != 'none') and (string-length($VarBorderTopStyle) &gt; 0)">
        <xsl:value-of select="$VarBorderTopStyle" />
       </xsl:when>

       <xsl:when test="($VarBorderBottomStyle != 'none') and (string-length($VarBorderBottomStyle) &gt; 0)">
        <xsl:value-of select="$VarBorderBottomStyle" />
       </xsl:when>
      </xsl:choose>
     </xsl:variable>

     <xsl:if test="($VarBorderStyle = 'none') or ($VarBorderStyle = 'inset') or ($VarBorderStyle = 'outset')">
      <wwproject:Property Name="border-style" Value="{$VarBorderStyle}" />
     </xsl:if>
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>

  <!-- Valid CSS properties -->
  <!--                      -->
  <xsl:for-each select="$ParamProperties">
   <xsl:variable name="VarProperty" select="." />

   <xsl:for-each select="$GlobalValidCSSProperties[1]">
    <xsl:for-each select="key('wwprops-property-by-name', $VarProperty/@Name)[1]">
     <xsl:choose>
      <!-- background-image -->
      <!--                  -->
      <xsl:when test="$VarProperty/@Name = 'background-image'">
       <xsl:if test="(string-length($VarProperty/@Value) &gt; 0) and ($VarProperty/@Value != 'none')">
        <xsl:variable name="VarValue">
         <xsl:text>url("</xsl:text>
         <xsl:call-template name="URI-ResolveProjectFileURI">
          <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamFromAbsoluteURI" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamURI" select="$VarProperty/@Value" />
         </xsl:call-template>
         <xsl:text>")</xsl:text>
        </xsl:variable>

        <wwproject:Property Name="{$VarProperty/@Name}" Value="{$VarValue}" />
       </xsl:if>
      </xsl:when>

      <!-- border-width -->
      <!--              -->
      <xsl:when test="($VarProperty/@Name = 'border-left-width') or ($VarProperty/@Name = 'border-right-width') or ($VarProperty/@Name = 'border-top-width') or ($VarProperty/@Name = 'border-bottom-width')">
       <xsl:variable name="VarWidthNumber" select="wwunits:NumericPrefix($VarProperty/@Value)" />
       <xsl:variable name="VarWidthUnits" select="wwunits:UnitsSuffix($VarProperty/@Value)" />

       <xsl:choose>
        <xsl:when test="string-length($VarWidthUnits) &gt; 0">
         <xsl:variable name="VarWidthNumberAsPixels" select="wwunits:Convert($VarWidthNumber, $VarWidthUnits, 'px')" />

         <xsl:choose>
          <xsl:when test="($VarWidthUnits = 'px') and ($VarWidthNumberAsPixels &gt; 0) and ($VarWidthNumberAsPixels &lt; 1)">
           <wwproject:Property Name="{$VarProperty/@Name}" Value="1px" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:copy-of select="$VarProperty" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:when>

        <xsl:when test="($VarWidthNumber &gt; 0) and ($VarWidthNumber &lt; 1)">
         <wwproject:Property Name="{$VarProperty/@Name}" Value="1px" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:copy-of select="$VarProperty" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <!-- Everything else -->
      <!--                 -->
      <xsl:otherwise>
       <xsl:copy-of select="$VarProperty" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="CSS-TranslateImageObjectProjectProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamFromAbsoluteURI" />
  <xsl:param name="ParamSplits" />

  <!-- Remove properties that impact image alignment.                              -->
  <!-- These removed properties will be implemented in the wrapper parent element. -->
  <!--                                                                             -->
  <xsl:call-template name="CSS-TranslateProjectProperties">
   <xsl:with-param name="ParamProperties" select="$ParamProperties[(@Name != 'text-align') and (@Name != 'display') and (@Name != 'float')]" />
   <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamFromAbsoluteURI" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="CSS-TranslateImageWrapperProjectProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamFromAbsoluteURI" />
  <xsl:param name="ParamSplits" />

  <!-- Inject properties that impact image alignment. -->
  <!--                                                -->
  <xsl:call-template name="CSS-TranslateProjectProperties">
   <xsl:with-param name="ParamProperties" select="$ParamProperties[(@Name = 'text-align') or (@Name = 'display') or (@Name = 'float')]" />
   <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamFromAbsoluteURI" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
  </xsl:call-template>

  <!-- Prevent potential inheritance of parent's text-indent property. -->
  <!--                                                                 -->
  <wwproject:Property Name="text-indent" Value="initial" />
 </xsl:template>
 
 
 <xsl:template name="CSS-CatalogProperties">
  <xsl:param name="ParamProperties" />

  <xsl:for-each select="$ParamProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$ParamProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:text>  </xsl:text>
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:text>
</xsl:text>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="CSS-CatalogPropertiesOuter">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarProperties" select="$ParamProperties[(@Name = 'background-color') or (@Name = 'clear') or (@Name != 'margin-left') and ((starts-with(@Name, 'margin-')) or (starts-with(@Name, 'padding-')) or (starts-with(@Name, 'border-')))]" />
  <xsl:for-each select="$VarProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:text>  </xsl:text>
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:text>
</xsl:text>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="CSS-CatalogPropertiesInner">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarProperties" select="$ParamProperties[(@Name != 'background-color') and (@Name != 'clear') and (@Name != 'text-indent') and (not(starts-with(@Name, 'margin-'))) and (not(starts-with(@Name, 'padding-'))) and (not(starts-with(@Name, 'border-')))]" />
  <xsl:for-each select="$VarProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:text>  </xsl:text>
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:text>
</xsl:text>
   </xsl:for-each>
  </xsl:for-each>

  <!-- Hard code 0 values for margins and padding -->
  <!--                                            -->
  <xsl:value-of select="'  margin-left: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  margin-right: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  margin-top: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  margin-bottom: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  padding-left: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  padding-right: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  padding-top: 0pt;'"/>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="'  padding-bottom: 0pt;'"/>
  <xsl:text>
</xsl:text>
 </xsl:template>

 <xsl:template name="CSS-InlineProperties">
  <xsl:param name="ParamProperties" />

  <xsl:for-each select="$ParamProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$ParamProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:if test="position() != last()">
     <xsl:value-of select="' '" />
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="CSS-InlinePropertiesOuter">
  <xsl:param name="ParamContextProperties" />

  <xsl:variable name="VarTextIndent" select="wwunits:NumericPrefix($ParamContextProperties[@Name = 'text-indent']/@Value)" />
  <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($ParamContextProperties[@Name = 'text-indent']/@Value)" />
  <xsl:variable name="VarMarginLeft" select="wwunits:NumericPrefix($ParamContextProperties[@Name = 'margin-left']/@Value)" />
  <xsl:variable name="VarMarginUnits" select="wwunits:UnitsSuffix($ParamContextProperties[@Name = 'margin-left']/@Value)" />

  <!-- Make sure we're talking the same language. -->
  <!--                                            -->
  <xsl:variable name="VarMarginAsTextIndentUnit" select="wwunits:Convert($VarMarginLeft, $VarMarginUnits, $VarTextIndentUnits)" />
  <xsl:variable name="VarMarginSum" select="number($VarMarginAsTextIndentUnit) + number($VarTextIndent)" />

  <!-- And convert it back. -->
  <!--                      -->
  <xsl:variable name="VarMarginSumAsMarginUnits" select="wwunits:Convert($VarMarginSum, $VarTextIndentUnits, $VarMarginUnits)" />

  <!-- margin-left -->
  <!--             -->
  <xsl:text>margin-left: </xsl:text>
  <xsl:value-of select="$VarMarginSumAsMarginUnits" />
  <xsl:value-of select="$VarMarginUnits" />
  <xsl:text>;</xsl:text>

  <xsl:variable name="VarContextProperties" select="$ParamContextProperties[(@Name != 'margin-left') and (not(contains(@Name, 'font')) and not(contains(@Name, 'text')) and not(@Name = 'color'))]" />
  <xsl:for-each select="$VarContextProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarContextProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:if test="position() != last()">
     <xsl:value-of select="' '" />
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="CSS-InlinePropertiesInnerNumber">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarProperties" select="$ParamProperties[(@Name != 'text-indent') and (@Name != 'width') and (@Name != 'white-space') and (contains(@Name, 'font') or contains(@Name, 'text') or (@Name = 'color'))]" />
  <xsl:for-each select="$VarProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:if test="position() != last()">
     <xsl:value-of select="' '" />
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="CSS-InlinePropertiesInnerContent">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarProperties" select="$ParamProperties[(@Name != 'text-indent') and (contains(@Name, 'font') or contains(@Name, 'text') or (@Name = 'color'))]" />
  <xsl:for-each select="$VarProperties[1]">
   <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
   <!--                                                                          -->
   <xsl:for-each select="$VarProperties">
    <xsl:sort select="@Name" data-type="text" order="ascending" />

    <!-- Emit Property -->
    <!--               -->
    <xsl:value-of select="@Name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@Value" />
    <xsl:text>;</xsl:text>
    <xsl:if test="position() != last()">
     <xsl:value-of select="' '" />
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
