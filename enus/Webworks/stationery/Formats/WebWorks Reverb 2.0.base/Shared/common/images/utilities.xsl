<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwimages="urn:WebWorks-Images-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwmode wwfiles wwdoc wwbehaviors wwproject wwimages wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:key name="wwimages-types-by-name" match="wwimages:Type" use="@name" />


 <xsl:template name="Images-MaxSizeOption">
  <xsl:param name="ParamMaxSizeOptionValue" />

  <xsl:choose>
   <xsl:when test="$ParamMaxSizeOptionValue = 'none'">
    <xsl:value-of select="0" />
   </xsl:when>

   <xsl:when test="(string-length($ParamMaxSizeOptionValue) &gt; 0) and (number($ParamMaxSizeOptionValue) &gt; 0)">
    <xsl:value-of select="number($ParamMaxSizeOptionValue)" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="0" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-WIFAllowsByReference">
  <xsl:param name="ParamFrame" />

  <!-- WIF structure allows for by reference graphic            -->
  <!--                                                          -->
  <!--  1. By reference facet and no non-marker nested content. -->
  <!--  2. Document only facet with nested content              -->
  <!--     containing only a single frame with a                -->
  <!--     by reference facet and no non-marker nested content. -->
  <!--                                                          -->
  <xsl:variable name="VarPossibleByReferenceFrame">
   <xsl:choose>
    <!-- By reference facet exists -->
    <!--                           -->
    <xsl:when test="count($ParamFrame/wwdoc:Frame/wwdoc:Facets/wwdoc:Facet[@type = 'by-reference']) &gt; 0">
     <!-- Verify frame boundaries -->
     <!--                         -->
     <xsl:call-template name="CheckByReferenceFrameBoundaries">
      <xsl:with-param name="ParamFrame" select="$ParamFrame/wwdoc:Frame" />
      <xsl:with-param name="ParamByReferenceFrame" select="$ParamFrame/wwdoc:Frame[./wwdoc:Facets/wwdoc:Facet/@type = 'by-reference'][1]" />
     </xsl:call-template>

     <xsl:call-template name="CheckByRefContent">
      <xsl:with-param name="ParamContent" select="$ParamFrame/wwdoc:Frame/wwdoc:Content" />
     </xsl:call-template>
    </xsl:when>

    <!-- Nested content exists -->
    <!--                       -->
    <xsl:otherwise>
     <!-- Only 'document' facets exist -->
     <!--                              -->
     <xsl:if test="count($ParamFrame/wwdoc:Frame/wwdoc:Facets/wwdoc:Facet[@type = 'document']) = count($ParamFrame/wwdoc:Frame/wwdoc:Facets/wwdoc:Facet)">
      <!-- Content contains a single frame only -->
      <!--                                      -->
      <xsl:if test="count($ParamFrame/wwdoc:Frame/wwdoc:Content/wwdoc:*) = count($ParamFrame/wwdoc:Frame/wwdoc:Content/wwdoc:Frame)">
       <!-- By reference facet exists -->
       <!--                           -->
       <xsl:if test="count($ParamFrame/wwdoc:Frame/wwdoc:Content/wwdoc:Frame/wwdoc:Facets/wwdoc:Facet[@type = 'by-reference']) = 1">
        <!-- Verify frame boundaries -->
        <!--                         -->
        <xsl:call-template name="CheckByReferenceFrameBoundaries">
         <xsl:with-param name="ParamFrame" select="$ParamFrame/wwdoc:Frame" />
         <xsl:with-param name="ParamByReferenceFrame" select="$ParamFrame/wwdoc:Frame/wwdoc:Content/wwdoc:Frame[./wwdoc:Facets/wwdoc:Facet/@type = 'by-reference'][1]" />
        </xsl:call-template>

        <xsl:for-each select="$ParamFrame/wwdoc:Frame/wwdoc:Content/wwdoc:Frame">
         <xsl:variable name="VarNestedFrame" select="." />

         <xsl:if test="count($VarNestedFrame/wwdoc:Facets/wwdoc:Facet[@type = 'by-reference']) = 0">
          <xsl:call-template name="CheckByRefContent">
           <xsl:with-param name="ParamContent" select="$VarNestedFrame" />
          </xsl:call-template>
         </xsl:if>
        </xsl:for-each>
       </xsl:if>
      </xsl:if>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- By reference? -->
  <!--               -->
  <xsl:value-of select="(string-length($VarPossibleByReferenceFrame) &gt; 0) and not(contains($VarPossibleByReferenceFrame, string(false())))" />
 </xsl:template>


 <xsl:template name="CheckByReferenceFrameBoundaries">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamByReferenceFrame" />

  <!-- Check width -->
  <!--             -->
  <xsl:if test="(string-length($ParamFrame/wwdoc:Attribute[@name = 'width']/@value) &gt; 0) and (number($ParamFrame/wwdoc:Attribute[@name = 'width']/@value) &gt; 0)">
   <xsl:variable name="VarFrameWidth" select="number($ParamFrame/wwdoc:Attribute[@name = 'width']/@value)" />

   <xsl:if test="(string-length($ParamByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value) &gt; 0) and (number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value) &gt; 0)">
    <xsl:variable name="VarByReferenceFrameWidth" select="number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value)" />

    <xsl:choose>
     <xsl:when test="(string-length($ParamByReferenceFrame/wwdoc:Attribute[@name = 'left']/@value) &gt; 0) and (number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'left']/@value) &gt; 0)">
      <xsl:variable name="VarByReferenceFrameLeft" select="number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'left']/@value)" />

      <xsl:value-of select="($VarByReferenceFrameLeft + $VarByReferenceFrameWidth) &lt;= $VarFrameWidth" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarByReferenceFrameWidth &lt;= $VarFrameWidth" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:if>

  <!-- Check height -->
  <!--              -->
  <xsl:if test="(string-length($ParamFrame/wwdoc:Attribute[@name = 'height']/@value) &gt; 0) and (number($ParamFrame/wwdoc:Attribute[@name = 'height']/@value) &gt; 0)">
   <xsl:variable name="VarFrameHeight" select="number($ParamFrame/wwdoc:Attribute[@name = 'height']/@value)" />

   <xsl:if test="(string-length($ParamByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value) &gt; 0) and (number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value) &gt; 0)">
    <xsl:variable name="VarByReferenceFrameHeight" select="number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value)" />

    <xsl:choose>
     <xsl:when test="(string-length($ParamByReferenceFrame/wwdoc:Attribute[@name = 'top']/@value) &gt; 0) and (number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'top']/@value) &gt; 0)">
      <xsl:variable name="VarByReferenceFrameTop" select="number($ParamByReferenceFrame/wwdoc:Attribute[@name = 'top']/@value)" />

      <xsl:value-of select="($VarByReferenceFrameTop + $VarByReferenceFrameHeight) &lt;= $VarFrameHeight" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarByReferenceFrameHeight &lt;= $VarFrameHeight" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="CheckByRefContent">
  <xsl:param name="ParamContent" />

  <!-- Ensure content block is compatible -->
  <!--                                    -->
  <xsl:variable name="VarCheckByRefContent">
   <xsl:apply-templates select="$ParamContent" mode="wwmode:CheckByRefContent" />
  </xsl:variable>

  <xsl:choose>
   <!-- Nested content is compatable -->
   <!--                              -->
   <xsl:when test="string-length($VarCheckByRefContent) = 0">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- Nested content is incompatable -->
   <!--                                -->
   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwdoc:Content | wwdoc:Paragraph" mode="wwmode:CheckByRefContent">
  <xsl:param name="ParamElement" select="." />

  <xsl:choose>
   <!-- First one allowed -->
   <!--                   -->
   <xsl:when test="count($ParamElement/preceding-sibling::wwdoc:*[local-name() = local-name($ParamElement)]) = 0">
    <xsl:apply-templates mode="wwmode:CheckByRefContent" />
   </xsl:when>

   <!-- Not allowed -->
   <!--             -->
   <xsl:otherwise>
    <xsl:text>NA</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwdoc:Frame | wwdoc:TextRun" mode="wwmode:CheckByRefContent">
  <!-- Allowed -->
  <!--         -->
  <xsl:apply-templates mode="wwmode:CheckByRefContent" />
 </xsl:template>


 <xsl:template match="wwdoc:Aliases | wwdoc:Attribute | wwdoc:Description | wwdoc:Marker | wwdoc:Link | wwdoc:Style" mode="wwmode:CheckByRefContent">
  <!-- Allowed -->
  <!--         -->
 </xsl:template>


 <xsl:template match="wwdoc:Facets" mode="wwmode:CheckByRefContent">
  <xsl:param name="ParamFacets" select="." />

  <xsl:if test="count($ParamFacets/wwdoc:Facet[@type != 'document']) &gt; 0">
   <!-- Not allowed -->
   <!--             -->
   <xsl:text>NA</xsl:text>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Number" mode="wwmode:CheckByRefContent">
  <!-- Allowed -->
  <!--         -->
  <xsl:apply-templates mode="wwmode:CheckByRefContent" />
 </xsl:template>


 <xsl:template match="wwdoc:Text[string-length(@value) = 0]" mode="wwmode:CheckByRefContent">
  <!-- Allowed -->
  <!--         -->
 </xsl:template>


 <xsl:template match="wwdoc:*" mode="wwmode:CheckByRefContent">
  <!-- Not allowed -->
  <!--             -->
  <xsl:text>NA</xsl:text>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:CheckByRefContent">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <xsl:template name="Images-ByReferenceSourcePath">
  <xsl:param name="ParamFrame" />

  <xsl:variable name="VarByReferenceFacets"  select="$ParamFrame/wwdoc:Frame//wwdoc:Facet[@type = 'by-reference']" />
  <xsl:choose>
   <xsl:when test="count($VarByReferenceFacets[1]) &gt; 0">
    <xsl:variable name="VarByReferenceFacet" select="$VarByReferenceFacets[1]" />

    <xsl:value-of select="$VarByReferenceFacet/wwdoc:Attribute[@name = 'path']/@value" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="''" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-ImageScaleMarkerValue">
  <xsl:param name="ParamFrameBehavior" />

   <!-- Get image-scale marker -->
   <!--                        -->
   <xsl:variable name="VarImageScaleBehaviorMarkers" select="$ParamFrameBehavior//wwbehaviors:Marker[@behavior = 'image-scale']" />
   <xsl:if test="count($VarImageScaleBehaviorMarkers) &gt; 0">
    <xsl:variable name="VarImageScaleMarkerValue">
     <!-- Use last one defined -->
     <!--                      -->
     <xsl:for-each select="$VarImageScaleBehaviorMarkers[count($VarImageScaleBehaviorMarkers)]">
      <xsl:variable name="VarImageScaleBehaviorMarker" select="." />
  
      <xsl:for-each select="$VarImageScaleBehaviorMarker/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:for-each>
    </xsl:variable>
  
    <xsl:if test="(string-length($VarImageScaleMarkerValue) &gt; 0) and (number($VarImageScaleMarkerValue) &gt; 0)">
     <xsl:value-of select="number($VarImageScaleMarkerValue)" />
    </xsl:if>
   </xsl:if>
 </xsl:template>


 <xsl:template name="Images-VectorImageFormat">
  <xsl:param name="ParamImageInfo" />

  <xsl:choose>
   <xsl:when test="$ParamImageInfo/@format = 'svg'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="string-length($ParamImageInfo/@format) = 0">
    <xsl:value-of select="false()" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-RasterImageFormat">
  <xsl:param name="ParamImageInfo" />

  <xsl:choose>
   <xsl:when test="$ParamImageInfo/@format = 'bmp'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="$ParamImageInfo/@format = 'gif'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="$ParamImageInfo/@format = 'jpeg'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="$ParamImageInfo/@format = 'png'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="$ParamImageInfo/@format = 'tiff'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <xsl:when test="string-length($ParamImageInfo/@format) = 0">
    <xsl:value-of select="false()" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-ByRefImageRequiresScaling">
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamFrameBehavior" />
  <xsl:param name="ParamImageInfo" />

  <!-- Image requires scaling when:                                                  -->
  <!--                                                                               -->
  <!--  1. Image scale marker found with value other than 100%                       -->
  <!--  2. Rule defines scaling value and this value is not 100%                     -->
  <!--  3. Raster image width/height exceeds max width/height limits defined by rule -->
  <!--                                                                               -->

  <!-- Access image scale marker -->
  <!--                           -->
  <xsl:variable name="VarImageScale">
   <xsl:call-template name="Images-ImageScaleMarkerValue">
    <xsl:with-param name="ParamFrameBehavior" select="$ParamFrameBehavior" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <!-- Scaled! -->
   <!--         -->
   <xsl:when test="(string-length($VarImageScale) > 0) and (number($VarImageScale) != (100))">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- May be scaled -->
   <!--               -->
   <xsl:otherwise>
    <!-- Access scale option from rule -->
    <!--                               -->
    <xsl:variable name="VarScaleOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />

    <xsl:choose>
     <!-- Scaled! -->
     <!--         -->
     <xsl:when test="(string-length($VarScaleOption) &gt; 0) and ($VarScaleOption != 'none') and (number($VarScaleOption) != 100)">
      <xsl:value-of select="true()" />
     </xsl:when>

     <!-- May be scaled -->
     <!--               -->
     <xsl:otherwise>
      <!-- Scaling due to size limits? -->
      <!--                             -->
      <xsl:variable name="VarMaxWidthOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
      <xsl:variable name="VarMaxHeightOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />

      <xsl:choose>
       <!-- Size limits defined -->
       <!--                     -->
       <xsl:when test="(string-length($VarMaxWidthOption) &gt; 0) and (string-length($VarMaxHeightOption) &gt; 0) and ($VarMaxWidthOption != 'none') and ($VarMaxHeightOption != 'none') and ((number($VarMaxWidthOption) &gt; 0) and (number($VarMaxHeightOption) &gt; 0))">
        <!-- Raster image format? -->
        <!--                      -->
        <xsl:variable name="VarRasterImageFormatAsText">
         <xsl:call-template name="Images-RasterImageFormat">
          <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarRasterImageFormat" select="$VarRasterImageFormatAsText = string(true())" />

        <xsl:choose>
         <xsl:when test="$VarRasterImageFormat">
          <!-- Determine image width/height -->
          <!--                              -->
          <xsl:variable name="VarWidth" select="number($ParamImageInfo/@width)" />
          <xsl:variable name="VarHeight" select="number($ParamImageInfo/@height)" />

          <xsl:choose>
           <!-- Scaled! -->
           <!--         -->
           <xsl:when test="($VarWidth &gt; number($VarMaxWidthOption)) and ($VarHeight &gt; number($VarMaxHeightOption))">
            <xsl:value-of select="true()" />
           </xsl:when>
    
           <!-- Not scaled -->
           <!--            -->
           <xsl:otherwise>
            <xsl:value-of select="false()" />
           </xsl:otherwise>
          </xsl:choose>
         </xsl:when>

         <!-- Vector image format, assume scaling is required -->
         <!--                                                 -->
         <xsl:otherwise>
          <xsl:value-of select="true()" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Not scaled -->
       <!--            -->
       <xsl:otherwise>
        <xsl:value-of select="false()" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Images-AllowByReference">
  <xsl:param name="ParamAllowedByReferenceTypes" />
  <xsl:param name="ParamByReferenceSourcePath" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamFrameBehavior" />

  <!-- By reference frame requires:                                 -->
  <!--                                                              -->
  <!--  1. Graphic rule allows by-ref                               -->
  <!--  2. Image one of:                                            -->
  <!--     a. Unscaled, output supports SVG and SVG by-ref enabled  -->
  <!--     b. Unscaled, output supports source raster image format  -->
  <!--                                                              -->

  <!-- Rule allows by reference? -->
  <!--                           -->
  <xsl:variable name="VarAllowByReferenceGraphicsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-graphics']/@Value" />
  <xsl:variable name="VarAllowByReferenceGraphics" select="(string-length($VarAllowByReferenceGraphicsOption) = 0) or ($VarAllowByReferenceGraphicsOption = 'true')" />
  <xsl:if test="$VarAllowByReferenceGraphics">
   <!-- Access image info -->
   <!--                   -->
   <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($ParamByReferenceSourcePath)" />

   <!-- Scaling required? -->
   <!--                   -->
   <xsl:variable name="VarScalingRequiredAsText">
    <xsl:call-template name="Images-ByRefImageRequiresScaling">
     <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     <xsl:with-param name="ParamFrameBehavior" select="$ParamFrameBehavior" />
     <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarScalingRequired" select="$VarScalingRequiredAsText = string(true())" />

   <xsl:choose>
    <!-- Scaling required -->
    <!--                  -->
    <xsl:when test="$VarScalingRequired">
     <xsl:value-of select="false()" />
    </xsl:when>

    <!-- No scaling required -->
    <!--                     -->
    <xsl:otherwise>
     <!-- Allow by reference vector images? -->
     <!--                                   -->
     <xsl:variable name="VarByReferenceVectorOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-vector']/@Value" />
     <xsl:variable name="VarByReferenceVector" select="$VarByReferenceVectorOption = 'true'" />
     <xsl:choose>
      <!-- SVG by-ref image found and allowed -->
      <!--                                    -->
      <xsl:when test="($VarByReferenceVector) and ($VarImageInfo/@format = 'svg')">
       <!-- Check for thumbnail size restrictions -->
       <!--                                       -->
       <xsl:variable name="VarThumbnailWidthOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'thumbnail-width']/@Value" />
       <xsl:variable name="VarThumbnailHeightOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'thumbnail-height']/@Value" />
       <xsl:choose>
        <!-- Thumbnail width/height defined -->
        <!--                                -->
        <xsl:when test="(string-length($VarThumbnailWidthOption) &gt; 0) and (string-length($VarThumbnailHeightOption) &gt; 0) and ($VarThumbnailWidthOption != 'none') and ($VarThumbnailHeightOption != 'none') and ((number($VarThumbnailWidthOption) &gt; 0) and (number($VarThumbnailHeightOption) &gt; 0))">
         <xsl:value-of select="false()" />
        </xsl:when>

        <!-- By-reference image allowed -->
        <!--                            -->
        <xsl:otherwise>
         <xsl:value-of select="true()" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <!-- Non-SVG image -->
      <!--               -->
      <xsl:otherwise>
       <!-- Allowed image format? -->
       <!--                       -->
       <xsl:variable name="VarImageFormatSearchResult">
        <xsl:for-each select="$ParamAllowedByReferenceTypes[1]">
         <xsl:for-each select="key('wwimages-types-by-name', $VarImageInfo/@format)[1]">
          <xsl:value-of select="$VarImageInfo/@format" />
         </xsl:for-each>
        </xsl:for-each>
       </xsl:variable>
       <xsl:variable name="VarAllowedImageFormat" select="string-length($VarImageFormatSearchResult) &gt; 0" />

       <xsl:choose>
        <!-- Allowed image format -->
        <!--                      -->
        <xsl:when test="$VarAllowedImageFormat">
         <xsl:value-of select="true()" />
        </xsl:when>

        <!-- Unsupported image format -->
        <!--                          -->
        <xsl:otherwise>
         <xsl:value-of select="false()" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
