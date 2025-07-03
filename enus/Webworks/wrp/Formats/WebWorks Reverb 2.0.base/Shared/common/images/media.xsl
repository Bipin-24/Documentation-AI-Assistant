<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-frames-by-groupid" match="wwsplits:Frame" use="@groupID" />
 <xsl:key name="wwsplits-media-by-path-lowercase" match="wwsplits:Media" use="@path-lowercase" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Get splits info -->
   <!--                 -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarSplitsFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarStartSplitsProgress" select="wwprogress:Start(count($VarSplitsFiles))" />

    <xsl:for-each select="$VarSplitsFiles">
     <xsl:variable name="VarSplitsFile" select="." />

     <xsl:variable name="VarStartSplitProgress" select="wwprogress:Start(1)" />

     <!-- Load splits -->
     <!--             -->
     <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />

     <xsl:for-each select="$VarSplits[1]">
      <!-- Copy first instance of media files -->
      <!--                                    -->
      <xsl:variable name="VarDataFiles" select="key('wwsplits-frames-by-groupid', $VarSplitsFile/@groupID)/wwsplits:Media[string-length(@path) &gt; 0]" />
      <xsl:for-each select="$VarDataFiles">
       <xsl:variable name="VarDataFile" select="." />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <!-- Copy only once -->
        <!--                -->
        <xsl:if test="count(key('wwsplits-media-by-path-lowercase', $VarDataFile/@path-lowercase)[(parent::*/@groupID = $VarDataFile/parent::*/@groupID)][1] | $VarDataFile) = 1">
         <!-- Get source and destination paths -->
         <!--                                  -->
         <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarDataFile/@source)" />
         <xsl:variable name="VarDestinationPath" select="$VarDataFile/@path" />

         <!-- Copy -->
         <!--      -->
         <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarDestinationPath, '', $VarDataFile/parent::*/@groupID, '', concat($GlobalActionChecksum, ':', $VarSourcePath))" />
         <xsl:if test="not($VarUpToDate)">
          <xsl:variable name="VarIgnore">
           <xsl:value-of select="wwfilesystem:CopyFile($VarSourcePath, $VarDestinationPath)" />
          </xsl:variable>
         </xsl:if>

         <!-- Report Files -->
         <!--              -->
         <wwfiles:File path="{$VarDestinationPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarDestinationPath)}" projectchecksum="" groupID="{$VarDataFile/parent::*/@groupID}" documentID="{$VarDataFile/parent::*/@documentID}" actionchecksum="{concat($GlobalActionChecksum, ':', $VarSourcePath)}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
          <wwfiles:Depends path="{$VarSourcePath}" checksum="{wwfilesystem:GetChecksum($VarSourcePath)}" groupID="{$VarSplitsFile/@groupID}" documentID="" />
         </wwfiles:File>
        </xsl:if>
       </xsl:if>
      </xsl:for-each>
     </xsl:for-each>

     <xsl:variable name="VarEndSplitProgress" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarEndSplitsProgress" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
