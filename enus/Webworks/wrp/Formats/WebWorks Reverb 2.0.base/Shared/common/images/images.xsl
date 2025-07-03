<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwtrait="urn:WebWorks-Engine-FormatTraitInfo-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwadapter="urn:WebWorks-XSLT-Extension-Adapter"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwimageinfo="urn:WebWorks-Imaging-Info"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwstageinfo="urn:WebWorks-XSLT-Extension-StageInfo"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwbehaviors wwsplits wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwunits wwprojext wwadapter wwimaging wwimageinfo wwexsldoc wwstageinfo"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterPostScriptType" />
 <xsl:param name="ParameterDefaultFormat" />
 <xsl:param name="ParameterAllowThumbnails" />
 <xsl:param name="ParameterThumbnailType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:include href="wwtransform:common/images/utilities.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwdoc-frames-by-id" match="wwdoc:Frame" use="@id" />
 <xsl:key name="wwbehaviors-frames-by-id" match="wwbehaviors:Frame" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/utilities.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Configure stage info -->
   <!--                      -->
   <xsl:if test="string-length(wwstageinfo:Get('group-position')) = 0">
    <xsl:variable name="VarInitGroupPosition" select="wwstageinfo:Set('group-position', '0')" />
    <xsl:variable name="VarInitDocumentPosition" select="wwstageinfo:Set('document-position', '0')" />
    <xsl:variable name="VarInitSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
    <xsl:variable name="VarInitSplitFramePosition" select="wwstageinfo:Set('split-frame-position', '0')" />
   </xsl:if>

   <!-- Determine restart position -->
   <!--                            -->
   <xsl:variable name="VarLastGroupPosition" select="number(wwstageinfo:Get('group-position'))" />

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />
    <xsl:variable name="VarGroupPosition" select="position()" />

    <!-- Splits -->
    <!--        -->
    <xsl:variable name="VarProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Handle restart -->
    <!--                -->
    <xsl:if test="$VarGroupPosition &gt; $VarLastGroupPosition">
     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Determine restart position -->
      <!--                            -->
      <xsl:variable name="VarLastDocumentPosition" select="number(wwstageinfo:Get('document-position'))" />

      <xsl:for-each select="$GlobalInput[1]">
       <!-- Load splits -->
       <!--             -->
       <xsl:variable name="VarSplitsFiles" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
       <xsl:for-each select="$VarSplitsFiles[1]">
        <xsl:variable name="VarSplitsFile" select="." />

        <!-- Load splits -->
        <!--             -->
        <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />

        <!-- Documents -->
        <!--           -->
        <xsl:variable name="VarDocumentFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />
        <xsl:variable name="VarDocumentFilesStart" select="wwprogress:Start(count($VarDocumentFiles))" />
        <xsl:for-each select="$VarDocumentFiles">
         <xsl:variable name="VarDocumentFile" select="." />
         <xsl:variable name="VarDocumentPosition" select="position()" />

         <xsl:variable name="VarDocumentFileStart" select="wwprogress:Start(1)" />

         <!-- Handle restart -->
         <!--                -->
         <xsl:if test="$VarDocumentPosition &gt; $VarLastDocumentPosition">
          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <!-- Document has frames? -->
           <!--                      -->
           <xsl:for-each select="($VarSplits//wwsplits:Frame[@documentID = $VarDocumentFile/@documentID])[1]">
            <!-- Load document -->
            <!--               -->
            <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarDocumentFile/@path, false())" />

            <xsl:for-each select="$GlobalFiles[1]">
             <!-- Load behaviors -->
             <!--                -->
             <xsl:variable name="VarBehaviorsFiles" select="key('wwfiles-files-by-documentid', $VarDocumentFile/@documentID)[@type = $ParameterBehaviorsType]" />
             <xsl:for-each select="$VarBehaviorsFiles[1]">
              <xsl:variable name="VarBehaviorsFile" select="." />
              <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

              <!-- Document Frames -->
              <!--                 -->
              <xsl:apply-templates select="$VarSplits" mode="wwmode:split-frames">
               <xsl:with-param name="ParamDocumentFile" select="$VarDocumentFile" />
               <xsl:with-param name="ParamBehaviorsFile" select="$VarBehaviorsFile" />
               <xsl:with-param name="ParamDocument" select="$VarDocument" />
               <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
              </xsl:apply-templates>
             </xsl:for-each>
            </xsl:for-each>
           </xsl:for-each>
          </xsl:if>

          <!-- Update stage info -->
          <!--                   -->
          <xsl:if test="not(wwprogress:Abort())">
           <xsl:variable name="VarUpdateDocumentPosition" select="wwstageinfo:Set('document-position', string($VarDocumentPosition))" />
           <xsl:variable name="VarResetSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
           <xsl:variable name="VarResetSplitFramePosition" select="wwstageinfo:Set('split-frame-position', '0')" />
          </xsl:if>
         </xsl:if>

         <xsl:variable name="VarDocumentFileEnd" select="wwprogress:End()" />

        </xsl:for-each>
        <xsl:variable name="VarDocumentFilesEnd" select="wwprogress:End()" />
       </xsl:for-each>
      </xsl:for-each>
     </xsl:if>

     <!-- Update stage info -->
     <!--                   -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarUpdateGroupPosition" select="wwstageinfo:Set('group-position', string($VarGroupPosition))" />
      <xsl:variable name="VarResetDocumentPosition" select="wwstageinfo:Set('document-position', '0')" />
      <xsl:variable name="VarResetSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
      <xsl:variable name="VarResetSplitFramePosition" select="wwstageinfo:Set('split-frame-position', '0')" />
     </xsl:if>
    </xsl:if>

    <xsl:variable name="VarProjectGroupEnd" select="wwprogress:End()" />

   </xsl:for-each>
   <xsl:variable name="VarProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:split-frames -->
 <!--                     -->

 <xsl:template match="/" mode="wwmode:split-frames">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:split-frames">
    <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
    <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:split-frames">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:apply-templates mode="wwmode:split-frames">
   <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
   <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwsplits:Split" mode="wwmode:split-frames">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamSplit" select="." />

  <!-- Split in current document? -->
  <!--                            -->
  <xsl:if test="$ParamSplit/@documentID = $ParamDocumentFile/@documentID">
   <!-- Determine restart position -->
   <!--                            -->
   <xsl:variable name="VarLastSplitPosition" select="number(wwstageinfo:Get('split-position'))" />
   <xsl:variable name="VarSplitPosition" select="number($ParamSplit/@position)" />
   <xsl:if test="$VarSplitPosition &gt; $VarLastSplitPosition">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:apply-templates mode="wwmode:split-frames">
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     </xsl:apply-templates>
    </xsl:if>
   </xsl:if>

   <!-- Update stage info -->
   <!--                   -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:variable name="VarUpdateSplitPosition" select="wwstageinfo:Set('split-position', string($VarSplitPosition))" />
    <xsl:variable name="VarResetSplitFramePosition" select="wwstageinfo:Set('split-frame-position', '0')" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwsplits:Frame" mode="wwmode:split-frames">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamSplitFrame" select="." />

  <!-- Frame in current document? -->
  <!--                            -->
  <xsl:if test="$ParamSplitFrame/@documentID = $ParamDocumentFile/@documentID">
   <!-- Determine restart position -->
   <!--                            -->
   <xsl:variable name="VarLastSplitFramePosition" select="number(wwstageinfo:Get('split-frame-position'))" />
   <xsl:variable name="VarSplitFramePosition" select="number($ParamSplitFrame/@position)" />
   <xsl:if test="$VarSplitFramePosition &gt; $VarLastSplitFramePosition">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Graphic Rule -->
     <!--              -->
     <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamSplitFrame/@stylename, $ParamSplitFrame/@documentID, $ParamSplitFrame/@id)" />
     <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
     <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
     <xsl:if test="$VarGenerateOutput">
      <!-- Locate document frame -->
      <!--                       -->
      <xsl:for-each select="$ParamDocument[1]">
       <xsl:variable name="VarDocumentFrame" select="key('wwdoc-frames-by-id', $ParamSplitFrame/@id)[1]" />

       <!-- Locate behaviors frame -->
       <!--                        -->
       <xsl:for-each select="$ParamBehaviors[1]">
        <xsl:variable name="VarBehaviorsFrame" select="key('wwbehaviors-frames-by-id', $ParamSplitFrame/@id)[1]" />

        <!-- Full size -->
        <!--           -->
        <xsl:call-template name="FullSize">
         <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
         <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
         <xsl:with-param name="ParamDocumentFrame" select="$VarDocumentFrame" />
         <xsl:with-param name="ParamBehaviorsFrame" select="$VarBehaviorsFrame" />
         <xsl:with-param name="ParamSplitFrame" select="$ParamSplitFrame" />
         <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
        </xsl:call-template>

        <!-- Thumbnail -->
        <!--           -->
        <xsl:if test="$ParameterAllowThumbnails = 'true'">
         <xsl:call-template name="Thumbnail">
          <xsl:with-param name="ParamDocumentFrame" select="$VarDocumentFrame" />
          <xsl:with-param name="ParamBehaviorsFrame" select="$VarBehaviorsFrame" />
          <xsl:with-param name="ParamSplitFrame" select="$ParamSplitFrame" />
          <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
         </xsl:call-template>
        </xsl:if>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:if>
    </xsl:if>
   </xsl:if>

   <!-- Update stage info -->
   <!--                   -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:variable name="VarUpdateSplitFramePosition" select="wwstageinfo:Set('split-frame-position', string($VarSplitFramePosition))" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:split-frames">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template name="FullSize">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocumentFrame" />
  <xsl:param name="ParamBehaviorsFrame" />
  <xsl:param name="ParamSplitFrame" />
  <xsl:param name="ParamContextRule" />

  <!-- Skip by reference graphics -->
  <!--                            -->
  <xsl:variable name="VarByReference" select="$ParamSplitFrame/@byref = string(true())" />
  <xsl:if test="not($VarByReference)">
   <!-- Translation from source image possible? -->
   <!--                                         -->
   <xsl:variable name="VarTranslateAsText">
    <!-- Rule allows by reference? -->
    <!--                           -->
    <xsl:variable name="VarAllowByReferenceGraphicsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-graphics']/@Value" />
    <xsl:variable name="VarAllowByReferenceGraphics" select="(string-length($VarAllowByReferenceGraphicsOption) = 0) or ($VarAllowByReferenceGraphicsOption = 'true')" />
    <xsl:if test="$VarAllowByReferenceGraphics">
     <!-- Qualify based on upstream processing -->
     <!--                                      -->
     <xsl:if test="($ParamSplitFrame/@byref-allowed-by-wif = string(true())) and (wwfilesystem:FileExists($ParamSplitFrame/@source))">
      <!-- Raster image format? -->
      <!--                      -->
      <xsl:variable name="VarRasterImageFormatAsText">
       <!-- Access source image info -->
       <!--                          -->
       <xsl:variable name="VarSourceImageInfo" select="wwimaging:GetInfo($ParamSplitFrame/@source)" />
       <xsl:call-template name="Images-RasterImageFormat">
        <xsl:with-param name="ParamImageInfo" select="$VarSourceImageInfo" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarRasterImageFormat" select="$VarRasterImageFormatAsText = string(true())" />

      <!-- Allow if raster image format -->
      <!--                              -->
      <xsl:value-of select="$VarRasterImageFormat" />
     </xsl:if>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarTranslate" select="$VarTranslateAsText = string(true())" />

   <xsl:choose>
    <!-- Translate from origional source file -->
    <!--                                      -->
    <xsl:when test="$VarTranslate">
     <xsl:call-template name="FullSize-Translate">
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
      <xsl:with-param name="ParamDocumentFrame" select="$ParamDocumentFrame" />
      <xsl:with-param name="ParamBehaviorsFrame" select="$ParamBehaviorsFrame" />
      <xsl:with-param name="ParamSplitFrame" select="$ParamSplitFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     </xsl:call-template>
    </xsl:when>

    <!-- Render via PostScript -->
    <!--                       -->
    <xsl:when test="count($ParamDocumentFrame/wwdoc:Facets[1]/wwdoc:Facet[@type = 'document'][1]) = 1">
     <xsl:call-template name="FullSize-PostScript">
      <xsl:with-param name="ParamDocumentFile" select="$ParamDocumentFile" />
      <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
      <xsl:with-param name="ParamDocumentFrame" select="$ParamDocumentFrame" />
      <xsl:with-param name="ParamBehaviorsFrame" select="$ParamBehaviorsFrame" />
      <xsl:with-param name="ParamSplitFrame" select="$ParamSplitFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     </xsl:call-template>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="FullSize-Translate">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocumentFrame" />
  <xsl:param name="ParamBehaviorsFrame" />
  <xsl:param name="ParamSplitFrame" />
  <xsl:param name="ParamContextRule" />

  <!-- Get image-scale marker -->
  <!--                        -->
  <xsl:variable name="VarImageScale">
   <xsl:call-template name="Images-ImageScaleMarkerValue">
    <xsl:with-param name="ParamFrameBehavior" select="$ParamBehaviorsFrame" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Get graphic options -->
  <!--                     -->
  <xsl:variable name="VarScaleOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
  <xsl:variable name="VarMaxWidthOption">
   <xsl:call-template name="Images-MaxSizeOption">
    <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarMaxHeightOption">
   <xsl:call-template name="Images-MaxSizeOption">
    <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Generate image -->
  <!--                -->
  <xsl:variable name="VarImageUpToDate" select="wwfilesext:UpToDate($ParamSplitFrame/@path, concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarImageScale, ':', $VarScaleOption, ':', $VarMaxWidthOption, ':', $VarMaxHeightOption), $ParamSplitFrame/@groupID, $ParamSplitFrame/@documentID, $GlobalActionChecksum)" />
  <xsl:if test="not($VarImageUpToDate)">
   <!-- Load image info -->
   <!--                 -->
   <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($ParamSplitFrame/@source)" />

   <!-- Define initial width/height -->
   <!--                             -->
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />

   <!-- Render DPI -->
   <!--            -->
   <xsl:variable name="VarRenderDPI">
    <xsl:variable name="VarRenderDPIOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'render-dpi']/@Value" />
    <xsl:choose>
     <xsl:when test="string-length($VarRenderDPIOption) &gt; 0">
      <xsl:value-of select="$VarRenderDPIOption" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="96" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:variable name="VarInitialWidth">
    <xsl:choose>
     <xsl:when test="($VarByReferenceGraphicsUseDocumentDimensions) or ($VarImageInfo/@width = 0)">
      <xsl:variable name="VarDocumentFrameWidth" select="wwunits:NumericPrefix($ParamDocumentFrame/wwdoc:Attribute[@name = 'width']/@value)" />

      <xsl:value-of select="wwunits:Convert($VarDocumentFrameWidth, 'points', 'inches') * $VarRenderDPI" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarImageInfo/@width" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarInitialHeight">
    <xsl:choose>
     <xsl:when test="($VarByReferenceGraphicsUseDocumentDimensions) or ($VarImageInfo/@height = 0)">
      <xsl:variable name="VarDocumentFrameHeight" select="wwunits:NumericPrefix($ParamDocumentFrame/wwdoc:Attribute[@name = 'height']/@value)" />

      <xsl:value-of select="wwunits:Convert($VarDocumentFrameHeight, 'points', 'inches') * $VarRenderDPI" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarImageInfo/@height" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Determine up scaling factor -->
   <!--                             -->
   <xsl:variable name="VarUpScalingFactor">
    <xsl:choose>
     <!-- Use image-scale markers if defined -->
     <!--                                    -->
     <xsl:when test="string-length($VarImageScale) &gt; 0">
      <xsl:value-of select="$VarImageScale div 100.0" />
     </xsl:when>

     <!-- Scale -->
     <!--       -->
     <xsl:when test="(string-length($VarScaleOption) &gt; 0) and ($VarScaleOption != 'none') and (number($VarScaleOption) &gt; 0)">
      <xsl:value-of select="$VarScaleOption div 100.0" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="1.0" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Determine scaled width/height -->
   <!--                               -->
   <xsl:variable name="VarScaledWidth">
    <xsl:value-of select="$VarInitialWidth * $VarUpScalingFactor" />
   </xsl:variable>
   <xsl:variable name="VarScaledHeight">
    <xsl:value-of select="$VarInitialHeight * $VarUpScalingFactor" />
   </xsl:variable>

   <!-- Determine down scaling factor -->
   <!--                               -->
   <xsl:variable name="VarDownScalingFactor">
    <xsl:choose>
     <!-- Max Width/Height -->
     <!--                  -->
     <xsl:when test="($VarMaxWidthOption &gt; 0) or ($VarMaxHeightOption &gt; 0)">
      <!-- Determine scaling ratio -->
      <!--                         -->
      <xsl:variable name="VarWidthRatio" select="$VarMaxWidthOption div $VarScaledWidth" />
      <xsl:variable name="VarHeightRatio" select="$VarMaxHeightOption div $VarScaledHeight" />
      <xsl:choose>
       <xsl:when test="($VarWidthRatio &lt; 1.0) and ((($VarWidthRatio &gt; 0) and ($VarWidthRatio &lt; $VarHeightRatio)) or ($VarHeightRatio = 0))">
        <xsl:value-of select="$VarWidthRatio" />
       </xsl:when>

       <xsl:when test="$VarHeightRatio &lt; 1.0">
        <xsl:value-of select="$VarHeightRatio" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="1.0" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="1.0" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Determine target width/height -->
   <!--                               -->
   <xsl:variable name="VarTargetWidth">
    <xsl:value-of select="ceiling($VarDownScalingFactor * $VarScaledWidth)" />
   </xsl:variable>
   <xsl:variable name="VarTargetHeight">
    <xsl:value-of select="ceiling($VarDownScalingFactor * $VarScaledHeight)" />
   </xsl:variable>

   <!-- Format -->
   <!--        -->
   <xsl:variable name="VarFormat">
    <xsl:variable name="VarFormatOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'format']/@Value" />
    <xsl:choose>
     <xsl:when test="string-length($VarFormatOption) &gt; 0">
      <xsl:value-of select="$VarFormatOption" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$ParameterDefaultFormat" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Quality (for JPEGs) -->
   <!--                     -->
   <xsl:variable name="VarQuality">
    <xsl:variable name="VarQualityOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'quality']/@Value" />

    <xsl:choose>
     <xsl:when test="number($VarQualityOption) &gt; 0">
      <xsl:value-of select="$VarQualityOption" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="75" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Transform -->
   <!--           -->
   <xsl:variable name="VarTransform" select="wwimaging:Transform($ParamSplitFrame/@source, $VarFormat, $VarQuality, $VarTargetWidth, $VarTargetHeight, $ParamSplitFrame/@path, $VarRenderDPI)" />
  </xsl:if>

  <!-- Dependency info -->
  <!--                 -->
  <wwfiles:File path="{$ParamSplitFrame/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplitFrame/@path)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarImageScale, ':', $VarScaleOption, ':', $VarMaxWidthOption, ':', $VarMaxHeightOption)}" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
   <wwfiles:Depends path="{$ParamSplitFrame/@source}" checksum="{wwfilesystem:GetChecksum($ParamSplitFrame/@source)}" groupID="" documentID="" />
   <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
  </wwfiles:File>
 </xsl:template>


 <xsl:template name="FullSize-PostScript">
  <xsl:param name="ParamDocumentFile" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamDocumentFrame" />
  <xsl:param name="ParamBehaviorsFrame" />
  <xsl:param name="ParamSplitFrame" />
  <xsl:param name="ParamContextRule" />

  <!-- Generate PostScript -->
  <!--                     -->
  <xsl:variable name="VarPostScriptPath" select="wwfilesystem:Combine(wwprojext:GetDocumentDataDirectoryPath($ParamSplitFrame/@documentID), concat(translate($ParameterType, ':', '_'), '_', $ParamSplitFrame/@id, '.ps'))" />
  <xsl:variable name="VarPostScriptUpToDate" select="wwfilesext:UpToDate($VarPostScriptPath, '', $ParamSplitFrame/@groupID, $ParamSplitFrame/@documentID, $GlobalActionChecksum)" />
  <xsl:if test="not($VarPostScriptUpToDate)">
   <xsl:variable name="VarIgnoreResult" select="wwadapter:GeneratePostScriptForImage($ParamDocumentFrame, $VarPostScriptPath)" />
  </xsl:if>

  <!-- Dependency info -->
  <!--                 -->
  <xsl:variable name="VarPostScriptChecksum" select="wwfilesystem:GetChecksum($VarPostScriptPath)" />
  <wwfiles:File path="{$VarPostScriptPath}" type="$ParameterPostScriptType" checksum="{$VarPostScriptChecksum}" projectchecksum="" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" actionchecksum="{$GlobalActionChecksum}">
   <wwfiles:Depends path="{$ParamDocumentFile/@path}" checksum="{$ParamDocumentFile/@checksum}" groupID="{$ParamDocumentFile/@groupID}" documentID="{$ParamDocumentFile/@documentID}" />
  </wwfiles:File>

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <!-- Get image-scale marker -->
   <!--                        -->
   <xsl:variable name="VarImageScale">
    <xsl:call-template name="Images-ImageScaleMarkerValue">
     <xsl:with-param name="ParamFrameBehavior" select="$ParamBehaviorsFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Get graphic options -->
   <!--                     -->
   <xsl:variable name="VarScaleOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
   <xsl:variable name="VarMaxWidthOption">
    <xsl:call-template name="Images-MaxSizeOption">
     <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarMaxHeightOption">
    <xsl:call-template name="Images-MaxSizeOption">
     <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Generate image -->
   <!--                -->
   <xsl:variable name="VarImageUpToDate" select="wwfilesext:UpToDate($ParamSplitFrame/@path, concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarImageScale, ':', $VarScaleOption, ':', $VarMaxWidthOption, ':', $VarMaxHeightOption), $ParamSplitFrame/@groupID, $ParamSplitFrame/@documentID, $GlobalActionChecksum)" />
   <xsl:if test="not($VarPostScriptUpToDate) or not($VarImageUpToDate)">
    <!-- Rasterize -->
    <!--           -->
    <xsl:variable name="VarDocumentFrameWidth" select="wwunits:NumericPrefix($ParamDocumentFrame/wwdoc:Attribute[@name = 'width']/@value)" />
    <xsl:variable name="VarDocumentFrameHeight" select="wwunits:NumericPrefix($ParamDocumentFrame/wwdoc:Attribute[@name = 'height']/@value)" />
    <xsl:if test="($VarDocumentFrameWidth &gt; 0) and ($VarDocumentFrameHeight &gt; 0)">
     <!-- Render DPI -->
     <!--            -->
     <xsl:variable name="VarRenderDPI">
      <xsl:variable name="VarRenderDPIOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'render-dpi']/@Value" />
      <xsl:choose>
       <xsl:when test="string-length($VarRenderDPIOption) &gt; 0">
        <xsl:value-of select="$VarRenderDPIOption" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="96" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Width/Height -->
     <!--              -->
     <xsl:variable name="VarWidth" select="wwunits:Convert($VarDocumentFrameWidth, 'points', 'inches') * $VarRenderDPI" />
     <xsl:variable name="VarHeight" select="wwunits:Convert($VarDocumentFrameHeight, 'points', 'inches') * $VarRenderDPI" />

     <!-- Format -->
     <!--        -->
     <xsl:variable name="VarFormat">
      <xsl:variable name="VarFormatOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'format']/@Value" />
      <xsl:choose>
       <xsl:when test="string-length($VarFormatOption) &gt; 0">
        <xsl:value-of select="$VarFormatOption" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$ParameterDefaultFormat" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Color Depth -->
     <!--             -->
     <xsl:variable name="VarColorDepth">
      <xsl:variable name="VarColorDepthOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'color-depth']/@Value" />
      <xsl:choose>
       <xsl:when test="number($VarColorDepthOption) &gt; 0">
        <xsl:value-of select="$VarColorDepthOption" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="256" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Grayscale -->
     <!--           -->
     <xsl:variable name="VarGrayscaleOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'grayscale']/@Value" />
     <xsl:variable name="VarGrayscale" select="$VarGrayscaleOption = 'true'" />

     <!-- Transparent -->
     <!--             -->
     <xsl:variable name="VarTransparentOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'transparent']/@Value" />
     <xsl:variable name="VarTransparent" select="$VarTransparentOption = 'true'" />

     <!-- Interlaced (for GIFs) -->
     <!--                       -->
     <xsl:variable name="VarInterlacedOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'interlaced']/@Value" />
     <xsl:variable name="VarInterlaced" select="$VarInterlacedOption = 'true'" />

     <!-- Quality (for JPEGs) -->
     <!--                     -->
     <xsl:variable name="VarQuality">
      <xsl:variable name="VarQualityOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'quality']/@Value" />

      <xsl:choose>
       <xsl:when test="number($VarQualityOption) &gt; 0">
        <xsl:value-of select="$VarQualityOption" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="75" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Determine scaling ratio -->
     <!--                         -->
     <xsl:variable name="VarUpScalingRatio">
      <xsl:choose>
       <!-- Use image-scale markers if defined -->
       <!--                                    -->
       <xsl:when test="string-length($VarImageScale) &gt; 0">
        <xsl:value-of select="$VarImageScale div 100.0" />
       </xsl:when>

       <!-- Scale -->
       <!--       -->
       <xsl:when test="(string-length($VarScaleOption) &gt; 0) and ($VarScaleOption != 'none') and (number($VarScaleOption) &gt; 0)">
        <xsl:value-of select="$VarScaleOption div 100.0" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="1.0" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Record upscaling parameters -->
     <!--                             -->
     <xsl:variable name="VarScaledRenderDPI">
      <xsl:choose>
       <xsl:when test="$VarUpScalingRatio &gt; 1.0">
        <xsl:value-of select="round($VarRenderDPI * $VarUpScalingRatio)" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$VarRenderDPI" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>
     <xsl:variable name="VarScaledWidth">
      <xsl:choose>
       <xsl:when test="$VarUpScalingRatio &gt; 1.0">
        <xsl:value-of select="ceiling($VarWidth * $VarUpScalingRatio)" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="ceiling($VarWidth)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>
     <xsl:variable name="VarScaledHeight">
      <xsl:choose>
       <xsl:when test="$VarUpScalingRatio &gt; 1.0">
        <xsl:value-of select="ceiling($VarHeight * $VarUpScalingRatio)" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="ceiling($VarHeight)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Rasterize PostScript -->
     <!--                      -->
     <xsl:variable name="VarImageInfo" select="wwimaging:RasterizePostScript($VarPostScriptPath, $VarScaledRenderDPI, $VarScaledRenderDPI, $VarScaledWidth, $VarScaledHeight, $VarFormat, $VarColorDepth, $VarGrayscale, $VarTransparent, $VarInterlaced, $VarQuality, $ParamSplitFrame/@path)" />
     <xsl:if test="(number($VarImageInfo/@width) &gt; 0) and (number($VarImageInfo/@height) &gt; 0)">
      <!-- Determine downscaling ratio -->
      <!--                             -->
      <xsl:variable name="VarDownScalingRatio">
       <xsl:choose>
        <!-- Use image-scale markers if defined -->
        <!--                                    -->
        <xsl:when test="string-length($VarImageScale) &gt; 0">
         <xsl:value-of select="$VarImageScale div 100.0" />
        </xsl:when>

        <!-- Use graphic options -->
        <!--                     -->
        <xsl:otherwise>
         <xsl:choose>
          <!-- Max Width/Height -->
          <!--                  -->
          <xsl:when test="($VarMaxWidthOption &gt; 0) or ($VarMaxHeightOption &gt; 0)">
           <!-- Determine scaling ratio -->
           <!--                         -->
           <xsl:variable name="VarWidthRatio" select="$VarMaxWidthOption div $VarImageInfo/@width" />
           <xsl:variable name="VarHeightRatio" select="$VarMaxHeightOption div $VarImageInfo/@height" />
           <xsl:choose>
            <xsl:when test="(($VarWidthRatio &gt; 0) and ($VarWidthRatio &lt; $VarHeightRatio)) or ($VarHeightRatio = 0)">
             <xsl:value-of select="$VarWidthRatio" />
            </xsl:when>

            <xsl:otherwise>
             <xsl:value-of select="$VarHeightRatio" />
            </xsl:otherwise>
           </xsl:choose>
          </xsl:when>

          <!-- Scale -->
          <!--       -->
          <xsl:when test="(string-length($VarScaleOption) &gt; 0) and ($VarScaleOption != 'none') and (number($VarScaleOption) &gt; 0)">
           <xsl:value-of select="$VarScaleOption div 100.0" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="1.0" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>

      <!-- Need to resize? -->
      <!--                 -->
      <xsl:if test="($VarDownScalingRatio &gt; 0.0) and ($VarDownScalingRatio &lt; 1.0)">
       <xsl:variable name="VarResizeWidth" select="ceiling($VarImageInfo/@width * $VarDownScalingRatio)" />
       <xsl:variable name="VarResizeHeight" select="ceiling($VarImageInfo/@height * $VarDownScalingRatio)" />

       <xsl:variable name="VarTransform" select="wwimaging:Transform($ParamSplitFrame/@path, $VarImageInfo/@format, $VarQuality, $VarResizeWidth, $VarResizeHeight, $ParamSplitFrame/@path, $VarRenderDPI)" />
      </xsl:if>
     </xsl:if>
    </xsl:if>
   </xsl:if>

   <!-- Dependency info -->
   <!--                 -->
   <wwfiles:File path="{$ParamSplitFrame/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($ParamSplitFrame/@path)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarImageScale, ':', $VarScaleOption, ':', $VarMaxWidthOption, ':', $VarMaxHeightOption)}" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
    <wwfiles:Depends path="{$VarPostScriptPath}" checksum="{$VarPostScriptChecksum}" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
   </wwfiles:File>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Thumbnail">
  <xsl:param name="ParamDocumentFrame" />
  <xsl:param name="ParamBehaviorsFrame" />
  <xsl:param name="ParamSplitFrame" />
  <xsl:param name="ParamContextRule" />

  <!-- Determine thumbnail width/height limits -->
  <!--                                         -->
  <xsl:variable name="VarThumbnailWidthOption">
   <xsl:call-template name="Images-MaxSizeOption">
    <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'thumbnail-width']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarThumbnailHeightOption">
   <xsl:call-template name="Images-MaxSizeOption">
    <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'thumbnail-height']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:if test="($VarThumbnailWidthOption &gt; 0) or ($VarThumbnailHeightOption &gt; 0)">
   <!-- Determine source image path -->
   <!--                             -->
   <xsl:variable name="VarThumbnailSourcePath">
    <xsl:variable name="VarByReference" select="$ParamSplitFrame/@byref = string(true())" />
    <xsl:choose>
     <!-- Thumbnails may not have been copied yet -->
     <!--                                         -->
     <xsl:when test="$VarByReference">
      <xsl:value-of select="$ParamSplitFrame/@source" />
     </xsl:when>

     <!-- Image exists because it was just generated -->
     <!--                                            -->
     <xsl:otherwise>
      <xsl:value-of select="$ParamSplitFrame/@path" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Get thumbnail source image info -->
   <!--                                 -->
   <xsl:variable name="VarThumbnailSourceImageInfo" select="wwimaging:GetInfo($VarThumbnailSourcePath)" />

   <!-- Raster image format? -->
   <!--                      -->
   <xsl:variable name="VarRasterImageFormatAsText">
    <xsl:call-template name="Images-RasterImageFormat">
     <xsl:with-param name="ParamImageInfo" select="$VarThumbnailSourceImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRasterImageFormat" select="$VarRasterImageFormatAsText = string(true())" />

   <!-- Only process raster images -->
   <!--                            -->
   <xsl:if test="$VarRasterImageFormat">
    <!-- Determine scaling ratio -->
    <!--                         -->
    <xsl:variable name="VarScalingRatio">
     <xsl:variable name="VarWidthRatio" select="$VarThumbnailWidthOption div $VarThumbnailSourceImageInfo/@width" />
     <xsl:variable name="VarHeightRatio" select="$VarThumbnailHeightOption div $VarThumbnailSourceImageInfo/@height" />

     <xsl:choose>
      <xsl:when test="($VarWidthRatio &gt; 0) and ($VarHeightRatio &gt; 0)">
       <xsl:choose>
        <xsl:when test="$VarWidthRatio &lt; $VarHeightRatio">
         <xsl:value-of select="$VarWidthRatio" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="$VarHeightRatio" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:when test="$VarWidthRatio &gt; 0">
       <xsl:value-of select="$VarWidthRatio" />
      </xsl:when>

      <xsl:when test="$VarHeightRatio &gt; 0">
       <xsl:value-of select="$VarHeightRatio" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="1.0" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Need thumbnail? -->
    <!--                 -->
    <xsl:if test="($VarScalingRatio &gt; 0.0) and ($VarScalingRatio &lt; 1.0)">
     <!-- Thumbnail up-to-date? -->
     <!--                       -->
     <xsl:variable name="VarThumbnailPath" select="$ParamSplitFrame/wwsplits:Thumbnail/@path" />
     <xsl:variable name="VarThumbnailUpToDate" select="wwfilesext:UpToDate($VarThumbnailPath, $GlobalProject/wwproject:Project/@ChangeID, $ParamSplitFrame/@groupID, $ParamSplitFrame/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarThumbnailUpToDate)">
      <xsl:variable name="VarResizeWidth" select="ceiling($VarThumbnailSourceImageInfo/@width * $VarScalingRatio)" />
      <xsl:variable name="VarResizeHeight" select="ceiling($VarThumbnailSourceImageInfo/@height * $VarScalingRatio)" />

      <xsl:variable name="VarTransform" select="wwimaging:Transform($VarThumbnailSourcePath, $VarThumbnailSourceImageInfo/@format, $VarResizeWidth, $VarResizeHeight, $VarThumbnailPath)" />
     </xsl:if>

     <!-- Track thumbnail file -->
     <!--                      -->
     <wwfiles:File path="{$VarThumbnailPath}" type="{$ParameterThumbnailType}" checksum="{wwfilesystem:GetChecksum($VarThumbnailPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="" use="" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarThumbnailSourcePath}" checksum="{wwfilesystem:GetChecksum($VarThumbnailSourcePath)}" groupID="{$ParamSplitFrame/@groupID}" documentID="{$ParamSplitFrame/@documentID}" />
     </wwfiles:File>
    </xsl:if>
   </xsl:if>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
