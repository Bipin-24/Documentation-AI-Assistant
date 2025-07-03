<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwmode msxsl wwfiles wwdoc wwbehaviors wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwtoc" result-prefix="#default" />
 <xsl:strip-space elements="" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />

       <xsl:call-template name="Hierarchy">
        <xsl:with-param name="ParamDocument" select="$VarDocument" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Hierarchy">
  <xsl:param name="ParamDocument" />

  <!-- TableOfContents -->
  <!--                 -->
  <wwtoc:TableOfContents version="1.0">
   <xsl:text>
</xsl:text>

   <xsl:for-each select="$ParamDocument/wwtoc:TableOfContents/*">
    <!-- Open -->
    <!--      -->
    <xsl:if test="position() = 1">
     <xsl:call-template name="Open">
      <xsl:with-param name="ParamStart" select="0" />
      <xsl:with-param name="ParamEnd" select="@level - 1" />
     </xsl:call-template>
    </xsl:if>

    <!-- Entry -->
    <!--       -->
    <wwexsldoc:Text disable-output-escaping="yes">
     <xsl:call-template name="Spaces">
      <xsl:with-param name="ParamCount" select="@level" />
     </xsl:call-template>
     <xsl:text>&lt;</xsl:text>
     <xsl:text>Entry</xsl:text>
     <xsl:text> id="</xsl:text><xsl:value-of select="@id" /><xsl:text>"</xsl:text>
     <xsl:text> documentID="</xsl:text><xsl:value-of select="@documentID" /><xsl:text>"</xsl:text>
     <xsl:text> level="</xsl:text><xsl:value-of select="@level" /><xsl:text>"</xsl:text>
     <xsl:text> display="</xsl:text><xsl:value-of select="@display" /><xsl:text>"</xsl:text>
     <xsl:if test="string-length(@documentposition) &gt; 0">
      <xsl:text> documentposition="</xsl:text><xsl:value-of select="@documentposition" /><xsl:text>"</xsl:text>
     </xsl:if>
     <xsl:text>&gt;</xsl:text>
     <xsl:text>
</xsl:text>
    </wwexsldoc:Text>

    <!-- Prep for next -->
    <!--               -->
    <xsl:choose>
     <!-- Close -->
     <!--       -->
     <xsl:when test="position() = last()">
      <xsl:call-template name="Close">
       <xsl:with-param name="ParamStart" select="@level" />
       <xsl:with-param name="ParamEnd" select="1" />
      </xsl:call-template>
     </xsl:when>

     <xsl:otherwise>
      <!-- Open or close as necessary -->
      <!--                            -->
      <xsl:variable name="VarNextLevel" select="following-sibling::wwtoc:Entry[1]/@level" />

      <xsl:call-template name="Close">
       <xsl:with-param name="ParamStart" select="@level" />
       <xsl:with-param name="ParamEnd" select="$VarNextLevel" />
      </xsl:call-template>

      <xsl:call-template name="Open">
       <xsl:with-param name="ParamStart" select="@level" />
       <xsl:with-param name="ParamEnd" select="$VarNextLevel - 1" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>

  </wwtoc:TableOfContents>
 </xsl:template>


 <xsl:template name="Spaces">
  <xsl:param name="ParamCount" />

  <xsl:if test="$ParamCount &gt; 0">
   <xsl:text> </xsl:text>

   <xsl:call-template name="Spaces">
    <xsl:with-param name="ParamCount" select="$ParamCount - 1" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Open">
  <xsl:param name="ParamStart" />
  <xsl:param name="ParamEnd" />

  <xsl:if test="$ParamStart &lt; $ParamEnd">
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:call-template name="Spaces">
     <xsl:with-param name="ParamCount" select="$ParamStart + 1" />
    </xsl:call-template>
    <xsl:text>&lt;Entry&gt;</xsl:text>
    <xsl:text>
</xsl:text>
   </wwexsldoc:Text>

   <xsl:call-template name="Open">
    <xsl:with-param name="ParamStart" select="$ParamStart + 1"/>
    <xsl:with-param name="ParamEnd" select="$ParamEnd" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Close">
  <xsl:param name="ParamStart" />
  <xsl:param name="ParamEnd" />

  <xsl:if test="$ParamStart &gt;= $ParamEnd">
   <wwexsldoc:Text disable-output-escaping="yes">
    <xsl:call-template name="Spaces">
     <xsl:with-param name="ParamCount" select="$ParamStart" />
    </xsl:call-template>
    <xsl:text>&lt;/Entry&gt;</xsl:text>
    <xsl:text>
</xsl:text>
   </wwexsldoc:Text>

   <xsl:call-template name="Close">
    <xsl:with-param name="ParamStart" select="$ParamStart - 1"/>
    <xsl:with-param name="ParamEnd" select="$ParamEnd" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
