<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc html"
>
 <xsl:key name="wwsplits-files-by-groupid-type" match="wwsplits:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwsplits-frames-by-id" match="wwsplits:Frame" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />
 <xsl:key name="wwbehaviors-frames-by-id" match="wwbehaviors:Frame" use="@id" />
 <xsl:key name="wwbehaviors-tables-by-id" match="wwbehaviors:Table" use="@id" />
 <xsl:key name="wwbehaviors-markers-by-id" match="wwbehaviors:Marker" use="@id" />
 <xsl:key name="wwdoc-paragraphs-by-id" match="wwdoc:Paragraph" use="@id" />
 <xsl:key name="wwnotes-notes-by-id" match="wwnotes:Note" use="@id" />
 <xsl:key name="wwfiles-files-by-path" match="wwfiles:File" use="@path" />
 <xsl:key name="wwproject-property-by-name" match="wwproject:Property" use="@Name"/>
 <xsl:key name="wwlinks-by-anchor" match="wwdoc:Link" use="@anchor" />



 <xsl:template name="Content-Content">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Content -->
  <!--         -->
  <xsl:apply-templates select="$ParamContent" mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>

 </xsl:template>


 <xsl:template name="Content-Notes">
  <xsl:param name="ParamNotes" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:if test="count($ParamNotes[1]) = 1">
   <xsl:call-template name="Markdown-FNotes">
    <xsl:with-param name="ParamNotes" select="$ParamNotes" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Notes-Number">
  <xsl:param name="ParamNotes" />

  <wwnotes:NoteNumbering version="1.0">
   <xsl:for-each select="$ParamNotes">
    <xsl:variable name="VarNote" select="." />

    <wwnotes:Note id="{$VarNote/@id}" number="{position()}" />
   </xsl:for-each>
  </wwnotes:NoteNumbering>
 </xsl:template>


 <xsl:template match="wwdoc:List" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarList" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarList/@stylename, $ParamSplit/@documentID, $VarList/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarList/@id)[1]" />
      <!-- List -->
      <!--      -->
      <xsl:call-template name="List">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamList" select="$VarList" />
       <xsl:with-param name="ParamStyleName" select="$VarList/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListBehavior" select="$VarListBehavior" />
      </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="List">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamList" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListBehavior" />


  <!-- Begin list emit -->
  <!--                 -->

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamList/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End list emit -->
   <!--               -->

 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarListItem" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarListItem/@stylename, $ParamSplit/@documentID, $VarListItem/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListItemBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarListItem/@id)[1]" />
      <!-- ListItem -->
      <!--          -->
      <xsl:call-template name="ListItem">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamListItem" select="$VarListItem" />
       <xsl:with-param name="ParamStyleName" select="$VarListItem/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListItemBehavior" select="$VarListItemBehavior" />
      </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="ListItem">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamListItem" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListItemBehavior" />


   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamListItem/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarBlock" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarBlock/@stylename, $ParamSplit/@documentID, $VarBlock/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarBlockBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarBlock/@id)[1]" />
      <!-- Block -->
      <!--           -->
      <xsl:call-template name="Block">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamBlock" select="$VarBlock" />
       <xsl:with-param name="ParamStyleName" select="$VarBlock/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamBlockBehavior" select="$VarBlockBehavior" />
      </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Block">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBlock" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamBlockBehavior" />


   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamBlock/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarParagraph" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarParagraph/@id)[1]" />
      <!-- Paragraph -->
      <!--           -->
      <xsl:call-template name="Paragraph">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
       <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamParagraphBehavior" select="$VarParagraphBehavior" />
      </xsl:call-template>

    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>



 <xsl:template name="Paragraph">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Non-empty text runs -->
  <!--                     -->
  <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />

  <!-- Process this paragraph at all? -->
  <!--                                -->
  <xsl:if test="($VarPreserveEmpty) or (count($VarTextRuns[1]) = 1)">
   <!-- Pass-through? -->
   <!--               -->
   <xsl:variable name="VarPassThrough">
    <xsl:variable name="VarPassThroughOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarPassThroughOption = 'true'">
      <xsl:value-of select="true()" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Conditions-PassThrough">
       <xsl:with-param name="ParamConditions" select="$ParamParagraph/wwdoc:Conditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:choose>
    <!-- Pass-through -->
    <!--              -->
    <xsl:when test="$VarPassThrough = 'true'">
     <xsl:call-template name="Paragraph-PassThrough">
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="Paragraph-Normal">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
      <xsl:with-param name="ParamOverrideRule" select="$ParamOverrideRule" />
      <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Paragraph-PassThrough">
  <xsl:param name="ParamParagraph" />

  <wwexsldoc:Text disable-output-escaping="yes">
   <xsl:for-each select="$ParamParagraph//wwdoc:TextRun[count(parent::wwdoc:Marker[1]) = 0]/wwdoc:Text">
    <xsl:variable name="VarText" select="." />

    <xsl:value-of select="$VarText/@value" />
   </xsl:for-each>
  </wwexsldoc:Text>
 </xsl:template>


 <xsl:template name="Paragraph-Normal">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

  <!-- CSS properties -->
  <!--                -->
  <xsl:variable name="VarCSSPropertiesAsXML">
   <xsl:call-template name="CSS-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
    <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamParagraph/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- CSS properties -->
  <!--                -->
  <xsl:variable name="VarCSSContextPropertiesAsXML">
   <xsl:call-template name="CSS-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarCSSContextProperties" select="msxsl:node-set($VarCSSContextPropertiesAsXML)/wwproject:Property" />

  <!-- Use numbering? -->
  <!--                -->
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption = 'true')" />

  <!-- Text Indent -->
  <!--             -->
  <xsl:variable name="VarTextIndent">
   <xsl:if test="$VarUseNumbering">
    <xsl:variable name="VarOverrideTextIndent" select="$VarCSSProperties[@Name = 'text-indent']/@Value" />
    <xsl:choose>
     <xsl:when test="string-length($VarOverrideTextIndent) &gt; 0">
      <xsl:value-of select="$VarOverrideTextIndent" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Text indent defined? -->
      <!--                      -->
      <xsl:variable name="VarContextTextIndent" select="$VarCSSContextProperties[@Name = 'text-indent']/@Value" />
      <xsl:if test="string-length($VarContextTextIndent) &gt; 0">
       <xsl:value-of select="$VarContextTextIndent" />
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:variable>

  <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
  <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

  <!-- Use bullet from UI? -->
  <!--                     -->
  <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
  <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
  <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
  <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />

  <!-- Is numbered paragraph -->
  <!--                       -->
  <xsl:variable name="VarIsNumberedParagraph" select="($VarTextIndentLessThanZero = true()) and ((count($ParamParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0))" />

  <!-- Citation -->
  <!--          -->
  <xsl:variable name="VarCitation">
   <xsl:call-template name="Behaviors-Options-OptionMarker">
    <xsl:with-param name="ParamContainer" select="$ParamParagraph" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
    <xsl:with-param name="ParamRule" select="$VarContextRule" />
    <xsl:with-param name="ParamOption" select="'citation'" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTagProperty" select="$VarResolvedContextProperties[@Name = 'tag']/@Value" />
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="string-length($VarTagProperty) &gt; 0">
     <xsl:value-of select="$VarTagProperty" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'div'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Tag to use for outer wrapper -->
  <!--                              -->
  <xsl:variable name="VarOuterTag">
   <xsl:choose>
    <xsl:when test="$VarIsNumberedParagraph = true()">
     <xsl:value-of select="'div'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarTag" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Markdown properties -->
  <!--                     -->
  <xsl:variable name="VarMarkdownPropertiesAsXML">
   <xsl:call-template name="Markdown-TranslateParagraphStyleProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarMarkdownProperties" select="msxsl:node-set($VarMarkdownPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarParagraphNumberAsXML">
   <xsl:if test="$VarUseNumbering and (count($ParamParagraph/wwdoc:Number[1]) &gt; 0)">
    <xsl:call-template name="Number">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
     <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
     <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
     <xsl:with-param name="ParamImage" select="$VarBulletImage" />
     <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
     <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarParagraphNumber" select="msxsl:node-set($VarParagraphNumberAsXML)" />

  <xsl:variable name="VarParagraphContentAsXML">
   <xsl:call-template name="ParagraphTextRuns">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
    <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarParagraphContent" select="msxsl:node-set($VarParagraphContentAsXML)" />
  <xsl:variable name="VarIsTableCell" select="count($ParamParagraph/ancestor::wwdoc:TableCell[1]) = 1" />

  <xsl:choose>
   <xsl:when test="$VarIsTableCell">
    <xsl:variable name="VarTableStyleName" select="$ParamParagraph/ancestor::wwdoc:Table[1]/@stylename" />
    <xsl:variable name="VarTableRule" select="wwprojext:GetRule('Table', $VarTableStyleName)" />
    <xsl:variable name="VarRenderingOption" select="$VarTableRule/wwproject:Options/wwproject:Option[@Name = 'table-rendering']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarRenderingOption = 'pipes'">
      <xsl:call-template name="Markdown-Paragraph-TableCell">
       <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
       <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
      </xsl:call-template>
     </xsl:when>

     <xsl:when test="$VarRenderingOption = 'pipes-multiline'">
      <xsl:call-template name="Markdown-Paragraph">
       <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
       <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
       <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
       <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
       <xsl:with-param name="ParamRule" select="$VarContextRule" />
       <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
      </xsl:call-template>
     </xsl:when>
    </xsl:choose>

   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="Markdown-Paragraph">
     <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
     <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
     <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamRule" select="$VarContextRule" />
     <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Number">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamIgnoreDocumentNumber" />
  <xsl:param name="ParamCharacter" />
  <xsl:param name="ParamImage" />
  <xsl:param name="ParamSeparator" />
  <xsl:param name="ParamStyle" />

  <xsl:call-template name="Markdown-ParaNumber">
   <xsl:with-param name="ParamNumber" select="$ParamParagraph/wwdoc:Number[1]" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="ParagraphTextRuns">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamPreserveEmpty" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamParagraph" />

  <!-- Prevent whitespace issues with preformatted text blocks -->
  <!--                                                         -->
  <wwexsldoc:NoBreak />

  <!-- Non-empty text runs -->
  <!--                     -->
  <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />
  <xsl:variable name="VarNonMarkerTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1]) &gt; 0]" />

  <!-- Check for empty paragraphs -->
  <!--                            -->
  <xsl:choose>
   <xsl:when test="count($VarTextRuns[1]) = 1">
    <!-- Paragraph has content -->
    <!--                       -->
    <xsl:for-each select="$VarTextRuns">
     <xsl:variable name="VarTextRun" select="." />

     <xsl:call-template name="TextRun">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:when>

   <xsl:otherwise>
    <!-- Empty paragraph! -->
    <!--                  -->
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="LinkInfo">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocumentLink" />

  <xsl:element name="LinkInfo" namespace="urn:WebWorks-Engine-Links-Schema">
   <xsl:if test="count($ParamDocumentLink) &gt; 0">
    <!-- Resolve link -->
    <!--              -->
    <xsl:variable name="VarResolvedLinkInfoAsXML">
     <xsl:call-template name="Links-Resolve">
      <xsl:with-param name="ParamAllowBaggage" select="$ParameterAllowBaggage" />
      <xsl:with-param name="ParamAllowGroupToGroup" select="$ParameterAllowGroupToGroup" />
      <xsl:with-param name="ParamAllowURL" select="$ParameterAllowURL" />
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType" />
      <xsl:with-param name="ParamProject" select="$GlobalProject" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamSplitGroupID" select="$ParamSplit/@groupID" />
      <xsl:with-param name="ParamSplitDocumentID" select="$ParamSplit/@documentID" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedLinkInfo" select="msxsl:node-set($VarResolvedLinkInfoAsXML)/wwlinks:ResolvedLink" />

    <!-- @title -->
    <!--        -->
    <xsl:if test="string-length($VarResolvedLinkInfo/@title) &gt; 0">
     <xsl:attribute name="title">
      <xsl:value-of select="$VarResolvedLinkInfo/@title" />
     </xsl:attribute>
    </xsl:if>

    <xsl:choose>
     <!-- Baggage -->
     <!--         -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'baggage'">
      <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

      <xsl:attribute name="href">
       <xsl:value-of select="$VarRelativePath" />
      </xsl:attribute>

      <xsl:variable name="VarTarget" select="wwprojext:GetFormatSetting('baggage-file-target')" />

      <xsl:if test="(string-length($VarTarget) &gt; 0) and ($VarTarget != 'none')">
       <xsl:attribute name="target">
        <xsl:value-of select="$VarTarget" />
       </xsl:attribute>
      </xsl:if>
     </xsl:when>

     <!-- Document -->
     <!--          -->
     <xsl:when test="($VarResolvedLinkInfo/@type = 'document') or ($VarResolvedLinkInfo/@type = 'group') or ($VarResolvedLinkInfo/@type = 'project')">
      <xsl:attribute name="href">
       <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

       <xsl:value-of select="$VarRelativePath" />
       <xsl:text>#</xsl:text>
       <xsl:if test="(string-length($ParamDocumentLink/@anchor) &gt; 0) and ($VarResolvedLinkInfo/@first != 'true') and (string-length($VarResolvedLinkInfo/@linkid) &gt; 0)">
        <xsl:value-of select="$VarResolvedLinkInfo/@linkid" />
       </xsl:if>
      </xsl:attribute>
     </xsl:when>

     <!-- URL -->
     <!--     -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'url'">
      <xsl:attribute name="href">
       <xsl:value-of select="$VarResolvedLinkInfo/@url" />
      </xsl:attribute>

      <!-- External URL Target -->
      <!--                     -->
      <xsl:if test="not(wwuri:IsFile($VarResolvedLinkInfo/@url))">
       <xsl:variable name="VarTarget" select="wwprojext:GetFormatSetting('external-url-target', 'external_window')" />

       <xsl:if test="(string-length($VarTarget) &gt; 0) and ($VarTarget != 'none')">
        <xsl:attribute name="target">
         <xsl:value-of select="$VarTarget" />
        </xsl:attribute>
       </xsl:if>
      </xsl:if>
     </xsl:when>
    </xsl:choose>
   </xsl:if>
  </xsl:element>
 </xsl:template>


 <xsl:template name="TextRun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamTextRun" />

  <!-- Get stylename -->
  <!--               -->
  <xsl:variable name="VarStyleName">
   <xsl:choose>
    <xsl:when test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value) &gt; 0">
     <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamTextRun/@stylename" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $VarStyleName)" />

  <!-- Generate output? -->
  <!---                 -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Pass-through? -->
   <!--               -->
   <xsl:variable name="VarPassThrough">
    <xsl:variable name="VarPassThroughOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarPassThroughOption = 'true'">
      <xsl:value-of select="true()" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Conditions-PassThrough">
       <xsl:with-param name="ParamConditions" select="$ParamTextRun/wwdoc:Conditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="$VarPassThrough = 'true'">
     <xsl:call-template name="TextRun-PassThrough">
      <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="TextRun-Normal">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
      <xsl:with-param name="ParamRule" select="$VarRule" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="TextRun-PassThrough">
  <xsl:param name="ParamTextRun" />

  <wwexsldoc:Text disable-output-escaping="yes">
   <xsl:for-each select="$ParamTextRun/wwdoc:Text">
    <xsl:variable name="VarText" select="." />

    <xsl:value-of select="$VarText/@value" />
   </xsl:for-each>
  </wwexsldoc:Text>
 </xsl:template>


 <xsl:template name="TextRun-Normal">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamTextRun" />
  <xsl:param name="ParamRule" />

  <!-- Get stylename -->
  <!--               -->
  <xsl:variable name="VarStyleName" select="$ParamTextRun/@stylename"/>
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $VarStyleName, $ParamSplit/@documentID, $ParamTextRun/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamTextRun" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
    <xsl:with-param name="ParamStyleType" select="'Character'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamTextRun/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- Markdown properties -->
  <!--                     -->
  <xsl:variable name="VarMarkdownPropertiesAsXML">
   <xsl:call-template name="Markdown-TranslateCharacterStyleProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarMarkdownProperties" select="msxsl:node-set($VarMarkdownPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarTextRunContent">
   <xsl:call-template name="TextRunChildren">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
    <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
   </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="Markdown-TextRun">
   <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
   <xsl:with-param name="ParamTextRunContent" select="$VarTextRunContent" />
   <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
   <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="TextRunChildren">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamTextRun" />

  <!-- Force anchor on same line as containing span -->
  <!--                                              -->
  <wwexsldoc:NoBreak />

  <!-- Link? -->
  <!--       -->
  <xsl:variable name="VarLinkInfoAsXML">
   <xsl:call-template name="LinkInfo">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamDocumentLink" select="$ParamTextRun/wwdoc:Link" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:LinkInfo" />

  <xsl:call-template name="Markdown-LinkPrefix">
   <xsl:with-param name="ParamLinkInfo" select="$VarLinkInfo" />
  </xsl:call-template>

  <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>

  <xsl:call-template name="Markdown-LinkSuffix">
   <xsl:with-param name="ParamLinkInfo" select="$VarLinkInfo" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarTextRun" select="." />
  <xsl:variable name="VarStyleName" select="$VarTextRun/@stylename" />
  <xsl:variable name="VarParagraphID" select="$ParamSplit/@id" />
  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Character', $VarStyleName, $ParamSplit/@documentID, $VarTextRun/@id)" />

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <xsl:call-template name="TextRun">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamParagraphID" select="$VarParagraphID" />
   <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
   <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:Note" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarContext" select="." />

  <xsl:for-each select="$ParamCargo/wwnotes:NoteNumbering[1]">
   <xsl:variable name="VarNoteNumber" select="key('wwnotes-notes-by-id', $VarContext/@id)/@number" />

   <!-- Force sup on same line as containing span -->
   <!--                                           -->
   <wwexsldoc:NoBreak />

   <xsl:call-template name="Markdown-FNoteRef">
    <xsl:with-param name="ParamNoteNumber" select="$VarNoteNumber" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:call-template name="Markdown-ParaLineBreak">
   <xsl:with-param name="ParamLineBreak" select="." />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:IndexMarker" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Ignore index markers -->
  <!--                      -->
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarMarker" select="." />

  <!-- Pass-through marker? -->
  <!--                      -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarMarkerBehavior" select="key('wwbehaviors-markers-by-id', $VarMarker/@id)[1]" />

   <xsl:if test="$VarMarkerBehavior/@behavior = 'pass-through'">
    <!-- Pass-through -->
    <!--              -->
    <xsl:for-each select="$VarMarker/wwdoc:TextRun">
     <xsl:variable name="VarTextRun" select="." />

     <xsl:call-template name="TextRun-PassThrough">
      <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwdoc:Text" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:value-of select="@value" />
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarTable" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Table', $VarTable/@stylename, $ParamSplit/@documentID, $VarTable/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">

    <!-- Get behavior -->
    <!--              -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarTableBehavior" select="key('wwbehaviors-tables-by-id', $VarTable/@id)[1]" />

     <!-- Table -->
     <!--       -->
     <xsl:call-template name="Table">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamTable" select="$VarTable" />
      <xsl:with-param name="ParamStyleName" select="$VarTable/@stylename" />
      <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
      <xsl:with-param name="ParamTableBehavior" select="$VarTableBehavior" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Table">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamTableBehavior" />

  <!-- Notes -->
  <!--       -->
  <xsl:variable name="VarNotes" select="$ParamTable//wwdoc:Note[not(ancestor::wwdoc:Frame)]" />

  <!-- Note numbering -->
  <!--                -->
  <xsl:variable name="VarNoteNumberingAsXML">
   <xsl:call-template name="Notes-Number">
    <xsl:with-param name="ParamNotes" select="$VarNotes" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

  <!-- Cargo for recursion -->
  <!--                     -->
  <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'NoteNumbering']/.. | $VarNoteNumbering" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamTable/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $ParamTable/@stylename, $ParamSplit/@documentID, $ParamTable/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamTable" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamTable/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Table'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamTable/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- caption -->
  <!--         -->
  <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
   <xsl:apply-templates select="./*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$VarCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>
  </xsl:for-each>

  <!-- Use StyleName? -->
  <!--                -->
  <xsl:variable name="VarUseStyleNameOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
  <xsl:variable name="VarUseStyleName" select="(string-length($ParamTable[1]/@stylename) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true')" />
  <xsl:variable name="VarStyleName">
   <xsl:if test="$VarUseStyleName">
    <xsl:for-each select="$GlobalDefaultTableStyles">
     <xsl:variable name="VarStyle" select="key('wwmddefaults-table-styles-by-name', $ParamTable[1]/@stylename)" />
     <xsl:if test="count($VarStyle) = 0">
      <xsl:value-of select="$ParamTable[1]/@stylename" />
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>

  <!-- Process table without caption -->
  <!--                               -->
  <xsl:variable name="VarTableAsXML">
   <xsl:element name="table" namespace="">
    <xsl:for-each select="$ParamTable/wwdoc:TableHead|$ParamTable/wwdoc:TableBody|$ParamTable/wwdoc:TableFoot">
     <xsl:variable name="VarSection" select="." />
     <xsl:variable name="VarSectionPosition" select="position()" />

     <!-- Resolve section properties -->
     <!--                            -->
     <xsl:variable name="VarResolvedSectionPropertiesAsXML">
      <xsl:call-template name="Properties-Table-Section-ResolveContextRule">
       <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
       <xsl:with-param name="ParamDocumentContext" select="$ParamTable" />
       <xsl:with-param name="ParamTable" select="$ParamTable" />
       <xsl:with-param name="ParamSection" select="$VarSection" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarResolvedSectionProperties" select="msxsl:node-set($VarResolvedSectionPropertiesAsXML)/wwproject:Property" />

     <!-- Process section rows -->
     <!--                      -->
     <xsl:for-each select="$VarSection/wwdoc:TableRow">
      <xsl:variable name="VarTableRow" select="." />
      <xsl:variable name="VarRowPosition" select="position()" />

      <xsl:element name="tr" namespace="">
       <xsl:for-each select="$VarTableRow/wwdoc:TableCell">
        <xsl:variable name="VarTableCell" select="." />
        <xsl:variable name="VarCellPosition" select="position()" />

        <!-- Calculate row span -->
        <!--                    -->
        <xsl:variable name="VarRowSpan">
         <xsl:variable name="VarRowSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'row-span']/@value" />
         <xsl:choose>
          <xsl:when test="string-length($VarRowSpanHint) &gt; 0">
           <xsl:value-of select="$VarRowSpanHint" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="'0'" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>

        <!-- Calculate column span -->
        <!--                       -->
        <xsl:variable name="VarColumnSpan">
         <xsl:variable name="VarColumnSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
         <xsl:choose>
          <xsl:when test="string-length($VarColumnSpanHint) &gt; 0">
           <xsl:value-of select="$VarColumnSpanHint" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="'0'" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>

        <!-- Emit cell with proper th/td tagging -->
        <!--                                     -->
        <xsl:variable name="VarCellTag">
         <xsl:choose>
          <xsl:when test="($VarSectionPosition = 1) and ($VarRowPosition = 1)">
           <xsl:text>th</xsl:text>
          </xsl:when>
          <xsl:otherwise>
           <xsl:text>td</xsl:text>
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$VarCellTag}" namespace="">
         <!-- Emit cell end -->
         <!--               -->

         <!-- Row span attribute -->
         <!--                    -->
         <xsl:if test="number($VarRowSpan) &gt; 0">
          <xsl:attribute name="rowspan">
           <xsl:value-of select="$VarRowSpan" />
          </xsl:attribute>
         </xsl:if>

         <!-- Column span attribute -->
         <!--                       -->
         <xsl:if test="number($VarColumnSpan) &gt; 0">
          <xsl:attribute name="colspan">
           <xsl:value-of select="$VarColumnSpan" />
          </xsl:attribute>
         </xsl:if>

         <!-- Recurse -->
         <!--         -->
         <xsl:apply-templates select="./*" mode="wwmode:content">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$VarCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         </xsl:apply-templates>
         <!-- Emit cell close -->
         <!--                 -->
        </xsl:element>
       </xsl:for-each>

      </xsl:element>
     </xsl:for-each>
    </xsl:for-each>

   </xsl:element>
  </xsl:variable>
  <xsl:variable name="VarTable" select="msxsl:node-set($VarTableAsXML)" />

  <xsl:call-template name="Markdown-Table">
   <xsl:with-param name="ParamTable" select="$VarTable" />
   <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
  </xsl:call-template>


  <!-- Table Footnotes -->
  <!--                 -->
  <xsl:call-template name="Content-Notes">
   <xsl:with-param name="ParamNotes" select="$VarNotes" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$VarCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:call-template name="Frame">
    <xsl:with-param name="ParamFrame" select="." />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:call-template name="Frame">
   <xsl:with-param name="ParamFrame" select="." />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Frame">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Get splits frame -->
  <!--                  -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarSplitsFrame" select="key('wwsplits-frames-by-id', $ParamFrame/@id)[@documentID = $ParamSplit/@documentID]" />

   <!-- Frame known? -->
   <!--              -->
   <xsl:if test="count($VarSplitsFrame) = 1">
    <xsl:for-each select="$GlobalFiles[1]">

     <!-- Emit markup -->
     <!--             -->
     <xsl:call-template name="Frame-Markup">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
      <xsl:with-param name="ParamThumbnail" select="false()" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Frame-Markup">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamThumbnail" />

  <!-- Context Rule -->
  <!--              -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />

  <!-- Generate? -->
  <!--           -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Video or Object? -->
   <!--                  -->
   <xsl:variable name="VarVideoFacet" select="$ParamFrame//wwdoc:Facet[@type = 'video'][1]" />
   <xsl:choose>
    <!-- Video -->
    <!--       -->
    <xsl:when test="(count($VarVideoFacet) = 1) and ((count($ParamSplitsFrame/wwsplits:Media[1]) = 1) or (string-length($VarVideoFacet/wwdoc:Attribute[@name = 'src'][1]/@value) &gt; 0))">
     <xsl:call-template name="Frame-Markup-Video">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>

    <!-- Object -->
    <!--        -->
    <xsl:when test="count($ParamFrame//wwdoc:Facet[@type = 'object'][1]) = 1">
     <xsl:call-template name="Frame-Markup-Object">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>

    <!-- Document image -->
    <!--                -->
    <xsl:otherwise>
     <xsl:call-template name="Frame-Markup-Document-Image">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Frame-Markup-Video">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamThumbnail" />

  <!-- Determine media source -->
  <!--                        -->
  <xsl:variable name="VarSplitsMedia" select="$ParamSplitsFrame/wwsplits:Media[1]" />
  <xsl:variable name="VarVideoFacet" select="$ParamFrame//wwdoc:Facet[@type = 'video'][1]" />
  <xsl:variable name="VarVideoSrcURI">
   <xsl:choose>
    <xsl:when test="count($VarSplitsMedia) &gt; 0">
     <xsl:value-of select="wwuri:GetRelativeTo($VarSplitsMedia/@path, $ParamSplit/@path)" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarVideoFacet/wwdoc:Attribute[@name = 'src'][1]/@value" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit video tag? -->
  <!--                 -->
  <xsl:element name="video" namespace="">
   <!-- Class -->
   <!--       -->
   <xsl:if test="string-length(wwstring:CSSClassName($ParamFrame/@stylename)) &gt; 0">
    <xsl:attribute name="class">
     <xsl:value-of select="wwstring:CSSClassName($ParamFrame/@stylename)" />
    </xsl:attribute>
   </xsl:if>

   <!-- @src (only if type is missing) -->
   <!--                                -->
   <xsl:if test="string-length($VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value) = 0">
    <xsl:attribute name="src">
     <xsl:value-of select="$VarVideoSrcURI" />
    </xsl:attribute>
   </xsl:if>

   <!-- @width -->
   <!--        -->
   <xsl:if test="string-length($ParamFrame/@width) &gt; 0">
    <xsl:attribute name="width">
     <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/@width), wwunits:UnitsSuffix($ParamFrame/@width), 'px'))" />
    </xsl:attribute>
   </xsl:if>

   <!-- @height -->
   <!--         -->
   <xsl:if test="string-length($ParamFrame/@height) &gt; 0">
    <xsl:attribute name="height">
     <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/@height), wwunits:UnitsSuffix($ParamFrame/@height), 'px'))" />
    </xsl:attribute>
   </xsl:if>

   <!-- @controls -->
   <!--           -->
   <xsl:if test="$VarVideoFacet/wwdoc:Attribute[@name = 'controls']/@value = 'controls'">
    <xsl:attribute name="controls">
     <xsl:text>controls</xsl:text>
    </xsl:attribute>
   </xsl:if>

   <!-- @poster -->
   <!--         -->
   <xsl:variable name="VarImagePath">
    <xsl:choose>
     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="$ParamSplitsFrame/wwsplits:Thumbnail/@path" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$ParamSplitsFrame/@path" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:if test="wwfilesystem:FileExists($VarImagePath)">
    <xsl:attribute name="poster">
     <xsl:value-of select="wwuri:GetRelativeTo($VarImagePath, $ParamSplit/@path)" />
    </xsl:attribute>
   </xsl:if>

   <!-- Source -->
   <!--        -->
   <xsl:if test="string-length($VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value) &gt; 0">
    <xsl:element name="source" namespace="">
     <xsl:attribute name="src">
      <xsl:value-of select="$VarVideoSrcURI" />
     </xsl:attribute>
     <xsl:attribute name="type">
      <xsl:value-of select="$VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value" />
     </xsl:attribute>
    </xsl:element>
   </xsl:if>

   <!-- Emit fallback elements -->
   <!--                        -->
   <xsl:variable name="VarObjectFacet" select="$ParamFrame//wwdoc:Facet[@type = 'object'][1]" />
   <xsl:choose>
    <!-- Emit object markup -->
    <!--                    -->
    <xsl:when test="count($VarObjectFacet) = 1">
     <xsl:call-template name="Frame-Markup-Object">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>

    <!-- Emit document image -->
    <!--                     -->
    <xsl:otherwise>
     <xsl:call-template name="Frame-Markup-Document-Image">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:element>
 </xsl:template>


 <xsl:template name="Frame-Markup-Object">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamThumbnail" />

  <!-- Locate object facet -->
  <!--                     -->
  <xsl:variable name="VarObjectFacet" select="$ParamFrame//wwdoc:Facet[@type = 'object'][1]" />

  <!-- Convert object to target namespace -->
  <!--                                    -->
  <xsl:for-each select="$VarObjectFacet/wwdoc:object[1]">
   <xsl:variable name="VarObject" select="." />

   <!-- Determine src -->
   <!--               -->
   <xsl:variable name="VarSplitsMedia" select="$ParamSplitsFrame/wwsplits:Media[1]" />
   <xsl:variable name="VarSrcURI">
    <xsl:choose>
     <xsl:when test="count($VarSplitsMedia) &gt; 0">
      <xsl:value-of select="wwuri:GetRelativeTo($VarSplitsMedia/@path, $ParamSplit/@path)" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarObject/@data" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarFLVPlayerURI">
    <xsl:if test="($VarObject/@type = 'webworks-video/x-flv') and (count($VarSplitsMedia) &gt; 0) and (string-length($VarSrcURI) &gt; 0)">
     <xsl:variable name="VarFLVPlayerFilePath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarSplitsMedia/@path), 'player_flv_maxi.swf')" />

     <xsl:value-of select="wwuri:GetRelativeTo($VarFLVPlayerFilePath, $ParamSplit/@path)" />
    </xsl:if>
   </xsl:variable>

   <!-- Determine type -->
   <!--                -->
   <xsl:variable name="VarType">
    <xsl:choose>
     <xsl:when test="string-length($VarFLVPlayerURI) &gt; 0">
      <xsl:text>application/x-shockwave-flash</xsl:text>
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarObject/@type" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:element name="object" namespace="">
    <xsl:copy-of select="@*[(name() != 'data') and (name() != 'type')]" />

    <!-- @data -->
    <!--       -->
    <xsl:if test="string-length($VarSrcURI) &gt; 0">
     <xsl:attribute name="data">
      <xsl:choose>
       <xsl:when test="string-length($VarFLVPlayerURI) &gt; 0">
        <xsl:value-of select="$VarFLVPlayerURI" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$VarSrcURI" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>
    </xsl:if>

    <!-- @type -->
    <!--       -->
    <xsl:if test="string-length($VarType) &gt; 0">
     <xsl:attribute name="type">
      <xsl:value-of select="$VarType" />
     </xsl:attribute>
    </xsl:if>

    <!-- param elements -->
    <!--                -->
    <xsl:for-each select="$VarObject/wwdoc:param[(wwstring:ToLower(@name) != 'flashvars') or (wwstring:ToLower(@name) != 'allowfullscreen')]">
     <xsl:variable name="VarParam" select="." />

     <xsl:variable name="VarValue">
      <xsl:choose>
       <xsl:when test="(($VarParam/@name = 'src') or ($VarParam/@name = 'filename') or ($VarParam/@name = 'movie') or ($VarParam/@name = 'mediafile')) and (string-length($VarSrcURI) &gt; 0)">
        <xsl:choose>
         <xsl:when test="string-length($VarFLVPlayerURI) &gt; 0">
          <xsl:value-of select="$VarFLVPlayerURI" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="$VarSrcURI" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$VarParam/@value" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <xsl:element name="param" namespace="">
      <xsl:attribute name="name">
       <xsl:value-of select="$VarParam/@name" />
      </xsl:attribute>
      <xsl:attribute name="value">
       <xsl:value-of select="$VarValue"/>
      </xsl:attribute>
     </xsl:element>
    </xsl:for-each>

    <!-- allowFullScreen param -->
    <!--                       -->
    <xsl:variable name="VarAllowFullScreen">
     <xsl:choose>
      <xsl:when test="string-length($VarObject/wwdoc:param[wwstring:ToLower(@name) = 'allowfullscreen']/@value) &gt; 0">
       <xsl:value-of select="$VarObject/wwdoc:param[wwstring:ToLower(@name) = 'allowfullscreen']/@value" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:text>true</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($VarAllowFullScreen) &gt; 0">
     <xsl:element name="param" namespace="">
      <xsl:attribute name="name">
       <xsl:text>allowFullScreen</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value">
       <xsl:value-of select="$VarAllowFullScreen"/>
      </xsl:attribute>
     </xsl:element>
    </xsl:if>

    <!-- FlashVars param -->
    <!--                 -->
    <xsl:choose>
     <xsl:when test="string-length($VarFLVPlayerURI) &gt; 0">
      <!-- Flash movie -->
      <!--             -->
      <xsl:variable name="VarFLVURI" select="wwfilesystem:GetFileName($VarSplitsMedia/@path)" />

      <!-- startimage -->
      <!--            -->
      <xsl:variable name="VarStartImage">
       <xsl:if test="count($ParamFrame/wwdoc:Facets[1]/wwdoc:Facet[@type = 'document'][1]) = 1">
        <!-- Determine image path -->
        <!--                      -->
        <xsl:variable name="VarImagePath">
         <xsl:choose>
          <xsl:when test="$ParamThumbnail">
           <xsl:value-of select="$ParamSplitsFrame/wwsplits:Thumbnail/@path" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="$ParamSplitsFrame/@path" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>

        <xsl:text>&amp;startimage=</xsl:text>
        <xsl:value-of select="wwuri:GetRelativeTo($VarImagePath, $ParamSplit/@path)" />
       </xsl:if>
      </xsl:variable>

      <xsl:element name="param" namespace="">
       <xsl:attribute name="name">
        <xsl:text>FlashVars</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="value">
        <xsl:value-of select="flv=wwstring:EncodeURIComponent($VarFLVURI)" />
        <xsl:value-of select="$VarStartImage" />
        <xsl:text>&amp;autoplay=0&amp;autoload=0&amp;showvolume=1&amp;showfullscreen=1</xsl:text>
       </xsl:attribute>
      </xsl:element>
     </xsl:when>

     <xsl:otherwise>
      <xsl:copy-of select="$VarObject/wwdoc:param[wwstring:ToLower(@name) = 'flashvars']" />
     </xsl:otherwise>
    </xsl:choose>

    <!-- Emit document image -->
    <!--                     -->
    <xsl:call-template name="Frame-Markup-Document-Image">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
     <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
    </xsl:call-template>
   </xsl:element>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Frame-Markup-Document-Image">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamThumbnail" />

  <!-- Document facet defined? -->
  <!--                         -->
  <xsl:if test="count($ParamFrame/wwdoc:Facets[1]/wwdoc:Facet[@type = 'document'][1]) = 1">
   <!-- Determine image path -->
   <!--                      -->
   <xsl:variable name="VarImagePath">
    <xsl:choose>
     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="$ParamSplitsFrame/wwsplits:Thumbnail/@path" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$ParamSplitsFrame/@path" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Access image info -->
   <!--                   -->
   <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImagePath)" />

   <!-- Determine type -->
   <!--                -->
   <xsl:variable name="VarVectorImageAsText">
    <xsl:call-template name="Images-VectorImageFormat">
     <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarVectorImage" select="$VarVectorImageAsText = string(true())" />
   <xsl:variable name="VarRasterImageAsText">
    <xsl:call-template name="Images-RasterImageFormat">
     <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRasterImage" select="$VarRasterImageAsText = string(true())" />

   <!-- Emit image -->
   <!--            -->
   <xsl:choose>
    <!-- Vector Image -->
    <!--              -->
    <xsl:when test="$VarVectorImage">
     <xsl:call-template name="Frame-Markup-Vector">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>

    <!-- Raster Image -->
    <!--              -->
    <xsl:when test="$VarRasterImage">
     <xsl:call-template name="Frame-Markup-Raster">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Frame-Markup-Vector">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <xsl:choose>
   <!-- SVG -->
   <!--     -->
   <xsl:when test="$ParamImageInfo/@format = 'svg'">
    <xsl:call-template name="Frame-Markup-Vector-SVG">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
     <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
     <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
    </xsl:call-template>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Frame-Markup-Vector-SVG">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <!-- Access frame behavior -->
  <!--                       -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarBehaviorFrame" select="key('wwbehaviors-frames-by-id', $ParamFrame/@id)[1]" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveContextRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamFrame" />
     <xsl:with-param name="ParamProperties" select="$ParamContextRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$ParamFrame/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
     <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- Width/Height -->
   <!--              -->
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
   <xsl:variable name="VarWidth">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'width']) = 0">
      <xsl:value-of select="0" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@width)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px'))" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@width)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarHeight">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'height']) = 0">
      <xsl:value-of select="0" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@height)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px'))" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@height)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Responsive image? -->
   <!--                   -->
   <xsl:variable name="VarOptionResponsiveImageSize" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'responsive-image-size']/@Value" />
   <xsl:variable name="VarResponsiveImageSize" select="($VarWidth != '0') and ($VarOptionResponsiveImageSize = 'true')" />

   <!-- CSS properties -->
   <!--                -->
   <xsl:variable name="VarCSSPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateImageObjectProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[(@Name != 'width') and (@Name != 'height')]" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    </xsl:call-template>

    <xsl:if test="$VarResponsiveImageSize">
     <xsl:if test="$VarWidth != '0'">
      <wwproject:Property Name="max-width" Value="{$VarWidth}px" />
     </xsl:if>
     <xsl:if test="$VarHeight != '0'">
      <wwproject:Property Name="max-height" Value="{$VarHeight}px" />
     </xsl:if>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />
   <xsl:variable name="VarInlineCSSProperties">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Src -->
   <!--     -->
   <xsl:variable name="VarSrc" select="wwuri:GetRelativeTo($ParamImageInfo/@path, $ParamSplit/@path)" />

   <!-- Alt Text -->
   <!--          -->
   <xsl:variable name="VarAltText">
    <xsl:call-template name="Images-AltText">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
    </xsl:call-template>
   </xsl:variable>


   <!-- SVG object tag info:                                          -->
   <!--   http://joliclic.free.fr/html/object-tag/en/object-svg.html  -->
   <!--   http://volity.org/wiki/index.cgi?SVG_Scaling                -->
   <!--                                                               -->

   <!-- Graphic element -->
   <!--                 -->
   <xsl:element name="object" namespace="">
    <!-- Type attribute -->
    <!--                -->
    <xsl:attribute name="type">
     <xsl:text>image/svg+xml</xsl:text>
    </xsl:attribute>

    <!-- Data attribute -->
    <!--                -->
    <xsl:attribute name="data">
     <xsl:value-of select="$VarSrc" />
    </xsl:attribute>

    <!-- Width attribute -->
    <!--                 -->
    <xsl:choose>
     <xsl:when test="$VarResponsiveImageSize">
      <xsl:attribute name="width">
       <xsl:text>100%</xsl:text>
      </xsl:attribute>
     </xsl:when>

     <xsl:otherwise>
      <xsl:if test="$VarWidth != '0'">
       <xsl:attribute name="width">
        <xsl:value-of select="$VarWidth"/>
       </xsl:attribute>
      </xsl:if>
     </xsl:otherwise>
    </xsl:choose>

    <!-- Height attribute -->
    <!--                  -->
    <xsl:if test="not($VarResponsiveImageSize)">
     <xsl:if test="$VarHeight != '0'">
      <xsl:attribute name="height">
       <xsl:value-of select="$VarHeight"/>
      </xsl:attribute>
     </xsl:if>
    </xsl:if>

    <!-- Style attribute -->
    <!--                 -->
    <xsl:if test="string-length($VarInlineCSSProperties) &gt; 0">
     <xsl:attribute name="style">
      <xsl:value-of select="$VarInlineCSSProperties" />
     </xsl:attribute>
    </xsl:if>

    <!-- Title attribute -->
    <!--                 -->
    <xsl:choose>
     <xsl:when test="string-length($VarAltText) &gt; 0">
      <xsl:attribute name="title">
       <xsl:value-of select="$VarAltText" />
      </xsl:attribute>
     </xsl:when>

     <xsl:when test="string-length($ParamSplitsFrame/@title) &gt; 0">
      <xsl:attribute name="title">
       <xsl:value-of select="$ParamSplitsFrame/@title" />
      </xsl:attribute>
     </xsl:when>
    </xsl:choose>

    <!-- Src parameter -->
    <!--               -->
    <xsl:element name="param">
     <xsl:attribute name="name">
      <xsl:text>src</xsl:text>
     </xsl:attribute>
     <xsl:attribute name="value">
      <xsl:value-of select="$VarSrc" />
     </xsl:attribute>
     <xsl:attribute name="valuetype">
      <xsl:text>data</xsl:text>
     </xsl:attribute>
    </xsl:element>
   </xsl:element>

  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Frame-Markup-Raster">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <!-- Access frame behavior -->
  <!--                       -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarBehaviorFrame" select="key('wwbehaviors-frames-by-id', $ParamFrame/@id)[1]" />

   <!-- Override Rule -->
   <!--               -->
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveOverrideRule">
     <xsl:with-param name="ParamProperties" select="$VarOverrideRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- Width/Height -->
   <!--              -->
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
   <xsl:variable name="VarWidth">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'width']) = 0">
      <xsl:value-of select="0" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@width)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px'))" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@width)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarHeight">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'height']) = 0">
      <xsl:value-of select="0" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@height)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px'))" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@height)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Responsive image? -->
   <!--                   -->
   <xsl:variable name="VarOptionResponsiveImageSize" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'responsive-image-size']/@Value" />
   <xsl:variable name="VarResponsiveImageSize" select="($VarWidth != '0') and ($VarOptionResponsiveImageSize = 'true')" />

   <!-- CSS properties -->
   <!--                -->
   <xsl:variable name="VarCSSPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateImageObjectProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[(@Name != 'width') and (@Name != 'height')]" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    </xsl:call-template>

    <xsl:if test="$VarResponsiveImageSize">
     <xsl:if test="$VarWidth != '0'">
      <wwproject:Property Name="max-width" Value="{$VarWidth}px" />
     </xsl:if>
     <xsl:if test="$VarHeight != '0'">
      <wwproject:Property Name="max-height" Value="{$VarHeight}px" />
     </xsl:if>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />
   <xsl:variable name="VarInlineCSSProperties">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Src -->
   <!--     -->
   <xsl:variable name="VarSrc" select="wwuri:GetRelativeTo($ParamImageInfo/@path, $ParamSplit/@path)" />

   <!-- Define Use Map -->
   <!--                -->
   <xsl:variable name="VarUseMap">
    <xsl:choose>
     <xsl:when test="($ParamThumbnail) or (count($ParamFrame//wwdoc:Link) &gt; 0)">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="$ParamSplitsFrame/@documentID" />
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$ParamSplitsFrame/@id" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="''" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Alt Text -->
   <!--          -->
   <xsl:variable name="VarAltText">
    <xsl:call-template name="Images-AltText">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Use StyleName? -->
   <!--                -->
   <xsl:variable name="VarUseStyleNameOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
   <xsl:variable name="VarUseStyleName" select="(string-length($ParamFrame[1]/@stylename) &gt; 0) and
                                               ($VarUseStyleNameOption = 'true')" />
   <xsl:variable name="VarStyleName">
    <xsl:if test="$VarUseStyleName">
     <xsl:for-each select="$GlobalDefaultGraphicStyles">
      <xsl:variable name="VarStyle" select="key('wwmddefaults-graphic-styles-by-name', $ParamFrame[1]/@stylename)" />
      <xsl:if test="count($VarStyle) = 0">
       <xsl:value-of select="$ParamFrame[1]/@stylename" />
      </xsl:if>
     </xsl:for-each>
    </xsl:if>
   </xsl:variable>

   <xsl:call-template name="Markdown-ImageLink">
    <xsl:with-param name="ParamAltText" select="$VarAltText" />
    <xsl:with-param name="ParamSrc" select="$VarSrc" />
    <xsl:with-param name="ParamTitleText" select="$VarAltText" />
    <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="ImageMap">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamParentBehavior" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamHorizontalScaling" />
  <xsl:param name="ParamVerticalScaling" />

  <!-- Process child frames first -->
  <!--                            -->
  <xsl:for-each select="$ParamFrame/wwdoc:Content//wwdoc:Frame[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]">
   <xsl:call-template name="ImageMap">
    <xsl:with-param name="ParamFrame" select="." />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamHorizontalScaling" select="$ParamHorizontalScaling" />
    <xsl:with-param name="ParamVerticalScaling" select="$ParamVerticalScaling" />
   </xsl:call-template>
  </xsl:for-each>

  <!-- Get link -->
  <!--          -->
  <xsl:variable name="VarLinkInfoAsXML">
   <xsl:choose>
    <xsl:when test="count($ParamFrame/wwdoc:Link[1]) = 1">
     <xsl:call-template name="LinkInfo">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamFrame/wwdoc:Link" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarChildLinks" select="$ParamFrame/wwdoc:Content//wwdoc:Link[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]" />
     <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
     <xsl:if test="$VarChildLinksCount &gt; 0">
      <xsl:call-template name="LinkInfo">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamDocumentLink" select="$VarChildLinks[$VarChildLinksCount]" />
      </xsl:call-template>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:LinkInfo" />

  <xsl:if test="string-length($VarLinkInfo/@href) &gt; 0">
   <!-- Get coords attribute -->
   <!--                      -->
   <xsl:variable name="VarLeftAsPixels">
    <xsl:variable name="VarOrigLeftAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'left']/@value), 'pt', 'px')))" />
    <xsl:choose>
     <xsl:when test="$ParamHorizontalScaling != 1">
      <xsl:value-of select="number($VarOrigLeftAsPixels) * number($ParamHorizontalScaling)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarOrigLeftAsPixels" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:variable name="VarTopAsPixels">
    <xsl:variable name="VarOrigTopAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'top']/@value), 'pt', 'px')))" />
    <xsl:choose>
     <xsl:when test="$ParamVerticalScaling != 1">
      <xsl:value-of select="number($VarOrigTopAsPixels) * number($ParamVerticalScaling)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarOrigTopAsPixels" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:variable name="VarWidthAsPixels">
    <xsl:variable name="VarOrigWidthAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px')))" />
    <xsl:choose>
     <xsl:when test="$ParamHorizontalScaling != 1">
      <xsl:value-of select="number($VarOrigWidthAsPixels) * number($ParamHorizontalScaling)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarOrigWidthAsPixels" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:variable name="VarHeightAsPixels">
    <xsl:variable name="VarOrigHeightAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px')))" />
    <xsl:choose>
     <xsl:when test="$ParamVerticalScaling != 1">
      <xsl:value-of select="number($VarOrigHeightAsPixels) * number($ParamVerticalScaling)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarOrigHeightAsPixels" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- coords -->
   <!--        -->
   <xsl:variable name="VarCoordsString">
    <xsl:choose>
     <xsl:when test="string-length($VarLeftAsPixels) &gt; 0">
      <xsl:value-of select="$VarLeftAsPixels" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="'0'" />
     </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="','"/>

    <xsl:choose>
     <xsl:when test="string-length($VarTopAsPixels) &gt; 0">
      <xsl:value-of select="$VarTopAsPixels" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="'0'" />
     </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="','"/>

    <xsl:choose>
     <xsl:when test="string-length($VarWidthAsPixels) &gt; 0">
      <xsl:value-of select="string(number($VarWidthAsPixels) + number($VarLeftAsPixels))" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="'0'" />
     </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="','"/>

    <xsl:choose>
     <xsl:when test="string-length($VarHeightAsPixels) &gt; 0">
      <xsl:value-of select="string(number($VarHeightAsPixels) + number($VarTopAsPixels))" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="'0'" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- alt -->
   <!--     -->
   <xsl:variable name="VarAltText">
    <xsl:call-template name="Images-ImageAreaAltText">
     <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- area -->
   <!--      -->
   <xsl:element name="area" namespace="">
    <xsl:attribute name="href">
     <xsl:value-of select="$VarLinkInfo/@href" />
    </xsl:attribute>
    <xsl:attribute name="coords">
     <xsl:value-of select="$VarCoordsString" />
    </xsl:attribute>
    <xsl:attribute name="shape">
     <xsl:text>rect</xsl:text>
    </xsl:attribute>

    <!-- target -->
    <!--        -->
    <xsl:if test="string-length($VarLinkInfo/@target) &gt; 0">
     <xsl:attribute name="target">
      <xsl:value-of select="$VarLinkInfo/@target" />
     </xsl:attribute>
    </xsl:if>

    <!-- alt -->
    <!--     -->
    <xsl:attribute name="alt">
     <xsl:value-of select="$VarAltText" />
    </xsl:attribute>
    <xsl:attribute name="title">
     <xsl:value-of select="$VarAltText" />
    </xsl:attribute>
   </xsl:element>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
