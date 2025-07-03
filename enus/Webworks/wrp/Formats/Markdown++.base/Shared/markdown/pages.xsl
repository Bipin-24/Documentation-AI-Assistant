<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwstageinfo="urn:WebWorks-XSLT-Extension-StageInfo"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwprojext wwexsldoc wwstageinfo"
>
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />


 <xsl:template name="DocumentsPages">
  <xsl:param name="ParamInput" />
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamFiles" />
  <xsl:param name="ParamLinksType" />
  <xsl:param name="ParamDependsType" />
  <xsl:param name="ParamSegmentsType" />
  <xsl:param name="ParamSplitsType" />
  <xsl:param name="ParamBehaviorsType" />

  <!-- Configure stage info -->
  <!--                      -->
  <xsl:if test="string-length(wwstageinfo:Get('group-position')) = 0">
   <xsl:variable name="VarInitGroupPosition" select="wwstageinfo:Set('group-position', '0')" />
   <xsl:variable name="VarInitFilePosition" select="wwstageinfo:Set('file-position', '0')" />
   <xsl:variable name="VarInitSegmentPosition" select="wwstageinfo:Set('segment-position', '0')" />
   <xsl:variable name="VarInitSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
  </xsl:if>

  <!-- Load project links -->
  <!--                    -->
  <xsl:for-each select="$ParamFiles[1]">
   <xsl:variable name="VarLinksPath" select="key('wwfiles-files-by-type', $ParamLinksType)/@path" />
   <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksPath, false())" />

   <!-- Determine restart position -->
   <!--                            -->
   <xsl:variable name="VarLastGroupPosition" select="number(wwstageinfo:Get('group-position'))" />

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$ParamProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />
    <xsl:variable name="VarGroupPosition" select="position()" />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Handle restart -->
    <!--                -->
    <xsl:if test="$VarGroupPosition &gt; $VarLastGroupPosition">
     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:for-each select="$ParamFiles[1]">
       <!-- Group Splits -->
       <!--              -->
       <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParamSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

       <!-- Iterate input documents -->
       <!--                         -->
       <xsl:for-each select="$ParamInput[1]">
        <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParamDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

        <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

        <!-- Determine restart position -->
        <!--                            -->
        <xsl:variable name="VarLastFilePosition" select="number(wwstageinfo:Get('file-position'))" />

        <xsl:for-each select="$VarFilesByType">
         <xsl:variable name="VarFile" select="." />
         <xsl:variable name="VarFilePosition" select="position()" />

         <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

         <!-- Handle restart -->
         <!--                -->
         <xsl:if test="$VarFilePosition &gt; $VarLastFilePosition">
          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <!-- Behaviors -->
           <!--           -->
           <xsl:for-each select="$ParamFiles[1]">
            <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-documentid', $VarFile/@documentID)[@type = $ParamBehaviorsType][1]" />
            <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

            <!-- Segments -->
            <!--          -->
            <xsl:variable name="VarSegmentsAsXML">
             <xsl:choose>
              <!-- Use defined segments -->
              <!--                      -->
              <xsl:when test="string-length($ParamSegmentsType) &gt; 0">
               <xsl:for-each select="$ParamFiles[1]">
                <xsl:variable name="VarSegmentsFile" select="key('wwfiles-files-by-documentid', $VarFile/@documentID)[@type = $ParamSegmentsType][1]" />
                <xsl:variable name="VarSegments" select="wwexsldoc:LoadXMLWithoutResolver($VarSegmentsFile/@path, false())" />
                <xsl:copy-of select="$VarSegments/wwsplits:Segments/wwsplits:Segment" />
               </xsl:for-each>
              </xsl:when>

              <!-- Synthesize segment for WIF file -->
              <!--                                 -->
              <xsl:otherwise>
               <wwsplits:Segment position="1" documentstartposition="1" path="{$VarFile/@path}" />
              </xsl:otherwise>
             </xsl:choose>
            </xsl:variable>
            <xsl:variable name="VarSegments" select="msxsl:node-set($VarSegmentsAsXML)/wwsplits:Segment" />

            <!-- Call template -->
            <!--               -->
            <xsl:call-template name="Segments">
             <xsl:with-param name="ParamSegments" select="$VarSegments" />
             <xsl:with-param name="ParamLinks" select="$VarLinks" />
             <xsl:with-param name="ParamFilesDocumentNode" select="$VarFile" />
             <xsl:with-param name="ParamFilesSplits" select="$VarFilesSplits" />
             <xsl:with-param name="ParamSplits" select="$VarSplits" />
             <xsl:with-param name="ParamBehaviorsFile" select="$VarBehaviorsFile" />
             <xsl:with-param name="ParamBehaviors" select="$VarBehaviors" />
            </xsl:call-template>
           </xsl:for-each>
          </xsl:if>

          <!-- Update stage info -->
          <!--                   -->
          <xsl:if test="not(wwprogress:Abort())">
           <xsl:variable name="VarUpdateFilePosition" select="wwstageinfo:Set('file-position', string($VarFilePosition))" />
           <xsl:variable name="VarResetSegmentPosition" select="wwstageinfo:Set('segment-position', '0')" />
           <xsl:variable name="VarResetSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
          </xsl:if>
         </xsl:if>

         <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
        </xsl:for-each>

        <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
       </xsl:for-each>
      </xsl:for-each>
     </xsl:if>

     <!-- Update stage info -->
     <!--                   -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarUpdateGroupPosition" select="wwstageinfo:Set('group-position', string($VarGroupPosition))" />
      <xsl:variable name="VarResetFilePosition" select="wwstageinfo:Set('file-position', '0')" />
      <xsl:variable name="VarResetSegmentPosition" select="wwstageinfo:Set('segment-position', '0')" />
      <xsl:variable name="VarResetSplitPosition" select="wwstageinfo:Set('split-position', '0')" />
     </xsl:if>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Segments">
  <xsl:param name="ParamSegments" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />

  <!-- Determine restart position -->
  <!--                            -->
  <xsl:variable name="VarLastSegmentPosition" select="number(wwstageinfo:Get('segment-position'))" />

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
    <!-- Handle restart -->
    <!--                -->
    <xsl:if test="number($VarSegment/@position) &gt; $VarLastSegmentPosition">
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

     <xsl:call-template name="Pages">
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamFilesDocumentNode" select="$ParamFilesDocumentNode" />
      <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$VarSegmentDocumentStartPosition" />
      <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$VarSegmentDocumentEndPosition" />
      <xsl:with-param name="ParamDocumentSegment" select="$VarDocumentSegment" />
      <xsl:with-param name="ParamFilesSplits" select="$ParamFilesSplits" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamBehaviorsFile" select="$ParamBehaviorsFile" />
      <xsl:with-param name="ParamBehaviors" select="$ParamBehaviors" />
     </xsl:call-template>

     <!-- Update stage info -->
     <!--                   -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarUpdateSegmentPosition" select="wwstageinfo:Set('segment-position', $VarSegment/@position)" />
     </xsl:if>
    </xsl:if>
   </xsl:if>

   <xsl:variable name="VarProgressSegmentEnd" select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:variable name="VarProgressSegmentsEnd" select="wwprogress:End()" />
 </xsl:template>


 <xsl:template name="Pages">
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />
  <xsl:param name="ParamDocumentSegment" />
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />

  <!-- Determine restart position -->
  <!--                            -->
  <xsl:variable name="VarLastSplitPosition" select="number(wwstageinfo:Get('split-position'))" />

  <!-- Break document into chunks -->
  <!--                            -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $ParamFilesDocumentNode/@documentID)" />

   <xsl:variable name="VarProgressSplitsStart" select="wwprogress:Start(count($VarDocumentSplits))" />

   <xsl:for-each select="$VarDocumentSplits">
    <xsl:sort select="@position" order="ascending" data-type="number" />
    <xsl:variable name="VarSplit" select="." />

    <xsl:variable name="VarProgressSplitStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Within segment? -->
     <!--                 -->
     <xsl:variable name="VarSplitDocumentStartPosition" select="number($VarSplit/@documentstartposition)" />
     <xsl:variable name="VarSplitPosition" select="number($VarSplit/@position)" />
     <xsl:if test="($ParamSegmentDocumentStartPosition &lt;= $VarSplitDocumentStartPosition) and (($ParamSegmentDocumentEndPosition = -1) or ($VarSplitDocumentStartPosition &lt;= $ParamSegmentDocumentEndPosition))">
      <!-- Handle restart -->
      <!--                -->
      <xsl:if test="$VarSplitPosition &gt; $VarLastSplitPosition">
      </xsl:if>

      <!-- Update stage info -->
      <!--                   -->
      <xsl:if test="not(wwprogress:Abort())">
       <xsl:variable name="VarUpdateSplitPosition" select="wwstageinfo:Set('split-position', $VarSplit/@position)" />
      </xsl:if>
     </xsl:if>
    </xsl:if>

    <xsl:variable name="VarProgressSplitEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressSplitsEnd" select="wwprogress:End()" />
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
