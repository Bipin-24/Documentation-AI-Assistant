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
                              xmlns:wwutil="urn:WebWorks-XSLT-Extension-Util"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwmddefaults="urn:WebWorks-Markdown-Defaults-Schema"
                              exclude-result-prefixes="xsl msxsl wwmode wwdoc wwproject wwprops wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc wwutil wwbehaviors wwmddefaults"
>
 <xsl:key name="wwmddefaults-paragraph-styles-by-name" match="wwmddefaults:ParagraphStyle" use="@name" />
 <xsl:key name="wwmddefaults-character-styles-by-name" match="wwmddefaults:CharacterStyle" use="@name" />
 <xsl:key name="wwmddefaults-table-styles-by-name" match="wwmddefaults:TableStyle" use="@name" />
 <xsl:key name="wwmddefaults-graphic-styles-by-name" match="wwmddefaults:GraphicStyle" use="@name" />


 <!-- Default Markdown Styles -->
 <!--                         -->
 <xsl:variable name="GlobalMDDefaults" select="wwexsldoc:LoadXMLWithoutResolver('wwtransform:markdown/defaults.xml')" />

 <xsl:variable name="GlobalDefaultParagraphStylesAsXML">
  <wwmddefaults:ParagraphStyles>
   <xsl:for-each select="$GlobalMDDefaults/wwmddefaults:MarkdownDefaults/wwmddefaults:ParagraphStyles/wwmddefaults:ParagraphStyle">
    <xsl:variable name="VarStyle" select="." />
    <wwmddefaults:ParagraphStyle name="{$VarStyle/@name}" />
   </xsl:for-each>
  </wwmddefaults:ParagraphStyles>
 </xsl:variable>
 <xsl:variable name="GlobalDefaultParagraphStyles" select="msxsl:node-set($GlobalDefaultParagraphStylesAsXML)" />

 <xsl:variable name="GlobalDefaultCharacterStylesAsXML">
  <wwmddefaults:CharacterStyles>
  <xsl:for-each select="$GlobalMDDefaults/wwmddefaults:MarkdownDefaults/wwmddefaults:CharacterStyles/wwmddefaults:CharacterStyle">
    <xsl:variable name="VarStyle" select="." />
    <wwmddefaults:CharacterStyle name="{$VarStyle/@name}" />
  </xsl:for-each>
  </wwmddefaults:CharacterStyles>
 </xsl:variable>
 <xsl:variable name="GlobalDefaultCharacterStyles" select="msxsl:node-set($GlobalDefaultCharacterStylesAsXML)" />

 <xsl:variable name="GlobalDefaultTableStylesAsXML">
  <wwmddefaults:TableStyles>
   <xsl:for-each select="$GlobalMDDefaults/wwmddefaults:MarkdownDefaults/wwmddefaults:TableStyles/wwmddefaults:TableStyle">
    <xsl:variable name="VarStyle" select="." />
    <wwmddefaults:TableStyle name="{$VarStyle/@name}" />
   </xsl:for-each>
  </wwmddefaults:TableStyles>
 </xsl:variable>
 <xsl:variable name="GlobalDefaultTableStyles" select="msxsl:node-set($GlobalDefaultTableStylesAsXML)" />

 <xsl:variable name="GlobalDefaultGraphicStylesAsXML">
  <wwmddefaults:GraphicStyles>
   <xsl:for-each select="$GlobalMDDefaults/wwmddefaults:MarkdownDefaults/wwmddefaults:GraphicStyles/wwmddefaults:GraphicStyle">
    <xsl:variable name="VarStyle" select="." />
    <wwmddefaults:GraphicStyle name="{$VarStyle/@name}" />
   </xsl:for-each>
  </wwmddefaults:GraphicStyles>
 </xsl:variable>
 <xsl:variable name="GlobalDefaultGraphicStyles" select="msxsl:node-set($GlobalDefaultGraphicStylesAsXML)" />


 <xsl:template name="Markdown-TranslateParagraphStyleProperties">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamParagraph" />

  <!-- syntax -->
  <!--        -->
  <xsl:variable name="VarSyntaxProperty" select="$ParamProperties[@Name = 'syntax']" />
  <xsl:variable name="VarSyntaxPropertyValue">
   <xsl:call-template name="Private-MdSyntaxTranslate">
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="$VarSyntaxPropertyValue = 'auto-detect'">
    <xsl:variable name="VarAutoSyntax">
     <xsl:choose>
      <!-- Use document style toc-level property -->
      <!--                                       -->
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 1)]">
       <xsl:text>title-1</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 2)]">
       <xsl:text>heading-1</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 3)]">
       <xsl:text>heading-2</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 4)]">
       <xsl:text>heading-3</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 5)]">
       <xsl:text>heading-4</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 6)]">
       <xsl:text>heading-5</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamProperties[@Name='toc-level' and (@Value = 7)]">
       <xsl:text>heading-6</xsl:text>
      </xsl:when>

      <!-- Use document style white-space property -->
      <!--                                         -->
      <xsl:when test="count($ParamProperties[@Name='white-space' and starts-with(@Value, 'pre')][1]) = 1">
       <xsl:text>code-fence</xsl:text>
      </xsl:when>

      <xsl:when test="((count($ParamParagraph/wwdoc:Number[1]) = 1) and
                       (number($ParamParagraph/wwdoc:Number/@value) = 0) and
                       (count($ParamParagraph/wwdoc:Number/wwdoc:Style/wwdoc:Attribute[(@name = 'list-style-type')][1]) = 0)
                      ) or
                      (count($ParamParagraph/wwdoc:Number/wwdoc:Style/wwdoc:Attribute[(@name = 'list-style-type') and (@value = 'bullet')][1]) = 1)">
       <xsl:text>unordered-list</xsl:text>
      </xsl:when>

      <xsl:when test="(number($ParamParagraph/wwdoc:Number/@value) &gt; 0) or
                      (count($ParamParagraph/wwdoc:Number/wwdoc:Style/wwdoc:Attribute[(@name = 'wwdoc-list-level') and (@value &gt; 0)][1]) = 1)">
       <xsl:variable name="VarIsList" select="wwstring:MatchExpression($ParamParagraph/wwdoc:Number/wwdoc:Text[1]/@value, '[0-9a-zA-Z]+[.][ \t]')" />
       <xsl:if test="$VarIsList">
        <xsl:text>ordered-list</xsl:text>
       </xsl:if>
      </xsl:when>
     </xsl:choose>
    </xsl:variable>
    <wwproject:Property Name="syntax" Value="{$VarAutoSyntax}" />
   </xsl:when>

   <xsl:otherwise>
    <wwproject:Property Name="syntax" Value="{$VarSyntaxPropertyValue}" />
   </xsl:otherwise>
  </xsl:choose>

  <!-- indentation-level -->
  <!--                   -->
  <xsl:variable name="VarIndentationLevelProperty" select="$ParamProperties[@Name = 'indentation-level']" />
  <xsl:variable name="VarIndentationLevelPropertyValue">
   <xsl:call-template name="Private-MdIndentationLevelTranslate">
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="$VarIndentationLevelPropertyValue = 'none'">
    <xsl:variable name="VarNoneIndentationLevel">
     <xsl:text>0</xsl:text>
    </xsl:variable>
    <wwproject:Property Name="indentation-level" Value="{$VarNoneIndentationLevel}" />
   </xsl:when>
   <xsl:otherwise>
    <wwproject:Property Name="indentation-level" Value="{$VarIndentationLevelPropertyValue}" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Markdown-TranslateCharacterStyleProperties">
  <xsl:param name="ParamProperties" />

  <!-- syntax -->
  <!--        -->
  <xsl:variable name="VarSyntaxProperty" select="$ParamProperties[@Name = 'syntax']" />
  <xsl:variable name="VarSyntaxPropertyValue">
   <xsl:call-template name="Private-MdSyntaxTranslate">
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="$VarSyntaxPropertyValue = 'auto-detect'">
    <!-- Use document style toc-level property -->
    <!--                                       -->
    <xsl:variable name="VarAutoSyntax">
     <xsl:choose>
      <xsl:when test="count($ParamProperties[@Name='white-space' and starts-with(@Value, 'pre')][1]) = 1">
       <xsl:text>code</xsl:text>
      </xsl:when>
      <xsl:when test="count($ParamProperties[@Name = 'font-weight' and @Value = 'bold'][1]) = 1">
       <xsl:text>bold</xsl:text>
      </xsl:when>
      <xsl:when test="count($ParamProperties[@Name = 'font-style' and @Value = 'italic'][1]) = 1">
       <xsl:text>italic</xsl:text>
      </xsl:when>
      <xsl:when test="count($ParamProperties[@Name = 'text-decoration-line-through' and @Value = 'single'][1]) = 1">
       <xsl:text>strikethrough</xsl:text>
      </xsl:when>
     </xsl:choose>
    </xsl:variable>
    <wwproject:Property Name="syntax" Value="{$VarAutoSyntax}" />
   </xsl:when>
   <xsl:otherwise>
    <wwproject:Property Name="syntax" Value="{$VarSyntaxPropertyValue}" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Markdown-Paragraph-TableCell">
  <xsl:param name="ParamNumber" />
  <xsl:param name="ParamContent" />

  <!-- Escape Markdown special characters -->
  <!--                                    -->
  <xsl:variable name="VarEscapedNumberAsXML">
   <xsl:apply-templates select="$ParamNumber" mode="wwmode:escape-markdown" />
  </xsl:variable>
  <xsl:variable name="VarEscapedNumber" select="msxsl:node-set($VarEscapedNumberAsXML)" />
  <xsl:variable name="VarEscapedContentAsXML">
   <xsl:apply-templates select="$ParamContent" mode="wwmode:escape-markdown" />
  </xsl:variable>
  <xsl:variable name="VarEscapedContent" select="msxsl:node-set($VarEscapedContentAsXML)" />

  <xsl:copy-of select="$VarEscapedNumber" />
  <xsl:copy-of select="$VarEscapedContent"/>

  <!-- New Line -->
  <xsl:text>
</xsl:text>

 </xsl:template>


 <xsl:template name="Markdown-Paragraph">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamNumber" />
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <xsl:variable name="VarSyntax" select="$ParamProperties[@Name = 'syntax']/@Value" />

  <xsl:variable name="VarEscapedNumberAsXML">
   <xsl:apply-templates select="$ParamNumber" mode="wwmode:escape-markdown" />
  </xsl:variable>
  <xsl:variable name="VarEscapedNumber" select="msxsl:node-set($VarEscapedNumberAsXML)" />
  <xsl:variable name="VarEscapedContentAsXML">
   <xsl:apply-templates select="$ParamContent" mode="wwmode:escape-markdown" />
  </xsl:variable>
  <xsl:variable name="VarEscapedContent" select="msxsl:node-set($VarEscapedContentAsXML)" />

  <xsl:variable name="VarStructurePrefixFirstLine">
   <xsl:call-template name="Private-MdStructurePrefix-Recurse">
    <xsl:with-param name="ParamElement" select="$ParamParagraph" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarStructurePrefixAdditional">
   <xsl:call-template name="Private-MdStructurePrefix-Recurse">
    <xsl:with-param name="ParamElement" select="$ParamParagraph" />
    <xsl:with-param name="ParamIsFirstLine" select="false()" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarParaPrefixFirstLine">
   <xsl:call-template name="Private-MdParaPrefixWithSyntax">
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarParaPrefixAdditional">
   <xsl:call-template name="Private-MdParaPrefixWithSyntax">
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$ParamProperties" />
    <xsl:with-param name="ParamIsFirstLine" select="false()" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarTotalPrefixAdditional">
   <xsl:copy-of select="$VarStructurePrefixAdditional" />
   <xsl:copy-of select="$VarParaPrefixAdditional" />
  </xsl:variable>

  <!-- Apply List/Block structure prefix -->
  <!--                                   -->
  <xsl:copy-of select="$VarStructurePrefixFirstLine" />

  <!-- Apply Paragraph pseudo structure prefix and include content -->
  <!--                                                             -->
  <xsl:choose>
   <xsl:when test="($VarSyntax = 'unordered-list') or
                  ($VarSyntax = 'ordered-list')">
    <xsl:variable name="VarPrecedingParagraph" select="$ParamParagraph/preceding-sibling::wwdoc:Paragraph[1]" />
    <xsl:variable name="VarPrecedingStyleName">
     <xsl:value-of select="$VarPrecedingParagraph/@stylename" />
    </xsl:variable>
    <xsl:variable name="VarParaAutoNumberValue" select="number($ParamParagraph/wwdoc:Number[1]/@value)" />

    <xsl:if test="(($VarSyntax = 'unordered-list') and ((string-length($VarPrecedingStyleName) = 0) or
                                                      ($ParamParagraph/@stylename != $VarPrecedingStyleName))) or
                  (($VarSyntax = 'ordered-list') and ($VarParaAutoNumberValue = 1))">
     <!-- Use prefix for additional lines of preceding paragraph -->
     <!--                                                        -->
     <xsl:variable name="VarPreviousParaPrefix">
      <xsl:call-template name="Private-PrecedingParaMdParaPrefix-Recurse">
       <xsl:with-param name="ParamCurrentParagraph" select="$ParamParagraph" />
       <xsl:with-param name="ParamCurrentLevel" select="number($ParamProperties[@Name = 'indentation-level']/@Value)" />
       <xsl:with-param name="ParamCurrentPrefix" select="string('')" />
       <xsl:with-param name="ParamIsFirstLine" select="false()" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:call-template name="Private-MdPlusParaTag-StyleOnly">
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamRule" select="$ParamRule" />
      <xsl:with-param name="ParamPrefix" select="$VarPreviousParaPrefix" />
      <xsl:with-param name="ParamNextLinePrefix" select="$VarStructurePrefixAdditional" />
     </xsl:call-template>
    </xsl:if>

    <xsl:copy-of select="$VarParaPrefixFirstLine" />

    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="string('')" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarTotalPrefixAdditional" />
     <xsl:with-param name="ParamSuppressStyleName" select="true()" />
    </xsl:call-template>

    <xsl:copy-of select="$VarEscapedContent"/>
   </xsl:when>

   <xsl:when test="$VarSyntax = 'blockquote'">
    <xsl:variable name="VarPrecedingParagraph" select="$ParamParagraph/preceding-sibling::wwdoc:Paragraph[1]" />
    <xsl:variable name="VarPrecedingStyleName">
     <xsl:value-of select="$VarPrecedingParagraph/@stylename" />
    </xsl:variable>

    <xsl:if test="((string-length($VarPrecedingStyleName) = 0) or
                   ($ParamParagraph/@stylename != $VarPrecedingStyleName))">
     <!-- Use prefix for additional lines of preceding paragraph -->
     <!--                                                        -->
     <xsl:variable name="VarPreviousParaPrefix">
      <xsl:call-template name="Private-PrecedingParaMdParaPrefix-Recurse">
       <xsl:with-param name="ParamCurrentParagraph" select="$ParamParagraph" />
       <xsl:with-param name="ParamCurrentLevel" select="number($ParamProperties[@Name = 'indentation-level']/@Value)" />
       <xsl:with-param name="ParamCurrentPrefix" select="string('')" />
       <xsl:with-param name="ParamIsFirstLine" select="false()" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:call-template name="Private-MdPlusParaTag-StyleOnly">
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamRule" select="$ParamRule" />
      <xsl:with-param name="ParamPrefix" select="$VarPreviousParaPrefix" />
      <xsl:with-param name="ParamNextLinePrefix" select="$VarStructurePrefixAdditional" />
     </xsl:call-template>
    </xsl:if>

    <xsl:copy-of select="$VarParaPrefixFirstLine" />

    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="string('')" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarTotalPrefixAdditional" />
     <xsl:with-param name="ParamSuppressStyleName" select="true()" />
    </xsl:call-template>

    <xsl:copy-of select="$VarEscapedContent"/>
   </xsl:when>

   <xsl:when test="$VarSyntax = 'code-fence'">
    <!-- Use prefix for additional lines of current paragraph -->
    <!--  (same as using previous paragraph prefix)           -->
    <xsl:copy-of select="$VarParaPrefixAdditional" />

    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="string('')" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarTotalPrefixAdditional" />
    </xsl:call-template>

    <xsl:text>```
</xsl:text>
    <xsl:copy-of select="$VarTotalPrefixAdditional" />

    <wwexsldoc:Text disable-output-escaping="yes">
     <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text" mode="wwmode:paragraph-code-fence" />
    </wwexsldoc:Text>

    <wwexsldoc:Text disable-output-escaping="yes">
     <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:paragraph-code-fence">
      <xsl:with-param name="ParamPrefix" select="$VarTotalPrefixAdditional" />
     </xsl:apply-templates>
    </wwexsldoc:Text>

    <xsl:text>
</xsl:text>

    <xsl:copy-of select="$VarTotalPrefixAdditional" />
    <xsl:text>```</xsl:text>
   </xsl:when>

   <xsl:when test="$VarSyntax = 'title-1'">
    <!-- Use prefix for additional lines of current paragraph -->
    <!--  (same as using previous paragraph prefix)           -->
    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="$VarParaPrefixAdditional" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarStructurePrefixAdditional" />
    </xsl:call-template>

    <xsl:copy-of select="$VarParaPrefixFirstLine" />

    <xsl:copy-of select="$VarEscapedNumber"/>
    <xsl:copy-of select="$VarEscapedContent" />
    <xsl:call-template name="Private-MdTitleUnderline">
     <xsl:with-param name="ParamContent" select="$VarEscapedNumber | $VarEscapedContent" />
     <xsl:with-param name="ParamReplacementString" select="'='" />
     <xsl:with-param name="ParamPrefix" select="$VarTotalPrefixAdditional" />
    </xsl:call-template>
   </xsl:when>

   <xsl:when test="$VarSyntax = 'title-2'">
    <!-- Use prefix for additional lines of current paragraph -->
    <!--  (same as using previous paragraph prefix)           -->
    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="$VarParaPrefixAdditional" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarStructurePrefixAdditional" />
    </xsl:call-template>

    <xsl:copy-of select="$VarParaPrefixFirstLine" />

    <xsl:copy-of select="$VarEscapedNumber"/>
    <xsl:copy-of select="$VarEscapedContent" />
    <xsl:call-template name="Private-MdTitleUnderline">
     <xsl:with-param name="ParamContent" select="$VarEscapedNumber | $VarEscapedContent" />
     <xsl:with-param name="ParamReplacementString" select="'-'" />
     <xsl:with-param name="ParamPrefix" select="$VarTotalPrefixAdditional" />
    </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
    <!-- Use prefix for additional lines of current paragraph -->
    <!--  (same as using previous paragraph prefix)           -->
    <xsl:call-template name="Private-MdPlusParaTag">
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$ParamRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     <xsl:with-param name="ParamPrefix" select="$VarParaPrefixAdditional" />
     <xsl:with-param name="ParamNextLinePrefix" select="$VarStructurePrefixAdditional" />
    </xsl:call-template>

    <xsl:copy-of select="$VarParaPrefixFirstLine" />

    <xsl:copy-of select="$VarEscapedNumber"/>
    <xsl:copy-of select="$VarEscapedContent" />
   </xsl:otherwise>
  </xsl:choose>

  <!-- Add empty line after paragraph -->
  <!--                                -->
  <xsl:text>
</xsl:text>

  <!-- Reapply prefix when inside a blockquote and followed by content -->
  <!--                                                                 -->
  <xsl:variable name="VarAncestorIsBlockquote" select="$ParamParagraph/ancestor::wwdoc:Block" />
  <xsl:variable name="VarParaHasFollowingSibling" select="$ParamParagraph/following-sibling::*" />
  <xsl:variable name="VarParaIsBlockquote" select="$VarSyntax = 'blockquote'" />

  <xsl:choose>
   <xsl:when test="$VarAncestorIsBlockquote and $VarParaHasFollowingSibling">
    <xsl:copy-of select="$VarTotalPrefixAdditional" />
   </xsl:when>

   <xsl:when test="VarParaIsBlockquote">
    <xsl:variable name="VarFollowingPara" select="$ParamParagraph/following-sibling::wwdoc:Paragraph" />

    <xsl:variable name="VarFollowingParaPropertiesAsXML">
     <xsl:call-template name="Private-MdParaProperties">
      <xsl:with-param name="ParamParagraph" select="$VarFollowingPara" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarFollowingParaProperties" select="msxsl:node-set($VarFollowingParaPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarFollowingParaSyntax">
     <xsl:call-template name="Private-MdParaSyntax">
      <xsl:with-param name="ParamParagraph" select="$VarFollowingPara" />
      <xsl:with-param name="ParamProperties" select="$VarFollowingParaProperties" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$VarFollowingParaSyntax = 'blockquote'">
     <xsl:copy-of select="$VarTotalPrefixAdditional" />
    </xsl:if>
   </xsl:when>
  </xsl:choose>

  <xsl:text>
</xsl:text>
 </xsl:template>


 <xsl:template name="Markdown-ParaLineBreak">
  <xsl:param name="ParamLineBreak"  />

  <xsl:variable name="VarTotalPrefixAdditional">
   <xsl:call-template name="Private-MdStructurePrefix-Recurse">
    <xsl:with-param name="ParamElement" select="$ParamLineBreak/ancestor::wwdoc:Paragraph[1]" />
    <xsl:with-param name="ParamIsFirstLine" select="false()" />
   </xsl:call-template>
   <xsl:call-template name="Private-MdParaPrefixWithSyntax-MissingProperties">
    <xsl:with-param name="ParamParagraph" select="$ParamLineBreak/ancestor::wwdoc:Paragraph[1]" />
    <xsl:with-param name="ParamIsFirstLine" select="false()" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="Private-ParaLineBreak">
   <xsl:with-param name="ParamLineBreak" select="$ParamLineBreak" />
   <xsl:with-param name="ParamPrefix" select="$VarTotalPrefixAdditional" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Markdown-ParaNumber">
  <xsl:param name="ParamNumber" />

  <xsl:variable name="VarUseBullet" select="((number($ParamNumber/@value) = 0) and (count($ParamNumber/wwdoc:Style/wwdoc:Attribute[(@name='list-style-type')]) = 0)) or
                                            (count($ParamNumber/wwdoc:Style/wwdoc:Attribute[(@name='list-style-type') and (@value = 'bullet')][1]) = 1)" />

  <xsl:choose>
   <xsl:when test="$VarUseBullet">
    <xsl:text>- </xsl:text>
   </xsl:when>

  <xsl:otherwise>
   <xsl:variable name="VarNumber">
    <xsl:for-each select="$ParamNumber/wwdoc:Text">
     <xsl:value-of select="wwstring:Replace(./@value,'&#x9;', ' ')" />
    </xsl:for-each>
   </xsl:variable>

   <!-- if number exists, clean it up -->
   <!--                               -->
   <xsl:if test="string-length(normalize-space($VarNumber)) &gt; 0">
    <xsl:value-of select="wwstring:Replace(normalize-space($VarNumber), '&#x9;', ' ')" />
    <xsl:text> </xsl:text>
   </xsl:if>
  </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Markdown-TextRun">
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamTextRunContent" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />

  <!-- syntax -->
  <!--        -->
  <xsl:variable name="VarSyntax" select="$ParamProperties[@Name = 'syntax']/@Value" />


  <xsl:if test="string-length($VarSyntax) &gt; 0">
   <!-- Apply optional Markdown++ leading comment -->
   <!--                                           -->
   <xsl:call-template name="Private-MdPlusTextRunTag">
    <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
    <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
   </xsl:call-template>

   <xsl:element name="wwdoc:MDSyntax">
    <xsl:choose>
     <xsl:when test="$VarSyntax = 'bold'">
      <xsl:text>**</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'italic'">
      <xsl:text>*</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'strikethrough'">
      <xsl:text>~~</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'code'">
      <xsl:text>`</xsl:text>
     </xsl:when>
    </xsl:choose>
   </xsl:element>
  </xsl:if>

  <xsl:choose>
   <xsl:when test="$VarSyntax = 'code'">
    <xsl:element name="wwdoc:DisableMDEscape">
     <xsl:value-of select="$ParamTextRunContent" />
    </xsl:element>
   </xsl:when>

   <xsl:otherwise>
    <xsl:copy-of select="$ParamTextRunContent" />
   </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="string-length($VarSyntax) &gt; 0">
   <xsl:element name="wwdoc:MDSyntax">
    <xsl:choose>
     <xsl:when test="$VarSyntax = 'bold'">
      <xsl:text>**</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'italic'">
      <xsl:text>*</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'strikethrough'">
      <xsl:text>~~</xsl:text>
     </xsl:when>
     <xsl:when test="$VarSyntax = 'code'">
      <xsl:text>`</xsl:text>
     </xsl:when>
    </xsl:choose>
   </xsl:element>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Markdown-LinkPrefix">
  <xsl:param name="ParamLinkInfo" />

  <xsl:if test="string-length($ParamLinkInfo/@href) &gt; 0">
   <xsl:element name="wwdoc:MDSyntax">
    <xsl:text>[</xsl:text>
   </xsl:element>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Markdown-LinkSuffix">
  <xsl:param name="ParamLinkInfo" />

  <xsl:if test="string-length($ParamLinkInfo/@href) &gt; 0">
   <wwexsldoc:NoBreak />
   <xsl:element name="wwdoc:MDSyntax">
    <xsl:text>](</xsl:text>
    <wwexsldoc:NoBreak />
    <xsl:value-of select="$ParamLinkInfo/@href" />
   </xsl:element>

   <xsl:if test="string-length($ParamLinkInfo/@title) &gt; 0">
    <wwexsldoc:NoBreak />
    <xsl:element name="wwdoc:MDSyntax">
     <xsl:text> "</xsl:text>
    </xsl:element>

    <xsl:value-of select="$ParamLinkInfo/@title" />

    <xsl:element name="wwdoc:MDSyntax">
     <xsl:text>"</xsl:text>
    </xsl:element>
   </xsl:if>

   <wwexsldoc:NoBreak />
   <xsl:element name="wwdoc:MDSyntax">
    <xsl:text>)</xsl:text>
   </xsl:element>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Markdown-ImageLink">
  <xsl:param name="ParamAltText" />
  <xsl:param name="ParamSrc" />
  <xsl:param name="ParamTitleText" />
  <xsl:param name="ParamStyleName" />

  <xsl:if test="string-length($ParamStyleName) &gt; 0">
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:text>&lt;!-- style:</xsl:text>
    <xsl:value-of select="$ParamStyleName" />
    <xsl:text> --&gt;</xsl:text>
   </wwexsldoc:Text>
  </xsl:if>

  <xsl:element name="wwdoc:MDSyntax">
   <xsl:text>![</xsl:text>
  </xsl:element>

  <xsl:value-of select="$ParamAltText" />

  <xsl:element name="wwdoc:MDSyntax">
   <xsl:text>](</xsl:text>
   <xsl:value-of select="$ParamSrc" />
  </xsl:element>

  <xsl:if test="string-length($ParamTitleText) &gt; 0">
   <xsl:element name="wwdoc:MDSyntax">
    <xsl:text> "</xsl:text>
   </xsl:element>

   <xsl:value-of select="$ParamTitleText" />

   <xsl:element name="wwdoc:MDSyntax">
    <xsl:text>"</xsl:text>
   </xsl:element>
  </xsl:if>

  <xsl:element name="wwdoc:MDSyntax">
   <xsl:text>)</xsl:text>
  </xsl:element>
 </xsl:template>


 <xsl:template name="Markdown-FNoteRef">
  <xsl:param name="ParamNoteNumber" />

  <xsl:element name="wwdoc:MDSyntax">
   <xsl:text>[^</xsl:text>
  </xsl:element>
  <xsl:value-of select="$ParamNoteNumber" />
  <xsl:element name="wwdoc:MDSyntax">
   <xsl:text>]</xsl:text>
  </xsl:element>
 </xsl:template>


 <xsl:template name="Markdown-FNotes">
  <xsl:param name="ParamNotes" />

  <xsl:text>
</xsl:text>

  <xsl:for-each select="$ParamNotes">
   <xsl:variable name="VarNote" select="." />
   <xsl:variable name="VarParagraphID" select="$VarNote/wwdoc:Paragraph[1]/@id" />
   <xsl:variable name="VarParagraphStyleName" select="$VarNote/wwdoc:Paragraph[1]/@stylename" />
   <xsl:variable name="VarNoteContentAsXML"><!-- TODO: Replace with apply-templates to process each TextRun for inline styling support. -->
    <xsl:for-each select="$VarNote//wwdoc:TextRun/wwdoc:Text">
     <xsl:value-of select="@value" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarNoteContent" select="msxsl:node-set($VarNoteContentAsXML)" />
   <xsl:variable name="VarEscapedNoteContent">
    <xsl:apply-templates select="$VarNoteContent" mode="wwmode:escape-markdown" />
   </xsl:variable>

   <!-- TODO: handle Markdown++ comment for the paragraph using style name of this note. -->

   <xsl:text>[^</xsl:text>
   <xsl:value-of select="position()" />
   <xsl:text>]: </xsl:text>
   <xsl:value-of select="$VarEscapedNoteContent" />
   <xsl:text>

</xsl:text>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Markdown-Table">
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamStyleName" />

  <xsl:variable name="VarTableRule" select="wwprojext:GetRule('Table', $ParamStyleName)" />
  <xsl:variable name="VarRenderingOption" select="$VarTableRule/wwproject:Options/wwproject:Option[@Name = 'table-rendering']/@Value" />

  <xsl:variable name="VarXMarkdownAsXml">
   <xsl:copy-of select="wwutil:ConvertHtmlToXMarkdown($ParamTable, $VarRenderingOption)" />
  </xsl:variable>

  <xsl:variable name="VarXMarkdown" select="msxsl:node-set($VarXMarkdownAsXml)" />

  <!-- Use StyleName? -->
  <!--                -->
  <xsl:variable name="VarUseStyleNameOption" select="$VarTableRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
  <xsl:variable name="VarUseStyleName" select="(string-length($ParamStyleName) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true')" />

  <!-- Use Multiline? -->
  <!--                -->
  <xsl:variable name="VarUseMultilineOption" select="$VarTableRule/wwproject:Options/wwproject:Option[@Name = 'table-rendering' and @Value = 'pipes-multiline']/@Value" />
  <xsl:variable name="VarUseMultiline" select="($VarUseMultilineOption = 'pipes-multiline')" />

  <xsl:if test="$VarUseStyleName or
                $VarUseMultiline">
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:text>&lt;!-- </xsl:text>

    <xsl:if test="$VarUseStyleName">
     <xsl:text>style:</xsl:text>
     <xsl:value-of select="$ParamStyleName" />
     <xsl:if test="$VarUseMultiline">
      <xsl:text>; </xsl:text>
     </xsl:if>
    </xsl:if>

    <xsl:if test="$VarUseMultiline">
     <xsl:text>multiline</xsl:text>
    </xsl:if>

    <xsl:text> --&gt;</xsl:text>
   </wwexsldoc:Text>
   <xsl:text>
</xsl:text>
  </xsl:if>

  <xsl:call-template name="Private-MdTableFromXMd">
   <xsl:with-param name="ParamTable" select="$VarXMarkdown" />
  </xsl:call-template>

  <xsl:text>
</xsl:text>
 </xsl:template>


 <xsl:template name="Private-MdStructurePrefix-Recurse">
  <xsl:param name="ParamElement" />
  <xsl:param name="ParamIsFirstLine" select="true()" />

  <xsl:if test="$ParamElement/parent::*">
   <xsl:call-template name="Private-MdStructurePrefix-Recurse">
    <xsl:with-param name="ParamElement" select="$ParamElement/parent::*" />
   </xsl:call-template>
  </xsl:if>

  <xsl:choose>
   <xsl:when test="$ParamIsFirstLine and
                   $ParamElement/parent::wwdoc:ListItem[@ordered='False'] and
                   (count($ParamElement/preceding-sibling::*) = 0)">
    <xsl:text>- </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   $ParamElement/parent::wwdoc:ListItem[@ordered='True'] and
                   (count($ParamElement/preceding-sibling::*) = 0)">
    <xsl:value-of select="number($ParamElement/parent::wwdoc:ListItem/@number)" />
    <xsl:text>. </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamElement/parent::wwdoc:ListItem[@ordered='False']">
    <xsl:text>  </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamElement/parent::wwdoc:ListItem[@ordered='True']">
    <xsl:choose>
     <xsl:when test="(number($ParamElement/parent::wwdocListItem/@number) - 999) &gt; 0">
      <xsl:text>      </xsl:text>
     </xsl:when>

     <xsl:when test="(number($ParamElement/parent::wwdocListItem/@number) - 99) &gt; 0">
      <xsl:text>     </xsl:text>
     </xsl:when>

     <xsl:when test="(number($ParamElement/parent::wwdocListItem/@number) - 9) &gt; 0">
      <xsl:text>    </xsl:text>
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>   </xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:when test="$ParamElement/parent::wwdoc:Block">
    <wwexsldoc:Text disable-output-escaping="yes">&gt; </wwexsldoc:Text>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdParaPrefixWithSyntax-MissingProperties">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamIsFirstLine" select="true()" />

  <xsl:variable name="VarPropertiesAsXML">
   <xsl:call-template name="Private-MdParaProperties">
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarProperties" select="msxsl:node-set($VarPropertiesAsXML)/wwproject:Property" />

  <xsl:call-template name="Private-MdParaPrefixWithSyntax">
   <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   <xsl:with-param name="ParamProperties" select="$VarProperties" />
   <xsl:with-param name="ParamIsFirstLine" select="ParamIsFirstLine" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Private-MdParaPrefixWithSyntax">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamIsFirstLine" select="true()" />

  <xsl:variable name="VarCurrentLevel" select="number($ParamProperties[@Name = 'indentation-level']/@Value)" />

  <xsl:call-template name="Private-PrecedingParaMdParaPrefix-Recurse">
   <xsl:with-param name="ParamCurrentParagraph" select="$ParamParagraph" />
   <xsl:with-param name="ParamCurrentLevel" select="$VarCurrentLevel" />
   <xsl:with-param name="ParamCurrentPrefix" select="string('')" />
   <xsl:with-param name="ParamIsFirstLine" select="false()" />
  </xsl:call-template>

  <xsl:call-template name="Private-MdParaSyntax">
   <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   <xsl:with-param name="ParamProperties" select="$ParamProperties" />
   <xsl:with-param name="ParamIsFirstLine" select="$ParamIsFirstLine" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Private-PrecedingParaMdParaPrefix-Recurse">
  <xsl:param name="ParamCurrentParagraph" />
  <xsl:param name="ParamCurrentLevel" />
  <xsl:param name="ParamCurrentPrefix" />
  <xsl:param name="ParamIsFirstLine" select="true()" />

  <xsl:variable name="VarPrecedingParagraph" select="$ParamCurrentParagraph/preceding-sibling::*[1]" />

  <xsl:choose>
   <xsl:when test="($ParamCurrentLevel &gt; 0) and (count($VarPrecedingParagraph) = 1)">
    <xsl:variable name="VarPrecedingPropertiesAsXML">
     <xsl:call-template name="Private-MdParaProperties">
      <xsl:with-param name="ParamParagraph" select="$VarPrecedingParagraph" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarPrecedingProperties" select="msxsl:node-set($VarPrecedingPropertiesAsXML)/wwproject:Property" />
    <xsl:variable name="VarPrecedingLevel" select="number($VarPrecedingProperties[@Name = 'indentation-level']/@Value)" />
    <xsl:variable name="VarPrecedingPrefix">
     <xsl:call-template name="Private-MdParaSyntax">
      <xsl:with-param name="ParamParagraph" select="$VarPrecedingParagraph" />
      <xsl:with-param name="ParamProperties" select="$VarPrecedingProperties" />
      <xsl:with-param name="ParamIsFirstLine" select="$ParamIsFirstLine" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
     <xsl:when test="$VarPrecedingLevel &lt; 1">
      <xsl:copy-of select="$VarPrecedingPrefix" />
      <xsl:copy-of select="$ParamCurrentPrefix" />
     </xsl:when>

     <xsl:when test="$VarPrecedingLevel &gt;= $ParamCurrentLevel">
      <xsl:call-template name="Private-PrecedingParaMdParaPrefix-Recurse">
       <xsl:with-param name="ParamCurrentParagraph" select="$VarPrecedingParagraph" />
       <xsl:with-param name="ParamCurrentLevel" select="$ParamCurrentLevel" />
       <xsl:with-param name="ParamCurrentPrefix" select="$ParamCurrentPrefix" />
       <xsl:with-param name="ParamIsFirstLine" select="false()" />
      </xsl:call-template>
     </xsl:when>

     <xsl:otherwise>
      <xsl:variable name="VarTotalPrefix">
       <xsl:copy-of select="$VarPrecedingPrefix" />
       <xsl:copy-of select="$ParamCurrentPrefix" />
      </xsl:variable>

      <xsl:call-template name="Private-PrecedingParaMdParaPrefix-Recurse">
       <xsl:with-param name="ParamCurrentParagraph" select="$VarPrecedingParagraph" />
       <xsl:with-param name="ParamCurrentLevel" select="$VarPrecedingLevel" />
       <xsl:with-param name="ParamCurrentPrefix" select="$VarTotalPrefix" />
       <xsl:with-param name="ParamIsFirstLine" select="false()" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <xsl:copy-of select="$ParamCurrentPrefix" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdParaSyntax">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamProperties" />
  <xsl:param name="ParamIsFirstLine" select="true()" />

  <xsl:variable name="VarSyntax" select="$ParamProperties[@Name = 'syntax']/@Value" />

  <xsl:choose>
   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'unordered-list')">
    <xsl:text>- </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'ordered-list')">
    <xsl:variable name="VarAutoNumberText">
     <xsl:call-template name="Markdown-ParaNumber">
      <xsl:with-param name="ParamNumber" select="$ParamParagraph/wwdoc:Number" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$VarAutoNumberText" />
   </xsl:when>

   <xsl:when test="$VarSyntax = 'unordered-list'">
    <xsl:text>  </xsl:text>
   </xsl:when>

   <xsl:when test="$VarSyntax = 'ordered-list'">
    <xsl:variable name="VarAutoNumberText">
     <xsl:call-template name="Markdown-ParaNumber">
      <xsl:with-param name="ParamNumber" select="$ParamParagraph/wwdoc:Number" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="wwutil:CreateIndentationString(string-length($VarAutoNumberText))" />
   </xsl:when>

   <xsl:when test="$VarSyntax = 'blockquote'">
    <wwexsldoc:Text disable-output-escaping="yes">&gt; </wwexsldoc:Text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-1')">
    <xsl:text># </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-2')">
    <xsl:text>## </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-3')">
    <xsl:text>### </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-4')">
    <xsl:text>#### </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-5')">
    <xsl:text>##### </xsl:text>
   </xsl:when>

   <xsl:when test="$ParamIsFirstLine and
                   ($VarSyntax = 'heading-6')">
    <xsl:text>###### </xsl:text>
   </xsl:when>

  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdSyntaxTranslate">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarSyntaxProperty" select="$ParamProperties[@Name = 'syntax']" />

  <xsl:choose>
   <xsl:when test="
    (string-length($VarSyntaxProperty/@Name) = 0) or
    (string-length($VarSyntaxProperty/@Value) = 0) or
    starts-with($VarSyntaxProperty/@Value, '&lt;')
   ">
    <xsl:text>auto-detect</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$VarSyntaxProperty/@Value" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdIndentationLevelTranslate">
  <xsl:param name="ParamProperties" />

  <xsl:variable name="VarIndentationLevelProperty" select="$ParamProperties[@Name = 'indentation-level']" />

  <xsl:choose>
   <xsl:when test="
    (string-length($VarIndentationLevelProperty/@Name) = 0) or
    (string-length($VarIndentationLevelProperty/@Value) = 0)
   ">
    <xsl:text>0</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$VarIndentationLevelProperty/@Value" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdTitleUnderline">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamReplacementString" />
  <xsl:param name="ParamPrefix" />

  <xsl:variable name="VarContentString">
   <xsl:for-each select="$ParamContent">
    <xsl:value-of select="." />
   </xsl:for-each>
  </xsl:variable>

  <!-- Markup starts on next line -->
  <xsl:text>
</xsl:text>

  <!-- Expand to the length of the content -->
  <xsl:copy-of select="$ParamPrefix" />
  <xsl:value-of select="wwutil:CreateUniformString($VarContentString, $ParamReplacementString)"/>
 </xsl:template>


 <xsl:template name="Private-MdPlusParaTag-StyleOnly">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamPrefix" />
  <xsl:param name="ParamNextLinePrefix" />

  <!-- Use StyleName? -->
  <!--                -->
  <xsl:variable name="VarStyleName">
   <!-- StyleName will be empty if it is a default markdown style. -->
   <!--                                                            -->
   <xsl:for-each select="$GlobalDefaultParagraphStyles">
    <xsl:variable name="VarStyle" select="key('wwmddefaults-paragraph-styles-by-name', $ParamParagraph/@stylename)" />
    <xsl:if test="count($VarStyle) = 0">
     <xsl:value-of select="$ParamParagraph/@stylename" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarUseStyleNameOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
  <xsl:variable name="VarUseStyleName" select="(string-length($VarStyleName) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true')" />

  <xsl:if test="$VarUseStyleName">
   <!-- Apply existing prefix -->
   <!--                       -->
   <xsl:if test="string-length($ParamPrefix) &gt; 0">
    <xsl:copy-of select="$ParamPrefix" />
   </xsl:if>
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:text>&lt;!-- </xsl:text>

    <xsl:if test="$VarUseStyleName">
     <xsl:text>style:</xsl:text>
     <xsl:value-of select="$VarStyleName" />
    </xsl:if>
    <xsl:text> --&gt;
</xsl:text>
   </wwexsldoc:Text>

   <!-- Apply prefix for next line -->
   <!--                            -->
   <xsl:if test="string-length($ParamNextLinePrefix) &gt; 0">
    <xsl:copy-of select="$ParamNextLinePrefix" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Private-MdPlusParaTag">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamParagraphBehavior" />
  <xsl:param name="ParamPrefix" />
  <xsl:param name="ParamNextLinePrefix" />
  <xsl:param name="ParamSuppressStyleName" select="false()" />

  <!-- Use StyleName? -->
  <!--                -->
  <xsl:variable name="VarParaStyleName">
   <xsl:for-each select="$GlobalDefaultParagraphStyles">
    <xsl:variable name="VarStyle" select="key('wwmddefaults-paragraph-styles-by-name', $ParamParagraph/@stylename)" />
    <xsl:if test="count($VarStyle) = 0">
     <xsl:value-of select="$ParamParagraph/@stylename" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarStyleName">
   <!-- StyleName will be empty if it is a default markdown style. -->
   <!--                                                            -->

   <xsl:if test ="string-length($VarParaStyleName) &gt; 0">
    <!-- Account for nested style name and search for matching default stylename at end -->
    <!--                                                                                -->
    <!-- TODO: Markdown adapter needs to store non-hierarchical style name to improve roundtripping. -->
    <xsl:variable name="VarEndsWithDefaultStyle">
     <xsl:for-each select="$GlobalDefaultParagraphStyles//wwmddefaults:ParagraphStyle">
      <xsl:variable name="VarDefaultStyleToTry" select="./@name" />

      <xsl:if test="wwstring:EndsWith($ParamParagraph/@stylename, $VarDefaultStyleToTry)">
       <xsl:text>true</xsl:text>
      </xsl:if>
     </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$VarEndsWithDefaultStyle != 'true'">
     <xsl:value-of select="$ParamParagraph/@stylename" />
    </xsl:if>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarUseStyleNameOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
  <xsl:variable name="VarUseStyleName" select="(string-length($VarStyleName) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true') and
                                               ($ParamSuppressStyleName = false())" />

  <!-- Use Markers? -->
  <!--              -->
  <xsl:variable name="VarMarkers">
   <xsl:call-template name="Private-MdPlusMarkers">
    <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarUseMarkersOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-markers']/@Value" />
  <xsl:variable name="VarUseMarkers" select="(string-length($VarMarkers) &gt; 0) and
                                             ($VarUseMarkersOption = 'true')" />

  <!-- Use Anchor? -->
  <!--             -->
  <xsl:variable name="VarAnchor" select="$ParamParagraph/@id" />
  <xsl:variable name="VarUseAnchorOption" select="$ParamRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-anchor']/@Value" />
  <xsl:variable name="VarUseAnchor" select="(string-length($VarAnchor) &gt; 0) and
                                            ($VarUseAnchorOption = 'true')" />

  <xsl:if test="$VarUseStyleName or
                $VarUseMarkers or
                $VarUseAnchor">
   <!-- Apply prefix -->
   <!--              -->
   <xsl:if test="string-length($ParamPrefix) &gt; 0">
    <xsl:copy-of select="$ParamPrefix" />
   </xsl:if>

   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:text>&lt;!-- </xsl:text>

    <xsl:if test="$VarUseStyleName">
     <xsl:text>style:</xsl:text>
     <xsl:value-of select="$VarStyleName" />
     <xsl:if test="$VarUseMarkers or $VarUseAnchor">
      <xsl:text>; </xsl:text>
     </xsl:if>
    </xsl:if>

    <xsl:if test="$VarUseMarkers">
     <xsl:value-of select="$VarMarkers" />
     <xsl:if test="$VarUseAnchor">
      <xsl:text>; </xsl:text>
     </xsl:if>
    </xsl:if>

    <xsl:if test="$VarUseAnchor">
     <xsl:text>#</xsl:text>
     <xsl:value-of select="$VarAnchor" />
    </xsl:if>

    <xsl:text> --&gt;
</xsl:text>
   </wwexsldoc:Text>

   <!-- Apply prefix for next line -->
   <!--                            -->
   <xsl:if test="string-length($ParamNextLinePrefix) &gt; 0">
    <xsl:copy-of select="$ParamNextLinePrefix" />
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Private-MdParaProperties">
  <xsl:param name="ParamParagraph" />

  <xsl:variable name="VarRule" select="wwprojext:GetRule('paragraph', $ParamParagraph/@stylename)" />
  <xsl:variable name="VarPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
     <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$ParamParagraph/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarProperties" select="msxsl:node-set($VarPropertiesAsXML)/wwproject:Property" />

  <xsl:call-template name="Markdown-TranslateParagraphStyleProperties">
   <xsl:with-param name="ParamProperties" select="$VarProperties" />
   <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Private-ParaLineBreak">
  <xsl:param name="ParamLineBreak" />
  <xsl:param name="ParamPrefix" />

  <xsl:text>
</xsl:text>

  <xsl:if test="$ParamLineBreak/following-sibling::*[1][self::wwdoc:Text]" >
   <xsl:copy-of select="$ParamPrefix" />
  </xsl:if>

 </xsl:template>

<xsl:template name="Private-IndexMarkerCompoundEntry-Recurse">
 <xsl:param name="ParamEntry" />

 <xsl:variable name="VarEntryPart" select="$ParamEntry/wwdoc:Content/wwdoc:TextRun/wwdoc:Text[1]" />

 <xsl:value-of select="$VarEntryPart/@value"/>

 <xsl:for-each select="$ParamEntry/wwdoc:Entry">
  <xsl:text>:</xsl:text>

  <xsl:call-template name="Private-IndexMarkerCompoundEntry-Recurse">
   <xsl:with-param name="ParamEntry" select="." />
  </xsl:call-template>
 </xsl:for-each>
</xsl:template>


 <xsl:template name="Private-MdPlusMarkers">
  <xsl:param name="ParamParagraphBehavior" />
  <xsl:param name="ParamParagraph" />

  <xsl:variable name="VarMarkersAsXML">
   <!-- Collect IndexMakers and put into one IndexMarker -->
   <!--                                                  -->
   <xsl:variable name="VarEntriesString">
    <xsl:for-each select="$ParamParagraph/wwdoc:TextRun/wwdoc:IndexMarker/wwdoc:Entry">
     <xsl:variable name="VarEntryCompoundValue">
      <xsl:call-template name="Private-IndexMarkerCompoundEntry-Recurse">
       <xsl:with-param name="ParamEntry" select="." />
      </xsl:call-template>
     </xsl:variable>

     <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
     </xsl:if>

     <xsl:value-of select="$VarEntryCompoundValue" />
    </xsl:for-each>
   </xsl:variable>

   <xsl:if test="string-length($VarEntriesString) &gt; 0">
    <Marker name="IndexMarker" value="{$VarEntriesString}" />
   </xsl:if>


   <!-- Collect all other markers other than 'pass-through' -->
   <!--                                                     -->
   <xsl:variable name="VarMarkerBehaviors" select="$ParamParagraphBehavior/wwbehaviors:Marker[@behavior != 'pass-through']" />
   <xsl:for-each select="$VarMarkerBehaviors/wwdoc:Marker">
    <xsl:variable name="VarMarkerName" select="../@behavior" />
    <xsl:variable name="VarMarkerValue" select="./wwdoc:TextRun/wwdoc:Text/@value" />
    <Marker name="{$VarMarkerName}" value="{$VarMarkerValue}" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarMarkers" select="msxsl:node-set($VarMarkersAsXML)" />

  <!-- Emit all markers -->
  <!--                  -->
  <xsl:choose>
   <xsl:when test="count($VarMarkers/Marker) = 1">
    <xsl:variable name="VarMarkerName" select="$VarMarkers/Marker[1]/@name" />
    <xsl:variable name="VarMarkerValue" select="$VarMarkers/Marker[1]/@value" />

    <xsl:text>marker:</xsl:text>
    <xsl:value-of select="$VarMarkerName"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="$VarMarkerValue"/>
    <xsl:text>"</xsl:text>
   </xsl:when>

   <xsl:when test="count($VarMarkers/Marker) &gt; 1">
    <xsl:text>markers:{</xsl:text>

    <xsl:for-each select="$VarMarkers/Marker">
     <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
     </xsl:if>

     <xsl:text>"</xsl:text>
     <xsl:value-of select="./@name" />
     <xsl:text>":"</xsl:text>
     <xsl:value-of select="./@value" />
     <xsl:text>"</xsl:text>
    </xsl:for-each>

    <xsl:text>}</xsl:text>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Private-MdPlusTextRunTag">
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />

  <!-- Use StyleName? -->
  <!--                -->
  <xsl:variable name="VarStyleName">
   <xsl:for-each select="$GlobalDefaultCharacterStyles">
    <xsl:variable name="VarStyle" select="key('wwmddefaults-character-styles-by-name', $ParamStyleName)" />
    <xsl:if test="count($VarStyle) = 0">
     <xsl:value-of select="$ParamStyleName" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarUseStyleNameOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
  <xsl:variable name="VarUseStyleName" select="(string-length($VarStyleName) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true')" />

  <xsl:if test="$VarUseStyleName">
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:text>&lt;!-- style:</xsl:text>
    <xsl:value-of select="$VarStyleName" />
    <xsl:text> --&gt;</xsl:text>
   </wwexsldoc:Text>
  </xsl:if>

 </xsl:template>

 <xsl:template name="Private-MdTableFromXMd">
  <xsl:param name="ParamTable" />

  <xsl:for-each select="$ParamTable//wwdoc:TableHeaderRow | $ParamTable//wwdoc:TableDivider | $ParamTable//wwdoc:TableRow | $ParamTable//wwdoc:TableTerminationRow">
   <xsl:for-each select="wwdoc:TableCell | wwdoc:TableCellDel">
    <xsl:apply-templates mode="wwmode:cell" />
   </xsl:for-each>
   <xsl:text>
</xsl:text>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwexsldoc:Text" mode="wwmode:cell">
  <xsl:copy-of select="." />
 </xsl:template>


 <!-- Escape Markdown text() -->
 <!--                        -->
 <xsl:template match="*[(local-name() != Text) or
                        (local-name() != DisableMDEscape) or
                        (local-name() != MDSyntax)]" mode="wwmode:escape-markdown">
  <xsl:copy-of select="." />

  <xsl:apply-templates mode="wwmode:escape-markdown" />
 </xsl:template>

   <!-- bypass escaping (pass-through) for certain elements -->
   <!--                                                     -->
 <xsl:template match="wwdoc:DisableMDEscape | wwdoc:MDSyntax" mode="wwmode:escape-markdown">
  <xsl:apply-templates mode="wwmode:escaped-markdown-pass-through" />
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:escape-markdown">
  <xsl:copy>
   <xsl:attribute name="value">
   <xsl:value-of select="wwutil:CreateEscapedMarkdownString(.)" />
  </xsl:attribute>

  <xsl:apply-templates select="@*" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text()" mode="wwmode:escape-markdown">
  <xsl:value-of select="wwutil:CreateEscapedMarkdownString(.)" />
 </xsl:template>

 <xsl:template match="wwexsldoc:Text" mode="wwmode:escape-markdown">
  <xsl:copy-of select="." />
 </xsl:template>


 <!-- Pass through text() -->
 <!--                     -->
 <xsl:template match="*" mode="wwmode:escaped-markdown-pass-through">
  <xsl:apply-templates mode="wwmode:escaped-markdown-pass-through" />
 </xsl:template>

 <xsl:template match="text()" mode="wwmode:escaped-markdown-pass-through">
  <xsl:value-of select="." />
 </xsl:template>


 <!-- Paragraph code-fence: process Text and LineBreak elements -->
 <!--                                                           -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:paragraph-code-fence">
  <xsl:param name="ParamPrefix" />

  <xsl:apply-templates mode="wwmode:paragraph-code-fence">
   <xsl:with-param name="ParamPrefix" select="$ParamPrefix" />
 </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:paragraph-code-fence">
  <xsl:param name="ParamPrefix" />
  <xsl:value-of select="@value" />
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:paragraph-code-fence">
  <xsl:param name="ParamPrefix" />

  <xsl:call-template name="Private-ParaLineBreak">
   <xsl:with-param name="ParamLineBreak" select="." />
   <xsl:with-param name="ParamPrefix" select="$ParamPrefix" />
  </xsl:call-template>
 </xsl:template>

 <xsl:template match="text()" mode="wwmode:paragraph-code-fence">
  <!-- suppress output -->
 </xsl:template>

 <msxsl:script language="c#" implements-prefix="wwutil">
  <msxsl:using namespace="System.Text" />
  <msxsl:using namespace="System.Collections.Generic" />
  <![CDATA[
    XmlNamespaceManager mNamespaceManager = null;

    private XmlNamespaceManager NamespaceManager
    {
      get
      {
        if (this.mNamespaceManager == null)
        {
          this.mNamespaceManager = new XmlNamespaceManager(new NameTable());
          this.mNamespaceManager.AddNamespace("wwdoc", "urn:WebWorks-Document-Schema");
          this.mNamespaceManager.AddNamespace("wwexsldoc", "urn:WebWorks-XSLT-Extension-Document");
        }

        return this.mNamespaceManager;
      }
    }

   public string CreateUniformString(string input, string character)
   {
     if (input == null || character == null || character.Length != 1)
     {
       throw new ArgumentException("Invalid input or character for creating markdown title syntax.");
     }

     return new string(character[0], input.Length);
   }

   public string CreateIndentationString(int numCharacters)
   {
     if (numCharacters < 0)
     {
       return String.Empty;
     }

     return new string(' ', numCharacters);
   }

   private StringBuilder mBuffer = new StringBuilder();

   public string CreateEscapedMarkdownString(string input)
   {
     // Escape markdown syntactical characters,
     // excluding HTML characters such as '<' or '>', which or better handled using HTML entities.
     //
     StringBuilder escapedString;
     char[] specialChars = { '#', '*', '_', '[', ']', '`', '|', '~', '\\' };
     // Not escaping: '!', '(', ')', '+', '-', '.'

     escapedString = this.mBuffer;
     escapedString.Length = 0;

     foreach (char c in input)
     {
         if (Array.Exists(specialChars, specialChar => specialChar == c))
         {
             escapedString.Append('\\');
         }
         escapedString.Append(c);
     }

     return escapedString.ToString();
   }

    public enum MarkdownTableMode
    {
      Pipes,
      PipesMultiline
    }
    
    public MarkdownTableMode ParseMarkdownTableMode(string mode)
    {
      // Normalize the input by removing hyphens and converting to lowercase for case-insensitive matching
      string normalizedMode = mode.Replace("-", "").ToLower();
    
      if (normalizedMode == "pipes")
      {
         return MarkdownTableMode.Pipes;
      }
      else if (normalizedMode == "pipesmultiline")
      {
        return MarkdownTableMode.PipesMultiline;
      }
      else
      {
         throw new ArgumentException("Invalid table mode specified");
      }
    }

    public XPathNodeIterator ConvertHtmlToXMarkdown(XPathNavigator navigator, string tableFormat)
    {
        MarkdownTableMode mode = ParseMarkdownTableMode(tableFormat);
        XmlDocument resultDoc = new XmlDocument();
        XmlElement root = resultDoc.CreateElement("root");
        resultDoc.AppendChild(root);

        var rowspanMap = new Dictionary<int, int>();
        List<int> columnLengths = CalculateColumnLengths(navigator, mode);

        // Determine if headers are present
        XPathNodeIterator headerIterator = navigator.Select("//table/tr[1]/th");
        XPathNodeIterator bodyIterator = navigator.Select(headerIterator.Count > 0 ? "//table/tr[position()>1]" : "//table/tr");

        ProcessHeader(resultDoc, root, headerIterator, columnLengths, rowspanMap, mode);
        AppendDividerRow(resultDoc, root, columnLengths, mode);
        ProcessBody(resultDoc, root, bodyIterator, columnLengths, rowspanMap, mode);

        return resultDoc.CreateNavigator().Select("//root/*");
    }

    private bool ProcessHeader(XmlDocument doc, XmlElement root, XPathNodeIterator iterator, List<int> columnLengths, Dictionary<int, int> rowspanMap, MarkdownTableMode mode)
    {
        if (iterator.Count == 0)
        {
            // If no header elements, append an empty header row based on the mode
            AppendEmptyHeaderRow(doc, root, columnLengths, mode);
            return false;
        }
        else
        {
            switch (mode)
            {
                case MarkdownTableMode.Pipes:
                    ProcessRowPipes(doc, root, iterator, true, rowspanMap, 1, columnLengths);
                    break;
                    
                case MarkdownTableMode.PipesMultiline:
                    ProcessRowPipesMultiline(doc, root, iterator, true, rowspanMap, 1, columnLengths);
                    break;
                    
                default:
                    throw new ArgumentOutOfRangeException("mode", string.Format("Unsupported table mode: {0}", mode));
            }
            return true;
        }
    }


    private bool ProcessBody(XmlDocument doc, XmlElement root, XPathNodeIterator iterator, List<int> columnLengths, Dictionary<int, int> rowspanMap, MarkdownTableMode mode)
    {
        if (iterator.Count == 0)
        {
            // If no body elements, append an empty body row based on the mode
            AppendEmptyBodyRow(doc, root, columnLengths, mode);
            return false;
        }
        else
        {
            ProcessRows(doc, root, iterator, columnLengths, rowspanMap, mode);
            return true;
        }
    }

    private void AppendDividerRow(XmlDocument doc, XmlElement root, List<int> columnLengths, MarkdownTableMode mode)
    {
        XmlElement rowElement = doc.CreateElement("wwdoc:TableDivider", "urn:WebWorks-Document-Schema");

        AppendDelimiterNode(doc, rowElement, "|");

        for (int i = 0; i < columnLengths.Count; i++)
        {
            // Create the divider content with dashes, padded on both sides
            string dividerContent = new string('-', columnLengths[i])
                                        .PadLeft(columnLengths[i] + 1) // Pad left with one space
                                        .PadRight(columnLengths[i] + 2); // Pad right with one space (+2 accounts for the initial pad)

            CreateAndAppendCell(doc, rowElement, dividerContent);

            AppendDelimiterNode(doc, rowElement, "|");
        }

        root.AppendChild(rowElement);
    }

    private void AppendEmptyHeaderRow(XmlDocument doc, XmlElement root, List<int> columnLengths, MarkdownTableMode mode)
    {
        XmlElement rowElement = doc.CreateElement("wwdoc:TableHeaderRow", "urn:WebWorks-Document-Schema");

        AppendDelimiterNode(doc, rowElement, "|");

        for (int i = 0; i < columnLengths.Count; i++)
        {
            // Create an empty header cell with padding based on the column length
            string headerContent = new string(' ', columnLengths[i] + 2);

            CreateAndAppendCell(doc, rowElement, headerContent);

            AppendDelimiterNode(doc, rowElement, "|");
        }

        root.AppendChild(rowElement);
    }

    private void AppendEmptyBodyRow(XmlDocument doc, XmlElement root, List<int> columnLengths, MarkdownTableMode mode)
    {
        XmlElement rowElement = doc.CreateElement("wwdoc:TableRow", "urn:WebWorks-Document-Schema");

        AppendDelimiterNode(doc, rowElement, "|");

        for (int i = 0; i < columnLengths.Count; i++)
        {
            // Create an empty body cell with padding based on the column length
            string bodyContent = new string(' ', columnLengths[i] + 2);

            CreateAndAppendCell(doc, rowElement, bodyContent);

            AppendDelimiterNode(doc, rowElement, "|");
        }

        root.AppendChild(rowElement);
    }

    private void AppendTerminationRow(XmlDocument doc, XmlElement root, List<int> columnLengths)
    {
        XmlElement terminationRowElement = doc.CreateElement("wwdoc:TableTerminationRow", "urn:WebWorks-Document-Schema");
    
        AppendDelimiterNode(doc, terminationRowElement, "|");
    
        for (int i = 0; i < columnLengths.Count; i++)
        {
            // Create the termination content with padding based on the column length
            string terminationContent = new string(' ', columnLengths[i] + 2);
    
            CreateAndAppendCell(doc, terminationRowElement, terminationContent);
    
            AppendDelimiterNode(doc, terminationRowElement, "|");
        }

        root.AppendChild(terminationRowElement);
    }

    private void ProcessRows(XmlDocument doc, XmlElement root, XPathNodeIterator iterator, List<int> columnLengths, Dictionary<int, int> rowspanMap, MarkdownTableMode mode)
    {
        int rowIndex = 1;
    
        while (iterator.MoveNext())
        {
            XPathNodeIterator cellIterator = iterator.Current.Select("td");
    
            // Use a switch statement to select the appropriate row processing function based on the mode
            switch (mode)
            {
                case MarkdownTableMode.Pipes:
                    ProcessRowPipes(doc, root, cellIterator, false, rowspanMap, rowIndex++, columnLengths);
                    break;
                    
                case MarkdownTableMode.PipesMultiline:
                    ProcessRowPipesMultiline(doc, root, cellIterator, false, rowspanMap, rowIndex++, columnLengths);

                    AppendTerminationRow(doc, root, columnLengths);
                    break;
                    
                default:
                    throw new ArgumentOutOfRangeException("mode", string.Format("Unsupported table mode: {0}", mode));
            }
        }
    }

    private List<int> CalculateColumnLengths(XPathNavigator navigator, MarkdownTableMode mode)
    {
        switch (mode)
        {
            case MarkdownTableMode.Pipes:
                return CalculateColumnLengthsPipes(navigator);
    
            case MarkdownTableMode.PipesMultiline:
                return CalculateColumnLengthsPipesMultiline(navigator);
    
            default:
                throw new ArgumentOutOfRangeException("mode", string.Format("Unsupported table mode: {0}", mode));
        }
    }

    private List<int> CalculateColumnLengthsPipes(XPathNavigator navigator)
    {
        List<int> columnLengths = new List<int>();
        XPathNodeIterator rowIterator = navigator.Select("//table/tr");
    
        while (rowIterator.MoveNext())
        {
            XPathNodeIterator cellIterator = rowIterator.Current.Select("th | td");
            int columnIndex = 0;
    
            while (cellIterator.MoveNext())
            {
                string cellValue = PreprocessCellValue(cellIterator.Current.Value, MarkdownTableMode.Pipes);
                
                // Count total newlines in cell and 4 per newline to cellLength
                //
                int newLinesCount = cellValue.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None).Length - 1;
                int cellLength = cellValue.Length + newLinesCount*4;
    
                if (columnIndex >= columnLengths.Count)
                {
                    columnLengths.Add(cellLength);
                }
                else
                {
                    columnLengths[columnIndex] = Math.Max(columnLengths[columnIndex], cellLength);
                }
    
                int colspan = GetAttributeAsInt(cellIterator.Current, "colspan", defaultValue: 1);
                columnIndex += colspan;
            }
        }
    
        for (int i = 0; i < columnLengths.Count; i++)
        {
            columnLengths[i] = Math.Max(columnLengths[i], 4);
        }
    
        return columnLengths;
    }
    
    private List<int> CalculateColumnLengthsPipesMultiline(XPathNavigator navigator)
    {
        List<int> columnLengths = new List<int>();
        XPathNodeIterator rowIterator = navigator.Select("//table/tr");
    
        while (rowIterator.MoveNext())
        {
            XPathNodeIterator cellIterator = rowIterator.Current.Select("th | td");
            int columnIndex = 0;
    
            while (cellIterator.MoveNext())
            {
                string cellValue = PreprocessCellValue(cellIterator.Current.Value, MarkdownTableMode.PipesMultiline);
    
                // Split cell value into lines and manually find the maximum line length
                var lines = cellValue.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
                int maxLineLength = 0;
                foreach (var line in lines)
                {
                    maxLineLength = Math.Max(maxLineLength, line.Length);
                }
    
                // Update or add the column length based on the maximum line length
                if (columnIndex >= columnLengths.Count)
                {
                    columnLengths.Add(maxLineLength);
                }
                else
                {
                    columnLengths[columnIndex] = Math.Max(columnLengths[columnIndex], maxLineLength);
                }
    
                // Move columnIndex forward by the colspan amount
                int colspan = GetAttributeAsInt(cellIterator.Current, "colspan", defaultValue: 1);
                columnIndex += colspan;
            }
        }
    
        // Ensure each column has a minimum width of 4 characters
        for (int i = 0; i < columnLengths.Count; i++)
        {
            columnLengths[i] = Math.Max(columnLengths[i], 4);
        }
    
        return columnLengths;
    }

    private int CalculateRowMaxHeight(XPathNodeIterator cellIterator)
    {
        // Clone the iterator to prevent advancing the original position
        XPathNodeIterator clonedIterator = cellIterator.Clone();
    
        // Assume MarkdownTableMode: PipesMultiline
        int maxHeight = 1;
    
        while (clonedIterator.MoveNext())
        {
            string cellValue = PreprocessCellValue(clonedIterator.Current.Value, MarkdownTableMode.PipesMultiline);
    
            // Calculate the height of each cell by counting its lines
            int cellHeight = cellValue.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None).Length;
    
            // Update maxHeight if this cell's line count is greater
            maxHeight = Math.Max(maxHeight, cellHeight);
        }
    
        return maxHeight;
    }

    private void ProcessRowPipes(XmlDocument doc, XmlElement root, XPathNodeIterator cellIterator, bool isHeader, Dictionary<int, int> rowspanMap, int currentRow, List<int> columnLengths)
    {
        XmlElement rowElement = doc.CreateElement(isHeader ? "wwdoc:TableHeaderRow" : "wwdoc:TableRow", "urn:WebWorks-Document-Schema");
    
        int columnIndex = 0;
        AppendDelimiterNode(doc, rowElement, "|");
    
        // Handle any cells in the current row affected by rowspan from previous rows
        HandleRowspanMap(doc, rowElement, rowspanMap, ref columnIndex, currentRow, columnLengths);
    
        // Iterate over each cell in the row
        while (cellIterator.MoveNext())
        {
            string cellValue = PreprocessCellValue(cellIterator.Current.Value, MarkdownTableMode.Pipes);
            int colspan = GetAttributeAsInt(cellIterator.Current, "colspan", defaultValue: 1);
            int rowspan = GetAttributeAsInt(cellIterator.Current, "rowspan", defaultValue: 1);
    
            // Process cell content as a single cell with <br/> breaks for each line
            AppendProcessedCellPipes(doc, rowElement, cellValue, columnIndex, columnLengths);
    
            // Adjust columnIndex for colspan, and add empty cells if needed
            columnIndex += colspan;
            for (int i = 1; i < colspan; i++)
            {
                AppendDelimiterNode(doc, rowElement, "|");
                AppendEmptyCellNode(doc, rowElement, columnIndex - colspan + i, columnLengths);
            }
    
            // Manage rowspan by updating rowspanMap if the cell spans multiple rows
            if (rowspan > 1)
            {
                UpdateRowspanMap(rowspanMap, currentRow, rowspan, colspan);
            }
    
            // Append a delimiter after each cell or empty cell in the row
            AppendDelimiterNode(doc, rowElement, "|");
        }
    
        // Append the completed row to the root element
        root.AppendChild(rowElement);
    }

    private void ProcessRowPipesMultiline(XmlDocument doc, XmlElement root, XPathNodeIterator cellIterator, bool isHeader, Dictionary<int, int> rowspanMap, int currentRow, List<int> columnLengths)
    {
        // Calculate maxHeight for all cells in this row
        int maxHeight = CalculateRowMaxHeight(cellIterator);
    
        // Use columnLengths.Count as the required column count for each row
        int targetColumnIndex = columnLengths.Count;
    
        // Initialize a list to store each cell’s lines
        List<List<string>> rowLines = new List<List<string>>();
        List<int> colspans = new List<int>(); // Track colspan for each cell in the row
    
        // Gather lines for each cell and handle colspan and rowspan
        int columnIndex = 0;
        while (cellIterator.MoveNext())
        {
            string cellValue = PreprocessCellValue(cellIterator.Current.Value, MarkdownTableMode.PipesMultiline);
            int colspan = GetAttributeAsInt(cellIterator.Current, "colspan", defaultValue: 1);
            int rowspan = GetAttributeAsInt(cellIterator.Current, "rowspan", defaultValue: 1);
    
            // Split cell value by lines and add to the cell’s list of lines
            List<string> cellLines = new List<string>(cellValue.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None));
    
            // Pad the cell’s lines with empty strings until it reaches maxHeight
            while (cellLines.Count < maxHeight)
            {
                cellLines.Add("");  // Empty line for padding
            }
    
            rowLines.Add(cellLines);
            colspans.Add(colspan);
    
            // Track rowspan in the rowspanMap for future rows
            if (rowspan > 1)
            {
                UpdateRowspanMap(rowspanMap, currentRow, rowspan, colspan);
            }
    
            // Advance the columnIndex by colspan
            columnIndex += colspan;
        }
    
        // Emit each row of virtual cells, iterating line-by-line
        for (int lineIndex = 0; lineIndex < maxHeight; lineIndex++)
        {
            XmlElement rowElement = doc.CreateElement("wwdoc:TableRow", "urn:WebWorks-Document-Schema");
    
            columnIndex = 0;
            for (int cellIndex = 0; cellIndex < rowLines.Count; cellIndex++)
            {
                // Handle any placeholders for rowspans affecting this row
                if (rowspanMap.ContainsKey(columnIndex) && rowspanMap[columnIndex] > currentRow)
                {
                    AppendDelimiterNode(doc, rowElement, "|");
                    AppendEmptyCellNode(doc, rowElement, columnIndex, columnLengths);
                    columnIndex++;
                    continue;
                }
    
                // Add a delimiter before the cell
                AppendDelimiterNode(doc, rowElement, "|");
    
                // Get the content for this cell line
                string lineContent = rowLines[cellIndex][lineIndex];
                AppendProcessedCellPipesMultiline(doc, rowElement, lineContent, columnIndex, columnLengths);
    
                // Apply colspan by adding empty cells after the main cell
                int colspan = colspans[cellIndex];
                for (int i = 1; i < colspan; i++)
                {
                    AppendDelimiterNode(doc, rowElement, "|");
                    AppendEmptyCellNode(doc, rowElement, columnIndex + i, columnLengths);
                }
    
                // Update columnIndex based on colspan
                columnIndex += colspan;
            }
    
            // Add a final delimiter for the completed TableRow
            AppendDelimiterNode(doc, rowElement, "|");
    
            // Append the completed TableRow for this line to root
            root.AppendChild(rowElement);
        }
    }

    private void HandleRowspanMap(XmlDocument doc, XmlElement rowElement, Dictionary<int, int> rowspanMap, ref int columnIndex, int currentRow, List<int> columnLengths)
    {
        // Check if there are any pending rowspans affecting the current row
        if (rowspanMap.ContainsKey(currentRow))
        {
            int remainingRowspan = rowspanMap[currentRow];
    
            // Insert placeholder cells for each column spanned by rowspan
            for (int i = 0; i < remainingRowspan; i++)
            {
                // Create an empty cell for rowspan continuation
                AppendEmptyCellNode(doc, rowElement, columnIndex, columnLengths);
    
                // Add delimiter after the empty cell
                AppendDelimiterNode(doc, rowElement, "|");
                columnIndex++;
            }
    
            // Remove the current row from rowspanMap once processed
            rowspanMap.Remove(currentRow);
        }
    }

    private void UpdateRowspanMap(Dictionary<int, int> rowspanMap, int currentRow, int rowspan, int colspan)
    {
        for (int i = 1; i < rowspan; i++)
        {
            int nextRow = currentRow + i;
            if (!rowspanMap.ContainsKey(nextRow))
            {
                rowspanMap[nextRow] = 0;
            }
            rowspanMap[nextRow] += colspan;
        }
    }

    private int GetAttributeAsInt(XPathNavigator node, string attributeName, int defaultValue)
    {
        string attributeValue = node.GetAttribute(attributeName, "");
        int result;
        return int.TryParse(attributeValue, out result) ? result : defaultValue;
    }

    private void CreateAndAppendCell(XmlDocument doc, XmlElement parent, string innerText)
    {
        XmlElement cellElement = doc.CreateElement("wwdoc:TableCell", "urn:WebWorks-Document-Schema");
        cellElement.InnerText = innerText;
        parent.AppendChild(cellElement);
    }

    private void AppendProcessedCellPipes(XmlDocument doc, XmlElement parent, string cellValue, int columnIndex, List<int> columnLengths)
    {
        // Combine all lines into one string with <br/> for line breaks
        var lines = cellValue.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
        StringBuilder combinedValue = new StringBuilder();

        for (int i = 0; i < lines.Length; i++)
        {
            combinedValue.Append(lines[i]);
            if (i < lines.Length - 1)
            {
                combinedValue.Append("<br/>");
            }
        }

        // Pad the combined value with a space on the left and adjust the right padding to length + 2
        string paddedValue = combinedValue.ToString().PadLeft(combinedValue.Length + 1).PadRight(columnLengths[columnIndex] + 2);

        // Create a single TableCell element
        XmlElement cellElement = doc.CreateElement("wwdoc:TableCell", "urn:WebWorks-Document-Schema");

        // Split the padded value at each occurrence of "<br/>"
        string[] parts = paddedValue.Split(new[] { "<br/>" }, StringSplitOptions.None);

        for (int i = 0; i < parts.Length; i++)
        {
        // Process each part to handle embedded HTML elements
        AppendProcessedPart(doc, cellElement, parts[i]);

            // If this isn't the last part, append a line break element
            if (i < parts.Length - 1)
            {
                AppendLineBreak(doc, cellElement);
            }
        }

        parent.AppendChild(cellElement);
    }

    private void AppendProcessedCellPipesMultiline(XmlDocument doc, XmlElement parent, string cellValue, int columnIndex, List<int> columnLengths)
    {
        // Pad the combined value with a space on the left and adjust the right padding to length + 2
        string paddedValue = cellValue.PadLeft(cellValue.Length + 1).PadRight(columnLengths[columnIndex] + 2);

        // Create a single TableCell element
        XmlElement cellElement = doc.CreateElement("wwdoc:TableCell", "urn:WebWorks-Document-Schema");

        // Process each part to handle embedded HTML elements
        AppendProcessedPart(doc, cellElement, paddedValue);

        parent.AppendChild(cellElement);
    }

    private void AddPaddingCells(XmlDocument doc, XmlElement rowElement, ref int columnIndex, int targetColumnCount, List<int> columnLengths)
    {
        // Add empty cells until columnIndex reaches the targetColumnCount
        while (columnIndex < targetColumnCount)
        {
            AppendDelimiterNode(doc, rowElement, "|");  // Add delimiter before the empty cell
            AppendEmptyCellNode(doc, rowElement, columnIndex, columnLengths);
            columnIndex++;
        }
    }

    private void AppendProcessedPart(XmlDocument doc, XmlElement cellElement, string part)
    {
        // Regular expression to identify valid single HTML elements such as <br/>, <!-- -->, etc.
        var htmlElementPattern = @"<[^<&>]+?>";  // Match any sequence that starts with < and ends with >

        // Use Regex to match all segments including HTML elements and text
        var matches = System.Text.RegularExpressions.Regex.Matches(part, htmlElementPattern + "|[^<>&]+|.{1,4}?");

        foreach (System.Text.RegularExpressions.Match match in matches)
        {
            string segment = match.Value;

            if (System.Text.RegularExpressions.Regex.IsMatch(segment, htmlElementPattern))
            {
                // Use the helper function to wrap HTML elements
                cellElement.AppendChild(WrapHtmlElement(doc, segment));
            }
            else
            {
                // Add regular text content as a text node
                cellElement.AppendChild(doc.CreateTextNode(segment));
            }
        }
    }

    private string PreprocessCellValue(string cellValue, MarkdownTableMode mode)
    {
        string cleanedValue = cellValue;

        switch (mode)
        {
            case MarkdownTableMode.Pipes:
                cleanedValue = PreprocessCellValuePipes(cellValue);
                break;
                
            case MarkdownTableMode.PipesMultiline:
                cleanedValue = PreprocessCellValuePipesMultiline(cellValue);
                break;
                
            default:
                throw new ArgumentOutOfRangeException("mode", string.Format("Unsupported table mode: {0}", mode));
        }
        
        return cleanedValue;
    }

    private string CompressNewlines(string input)
    {
        // Replace multiple consecutive new lines with a single new line
        //
        return Regex.Replace(input, @"(\r\n|\r|\n){2,}", Environment.NewLine);
    }
    
    private string StripEmptyLines(string input)
    {
        // Strip white-space-only lines.
        //
        return Regex.Replace(input, @"[ ]*[\r\n]+", Environment.NewLine);
    }

    private string PreprocessCellValuePipes(string cellValue)
    {
        string cleanedValue = cellValue;
    
        // Replace tab characters with spaces
        cleanedValue = cleanedValue.Replace("\t", " ");
    
        // Remove trailing new lines
        cleanedValue = cleanedValue.TrimEnd('\r', '\n');

        // Apply compression of consecutive new lines
        cleanedValue = CompressNewlines(cleanedValue);
    
        // Return the processed cell value
        return cleanedValue;
    }

    private string PreprocessCellValuePipesMultiline(string cellValue)
    {
        string cleanedValue = cellValue;

        // Remove trailing new lines
        cleanedValue = cleanedValue.TrimEnd('\r', '\n');

        // Strip empty lines (only white space)
        cleanedValue = StripEmptyLines(cleanedValue);
        
        return cleanedValue;
    }

    private void AppendLineBreak(XmlDocument doc, XmlElement cellElement)
    {
        cellElement.AppendChild(WrapHtmlElement(doc, "<br/>"));
    }

    private void AppendDelimiterNode(XmlDocument doc, XmlElement parent, string delimiter)
    {
        XmlElement delimiterElement = doc.CreateElement("wwdoc:TableCellDel", "urn:WebWorks-Document-Schema");
        delimiterElement.InnerText = delimiter;
        parent.AppendChild(delimiterElement);
    }

    private void AppendEmptyCellNode(XmlDocument doc, XmlElement parent, int columnIndex, List<int> columnLengths)
    {
        XmlElement emptyCellElement = doc.CreateElement("wwdoc:TableCell", "urn:WebWorks-Document-Schema");

        // Pad with a space on the left and adjust the right padding to length + 1
        emptyCellElement.InnerText = " ".PadLeft(1).PadRight(columnLengths[columnIndex] + 2);
        parent.AppendChild(emptyCellElement);
    }

    private XmlElement WrapHtmlElement(XmlDocument doc, string element)
    {
        XmlElement specialElement = doc.CreateElement("wwexsldoc:Text", "urn:WebWorks-XSLT-Extension-Document");
        specialElement.InnerText = element;
        specialElement.SetAttribute("disable-output-escaping", "yes");
        return specialElement;
    }
  ]]>
 </msxsl:script>
</xsl:stylesheet>
