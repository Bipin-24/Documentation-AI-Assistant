<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwfilesext wwmode wwfiles wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwtoc" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />
 <xsl:key name="wwdoc-paragraphstyle-by-name" match="wwdoc:ParagraphStyle" use="@name" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarBehaviorsDocument" select="key('wwfiles-files-by-documentid', $VarFilesDocument/@documentID)[@type = $ParameterBehaviorsType]" />

      <!-- Up to date? -->
      <!--             -->
      <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Load document -->
        <!--               -->
        <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />
        <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsDocument/@path, false())" />

        <xsl:call-template name="Document">
         <xsl:with-param name="ParamDocument" select="$VarDocument" />
         <xsl:with-param name="ParamDocumentID" select="$VarFilesDocument/@documentID" />
         <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
      </xsl:if>

      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarBehaviorsDocument/@path}" checksum="{$VarBehaviorsDocument/@checksum}" groupID="{$VarBehaviorsDocument/@groupID}" documentID="{$VarBehaviorsDocument/@documentID}" />
       <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
      </wwfiles:File>

     </xsl:for-each>
     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Document">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamBehaviors" />

  <wwtoc:TableOfContents version="1.0">
   <xsl:apply-templates select="$ParamDocument/wwdoc:Document/wwdoc:Content/*" mode="wwmode:toc">
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    <xsl:with-param name="ParamTrackDocumentPosition" select="true()" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </wwtoc:TableOfContents>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <xsl:for-each select="wwdoc:Caption[1]">
   <xsl:apply-templates select="./*" mode="wwmode:toc">
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    <xsl:with-param name="ParamTrackDocumentPosition" select="false()" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:for-each>

  <xsl:for-each select="wwdoc:TableHead | wwdoc:TableBody | wwdoc:TableFoot">
   <xsl:for-each select="wwdoc:TableRow">
    <xsl:for-each select="wwdoc:TableCell">
     <xsl:apply-templates select="./*" mode="wwmode:toc">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
      <xsl:with-param name="ParamTrackDocumentPosition" select="false()" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     </xsl:apply-templates>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <!-- Do not recurse frames -->
  <!--                       -->
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarParagraph" select="." />

  <xsl:call-template name="Paragraph">
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
   <xsl:with-param name="ParamTrackDocumentPosition" select="$ParamTrackDocumentPosition" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Paragraph">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <!-- Record position -->
  <!--                 -->
  <xsl:variable name="VarPosition" select="position()" />

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamDocumentID, $ParamParagraph/@id)" />
  <xsl:variable name="VarTOCDisplay" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'toc-display']/@Value" />

  <!-- In TOC? -->
  <!--         -->
  <xsl:variable name="VarTOCLevel">
   <xsl:variable name="VarTOCOptionHint" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'toc-level']/@Value" />
   <xsl:choose>
    <xsl:when test="$VarTOCOptionHint = 'auto-detect'">
     <xsl:variable name="VarAutoDetectLevel">
      <xsl:for-each select="$ParamDocument[1]">
       <xsl:variable name="VarWifParagraphStyle" select="key('wwdoc-paragraphstyle-by-name', $ParamParagraph/@stylename)" />
       <xsl:choose>
        <xsl:when test="count($ParamParagraph/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]) = 1">
         <xsl:value-of select="$ParamParagraph/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]/@value" />
        </xsl:when>

        <xsl:when test="count($VarWifParagraphStyle/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]) = 1">
         <xsl:value-of select="$VarWifParagraphStyle/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]/@value" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="0" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>
     </xsl:variable>
     <xsl:value-of select="$VarAutoDetectLevel" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarTOCOptionHint" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:if test="($VarTOCLevel != 'none') and ($VarTOCLevel &gt; 0)">
   <!-- Preserve empty? -->
   <!--                 -->
   <xsl:variable name="VarPreserveEmptyOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
   <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

   <!-- Non-empty text runs -->
   <!--                     -->
   <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1]) &gt; 0]" />

   <!-- Process this paragraph at all? -->
   <!--                                -->
   <xsl:if test="($VarPreserveEmpty) or (count($VarTextRuns[1]) = 1)">
    <!-- Create entry -->
    <!--              -->
    <wwtoc:Entry>
     <xsl:attribute name="id">
      <xsl:value-of select="$ParamParagraph/@id" />
     </xsl:attribute>
     <xsl:attribute name="documentID">
      <xsl:value-of select="$ParamDocumentID" />
     </xsl:attribute>
     <xsl:attribute name="level">
      <xsl:value-of select="$VarTOCLevel" />
     </xsl:attribute>
      <xsl:attribute name="display">
        <xsl:value-of select="$VarTOCDisplay"/>
      </xsl:attribute>
     <xsl:if test="$ParamTrackDocumentPosition">
      <xsl:attribute name="documentposition">
       <xsl:value-of select="$VarPosition" />
      </xsl:attribute>
     </xsl:if>

     <!-- Replace paragraph in TOC? -->
     <!--                           -->
     <xsl:variable name="VarAlternateTOCTitleMarkersAsXML">
      <xsl:call-template name="Alternate-TOC-Title">
       <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
       <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarAlternateTOCTitleMarkers" select="msxsl:node-set($VarAlternateTOCTitleMarkersAsXML)/*" />

     <!-- Paragraph -->
     <!--           -->
     <xsl:choose>
      <xsl:when test="count($VarAlternateTOCTitleMarkers) &gt; 0">
       <wwdoc:Paragraph>
        <xsl:apply-templates select="$VarAlternateTOCTitleMarkers[1]/*" mode="wwmode:copy-elements" />
       </wwdoc:Paragraph>
      </xsl:when>

      <xsl:otherwise>
       <wwdoc:Paragraph>
        <!-- @stylename -->
        <!--            -->
        <xsl:attribute name="stylename">
         <xsl:value-of select="$ParamParagraph/@stylename" />
        </xsl:attribute>

        <!-- Style -->
        <!--       -->
        <xsl:call-template name="Style">
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
         <xsl:with-param name="ParamNode" select="$ParamParagraph" />
         <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
        </xsl:call-template>

        <!-- Numbering -->
        <!--           -->
        <xsl:variable name="VarUseNumberingInTOCOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering-toc']/@Value" />
        <xsl:variable name="VarUseNumberingInTOC" select="(string-length($VarUseNumberingInTOCOption) = 0) or ($VarUseNumberingInTOCOption = 'true')" />
        <xsl:if test="$VarUseNumberingInTOC">
         <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
         <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />

         <!-- Numbering exists? -->
         <!--                   -->
         <xsl:if test="(count($ParamParagraph/wwdoc:Number/*) &gt; 0) or (string-length($VarBulletCharacter) &gt; 0)">
          <!-- Emit numbering information -->
          <!--                            -->
          <wwdoc:Number>
           <xsl:copy-of select="$ParamParagraph/wwdoc:Number/@*" />

           <!-- Use bullet charactor or original numbering text? -->
           <!--                                                  -->
           <xsl:choose>
            <!-- Bullet charactor -->
            <!--                  -->
            <xsl:when test="string-length($VarBulletCharacter) &gt; 0">
             <wwdoc:Text value="{$VarBulletCharacter}" />
            </xsl:when>

            <!-- Original numbering text -->
            <!--                         -->
            <xsl:otherwise>
             <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/*" mode="wwmode:copy-elements" />
            </xsl:otherwise>
           </xsl:choose>

           <!-- Separator -->
           <!--           -->
           <xsl:if test="string-length($VarBulletSeparator) &gt; 0">
            <wwdoc:Text value="{$VarBulletSeparator}" />
           </xsl:if>
          </wwdoc:Number>
         </xsl:if>
        </xsl:if>

        <!-- Copy text run elements -->
        <!--                        -->
        <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_copy">
         <xsl:with-param name="ParamDocument" select="$ParamDocument" />
        </xsl:apply-templates>
       </wwdoc:Paragraph>

       <!-- Copy Behaviors -->
       <!--                -->
       <xsl:for-each select="$ParamBehaviors[1]">
        <xsl:variable name="VarBehaviorParagraph" select="key('wwbehaviors-paragraphs-by-id', $ParamParagraph/@id)[1]" />

        <xsl:apply-templates select="$VarBehaviorParagraph" mode="wwmode:copy-elements" />
       </xsl:for-each>
      </xsl:otherwise>
     </xsl:choose>
    </wwtoc:Entry>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <!-- Copy TextRuns -->
 <!--               -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun_copy">
  <xsl:param name="ParamDocument" />
  <xsl:variable name="VarTextRun" select="."/>
  <!-- Create TOC text run -->
  <!--                     -->
  <wwdoc:TextRun>
   <xsl:copy-of select="$VarTextRun/@*" />

   <!-- Style -->
   <!--       -->
   <xsl:call-template name="Style">
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamNode" select="$VarTextRun" />
    <xsl:with-param name="ParamStyleType" select="'Character'" />
   </xsl:call-template>

   <!-- Recurse to find nested TextRuns, Text, and LineBreaks -->
   <!--                                                       -->
   <xsl:apply-templates select="$VarTextRun/*" mode="wwmode:textrun_copy">
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   </xsl:apply-templates>
  </wwdoc:TextRun>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:textrun_copy">
  <xsl:variable name="VarText" select="."/>
  <wwdoc:Text value="{$VarText/@value}" />
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun_copy">
  <wwdoc:Text value=" " />
 </xsl:template>

 <xsl:template match="* |text() | comment() | processing-instruction()" mode="wwmode:textrun_copy">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarList" select="."/>

  <xsl:apply-templates select="$VarList/*" mode="wwmode:toc">
    <xsl:with-param name="ParamDocument" select="$ParamDocument" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    <xsl:with-param name="ParamTrackDocumentPosition" select="$ParamTrackDocumentPosition" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarListItem" select="."/>

  <xsl:apply-templates select="$VarListItem/*" mode="wwmode:toc">
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   <xsl:with-param name="ParamTrackDocumentPosition" select="$ParamTrackDocumentPosition" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:toc">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamTrackDocumentPosition" />
  <xsl:param name="ParamBehaviors" />

  <xsl:variable name="VarBlock" select="."/>

  <xsl:apply-templates select="$VarBlock/*" mode="wwmode:toc">
   <xsl:with-param name="ParamDocument" select="$ParamDocument" />
   <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   <xsl:with-param name="ParamTrackDocumentPosition" select="$ParamTrackDocumentPosition" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template name="Style">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamStyleType" />

  <!-- Emit style block -->
  <!--                  -->
  <xsl:choose>
   <xsl:when test="string-length($ParamNode/@stylename) &gt; 0">
    <wwdoc:Style>
     <xsl:for-each select="$ParamDocument[1]">
      <!-- Get Catalog Style -->
      <!--                   -->
      <xsl:variable name="VarDocumentElement" select="$ParamDocument/wwdoc:Document" />
      <xsl:variable name="VarCatalogStyles" select="$VarDocumentElement/wwdoc:Styles/wwdoc:*[starts-with(local-name(), $ParamStyleType)]" />
      <xsl:variable name="VarCatalogStyle" select="$VarCatalogStyles/*[@name = $ParamNode/@stylename]" />

      <xsl:for-each select="$VarCatalogStyle/wwdoc:Style/wwdoc:Attribute">
       <xsl:variable name="VarAttribute" select="." />
       <xsl:variable name="VarOverrideValue" select="$ParamNode/wwdoc:Style/wwdoc:Attribute[@name = $VarAttribute/@name]/@value" />

       <xsl:if test="string-length($VarOverrideValue) = 0">
        <xsl:apply-templates select="." mode="wwmode:copy-elements" />
       </xsl:if>
      </xsl:for-each>
     </xsl:for-each>

     <!-- Get Overrides -->
     <!--               -->
     <xsl:apply-templates select="$ParamNode/wwdoc:Style/wwdoc:Attribute" mode="wwmode:copy-elements" />
    </wwdoc:Style>
   </xsl:when>

   <xsl:when test="count($ParamNode/wwdoc:Style) &gt; 0">
    <!-- Copy as is -->
    <!--            -->
    <wwdoc:Style>
     <xsl:apply-templates select="$ParamNode/wwdoc:Style/wwdoc:Attribute" mode="wwmode:copy-elements" />
    </wwdoc:Style>
   </xsl:when>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Alternate-TOC-Title">
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamParagraph" />

  <xsl:for-each select="$ParamParagraph//wwdoc:TextRun/wwdoc:Marker">
   <xsl:variable name="VarMarker" select="." />

   <!-- Get rule -->
   <!--          -->
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Marker', $VarMarker/@name, $ParamDocumentID, $VarMarker/@id)" />

   <!-- Replace TOC title? -->
   <!--                    -->
   <xsl:variable name="VarTOCTitleOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'alternate-toc-title']/@Value" />
   <xsl:if test="$VarTOCTitleOption = 'true'">
    <xsl:apply-templates select="$VarMarker" mode="wwmode:copy-elements" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <!-- wwmode:copy-elements -->
 <!--                      -->
 <xsl:template match="wwdoc:LineBreak" mode="wwmode:copy-elements">
  <wwdoc:Text value=" " />
 </xsl:template>

 <xsl:template match="*" mode="wwmode:copy-elements">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:copy-elements" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:copy-elements">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
