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
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwmultisere="urn:WebWorks-XSLT-Extension-MultiSearchReplace"
                              exclude-result-prefixes="xsl msxsl wwsplits wwmode wwfiles wwdoc wwbehaviors wwproject wwimages wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwunits wwprojext wwimaging wwexsldoc wwmultisere"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterImageTypesType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDefaultPageExtension" />
 <xsl:param name="ParameterDefaultGraphicExtension" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 
 <xsl:include href="wwtransform:common/images/utilities.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-splits-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwbehaviors-frames-by-id" match="wwbehaviors:Frame" use="@id" />
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/utilities.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:variable name="GlobalFilenameSplitPattern" select="normalize-space(wwprojext:GetFormatSetting('filename-split-pattern'))" />
 <xsl:variable name="GlobalFilenameFramePattern" select="normalize-space(wwprojext:GetFormatSetting('filename-frame-pattern'))" />
 <xsl:variable name="GlobalFilenameTablePattern" select="normalize-space(wwprojext:GetFormatSetting('filename-table-pattern'))" />

 <xsl:variable name="GlobalMaxTitleLength" select="48" />

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <!-- Image types -->
    <!--             -->
    <xsl:variable name="VarImageTypesPath" select="key('wwfiles-files-by-type', $ParameterImageTypesType)[1]/@path" />
    <xsl:variable name="VarImageTypes" select="wwexsldoc:LoadXMLWithoutResolver($VarImageTypesPath, false())" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFile" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFile/@groupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarGroupNameInfo" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path, false())" />

       <xsl:call-template name="Names">
        <xsl:with-param name="ParamGroupNameInfo" select="$VarGroupNameInfo" />
        <xsl:with-param name="ParamGroupID" select="$VarFile/@groupID" />
        <xsl:with-param name="ParamAllowedByReferenceTypes" select="$VarImageTypes" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFile/@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFile/@path}" checksum="{$VarFile/@checksum}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Names">
  <xsl:param name="ParamGroupNameInfo" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamAllowedByReferenceTypes" />

  <xsl:for-each select="$ParamGroupNameInfo/wwsplits:Splits">
   <xsl:variable name="VarSplits" select="." />

   <xsl:variable name="VarDocumentNumberingPadLength" select="string-length($VarSplits/wwsplits:Split[last()]/wwsplits:Document/@position)" />

   <wwsplits:Splits>
    <xsl:copy-of select="$VarSplits/@*" />

    <!-- Process all splits for a document at once -->
    <!--                                           -->
    <xsl:variable name="VarProjectGroupDocuments" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group[@GroupID = $ParamGroupID]//wwproject:Document" />
    <xsl:for-each select="$VarProjectGroupDocuments">
     <xsl:variable name="VarProjectGroupDocument" select="." />

     <!-- Locate document behaviors -->
     <!--                           -->
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarBehaviorsFiles" select="key('wwfiles-files-by-documentid', $VarProjectGroupDocument/@DocumentID)[@type = $ParameterBehaviorsType]" />

      <xsl:for-each select="$VarBehaviorsFiles[1]">
       <xsl:variable name="VarBehaviorsFile" select="." />

       <!-- Load document behaviors -->
       <!--                         -->
       <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

       <!-- Process document splits -->
       <!--                         -->
       <xsl:for-each select="$VarSplits[1]">
        <xsl:variable name="VarDocumentSplits" select="key('wwsplits-splits-by-documentid', $VarProjectGroupDocument/@DocumentID)" />

        <xsl:variable name="VarSplitNumberingPadLength" select="string-length(count($VarDocumentSplits))" />

        <!-- Process split -->
        <!--               -->
        <xsl:for-each select="$VarDocumentSplits">
         <xsl:variable name="VarSplit" select="." />

         <!-- Get page rule -->
         <!--               -->
         <xsl:variable name="VarPageStyleName">
          <xsl:call-template name="StyleName">
           <xsl:with-param name="ParamStyleNode" select="$VarSplit/wwsplits:PageStyle" />
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarPageRule" select="wwprojext:GetOverrideRule('Page', $VarPageStyleName, $VarSplit/@documentID, $VarSplit/@id)" />

         <!-- Generate output? -->
         <!--                  -->
         <xsl:variable name="VarPageGenerateOutputOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
         <xsl:variable name="VarPageGenerateOutput" select="(string-length($VarPageGenerateOutputOption) = 0) or ($VarPageGenerateOutputOption != 'false')" />

         <!-- Generate output? -->
         <!--                  -->
         <xsl:if test="$VarPageGenerateOutput">
          <!-- Get path -->
          <!--          -->
          <xsl:variable name="VarSplitPath">
           <xsl:call-template name="SplitPath">
            <xsl:with-param name="ParamSplit" select="$VarSplit" />
            <xsl:with-param name="ParamRule" select="$VarPageRule" />
            <xsl:with-param name="ParamDocumentNumberingPadLength" select="$VarDocumentNumberingPadLength" />
            <xsl:with-param name="ParamSplitNumberingPadLength" select="$VarSplitNumberingPadLength" />
           </xsl:call-template>
          </xsl:variable>
 
          <xsl:variable name="VarReplacedGroupName">
           <xsl:call-template name="ReplaceGroupNameSpacesWith">
            <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($VarSplit/@documentID)" />
           </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />
          <xsl:variable name="VarImagesDirectoryPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'images')" />
          <xsl:variable name="VarMediaDirectoryPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'media')" />

          <wwsplits:Split>
           <xsl:copy-of select="$VarSplit/@*" />
           <xsl:attribute name="path">
            <xsl:value-of select="$VarSplitPath" />
           </xsl:attribute>
           <xsl:attribute name="stylename">
            <xsl:value-of select="$VarPageStyleName" />
           </xsl:attribute>

           <xsl:variable name="VarFrameNumberingPadLength" select="string-length(count($VarSplit/wwsplits:Frames/wwsplits:Frame))" />

           <xsl:for-each select="$VarSplit/wwsplits:Frames/wwsplits:Frame">
            <xsl:variable name="VarFrame" select="." />

            <!-- Get graphic rule -->
            <!--                  -->
            <xsl:variable name="VarGraphicContextRule" select="wwprojext:GetContextRule('Graphic', $VarFrame/wwdoc:Frame/@stylename, $VarSplit/@documentID, $VarFrame/wwdoc:Frame/@id)" />

            <!-- Generate output? -->
            <!--                  -->
            <xsl:variable name="VarGraphicGenerateOutputOption" select="$VarGraphicContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
            <xsl:variable name="VarGraphicGenerateOutput" select="(string-length($VarGraphicGenerateOutputOption) = 0) or ($VarGraphicGenerateOutputOption != 'false')" />

            <!-- Generate output? -->
            <!--                  -->
            <xsl:if test="$VarGraphicGenerateOutput">
             <!-- WIF structure allows for by reference graphic? -->
             <!--                                                -->
             <xsl:variable name="VarWIFAllowsByReferenceAsText">
              <xsl:call-template name="Images-WIFAllowsByReference">
               <xsl:with-param name="ParamFrame" select="$VarFrame" />
              </xsl:call-template>
             </xsl:variable>
             <xsl:variable name="VarWIFAllowsByReference" select="$VarWIFAllowsByReferenceAsText = string(true())" />

             <!-- By reference source path -->
             <!--                          -->
             <xsl:variable name="VarByReferenceSourcePath">
              <xsl:choose>
               <xsl:when test="$VarWIFAllowsByReference">
                <xsl:variable name="VarByReferenceFacets"  select="$VarFrame/wwdoc:Frame//wwdoc:Facet[@type = 'by-reference']" />
                <xsl:for-each select="$VarByReferenceFacets[1]">
                 <xsl:variable name="VarByReferenceFacet" select="." />

                 <xsl:value-of select="$VarByReferenceFacet/wwdoc:Attribute[@name = 'path']/@value" />
                </xsl:for-each>
               </xsl:when>

               <xsl:otherwise>
                <xsl:value-of select="''" />
               </xsl:otherwise>
              </xsl:choose>
             </xsl:variable>

             <!-- By reference source path exists? -->
             <!--                                  -->
             <xsl:variable name="VarByReferenceSourcePathExistsAsText">
              <xsl:if test="string-length($VarByReferenceSourcePath) &gt; 0">
               <xsl:value-of select="wwfilesystem:FileExists($VarByReferenceSourcePath)" />
              </xsl:if>
             </xsl:variable>
             <xsl:variable name="VarByReferenceSourcePathExists" select="$VarByReferenceSourcePathExistsAsText = string(true())" />

             <!-- Handle as by-reference image? -->
             <!--                               -->
             <xsl:variable name="VarByReferenceAsText">
              <!-- Image file exists? -->
              <!--                    -->
              <xsl:if test="$VarByReferenceSourcePathExists">
               <!-- Locate frame behavior -->
               <!--                       -->
               <xsl:for-each select="$VarBehaviors[1]">
                <xsl:variable name="VarBehaviorFrame" select="key('wwbehaviors-frames-by-id', $VarFrame/wwdoc:Frame/@id)[1]" />

                <!-- Allow by reference? -->
                <!--                     -->
                <xsl:call-template name="Images-AllowByReference">
                 <xsl:with-param name="ParamAllowedByReferenceTypes" select="$ParamAllowedByReferenceTypes" />
                 <xsl:with-param name="ParamByReferenceSourcePath" select="$VarByReferenceSourcePath" />
                 <xsl:with-param name="ParamContextRule" select="$VarGraphicContextRule" />
                 <xsl:with-param name="ParamFrameBehavior" select="$VarBehaviorFrame" />
                </xsl:call-template>
               </xsl:for-each>
              </xsl:if>
             </xsl:variable>
             <xsl:variable name="VarByReference" select="$VarByReferenceAsText = string(true())" />

             <!-- Get path -->
             <!--          -->
             <xsl:variable name="VarFramePath">
              <xsl:choose>
               <xsl:when test="$VarByReference">
                <xsl:value-of select="wwfilesystem:Combine($VarImagesDirectoryPath, wwstring:ReplaceWithExpression(wwfilesystem:GetFileName($VarByReferenceSourcePath), $GlobalInvalidPathCharactersExpression, '_'))" />
               </xsl:when>

               <xsl:otherwise>
                <xsl:call-template name="FramePath">
                 <xsl:with-param name="ParamSplit" select="$VarSplit" />
                 <xsl:with-param name="ParamFrame" select="$VarFrame" />
                 <xsl:with-param name="ParamRule" select="$VarGraphicContextRule" />
                 <xsl:with-param name="ParamDocumentNumberingPadLength" select="$VarDocumentNumberingPadLength" />
                 <xsl:with-param name="ParamSplitNumberingPadLength" select="$VarSplitNumberingPadLength" />
                 <xsl:with-param name="ParamFrameNumberingPadLength" select="$VarFrameNumberingPadLength" />
                </xsl:call-template>
               </xsl:otherwise>
              </xsl:choose>
             </xsl:variable>

             <wwsplits:Frame>
              <xsl:attribute name="groupID">
               <xsl:value-of select="$VarSplit/@groupID" />
              </xsl:attribute>
              <xsl:attribute name="documentID">
               <xsl:value-of select="$VarSplit/@documentID" />
              </xsl:attribute>
              <xsl:copy-of select="$VarFrame/wwdoc:Frame/@*" />
              <xsl:copy-of select="$VarFrame/@*" />
              <xsl:if test="$VarByReference">
               <xsl:attribute name="byref">
                <xsl:value-of select="true()" />
               </xsl:attribute>
              </xsl:if>
              <xsl:if test="($VarWIFAllowsByReference) and ($VarByReferenceSourcePathExists)">
               <xsl:attribute name="byref-allowed-by-wif">
                <xsl:value-of select="true()" />
               </xsl:attribute>
              </xsl:if>
              <xsl:if test="(($VarByReference) or ($VarWIFAllowsByReference)) and ($VarByReferenceSourcePathExists)">
               <xsl:attribute name="source">
                <xsl:value-of select="$VarByReferenceSourcePath" />
               </xsl:attribute>
              </xsl:if>
              <xsl:if test="($VarWIFAllowsByReference) and (not($VarByReferenceSourcePathExists))">
               <xsl:attribute name="byref-source-missing">
                <xsl:value-of select="$VarByReferenceSourcePath" />
               </xsl:attribute>
              </xsl:if>
              <xsl:attribute name="path">
               <xsl:value-of select="$VarFramePath" />
              </xsl:attribute>

              <!-- Media? -->
              <!--        -->
              <xsl:variable name="VarMediaFilePath" select="$VarFrame//wwdoc:Facet[@type = 'media'][1]/wwdoc:Attribute[@name = 'path'][1]/@value" />
              <xsl:if test="(string-length($VarMediaFilePath) &gt; 0) and (wwfilesystem:FileExists($VarMediaFilePath))">
               <wwsplits:Media source="{$VarMediaFilePath}">
                <xsl:attribute name="path">
                 <xsl:value-of select="wwfilesystem:Combine($VarMediaDirectoryPath, wwfilesystem:GetFileName($VarMediaFilePath))" />
                </xsl:attribute>

                <xsl:variable name="VarMediaType" select="$VarFrame//wwdoc:Facet[@type = 'media'][1]/wwdoc:Attribute[@name = 'type'][1]/@value" />
                <xsl:if test="string-length($VarMediaType) &gt; 0">
                 <xsl:attribute name="media-type">
                  <xsl:value-of select="$VarMediaType" />
                 </xsl:attribute>
                </xsl:if>
               </wwsplits:Media>
              </xsl:if>

              <!-- Thumbnail, wrapper, and description files -->
              <!--                                           -->
              <xsl:variable name="VarThumbnailPageRuleOption" select="$VarGraphicContextRule/wwproject:Options/wwproject:Option[@Name = 'thumbnail-page-rule']/@Value" />
              <wwsplits:Thumbnail>
               <xsl:attribute name="path">
                <xsl:variable name="VarFileName">
                 <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($VarFramePath)" />
                 <xsl:text>_thumb</xsl:text>
                 <xsl:value-of select="wwfilesystem:GetExtension($VarFramePath)" />
                </xsl:variable>

                <xsl:value-of select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFramePath), $VarFileName)" />
               </xsl:attribute>
              </wwsplits:Thumbnail>
              <wwsplits:Wrapper groupID="{$VarSplit/@groupID}" documentID="{$VarSplit/@documentID}" stylename="{$VarThumbnailPageRuleOption}">
               <xsl:attribute name="path">
                <xsl:variable name="VarFileName">
                 <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($VarFramePath)" />
                 <xsl:value-of select="$ParameterDefaultPageExtension" />
                </xsl:variable>

                <xsl:value-of select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFramePath), $VarFileName)" />
               </xsl:attribute>
              </wwsplits:Wrapper>
              <wwsplits:Description>
               <xsl:attribute name="path">
                <xsl:variable name="VarFileName">
                 <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($VarFramePath)" />
                 <xsl:text>.txt</xsl:text>
                </xsl:variable>

                <xsl:value-of select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFramePath), $VarFileName)" />
               </xsl:attribute>
              </wwsplits:Description>
             </wwsplits:Frame>
            </xsl:if>
           </xsl:for-each>

           <!-- Copy over any tables -->
           <!--                      -->
           <xsl:variable name="VarTables" select="$VarSplit/wwsplits:Tables/wwsplits:Table" />
           <xsl:variable name="VarTableNumberingPadLength" select="string-length(count($VarTables))" />
           <xsl:for-each select="$VarTables">
            <xsl:variable name="VarTable" select="." />

            <xsl:variable name="VarDocumentBaseName" select="wwfilesystem:GetFileNameWithoutExtension($VarSplit/wwsplits:Document/@path)" />
            <xsl:variable name="VarTableFileName">
             <xsl:value-of select="$VarDocumentBaseName" />
             <xsl:text>-</xsl:text>
             <xsl:value-of select="$VarTable/@id" />
             <xsl:value-of select="$ParameterDefaultPageExtension" />
            </xsl:variable>
            <xsl:variable name="VarTablePath">
             <xsl:call-template name="TablePath">
              <xsl:with-param name="ParamSplit" select="$VarSplit" />
              <xsl:with-param name="ParamTable" select="$VarTable" />
              <xsl:with-param name="ParamRule" select="$VarPageRule" />
              <xsl:with-param name="ParamDocumentNumberingPadLength" select="$VarDocumentNumberingPadLength" />
              <xsl:with-param name="ParamSplitNumberingPadLength" select="$VarSplitNumberingPadLength" />
              <xsl:with-param name="ParamTableNumberingPadLength" select="$VarTableNumberingPadLength" />
             </xsl:call-template>
            </xsl:variable>

            <wwsplits:Table>
             <xsl:copy-of select="$VarTable/@*" />

             <xsl:attribute name="path">
              <xsl:value-of select="$VarTablePath" />
             </xsl:attribute>
            </wwsplits:Table>
           </xsl:for-each>

           <!-- Copy over any popups -->
           <!--                      -->
           <xsl:variable name="VarPopups" select="$VarSplit/wwsplits:Popups/wwsplits:Popup" />
           <xsl:for-each select="$VarPopups">
            <xsl:variable name="VarPopup" select="." />

            <!-- Get popup page rule -->
            <!--                     -->
            <xsl:variable name="VarPopupPageRule" select="wwprojext:GetRule('Page', $VarPopup/@stylename)" />
            <xsl:variable name="VarPopupPageExtensionOption" select="$VarPopupPageRule/wwproject:Options/wwproject:Option[@Name = 'file-extension']/@Value" />

            <xsl:variable name="VarDocumentBaseName" select="wwfilesystem:GetFileNameWithoutExtension($VarSplit/wwsplits:Document/@path)" />
            <xsl:variable name="VarPopupFileName">
             <xsl:value-of select="$VarDocumentBaseName" />
             <xsl:text>-</xsl:text>
             <xsl:value-of select="$VarPopup/@id" />
             <xsl:choose>
              <xsl:when test="string-length($VarPopupPageExtensionOption) &gt; 0">
               <xsl:value-of select="$VarPopupPageExtensionOption" />
              </xsl:when>

              <xsl:otherwise>
               <xsl:value-of select="$ParameterDefaultPageExtension" />
              </xsl:otherwise>
             </xsl:choose>
            </xsl:variable>
            <xsl:variable name="VarPopupPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), $VarSplit/wwsplits:Group/@name, 'popups', $VarPopupFileName)" />

            <wwsplits:Popup>
             <xsl:copy-of select="$VarPopup/@*" />

             <xsl:attribute name="path">
              <xsl:value-of select="$VarPopupPath" />
             </xsl:attribute>
            </wwsplits:Popup>
           </xsl:for-each>
          </wwsplits:Split>
         </xsl:if>
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:for-each>

   </wwsplits:Splits>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="StyleName">
  <xsl:param name="ParamStyleNode" />

  <xsl:choose>
   <xsl:when test="count($ParamStyleNode[1]) = 1">
    <!-- Use requested style -->
    <!--                     -->
    <xsl:value-of select="$ParamStyleNode/@value" />
   </xsl:when>

   <xsl:otherwise>
    <!-- Force default rule -->
    <!--                    -->
    <xsl:value-of select="''" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Make-Valid-Path">
  <xsl:param name="ParamPath" select="." />

  <xsl:variable name="VarPath" select="translate($ParamPath, '\', '/')" />
  <xsl:call-template name="Make-Valid-Path-Entries">
   <xsl:with-param name="ParamPath" select="$VarPath" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Make-Valid-Path-Entries">
  <xsl:param name="ParamPath" select="." />

  <xsl:choose>
   <!-- Multiple path entries exist? -->
   <!--                              -->
   <xsl:when test="contains($ParamPath, '/')">
    <xsl:variable name="VarPrefix" select="substring-before($ParamPath, '/')" />
    <xsl:variable name="VarSuffix" select="substring-after($ParamPath, '/')" />

    <xsl:variable name="VarPathRemainder">
     <xsl:call-template name="Make-Valid-Path-Entries">
      <xsl:with-param name="ParamPath" select="$VarSuffix" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
     <xsl:when test="(string-length($VarPrefix) &gt; 0) and (string-length($VarPathRemainder) &gt; 0)">
      <xsl:value-of select="wwfilesystem:Combine($VarPrefix, $VarPathRemainder)" />
     </xsl:when>

     <xsl:when test="(string-length($VarPrefix) &gt; 0) and (string-length($VarPathRemainder) = 0)">
      <xsl:value-of select="wwfilesystem:MakeValidFileName($VarPrefix)" />
     </xsl:when>

     <xsl:when test="(string-length($VarPrefix) = 0) and (string-length($VarPathRemainder) &gt; 0)">
      <xsl:value-of select="$VarPathRemainder" />
     </xsl:when>
    </xsl:choose>
   </xsl:when>

   <!-- Single path entry -->
   <!--                   -->
   <xsl:otherwise>
    <xsl:value-of select="wwfilesystem:MakeValidFileName($ParamPath)" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="H-Macro-Replacement">
  <xsl:param name="ParamTitle" />

  <xsl:variable name="VarNormalizeQuotes" select="wwstring:NormalizeQuotes($ParamTitle)" />
  <xsl:variable name="VarTitleLengthUnknown" select="normalize-space($VarNormalizeQuotes)" />
  <xsl:variable name="VarTrimmedTitle">
   <xsl:choose>
    <xsl:when test="string-length($VarTitleLengthUnknown) &gt; $GlobalMaxTitleLength">
     <xsl:value-of select="normalize-space(substring($VarTitleLengthUnknown, 1, $GlobalMaxTitleLength))" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarTitleLengthUnknown" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <wwmultisere:Entry match="$H;" replacement="{wwfilesystem:MakeValidFileName($VarTrimmedTitle)}" />
 </xsl:template>


 <xsl:template name="SplitPath">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamDocumentNumberingPadLength" />
  <xsl:param name="ParamSplitNumberingPadLength" />

  <!-- Gather file naming info -->
  <!--                         -->
  <xsl:variable name="VarReplacedDocumentGroupPath">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($ParamSplit/@documentID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedDocumentGroupPath, $GlobalInvalidPathCharactersExpression, '_'))" />
  <xsl:variable name="VarBaseFileName">
   <xsl:variable name="VarFileNameHint" select="$ParamSplit/wwsplits:FileName/@value" />
   <xsl:choose>
    <xsl:when test="string-length($VarFileNameHint) &gt; 0">
     <xsl:value-of select="$VarFileNameHint" />
    </xsl:when>

    <!-- Use original document name if this document does not split -->
    <!--                                                            -->
    <xsl:when test="($ParamSplit/@position = 1) and (count($ParamSplit/following-sibling::wwsplits:Split[@documentID = $ParamSplit/@documentID]) = 0)">
     <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)" />
    </xsl:when>

    <xsl:otherwise>
     <!-- Zero pad document number -->
     <!--                          -->
     <xsl:variable name="VarDN">
      <xsl:call-template name="ZeroPadder">
       <xsl:with-param name="ParamString" select="$ParamSplit/wwsplits:Document/@position" />
       <xsl:with-param name="ParamTotal" select="$ParamDocumentNumberingPadLength" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Zero pad page number -->
     <!--                      -->
     <xsl:variable name="VarPN">
      <xsl:call-template name="ZeroPadder">
       <xsl:with-param name="ParamString" select="$ParamSplit/@position" />
       <xsl:with-param name="ParamTotal" select="$ParamSplitNumberingPadLength" />
      </xsl:call-template>
     </xsl:variable>
 
     <!-- Define replacements -->
     <!--                     -->
     <xsl:variable name="VarReplacementsAsXML">
      <wwmultisere:Entry match="$P;" replacement="{normalize-space(wwprojext:GetProjectName())}" />
      <wwmultisere:Entry match="$T;" replacement="{normalize-space(wwprojext:GetProjectTargetName())}" />
      <wwmultisere:Entry match="$G;" replacement="{normalize-space(wwprojext:GetGroupName($ParamSplit/@groupID))}" />
      <wwmultisere:Entry match="$C;">
       <xsl:attribute name="replacement">
        <xsl:call-template name="MergeGroupContext">
         <xsl:with-param name="ParamProject" select="$GlobalProject" />
         <xsl:with-param name="ParamGroupID" select="$ParamSplit/@groupID" />
        </xsl:call-template>
       </xsl:attribute>
      </wwmultisere:Entry>
      <wwmultisere:Entry match="$D;" replacement="{wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)}" />
      <xsl:call-template name="H-Macro-Replacement">
       <xsl:with-param name="ParamTitle" select="$ParamSplit/@title" />
      </xsl:call-template>
      <wwmultisere:Entry match="$DN;" replacement="{$VarDN}" />
      <wwmultisere:Entry match="$PN;" replacement="{$VarPN}" />
     </xsl:variable>
     <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)/*" />
     <xsl:variable name="VarBaseFileNameFromPattern" select="wwmultisere:ReplaceAllInString($GlobalFilenameSplitPattern, $VarReplacements)" />

     <!-- Make sure a valid filename is defined -->
     <!--                                       -->
     <xsl:choose>
      <xsl:when test="string-length($VarBaseFileNameFromPattern) &gt; 0">
       <xsl:value-of select="$VarBaseFileNameFromPattern" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)" />
       <xsl:text>.</xsl:text>
       <xsl:value-of select="$ParamSplit/wwsplits:Document/@position" />
       <xsl:text>.</xsl:text>
       <xsl:value-of select="$ParamSplit/@position" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarExtensionOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'file-extension']/@Value" />
  <xsl:variable name="VarExtension">
   <xsl:choose>
    <xsl:when test="string-length($VarExtensionOption) &gt; 0">
     <xsl:value-of select="$VarExtensionOption" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParameterDefaultPageExtension" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarCasedBaseFileName">
   <xsl:call-template name="ConvertNameTo">
    <xsl:with-param name="ParamText" select="$VarBaseFileName" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarReplacedBaseFileName">
   <xsl:call-template name="ReplaceFileNameSpacesWith">
    <xsl:with-param name="ParamText" select="$VarCasedBaseFileName" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarName">
   <xsl:value-of select="$VarReplacedBaseFileName" />
   <xsl:value-of select="$VarExtension" />
  </xsl:variable>
  
  <xsl:variable name="VarValidPath">
   <xsl:call-template name="Make-Valid-Path">
    <xsl:with-param name="ParamPath" select="wwstring:ReplaceWithExpression($VarName, $GlobalInvalidPathCharactersExpression, '_')" />
   </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, $VarValidPath)" />

  <xsl:value-of select="$VarPath" />
 </xsl:template>


 <xsl:template name="FramePath">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamDocumentNumberingPadLength" />
  <xsl:param name="ParamSplitNumberingPadLength" />
  <xsl:param name="ParamFrameNumberingPadLength" />

  <!-- Gather file naming info -->
  <!--                         -->
  <xsl:variable name="VarReplacedDocumentGroupPath">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($ParamSplit/@documentID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedDocumentGroupPath, $GlobalInvalidPathCharactersExpression, '_'))" />
  <xsl:variable name="VarImagesDirectoryPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'images')" />
  <xsl:variable name="VarBaseFileName">
   <xsl:variable name="VarFileNameHint" select="$ParamFrame/wwsplits:FileName/@value" />
   <xsl:choose>
    <xsl:when test="string-length($VarFileNameHint) &gt; 0">
     <xsl:value-of select="$VarFileNameHint" />
    </xsl:when>

    <xsl:otherwise>
     <!-- Zero pad document number -->
     <!--                          -->
     <xsl:variable name="VarDN">
      <xsl:call-template name="ZeroPadder">
       <xsl:with-param name="ParamString" select="$ParamSplit/wwsplits:Document/@position" />
       <xsl:with-param name="ParamTotal" select="$ParamDocumentNumberingPadLength" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Zero pad page number -->
     <!--                      -->
     <xsl:variable name="VarPN">
      <xsl:call-template name="ZeroPadder">
       <xsl:with-param name="ParamString" select="$ParamSplit/@position" />
       <xsl:with-param name="ParamTotal" select="$ParamSplitNumberingPadLength" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Zero pad graphic number -->
     <!--                         -->
     <xsl:variable name="VarGN">
      <xsl:call-template name="ZeroPadder">
       <xsl:with-param name="ParamString" select="$ParamFrame/@position" />
       <xsl:with-param name="ParamTotal" select="$ParamFrameNumberingPadLength" />
      </xsl:call-template>
     </xsl:variable>
    
     <!-- Define replacements -->
     <!--                     -->
     <xsl:variable name="VarReplacementsAsXML">
      <wwmultisere:Entry match="$P;" replacement="{normalize-space(wwprojext:GetProjectName())}" />
      <wwmultisere:Entry match="$T;" replacement="{normalize-space(wwprojext:GetProjectTargetName())}" />
      <wwmultisere:Entry match="$G;" replacement="{normalize-space(wwprojext:GetGroupName($ParamSplit/@groupID))}" />
      <wwmultisere:Entry match="$C;">
       <xsl:attribute name="replacement">
        <xsl:call-template name="MergeGroupContext">
         <xsl:with-param name="ParamProject" select="$GlobalProject" />
         <xsl:with-param name="ParamGroupID" select="$ParamSplit/@groupID" />
        </xsl:call-template>
       </xsl:attribute>
      </wwmultisere:Entry>
      <wwmultisere:Entry match="$D;" replacement="{wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)}" />
      <xsl:call-template name="H-Macro-Replacement">
       <xsl:with-param name="ParamTitle" select="$ParamSplit/@title" />
      </xsl:call-template>
      <wwmultisere:Entry match="$DN;" replacement="{$VarDN}" />
      <wwmultisere:Entry match="$PN;" replacement="{$VarPN}" />
      <wwmultisere:Entry match="$GN;" replacement="{$VarGN}" />
     </xsl:variable>
     <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)/*" />
     <xsl:variable name="VarBaseFileNameFromPattern" select="wwmultisere:ReplaceAllInString($GlobalFilenameFramePattern, $VarReplacements)" />

     <!-- Make sure a valid filename is defined -->
     <!--                                       -->
     <xsl:choose>
      <xsl:when test="string-length($VarBaseFileNameFromPattern) &gt; 0">
       <xsl:value-of select="$VarBaseFileNameFromPattern" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)" />
       <xsl:text>.</xsl:text>
       <xsl:value-of select="$ParamSplit/wwsplits:Document/@position" />
       <xsl:text>.</xsl:text>
       <xsl:value-of select="$ParamSplit/@position" />
       <xsl:text>.</xsl:text>
       <xsl:value-of select="$ParamFrame/@position" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarExtensionOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'file-extension']/@Value" />
  <xsl:variable name="VarExtension">
   <xsl:choose>
    <xsl:when test="string-length($VarExtensionOption) &gt; 0">
     <xsl:value-of select="$VarExtensionOption" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParameterDefaultGraphicExtension" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="VarCasedBaseFileName">
   <xsl:call-template name="ConvertNameTo">
    <xsl:with-param name="ParamText" select="$VarBaseFileName" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarReplacedBaseFileName">
   <xsl:call-template name="ReplaceFileNameSpacesWith">
    <xsl:with-param name="ParamText" select="$VarCasedBaseFileName" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarName">
   <xsl:value-of select="$VarReplacedBaseFileName" />
   <xsl:value-of select="$VarExtension" />
  </xsl:variable>
  <xsl:variable name="VarValidPath">
   <xsl:call-template name="Make-Valid-Path">
    <xsl:with-param name="ParamPath" select="wwstring:ReplaceWithExpression($VarName, $GlobalInvalidPathCharactersExpression, '_')" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarImagesDirectoryPath, $VarValidPath)" />

  <xsl:value-of select="$VarPath" />
 </xsl:template>


 <xsl:template name="TablePath">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamDocumentNumberingPadLength" />
  <xsl:param name="ParamSplitNumberingPadLength" />
  <xsl:param name="ParamTableNumberingPadLength" />
 
  <!-- Gather file naming info -->
  <!--                         -->
  <xsl:variable name="VarReplacedDocumentGroupPath">
   <xsl:call-template name="ReplaceGroupNameSpacesWith">
    <xsl:with-param name="ParamText" select="wwprojext:GetDocumentGroupPath($ParamSplit/@documentID)" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedDocumentGroupPath, $GlobalInvalidPathCharactersExpression, '_'))" />
  <xsl:variable name="VarTablesDirectoryPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'tables')" />
  <xsl:variable name="VarBaseFileName">
   <!-- Zero pad document number -->
   <!--                          -->
   <xsl:variable name="VarDN">
    <xsl:call-template name="ZeroPadder">
     <xsl:with-param name="ParamString" select="$ParamSplit/wwsplits:Document/@position" />
     <xsl:with-param name="ParamTotal" select="$ParamDocumentNumberingPadLength" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Zero pad page number -->
   <!--                      -->
   <xsl:variable name="VarPN">
    <xsl:call-template name="ZeroPadder">
     <xsl:with-param name="ParamString" select="$ParamSplit/@position" />
     <xsl:with-param name="ParamTotal" select="$ParamSplitNumberingPadLength" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Zero pad table number -->
   <!--                       -->
   <xsl:variable name="VarTN">
    <xsl:call-template name="ZeroPadder">
     <xsl:with-param name="ParamString" select="$ParamTable/@position" />
     <xsl:with-param name="ParamTotal" select="$ParamTableNumberingPadLength" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Define replacements -->
   <!--                     -->
   <xsl:variable name="VarReplacementsAsXML">
    <wwmultisere:Entry match="$P;" replacement="{normalize-space(wwprojext:GetProjectName())}" />
    <wwmultisere:Entry match="$T;" replacement="{normalize-space(wwprojext:GetProjectTargetName())}" />
    <wwmultisere:Entry match="$G;" replacement="{normalize-space(wwprojext:GetGroupName($ParamSplit/@groupID))}" />
    <wwmultisere:Entry match="$C;">
     <xsl:attribute name="replacement">
      <xsl:call-template name="MergeGroupContext">
       <xsl:with-param name="ParamProject" select="$GlobalProject" />
       <xsl:with-param name="ParamGroupID" select="$ParamSplit/@groupID" />
      </xsl:call-template>
     </xsl:attribute>
    </wwmultisere:Entry>
    <wwmultisere:Entry match="$D;" replacement="{wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)}" />
    <xsl:call-template name="H-Macro-Replacement">
     <xsl:with-param name="ParamTitle" select="$ParamSplit/@title" />
    </xsl:call-template>
    <wwmultisere:Entry match="$DN;" replacement="{$VarDN}" />
    <wwmultisere:Entry match="$PN;" replacement="{$VarPN}" />
    <wwmultisere:Entry match="$TN;" replacement="{$VarTN}" />
   </xsl:variable>
   <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)/*" />
   <xsl:variable name="VarBaseFileNameFromPattern" select="wwmultisere:ReplaceAllInString($GlobalFilenameTablePattern, $VarReplacements)" />

   <!-- Make sure a valid filename is defined -->
   <!--                                       -->
   <xsl:choose>
    <xsl:when test="string-length($VarBaseFileNameFromPattern) &gt; 0">
     <xsl:value-of select="$VarBaseFileNameFromPattern" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="wwfilesystem:GetFileNameWithoutExtension($ParamSplit/wwsplits:Document/@path)" />
     <xsl:text>.</xsl:text>
     <xsl:value-of select="$ParamSplit/wwsplits:Document/@position" />
     <xsl:text>.</xsl:text>
     <xsl:value-of select="$ParamSplit/@position" />
     <xsl:text>.</xsl:text>
     <xsl:value-of select="$ParamTable/@position" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarExtensionOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'file-extension']/@Value" />
  <xsl:variable name="VarExtension">
   <xsl:choose>
    <xsl:when test="string-length($VarExtensionOption) &gt; 0">
     <xsl:value-of select="$VarExtensionOption" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParameterDefaultPageExtension" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarCasedBaseFileName">
   <xsl:call-template name="ConvertNameTo">
    <xsl:with-param name="ParamText" select="$VarBaseFileName" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarReplacedBaseFileName">
   <xsl:call-template name="ReplaceFileNameSpacesWith">
    <xsl:with-param name="ParamText" select="$VarCasedBaseFileName" />
   </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="VarName">
   <xsl:value-of select="$VarReplacedBaseFileName" />
   <xsl:value-of select="$VarExtension" />
  </xsl:variable>
  <xsl:variable name="VarValidPath">
   <xsl:call-template name="Make-Valid-Path">
    <xsl:with-param name="ParamPath" select="wwstring:ReplaceWithExpression($VarName, $GlobalInvalidPathCharactersExpression, '_')" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarTablesDirectoryPath, $VarValidPath)" />

  <xsl:value-of select="$VarPath" />
 </xsl:template>


 <xsl:template name="MergeGroupContext">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamGroupID" />

  <!-- Merge context -->
  <!--               -->
  <xsl:variable name="VarMergeGroupContext">
   <xsl:for-each select="$ParamProject[1]">
    <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
    <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

    <xsl:variable name="VarMergeGroup" select="$VarMergeSettings//wwproject:MergeGroup[@GroupID = $ParamGroupID]" />
    <xsl:if test="count($VarMergeGroup) &gt; 0">
     <xsl:value-of select="$VarMergeGroup/@Context" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
   <!-- Merge context -->
   <!--               -->
   <xsl:when test="string-length($VarMergeGroupContext)">
    <xsl:value-of select="wwstring:WebWorksHelpContextOrTopic($VarMergeGroupContext)" />
   </xsl:when>

   <!-- Project group name -->
   <!--                    -->
   <xsl:otherwise>
    <xsl:value-of select="wwstring:WebWorksHelpContextOrTopic(wwprojext:GetGroupName($ParamGroupID))" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- Zero padder template -->
 <!--                      -->
 <xsl:template name="ZeroPadder">
  <xsl:param name="ParamString" />
  <xsl:param name="ParamTotal" />

  <xsl:choose>
   <xsl:when test="string-length($ParamString) &lt; $ParamTotal">
    <xsl:variable name="VarString">
     <xsl:text>0</xsl:text>
     <xsl:value-of select="$ParamString" />
    </xsl:variable>

    <xsl:call-template name="ZeroPadder">
     <xsl:with-param name="ParamString" select="$VarString" />
     <xsl:with-param name="ParamTotal" select="$ParamTotal" />
    </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="$ParamString" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
