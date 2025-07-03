<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwsplits wwdoc wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwlinks" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate Groups -->
   <!--                -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Iterate input documents -->
    <!--                         -->
    <xsl:for-each select="$GlobalInput[1]">
     <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

     <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarWIFFiles))" />

     <xsl:for-each select="$VarWIFFiles">
      <xsl:variable name="VarWIFFile" select="." />

      <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWIFFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarProjectGroup/@GroupID, $VarWIFFile/@DocumentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsTreeFragment">
         <!-- Load WIF -->
         <!--          -->
         <xsl:variable name="VarWIF" select="wwexsldoc:LoadXMLWithoutResolver($VarWIFFile/@path, false())" />

         <!-- Extract link anchors -->
         <!--                      -->
         <xsl:apply-templates select="$VarWIF" mode="wwmode:link-anchors" />
        </xsl:variable>
        <xsl:if test="not(wwprogress:Abort())">
         <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
        </xsl:if>
       </xsl:if>

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarProjectGroup/@GroupID}" documentID="{$VarWIFFile/@DocumentID}" actionchecksum="{$GlobalActionChecksum}">
         <wwfiles:Depends path="{$VarWIFFile/@path}" checksum="{$VarWIFFile/@checksum}" groupID="{$VarWIFFile/@groupID}" documentID="{$VarWIFFile/@documentID}" />
        </wwfiles:File>
       </xsl:if>
      </xsl:if>

      <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
     </xsl:for-each>

     <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:link-anchors -->
 <!--                     -->

 <xsl:template match="/" mode="wwmode:link-anchors">
  <wwlinks:Anchors>
   <xsl:apply-templates mode="wwmode:link-anchors" />
  </wwlinks:Anchors>
 </xsl:template>


 <xsl:template match="wwdoc:Link" mode="wwmode:link-anchors">
  <xsl:param name="ParamLink" select="." />

  <xsl:if test="string-length($ParamLink/@anchor) &gt; 0">
   <wwlinks:Anchor value="{$ParamLink/@anchor}" />
  </xsl:if>

  <xsl:apply-templates mode="wwmode:link-anchors" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:link-anchors">
  <xsl:apply-templates mode="wwmode:link-anchors" />
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:link-anchors">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
