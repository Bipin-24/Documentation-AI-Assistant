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
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwmode wwfiles wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterEmitTableEntries" select="'false'" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwbehaviors-splits-by-id" match="wwbehaviors:Split" use="@id" />
 <xsl:key name="wwbehaviors-markers-by-id" match="wwbehaviors:Marker" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />
    <xsl:variable name="VarProjectGroupPosition" select="position()" />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Documents -->
     <!--           -->
     <xsl:variable name="VarProjectDocuments" select="$VarProjectGroup//wwproject:Document" />
     <xsl:variable name="VarProgressProjectDocumentsStart" select="wwprogress:Start(count($VarProjectDocuments))" />
     <xsl:for-each select="$VarProjectDocuments">
      <xsl:variable name="VarProjectDocument" select="." />
      <xsl:variable name="VarProjectDocumentPosition" select="position()" />

      <xsl:variable name="VarProgressProjectDocumentStart" select="wwprogress:Start(1)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Splits -->
       <!--        -->
       <xsl:for-each select="$GlobalFiles[1]">
        <xsl:variable name="VarFilesWithDocumentID" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)" />

        <!-- Load splits -->
        <!--             -->
        <xsl:variable name="VarFilesSplits" select="$VarFilesWithDocumentID[@type = $ParameterDependsType][1]" />
        <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

        <xsl:variable name="VarFilesDocument" select="$VarFilesWithDocumentID[@type = $ParameterDocumentType][1]" />
        <xsl:for-each select="$VarFilesDocument[1]">
         <xsl:variable name="VarFilesBehaviors" select="$VarFilesWithDocumentID[@type = $ParameterBehaviorsType][1]" />
         <xsl:for-each select="$VarFilesBehaviors[1]">
          <!-- Call template -->
          <!--               -->
          <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesSplits/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
          <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesSplits/@groupID, $VarFilesSplits/@documentID, $GlobalActionChecksum)" />
          <xsl:if test="not($VarUpToDate)">
           <xsl:variable name="VarResultAsXML">
            <!-- Load document -->
            <!--               -->
            <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />
            <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesBehaviors/@path, false())" />

            <xsl:call-template name="NameInfo">
             <xsl:with-param name="ParamProjectGroup" select="$VarProjectGroup" />
             <xsl:with-param name="ParamProjectGroupPosition" select="$VarProjectGroupPosition" />
             <xsl:with-param name="ParamProjectDocument" select="$VarProjectDocument" />
             <xsl:with-param name="ParamProjectDocumentPosition" select="$VarProjectDocumentPosition" />
             <xsl:with-param name="ParamDocument" select="$VarDocument" />
             <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
             <xsl:with-param name="ParamSplits" select="$VarSplits" />
            </xsl:call-template>
           </xsl:variable>
           <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
           <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
          </xsl:if>

          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" actionchecksum="{$GlobalActionChecksum}">
            <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
            <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
            <wwfiles:Depends path="{$VarFilesBehaviors/@path}" checksum="{$VarFilesBehaviors/@checksum}" groupID="{$VarFilesBehaviors/@groupID}" documentID="{$VarFilesBehaviors/@documentID}" />
           </wwfiles:File>
          </xsl:if>
         </xsl:for-each>
        </xsl:for-each>
       </xsl:for-each>
      </xsl:if>

      <xsl:variable name="VarProgressProjectDocumentEnd" select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:variable name="VarProgressProjectDocumentsEnd" select="wwprogress:End()" />
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEndt" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="SplitTitle">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamElement" />

  <xsl:if test="$ParamElement">
   <xsl:variable name="VarRawSplitTitle">
    <xsl:choose>
     <xsl:when test="local-name($ParamElement) = 'Paragraph'">
      <!-- Generate output? -->
      <!--                  -->
      <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamElement/@stylename, $ParamSplit/@documentID, $ParamElement/@id)" />
      <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
      <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
      <xsl:if test="$VarGenerateOutput">
       <!-- Use numbering? -->
       <!--                -->
       <xsl:variable name="VarUseNumberingInTOCOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering-toc']/@Value" />
       <xsl:variable name="VarUseNumberingInTOC" select="(string-length($VarUseNumberingInTOCOption) = 0) or ($VarUseNumberingInTOCOption = 'true')" />
       <xsl:if test="$VarUseNumberingInTOC">
        <!-- Use content numbering? -->
        <!--                        -->
        <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
        <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
        <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />
        <xsl:if test="(count($ParamElement/wwdoc:Number[1]) &gt; 0) and not($VarIgnoreDocumentNumber)">
         <xsl:for-each select="$ParamElement/wwdoc:Number/wwdoc:Text">
          <xsl:value-of select="@value" />
         </xsl:for-each>
        </xsl:if>
       </xsl:if>

       <!-- Paragraph content -->
       <!---                  -->
       <xsl:apply-templates select="$ParamElement/wwdoc:TextRun" mode="wwmode:textrun_text" />
      </xsl:if>
     </xsl:when>

     <xsl:when test="local-name($ParamElement) = 'Table'">
      <xsl:variable name="VarTableCaption">
       <xsl:call-template name="SplitTitle">
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
        <xsl:with-param name="ParamElement" select="$ParamElement/wwdoc:Caption/wwdoc:Paragraph[1]" />
       </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
       <xsl:when test="string-length($VarTableCaption) &gt; 0">
        <xsl:value-of select="$VarTableCaption" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:call-template name="SplitTitle">
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
         <xsl:with-param name="ParamElement" select="$ParamElement/wwdoc:*/wwdoc:TableRow/wwdoc:TableCell/wwdoc:Paragraph[1]" />
        </xsl:call-template>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarSplitTitle" select="normalize-space($VarRawSplitTitle)" />

   <xsl:choose>
    <xsl:when test="string-length($VarSplitTitle) &gt; 0">
     <xsl:value-of select="$VarSplitTitle" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="SplitTitle">
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
      <xsl:with-param name="ParamElement" select="$ParamElement/following-sibling::*[1]" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <!-- Process all valid text in TextRuns and nested TextRuns (depth first, in order). -->
 <!--                                                                                 -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun_text">
  <xsl:variable name="VarTextRun" select="."/>
  <!-- Recurse to find nested TextRuns, Text, and LineBreaks -->
  <!--                                                       -->
  <xsl:apply-templates select="$VarTextRun/*" mode="wwmode:textrun_text"/>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:textrun_text">
  <xsl:value-of select="./@value"/>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun_text">
  <!-- Replace LineBreaks with a single space -->
  <!--                                        -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="* |text() | comment() | processing-instruction()" mode="wwmode:textrun_text">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <xsl:template name="GetFileNameMarkers">
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamMarkers" />

  <!-- Create filename markers -->
  <!--                         -->
  <xsl:for-each select="$ParamMarkers">
   <xsl:variable name="VarMarker" select="." />

   <xsl:for-each select="$ParamBehaviors[1]">
    <xsl:variable name="VarBehaviorMarker" select="key('wwbehaviors-markers-by-id', $VarMarker/@id)" />

    <xsl:for-each select="$VarBehaviorMarker[1][(@behavior = 'filename') or (@behavior = 'filename-and-topic')]">
     <xsl:variable name="VarFileName">
      <xsl:for-each select="$VarMarker/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarNormalizedFileName" select="normalize-space($VarFileName)" />

     <xsl:if test="string-length($VarNormalizedFileName) &gt; 0">
      <wwsplits:FileName value="{$VarNormalizedFileName}" />
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="NameInfo">
  <xsl:param name="ParamProjectGroup" />
  <xsl:param name="ParamProjectGroupPosition" />
  <xsl:param name="ParamProjectDocument" />
  <xsl:param name="ParamProjectDocumentPosition" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamSplits" />

  <xsl:variable name="VarDocumentNameWithoutExtension" select="wwfilesystem:GetFileNameWithoutExtension(wwprojext:GetDocumentPath($ParamProjectDocument/@DocumentID))" />

  <wwsplits:Splits version="1.0">
   <xsl:variable name="VarSplitElements" select="$ParamSplits/wwsplits:Splits/wwsplits:Split" />
   <xsl:variable name="VarLastSplitElementPosition" select="count($VarSplitElements)" />
   <xsl:for-each select="$VarSplitElements">
    <xsl:variable name="VarSplit" select="." />
    <xsl:variable name="VarPosition" select="position()" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Identify start/end positions -->
     <!--                              -->
     <xsl:variable name="VarStartPosition" select="$VarSplit/@documentposition" />
     <xsl:variable name="VarEndPosition">
      <xsl:choose>
       <xsl:when test="position() = $VarLastSplitElementPosition">
        <xsl:value-of select="-1" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$VarSplit/following-sibling::wwsplits:Split[1]/@documentposition - 1" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Select content -->
     <!--                -->
     <xsl:for-each select="$ParamDocument[1]">
      <xsl:variable name="VarSplitStartElement" select="$ParamDocument/wwdoc:Document/wwdoc:Content/*[@id = $VarSplit/@id]" />
      <xsl:variable name="VarSplitPositionCount" select="$VarEndPosition - $VarStartPosition" />
      <xsl:variable name="VarContent" select="$VarSplitStartElement | $VarSplitStartElement/following-sibling::*[($VarEndPosition = -1) or (position() &lt;= $VarSplitPositionCount)]" />

      <xsl:variable name="VarSplitTitle">
       <xsl:call-template name="SplitTitle">
        <xsl:with-param name="ParamSplit" select="$VarSplit" />
        <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
        <xsl:with-param name="ParamElement" select="$VarContent[1]" />
       </xsl:call-template>
      </xsl:variable>

      <!-- Split behavior -->
      <!--                -->
      <xsl:for-each select="$ParamBehaviors[1]">
       <xsl:variable name="VarBehaviorsSplit" select="key('wwbehaviors-splits-by-id', $VarSplit/@id)[1]" />

       <!-- Window type -->
       <!--             -->
       <xsl:variable name="VarWindowType" select="$VarBehaviorsSplit/@window-type" />

       <!-- Name Info -->
       <!--           -->
       <wwsplits:Split groupID="{$ParamProjectGroup/@GroupID}" documentID="{$ParamProjectDocument/@DocumentID}" id="{$VarSplit/@id}" position="{$VarPosition}" documentstartposition="{$VarStartPosition}" documentendposition="{$VarStartPosition + count($VarContent) - 1}" title="{$VarSplitTitle}">
        <xsl:if test="string-length($VarWindowType) &gt; 0">
         <xsl:attribute name="window-type">
          <xsl:value-of select="$VarWindowType" />
         </xsl:attribute>
        </xsl:if>
        <wwsplits:Group name="{$ParamProjectGroup/@Name}" id="{$ParamProjectGroup/@GroupID}" position="{$ParamProjectGroupPosition}" />
        <wwsplits:Document path="{wwprojext:GetDocumentPath($ParamProjectDocument/@DocumentID)}" id="{$ParamProjectDocument/@DocumentID}" position="{$ParamProjectDocumentPosition}" />

        <!-- Select page markers -->
        <!--                     -->
        <xsl:variable name="VarPageMarkers" select="$VarContent/wwdoc:Marker | $VarContent//wwdoc:Marker[count(ancestor::wwdoc:Frame[1]) = 0]" />

        <!-- Get last file name marker -->
        <!--                           -->
        <xsl:variable name="VarPageFileNameMarkersAsXML">
         <xsl:call-template name="GetFileNameMarkers">
          <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
          <xsl:with-param name="ParamMarkers" select="$VarPageMarkers" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarPageFileNameMarkers" select="msxsl:node-set($VarPageFileNameMarkersAsXML)/wwsplits:FileName" />
        <xsl:copy-of select="$VarPageFileNameMarkers[count($VarPageFileNameMarkers)]" />

        <!-- Get last page style marker -->
        <!--                            -->
        <xsl:variable name="VarPageStyle">
         <xsl:variable name="VarPageStyleMarkers" select="$VarPageMarkers[@name = 'PageStyle']" />
         <xsl:variable name="VarPageStyleMarkersCount" select="count($VarPageStyleMarkers)" />
         <xsl:choose>
          <xsl:when test="$VarPageStyleMarkersCount &gt; 0">
           <xsl:for-each select="$VarPageStyleMarkers[$VarPageStyleMarkersCount]/wwdoc:TextRun/wwdoc:Text">
            <xsl:value-of select="@value" />
           </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="'Default'" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>
        <wwsplits:PageStyle value="{$VarPageStyle}" />

        <!-- Get frames -->
        <!--            -->
        <wwsplits:Frames>
         <xsl:variable name="VarFrames" select="$VarContent[local-name() = 'Frame'] | $VarContent//wwdoc:Frame[count(ancestor::wwdoc:Frame[1]) = 0]" />
         <xsl:for-each select="$VarFrames">
          <xsl:variable name="VarFrame" select="." />

          <!-- Generate paragraph? -->
          <!--                     -->
          <xsl:variable name="VarParagraphGenerateOutputAsText">
           <xsl:for-each select="($VarFrame/parent::wwdoc:Paragraph[1] | $VarFrame/parent::wwdoc:TextRun/parent::wwdoc:Paragraph[1])[1]">
            <xsl:variable name="VarParagraph" select="." />

            <xsl:variable name="VarParagraphContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamProjectDocument/@documentID, $VarParagraph/@id)" />
            <xsl:variable name="VarParagraphGenerateOutputOption" select="$VarParagraphContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
            <xsl:value-of select="$VarParagraphGenerateOutputOption" />
           </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="VarParagraphGenerateOutput" select="$VarParagraphGenerateOutputAsText != 'false'" />
          <xsl:if test="$VarParagraphGenerateOutput">
           <!-- Process frame -->
           <!--               -->
           <xsl:variable name="VarFrameTitle">
            <xsl:for-each select="$VarFrame/wwdoc:Description/wwdoc:Paragraph[1]//wwdoc:TextRun/wwdoc:Text">
             <xsl:value-of select="@value" />
            </xsl:for-each>
           </xsl:variable>

           <wwsplits:Frame position="{position()}" title="{$VarFrameTitle}">
            <xsl:copy-of select="$VarFrame" />

            <!-- Select frame markers -->
            <!--                      -->
            <xsl:variable name="VarFrameMarkers" select="$VarFrame//wwdoc:Marker" />

            <!-- Get last file name marker -->
            <!--                           -->
            <xsl:variable name="VarFrameFileNameMarkersAsXML">
             <xsl:call-template name="GetFileNameMarkers">
              <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
              <xsl:with-param name="ParamMarkers" select="$VarFrameMarkers" />
             </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="VarFrameFileNameMarkers" select="msxsl:node-set($VarFrameFileNameMarkersAsXML)/wwsplits:FileName" />
            <xsl:copy-of select="$VarFrameFileNameMarkers[count($VarFrameFileNameMarkers)]" />
           </wwsplits:Frame>
          </xsl:if>
         </xsl:for-each>
        </wwsplits:Frames>

        <!-- Emit Table file names if supported -->
        <!--                                    -->
        <xsl:if test="$ParameterEmitTableEntries = 'true'">
         <wwsplits:Tables>
          <xsl:variable name="VarTables" select="$VarBehaviorsSplit//wwbehaviors:Table" />
          <xsl:for-each select="$VarTables">
           <xsl:variable name="VarTable" select="." />

           <wwsplits:Table groupID="{$ParamProjectGroup/@GroupID}" documentID="{$ParamProjectDocument/@DocumentID}" id="{$VarTable/@id}" position="{position()}" />
          </xsl:for-each>
         </wwsplits:Tables>
        </xsl:if>

        <!-- Emit Popup file names if supported -->
        <!--                                    -->
        <wwsplits:Popups>
         <xsl:variable name="VarPopupDefineElements" select="$VarBehaviorsSplit//wwbehaviors:Paragraph[(@popup = 'define') or (@popup = 'define-no-output')] |
                                                             $VarBehaviorsSplit//wwbehaviors:Table[(@popup = 'define') or (@popup = 'define-no-output')]" />

         <xsl:for-each select="$VarPopupDefineElements">
          <xsl:variable name="VarPopupParagraph" select="." />

          <wwsplits:Popup groupID="{$ParamProjectGroup/@GroupID}" documentID="{$ParamProjectDocument/@DocumentID}" id="{$VarPopupParagraph/@id}" stylename="{$VarPopupParagraph/@popup-page-rule}" />
         </xsl:for-each>
        </wwsplits:Popups>
       </wwsplits:Split>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>
   </xsl:for-each>

  </wwsplits:Splits>
 </xsl:template>
</xsl:stylesheet>
