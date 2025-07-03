<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwsplits wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-any-by-path-tolower" match="wwsplits:*" use="wwstring:ToLower(@path)" />
 <xsl:key name="wwsplits-any-by-source-nonuniquepath-lowercase" match="wwsplits:*" use="@source-nonuniquepath-lowercase" />


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
     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName(@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarCheckPath" select="concat($VarPath, '.check')" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', @groupID, @documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarNames" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />

       <xsl:call-template name="UniquePaths">
        <xsl:with-param name="ParamNames" select="$VarNames" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarCheckPath, 'utf-8', 'xml', '1.0', 'no')" />

      <!-- Contents changed? -->
      <!--                   -->
      <xsl:if test="not(wwfilesystem:FilesEqual($VarCheckPath, $VarPath))">
       <xsl:value-of select="wwfilesystem:CopyFile($VarCheckPath, $VarPath)" />
      </xsl:if>
      <xsl:value-of select="wwfilesystem:DeleteFile($VarCheckPath)" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="UniquePaths">
  <xsl:param name="ParamNames" />

  <!-- Determine unique paths -->
  <!--                        -->
  <xsl:variable name="VarUniqueNamesAsXML">
   <xsl:apply-templates select="$ParamNames/wwsplits:Splits" mode="wwmode:unique-paths" />
  </xsl:variable>
  <xsl:variable name="VarUniqueNames" select="msxsl:node-set($VarUniqueNamesAsXML)" />

  <!-- By-reference graphics and media can reuse paths -->
  <!--                                                 -->
  <xsl:apply-templates select="$VarUniqueNames/wwsplits:Splits" mode="wwmode:reuse-paths" />
 </xsl:template>


 <!-- wwmode:unique-paths -->
 <!--                     -->

 <xsl:template match="wwsplits:Splits" mode="wwmode:unique-paths">
  <xsl:param name="ParamNode" select="." />

  <xsl:copy>
   <xsl:copy-of select="$ParamNode/@*" />

   <xsl:apply-templates select="$ParamNode/*" mode="wwmode:unique-paths" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="wwsplits:*" mode="wwmode:unique-paths">
  <xsl:param name="ParamNode" select="." />

  <!-- Determine unique path -->
  <!--                       -->
  <xsl:variable name="VarUniquePath">
   <xsl:variable name="VarNodesWithPath" select="key('wwsplits-any-by-path-tolower', wwstring:ToLower($ParamNode/@path))" />
   <xsl:variable name="VarFirstUnique" select="count($VarNodesWithPath[1] | $ParamNode) = 1" />

   <xsl:choose>
    <!-- Use path as is -->
    <!--                -->
    <xsl:when test="$VarFirstUnique">
     <xsl:value-of select="$ParamNode/@path" />
    </xsl:when>

    <!-- Determine unique path -->
    <!--                       -->
    <xsl:otherwise>
     <xsl:call-template name="DetermineUniquePath">
      <xsl:with-param name="ParamNodesWithPath" select="$VarNodesWithPath" />
      <xsl:with-param name="ParamNode" select="$ParamNode" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit node -->
  <!--           -->
  <xsl:element name="{local-name($ParamNode)}" namespace="{namespace-uri($ParamNode)}">
   <xsl:copy-of select="$ParamNode/@*[(local-name() != 'path') and (local-name() != 'title')]" />

   <!-- documentpath-lowercase -->
   <!--                  -->
   <xsl:if test="string-length($ParamNode/@documentpath) &gt; 0">
    <xsl:attribute name="documentpath-lowercase">
     <xsl:value-of select="wwstring:ToLower($ParamNode/@documentpath)" />
    </xsl:attribute>
   </xsl:if>

   <!-- source-lowercase -->
   <!--                  -->
   <xsl:if test="string-length($ParamNode/@source) &gt; 0">
    <xsl:attribute name="source-lowercase">
     <xsl:value-of select="wwstring:ToLower($ParamNode/@source)" />
    </xsl:attribute>
   </xsl:if>

   <!-- path -->
   <!--      -->
   <xsl:attribute name="path">
    <xsl:value-of select="$VarUniquePath" />
   </xsl:attribute>

   <!-- path-lowercase -->
   <!--                -->
   <xsl:attribute name="path-lowercase">
    <xsl:value-of select="wwstring:ToLower($VarUniquePath)" />
   </xsl:attribute>

   <!-- source-nonuniquepath-lowercase -->
   <!--                       -->
   <xsl:attribute name="source-nonuniquepath-lowercase">
    <xsl:value-of select="wwstring:ToLower($ParamNode/@source)" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="wwstring:ToLower($ParamNode/@path)" />
   </xsl:attribute>

   <!-- title -->
   <!--       -->
   <xsl:attribute name="title">
    <xsl:variable name="VarNormalizedTitle" select="normalize-space($ParamNode/@title)" />
    <xsl:choose>
     <xsl:when test="string-length($VarNormalizedTitle) &gt; 0">
      <xsl:value-of select="$VarNormalizedTitle" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="wwfilesystem:GetFileName($VarUniquePath)" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Recurse -->
   <!--         -->
   <xsl:apply-templates select="$ParamNode/*" mode="wwmode:unique-paths" />
  </xsl:element>
 </xsl:template>


 <xsl:template name="DetermineUniquePath">
  <xsl:param name="ParamNodesWithPath" />
  <xsl:param name="ParamNode" />

  <xsl:variable name="VarDirectoryPath" select="wwfilesystem:GetDirectoryName($ParamNode/@path)" />
  <xsl:variable name="VarFileName" select="wwfilesystem:GetFileName($ParamNode/@path)" />

  <xsl:variable name="VarPosition">
   <xsl:for-each select="$ParamNodesWithPath">
    <xsl:if test="count($ParamNode | .) = 1">
     <xsl:value-of select="position()" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="VarUniqueFileName">
   <xsl:choose>
    <xsl:when test="contains($VarFileName, '.')">
     <xsl:value-of select="substring-before($VarFileName, '.')" />
     <xsl:text>_</xsl:text>
     <xsl:value-of select="$VarPosition" />
     <xsl:text>.</xsl:text>
     <xsl:value-of select="substring-after($VarFileName, '.')" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarFileName" />
     <xsl:text>_</xsl:text>
     <xsl:value-of select="$VarPosition" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="wwfilesystem:Combine($VarDirectoryPath, $VarUniqueFileName)" />
 </xsl:template>


 <!-- wwmode:reuse-paths -->
 <!--                    -->

 <xsl:template match="wwsplits:Splits" mode="wwmode:reuse-paths">
  <xsl:param name="ParamNode" select="." />

  <xsl:copy>
   <xsl:copy-of select="$ParamNode/@*" />

   <xsl:apply-templates select="$ParamNode/*" mode="wwmode:reuse-paths" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="wwsplits:*" mode="wwmode:reuse-paths">
  <xsl:param name="ParamNode" select="." />

  <!-- Emit node -->
  <!--           -->
  <xsl:element name="{local-name($ParamNode)}" namespace="{namespace-uri($ParamNode)}">
   <!-- Keep existing path -->
   <!--                    -->
   <xsl:copy-of select="$ParamNode/@*[local-name() != 'source-nonuniquepath-lowercase']" />

   <!-- Recurse -->
   <!--         -->
   <xsl:apply-templates select="$ParamNode/*" mode="wwmode:reuse-paths" />
  </xsl:element>
 </xsl:template>

 <xsl:template match="wwsplits:*[@byref = 'true'] | wwsplits:Media" mode="wwmode:reuse-paths">
  <xsl:param name="ParamNode" select="." />

  <!-- Emit node -->
  <!--           -->
  <xsl:element name="{local-name($ParamNode)}" namespace="{namespace-uri($ParamNode)}">
   <!-- By-reference paths and media should reuse existing entries -->
   <!--                                                            -->
   <xsl:variable name="VarFirstNodeWithSourceNonUniquePath" select="key('wwsplits-any-by-source-nonuniquepath-lowercase', $ParamNode/@source-nonuniquepath-lowercase)[1]" />

   <!-- Preserve node attribute order -->
   <!--                               -->
   <xsl:for-each select="$ParamNode/@*[local-name() != 'source-nonuniquepath-lowercase']">
    <xsl:variable name="VarAttribute" select="." />

    <xsl:choose>
     <xsl:when test="local-name($VarAttribute) = 'path'">
      <xsl:copy-of select="$VarFirstNodeWithSourceNonUniquePath/@path" />
     </xsl:when>

     <xsl:when test="local-name($VarAttribute) = 'path-lowercase'">
      <xsl:copy-of select="$VarFirstNodeWithSourceNonUniquePath/@path-lowercase" />
     </xsl:when>

     <xsl:when test="local-name($VarAttribute) = 'title'">
      <xsl:copy-of select="$VarFirstNodeWithSourceNonUniquePath/@title" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:copy-of select="$VarAttribute" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>

   <!-- Recurse -->
   <!--         -->
   <xsl:apply-templates select="$ParamNode/*" mode="wwmode:reuse-paths" />
  </xsl:element>
 </xsl:template>
</xsl:stylesheet>
