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


 <xsl:variable name="GlobalValidFOProperties" select="wwexsldoc:LoadXMLWithoutResolver('wwtransform:fo/fo_properties.xml', false())/wwprops:Properties/wwprops:Property" />
 <xsl:variable name="GlobalQuote">
  <xsl:text>"</xsl:text>
 </xsl:variable>

 <xsl:template name="FO-TranslateProjectProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamStyleType" />

  <xsl:variable name="VarFOPropertiesAsXML">
   <!-- text-decoration -->
   <!--                 -->
   <xsl:for-each select="$GlobalValidFOProperties[1]">
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


   <!-- Clip -->
   <!--      -->
   <xsl:variable name="VarClipBottom" select="$ParamProperties[@Name = 'clip-bottom']" />
   <xsl:variable name="VarClipLeft" select="$ParamProperties[@Name = 'clip-left']" />
   <xsl:variable name="VarClipRight" select="$ParamProperties[@Name = 'clip-right']" />
   <xsl:variable name="VarClipTop" select="$ParamProperties[@Name = 'clip-top']" />

   <xsl:if test="(string-length($VarClipBottom/@Value) &gt; 0) or (string-length($VarClipLeft/@Value) &gt; 0) or (string-length($VarClipRight/@Value) &gt; 0) or (string-length($VarClipTop/@Value) &gt; 0)">
    <!-- Bottom -->
    <!--        -->
    <xsl:variable name="VarClipBottomValue">
     <xsl:choose>
      <xsl:when test="string-length($VarClipBottom/@Value) &gt; 0">
       <xsl:value-of select="$VarClipBottom/@Value" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>0pt</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Left -->
    <!--      -->
    <xsl:variable name="VarClipLeftValue">
     <xsl:choose>
      <xsl:when test="string-length($VarClipLeft/@Value) &gt; 0">
       <xsl:value-of select="$VarClipLeft/@Value" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>0pt</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Right -->
    <!--       -->
    <xsl:variable name="VarClipRightValue">
     <xsl:choose>
      <xsl:when test="string-length($VarClipRight/@Value) &gt; 0">
       <xsl:value-of select="$VarClipRight/@Value" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>0pt</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Top -->
    <!--     -->
    <xsl:variable name="VarClipTopValue">
     <xsl:choose>
      <xsl:when test="string-length($VarClipTop/@Value) &gt; 0">
       <xsl:value-of select="$VarClipTop/@Value" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>0pt</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <wwproject:Property Name="clip" Value="rect({$VarClipTopValue}, {$VarClipRightValue}, {$VarClipBottomValue}, {$VarClipLeftValue})" />
   </xsl:if>


   <!-- Valid FO properties -->
   <!--                     -->
   <xsl:for-each select="$ParamProperties[not(string-length(@Value) = 0) and not(starts-with(@Name, 'clip')) and not(starts-with(@Name, 'text-decoration'))]">
    <xsl:variable name="VarProperty" select="." />

    <xsl:for-each select="$GlobalValidFOProperties[1]">
     <xsl:for-each select="key('wwprops-property-by-name', $VarProperty/@Name)[1]">
      <xsl:choose>
       <!-- background-image -->
       <!--                  -->
       <xsl:when test="$VarProperty/@Name = 'background-image'">
        <xsl:if test="(string-length($VarProperty/@Value) &gt; 0) and ($VarProperty/@Value != 'none')">
         <xsl:variable name="VarValue">
          <xsl:text>url('</xsl:text>
          <xsl:call-template name="FO-ResolveProjectFileURI">
           <xsl:with-param name="ParamURI" select="$VarProperty/@Value" />
          </xsl:call-template>
          <xsl:text>')</xsl:text>
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
           <xsl:when test="($VarWidthNumberAsPixels &gt; 0) and ($VarWidthNumberAsPixels &lt; 1)">
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

       <!-- Strip xsl prefixes -->
       <!--                    -->
       <xsl:when test="starts-with($VarProperty/@Name, 'xsl-')">
        <wwproject:Property Name="{substring-after($VarProperty/@Name, 'xsl-')}" Value="{$VarProperty/@Value}" />
       </xsl:when>

       <!-- Translate colors to RGB values -->
       <!--                                -->
       <xsl:when test="($VarProperty/@Name = 'color') or (contains($VarProperty/@Name, '-color'))">
        <!-- Determine RGB color value -->
        <!--                           -->
        <xsl:variable name="VarRGBColor">
         <xsl:choose>
          <xsl:when test="string-length($VarProperty/@Value) &gt; 0">
           <xsl:choose>
            <xsl:when test="contains($VarProperty/@Value, '#')">
             <xsl:value-of select="$VarProperty/@Value" />
            </xsl:when>

            <xsl:otherwise>
             <xsl:value-of select="wwunits:CSSRGBColor($VarProperty/@Value)" />
            </xsl:otherwise>
           </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
           <xsl:text></xsl:text>
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>

        <!-- Emit color -->
        <!--            -->
        <xsl:choose>
         <xsl:when test="string-length($VarRGBColor) &gt; 0">
          <wwproject:Property Name="{$VarProperty/@Name}" Value="{$VarRGBColor}" />
         </xsl:when>

         <xsl:otherwise>
          <wwproject:Property Name="{$VarProperty/@Name}" Value="{$VarProperty/@Value}" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Emit white-space-->
       <!--                 -->
       <xsl:when test="$VarProperty/@Name = 'white-space'">
        <xsl:choose>
         <xsl:when test="($VarProperty/@Value = 'pre-line') or ($VarProperty/@Value = 'pre-wrap') or ($VarProperty/@Value = 'initial')">
          <wwproject:Property Name="{$VarProperty/@Name}" Value="pre" />
         </xsl:when>

         <xsl:otherwise>
          <wwproject:Property Name="{$VarProperty/@Name}" Value="{$VarProperty/@Value}" />
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
  </xsl:variable>
  <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

  <xsl:call-template name="FO-AddDefaultProjectProperties">
   <xsl:with-param name="ParamProperties" select="$VarFOProperties" />
   <xsl:with-param name="ParamStyleType" select="$ParamStyleType" />
  </xsl:call-template>
   
 </xsl:template>

 <xsl:template name="FO-ResolveProjectFileURI">
  <xsl:param name="ParamURI" />

  <xsl:choose>
   <xsl:when test="string-length($ParamURI) &gt; 0">
    <!-- Resolve project file -->
    <!--                      -->
    <xsl:variable name="VarAbsoluteURI" select="wwuri:MakeAbsolute('wwprojfile:dummy.component', $ParamURI)" />
    <xsl:choose>
     <!-- Absolute URI -->
     <!--              -->
     <xsl:when test="string-length($VarAbsoluteURI) &gt; 0">
      <xsl:value-of select="wwuri:AsURI(wwuri:AsFilePath($VarAbsoluteURI))" />
     </xsl:when>

     <!-- Use URI as is -->
     <!--               -->
     <xsl:otherwise>
      <xsl:value-of select="$ParamURI" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="''" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

<xsl:template name="FO-AddDefaultProjectProperties">
 <xsl:param name="ParamProperties" />
 <xsl:param name="ParamStyleType" />

 <!-- Add default FO engine Paragraph properties -->
 <!--                                            -->
 <xsl:if test="$ParamStyleType = 'Paragraph'">
  <!-- wrap-option -->
  <!--             -->
  <xsl:if test="count($ParamProperties[@Name = 'wrap-option']) = 0">
   <wwproject:Property Name="wrap-option" Value="wrap" />
  </xsl:if>

  <!-- hyphenate -->
  <!--           -->
  <xsl:if test="count($ParamProperties[@Name = 'hyphenate']) = 0">
   <wwproject:Property Name="hyphenate" Value="false" />
  </xsl:if>
 </xsl:if>

 <!-- Add default FO engine Table properties -->
 <!--                                        -->
 <xsl:if test="$ParamStyleType = 'Table'">
  <!-- Placeholder -->
  <!--             -->
 </xsl:if>

 <!-- Add default FO engine Page properties -->
 <!--                                       -->
 <xsl:if test="$ParamStyleType = 'Page'">
  <!-- implemented in flows-preprocess.xsl, stitch.xsl -->
 </xsl:if>

 <!-- Add default FO engine Graphic properties -->
 <!--                                          -->
 <xsl:if test="$ParamStyleType = 'Graphic'">
  <!-- content-height -->
  <!--               -->
  <xsl:if test="count($ParamProperties[@Name = 'content-height']) = 0">
   <wwproject:Property Name="content-height" Value="scale-down-to-fit" />
  </xsl:if>

  <!-- content-width -->
  <!--               -->
  <xsl:if test="count($ParamProperties[@Name = 'content-width']) = 0">
   <wwproject:Property Name="content-width" Value="scale-down-to-fit" />
  </xsl:if>

  <!-- max-height (before FO-translate: xsl-max-height) -->
  <!--                                                  -->
  <xsl:if test="count($ParamProperties[@Name = 'max-height']) = 0">
   <wwproject:Property Name="max-height" Value="100%" />
  </xsl:if>

  <!-- max-width (before FO-translate: xsl-max-width) -->
  <!--                                                -->
  <xsl:if test="count($ParamProperties[@Name = 'max-width']) = 0">
   <wwproject:Property Name="max-width" Value="100%" />
  </xsl:if>
 </xsl:if>


 <!-- Emit existing FO engine properties -->
 <!--                                    -->
 <xsl:for-each select="$ParamProperties">
  <xsl:variable name="VarProperty" select="." />
   <xsl:copy-of select="$VarProperty" />
 </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
