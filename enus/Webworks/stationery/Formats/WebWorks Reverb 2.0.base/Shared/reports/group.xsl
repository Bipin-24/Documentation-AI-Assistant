<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Reports-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwreport="urn:WebWorks-Reports-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
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
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              exclude-result-prefixes="xsl msxsl wwsplits wwlinks wwlocale wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwexec"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwreport" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocalePathChecksum" select="wwfilesystem:GetChecksum($GlobalUILocalePath)" />
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


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
     <xsl:for-each select="$GlobalInput[1]">
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
         <!-- Join reports -->
         <!--              -->
         <wwreport:Report version="1.0">

          <xsl:for-each select="$VarGroupFilesOfType">
           <xsl:variable name="VarFileOfType" select="." />

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFileOfType/@path, false())" />

            <xsl:copy-of select="$VarDocument/wwreport:Report/*" />
           </xsl:if>
          </xsl:for-each>

         </wwreport:Report>
        </xsl:variable>
        <xsl:if test="not(wwprogress:Abort())">
         <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResultAsTreeFragment, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
        </xsl:if>
       </xsl:if>

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <wwfiles:File path="{$VarPath}" displayname="{$VarGroupFilesOfType[1]/@displayname}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupFilesOfType))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
         <wwfiles:Depends path="{$GlobalUILocalePath}" checksum="{$GlobalUILocalePathChecksum}" groupID="" documentID="" />

         <xsl:for-each select="$VarGroupFilesOfType">
          <xsl:variable name="VarFileOfType" select="." />

          <wwfiles:Depends path="{$VarFileOfType/@path}" checksum="{$VarFileOfType/@checksum}" groupID="{$VarFileOfType/@groupID}" documentID="{$VarFileOfType/@documentID}" />
         </xsl:for-each>
        </wwfiles:File>

        <!-- Emit warnings/errors summary to the log -->
        <!--                                         -->
        <xsl:if test="wwfilesystem:FileExists($VarPath)">
         <xsl:variable name="VarGroupReport" select="wwexsldoc:LoadXMLWithoutResolver($VarPath, false())" />

         <xsl:variable name="VarWarningsCount" select="count($VarGroupReport/wwreport:Report/wwreport:Entry[@severity = 'warning'])" />
         <xsl:variable name="VarErrorsCount" select="count($VarGroupReport/wwreport:Report/wwreport:Entry[@severity = 'error'])" />

         <xsl:variable name="VarReportSummaryString" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'ReportSummary']/@value" />
         <xsl:variable name="VarMessage" select="wwstring:Format($VarReportSummaryString, $GlobalPipelineName, wwprojext:GetGroupName($VarProjectGroup/@GroupID), $VarErrorsCount, $VarWarningsCount)" />

         <xsl:choose>
          <!-- Warning -->
          <!--         -->
          <xsl:when test="($VarWarningsCount &gt; 0) and ($VarErrorsCount = 0)">
           <xsl:variable name="VarLogWarning" select="wwlog:Warning($VarMessage)" />
          </xsl:when>

          <!-- Error -->
          <!--       -->
          <xsl:when test="$VarErrorsCount &gt; 0">
           <xsl:variable name="VarLogError" select="wwlog:Error($VarMessage)" />
          </xsl:when>

          <!-- Message -->
          <!--         -->
          <xsl:otherwise>
           <xsl:variable name="VarLogMessage" select="wwlog:Message($VarMessage)" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:if>
       </xsl:if>
      </xsl:if>
     </xsl:for-each>
    </xsl:if>

    <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>

   <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
