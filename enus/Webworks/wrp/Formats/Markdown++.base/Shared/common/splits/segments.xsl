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
 <xsl:param name="ParameterWIFType" />
 <xsl:param name="ParameterSegmentWIFType" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:strip-space elements="*" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:variable name="GlobalSegmentInterval" select="256" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Groups -->
   <!--        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <xsl:for-each select="$GlobalFiles[1]">
      <!-- Group Splits -->
      <!--              -->
      <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID][1]" />
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path, false())" />

      <!-- Iterate input documents -->
      <!--                         -->
      <xsl:for-each select="$GlobalInput[1]">
       <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', $ParameterWIFType)[@groupID = $VarProjectGroup/@GroupID]" />

       <xsl:variable name="VarProgressWIFFilesStart" select="wwprogress:Start(count($VarWIFFiles))" />

       <xsl:for-each select="$VarWIFFiles">
        <xsl:variable name="VarWIFFile" select="." />

        <xsl:variable name="VarProgressWIFFileStart" select="wwprogress:Start(1)" />

        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWIFFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarWIFFile/@groupID, $VarWIFFile/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <xsl:variable name="VarResultAsXML">
          <xsl:call-template name="Document-Segments">
           <xsl:with-param name="ParamSplits" select="$VarSplits" />
           <xsl:with-param name="ParamWIFFile" select="$VarWIFFile" />
          </xsl:call-template>
         </xsl:variable>

         <!-- Aborted? -->
         <!--          -->
         <xsl:if test="not(wwprogress:Abort())">
          <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
          <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsXML, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
         </xsl:if>
        </xsl:if>

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
         <!-- Record files -->
         <!--              -->
         <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
          <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{wwfilesystem:GetChecksum($VarWIFFile/@path)}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
          <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{wwfilesystem:GetChecksum($VarFilesSplits/@path)}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
         </wwfiles:File>
        </xsl:if>

        <xsl:variable name="VarProgressWIFFileEnd" select="wwprogress:End()" />
       </xsl:for-each>

       <xsl:variable name="VarProgressWIFFilesEnd" select="wwprogress:End()" />
      </xsl:for-each>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>
   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Document-Segments">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamWIFFile" />

  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarDocumentSplits" select="key('wwsplits-split-by-documentid', $ParamWIFFile/@documentID)" />

   <!-- Determine segments -->
   <!--                    -->
   <xsl:variable name="VarSegmentSplitsAsXML">
    <xsl:for-each select="$VarDocumentSplits">
     <xsl:sort select="@position" order="ascending" data-type="number" />
     <xsl:variable name="VarSplit" select="." />

     <xsl:if test="(position() mod $GlobalSegmentInterval) = 1">
      <xsl:copy>
       <xsl:copy-of select="@*" />
      </xsl:copy>
     </xsl:if>
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarSegmentSplits" select="msxsl:node-set($VarSegmentSplitsAsXML)/wwsplits:Split" />

   <!-- Emit segments -->
   <!--               -->
   <wwsplits:Segments>
    <xsl:choose>
     <!-- Use WIF file -->
     <!--              -->
     <xsl:when test="count($VarSegmentSplits) = 1">
      <wwsplits:Segment position="1" documentstartposition="{$VarSegmentSplits[1]/@documentstartposition}" path="{$ParamWIFFile/@path}" />
     </xsl:when>

     <!-- Segment WIF file -->
     <!--                  -->
     <xsl:otherwise>
      <xsl:for-each select="$VarSegmentSplits">
       <xsl:variable name="VarSegmentSplit" select="." />

       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($ParamWIFFile/@path), concat(translate($ParameterSegmentWIFType, ':', '_'), '_', $VarSegmentSplit/@position, '.xml'))" />

       <wwsplits:Segment position="{$VarSegmentSplit/@position}" documentstartposition="{$VarSegmentSplit/@documentstartposition}" path="{$VarPath}" />
      </xsl:for-each>
     </xsl:otherwise>
    </xsl:choose>
   </wwsplits:Segments>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
