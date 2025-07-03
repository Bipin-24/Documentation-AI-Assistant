<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Files-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwadapter="urn:WebWorks-XSLT-Extension-Adapter"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwadapter wwimaging wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterPDFSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:namespace-alias stylesheet-prefix="wwfiles" result-prefix="#default" />
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

   <!-- Determine PDF target dependency -->
   <!--                                 -->
   <xsl:variable name="VarCopyPDFsFromTargetID" select="wwprojext:GetFormatSetting('pdf-target-dependency')" />

   <xsl:if test="string-length($VarCopyPDFsFromTargetID) &gt; 0">
    <xsl:call-template name="CopyPDFs">
     <xsl:with-param name="ParamCopyPDFsFromTargetID" select="$VarCopyPDFsFromTargetID" />
    </xsl:call-template>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="CopyPDFs">
  <xsl:param name="ParamCopyPDFsFromTargetID" />

  <!-- Load target files -->
  <!--                   -->
  <xsl:variable name="VarTargetFiles" select="wwexsldoc:LoadXMLWithoutResolver(wwprojext:GetTargetFilesInfoPath($ParamCopyPDFsFromTargetID), false())" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">

   <xsl:for-each select="$VarTargetFiles[1]">
    <!-- Locate source PDF -->
    <!--                   -->
    <xsl:for-each select="key('wwfiles-files-by-type', $ParameterType)[1]">
     <xsl:variable name="VarSourcePDFFile" select="." />

     <!-- Project PDF, same filename but in current target directory -->
     <!--                                                            -->
     <xsl:variable name="VarProjectPDFPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwfilesystem:GetFileName($VarSourcePDFFile/@path))" />

     <!-- Up-to-date? -->
     <!--             -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarProjectPDFPath, $GlobalProject/@ChangeID, '', '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <!-- Copy PDF -->
      <!--          -->
      <xsl:variable name="VarCopyPDF" select="wwfilesystem:CopyFile($VarSourcePDFFile/@path, $VarProjectPDFPath)" />
     </xsl:if>

     <!-- Track PDF file -->
     <!--                -->
     <wwfiles:File path="{$VarProjectPDFPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarProjectPDFPath)}" projectchecksum="{$GlobalProject/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarSourcePDFFile/@path}" checksum="{$VarSourcePDFFile/@checksum}" groupID="" documentID="" />
     </wwfiles:File>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
