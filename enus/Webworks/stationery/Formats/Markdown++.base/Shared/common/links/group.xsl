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

   <!-- Iterate Project Groups -->
   <!--                        -->
   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Get Group Files -->
     <!--                 -->
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarGroupFilesOfType" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

      <!-- At least one file exists? -->
      <!--                           -->
      <xsl:if test="count($VarGroupFilesOfType[1]) = 1">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'),'.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupFilesOfType)), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsTreeFragment">
         <!-- Merge document links -->
         <!--                      -->
         <wwlinks:Links version="1.0">
          <xsl:for-each select="$VarGroupFilesOfType">
           <xsl:variable name="VarFile" select="." />

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <!-- Load document -->
            <!--               -->
            <xsl:variable name="VarDocumentLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path, false())" />

            <!-- Copy link info -->
            <!--                -->
            <xsl:apply-templates select="$VarDocumentLinks" mode="wwmode:group-links" />
           </xsl:if>
          </xsl:for-each>
         </wwlinks:Links>
        </xsl:variable>
        <xsl:if test="not(wwprogress:Abort())">
         <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
        </xsl:if>
       </xsl:if>

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupFilesOfType))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
         <xsl:for-each select="$VarGroupFilesOfType">
          <xsl:variable name="VarFileOfType" select="." />

          <wwfiles:Depends path="{$VarFileOfType/@path}" checksum="{$VarFileOfType/@checksum}" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" />
         </xsl:for-each>
        </wwfiles:File>
       </xsl:if>
      </xsl:if>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:group-links -->
 <!--                    -->

 <xsl:template match="/" mode="wwmode:group-links">
  <xsl:apply-templates mode="wwmode:group-links" />
 </xsl:template>


 <xsl:template match="wwlinks:Links" mode="wwmode:group-links">
  <xsl:apply-templates mode="wwmode:group-links" />
 </xsl:template>


 <xsl:template match="*" mode="wwmode:group-links">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:group-links" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:group-links">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
