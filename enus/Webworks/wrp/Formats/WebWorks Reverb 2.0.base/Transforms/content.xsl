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
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
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
                              xmlns:wwx="urn:WebWorks-Web-Extension-Schema"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:key name="wwsplits-files-by-groupid-type" match="wwsplits:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwsplits-frames-by-id" match="wwsplits:Frame" use="@id" />
 <xsl:key name="wwsplits-popups-by-id" match="wwsplits:Popup" use="@id" />
 <xsl:key name="wwtoc-entry-by-id" match="wwtoc:Entry" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-relatedtopic" match="wwbehaviors:Paragraph" use="@relatedtopic" />
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
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <!-- Content -->
  <!--         -->
  <xsl:apply-templates select="$ParamContent" mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template name="Content-RelatedTopics">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <!-- Related Topics -->
  <!--                -->
  <xsl:call-template name="RelatedTopics">
   <xsl:with-param name="ParamContent" select="$ParamContent" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="RelatedTopics">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarAllRelatedTopicParagraphsAsXML">
   <xsl:call-template name="RelatedTopicParagraphs">
    <xsl:with-param name="ParamContent" select="$ParamContent" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarAllRelatedTopicParagraphs" select="msxsl:node-set($VarAllRelatedTopicParagraphsAsXML)/wwdoc:Paragraph" />

  <xsl:variable name="VarRelatedTopicParagraphsAsXML">
   <xsl:call-template name="EliminateDuplicateRelatedTopicParagraphs">
    <xsl:with-param name="ParamRelatedTopicParagraphs" select="$VarAllRelatedTopicParagraphs" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarRelatedTopicParagraphs" select="msxsl:node-set($VarRelatedTopicParagraphsAsXML)/wwdoc:Paragraph" />

  <xsl:if test="count($VarRelatedTopicParagraphs) &gt; 0">
   <xsl:variable name="VarRelatedTopicsTitleText" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'RelatedTopics']/@value" />

   <html:div class="Related_Topics">
    <html:div class="Related_Topics_Title">
     <xsl:choose>
      <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-use-dropdown') = 'true'">
       <xsl:attribute name="id">
        <xsl:text>ww_related_topics</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="onclick">
        <xsl:text>WebWorks_ToggleDIV('ww_related_topics')</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="style">
        <xsl:text>cursor: pointer;</xsl:text>
       </xsl:attribute>

       <xsl:variable name="VarRelatedTopicsDropdownIconPosition" select="wwprojext:GetFormatSetting('page-related-topic-icon-position')" />
       <xsl:variable name="VarDropdownArrowClass">
        <xsl:choose>
         <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-dropdown-start-behavior') = 'start-open'">
          <xsl:text>ww_skin_page_dropdown_arrow_expanded</xsl:text>
         </xsl:when>
         <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-dropdown-start-behavior') = 'start-closed'">
          <xsl:text>ww_skin_page_dropdown_arrow_collapsed</xsl:text>
         </xsl:when>
        </xsl:choose>
       </xsl:variable>

       <xsl:if test="$VarRelatedTopicsDropdownIconPosition = 'left'">
        <xsl:if test="not($VarDropdownArrowClass = '')">
         <wwexsldoc:Text disable-output-escaping="yes">&lt;span id=&quot;ww_related_topics:dd:arrow&quot; class=&quot;ww_skin ww_skin_dropdown_arrow </wwexsldoc:Text>
         <xsl:value-of select="$VarDropdownArrowClass" />
         <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;&lt;i class=&quot;fa&quot;&gt;&lt;/i&gt;&lt;/span&gt;&#160;</wwexsldoc:Text>
        </xsl:if>
       </xsl:if>

       <xsl:value-of select="$VarRelatedTopicsTitleText" />

       <xsl:if test="$VarRelatedTopicsDropdownIconPosition = 'right'">
        <xsl:if test="not($VarDropdownArrowClass = '')">
         <wwexsldoc:Text disable-output-escaping="yes">&#160;&lt;span id=&quot;ww_related_topics:dd:arrow&quot; class=&quot;ww_skin ww_skin_dropdown_arrow </wwexsldoc:Text>
         <xsl:value-of select="$VarDropdownArrowClass" />
         <wwexsldoc:Text disable-output-escaping="yes">&quot; style=&quot;float: right;&quot;&gt;&lt;i class=&quot;fa&quot;&gt;&lt;/i&gt;&lt;/span&gt;</wwexsldoc:Text>
        </xsl:if>
       </xsl:if>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$VarRelatedTopicsTitleText" />
      </xsl:otherwise>
     </xsl:choose>
    </html:div>
    <html:div>
     <xsl:variable name="VarRelatedTopicsListDivClass">
      <xsl:choose>
       <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-use-dropdown') = 'false'">
        <xsl:text>Related_Topics_List</xsl:text>
       </xsl:when>
       <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-dropdown-start-behavior') = 'start-open'">
        <xsl:text>Related_Topics_List ww_skin_page_dropdown_div_expanded</xsl:text>
       </xsl:when>
       <xsl:when test="wwprojext:GetFormatSetting('page-related-topic-dropdown-start-behavior') = 'start-closed'">
        <xsl:text>Related_Topics_List ww_skin_page_dropdown_div_collapsed</xsl:text>
       </xsl:when>
       <xsl:otherwise>
        <xsl:text>Related_Topics_List</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <xsl:attribute name="class">
      <xsl:value-of select="$VarRelatedTopicsListDivClass"/>
     </xsl:attribute>

     <xsl:if test="wwprojext:GetFormatSetting('page-related-topic-use-dropdown') = 'true'">
      <xsl:attribute name="id">
       <xsl:text>ww_related_topics:dd</xsl:text>
      </xsl:attribute>
     </xsl:if>

     <xsl:for-each select="$VarRelatedTopicParagraphs">
      <xsl:variable name="VarRelatedTopicParagraph" select="." />

      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarRelatedTopicParagraph/@stylename, $ParamSplit/@documentID, $VarRelatedTopicParagraph/@id)" />
      <xsl:variable name="VarParagraphBehavior" select="$ParamCargo/wwbehaviors:Behaviors[1]" />

      <html:div class="Related_Topics_Entry">
       <html:i class="fa"></html:i>

       <xsl:for-each select="$VarRelatedTopicParagraph/wwdoc:TextRun">
        <xsl:variable name="VarTextRun" select="." />
        <xsl:call-template name="TextRunChildren">
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$ParamCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
        </xsl:call-template>
       </xsl:for-each>
      </html:div>
     </xsl:for-each>
    </html:div>
   </html:div>
  </xsl:if>
 </xsl:template>


 <xsl:template name="RelatedTopicParagraphs">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamSplit" />

  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarRelatedTopicBehaviorParagraphs" select="key('wwbehaviors-paragraphs-by-relatedtopic', 'define') | key('wwbehaviors-paragraphs-by-relatedtopic', 'define-no-output')" />

   <xsl:for-each select="$VarRelatedTopicBehaviorParagraphs[(@documentposition &gt;= $ParamSplit/@documentstartposition) and (@documentposition &lt;= $ParamSplit/@documentendposition)]">
    <xsl:variable name="VarBehaviorParagraph" select="." />

    <xsl:for-each select="$ParamContent[1]">
     <xsl:for-each select="key('wwdoc-paragraphs-by-id', $VarBehaviorParagraph/@id)[1]">
      <xsl:variable name="VarContentNode" select="." />

      <!-- Paragraph has link? -->
      <!--                     -->
      <xsl:variable name="VarChildLinks" select="$VarContentNode//wwdoc:Link[count($VarContentNode | ancestor::wwdoc:Paragraph[1]) = 1]" />
      <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
      <xsl:if test="$VarChildLinksCount &gt; 0">
       <!-- Emit paragraph -->
       <!--                -->
       <wwdoc:Paragraph>
        <xsl:copy-of select="$VarContentNode/@*" />

        <!-- Insure link is defined -->
        <!--                        -->
        <xsl:if test="count($VarContentNode/wwdoc:Link) = 0">
         <xsl:copy-of select="$VarChildLinks[1]" />
        </xsl:if>

        <xsl:copy-of select="$VarContentNode/*" />
       </wwdoc:Paragraph>
      </xsl:if>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="EliminateDuplicateRelatedTopicParagraphs">
  <xsl:param name="ParamRelatedTopicParagraphs" />

  <xsl:for-each select="$ParamRelatedTopicParagraphs">
   <xsl:variable name="VarRelatedTopicParagraph" select="." />

   <xsl:variable name="VarParagraphLinks" select="$VarRelatedTopicParagraph//wwdoc:Link" />
   <xsl:variable name="VarLink" select="$VarParagraphLinks[1]" />
   <xsl:variable name="VarMatchingLinks" select="key('wwlinks-by-anchor', $VarLink/@anchor)" />

   <!-- Preserve paragraph if it is the first unique link -->
   <!--                                                   -->
   <xsl:if test="count($VarLink | $VarMatchingLinks[1]) = 1">
    <xsl:copy-of select="$VarRelatedTopicParagraph" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Content-Notes">
  <xsl:param name="ParamNotes" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:if test="count($ParamNotes[1]) = 1">
   <html:hr style="clear: both" />

   <xsl:for-each select="$ParamNotes">
    <xsl:variable name="VarNote" select="." />

    <xsl:variable name="VarNoteNumber" select="$ParamCargo/wwnotes:NoteNumbering/wwnotes:Note[@id = $VarNote/@id]/@number" />

    <xsl:if test="string-length($VarNoteNumber) &gt; 0">
     <xsl:apply-templates select="$VarNote/*" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:apply-templates>
     <html:br style="clear: both" />
    </xsl:if>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Content-Bullet">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamCharacter" />
  <xsl:param name="ParamImage" />
  <xsl:param name="ParamSeparator" />
  <xsl:param name="ParamStyle" />

  <xsl:choose>
   <xsl:when test="string-length($ParamStyle) &gt; 0">

    <!-- Get rule -->
    <!--          -->
    <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $ParamStyle)" />

    <!-- Resolve project properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedContextPropertiesAsXML">
     <xsl:call-template name="Properties-ResolveContextRule">
      <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
      <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyle" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
      <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Number[1]/wwdoc:Style" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

    <!-- CSS properties -->
    <!--                -->
    <xsl:variable name="VarCSSPropertiesAsXML">
     <xsl:call-template name="CSS-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
      <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

    <!-- Style attribute -->
    <!--                 -->
    <xsl:variable name="VarStyleAttribute">
     <xsl:call-template name="CSS-InlineProperties">
      <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="VarTagProperty" select="$VarRule/wwproject:Properties/wwproject:Property[@Name = 'tag']/@Value" />
    <xsl:variable name="VarTag">
     <xsl:choose>
      <xsl:when test="string-length($VarTagProperty) &gt; 0">
       <xsl:value-of select="$VarTagProperty" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="'span'" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
     <!-- Emit class using Character stylename plus 'Additional CSS classes' -->
     <!--                                                                    -->
     <xsl:variable name="VarClassAttribute">
      <xsl:if test="string-length($ParamStyle)">
       <xsl:value-of select="wwstring:CSSClassName($ParamStyle)" />
      </xsl:if>

      <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($VarRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
      <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
       <xsl:text> </xsl:text>
       <xsl:value-of select="$VarAdditionalCSSClassesOption" />
      </xsl:if>
     </xsl:variable>

     <!-- Class attribute -->
     <!--                 -->
     <xsl:if test ="string-length($VarClassAttribute)">
      <xsl:attribute name="class">
       <xsl:value-of select="$VarClassAttribute" />
      </xsl:attribute>
     </xsl:if>

     <!-- Style attribute -->
     <!--                 -->
     <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
      <xsl:attribute name="style">
       <xsl:value-of select="$VarStyleAttribute" />
      </xsl:attribute>
     </xsl:if>

     <xsl:if test="string-length($ParamImage) &gt; 0">
      <!-- Get absolute path for imaging info -->
      <!--                                    -->
      <xsl:variable name="VarReplacedGroupName">
       <xsl:call-template name="ReplaceGroupNameSpacesWith">
        <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplit/@groupID)" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarImageFileSystemPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'), $ParamImage)" />
      <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImageFileSystemPath)" />

      <xsl:variable name="VarImagePath">
       <xsl:call-template name="URI-ResolveProjectFileURI">
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamURI" select="$ParamImage" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Image -->
      <!--       -->
      <html:img src="{$VarImagePath}" alt="*" border="0" width="{$VarImageInfo/@width}" height="{$VarImageInfo/@height}" />
     </xsl:if>

     <!-- Characters -->
     <!--            -->
     <xsl:value-of select="$ParamCharacter" />

     <!-- Separator -->
     <!--           -->
     <xsl:value-of select="$ParamSeparator" />
    </xsl:element>
   </xsl:when>

   <xsl:otherwise>
    <html:span>
     <xsl:if test="string-length($ParamImage) &gt; 0">
      <!-- Get absolute path for imaging info -->
      <!--                                    -->
      <xsl:variable name="VarReplacedGroupName">
       <xsl:call-template name="ReplaceGroupNameSpacesWith">
        <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamSplit/@groupID)" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarImageFileSystemPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'), $ParamImage)" />
      <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImageFileSystemPath)" />

      <xsl:variable name="VarImagePath">
       <xsl:call-template name="URI-ResolveProjectFileURI">
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamURI" select="$ParamImage" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Image -->
      <!--       -->
      <html:img src="{$VarImagePath}" alt="*" border="0" width="{$VarImageInfo/@width}" height="{$VarImageInfo/@height}" />
     </xsl:if>

     <!-- Characters -->
     <!--            -->
     <xsl:value-of select="$ParamCharacter" />

     <!-- Separator -->
     <!--           -->
     <xsl:value-of select="$ParamSeparator" />
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
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
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarList" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarList/@stylename, $ParamSplit/@documentID, $VarList/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarList/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarListBehavior/@popup = 'define-no-output') or ($VarListBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarListBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- List -->
      <!--      -->
      <xsl:call-template name="List">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamList" select="$VarList" />
       <xsl:with-param name="ParamStyleName" select="$VarList/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListBehavior" select="$VarListBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="List">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamList" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamList/wwdoc:Style" />
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

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamList/@stylename, $ParamSplit/@documentID, $ParamList/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamList" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamList/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamList/wwdoc:Style" />
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

  <xsl:variable name="VarIsOrdered" select="$ParamList/@ordered = 'True'" />

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTagProperty" select="$VarResolvedContextProperties[@Name = 'tag']/@Value" />
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="string-length($VarTagProperty) &gt; 0">
     <xsl:value-of select="$VarTagProperty" />
    </xsl:when>
    <xsl:when test="$VarIsOrdered">
     <xsl:value-of select="'ol'" />
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="'ul'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Begin list emit -->
  <!--                 -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- ID -->
   <!--    -->
   <xsl:attribute name="id">
    <xsl:text>ww</xsl:text>
    <xsl:value-of select="$ParamList/@id" />
   </xsl:attribute>

   <!-- Class attribute -->
   <!--                 -->
   <xsl:attribute name="class">
    <xsl:value-of select="wwstring:CSSClassName($ParamStyleName)" />

    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
     <xsl:text> </xsl:text>
     <xsl:value-of select="$VarAdditionalCSSClassesOption" />
    </xsl:if>
   </xsl:attribute>

   <!-- Style attribute -->
   <!--                 -->
   <xsl:variable name="VarStyleAttribute">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
    <xsl:attribute name="style">
     <xsl:value-of select="$VarStyleAttribute" />
    </xsl:attribute>
   </xsl:if>

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamList/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End list emit -->
   <!--               -->
  </xsl:element>

  <xsl:variable name="VarDropdownDivClass">
   <xsl:choose>
    <xsl:when test="$ParamListBehavior/@dropdown = 'start-open'">
     <xsl:text>ww_skin_page_dropdown_div_expanded</xsl:text>
    </xsl:when>
    <xsl:when test="$ParamListBehavior/@dropdown = 'start-closed'">
     <xsl:text>ww_skin_page_dropdown_div_collapsed</xsl:text>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <!-- Dropdown Start -->
  <!--                -->
  <xsl:if test="not($VarDropdownDivClass = '')">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;div id=&quot;ww</wwexsldoc:Text>
   <xsl:value-of select="$ParamList/@id" />
   <wwexsldoc:Text disable-output-escaping="yes">:dd&quot; class=&quot;</wwexsldoc:Text>
   <xsl:value-of select="$VarDropdownDivClass"/>
   <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;</wwexsldoc:Text>
  </xsl:if>

  <!-- Dropdown End -->
  <!--              -->
  <xsl:if test="$ParamListBehavior/@dropdown = 'end'">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;/div&gt;</wwexsldoc:Text>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarListItem" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarListItem/@stylename, $ParamSplit/@documentID, $VarListItem/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListItemBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarListItem/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarListItemBehavior/@popup = 'define-no-output') or ($VarListItemBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarListItemBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- ListItem -->
      <!--          -->
      <xsl:call-template name="ListItem">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamListItem" select="$VarListItem" />
       <xsl:with-param name="ParamStyleName" select="$VarListItem/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListItemBehavior" select="$VarListItemBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="ListItem">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamListItem" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListItemBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamListItem/wwdoc:Style" />
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

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamListItem/@stylename, $ParamSplit/@documentID, $ParamListItem/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamListItem" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamListItem/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamListItem/wwdoc:Style" />
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

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTagProperty" select="$VarResolvedContextProperties[@Name = 'tag']/@Value" />
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="string-length($VarTagProperty) &gt; 0">
     <xsl:value-of select="$VarTagProperty" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'li'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Begin list item emit -->
  <!--                       -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- ID -->
   <!--    -->
   <xsl:attribute name="id">
    <xsl:text>ww</xsl:text>
    <xsl:value-of select="$ParamListItem/@id" />
   </xsl:attribute>

   <!-- Class attribute -->
   <!--                 -->
   <xsl:attribute name="class">
    <xsl:value-of select="wwstring:CSSClassName($ParamStyleName)" />

    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
     <xsl:text> </xsl:text>
     <xsl:value-of select="$VarAdditionalCSSClassesOption" />
    </xsl:if>
   </xsl:attribute>

   <xsl:attribute name="value">
    <xsl:value-of select="$ParamListItem/@number"/>
   </xsl:attribute>

   <!-- Style attribute -->
   <!--                 -->
   <xsl:variable name="VarStyleAttribute">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
    <xsl:attribute name="style">
     <xsl:value-of select="$VarStyleAttribute" />
    </xsl:attribute>
   </xsl:if>

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamListItem/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End list item emit -->
   <!--                    -->
  </xsl:element>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarBlock" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarBlock/@stylename, $ParamSplit/@documentID, $VarBlock/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarBlockBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarBlock/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarBlockBehavior/@popup = 'define-no-output') or ($VarBlockBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarBlockBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- Block -->
      <!--       -->
      <xsl:call-template name="Block">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamBlock" select="$VarBlock" />
       <xsl:with-param name="ParamStyleName" select="$VarBlock/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamBlockBehavior" select="$VarBlockBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Block">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData"/>
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBlock" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamBlockBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamBlock/wwdoc:Style" />
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

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamBlock/@stylename, $ParamSplit/@documentID, $ParamBlock/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamBlock" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamBlock/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamBlock/wwdoc:Style" />
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

  <!-- Begin Block item emit -->
  <!--                       -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- ID -->
   <!--    -->
   <xsl:attribute name="id">
    <xsl:text>ww</xsl:text>
    <xsl:value-of select="$ParamBlock/@id" />
   </xsl:attribute>

   <!-- Class attribute -->
   <!--                 -->
   <xsl:attribute name="class">
    <xsl:value-of select="wwstring:CSSClassName($ParamStyleName)" />

    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
     <xsl:text> </xsl:text>
     <xsl:value-of select="$VarAdditionalCSSClassesOption" />
    </xsl:if>
   </xsl:attribute>

   <!-- Style attribute -->
   <!--                 -->
   <xsl:variable name="VarStyleAttribute">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
    <xsl:attribute name="style">
     <xsl:value-of select="$VarStyleAttribute" />
    </xsl:attribute>
   </xsl:if>

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamBlock/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End quote emit -->
   <!--                -->
  </xsl:element>

   <xsl:variable name="VarDropdownDivClass">
   <xsl:choose>
    <xsl:when test="$ParamBlockBehavior/@dropdown = 'start-open'">
     <xsl:text>ww_skin_page_dropdown_div_expanded</xsl:text>
    </xsl:when>
    <xsl:when test="$ParamBlockBehavior/@dropdown = 'start-closed'">
     <xsl:text>ww_skin_page_dropdown_div_collapsed</xsl:text>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <!-- Dropdown Start -->
  <!--                -->
  <xsl:if test="not($VarDropdownDivClass = '')">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;div id=&quot;ww</wwexsldoc:Text>
   <xsl:value-of select="$ParamBlock/@id" />
   <wwexsldoc:Text disable-output-escaping="yes">:dd&quot; class=&quot;</wwexsldoc:Text>
   <xsl:value-of select="$VarDropdownDivClass"/>
   <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;</wwexsldoc:Text>
  </xsl:if>

  <!-- Dropdown End -->
  <!--              -->
  <xsl:if test="$ParamBlockBehavior/@dropdown = 'end'">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;/div&gt;</wwexsldoc:Text>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarParagraph" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarParagraph/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarParagraphBehavior/@popup = 'define-no-output') or ($VarParagraphBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarParagraphBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
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

      <!-- MiniTOC -->
      <!--         -->
      <xsl:if test="not($VarInPopupPage)">
       <xsl:variable name="VarMiniTOCSubLevels" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'minitoc-sublevels']/@Value" />
       <xsl:variable name="VarMiniTOCSubLevelsNumericPrefix" select="wwunits:NumericPrefix($VarMiniTOCSubLevels)" />
       <xsl:variable name="VarMiniTOCSubLevelsGreaterThanZero" select="(string-length($VarMiniTOCSubLevelsNumericPrefix) &gt; 0) and (number($VarMiniTOCSubLevelsNumericPrefix) &gt; 0)" />
       <xsl:if test="($VarMiniTOCSubLevelsGreaterThanZero) or ($VarMiniTOCSubLevels = 'all')">
        <xsl:for-each select="$ParamTOCData[1]">
         <xsl:variable name="VarTOCEntry" select="key('wwtoc-entry-by-id', $VarParagraph/@id)[@documentID = $ParamSplit/@documentID]" />
         <xsl:for-each select="$VarTOCEntry[1]">
          <xsl:call-template name="MiniTOC">
           <xsl:with-param name="ParamSplit" select="$ParamSplit" />
           <xsl:with-param name="ParamTOCEntry" select="$VarTOCEntry[1]" />
           <xsl:with-param name="ParamEmitTOCEntry" select="false()" />
           <xsl:with-param name="ParamMiniTOCSubLevels" select="$VarMiniTOCSubLevels" />
          </xsl:call-template>
         </xsl:for-each>
        </xsl:for-each>
       </xsl:if>
      </xsl:if>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template name="MiniTOC">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCEntry" />
  <xsl:param name="ParamEmitTOCEntry" />
  <xsl:param name="ParamMiniTOCSubLevels" />

  <xsl:if test="($ParamEmitTOCEntry = true()) or (count($ParamTOCEntry/wwtoc:Entry[1]) = 1)">
   <html:div class="WebWorks_MiniTOC">
    <!-- Emit MiniTOC cap -->
    <!--                  -->
    <html:div class="WebWorks_MiniTOC_Heading">&#160;</html:div>

    <!-- Emit top-level entry? -->
    <!--                       -->
    <xsl:choose>
     <xsl:when test="$ParamEmitTOCEntry = true()">
      <html:dl class="WebWorks_MiniTOC_List">
       <html:dd>
        <!-- Paragraph -->
        <!--           -->
        <html:div class="WebWorks_MiniTOC_Entry">
         <xsl:call-template name="MiniTOCParagraph">
          <xsl:with-param name="ParamParagraph" select="$ParamTOCEntry/wwdoc:Paragraph" />
         </xsl:call-template>
        </html:div>
       </html:dd>

       <!-- Children -->
       <!--          -->
       <xsl:call-template name="MiniTOCEntries">
        <xsl:with-param name="ParamReferencePath" select="$ParamSplit/@path" />
        <xsl:with-param name="ParamParent" select="$ParamTOCEntry" />
        <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
       </xsl:call-template>
      </html:dl>
     </xsl:when>

     <xsl:otherwise>
      <!-- Children -->
      <!--          -->
      <xsl:call-template name="MiniTOCEntries">
       <xsl:with-param name="ParamReferencePath" select="$ParamSplit/@path" />
       <xsl:with-param name="ParamParent" select="$ParamTOCEntry" />
       <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </html:div>
  </xsl:if>
 </xsl:template>


 <xsl:template name="MiniTOCEntries">
  <xsl:param name="ParamReferencePath" />
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamMiniTOCSubLevels" />

  <xsl:variable name="VarSubEntries" select="$ParamParent/wwtoc:Entry" />

  <xsl:for-each select="$VarSubEntries[1]">
   <html:dl class="WebWorks_MiniTOC_List">

    <xsl:for-each select="$VarSubEntries">
     <xsl:variable name="VarEntry" select="." />

     <html:dd>
      <html:div class="WebWorks_MiniTOC_Entry">
       <xsl:choose>
        <xsl:when test="string-length($VarEntry/@path) &gt; 0">
         <!-- Get link -->
         <!--          -->
         <xsl:variable name="VarRelativeLinkPath">
          <xsl:call-template name="Connect-URI-GetRelativeTo">
           <xsl:with-param name="ParamDestinationURI" select="$VarEntry/@path" />
           <xsl:with-param name="ParamSourceURI" select="$ParamReferencePath" />
          </xsl:call-template>
         </xsl:variable>

         <html:a class="WebWorks_MiniTOC_Link">
          <xsl:attribute name="href">
           <xsl:value-of select="$VarRelativeLinkPath" />
           <xsl:text>#</xsl:text>
           <xsl:if test="string-length($VarEntry/@linkid) &gt; 0">
            <xsl:text>ww</xsl:text>
            <xsl:choose>
             <xsl:when test="$VarEntry/@first != 'true'">
              <xsl:value-of select="$VarEntry/@linkid" />
             </xsl:when>

             <xsl:otherwise>
              <xsl:text>connect_header</xsl:text>
             </xsl:otherwise>
            </xsl:choose>
           </xsl:if>
          </xsl:attribute>

          <xsl:call-template name="MiniTOCParagraph">
           <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
          </xsl:call-template>
         </html:a>
        </xsl:when>

        <xsl:otherwise>
         <xsl:call-template name="MiniTOCParagraph">
          <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </html:div>
     </html:dd>

     <!-- Recurse -->
     <!--         -->
     <xsl:choose>
      <xsl:when test="$ParamMiniTOCSubLevels = 'all'">
       <xsl:call-template name="MiniTOCEntries">
        <xsl:with-param name="ParamReferencePath" select="$ParamReferencePath" />
        <xsl:with-param name="ParamParent" select="$VarEntry" />
        <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
       </xsl:call-template>
      </xsl:when>

      <xsl:when test="($ParamMiniTOCSubLevels - 1) &gt; 0">
       <xsl:call-template name="MiniTOCEntries">
        <xsl:with-param name="ParamReferencePath" select="$ParamReferencePath" />
        <xsl:with-param name="ParamParent" select="$VarEntry" />
        <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels - 1" />
       </xsl:call-template>
      </xsl:when>
     </xsl:choose>
    </xsl:for-each>

   </html:dl>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="MiniTOCParagraph">
  <xsl:param name="ParamParagraph" />

  <xsl:for-each select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph//wwdoc:TextRun/wwdoc:Text">
   <xsl:value-of select="@value" />
  </xsl:for-each>
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

  <!-- First note paragraph? -->
  <!--                       -->
  <xsl:variable name="VarFirstNoteParagraph" select="(count($ParamParagraph/parent::wwdoc:Note) = 1) and (count($ParamParagraph | $ParamParagraph/parent::wwdoc:Note/wwdoc:Paragraph[1]) = 1)" />

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

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Handle small screen device layouts -->
  <!--                                    -->
  <xsl:variable name="VarParagraphNeedsOverflowWrapper">
   <xsl:variable name="VarParagraphHasTable">
    <xsl:if test="count($ParamParagraph//wwdoc:Table[1]) &gt; 0">
     <xsl:text>true</xsl:text>
    </xsl:if>
   </xsl:variable>
   <xsl:variable name="VarParagraphHasNonInlineImage">
    <xsl:if test="count($ParamParagraph//wwdoc:Frame[1]) &gt; 0">
     <xsl:choose>
      <xsl:when test="count($ParamParagraph//wwdoc:Frame[1]//wwdoc:Attribute[@name='display' and @value='inline']) &gt; 0">
       <xsl:text>false</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <xsl:text>true</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
   </xsl:variable>

   <xsl:if test="$VarParagraphHasTable = 'true' or $VarParagraphHasNonInlineImage = 'true'">
    <xsl:text>true</xsl:text>
   </xsl:if>
  </xsl:variable>

  <xsl:if test="$VarParagraphNeedsOverflowWrapper = 'true'">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;div class="ww_skin_page_overflow"</wwexsldoc:Text>
   <xsl:if test="string-length($VarResolvedContextProperties[@Name = 'clear']/@Value) &gt; 0">
    <wwexsldoc:Text disable-output-escaping="yes"> style=&quot;clear: <xsl:value-of select="$VarResolvedContextProperties[@Name = 'clear']/@Value" />&quot;</wwexsldoc:Text>
   </xsl:if>
   <wwexsldoc:Text disable-output-escaping="yes">&gt;</wwexsldoc:Text>
  </xsl:if>

  <!-- Begin paragraph emit -->
  <!--                      -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- ID -->
   <!--    -->
   <xsl:attribute name="id">
    <xsl:text>ww</xsl:text>
    <xsl:value-of select="$ParamParagraph/@id" />
   </xsl:attribute>

   <!-- Class attribute -->
   <!--                 -->
   <xsl:attribute name="class">
    <xsl:value-of select="wwstring:CSSClassName($ParamStyleName)" />

    <!-- Additional CSS classes -->
    <!--                        -->
    <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
    <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
     <xsl:text> </xsl:text>
     <xsl:value-of select="$VarAdditionalCSSClassesOption" />
    </xsl:if>
   </xsl:attribute>

   <!-- Style attribute -->
   <!--                 -->
   <xsl:variable name="VarStyleAttribute">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
    <xsl:attribute name="style">
     <xsl:value-of select="$VarStyleAttribute" />
    </xsl:attribute>
   </xsl:if>

   <!-- Cite attribute -->
   <!--                -->
   <xsl:if test="string-length($VarCitation) &gt; 0">
    <xsl:attribute name="cite">
     <xsl:value-of select="$VarCitation" />
    </xsl:attribute>
   </xsl:if>

   <!-- Dropdown -->
   <!--          -->
   <xsl:if test="($ParamParagraphBehavior/@dropdown = 'start-open') or ($ParamParagraphBehavior/@dropdown = 'start-closed')">
    <xsl:attribute name="onclick">
     <xsl:text>WebWorks_ToggleDIV('ww</xsl:text>
     <xsl:value-of select="$ParamParagraph/@id" />
     <xsl:text>')</xsl:text>
    </xsl:attribute>
   </xsl:if>

   <!-- Dropdown Toggle -->
   <!--                 -->
   <xsl:variable name="VarDropdownToggleIconPositionOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'dropdown-toggle-icon-position']/@Value" />
   <xsl:if test="$VarDropdownToggleIconPositionOption = 'left'">
    <xsl:variable name="VarDropdownArrowClass">
     <xsl:choose>
      <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-open'">
       <xsl:text>ww_skin_page_dropdown_arrow_expanded</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-closed'">
       <xsl:text>ww_skin_page_dropdown_arrow_collapsed</xsl:text>
      </xsl:when>
     </xsl:choose>
    </xsl:variable>

    <xsl:if test="not($VarDropdownArrowClass = '')">
     <wwexsldoc:Text disable-output-escaping="yes">&lt;span id=&quot;ww</wwexsldoc:Text>
     <xsl:value-of select="$ParamParagraph/@id" />
     <wwexsldoc:Text disable-output-escaping="yes">:dd:arrow&quot; class=&quot;ww_skin ww_skin_dropdown_arrow </wwexsldoc:Text>
     <xsl:value-of select="$VarDropdownArrowClass" />
     <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;&lt;i class=&quot;fa&quot;&gt;&lt;/i&gt;&lt;/span&gt;&#160;</wwexsldoc:Text>
    </xsl:if>
   </xsl:if>

   <!-- Use numbering? -->
   <!--                -->
   <xsl:if test="$VarUseNumbering">
    <!-- Numbering present? -->
    <!--                    -->
    <xsl:if test="(string-length($VarBulletStyle) &gt; 0) or (count($ParamParagraph/wwdoc:Number[1]) &gt; 0) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)">
     <!-- Force on same line as containing block level tag -->
     <!--                                                  -->
     <wwexsldoc:NoBreak />

     <xsl:choose>
      <!-- Emit as inline block span -->
      <!--                           -->
      <xsl:when test="$VarTextIndentLessThanZero">
       <xsl:variable name="VarTextIndentNumberAsUnits" select="wwunits:NumericPrefix($VarTextIndent)" />
       <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($VarTextIndent)" />

       <html:span class="WebWorks_Number" style="width: {0 - $VarTextIndentNumberAsUnits}{$VarTextIndentUnits}">
        <!-- Force on same line as containing div -->
        <!--                                      -->
        <wwexsldoc:NoBreak />

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
       </html:span>
      </xsl:when>

      <!-- Emit as part of paragraph -->
      <!--                           -->
      <xsl:otherwise>
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
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
   </xsl:if>

   <!-- Note? -->
   <!--       -->
   <xsl:if test="$VarFirstNoteParagraph">
    <xsl:variable name="VarNote" select="$ParamParagraph/parent::wwdoc:Note" />
    <xsl:variable name="VarNoteNumber" select="$ParamCargo/wwnotes:NoteNumbering/wwnotes:Note[@id = $VarNote/@id]/@number" />

    <xsl:if test="string-length($VarNoteNumber) &gt; 0">
     <!-- Force on same line as containing block level tag -->
     <!--                                                  -->
     <wwexsldoc:NoBreak />

     <xsl:choose>
      <!-- Emit as floating paragraph -->
      <!--                            -->
      <xsl:when test="$VarTextIndentLessThanZero">
       <xsl:variable name="VarTextIndentNumberAsUnits" select="wwunits:NumericPrefix($VarTextIndent)" />
       <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($VarTextIndent)" />

       <html:span class="WebWorks_Number" style="width: {0 - $VarTextIndentNumberAsUnits}{$VarTextIndentUnits}">
        <!-- Force on same line as containing div -->
        <!--                                      -->
        <wwexsldoc:NoBreak />

        <html:sup id="ww{$VarNote/@id}">
         <!-- Force anchor on same line as containing span -->
         <!--                                              -->
         <wwexsldoc:NoBreak />
         <html:a>
          <xsl:attribute name="href">
           <xsl:text>#wwfootnote_inline_</xsl:text>
           <xsl:value-of select="$VarNote/@id" />
          </xsl:attribute>

          <xsl:value-of select="$VarNoteNumber"/>
         </html:a>
        </html:sup>
        <xsl:text> </xsl:text>
       </html:span>
      </xsl:when>

      <!-- Emit as part of paragraph -->
      <!--                           -->
      <xsl:otherwise>
       <html:sup id="ww{$VarNote/@id}">
        <!-- Force anchor on same line as containing span -->
        <!--                                              -->
        <wwexsldoc:NoBreak />
        <html:a>
         <xsl:attribute name="href">
          <xsl:text>#wwfootnote_inline_</xsl:text>
          <xsl:value-of select="$VarNote/@id" />
         </xsl:attribute>

         <xsl:value-of select="$VarNoteNumber"/>
        </html:a>
       </html:sup>
       <xsl:text> </xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
   </xsl:if>

   <!-- Text Runs -->
   <!--           -->
   <xsl:call-template name="ParagraphTextRuns">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
    <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
    <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
   </xsl:call-template>

   <!-- Dropdown Arrow -->
   <!--                -->
   <xsl:if test="$VarDropdownToggleIconPositionOption = 'right'">
    <xsl:variable name="VarDropdownArrowClass">
     <xsl:choose>
      <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-open'">
       <xsl:text>ww_skin_page_dropdown_arrow_expanded</xsl:text>
      </xsl:when>
      <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-closed'">
       <xsl:text>ww_skin_page_dropdown_arrow_collapsed</xsl:text>
      </xsl:when>
     </xsl:choose>
    </xsl:variable>

    <xsl:if test="not($VarDropdownArrowClass = '')">
     <wwexsldoc:Text disable-output-escaping="yes">&#160;&lt;span id=&quot;ww</wwexsldoc:Text>
     <xsl:value-of select="$ParamParagraph/@id" />
     <wwexsldoc:Text disable-output-escaping="yes">:dd:arrow&quot; class=&quot;ww_skin ww_skin_dropdown_arrow </wwexsldoc:Text>
     <xsl:value-of select="$VarDropdownArrowClass" />
     <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;&lt;i class=&quot;fa&quot;&gt;&lt;/i&gt;&lt;/span&gt;</wwexsldoc:Text>
    </xsl:if>
   </xsl:if>

   <!-- End paragraph emit -->
   <!--                    -->
  </xsl:element>

  <!-- Handle small screen device layouts -->
  <!--                                    -->
  <xsl:if test="$VarParagraphNeedsOverflowWrapper = 'true'">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;/div&gt;</wwexsldoc:Text>
  </xsl:if>

  <xsl:variable name="VarDropdownDivClass">
   <xsl:choose>
    <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-open'">
     <xsl:text>ww_skin_page_dropdown_div_expanded</xsl:text>
    </xsl:when>
    <xsl:when test="$ParamParagraphBehavior/@dropdown = 'start-closed'">
     <xsl:text>ww_skin_page_dropdown_div_collapsed</xsl:text>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <!-- Dropdown Start -->
  <!--                -->
  <xsl:if test="not($VarDropdownDivClass = '')">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;div id=&quot;ww</wwexsldoc:Text>
   <xsl:value-of select="$ParamParagraph/@id" />
   <wwexsldoc:Text disable-output-escaping="yes">:dd&quot; class=&quot;</wwexsldoc:Text>
   <xsl:value-of select="$VarDropdownDivClass"/>
   <wwexsldoc:Text disable-output-escaping="yes">&quot;&gt;</wwexsldoc:Text>
  </xsl:if>

   <!-- Dropdown End -->
   <!--              -->
   <xsl:if test="$ParamParagraphBehavior/@dropdown = 'end'">
    <wwexsldoc:Text disable-output-escaping="yes">&lt;/div&gt;</wwexsldoc:Text>
   </xsl:if>
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

  <xsl:choose>
   <xsl:when test="$ParamIgnoreDocumentNumber">
    <xsl:call-template name="Content-Bullet">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamCharacter" select="$ParamCharacter" />
     <xsl:with-param name="ParamImage" select="$ParamImage" />
     <xsl:with-param name="ParamSeparator" select="$ParamSeparator" />
     <xsl:with-param name="ParamStyle" select="$ParamStyle" />
    </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
    <xsl:variable name="VarBulletPropertiesAsXML">
     <wwproject:BulletProperties>
      <wwproject:Property Name="bullet-style" Value="{$ParamStyle}" />
      <wwproject:Property Name="bullet-separator" Value="{$ParamSeparator}" />
     </wwproject:BulletProperties>
    </xsl:variable>
    <xsl:variable name="VarBulletProperties" select="msxsl:node-set($VarBulletPropertiesAsXML)" />

    <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'BulletProperties']/.. | $VarBulletProperties" />

    <xsl:call-template name="TextRun">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$VarCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
     <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
     <xsl:with-param name="ParamTextRun" select="$ParamParagraph/wwdoc:Number[1]" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
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
    <xsl:if test="$ParamPreserveEmpty">
     <wwexsldoc:NoBreak />&#160;<wwexsldoc:NoBreak />
    </xsl:if>
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
    <xsl:variable name="VarIsReverbLink" select="wwstring:MatchExpression($ParamDocumentLink/@anchor, '^(context|search|page)/')" />
    <xsl:variable name="VarIsExternalLink" select="wwstring:MatchExpression($ParamDocumentLink/@url, '^(http)|^[^#]*[/]')" />

    <!-- Resolve link -->
    <!--              -->
    <xsl:variable name="VarResolvedLinkInfoAsXML">
     <!-- Runtime Reverb Link? -->
     <!--                      -->
     <xsl:choose>
      <xsl:when test="($VarIsReverbLink = true()) and ($VarIsExternalLink = false())">
       <wwlinks:ResolvedLink type="url">
        <!-- @anchor attribute -->
        <!--                   -->
        <xsl:attribute name="url">
         <xsl:text>#</xsl:text><xsl:value-of select="$ParamDocumentLink/@anchor" />
        </xsl:attribute>

        <!-- @title attribute -->
        <!--                  -->
        <xsl:call-template name="Link-Description-As-Title-Attribute">
         <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
        </xsl:call-template>
       </wwlinks:ResolvedLink>
      </xsl:when>

      <xsl:otherwise>
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
      </xsl:otherwise>
     </xsl:choose>
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
      <xsl:variable name="VarRelativePath">
       <xsl:call-template name="Connect-URI-GetRelativeTo">
        <xsl:with-param name="ParamDestinationURI" select="$VarResolvedLinkInfo/@path" />
        <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
       </xsl:call-template>
      </xsl:variable>

      <xsl:attribute name="href">
       <xsl:value-of select="$VarRelativePath" />
       <xsl:if test="string-length($ParamDocumentLink/@anchor) &gt; 0">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$ParamDocumentLink/@anchor" />
       </xsl:if>
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
       <xsl:variable name="VarRelativePath">
        <xsl:call-template name="Connect-URI-GetRelativeTo">
         <xsl:with-param name="ParamDestinationURI" select="$VarResolvedLinkInfo/@path" />
         <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
        </xsl:call-template>
       </xsl:variable>

       <xsl:value-of select="$VarRelativePath" />
       <xsl:text>#</xsl:text>
       <xsl:if test="(string-length($ParamDocumentLink/@anchor) &gt; 0) and (string-length($VarResolvedLinkInfo/@linkid) &gt; 0)">
        <xsl:text>ww</xsl:text>
        <xsl:choose>
         <xsl:when test="$VarResolvedLinkInfo/@first != 'true'">
          <xsl:value-of select="$VarResolvedLinkInfo/@linkid" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:text>connect_header</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:if>
      </xsl:attribute>

      <!-- Popup -->
      <!--       -->
      <xsl:if test="($VarResolvedLinkInfo/@popup = 'true') or
                    ($VarResolvedLinkInfo/@popup-only = 'true')">
       <xsl:variable name="VarOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression(wwstring:Replace(wwprojext:GetGroupName($VarResolvedLinkInfo/@groupID), $GlobalFilenameSpacesToUnderscoresSearchString, $GlobalFilenameSpacesToUnderscoresReplaceString), $GlobalInvalidPathCharactersExpression, '_'))" />
       <xsl:variable name="VarPopupPath">
        <xsl:for-each select="$GlobalProjectSplits[1]">
         <xsl:variable name="VarSplitsPopups" select="key('wwsplits-popups-by-id', $VarResolvedLinkInfo/@linkid)[@documentID = $VarResolvedLinkInfo/@documentID]" />
         <xsl:for-each select="$VarSplitsPopups[1]">
          <xsl:variable name="VarSplitsPopup" select="." />

          <xsl:value-of select="wwuri:GetRelativeTo($VarSplitsPopup/@path, wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), 'dummy.component'))" />
         </xsl:for-each>
        </xsl:for-each>
       </xsl:variable>

       <xsl:attribute name="data-popup-href">
        <xsl:value-of select="$VarPopupPath" />
       </xsl:attribute>
      </xsl:if>

     </xsl:when>

     <!-- URL -->
     <!--     -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'url'">
      <xsl:attribute name="href">
       <xsl:value-of select="$VarResolvedLinkInfo/@url" />
      </xsl:attribute>

      <!-- External URL Target -->
      <!--                     -->
      <xsl:if test="($VarIsExternalLink = true()) or (not(wwuri:IsFile($VarResolvedLinkInfo/@url)) and not($VarIsReverbLink = true()))">
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

  <xsl:choose>
   <xsl:when test="($ParamUseCharacterStyles) and ((string-length($VarStyleName) &gt; 0) or (count($ParamTextRun/wwdoc:Style) = 1))">
    <!-- Get override rule -->
    <!--                   -->
    <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Character', $VarStyleName, $ParamSplit/@documentID, $ParamTextRun/@id)" />

    <!-- Resolve project properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedPropertiesAsXML">
     <xsl:call-template name="Properties-ResolveOverrideRule">
      <xsl:with-param name="ParamProperties" select="$VarOverrideRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamContextStyle" select="$ParamTextRun/wwdoc:Style" />
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

    <!-- Abbreviation -->
    <!--              -->
    <xsl:variable name="VarAbbreviationTitle">
     <xsl:call-template name="Behaviors-Options-OptionMarker">
      <xsl:with-param name="ParamContainer" select="$ParamTextRun" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
      <xsl:with-param name="ParamRule" select="$ParamRule" />
      <xsl:with-param name="ParamOption" select="'abbreviation'" />
     </xsl:call-template>
    </xsl:variable>

    <!-- Acronym -->
    <!--         -->
    <xsl:variable name="VarAcronymTitle">
     <xsl:call-template name="Behaviors-Options-OptionMarker">
      <xsl:with-param name="ParamContainer" select="$ParamTextRun" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
      <xsl:with-param name="ParamRule" select="$ParamRule" />
      <xsl:with-param name="ParamOption" select="'acronym'" />
     </xsl:call-template>
    </xsl:variable>

    <!-- Citation -->
    <!--          -->
    <xsl:variable name="VarCitation">
     <xsl:call-template name="Behaviors-Options-OptionMarker">
      <xsl:with-param name="ParamContainer" select="$ParamTextRun" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
      <xsl:with-param name="ParamRule" select="$ParamRule" />
      <xsl:with-param name="ParamOption" select="'citation'" />
     </xsl:call-template>
    </xsl:variable>

    <!-- Tag -->
    <!--     -->
    <xsl:variable name="VarTagProperty" select="$ParamRule/wwproject:Properties/wwproject:Property[@Name = 'tag']/@Value" />
    <xsl:variable name="VarTag">
     <xsl:choose>
      <xsl:when test="string-length($VarAbbreviationTitle) &gt; 0">
       <xsl:value-of select="'abbr'" />
      </xsl:when>
      <xsl:when test="string-length($VarAcronymTitle) &gt; 0">
       <xsl:value-of select="'acronym'" />
      </xsl:when>
      <xsl:when test="string-length($VarCitation) &gt; 0">
       <xsl:value-of select="'q'" />
      </xsl:when>
      <xsl:otherwise>
       <xsl:choose>
        <xsl:when test="string-length($VarTagProperty) &gt; 0">
         <xsl:value-of select="$VarTagProperty" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="'span'" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Class attribute -->
    <!--                 -->
    <xsl:variable name="VarClassAttribute">
     <xsl:choose>
      <xsl:when test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value) &gt; 0">
       <xsl:value-of select="wwstring:CSSClassName($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value)" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="wwstring:CSSClassName($ParamTextRun/@stylename)" />
      </xsl:otherwise>
     </xsl:choose>

     <!-- Additional CSS classes -->
     <!--                        -->
     <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
     <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$VarAdditionalCSSClassesOption" />
     </xsl:if>
    </xsl:variable>

    <!-- Style attribute -->
    <!--                 -->
    <xsl:variable name="VarStyleAttribute">
     <xsl:call-template name="CSS-InlineProperties">
      <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
     </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
     <xsl:when test="(string-length($VarClassAttribute) &gt; 0) or (string-length($VarStyleAttribute) &gt; 0)">
      <!-- Character Style -->
      <!--                 -->
      <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
       <xsl:if test="string-length($VarClassAttribute) &gt; 0">
        <xsl:attribute name="class">
         <xsl:value-of select="$VarClassAttribute" />
        </xsl:attribute>
       </xsl:if>
       <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
        <xsl:attribute name="style">
         <xsl:value-of select="$VarStyleAttribute" />
        </xsl:attribute>
       </xsl:if>

       <!-- Abbreviation title -->
       <!--                    -->
       <xsl:if test="string-length($VarAbbreviationTitle) &gt; 0">
        <xsl:attribute name="title">
         <xsl:value-of select="$VarAbbreviationTitle" />
        </xsl:attribute>
       </xsl:if>

       <!-- Acronym title -->
       <!--                    -->
       <xsl:if test="string-length($VarAcronymTitle) &gt; 0">
        <xsl:attribute name="title">
         <xsl:value-of select="$VarAcronymTitle" />
        </xsl:attribute>
       </xsl:if>

       <!-- Cite attribute -->
       <!--                -->
       <xsl:if test="string-length($VarCitation) &gt; 0">
        <xsl:attribute name="cite">
         <xsl:value-of select="$VarCitation" />
        </xsl:attribute>
       </xsl:if>

       <xsl:call-template name="TextRunChildren">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
       </xsl:call-template>
      </xsl:element>
     </xsl:when>

     <xsl:otherwise>
      <!-- No style -->
      <!--          -->
      <html:span>
       <xsl:call-template name="TextRunChildren">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
       </xsl:call-template>
      </html:span>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <!-- No style -->
    <!--          -->
    <xsl:call-template name="TextRunChildren">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="TextRunChildren">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
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

  <!-- Handle links and first textrun anchor -->
  <!--                                       -->
  <xsl:choose>
   <xsl:when test="string-length($VarLinkInfo/@href) &gt; 0">
    <html:a href="{$VarLinkInfo/@href}">

     <xsl:choose>
      <xsl:when test="string-length($VarLinkInfo/@data-popup-href) &gt; 0">
       <xsl:attribute name="data-popup-href">
        <xsl:value-of select="$VarLinkInfo/@data-popup-href" />
       </xsl:attribute>
      </xsl:when>

      <xsl:when test="string-length($VarLinkInfo/@title) &gt; 0">
       <xsl:attribute name="title">
        <xsl:value-of select="$VarLinkInfo/@title" />
       </xsl:attribute>
      </xsl:when>
     </xsl:choose>

     <xsl:if test="string-length($VarLinkInfo/@target) &gt; 0">
      <xsl:attribute name="target">
       <xsl:value-of select="$VarLinkInfo/@target" />
      </xsl:attribute>
     </xsl:if>

     <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:apply-templates>
    </html:a>
   </xsl:when>

   <xsl:otherwise>
    <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
   </xsl:otherwise>
  </xsl:choose>

  <!-- Separator -->
  <!--           -->
  <xsl:if test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-separator']/@Value) &gt; 0">
   <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  </xsl:if>

  <!-- Force anchor on same line as containing span -->
  <!--                                              -->
  <wwexsldoc:NoBreak />
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

  <!-- Implement notes -->
  <!--                 -->
  <xsl:for-each select="$ParamCargo/wwnotes:NoteNumbering[1]">
   <xsl:variable name="VarNoteNumber" select="key('wwnotes-notes-by-id', $VarContext/@id)/@number" />

   <!-- Force sup on same line as containing span -->
   <!--                                           -->
   <wwexsldoc:NoBreak />

   <html:sup id="wwfootnote_inline_{$VarContext/@id}">
    <!-- Force anchor on same line as containing sup -->
    <!--                                             -->
    <wwexsldoc:NoBreak />

    <html:a>
     <xsl:attribute name="href">
      <xsl:text>#</xsl:text>
      <xsl:text>ww</xsl:text>
      <xsl:value-of select="$VarContext/@id" />
     </xsl:attribute>

     <xsl:value-of select="$VarNoteNumber" />
    </html:a>
   </html:sup>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <html:br />
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
  <xsl:param name="ParamTOCData" />
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
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
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


 <xsl:template name="Table-Attribute-In-Pixels">
  <xsl:param name="ParamValue" />

  <xsl:choose>
   <xsl:when test="string-length($ParamValue) &gt; 0">
    <!-- Normalize value for HTML attribute-->
    <!--                                   -->
    <xsl:variable name="VarValueToEmit">
     <xsl:variable name="VarUnitsSuffix" select="wwunits:UnitsSuffix($ParamValue)" />

     <xsl:choose>
      <xsl:when test="string-length($VarUnitsSuffix) &gt; 0">
       <xsl:variable name="VarNumPrefix" select="wwunits:NumericPrefix($ParamValue)" />

       <xsl:value-of select="wwunits:Convert($VarNumPrefix, $VarUnitsSuffix, 'px')" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$ParamValue" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="$VarValueToEmit" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="''" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Table">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
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

  <!-- Emit as table? -->
  <!--                -->
  <xsl:variable name="VarEmitAsTableOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-as-table']/@Value" />
  <xsl:variable name="VarEmitAsTable" select="$VarEmitAsTableOption = 'true'" />

  <!-- Table or div tags? -->
  <!--                    -->
  <xsl:variable name="VarTableTag">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text>table</xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>div</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarTableClass">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text></xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>WebWorks_Table</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarTableRowTag">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text>tr</xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>div</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarTableRowClass">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text></xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>WebWorks_Table_Row</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarTableCellTag">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text>td</xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>div</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarTableCellClass">
   <xsl:choose>
    <xsl:when test="$VarEmitAsTable">
     <xsl:text></xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>WebWorks_Table_Cell</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Table class -->
  <!--             -->
  <xsl:variable name="VarClassAttribute">
   <xsl:if test="string-length($VarTableClass) &gt; 0">
    <xsl:value-of select="$VarTableClass" />
    <xsl:text> </xsl:text>
   </xsl:if>

   <xsl:value-of select="wwstring:CSSClassName($ParamStyleName)" />

   <!-- Additional CSS classes -->
   <!--                        -->
   <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($VarContextRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
   <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
    <xsl:text> </xsl:text>
    <xsl:value-of select="$VarAdditionalCSSClassesOption" />
   </xsl:if>
  </xsl:variable>

  <!-- Style attribute -->
  <!--                 -->
  <xsl:variable name="VarStyleAttribute">
   <xsl:call-template name="CSS-InlineProperties">
    <xsl:with-param name="ParamProperties" select="$VarCSSProperties[(@Name != 'vertical-align')]" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Border -->
  <!--        -->
  <xsl:variable name="VarTableBorder">
   <xsl:call-template name="Table-Attribute-In-Pixels">
    <xsl:with-param name="ParamValue" select="$VarResolvedContextProperties[@Name = 'border']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Cell padding -->
  <!--              -->
  <xsl:variable name="VarTableCellPadding">
   <xsl:call-template name="Table-Attribute-In-Pixels">
    <xsl:with-param name="ParamValue" select="$VarResolvedContextProperties[@Name = 'cell-padding']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Cell spacing -->
  <!--              -->
  <xsl:variable name="VarTableCellSpacing">
   <xsl:call-template name="Table-Attribute-In-Pixels">
    <xsl:with-param name="ParamValue" select="$VarResolvedContextProperties[@Name = 'cell-spacing']/@Value" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Table vertical alignment -->
  <!--                          -->
  <xsl:variable name="VarTableVerticalAlignment">
   <xsl:variable name="VarTableVerticalAlignmentHint" select="$VarResolvedContextProperties[@Name = 'vertical-align']/@Value" />
   <xsl:choose>
    <xsl:when test="string-length($VarTableVerticalAlignmentHint) &gt; 0">
     <xsl:value-of select="$VarTableVerticalAlignmentHint" />
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="''" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Table summary -->
  <!--               -->
  <xsl:variable name="VarTableSummary">
   <xsl:call-template name="Tables-Summary">
    <xsl:with-param name="ParamTableBehavior" select="$ParamTableBehavior" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Caption Side -->
  <!--              -->
  <xsl:variable name="VarCaptionSide">
   <xsl:variable name="VarCaptionSideProperty">
    <xsl:value-of select="$VarResolvedContextProperties[@Name = 'caption-side']/@Value" />
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="string-length($VarCaptionSideProperty) &gt; 0">
     <xsl:value-of select="$VarCaptionSideProperty" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>top</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

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
       <xsl:with-param name="ParamTable" select="$ParamTable" />
       <xsl:with-param name="ParamReportAllCellWidths" select="not($VarEmitAsTable)" />
       <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
       <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
       <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
      </xsl:call-template>
     </xsl:when>

     <!-- Use original cell widths -->
     <!--                          -->
     <xsl:otherwise>
      <xsl:call-template name="Table-CellWidths">
       <xsl:with-param name="ParamTable" select="$ParamTable" />
       <xsl:with-param name="ParamReportAllCellWidths" select="not($VarEmitAsTable)" />
       <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
       <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
       <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="VarTableCellWidths" select="msxsl:node-set($VarTableCellWidthsAsXML)/*" />

  <!-- Wrap table to ensure proper handling on small screens -->
  <!--                                                       -->
  <html:div class="ww_skin_page_overflow">
   <xsl:if test="string-length($VarResolvedContextProperties[@Name = 'clear']/@Value) &gt; 0">
    <xsl:attribute name="style">
     <xsl:text>clear: </xsl:text>
     <xsl:value-of select="$VarResolvedContextProperties[@Name = 'clear']/@Value" />
    </xsl:attribute>
   </xsl:if>

   <!-- Caption -->
   <!--         -->
   <xsl:choose>
    <!-- Table as table -->
    <!--                -->
    <xsl:when test="$VarEmitAsTable">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <!-- Table as paragraphs -->
    <!--                     -->
    <xsl:otherwise>
     <!-- Caption at top? -->
     <!--                 -->
     <xsl:if test="$VarCaptionSide = 'top'">
      <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
       <xsl:apply-templates select="./*" mode="wwmode:content">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       </xsl:apply-templates>
      </xsl:for-each>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>

   <!-- Emit <table> element with class, style, and summary attributes -->
   <!--                                                                -->
   <xsl:element name="{$VarTableTag}" namespace="{$GlobalDefaultNamespace}">
    <!-- id attribute -->
    <!--              -->
    <xsl:if test="$VarEmitAsTable">
     <xsl:attribute name="id">
      <xsl:text>ww</xsl:text>
      <xsl:value-of select="$ParamTable/@id" />
     </xsl:attribute>
    </xsl:if>

    <!-- class attribute -->
    <!--                 -->
    <xsl:attribute name="class">
     <xsl:value-of select="$VarClassAttribute" />
    </xsl:attribute>

    <!-- style attribute -->
    <!--                 -->
    <xsl:if test="string-length($VarStyleAttribute) &gt; 0">
     <xsl:attribute name="style">
      <xsl:value-of select="$VarStyleAttribute" />
     </xsl:attribute>
    </xsl:if>

    <!-- border attribute -->
    <!--                  -->
    <xsl:if test="string-length($VarTableBorder) &gt; 0">
     <xsl:attribute name="border">
      <xsl:value-of select="$VarTableBorder" />
     </xsl:attribute>
    </xsl:if>

    <!-- cellpadding attribute -->
    <!--                       -->
    <xsl:if test="$VarEmitAsTable">
     <xsl:if test="string-length($VarTableCellPadding) &gt; 0">
      <xsl:attribute name="cellpadding">
       <xsl:value-of select="$VarTableCellPadding" />
      </xsl:attribute>
     </xsl:if>
    </xsl:if>

    <!-- cellspacing attribute -->
    <!--                       -->
    <xsl:if test="$VarEmitAsTable">
     <xsl:if test="string-length($VarTableCellSpacing) &gt; 0">
      <xsl:attribute name="cellspacing">
       <xsl:value-of select="$VarTableCellSpacing" />
      </xsl:attribute>
     </xsl:if>
    </xsl:if>

    <!-- summary attribute -->
    <!--                   -->
    <xsl:if test="$VarEmitAsTable">
     <xsl:attribute name="summary">
      <xsl:value-of select="$VarTableSummary" />
     </xsl:attribute>
    </xsl:if>

    <!-- Caption -->
    <!--         -->
    <xsl:choose>
     <!-- Table as table -->
     <!--                -->
     <xsl:when test="$VarEmitAsTable">
      <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
       <!-- Process content normally -->
       <!--                          -->
       <xsl:variable name="VarCaptionContentAsXML">
        <xsl:apply-templates select="./*" mode="wwmode:content">
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$VarCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        </xsl:apply-templates>
       </xsl:variable>
       <xsl:variable name="VarCaptionContent" select="msxsl:node-set($VarCaptionContentAsXML)/*" />

       <!-- Convert content to caption -->
       <!--                            -->
       <html:caption>
        <xsl:if test="string-length($VarCaptionContent[1]/@class) &gt; 0">
         <xsl:attribute name="class">
          <xsl:value-of select="$VarCaptionContent[1]/@class" />
         </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length($VarCaptionSide) &gt; 0">
         <xsl:attribute name="style">
          <xsl:text>caption-side: </xsl:text>
          <xsl:value-of select="$VarCaptionSide" />
         </xsl:attribute>
        </xsl:if>

        <!-- Emit contents of caption content -->
        <!--                                  -->
        <xsl:copy-of select="$VarCaptionContent" />
       </html:caption>
      </xsl:for-each>
     </xsl:when>

     <!-- Table as paragraphs -->
     <!--                     -->
     <xsl:otherwise>
      <!-- Nothing to do -->
      <!--               -->
     </xsl:otherwise>
    </xsl:choose>

    <xsl:for-each select="$ParamTable/wwdoc:TableHead|$ParamTable/wwdoc:TableBody|$ParamTable/wwdoc:TableFoot">
     <xsl:variable name="VarSection" select="." />

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

      <!-- Emit row -->
      <!--          -->
      <xsl:element name="{$VarTableRowTag}" namespace="{$GlobalDefaultNamespace}">
       <!-- Class attribute -->
       <!--                 -->
       <xsl:if test="string-length($VarTableRow/@stylename) &gt; 0">
        <xsl:attribute name="class">
         <xsl:value-of select="wwstring:CSSClassName($VarTableRow/@stylename)" />
        </xsl:attribute>
       </xsl:if>

       <!-- class attribute -->
       <!--                 -->
       <xsl:if test="string-length($VarTableRowClass) &gt; 0">
        <xsl:attribute name="class">
         <xsl:value-of select="$VarTableRowClass" />
        </xsl:attribute>
       </xsl:if>

       <!-- style attribute -->
       <!--                 -->
       <xsl:variable name="VarTableRowStyleAttribute">
        <xsl:choose>
         <!-- Table as table -->
         <!--                -->
         <xsl:when test="$VarEmitAsTable">
          <!-- Handle table level vertical align at row level -->
          <!--                                                -->
          <xsl:if test="string-length($VarTableVerticalAlignment) &gt; 0">
           <xsl:text>vertical-align: </xsl:text>
           <xsl:value-of select="$VarTableVerticalAlignment" />
          </xsl:if>
         </xsl:when>

         <!-- Table as paragraphs -->
         <!--                     -->
         <xsl:otherwise>
          <!-- Nothing to do -->
          <!--               -->
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>
       <xsl:if test="string-length($VarTableRowStyleAttribute) &gt; 0">
        <xsl:attribute name="style">
         <xsl:value-of select="$VarTableRowStyleAttribute" />
        </xsl:attribute>
       </xsl:if>

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
          <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarTableCellCSSProperties" select="msxsl:node-set($VarTableCellCSSPropertiesAsXML)/wwproject:Property" />

        <!-- Inline CSS properties -->
        <!--                       -->
        <xsl:variable name="VarInlineCSSProperties">
         <xsl:call-template name="CSS-InlineProperties">
          <xsl:with-param name="ParamProperties" select="$VarTableCellCSSProperties" />
         </xsl:call-template>
        </xsl:variable>

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

        <!-- Emit cell -->
        <!--           -->
        <!-- Detect Heading Row -->
        <!--                    -->
        <xsl:variable name="VarTableCellTag2">
         <xsl:choose>
          <xsl:when test="local-name($VarSection) = 'TableHead'">
           <xsl:text>th</xsl:text>
          </xsl:when>
          <xsl:otherwise>
           <xsl:text>td</xsl:text>
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>
        <!-- Detect Heading Row End -->
        <!--                        -->
        <xsl:element name="{$VarTableCellTag2}" namespace="{$GlobalDefaultNamespace}">
         <!-- class attribute -->
         <!--                 -->
         <xsl:if test="(string-length($VarTableCell/@stylename) &gt; 0) or (string-length($VarTableCellClass) &gt; 0)">
          <xsl:attribute name="class">
           <xsl:if test="string-length($VarTableCell/@stylename) &gt; 0">
            <xsl:value-of select="wwstring:CSSClassName($VarTableCell/@stylename)" />
           </xsl:if>
           <xsl:if test="string-length($VarTableCellClass) &gt; 0">
            <xsl:if test="string-length($VarTableCell/@stylename) &gt; 0">
             <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$VarTableCellClass" />
           </xsl:if>
          </xsl:attribute>
         </xsl:if>

         <!-- Style attribute -->
         <!--                 -->
         <xsl:if test="string-length($VarInlineCSSProperties) &gt; 0">
          <xsl:attribute name="style">
           <xsl:value-of select="$VarInlineCSSProperties" />
          </xsl:attribute>
         </xsl:if>

         <!-- Row span attribute -->
         <!--                    -->
         <xsl:if test="$VarEmitAsTable">
          <xsl:if test="number($VarRowSpan) &gt; 0">
           <xsl:attribute name="rowspan">
            <xsl:value-of select="$VarRowSpan" />
           </xsl:attribute>
          </xsl:if>
         </xsl:if>

         <!-- Column span attribute -->
         <!--                       -->
         <xsl:if test="$VarEmitAsTable">
          <xsl:if test="number($VarColumnSpan) &gt; 0">
           <xsl:attribute name="colspan">
            <xsl:value-of select="$VarColumnSpan" />
           </xsl:attribute>
          </xsl:if>
         </xsl:if>

         <!-- Recurse -->
         <!--         -->
         <xsl:apply-templates select="./*" mode="wwmode:content">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$VarCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         </xsl:apply-templates>
        </xsl:element>
       </xsl:for-each>

      </xsl:element>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:element>

   <!-- Ensure proper layout -->
   <!--                      -->
   <xsl:choose>
    <!-- Table as table -->
    <!--                -->
    <xsl:when test="$VarEmitAsTable">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <!-- Table as paragraphs -->
    <!--                     -->
    <xsl:otherwise>
     <html:div class="WebWorks_Table_End">&#160;</html:div>
    </xsl:otherwise>
   </xsl:choose>

   <!-- Caption -->
   <!--         -->
   <xsl:choose>
    <!-- Table as table -->
    <!--                -->
    <xsl:when test="$VarEmitAsTable">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <!-- Table as paragraphs -->
    <!--                     -->
    <xsl:otherwise>
     <!-- Caption at top? -->
     <!--                 -->
     <xsl:if test="$VarCaptionSide = 'bottom'">
      <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
       <xsl:apply-templates select="./*" mode="wwmode:content">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       </xsl:apply-templates>
      </xsl:for-each>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>

   <!-- Table Footnotes -->
   <!--                 -->
   <xsl:call-template name="Content-Notes">
    <xsl:with-param name="ParamNotes" select="$VarNotes" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$VarCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:call-template>

   <!-- Close out table wrapper -->
   <!--                         -->
  </html:div>

  <!-- Dropdown End -->
  <!--              -->
  <xsl:if test="$ParamTableBehavior/@dropdown = 'end'">
   <wwexsldoc:Text disable-output-escaping="yes">&lt;/div&gt;</wwexsldoc:Text>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
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

    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $VarSplitsFrame/@stylename, $VarSplitsFrame/@documentID, $VarSplitsFrame/@id)" />

     <!-- Resolve project properties -->
     <!--                            -->
     <xsl:variable name="VarResolvedPropertiesAsXML">
      <xsl:call-template name="Properties-ResolveContextRule">
       <xsl:with-param name="ParamDocumentContext" select="$ParamFrame" />
       <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
       <xsl:with-param name="ParamStyleName" select="$VarSplitsFrame/@stylename" />
       <xsl:with-param name="ParamStyleType" select="'Graphic'" />
       <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

     <!-- CSS properties -->
     <!--                -->
     <xsl:variable name="VarCSSPropertiesAsXML">
      <xsl:call-template name="CSS-TranslateImageWrapperProjectProperties">
       <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
       <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

     <xsl:variable name="VarInlineCSSProperties">
      <xsl:call-template name="CSS-InlineProperties">
       <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) &gt; 0]" />
      </xsl:call-template>
     </xsl:variable>

     <!-- Emit span for text-align -->
     <!--                          -->
     <xsl:element name="span">
      <!-- Style attribute -->
      <!--                 -->
      <xsl:if test="string-length($VarInlineCSSProperties) &gt; 0">
       <xsl:attribute name="style">
        <xsl:value-of select="$VarInlineCSSProperties" />
       </xsl:attribute>
      </xsl:if>

      <!--            -->
      <xsl:variable name="VarSplitsThumbnail" select="$VarSplitsFrame/wwsplits:Thumbnail" />
      <!-- Thumbnail? -->
      <xsl:variable name="VarThumbnailDefined" select="count(key('wwfiles-files-by-path', $VarSplitsThumbnail/@path)[1]) &gt; 0" />

      <!-- Emit image -->
      <!--            -->
      <xsl:choose>
       <!-- Thumbnail -->
       <!--           -->
       <xsl:when test="$VarThumbnailDefined">
        <!-- Emit markup -->
        <!--             -->
        <xsl:call-template name="Frame-Markup">
         <xsl:with-param name="ParamFrame" select="$ParamFrame" />
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$ParamCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
         <xsl:with-param name="ParamThumbnail" select="true()" />
        </xsl:call-template>
       </xsl:when>

       <!-- Fullsize -->
       <!--          -->
       <xsl:otherwise>
        <!-- Note numbering -->
        <!--                -->
        <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
        <xsl:variable name="VarNoteNumberingAsXML">
         <xsl:call-template name="Notes-Number">
          <xsl:with-param name="ParamNotes" select="$VarNotes" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

        <!-- Frame cargo -->
        <!--             -->
        <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'NoteNumbering']/.. | $VarNoteNumbering" />

        <!-- Emit markup -->
        <!--             -->
        <xsl:call-template name="Frame-Markup">
         <xsl:with-param name="ParamFrame" select="$ParamFrame" />
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$VarCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
         <xsl:with-param name="ParamThumbnail" select="false()" />
        </xsl:call-template>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:element>
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

  <!-- Determine video source -->
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
  <html:video>
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
    <html:source src="{$VarVideoSrcURI}" type="{$VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value}" />
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
  </html:video>
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

   <html:object>
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

     <html:param name="{$VarParam/@name}" value="{$VarValue}" />
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
     <html:param name="allowFullScreen" value="{$VarAllowFullScreen}" />
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

      <html:param name="FlashVars" value="flv={wwstring:EncodeURIComponent($VarFLVURI)}{$VarStartImage}&amp;autoplay=0&amp;autoload=0&amp;showvolume=1&amp;showfullscreen=1" />
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
   </html:object>
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
   <xsl:variable name="VarSrc">
    <xsl:call-template name="Connect-URI-GetRelativeTo">
     <xsl:with-param name="ParamDestinationURI" select="$ParamImageInfo/@path" />
     <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Alt Text -->
   <!--          -->
   <xsl:variable name="VarAltText">
    <xsl:call-template name="Images-AltText">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Long Description -->
   <!--                  -->
   <xsl:variable name="VarLongDescription">
    <xsl:call-template name="Images-LongDescription">
     <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
     <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- SVG object tag info:                                          -->
   <!--   http://joliclic.free.fr/html/object-tag/en/object-svg.html  -->
   <!--   http://volity.org/wiki/index.cgi?SVG_Scaling                -->
   <!--                                                               -->

   <!-- Graphic element -->
   <!--                 -->
   <xsl:variable name="VarSVGTag">
    <xsl:variable name="VarPropertyTag" select="wwstring:ToLower($VarResolvedProperties[@Name = 'tag']/@Value)" />
    <xsl:choose>
     <xsl:when test="$VarPropertyTag = 'img'">
      <xsl:value-of select="'img'" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="'object'" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:element name="{$VarSVGTag}" namespace="{$GlobalDefaultNamespace}">

    <!-- if img tag use src attribute, otherwise use data and type attribute -->
    <!--                                                                     -->
    <xsl:choose>
     <xsl:when test="$VarSVGTag = 'img'">
      <xsl:attribute name="src">
       <xsl:value-of select="$VarSrc" />
      </xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="data">
       <xsl:value-of select="$VarSrc" />
      </xsl:attribute>
      <xsl:attribute name="type">
       <xsl:text>image/svg+xml</xsl:text>
      </xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>

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

    <xsl:if test="$VarSVGTag = 'object'">
     <!-- Src parameter -->
     <!--               -->
     <html:param name="src" value="{$VarSrc}" valuetype="data" />
    </xsl:if>
   </xsl:element>

   <!-- Generate D Links -->
   <!--                  -->
   <xsl:variable name="VarGenerateDLinks" select="wwprojext:GetFormatSetting('accessibility-image-d-links', 'false')" />
   <xsl:if test="$VarGenerateDLinks = 'true'">
    <xsl:if test="string-length($VarLongDescription) &gt; 0">
     <xsl:text> </xsl:text>
     <html:a href="{$VarLongDescription}" title="Description link for {wwfilesystem:GetFileName($ParamSplitsFrame/@path)}">[D]</html:a><html:br />
    </xsl:if>
   </xsl:if>

   <!-- Notes -->
   <!--       -->
   <xsl:choose>
    <!-- Thumbnail -->
    <!--           -->
    <xsl:when test="$ParamThumbnail">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <!-- Fullsize -->
    <!--          -->
    <xsl:otherwise>
     <!-- Frame Footnotes -->
     <!--                 -->
     <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
     <xsl:call-template name="Content-Notes">
      <xsl:with-param name="ParamNotes" select="$VarNotes" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="''" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
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
   <xsl:variable name="VarSrc">
    <xsl:call-template name="Connect-URI-GetRelativeTo">
     <xsl:with-param name="ParamDestinationURI" select="$ParamImageInfo/@path" />
     <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
    </xsl:call-template>
   </xsl:variable>

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

   <!-- Long Description -->
   <!--                  -->
   <xsl:variable name="VarLongDescription">
    <xsl:call-template name="Images-LongDescription">
     <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
     <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Tag -->
   <!--     -->
   <xsl:variable name="VarTagProperty" select="$ParamContextRule/wwproject:Properties/wwproject:Property[@Name = 'tag']/@Value" />
   <xsl:variable name="VarTag">
    <xsl:choose>
     <xsl:when test="string-length($VarTagProperty) &gt; 0">
      <xsl:value-of select="$VarTagProperty" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="'img'" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Graphic element -->
   <!--                 -->
   <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
    <!-- Class attribute -->
    <!--                 -->
    <xsl:attribute name="class">
     <xsl:value-of select="wwstring:CSSClassName($ParamFrame/@stylename)" />

     <!-- Additional CSS classes -->
     <!--                        -->
     <xsl:variable name="VarAdditionalCSSClassesOption" select="normalize-space($ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'additional-css-classes']/@Value)" />
     <xsl:if test="string-length($VarAdditionalCSSClassesOption) &gt; 0">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$VarAdditionalCSSClassesOption" />
     </xsl:if>
    </xsl:attribute>

    <!-- Src attribute -->
    <!--               -->
    <xsl:attribute name="src">
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

    <!-- Alt attribute -->
    <!--               -->
    <xsl:attribute name="alt">
     <xsl:value-of select="$VarAltText" />
    </xsl:attribute>

    <xsl:attribute name="title">
     <xsl:value-of select="$VarAltText" />
    </xsl:attribute>

    <!-- Longdesc attribute -->
    <!--                    -->
    <xsl:if test="string-length($VarLongDescription) &gt; 0">
     <xsl:attribute name="longdesc">
      <xsl:value-of select="$VarLongDescription" />
     </xsl:attribute>
    </xsl:if>

    <!-- Usemap attribute -->
    <!--                  -->
    <xsl:if test="string-length($VarUseMap) &gt; 0">
     <xsl:attribute name="usemap">
      <xsl:value-of select="$VarUseMap" />
     </xsl:attribute>
     <xsl:attribute name="border">
      <xsl:value-of select="'0'" />
     </xsl:attribute>
    </xsl:if>
   </xsl:element>

   <!-- Generate D Links -->
   <!--                  -->
   <xsl:variable name="VarGenerateDLinks" select="wwprojext:GetFormatSetting('accessibility-image-d-links', 'false')" />
   <xsl:if test="$VarGenerateDLinks = 'true'">
    <xsl:if test="string-length($VarLongDescription) &gt; 0">
     <xsl:text> </xsl:text>
     <html:a href="{$VarLongDescription}" title="Description link for {wwfilesystem:GetFileName($ParamSplitsFrame/@path)}">[D]</html:a><html:br />
    </xsl:if>
   </xsl:if>

   <!-- Image map -->
   <!--           -->
   <xsl:if test="string-length($VarUseMap) &gt; 0">
    <html:map name="{$ParamSplitsFrame/@documentID}_{$ParamSplitsFrame/@id}">
     <xsl:choose>
      <!-- Thumbnail -->
      <!--           -->
      <xsl:when test="$ParamThumbnail">
       <html:area coords="0,0,{$VarWidth},{$VarHeight}" shape="rect">
        <xsl:attribute name="href">
         <xsl:call-template name="Connect-URI-GetRelativeTo">
          <xsl:with-param name="ParamDestinationURI" select="$ParamSplitsFrame/wwsplits:Wrapper/@path" />
          <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
         </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:value-of select="$VarAltText" />
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:value-of select="$VarAltText" />
        </xsl:attribute>

        <!-- Decorate additional attributes for image box effect -->
        <!--                                                     -->
        <xsl:attribute name="original-href" namespace="urn:WebWorks-Web-Extension-Schema">
         <xsl:call-template name="Connect-URI-GetRelativeTo">
          <xsl:with-param name="ParamDestinationURI" select="$ParamSplitsFrame/@path" />
          <xsl:with-param name="ParamSourceURI" select="$ParamSplit/@path" />
         </xsl:call-template>
        </xsl:attribute>

        <!-- Decorate original image's width and height -->
        <!--                                            -->
        <xsl:variable name="VarOriginalImageInfo" select="wwimaging:GetInfo($ParamSplitsFrame/@path)" />

        <xsl:attribute name="original-width" namespace="urn:WebWorks-Web-Extension-Schema">
         <xsl:variable name="VarStyledWidth">
          <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />

          <xsl:choose>
           <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($VarOriginalImageInfo/@width) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px'))" />
           </xsl:when>

           <xsl:when test="string-length($VarPropertyDimension) &gt; 0">
            <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
            <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />

            <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
           </xsl:when>
          </xsl:choose>
         </xsl:variable>
         <xsl:choose>
          <xsl:when test="number($VarStyledWidth) &gt; 0">
           <xsl:value-of select="$VarStyledWidth" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="$VarOriginalImageInfo/@width" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="original-height" namespace="urn:WebWorks-Web-Extension-Schema">
         <xsl:variable name="VarStyledHeight">
          <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />

          <xsl:choose>
           <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($VarOriginalImageInfo/@height) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px'))" />
           </xsl:when>

           <xsl:when test="string-length($VarPropertyDimension) &gt; 0">
            <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
            <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />

            <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
           </xsl:when>
          </xsl:choose>
         </xsl:variable>
         <xsl:choose>
          <xsl:when test="number($VarStyledHeight) &gt; 0">
           <xsl:value-of select="$VarStyledHeight" />
          </xsl:when>

          <xsl:otherwise>
           <xsl:value-of select="$VarOriginalImageInfo/@height" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:attribute>
       </html:area>
      </xsl:when>

      <!-- Fullsize -->
      <!--          -->
      <xsl:otherwise>
       <xsl:variable name="VarHorizontalScalingAsText">
        <xsl:choose>
         <xsl:when test="$VarWidth &gt; 0">
          <xsl:variable name="VarWidthAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px')))" />
          <xsl:value-of select="number($VarWidth) div number($VarWidthAsPixels)" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="1" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

       <xsl:variable name="VarVerticalScalingAsText">
        <xsl:choose>
         <xsl:when test="$VarHeight &gt; 0">
          <xsl:variable name="VarHeightAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px')))" />
          <xsl:value-of select="number($VarHeight) div number($VarHeightAsPixels)" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="1" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

       <xsl:call-template name="ImageMap">
        <xsl:with-param name="ParamFrame" select="$ParamFrame" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamParentBehavior" select="$VarBehaviorFrame" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamHorizontalScaling" select="number($VarHorizontalScalingAsText)" />
        <xsl:with-param name="ParamVerticalScaling" select="number($VarVerticalScalingAsText)" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </html:map>
   </xsl:if>

   <!-- Notes -->
   <!--       -->
   <xsl:choose>
    <!-- Thumbnail -->
    <!--           -->
    <xsl:when test="$ParamThumbnail">
     <!-- Nothing to do -->
     <!--               -->
    </xsl:when>

    <!-- Fullsize -->
    <!--          -->
    <xsl:otherwise>
     <!-- Frame Footnotes -->
     <!--                 -->
     <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
     <xsl:call-template name="Content-Notes">
      <xsl:with-param name="ParamNotes" select="$VarNotes" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="''" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
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
   <html:area href="{$VarLinkInfo/@href}" coords="{$VarCoordsString}" shape="rect">
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
   </html:area>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Breadcrumbs">
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />

  <!-- Determine separator -->
  <!--                     -->
  <xsl:variable name="VarBreadcrumbsSeparator">
   <xsl:variable name="VarBreadcrumbsSeparatorProperty" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = 'breadcrumbs-separator']/@Value" />
   <xsl:choose>
    <xsl:when test="string-length($VarBreadcrumbsSeparatorProperty) &gt; 0">
     <xsl:value-of select="$VarBreadcrumbsSeparatorProperty" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:text> : </xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit merge groups? -->
  <!--                    -->
  <xsl:variable name="VarMergeGroupsInBreadcrumbsOption" select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'include-merge-groups-in-breadcrumbs']/@Value" />
  <xsl:if test="$VarMergeGroupsInBreadcrumbsOption = 'true' or string-length($VarMergeGroupsInBreadcrumbsOption) = 0">
   <!-- Locate merge group settings -->
   <!--                             -->
   <xsl:variable name="VarMergeGroup" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID = wwprojext:GetFormatID()]/wwproject:MergeSettings//wwproject:MergeGroup[@GroupID = $ParamSplit/@groupID]" />

   <!-- Find first generated page in group -->
   <!--                                    -->
   <xsl:variable name="VarFirstSplitInGroup" select="$ParamSplit/parent::wwsplits:Splits/wwsplits:Split[@groupID = $ParamSplit/@groupID][1]" />

   <!-- Emit merge groups hierarchy -->
   <!--                             -->
   <xsl:apply-templates select="$VarMergeGroup" mode="breadcrumbs-merge-hierarchy">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamFirstSplitInGroup" select="$VarFirstSplitInGroup" />
    <xsl:with-param name="ParamBreadcrumbsSeparator" select="$VarBreadcrumbsSeparator" />
   </xsl:apply-templates>

   <!-- Emit separator -->
   <!--                -->
   <xsl:if test="count($ParamBreadcrumbTOCEntry) &gt; 0">
    <xsl:value-of select="$VarBreadcrumbsSeparator" />
   </xsl:if>
  </xsl:if>

  <!-- Emit TOC breadcrumb entries -->
  <!--                             -->
  <xsl:apply-templates select="$ParamBreadcrumbTOCEntry" mode="breadcrumbs-toc-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$VarBreadcrumbsSeparator" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template name="BreadcrumbEntry">
  <xsl:param name="ParamTOCEntry" />

  <xsl:for-each select="$ParamTOCEntry/wwdoc:Paragraph/wwdoc:Number/wwdoc:Text | $ParamTOCEntry/wwdoc:Paragraph//wwdoc:TextRun/wwdoc:Text">
   <xsl:variable name="VarText" select="." />

   <xsl:value-of select="$VarText/@value" />
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwproject:TOC" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamMergeTOC" select="." />

  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamMergeTOC/parent::*" mode="breadcrumbs-merge-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamFirstSplitInGroup" select="$ParamFirstSplitInGroup" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator -->
  <!--                -->
  <xsl:if test="count($ParamMergeTOC/parent::wwproject:TOC) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="count($ParamFirstSplitInGroup | $ParamSplit) &gt; 1">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamFirstSplitInGroup/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}">
     <xsl:value-of select="$ParamMergeTOC/@Name" />
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:value-of select="$ParamMergeTOC/@Name" />
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwproject:MergeGroup" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamMergeGroup" select="." />

  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamMergeGroup/parent::*" mode="breadcrumbs-merge-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamFirstSplitInGroup" select="$ParamFirstSplitInGroup" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator -->
  <!--                -->
  <xsl:if test="count($ParamMergeGroup/parent::wwproject:TOC) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Determine title -->
  <!--                 -->
  <xsl:variable name="VarMergeGroupTitle">
   <xsl:choose>
    <!-- Title exists? -->
    <!--               -->
    <xsl:when test="string-length($ParamMergeGroup/@Title) &gt; 0">
     <xsl:value-of select="$ParamMergeGroup/@Title" />
    </xsl:when>

    <!-- Use group name -->
    <!--                -->
    <xsl:otherwise>
     <xsl:value-of select="wwprojext:GetGroupName($ParamMergeGroup/@GroupID)" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="count($ParamFirstSplitInGroup | $ParamSplit) &gt; 1">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamFirstSplitInGroup/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}">
     <xsl:value-of select="$VarMergeGroupTitle" />
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:value-of select="$VarMergeGroupTitle" />
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- breadcrumbs-toc-hierarchy -->
 <!--                           -->
 <xsl:template match="wwtoc:Entry" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamTOCEntry" select="." />


  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamTOCEntry/parent::*" mode="breadcrumbs-toc-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator if necessary -->
  <!--                             -->
  <xsl:if test="count($ParamTOCEntry/parent::wwtoc:Entry) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="(string-length($ParamTOCEntry/@path) &gt; 0) and (count($ParamBreadcrumbTOCEntry | $ParamTOCEntry) &gt; 1)">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamTOCEntry/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}#{$ParamBreadcrumbTOCEntry/@linkid}">
     <xsl:call-template name="BreadcrumbEntry">
      <xsl:with-param name="ParamTOCEntry" select="$ParamTOCEntry" />
     </xsl:call-template>
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:call-template name="BreadcrumbEntry">
      <xsl:with-param name="ParamTOCEntry" select="$ParamTOCEntry" />
     </xsl:call-template>
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
