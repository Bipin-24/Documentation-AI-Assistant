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
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />


 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />

   <!-- Excluded to match preview engine -->
   <!--                                  -->
   <!--
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   -->
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

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName(@path), 'preview.css')" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarResultAsXML">
      <xsl:call-template name="Styles">
       <xsl:with-param name="ParamCSSPath" select="$VarPath" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'text')" />

     <wwfiles:File path="{$VarPath}" type="preview:css" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{@groupID}" documentID="{@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Styles">
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamDocument" />

  <xsl:text>.grid-wrapper { border: dashed 1px #dddddd; }

</xsl:text>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:ParagraphStyles/wwdoc:ParagraphStyle" />
   <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   <xsl:with-param name="ParamTag" select="'div'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:ParagraphStyles/wwdoc:ParagraphStyle" />
   <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   <xsl:with-param name="ParamTag" select="'ul'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:ParagraphStyles/wwdoc:ParagraphStyle" />
   <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   <xsl:with-param name="ParamTag" select="'ol'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:ParagraphStyles/wwdoc:ParagraphStyle" />
   <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   <xsl:with-param name="ParamTag" select="'li'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:CharacterStyles/wwdoc:CharacterStyle" />
   <xsl:with-param name="ParamStyleType" select="'Character'" />
   <xsl:with-param name="ParamTag" select="'span'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:GraphicStyles/wwdoc:GraphicStyle" />
   <xsl:with-param name="ParamStyleType" select="'Graphic'" />
   <xsl:with-param name="ParamTag" select="'img'" />
  </xsl:call-template>

  <xsl:call-template name="CatalogStyles">
   <xsl:with-param name="ParamCSSPath" select="$ParamCSSPath" />
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:TableStyles/wwdoc:TableStyle" />
   <xsl:with-param name="ParamStyleType" select="'Table'" />
   <xsl:with-param name="ParamTag" select="'table'" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="CatalogStyles">
  <xsl:param name="ParamCSSPath" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentStyles" />
  <xsl:param name="ParamStyleType" />
  <xsl:param name="ParamTag" />

  <xsl:for-each select="$ParamDocumentStyles">
   <xsl:variable name="VarStyleName" select="@name" />
   <xsl:variable name="VarRule" select="wwprojext:GetRule($ParamStyleType, $VarStyleName)" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamDocument" />
     <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
     <xsl:with-param name="ParamStyleType" select="$ParamStyleType" />
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

   <xsl:for-each select="$VarCSSProperties[1]">
    <!-- CSS Style -->
    <!--           -->
    <xsl:value-of select="$ParamTag" />
    <xsl:text>.</xsl:text>
    <xsl:value-of select="wwstring:CSSClassName($VarStyleName)" />
    <xsl:text>
{
</xsl:text>

    <xsl:call-template name="CSS-CatalogProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
    </xsl:call-template>

    <xsl:text>}

</xsl:text>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
