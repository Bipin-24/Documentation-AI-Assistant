<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Images-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwimages="urn:WebWorks-Images-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwimages wwlinks wwfiles wwdoc wwsplits wwproject wwtrait wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterImagesFTIURI" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwimages" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:value-of select="wwprogress:Start(1)" />

   <xsl:variable name="VarImagesFTIPath" select="wwuri:AsFilePath($ParameterImagesFTIURI)" />

   <!-- Up to date? -->
   <!--             -->
   <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'),'.xml'))" />
   <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', '', '', $GlobalActionChecksum)" />
   <xsl:if test="not($VarUpToDate)">
    <xsl:variable name="VarResultAsXML">
     <!-- Load images FTI  -->
     <!--                  -->
     <xsl:variable name="VarImagesFTI" select="wwexsldoc:LoadXMLWithoutResolver($VarImagesFTIPath, false())" />

     <!-- Extract valid image types -->
     <!--                           -->
     <wwimages:Images>

      <xsl:for-each select="$VarImagesFTI//wwtrait:Class[@name = 'image-format']/wwtrait:Item">
       <xsl:variable name="VarItem" select="." />

       <wwimages:Type name="{$VarItem/@value}" />
      </xsl:for-each>

     </wwimages:Images>
    </xsl:variable>
    <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'UTF-8', 'xml', '1.0', 'yes')" />
   </xsl:if>

   <!-- Single locale file for the whole project -->
   <!--                                          -->
   <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
    <wwfiles:Depends path="{$VarImagesFTIPath}" checksum="{wwfilesystem:GetChecksum($VarImagesFTIPath)}" groupID="" documentID="" />
   </wwfiles:File>

   <xsl:value-of select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
