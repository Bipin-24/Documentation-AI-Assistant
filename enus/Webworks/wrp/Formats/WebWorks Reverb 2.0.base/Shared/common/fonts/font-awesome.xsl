<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplitpriorities="urn:WebWorks-Engine-Split-Priorities-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwsplits wwsplitpriorities wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterType" />


 <xsl:strip-space elements="*" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwhelper:font-awesome-5.15.4'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwhelper:font-awesome-5.15.4')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Copy over font-awesome-5.15.4 to output -->
   <!--                                         -->
   <xsl:variable name="VarOutputFolderPath" select="wwproject:GetTargetOutputDirectoryPath()"/>

   <xsl:variable name="VarSourceFontAwesomePath" select="wwuri:AsFilePath('wwhelper:font-awesome-5.15.4')" />
   <xsl:variable name="VarTargetFontAwesomePath" select="wwfilesystem:Combine($VarOutputFolderPath, 'css', 'font-awesome')" />

   <!-- Only need files from 'css' and 'fonts' folders -->
   <!--                                                -->
   <xsl:variable name="VarFontAwesomeCSSFilesPath" select="wwfilesystem:Combine($VarSourceFontAwesomePath, 'css')"/>
   <xsl:variable name="VarFontAwesomeCSSFiles" select="wwfilesystem:GetFiles($VarFontAwesomeCSSFilesPath)/wwfiles:Files/wwfiles:File"/>

   <xsl:variable name="VarFontAwesomeFontFilesPath" select="wwfilesystem:Combine($VarSourceFontAwesomePath, 'webfonts')"/>
   <xsl:variable name="VarFontAwesomeFontFiles" select="wwfilesystem:GetFiles($VarFontAwesomeFontFilesPath)/wwfiles:Files/wwfiles:File"/>

   <!-- Merge the files to loop through -->
   <!--                                 -->
   <xsl:variable name="VarFontAwesomeFilesXML">
    <xsl:copy-of select="$VarFontAwesomeCSSFiles"/>
    <xsl:copy-of select="$VarFontAwesomeFontFiles"/>
   </xsl:variable>

   <xsl:variable name="VarFontAwesomeFiles" select="msxsl:node-set($VarFontAwesomeFilesXML)/wwfiles:File"/>

   <xsl:for-each select="$VarFontAwesomeFiles">
    <xsl:variable name="VarFontAwesomeFilePath" select="./@path"/>
    <xsl:variable name="VarFontAwesomeFileChecksum" select="./@checksum"/>
    <xsl:variable name="VarFontAwesomeFilePathRelative" select="substring(substring-after($VarFontAwesomeFilePath, $VarSourceFontAwesomePath), 2)"/>
    <xsl:variable name="VarFontAwesomeTargetFilePath" select="wwfilesystem:Combine($VarTargetFontAwesomePath, $VarFontAwesomeFilePathRelative)" />

    <!-- Copy -->
    <!--      -->
    <xsl:variable name="VarFile" select="wwfilesystem:CopyFile($VarFontAwesomeFilePath, $VarFontAwesomeTargetFilePath)" />

    <wwfiles:File path="{$VarFontAwesomeTargetFilePath}" source="{$VarFontAwesomeFilePath}" type="{$ParameterType}" checksum="{$VarFontAwesomeFileChecksum}" actionchecksum="{$GlobalActionChecksum}" title="" deploy="true">
      <wwfiles:Depends path="{$VarFontAwesomeFilePath}" checksum="{wwfilesystem:GetChecksum($VarFontAwesomeFilePath)}" />
    </wwfiles:File>

   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
