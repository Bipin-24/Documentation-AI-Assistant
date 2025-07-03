<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
 >
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />


 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:common/tables/tables.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />

   <!-- Excluded to match preview engine -->
   <!--                                  -->
   <xsl:if test="false()">
    <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
    <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/tables/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/tables/tables.xsl')))" />
    <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
    <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   </xsl:if>
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Get project files as splits -->
 <!--                             -->
 <xsl:variable name="GlobalProjectFilesAsSplitsAsXML">
  <xsl:variable name="VarProjectFiles" select="wwfilesystem:GetFiles(wwprojext:GetProjectFilesDirectoryPath())" />

  <wwsplits:Splits>
   <xsl:for-each select="$VarProjectFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarFile" select="." />

    <xsl:variable name="VarSource" select="wwuri:MakeAbsolute('wwprojfile:dummy.component', wwuri:GetRelativeTo($VarFile/@path, wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), 'dummy.component')))" />

    <wwsplits:File source="{$VarSource}" source-lowercase="{wwstring:ToLower($VarSource)}" path="{$VarFile/@path}" />
   </xsl:for-each>
  </wwsplits:Splits>
 </xsl:variable>
 <xsl:variable name="GlobalProjectFilesAsSplits" select="msxsl:node-set($GlobalProjectFilesAsSplitsAsXML)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', 'engine:wif')" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Load document -->
     <!--               -->
     <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName(@path), 'preview_overrides.css')" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarResultAsXML">
      <xsl:call-template name="ParagraphOverrides">
       <xsl:with-param name="ParamCSSPath" select="$VarPath" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
       <xsl:with-param name="ParamDocumentID" select="@documentID" />
      </xsl:call-template>

      <xsl:call-template name="TableOverrides">
       <xsl:with-param name="ParamCSSPath" select="$VarPath" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
       <xsl:with-param name="ParamDocumentID" select="@documentID" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'text')" />

     <wwfiles:File path="{$VarPath}" type="preview_overrides:css" checksum="{wwfilesystem:GetChecksum($VarPath)}"  projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{@groupID}" documentID="{@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </wwfiles:File>

     <!-- Handle doc numbering -->
     <!--                      -->
     <xsl:call-template name="DefineParagraphNumbers">
      <xsl:with-param name="ParamDocument" select="$VarDocument" />
      <xsl:with-param name="ParamDocumentID" select="@documentID" />
      <xsl:with-param name="ParamCSSPath" select="$VarPath" />
     </xsl:call-template>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="ParagraphOverrides">
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />

  <xsl:for-each select="$ParamDocument//wwdoc:Paragraph | $ParamDocument//wwdoc:List | $ParamDocument//wwdoc:ListItem | $ParamDocument//wwdoc:Block">
   <xsl:variable name="VarParagraph" select="." />
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarParagraph/@stylename, $ParamDocumentID, $VarParagraph/@id)" />

   <!-- Context rule -->
   <!--              -->
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamDocumentID, $VarParagraph/@id)" />
   <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
   <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
   <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
   <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveOverrideRule">
     <xsl:with-param name="ParamProperties" select="$VarOverrideRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamContextStyle" select="$VarParagraph/wwdoc:Style" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- CSS properties -->
   <!--                -->
   <xsl:variable name="VarCSSPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamCSSPath" />
     <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesAsSplits" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

   <!-- Text Indent -->
   <!--             -->
   <xsl:variable name="VarTextIndent">
    <xsl:variable name="VarOverrideTextIndent" select="$VarCSSProperties[@Name = 'text-indent']/@Value" />
    <xsl:choose>
     <xsl:when test="string-length($VarOverrideTextIndent) &gt; 0">
      <xsl:value-of select="$VarOverrideTextIndent" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Retrieve from rule -->
      <!--                    -->
      <xsl:variable name="VarCatalogRule" select="wwprojext:GetRule('Paragraph', $VarParagraph/@stylename)" />

      <!-- Resolve project properties -->
      <!--                            -->
      <xsl:variable name="VarResolvedCatalogPropertiesAsXML">
       <xsl:call-template name="Properties-ResolveRule">
        <xsl:with-param name="ParamDocumentContext" select="$ParamDocument" />
        <xsl:with-param name="ParamProperties" select="$VarCatalogRule/wwproject:Properties/wwproject:Property[@Name = 'text-indent']" />
        <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
        <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedCatalogProperties" select="msxsl:node-set($VarResolvedCatalogPropertiesAsXML)/wwproject:Property" />

      <!-- CSS properties -->
      <!--                -->
      <xsl:variable name="VarCSSCatalogPropertiesAsXML">
       <xsl:call-template name="CSS-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedCatalogProperties" />
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamCSSPath" />
        <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesAsSplits" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarCSSCatalogProperties" select="msxsl:node-set($VarCSSCatalogPropertiesAsXML)/wwproject:Property" />

      <!-- Text indent defined? -->
      <!--                      -->
      <xsl:variable name="VarCatalogTextIndent" select="$VarCSSCatalogProperties[@Name = 'text-indent']/@Value" />
      <xsl:if test="string-length($VarCatalogTextIndent) &gt; 0">
       <xsl:value-of select="$VarCatalogTextIndent" />
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
   <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

   <!-- Override necessary? -->
   <!--                     -->
   <xsl:if test="(count($VarCSSProperties[1]) = 1) or (count($VarParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0) or (string-length($VarBulletSeparator) &gt; 0) or (string-length($VarBulletStyle) &gt; 0)">
    <!-- CSS Style -->
    <!--           -->
    <xsl:text>#</xsl:text>
    <xsl:value-of select="wwstring:NCNAME($VarParagraph/@id)" />
    <xsl:text>
{
</xsl:text>

    <xsl:choose>
     <xsl:when test="$VarTextIndentLessThanZero">
      <xsl:call-template name="CSS-CatalogProperties">
       <xsl:with-param name="ParamProperties" select="$VarCSSProperties[@Name != 'text-indent']" />
      </xsl:call-template>
      <xsl:text>  text-indent: 0pt;
</xsl:text>
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="CSS-CatalogProperties">
       <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>

    <xsl:text>}

</xsl:text>

    <!-- Position wrapper for negative text indent -->
    <!--                                           -->
    <xsl:if test="$VarTextIndentLessThanZero">
     <xsl:text>#</xsl:text>
     <xsl:value-of select="wwstring:NCNAME($VarParagraph/@id)" />
     <xsl:text>_PositionWrapper</xsl:text>
     <xsl:text>
{
</xsl:text>

     <xsl:text>  position: absolute;
</xsl:text>

     <xsl:text>}

</xsl:text>
     </xsl:if>

    <!-- Number style -->
    <!--              -->
    <xsl:choose>
     <xsl:when test="count($VarParagraph/wwdoc:Number[1]) = 1">
      <xsl:choose>
       <xsl:when test="$VarTextIndentLessThanZero">
        <xsl:variable name="VarNumberAsXML">
         <wwdoc:Number id="{concat(wwstring:NCNAME($VarParagraph/@id), '_Number')}" stylename="{$VarParagraph/wwdoc:Number[1]/@stylename}">
          <wwdoc:Style>
           <wwdoc:Attribute name="left" value="{$VarTextIndent}" />
           <wwdoc:Attribute name="position" value="relative" />

           <xsl:for-each select="$VarParagraph/wwdoc:Number/wwdoc:Style/wwdoc:Attribute">
            <xsl:copy-of select="." />
           </xsl:for-each>
          </wwdoc:Style>
          <xsl:copy-of select="$VarParagraph/wwdoc:Number[1]/*[local-name(.) != 'Style']"/>
         </wwdoc:Number>
        </xsl:variable>
        <xsl:variable name="VarNumber" select="msxsl:node-set($VarNumberAsXML)/wwdoc:Number[1]" />

        <!-- Number Overrides -->
        <!--                  -->
        <xsl:call-template name="CharacterOverrides">
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
         <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
         <xsl:with-param name="ParamContextNodes" select="$VarNumber" />
         <xsl:with-param name="ParamBulletStyle" select="$VarBulletStyle" />
        </xsl:call-template>
       </xsl:when>

       <xsl:otherwise>
        <!-- Number Overrides -->
        <!--                  -->
        <xsl:call-template name="CharacterOverrides">
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
         <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
         <xsl:with-param name="ParamContextNodes" select="$VarParagraph/wwdoc:Number[1]" />
         <xsl:with-param name="ParamBulletStyle" select="$VarBulletStyle" />
        </xsl:call-template>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <xsl:when test="(count($VarParagraph/wwdoc:Number[1]) = 0) and ((string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0) or (string-length($VarBulletSeparator) &gt; 0) or (string-length($VarBulletStyle) &gt; 0))">
      <xsl:choose>
       <xsl:when test="$VarTextIndentLessThanZero">
        <xsl:variable name="VarNumberAsXML">
         <wwdoc:Number id="{concat(wwstring:NCNAME($VarParagraph/@id), '_Number')}" stylename="{$VarParagraph/wwdoc:Number[1]/@stylename}">
          <wwdoc:Style>
           <wwdoc:Attribute name="left" value="{$VarTextIndent}" />
           <wwdoc:Attribute name="position" value="relative" />
          </wwdoc:Style>
         </wwdoc:Number>
        </xsl:variable>
        <xsl:variable name="VarNumber" select="msxsl:node-set($VarNumberAsXML)/wwdoc:Number[1]" />

        <!-- Number Overrides -->
        <!--                  -->
        <xsl:call-template name="CharacterOverrides">
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
         <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
         <xsl:with-param name="ParamContextNodes" select="$VarNumber" />
         <xsl:with-param name="ParamBulletStyle" select="$VarBulletStyle" />
        </xsl:call-template>
       </xsl:when>

       <xsl:otherwise>
        <!-- Create dummy number to get info emitted in CSS -->
        <!--                                                -->
        <xsl:variable name="VarNumberAsXML">
         <wwdoc:Number id="{concat(wwstring:NCNAME($VarParagraph/@id), '_Number')}" />
        </xsl:variable>
        <xsl:variable name="VarNumber" select="msxsl:node-set($VarNumberAsXML)/wwdoc:Number[1]" />

        <!-- Number Overrides -->
        <!--                  -->
        <xsl:call-template name="CharacterOverrides">
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
         <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
         <xsl:with-param name="ParamContextNodes" select="$VarNumber" />
         <xsl:with-param name="ParamBulletStyle" select="$VarBulletStyle" />
        </xsl:call-template>
       </xsl:otherwise>
      </xsl:choose>

     </xsl:when>
    </xsl:choose>

   </xsl:if>

   <!-- Character Overrides -->
   <!--                     -->
   <xsl:call-template name="CharacterOverrides">
    <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
    <xsl:with-param name="ParamContextNodes" select="$VarParagraph//wwdoc:TextRun" />
    <xsl:with-param name="ParamBulletStyle" select="''" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="TableOverrides">
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />

  <xsl:for-each select="$ParamDocument//wwdoc:Table">
   <xsl:variable name="VarTable" select="." />
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $VarTable/@stylename, $ParamDocumentID, $VarTable/@id)" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedContextPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveContextRule">
     <xsl:with-param name="ParamDocumentContext" select="$VarTable" />
     <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$VarTable/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Table'" />
     <xsl:with-param name="ParamContextStyle" select="$VarTable/wwdoc:Style" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

   <!-- CSS properties -->
   <!--                -->
   <xsl:variable name="VarCSSContextPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamCSSPath" />
     <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesAsSplits" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarCSSContextProperties" select="msxsl:node-set($VarCSSContextPropertiesAsXML)/wwproject:Property" />

   <!-- Handle table alignment -->
   <!--                        -->
   <xsl:variable name="VarTableAlignment">
    <xsl:variable name="VarTableAlignmentHint" select="$VarResolvedContextProperties[@Name = 'text-align']/@Value" />
    <xsl:choose>
     <xsl:when test="string-length($VarTableAlignmentHint) &gt; 0">
      <xsl:value-of select="$VarTableAlignmentHint" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="''" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:if test="string-length($VarTableAlignment) &gt; 0">

    <!-- Write entry for div wrapper of table -->
    <!--                                      -->
    <xsl:text>#</xsl:text>
    <xsl:value-of select="wwstring:NCNAME($VarTable/@id)" />
    <xsl:text>_horizontal_alignment</xsl:text>
    <xsl:text>
{
  text-align: </xsl:text>
    <xsl:value-of select="$VarTableAlignment" />
    <xsl:text>;
}
</xsl:text>
   </xsl:if>

   <!-- Override necessary? -->
   <!--                     -->
   <xsl:if test="count($VarCSSContextProperties[1]) = 1">
    <!-- CSS Style -->
    <!--           -->
    <xsl:text>#</xsl:text>
    <xsl:value-of select="wwstring:NCNAME($VarTable/@id)" />
    <xsl:text>
{
</xsl:text>

    <xsl:call-template name="CSS-CatalogProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSContextProperties" />
    </xsl:call-template>

    <xsl:text>}

</xsl:text>

   </xsl:if>

   <!-- Determine table cell widths -->
   <!--                             -->
   <xsl:variable name="VarTableCellWidthsAsXML">
   <xsl:variable name="VarFirstTableCellWidth" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-cell-width-first']/@Value" />
   <xsl:variable name="VarLastTableCellWidth" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-cell-width-last']/@Value" />
   <xsl:variable name="VarEmitTableWidthsOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-use-document-cell-widths']/@Value" />
   <xsl:variable name="VarEmitTableWidths" select="($VarEmitTableWidthsOption = 'true') or (string-length($VarFirstTableCellWidth) &gt; 0) or (string-length($VarLastTableCellWidth) &gt; 0)" />
   <xsl:variable name="VarEmitFirstLastOnly" select="($VarEmitTableWidthsOption != 'true') and ((string-length($VarFirstTableCellWidth) &gt; 0) or (string-length($VarLastTableCellWidth) &gt; 0))" />
   <xsl:variable name="VarUsePercentageWidthsOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-use-percentage-cell-widths']/@Value" />
   <xsl:variable name="VarUsePercentageWidths" select="$VarUsePercentageWidthsOption = 'true'" />

   <xsl:if test="$VarEmitTableWidths">
    <!-- Use percentage cell widths? -->
    <!--                             -->
    <xsl:choose>
     <!-- Use percentage cell widths -->
     <!--                            -->
     <xsl:when test="$VarUsePercentageWidths">
      <xsl:call-template name="Table-CellWidthsAsPercentage">
       <xsl:with-param name="ParamTable" select="$VarTable" />
       <xsl:with-param name="ParamReportAllCellWidths" select="false()" />
       <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
       <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
       <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
      </xsl:call-template>
     </xsl:when>

     <!-- Use original cell widths -->
     <!--                          -->
     <xsl:otherwise>
      <xsl:call-template name="Table-CellWidths">
       <xsl:with-param name="ParamTable" select="$VarTable" />
       <xsl:with-param name="ParamReportAllCellWidths" select="false()" />
       <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
       <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
       <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarTableCellWidths" select="msxsl:node-set($VarTableCellWidthsAsXML)/*" />

   <xsl:for-each select="$VarTable/wwdoc:TableHead|$VarTable/wwdoc:TableBody|$VarTable/wwdoc:TableFoot">
    <xsl:variable name="VarSection" select="." />

    <!-- Resolve section properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedSectionPropertiesAsXML">
     <xsl:call-template name="Properties-Table-Section-ResolveContextRule">
      <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamDocumentContext" select="$VarTable" />
      <xsl:with-param name="ParamTable" select="$VarTable" />
      <xsl:with-param name="ParamSection" select="$VarSection" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedSectionProperties" select="msxsl:node-set($VarResolvedSectionPropertiesAsXML)/wwproject:Property" />

    <!-- Process section rows -->
    <!--                      -->
    <xsl:for-each select="$VarSection/wwdoc:TableRow">
     <xsl:variable name="VarTableRow" select="." />
     <xsl:variable name="VarRowPosition" select="position()" />

     <xsl:for-each select="$VarTableRow/wwdoc:TableCell">
      <xsl:variable name="VarTableCell" select="." />
      <xsl:variable name="VarCellPosition" select="position()" />

      <!-- Resolve cell properties -->
      <!--                         -->
      <xsl:variable name="VarResolvedCellPropertiesAsXML">
       <xsl:call-template name="Properties-Table-Cell-ResolveProperties">
        <xsl:with-param name="ParamSectionProperties" select="$VarResolvedSectionProperties" />
        <xsl:with-param name="ParamCellStyle" select="$VarTableCell/wwdoc:Style" />
        <xsl:with-param name="ParamRowIndex" select="$VarRowPosition" />
        <xsl:with-param name="ParamColumnIndex" select="$VarCellPosition" />
       </xsl:call-template>

       <!-- Width attribute -->
       <!--                 -->
       <xsl:for-each select="$VarTableCellWidths[@id = $VarTableCell/@id][1]">
        <xsl:variable name="VarTableCellWidth" select="." />

        <wwproject:Property Name="width" Value="{$VarTableCellWidth/@width}" />
       </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="VarResolvedCellProperties" select="msxsl:node-set($VarResolvedCellPropertiesAsXML)/wwproject:Property" />

      <!-- Valid CSS properties -->
      <!--                      -->
      <xsl:variable name="VarTableCellCSSPropertiesAsXML">
       <xsl:call-template name="CSS-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedCellProperties" />
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamCSSPath" />
        <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesAsSplits" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarTableCellCSSProperties" select="msxsl:node-set($VarTableCellCSSPropertiesAsXML)/wwproject:Property" />

      <!-- Override necessary? -->
      <!--                     -->
      <xsl:if test="count($VarTableCellCSSProperties[1]) = 1">
       <!-- CSS Style -->
       <!--           -->
       <xsl:text>#</xsl:text>
       <xsl:value-of select="wwstring:NCNAME($VarTableCell/@id)" />
       <xsl:text>
{
</xsl:text>

       <xsl:call-template name="CSS-CatalogProperties">
        <xsl:with-param name="ParamProperties" select="$VarTableCellCSSProperties" />
       </xsl:call-template>

       <xsl:text>}

</xsl:text>

      </xsl:if>
     </xsl:for-each>

    </xsl:for-each>

   </xsl:for-each>
  </xsl:for-each>

  <!-- Handle cellspacing -->
  <!--                    -->
  <xsl:call-template name="DefineCellSpacing">
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="CharacterOverrides">
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamContextNodes" />
  <xsl:param name="ParamBulletStyle" />

  <!-- Iterate text runs explicitly so that position() will match override IDs -->
  <!--                                                                         -->
  <xsl:for-each select="$ParamContextNodes">
   <xsl:variable name="VarContextNode" select="." />

   <xsl:variable name="VarCharacterID">
    <xsl:choose>
     <xsl:when test="local-name($VarContextNode) = 'Number'">
      <xsl:value-of select="concat(wwstring:NCNAME($ParamParagraph/@id), '_Number')" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:if test="(string-length($VarContextNode/@stylename) &gt; 0) or (count($VarContextNode/wwdoc:Style[1]) &gt; 0)">
       <xsl:value-of select="concat(wwstring:NCNAME($VarContextNode/../@id), '_Character_', position())" />
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:if test="string-length($VarCharacterID) &gt; 0">
    <xsl:choose>
     <xsl:when test="local-name($VarContextNode) = 'Number'">

      <xsl:choose>
       <xsl:when test="string-length($ParamBulletStyle) &gt; 0">
        <!-- Get rule -->
        <!--          -->
        <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $ParamBulletStyle)" />

        <xsl:variable name="VarStyleBlockAsXML">
         <wwdoc:Style>
          <wwdoc:Attribute name="position" value="relative" />
          <wwdoc:Attribute name="left" value="{$VarContextNode/wwdoc:Style/wwdoc:Attribute[@name = 'left']/@value}" />
         </wwdoc:Style>
        </xsl:variable>
        <xsl:variable name="VarStyleBlock" select="msxsl:node-set($VarStyleBlockAsXML)/wwdoc:Style" />

        <!-- Resolve project properties -->
        <!--                            -->
        <xsl:variable name="VarResolvedContextPropertiesAsXML">
         <xsl:call-template name="Properties-ResolveContextRule">
          <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
          <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
          <xsl:with-param name="ParamStyleName" select="$ParamBulletStyle" />
          <xsl:with-param name="ParamStyleType" select="'Character'" />
          <xsl:with-param name="ParamContextStyle" select="$VarStyleBlock" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

        <xsl:call-template name="ResolveCharacterOverrides">
         <xsl:with-param name="ParamResolvedProperties" select="$VarResolvedContextProperties" />
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamCharacterID" select="$VarCharacterID" />
        </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
        <!-- Get rule -->
        <!--          -->
        <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $VarContextNode/@stylename)" />

        <!-- Resolve project properties -->
        <!--                            -->
        <xsl:variable name="VarResolvedContextPropertiesAsXML">
         <xsl:call-template name="Properties-ResolveContextRule">
          <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
          <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
          <xsl:with-param name="ParamStyleName" select="$VarContextNode/@stylename" />
          <xsl:with-param name="ParamStyleType" select="'Character'" />
          <xsl:with-param name="ParamContextStyle" select="$VarContextNode/wwdoc:Style" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

        <xsl:call-template name="ResolveCharacterOverrides">
         <xsl:with-param name="ParamResolvedProperties" select="$VarResolvedContextProperties" />
         <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
         <xsl:with-param name="ParamCharacterID" select="$VarCharacterID" />
        </xsl:call-template>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <xsl:otherwise>
      <!-- Get rule -->
      <!--          -->
      <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $VarContextNode/@stylename)" />

      <!-- Resolve project properties -->
      <!--                            -->
      <xsl:variable name="VarResolvedPropertiesAsXML">
       <xsl:call-template name="Properties-ResolveOverrideRule">
        <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamContextStyle" select="$VarContextNode/wwdoc:Style" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

      <xsl:call-template name="ResolveCharacterOverrides">
       <xsl:with-param name="ParamResolvedProperties" select="$VarResolvedProperties" />
       <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
       <xsl:with-param name="ParamCharacterID" select="$VarCharacterID" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="ResolveCharacterOverrides">
  <xsl:param name="ParamResolvedProperties" />
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamCharacterID" />

  <!-- CSS properties -->
  <!--                -->
  <xsl:variable name="VarCSSPropertiesAsXML">
   <xsl:call-template name="CSS-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$ParamResolvedProperties" />
    <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamCSSPath" />
    <xsl:with-param name="ParamSplits" select="$GlobalProjectFilesAsSplits" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

  <!-- Override necessary? -->
  <!--                     -->
  <xsl:for-each select="$VarCSSProperties[1]">
   <!-- CSS Style -->
   <!--           -->
   <xsl:text>#</xsl:text>
   <xsl:value-of select="$ParamCharacterID" />
   <xsl:text>
{
</xsl:text>

   <xsl:call-template name="CSS-CatalogProperties">
    <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
   </xsl:call-template>

   <xsl:text>}

</xsl:text>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="DefineCellSpacing">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamCSSPath" />

  <xsl:variable name="VarHTMLAttrDefPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($ParamCSSPath), 'scripts', 'docinfo_tabledata.js')" />

  <xsl:variable name="VarResultAsXML">
   <xsl:text>function WWLoadDocInfoData()
{
</xsl:text>
   <xsl:for-each select="$ParamDocument//wwdoc:Table">
    <xsl:variable name="VarTable" select="." />

    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $VarTable/@stylename, $ParamDocumentID, $VarTable/@id)" />

    <!-- Resolve project properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedContextPropertiesAsXML">
     <xsl:call-template name="Properties-ResolveContextRule">
      <xsl:with-param name="ParamDocumentContext" select="$VarTable" />
      <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$VarTable/@stylename" />
      <xsl:with-param name="ParamStyleType" select="'Table'" />
      <xsl:with-param name="ParamContextStyle" select="$VarTable/wwdoc:Style" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarCellSpacing">
     <xsl:variable name="VarCellSpacingHint" select="$VarResolvedContextProperties[@Name = 'cell-spacing']/@Value" />
     <xsl:choose>
      <xsl:when test="string-length($VarCellSpacingHint) &gt; 0">
       <xsl:value-of select="$VarCellSpacingHint" />
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="''" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <xsl:if test="string-length($VarCellSpacing) &gt; 0">
     <xsl:text>  WWDocInfo.fAddProperty('</xsl:text>
     <xsl:value-of select="wwstring:NCNAME($VarTable/@id)"/>
     <xsl:text>', 'cellSpacing', '</xsl:text>
     <xsl:value-of select="$VarCellSpacing" />
     <xsl:text>');
</xsl:text>
    </xsl:if>

   </xsl:for-each>
   <xsl:text>}
</xsl:text>
  </xsl:variable>
  <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
  <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarHTMLAttrDefPath, 'utf-8', 'text')" />
 </xsl:template>


 <xsl:template name="DefineParagraphNumbers">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamCSSPath" />

  <xsl:variable name="VarNumberDefPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($ParamCSSPath), 'scripts', 'docinfo_number.js')" />

  <xsl:variable name="VarResultAsXML">
   <xsl:text>function WWLoadDocInfoNumberData()
{
</xsl:text>
   <xsl:for-each select="$ParamDocument//wwdoc:Paragraph">
    <xsl:variable name="VarParagraph" select="." />

    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamDocumentID, $VarParagraph/@id)" />

    <!-- Use bullet from UI? -->
    <!--                     -->
    <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
    <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
    <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />

    <xsl:variable name="VarRelativeImagePath">
     <xsl:call-template name="MakePreviewBulletImages">
       <xsl:with-param name="ParamBulletImage" select="$VarBulletImage" />
      <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="'WWDocInfo.fAddNumberData('"/>
    <xsl:text>"</xsl:text><xsl:value-of select="concat(wwstring:NCNAME($VarParagraph/@id), '_Number')" /><xsl:text>"</xsl:text>
    <xsl:value-of select="', '" />
    <xsl:text>"</xsl:text><xsl:value-of select="wwstring:Replace($VarBulletCharacter, '&quot;', '\&quot;')" /><xsl:text>"</xsl:text>
    <xsl:value-of select="', '" />

    <!-- Image variable -->
    <!--                -->
    <xsl:text>&quot;</xsl:text>
    <xsl:if test="string-length($VarRelativeImagePath) &gt; 0">
     <xsl:value-of select="$VarRelativeImagePath" />
    </xsl:if>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="', '" />

    <xsl:text>&quot;</xsl:text><xsl:value-of select="wwstring:Replace($VarBulletSeparator, '&quot;', '\&quot;')" /><xsl:text>&quot;</xsl:text>
    <xsl:value-of select="', '" />
    <xsl:text>&quot;</xsl:text>

    <xsl:variable name="VarNumberText">
     <xsl:for-each select="$VarParagraph/wwdoc:Number/wwdoc:Text">
      <xsl:value-of select="wwstring:Replace(@value, '&quot;', '\&quot;') "/>
     </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="wwstring:ReplaceWithExpression($VarNumberText, '[ \t\r\n]+$', '') "/>
    <xsl:text>&quot;);
</xsl:text>

   </xsl:for-each>
   <xsl:text>
}</xsl:text>
  </xsl:variable>
  <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
  <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarNumberDefPath, 'utf-8', 'text')" />
 </xsl:template>


 <xsl:template name="MakePreviewBulletImages">
  <xsl:param name="ParamBulletImage" />
  <xsl:param name="ParamCSSPath" />

  <xsl:if test="string-length($ParamBulletImage) &gt; 0">
   <!-- Take care of path info -->
   <!--                        -->
   <xsl:variable name="VarAbsoluteBulletImagePath" select="wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), $ParamBulletImage)" />
   <xsl:variable name="VarBulletImageFileName" select="wwfilesystem:GetFileName($ParamBulletImage)" />
   <xsl:variable name="VarBulletImageWithoutExtension" select="wwfilesystem:GetFileNameWithoutExtension($VarBulletImageFileName)" />
   <xsl:variable name="VarCSSDirectory" select="wwfilesystem:GetDirectoryName($ParamCSSPath)" />
   <xsl:variable name="VarAbsoluteDestination" select="wwfilesystem:Combine($VarCSSDirectory, 'bullet_images', $VarBulletImageFileName)" />
   <xsl:variable name="VarAbsoluteGIFDestination" select="wwfilesystem:Combine($VarCSSDirectory, 'bullet_images', concat($VarBulletImageWithoutExtension, '.gif'))" />

   <xsl:variable name="VarJPEGExtension" select="wwstring:ReplaceWithExpression($VarBulletImageFileName, '^.*\.[Jj][Pp][Gg]$', true())" />
   <xsl:variable name="VarGIFExtension" select="wwstring:ReplaceWithExpression($VarBulletImageFileName, '^.*\.[Gg][Ii][Ff]$', true())" />
   <xsl:variable name="VarPNGExtension" select="wwstring:ReplaceWithExpression($VarBulletImageFileName, '^.*\.[Pp][Nn][Gg]$', true())" />

   <xsl:choose>
    <xsl:when test="($VarJPEGExtension = 'true') or ($VarGIFExtension = 'true')">
     <xsl:if test="wwfilesystem:FileExists($VarAbsoluteDestination) != 'true'">
      <xsl:variable name="VarIgnore">
       <xsl:value-of select="wwfilesystem:CopyFile($VarAbsoluteBulletImagePath, $VarAbsoluteDestination)" />
      </xsl:variable>
     </xsl:if>
     <xsl:value-of select="wwuri:GetRelativeTo($VarAbsoluteDestination, $ParamCSSPath)"/>
    </xsl:when>

    <!-- Raster GIFs for preview -->
    <!--                         -->
    <xsl:when test="$VarPNGExtension = 'true'">
     <xsl:variable name="VarBulletSourceImageInfo" select="wwimaging:GetInfo($VarAbsoluteBulletImagePath)" />

     <xsl:variable name="VarResizeWidth" select="round($VarBulletSourceImageInfo/@width)" />
     <xsl:variable name="VarResizeHeight" select="round($VarBulletSourceImageInfo/@height)" />

     <xsl:if test="wwfilesystem:FileExists($VarAbsoluteGIFDestination) != 'true'">
      <xsl:if test="wwfilesystem:DirectoryExists(wwfilesystem:GetDirectoryName($VarAbsoluteGIFDestination)) != 'true'">
       <xsl:variable name="VarIgnoreMakeDir">
        <xsl:value-of select="wwfilesystem:CreateDirectory(wwfilesystem:GetDirectoryName($VarAbsoluteGIFDestination))" />
       </xsl:variable>
      </xsl:if>

      <xsl:variable name="VarIgnoreMakeImage">
       <xsl:value-of select="wwimaging:Transform($VarAbsoluteBulletImagePath, 'GIF', $VarResizeWidth, $VarResizeHeight, $VarAbsoluteGIFDestination)" />
      </xsl:variable>
     </xsl:if>

     <xsl:value-of select="wwuri:GetRelativeTo($VarAbsoluteGIFDestination, $ParamCSSPath)"/>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
