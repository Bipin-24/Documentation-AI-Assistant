<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwtrait="urn:WebWorks-Engine-FormatTraitInfo-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwbehaviors wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterSegmentsType" select="''" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="no" />
 <xsl:namespace-alias stylesheet-prefix="wwlinks" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwproject-groups-by-id" match="wwproject:Group" use="@GroupID" />
 <xsl:key name="wwbehaviors-splits-by-id" match="wwbehaviors:Split" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />
 <xsl:key name="wwbehaviors-tables-by-id" match="wwbehaviors:Table" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />

   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarUniqueNamesFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressUniqueNamesFilesStart" select="wwprogress:Start(count($VarUniqueNamesFiles))" />

    <xsl:for-each select="$VarUniqueNamesFiles">
     <xsl:variable name="VarUniqueNamesFile" select="." />

     <xsl:variable name="VarProgressUniqueNamesFileStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Load document -->
      <!--               -->
      <xsl:variable name="VarUniqueNames" select="wwexsldoc:LoadXMLWithoutResolver($VarUniqueNamesFile/@path, false())" />

      <xsl:call-template name="Links">
       <xsl:with-param name="ParamUniqueNamesFile" select="$VarUniqueNamesFile" />
       <xsl:with-param name="ParamUniqueNames" select="$VarUniqueNames" />
       <xsl:with-param name="ParamGroupID" select="$VarUniqueNamesFile/@groupID" />
      </xsl:call-template>
     </xsl:if>

     <xsl:variable name="VarProgressUniqueNamesFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressUniqueNamesFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="File-Element-Open">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamFirstSplit" />
  <xsl:param name="ParamNode" />

  <xsl:for-each select="$ParamBehaviors[1]">
   <xsl:variable name="VarSplitBehavior" select="key('wwbehaviors-splits-by-id', $ParamNode/@id)[1]" />

   <!-- Start of split? -->
   <!--                 -->
   <xsl:for-each select="$VarSplitBehavior[1]">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:variable name="VarSplit" select="$ParamSplits[@id = $VarSplitBehavior/@id]" />

     <xsl:variable name="VarDocumentPath" select="wwprojext:GetDocumentPath($VarSplit/@documentID)" />

     <!-- Close previous file element if not first split -->
     <!--                                                -->
     <xsl:if test="not($ParamFirstSplit)">
      <xsl:call-template name="File-Element-Close" />
     </xsl:if>

     <wwexsldoc:Text disable-output-escaping="yes">
      <xsl:text>&lt;</xsl:text>
      <xsl:text>File</xsl:text>
      <xsl:text> groupID="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@groupID)" /><xsl:text>"</xsl:text>
      <xsl:text> documentID="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@documentID)" /><xsl:text>"</xsl:text>
      <xsl:text> documentpath="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarDocumentPath)" /><xsl:text>"</xsl:text>
      <xsl:text> documentpath-lowercase="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute(wwstring:ToLower($VarDocumentPath))" /><xsl:text>"</xsl:text>
      <xsl:text> path="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@path)" /><xsl:text>"</xsl:text>
      <xsl:text> title="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@title)" /><xsl:text>"</xsl:text>
      <xsl:if test="string-length($VarSplit/@fileposition) &gt; 0">
       <xsl:text> fileposition="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@fileposition)" /><xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="string-length($VarSplit/@window-type) &gt; 0">
       <xsl:text> window-type="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute($VarSplit/@window-type)" /><xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>&gt;</xsl:text>
      <xsl:text>
</xsl:text>
     </wwexsldoc:Text>
    </xsl:if>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="File-Element-Close">
  <wwexsldoc:Text disable-output-escaping="yes">
   <xsl:text>&lt;</xsl:text>
   <xsl:text>/</xsl:text>
   <xsl:text>File</xsl:text>
   <xsl:text>&gt;</xsl:text>
   <xsl:text>
</xsl:text>
  </wwexsldoc:Text>
 </xsl:template>


 <xsl:template name="Links">
  <xsl:param name="ParamUniqueNamesFile" />
  <xsl:param name="ParamUniqueNames" />
  <xsl:param name="ParamGroupID" />

  <!-- Find Project Group -->
  <!--                    -->
  <xsl:for-each select="$GlobalProject[1]">
   <xsl:variable name="VarProjectGroup" select="key('wwproject-groups-by-id', $ParamGroupID)" />

   <xsl:variable name="VarProjectDocuments" select="$VarProjectGroup//wwproject:Document" />
   <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarProjectDocuments))" />

   <!-- Iterate Group Documents -->
   <!--                         -->
   <xsl:for-each select="$VarProjectDocuments">
    <xsl:variable name="VarProjectDocument" select="." />

    <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarDocumentFiles" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterDocumentType]" />
      <xsl:variable name="VarBehaviorsFiles" select="key('wwfiles-files-by-documentid', $VarProjectDocument/@DocumentID)[@type = $ParameterBehaviorsType]" />

      <xsl:for-each select="$VarDocumentFiles[1]">
       <xsl:variable name="VarDocumentFile" select="." />

       <xsl:for-each select="$VarBehaviorsFiles[1]">
        <xsl:variable name="VarBehaviorsFile" select="." />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentFile/@path), concat(translate($ParameterType, ':', '_'), '.xml'))" />

         <!-- Up to date? -->
         <!--             -->
         <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentFile/@groupID, $VarDocumentFile/@documentID, $GlobalActionChecksum)" />
         <xsl:if test="not($VarUpToDate)">
          <xsl:variable name="VarResultAsXML">
           <wwlinks:Links version="1.0">
            <!-- Load behaviors -->
            <!--                -->
            <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

            <!-- Segments -->
            <!--          -->
            <xsl:variable name="VarSegmentsAsXML">
             <xsl:choose>
              <!-- Use defined segments -->
              <!--                      -->
              <xsl:when test="string-length($ParameterSegmentsType) &gt; 0">
               <xsl:for-each select="$GlobalFiles[1]">
                <xsl:variable name="VarSegmentsFile" select="key('wwfiles-files-by-documentid', $VarDocumentFile/@documentID)[@type = $ParameterSegmentsType][1]" />
                <xsl:variable name="VarSegments" select="wwexsldoc:LoadXMLWithoutResolver($VarSegmentsFile/@path, false())" />
                <xsl:copy-of select="$VarSegments/wwsplits:Segments/wwsplits:Segment" />
               </xsl:for-each>
              </xsl:when>

              <!-- Synthesize segment for WIF file -->
              <!--                                 -->
              <xsl:otherwise>
               <wwsplits:Segment position="1" documentstartposition="1" path="{$VarDocumentFile/@path}" />
              </xsl:otherwise>
             </xsl:choose>
            </xsl:variable>
            <xsl:variable name="VarSegments" select="msxsl:node-set($VarSegmentsAsXML)/wwsplits:Segment" />

            <!-- Process splits into links -->
            <!--                           -->
            <xsl:variable name="VarSplits" select="$ParamUniqueNames/wwsplits:Splits/wwsplits:Split[@documentID = $VarProjectDocument/@DocumentID]" />
            <xsl:for-each select="$VarSplits[1]">
             <xsl:variable name="VarSplit" select="." />

             <!-- Call template -->
             <!--               -->
             <xsl:call-template name="Segments">
              <xsl:with-param name="ParamSegments" select="$VarSegments" />
              <xsl:with-param name="ParamSplits" select="$VarSplits" />
              <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
             </xsl:call-template>
            </xsl:for-each>
           </wwlinks:Links>
          </xsl:variable>

          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
           <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
          </xsl:if>
         </xsl:if>

         <!-- Aborted? -->
         <!--          -->
         <xsl:if test="not(wwprogress:Abort())">
          <!-- Report file -->
          <!--             -->
          <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
           <wwfiles:Depends path="{$ParamUniqueNamesFile/@path}" checksum="{$ParamUniqueNamesFile/@checksum}" groupID="{$ParamUniqueNamesFile/@groupID}" documentID="{$ParamUniqueNamesFile/@documentID}" />
           <wwfiles:Depends path="{$VarDocumentFile/@path}" checksum="{$VarDocumentFile/@checksum}" groupID="{$VarDocumentFile/@groupID}" documentID="{$VarDocumentFile/@documentID}" />
           <wwfiles:Depends path="{$VarBehaviorsFile/@path}" checksum="{$VarBehaviorsFile/@checksum}" groupID="{$VarBehaviorsFile/@groupID}" documentID="{$VarBehaviorsFile/@documentID}" />
          </wwfiles:File>
         </xsl:if>
        </xsl:if>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Segments">
  <xsl:param name="ParamSegments" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <!-- Iterate segments -->
  <!--                  -->
  <xsl:variable name="VarProgressSegmentsStart" select="wwprogress:Start(count($ParamSegments))" />
  <xsl:for-each select="$ParamSegments">
   <xsl:sort select="@position" order="ascending" data-type="number" />
   <xsl:variable name="VarSegment" select="." />

   <xsl:variable name="VarProgressSegmentStart" select="wwprogress:Start(1)" />

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <!-- Determine segment start/end positions -->
    <!--                                       -->
    <xsl:variable name="VarSegmentDocumentStartPosition" select="number($VarSegment/@documentstartposition)" />
    <xsl:variable name="VarSegmentDocumentEndPosition">
     <xsl:variable name="VarNextSegment" select="$VarSegment/following-sibling::wwsplits:Segment[1]" />
     <xsl:choose>
      <xsl:when test="count($VarNextSegment) = 1">
       <xsl:value-of select="number($VarNextSegment/@documentstartposition) - 1" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="-1" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Load segment -->
    <!--              -->
    <xsl:variable name="VarDocumentSegment" select="wwexsldoc:LoadXMLWithoutResolver($VarSegment/@path, false())" />

    <!-- Emit links -->
    <!--            -->
    <xsl:apply-templates select="$VarDocumentSegment" mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$VarSegmentDocumentStartPosition" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$VarSegmentDocumentEndPosition" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    </xsl:apply-templates>

    <!-- Close file element -->
    <!--                    -->
    <xsl:call-template name="File-Element-Close" />
   </xsl:if>

   <xsl:variable name="VarProgressSegmentEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressSegmentsEnd" select="wwprogress:End()" />
 </xsl:template>


 <xsl:template name="Link-Paragraph">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamID" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamTopic" />
  <xsl:param name="ParamWindowType" />

  <wwlinks:Paragraph id="{$ParamID}" linkid="{$ParamLinkID}">
   <!-- popup attributes -->
   <!--                  -->
   <xsl:if test="($ParamPopupBehavior = 'define') or ($ParamPopupBehavior = 'define-no-output')">
    <xsl:attribute name="popup">
     <xsl:value-of select="'true'" />
    </xsl:attribute>

    <xsl:attribute name="popup-only">
     <xsl:value-of select="$ParamPopupBehavior = 'define-no-output'" />
    </xsl:attribute>
   </xsl:if>

   <!-- topic attribute -->
   <!--                 -->
   <xsl:if test="string-length($ParamTopic) &gt; 0">
    <xsl:attribute name="topic">
     <xsl:value-of select="$ParamTopic" />
    </xsl:attribute>
   </xsl:if>

   <!-- window-type attribute -->
   <!--                       -->
   <xsl:if test="string-length($ParamWindowType) &gt; 0">
    <xsl:attribute name="window-type">
     <xsl:value-of select="$ParamWindowType" />
    </xsl:attribute>
   </xsl:if>

   <!-- first attribute -->
   <!--                 -->
   <xsl:attribute name="first">
    <xsl:for-each select="$ParamBehaviors[1]">
     <xsl:variable name="VarSplitBehavior" select="key('wwbehaviors-splits-by-id', $ParamLinkID)" />

     <xsl:choose>
      <xsl:when test="count($VarSplitBehavior) &gt; 0">
       <xsl:value-of select="$VarSplitBehavior/@id = $ParamID" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="false()" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:attribute>
  </wwlinks:Paragraph>
 </xsl:template>


 <!-- wwmode:links -->
 <!--              -->

 <xsl:template match="/" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Document" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Content" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph | wwdoc:List | wwdoc:Block | wwdoc:Table" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamNode" select="." />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <xsl:variable name="VarFirstSplit" select="position() = $ParamSegmentDocumentStartPosition" />

   <!-- Valid ID? -->
   <!--           -->
   <xsl:if test="string-length($ParamNode/@id) &gt; 0">
    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:call-template name="File-Element-Open">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
      <xsl:with-param name="ParamFirstSplit" select="$VarFirstSplit" />
      <xsl:with-param name="ParamNode" select="$ParamNode" />
     </xsl:call-template>

     <xsl:for-each select="$ParamBehaviors[1]">
      <xsl:variable name="VarBehaviorNode" select="key('wwbehaviors-paragraphs-by-id', $ParamNode/@id)[1] | key('wwbehaviors-tables-by-id', $ParamNode/@id)[1]" />

      <!-- Missing behavior implies this paragraph is not generated -->
      <!--                                                          -->
      <xsl:for-each select="$VarBehaviorNode[1]">
       <!-- Determine window-type -->
       <!--                       -->
       <xsl:variable name="VarWindowType">
        <xsl:variable name="VarWindowTypeHint" select="$VarBehaviorNode/@window-type" />

        <xsl:choose>
         <!-- Window-type defined -->
         <!--                     -->
         <xsl:when test="string-length($VarWindowTypeHint) &gt; 0">
          <xsl:value-of select="$VarWindowTypeHint" />
         </xsl:when>

         <!-- No window-type defined -->
         <!--                        -->
         <xsl:otherwise>
          <xsl:value-of select="''" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

       <!-- Emit paragraph link -->
       <!--                     -->
       <xsl:call-template name="Link-Paragraph">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
        <xsl:with-param name="ParamID" select="$ParamNode/@id" />
        <xsl:with-param name="ParamLinkID" select="$ParamNode/@id" />
        <xsl:with-param name="ParamPopupBehavior" select="$VarBehaviorNode/@popup" />
        <xsl:with-param name="ParamTopic" select="''" />
        <xsl:with-param name="ParamWindowType" select="$VarWindowType" />
       </xsl:call-template>

       <!-- Handle multiple topics for this paragraph -->
       <!--                                           -->
       <xsl:variable name="VarTopicMarkerBehaviors" select="$VarBehaviorNode/wwbehaviors:Marker[(@behavior = 'topic') or (@behavior = 'filename-and-topic')]" />
       <xsl:for-each select="$VarTopicMarkerBehaviors">
        <xsl:variable name="VarTopicMarkerBehavior" select="." />

        <xsl:variable name="VarTopic">
         <xsl:for-each select="$VarTopicMarkerBehavior/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
          <xsl:value-of select="@value" />
         </xsl:for-each>
        </xsl:variable>

        <xsl:if test="string-length($VarTopic) &gt; 0">
         <!-- Emit paragraph link -->
         <!--                     -->
         <xsl:call-template name="Link-Paragraph">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
          <xsl:with-param name="ParamID" select="$ParamNode/@id" />
          <xsl:with-param name="ParamLinkID" select="$ParamNode/@id" />
          <xsl:with-param name="ParamPopupBehavior" select="$VarBehaviorNode/@popup" />
          <xsl:with-param name="ParamTopic" select="$VarTopic" />
          <xsl:with-param name="ParamWindowType" select="$VarWindowType" />
         </xsl:call-template>
        </xsl:if>
       </xsl:for-each>

       <!-- Handle aliases and nested links -->
       <!--                                 -->
       <xsl:apply-templates select="$ParamNode/*" mode="wwmode:paragraphlinks">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
        <xsl:with-param name="ParamLinkID" select="$ParamNode/@id" />
        <xsl:with-param name="ParamPopupBehavior" select="$VarBehaviorNode/@popup" />
        <xsl:with-param name="ParamWindowType" select="$VarWindowType" />
       </xsl:apply-templates>
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamNode" select="." />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <!-- Within segment? -->
  <!--                 -->
  <xsl:if test="(position() &gt;= $ParamSegmentDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
   <xsl:variable name="VarFirstSplit" select="position() = $ParamSegmentDocumentStartPosition" />

   <!-- Aborted? -->
   <!--          -->
   <xsl:if test="not(wwprogress:Abort())">
    <xsl:call-template name="File-Element-Open">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     <xsl:with-param name="ParamFirstSplit" select="$VarFirstSplit" />
     <xsl:with-param name="ParamNode" select="$ParamNode" />
    </xsl:call-template>

    <xsl:apply-templates mode="wwmode:links">
     <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
     <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:links">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- wwmode:paragraph-links -->
 <!--                        -->

 <xsl:template match="wwdoc:Note" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Handle footnotes -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:links">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Emit paragraph link -->
  <!--                     -->
  <xsl:call-template name="Link-Paragraph">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamID" select="@id" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamTopic" select="''" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:call-template>

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:paragraphlinks">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
    <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
    <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Alias" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Emit paragraph link -->
  <!--                     -->
  <xsl:call-template name="Link-Paragraph">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamID" select="@value" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamTopic" select="''" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:call-template>

  <xsl:apply-templates mode="wwmode:paragraphlinks">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:links">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:links">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:links">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:links">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="-1" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="-1" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:framelinks">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
    <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
    <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwdoc:Style" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <xsl:template match="*" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:apply-templates mode="wwmode:paragraphlinks">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
    <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
    <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
    <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:paragraphlinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Nothing to do here -->
  <!--                    -->
 </xsl:template>


 <!-- wwmode:framelinks -->
 <!--                   -->

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:framelinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Emit paragraph link -->
  <!--                     -->
  <xsl:call-template name="Link-Paragraph">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamID" select="@id" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamTopic" select="''" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:call-template>

  <xsl:apply-templates mode="wwmode:paragraphlinks">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:framelinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <xsl:apply-templates mode="wwmode:framelinks">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
   <xsl:with-param name="ParamLinkID" select="$ParamLinkID" />
   <xsl:with-param name="ParamPopupBehavior" select="$ParamPopupBehavior" />
   <xsl:with-param name="ParamWindowType" select="$ParamWindowType" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:framelinks">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinkID" />
  <xsl:param name="ParamPopupBehavior" />
  <xsl:param name="ParamWindowType" />

  <!-- Nothing to do here -->
  <!--                    -->
 </xsl:template>
</xsl:stylesheet>
