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
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSegmentsType" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:strip-space elements="*" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />
    <xsl:variable name="VarSegmentsFiles" select="key('wwfiles-files-by-type', $ParameterSegmentsType)" />

    <xsl:variable name="VarProgressWIFFilesStart" select="wwprogress:Start(count($VarWIFFiles))" />

    <xsl:for-each select="$VarWIFFiles">
     <xsl:variable name="VarWIFFile" select="." />

     <xsl:variable name="VarProgressWIFFileStart" select="wwprogress:Start(1)" />

     <!-- Locate segments -->
     <!--                 -->
     <xsl:variable name="VarSegmentsFile" select="$VarSegmentsFiles[(@groupID = $VarWIFFile/@groupID) and (@documentID = $VarWIFFile/@documentID)][1]" />
     <xsl:variable name="VarSegments" select="wwexsldoc:LoadXMLWithoutResolver($VarSegmentsFile/@path, false())/wwsplits:Segments" />

     <!-- Process segments -->
     <!--                  -->
     <xsl:choose>
      <!-- Use WIF file -->
      <!--              -->
      <xsl:when test="(count($VarSegments/wwsplits:Segment) = 1) and ($VarSegments/wwsplits:Segment/@path = $VarWIFFile/@path)">
       <!-- Nothing to do! -->
       <!--                -->
      </xsl:when>

      <!-- Segment WIF file -->
      <!--                  -->
      <xsl:otherwise>
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarWIFFile/@path, false())" />

       <!-- Process segments -->
       <!--                  -->
       <xsl:for-each select="$VarSegments/wwsplits:Segment">
        <xsl:variable name="VarSegment" select="." />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Up-to-date? -->
         <!--             -->
         <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarSegment/@path, '', $VarWIFFile/@groupID, $VarWIFFile/@documentID, $GlobalActionChecksum)" />
         <xsl:if test="not($VarUpToDate)">
          <xsl:variable name="VarResultAsXML">
           <xsl:call-template name="Segment-Document">
            <xsl:with-param name="ParamDocument" select="$VarDocument" />
            <xsl:with-param name="ParamSegment" select="$VarSegment" />
           </xsl:call-template>
          </xsl:variable>

          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
           <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsXML, $VarSegment/@path, 'utf-8', 'xml', '1.0', 'no')" />
          </xsl:if>
         </xsl:if>
        </xsl:if>

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Record files -->
         <!--              -->
         <wwfiles:File path="{$VarSegment/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSegment/@path)}" projectchecksum="" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
          <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{wwfilesystem:GetChecksum($VarWIFFile/@path)}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
          <wwfiles:Depends path="{$VarSegmentsFile/@path}" checksum="{wwfilesystem:GetChecksum($VarSegmentsFile/@path)}" groupID="{$VarSegmentsFile/@groupID}" documentID="{$VarSegmentsFile/@documentID}" />
         </wwfiles:File>
        </xsl:if>
       </xsl:for-each>
      </xsl:otherwise>
     </xsl:choose>

     <xsl:variable name="VarProgressWIFFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressWIFFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Segment-Document">
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamSegment" />

  <xsl:variable name="VarSegmentDocumentStartPosition" select="$ParamSegment/@documentstartposition" />
  <xsl:variable name="VarSegmentDocumentEndPosition">
   <xsl:variable name="VarNextSegment" select="$ParamSegment/following-sibling::wwsplits:Segment[1]" />
   <xsl:choose>
    <xsl:when test="count($VarNextSegment) = 1">
     <xsl:value-of select="number($VarNextSegment/@documentstartposition) - 1" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="-1" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:apply-templates select="$ParamDocument" mode="wwmode:segment-document">
   <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$VarSegmentDocumentStartPosition" />
   <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$VarSegmentDocumentEndPosition" />
  </xsl:apply-templates>
 </xsl:template>


 <!-- wwmode:segment-document -->
 <!--                         -->

 <xsl:template match="/" mode="wwmode:segment-document">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

   <xsl:apply-templates mode="wwmode:segment-document">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Content" mode="wwmode:segment-document">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Switch to segmenting content -->
   <!--                              -->
   <xsl:apply-templates mode="wwmode:segment-content">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:segment-document">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:segment-document">
    <xsl:with-param name="ParamSegmentDocumentStartPosition" select="$ParamSegmentDocumentStartPosition" />
    <xsl:with-param name="ParamSegmentDocumentEndPosition" select="$ParamSegmentDocumentEndPosition" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:segment-document">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:segment-content -->
 <!--                        -->

 <xsl:template match="/" mode="wwmode:segment-content">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <xsl:template match="*" mode="wwmode:segment-content">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Check position -->
  <!--                -->
  <xsl:choose>
   <xsl:when test="($ParamSegmentDocumentStartPosition &lt;= position()) and (($ParamSegmentDocumentEndPosition = -1) or (position() &lt;= $ParamSegmentDocumentEndPosition))">
    <!-- Preserve -->
    <!--          -->
    <xsl:copy>
     <xsl:copy-of select="@*" />

     <xsl:apply-templates mode="wwmode:segment-preserve" />
    </xsl:copy>
   </xsl:when>

   <xsl:otherwise>
    <xsl:copy />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:segment-preserve">
  <xsl:param name="ParamSegmentDocumentStartPosition" />
  <xsl:param name="ParamSegmentDocumentEndPosition" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:segment-preserve -->
 <!--                         -->

 <xsl:template match="/" mode="wwmode:segment-preserve">
  <xsl:apply-templates mode="wwmode:segment-preserve" />
 </xsl:template>

 <xsl:template match="*" mode="wwmode:segment-preserve">
  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:segment-preserve" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:segment-preserve">
  <xsl:copy-of select="." />
 </xsl:template>
</xsl:stylesheet>
