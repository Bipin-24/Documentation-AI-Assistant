<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwbehaviors wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDropDowns" />
 <xsl:param name="ParameterPopups" />


 <xsl:namespace-alias stylesheet-prefix="wwbehaviors" result-prefix="#default" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
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
    <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressWIFFilesStart" select="wwprogress:Start(count($VarWIFFiles))" />

    <xsl:for-each select="$VarWIFFiles">
     <xsl:variable name="VarWIFFile" select="." />

     <xsl:variable name="VarProgressWIFFileStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Up to date? -->
      <!--             -->
      <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWIFFile/@path), concat(translate($ParameterType, ':', '_'), '.xml'))" />
      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarWIFFile/@groupID, $VarWIFFile/@documentID, $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Behaviors -->
        <!--           -->
        <xsl:call-template name="Behaviors">
         <xsl:with-param name="ParamWIFFile" select="$VarWIFFile" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
      </xsl:if>

      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
       <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{$VarWIFFile/@checksum}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
      </wwfiles:File>
     </xsl:if>

     <xsl:variable name="VarProgressWIFFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressWIFFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Behaviors">
  <xsl:param name="ParamWIFFile" />

  <wwbehaviors:Behaviors version="1.0">
   <!-- WIF document -->
   <!--              -->
   <xsl:variable name="VarWIFDocument" select="wwexsldoc:LoadXMLWithoutResolver($ParamWIFFile/@path, false())" />

   <xsl:apply-templates select="$VarWIFDocument/wwdoc:Document/wwdoc:Content/*" mode="wwmode:behavior">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
    <xsl:with-param name="ParamTopLevel" select="true()" />
   </xsl:apply-templates>

  </wwbehaviors:Behaviors>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:behavior">
  <xsl:param name="ParamTable" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $ParamTable/@stylename, $ParamWIFFile/@documentID, $ParamTable/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Split Priority -->
   <!--                -->
   <xsl:variable name="VarSplitPriorityOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'split-priority']/@Value" />
   <xsl:variable name="VarSplitPriority">
    <xsl:choose>
     <xsl:when test="string-length($VarSplitPriorityOption) = 0">
      <xsl:value-of select="'none'" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarSplitPriorityOption" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Table -->
   <!--       -->
   <wwbehaviors:Table id="{$ParamTable/@id}">
    <xsl:if test="$ParamTopLevel">
     <xsl:attribute name="documentposition">
      <xsl:value-of select="position()" />
     </xsl:attribute>
     <xsl:attribute name="splitpriority">
      <xsl:value-of select="$VarSplitPriority" />
     </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="$ParamTable/wwdoc:*" mode="wwmode:behavior">
     <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
     <xsl:with-param name="ParamTopLevel" select="false()" />
    </xsl:apply-templates>
   </wwbehaviors:Table>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:behavior">
  <xsl:param name="ParamList" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamList/@stylename, $ParamWIFFile/@documentID, $ParamList/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Split Priority -->
   <!--                -->
   <xsl:variable name="VarSplitPriorityOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'split-priority']/@Value" />
   <xsl:variable name="VarSplitPriority">
    <xsl:choose>
     <xsl:when test="string-length($VarSplitPriorityOption) = 0">
      <xsl:value-of select="'none'" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarSplitPriorityOption" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- List -->
   <!--       -->
   <wwbehaviors:Paragraph id="{$ParamList/@id}">
    <xsl:if test="$ParamTopLevel">
     <xsl:attribute name="documentposition">
      <xsl:value-of select="position()" />
     </xsl:attribute>
     <xsl:attribute name="splitpriority">
      <xsl:value-of select="$VarSplitPriority" />
     </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="$ParamList/wwdoc:*" mode="wwmode:behavior">
     <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
     <xsl:with-param name="ParamTopLevel" select="false()" />
    </xsl:apply-templates>
   </wwbehaviors:Paragraph>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:behavior">
  <xsl:param name="ParamListItem" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamListItem/@stylename, $ParamWIFFile/@documentID, $ParamListItem/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Split Priority -->
   <!--                -->
   <xsl:variable name="VarSplitPriorityOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'split-priority']/@Value" />
   <xsl:variable name="VarSplitPriority">
    <xsl:choose>
     <xsl:when test="string-length($VarSplitPriorityOption) = 0">
      <xsl:value-of select="'none'" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarSplitPriorityOption" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- List Item -->
   <!--       -->
   <wwbehaviors:Paragraph id="{$ParamListItem/@id}">
    <xsl:if test="$ParamTopLevel">
     <xsl:attribute name="documentposition">
      <xsl:value-of select="position()" />
     </xsl:attribute>
     <xsl:attribute name="splitpriority">
      <xsl:value-of select="$VarSplitPriority" />
     </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="$ParamListItem/wwdoc:*" mode="wwmode:behavior">
     <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
     <xsl:with-param name="ParamTopLevel" select="false()" />
    </xsl:apply-templates>
   </wwbehaviors:Paragraph>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:behavior">
  <xsl:param name="ParamBlock" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamBlock/@stylename, $ParamWIFFile/@documentID, $ParamBlock/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Split Priority -->
   <!--                -->
   <xsl:variable name="VarSplitPriorityOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'split-priority']/@Value" />
   <xsl:variable name="VarSplitPriority">
    <xsl:choose>
     <xsl:when test="string-length($VarSplitPriorityOption) = 0">
      <xsl:value-of select="'none'" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$VarSplitPriorityOption" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Block -->
   <!--       -->
   <wwbehaviors:Paragraph id="{$ParamBlock/@id}">
    <xsl:if test="$ParamTopLevel">
     <xsl:attribute name="documentposition">
      <xsl:value-of select="position()" />
     </xsl:attribute>
     <xsl:attribute name="splitpriority">
      <xsl:value-of select="$VarSplitPriority" />
     </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="$ParamBlock/wwdoc:*" mode="wwmode:behavior">
     <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
     <xsl:with-param name="ParamTopLevel" select="false()" />
    </xsl:apply-templates>
   </wwbehaviors:Paragraph>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Frame" mode="wwmode:behavior">
  <xsl:param name="ParamFrame" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamFrame/@stylename, $ParamWIFFile/@documentID, $ParamFrame/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Frame -->
   <!--       -->
   <wwbehaviors:Frame>
    <xsl:if test="string-length($ParamFrame/@id) &gt; 0">
     <xsl:attribute name="id">
      <xsl:value-of select="$ParamFrame/@id" />
     </xsl:attribute>
    </xsl:if>
    <xsl:if test="$ParamTopLevel">
     <xsl:attribute name="documentposition">
      <xsl:value-of select="position()" />
     </xsl:attribute>
    </xsl:if>

    <xsl:apply-templates select="$ParamFrame/wwdoc:*" mode="wwmode:behavior">
     <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
     <xsl:with-param name="ParamTopLevel" select="false()" />
    </xsl:apply-templates>
   </wwbehaviors:Frame>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:behavior">
  <xsl:param name="ParamParagraph" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get context rule -->
  <!--                  -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamWIFFile/@documentID, $ParamParagraph/@id)" />

  <!-- Generate output? -->
  <!--                  -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Preserve empty? -->
   <!--                 -->
   <xsl:variable name="VarPreserveEmptyOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
   <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

   <!-- Non-empty text runs -->
   <!--                     -->
   <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />

   <!-- Emit? -->
   <!--       -->
   <xsl:if test="$VarPreserveEmpty or (count($VarTextRuns[1]) = 1)">
    <!-- Split Priority -->
    <!--                -->
    <xsl:variable name="VarSplitPriorityOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'split-priority']/@Value" />
    <xsl:variable name="VarSplitPriority">
     <xsl:choose>
      <xsl:when test="$VarSplitPriorityOption = 'use-toc-level'">
       <!-- Determine TOC level -->
       <!--                     -->
       <xsl:variable name="VarTOCOptionHint" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'toc-level']/@Value" />
       <xsl:choose>
        <xsl:when test="$VarTOCOptionHint = 'auto-detect'">
         <xsl:for-each select="$ParamParagraph[1]">
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
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="$VarTOCOptionHint" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$VarSplitPriorityOption" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Paragraph -->
    <!--           -->
    <wwbehaviors:Paragraph id="{$ParamParagraph/@id}">
     <xsl:if test="$ParamTopLevel">
      <xsl:attribute name="documentposition">
       <xsl:value-of select="position()" />
      </xsl:attribute>
      <xsl:attribute name="splitpriority">
       <xsl:value-of select="$VarSplitPriority" />
      </xsl:attribute>
     </xsl:if>

     <xsl:apply-templates select="$ParamParagraph/wwdoc:*" mode="wwmode:behavior">
      <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
      <xsl:with-param name="ParamTopLevel" select="false()" />
     </xsl:apply-templates>
    </wwbehaviors:Paragraph>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:behavior">
  <xsl:param name="ParamMarker" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarRule" select="wwprojext:GetRule('Marker', $ParamMarker/@name)" />
  <xsl:variable name="VarBehaviorOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'marker-type']/@Value" />
  <xsl:variable name="VarIgnore" select="(string-length($VarBehaviorOption) = 0) or ($VarBehaviorOption = 'ignore')" />
  <xsl:if test="not($VarIgnore)">
   <!-- Marker -->
   <!--        -->
   <wwbehaviors:Marker behavior="{$VarBehaviorOption}" id="{$ParamMarker/@id}">
    <xsl:copy-of select="$ParamMarker" />
   </wwbehaviors:Marker>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:TableCell" mode="wwmode:behavior">
  <xsl:param name="ParamTableCell" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <wwbehaviors:TableCell>
   <xsl:apply-templates select="$ParamTableCell/wwdoc:*" mode="wwmode:behavior">
    <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
    <xsl:with-param name="ParamTopLevel" select="false()" />
   </xsl:apply-templates>
  </wwbehaviors:TableCell>
 </xsl:template>


 <xsl:template match="wwdoc:*" mode="wwmode:behavior">
  <xsl:param name="ParamNode" select="." />
  <xsl:param name="ParamWIFFile" />
  <xsl:param name="ParamTopLevel" />

  <xsl:apply-templates select="$ParamNode/wwdoc:*" mode="wwmode:behavior">
   <xsl:with-param name="ParamWIFFile" select="$ParamWIFFile" />
   <xsl:with-param name="ParamTopLevel" select="false()" />
  </xsl:apply-templates>
 </xsl:template>
</xsl:stylesheet>
