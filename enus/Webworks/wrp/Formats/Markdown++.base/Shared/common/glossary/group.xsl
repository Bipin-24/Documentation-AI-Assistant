<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Glossary-Schema"
                              xmlns:wwgloss="urn:WebWorks-Glossary-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwtoc wwlinks wwmode wwfiles wwdoc wwbehaviors wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />

 <xsl:namespace-alias stylesheet-prefix="wwgloss" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
   <xsl:variable name="VarProgressGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />

   <!-- Iterate Groups -->
   <!--                -->
   <xsl:for-each select="$VarProjectGroups">
    <xsl:variable name="VarProjectGroup" select="." />

    <xsl:variable name="VarProgressGroupStart" select="wwprogress:Start(1)" />

    <xsl:for-each select="$GlobalFiles[1]">

     <xsl:variable name="VarGroupGlossaryDocuments" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />

     <!-- Path -->
     <!--      -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($VarProjectGroup/@GroupID), concat(translate($ParameterType, ':', '_'), '.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupGlossaryDocuments)), $VarProjectGroup/@GroupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <wwgloss:Glossary version="1.0">
        <xsl:for-each select="$VarGroupGlossaryDocuments">
         <xsl:variable name="VarFilesGlossaryDocument" select="." />
         <xsl:variable name="VarGlossaryDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesGlossaryDocument/@path, false())" />

         <!-- Copy document glossary entries -->
         <!--                                -->
         <xsl:apply-templates select="$VarGlossaryDocument" mode="wwmode:glossary-document" />
        </xsl:for-each>
       </wwgloss:Glossary>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes', 'no', '', '', '', '', 'text/xml')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarGroupGlossaryDocuments))}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <xsl:for-each select="$VarGroupGlossaryDocuments">
       <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
      </xsl:for-each>
     </wwfiles:File>

    </xsl:for-each>
    <xsl:variable name="VarProgressGroupEnd" select="wwprogress:End()" />
   </xsl:for-each>
   <xsl:variable name="VarProgressGroupsEnd" select="wwprogress:End()" />
  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:glossary-document -->
 <!--                          -->

 <xsl:template match="/" mode="wwmode:glossary-document">
  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:glossary-document" />
 </xsl:template>

 <xsl:template match="wwgloss:Glossary" mode="wwmode:glossary-document">
  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:glossary-document" />
 </xsl:template>

 <xsl:template match="wwgloss:Term" mode="wwmode:glossary-document">
  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:glossary-document" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:glossary-document">
  <!-- Preserve -->
  <!--          -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:glossary-document" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:glossary-document">
  <!-- Nothing to do! -->
  <!--                -->
 </xsl:template>
</xsl:stylesheet>
