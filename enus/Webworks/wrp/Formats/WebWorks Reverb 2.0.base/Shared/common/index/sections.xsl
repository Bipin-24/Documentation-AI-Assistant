<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Index-Schema"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl wwmode msxsl wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterLocaleType" />


 <xsl:namespace-alias stylesheet-prefix="wwindex" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwindex-entries-by-sectionposition" match="wwindex:Entry" use="@sectionposition" />
 <xsl:key name="wwindex-groupsandentries-by-sectionposition" match="wwindex:Group | wwindex:Entry" use="@sectionposition" />


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

    <!-- Load locale -->
    <!--             -->
    <xsl:variable name="VarFilesLocale" select="key('wwfiles-files-by-type', $ParameterLocaleType)" />
    <xsl:variable name="VarLocale" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesLocale/@path)" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Sections">
        <xsl:with-param name="ParamLocale" select="$VarLocale" />
        <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesLocale/@path}" checksum="{$VarFilesLocale/@checksum}" groupID="{$VarFilesLocale/@groupID}" documentID="{$VarFilesLocale/@documentID}" />
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Sections">
  <xsl:param name="ParamLocale" />
  <xsl:param name="ParamFilesDocument" />

  <!-- Index -->
  <!--       -->
  <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path, false())" />

  <!-- Create sections and groups -->
  <!--                            -->
  <wwindex:Index version="1.0">

   <!-- Sections -->
   <!--          -->
   <xsl:for-each select="$ParamLocale/wwlocale:Locale/wwlocale:Index/wwlocale:Sections/wwlocale:Section">
    <xsl:variable name="VarSection" select="." />

    <!-- Set key context -->
    <!--                 -->
    <xsl:for-each select="$VarIndex[1]">
     <xsl:variable name="VarSectionEntries" select="key('wwindex-entries-by-sectionposition', $VarSection/@position)" />

     <!-- Section contains entries? -->
     <!--                           -->
     <xsl:for-each select="$VarSectionEntries[1]">

      <wwindex:Section position="{$VarSection/@position}">

       <!-- Emit default group for section -->
       <!--                                -->
       <wwindex:Group id="{$VarSection/@position}_0" name="{$VarSection/wwlocale:DefaultGroup/@name}" sort=" " />

       <!-- Emit section groups and entries -->
       <!--                                 -->
       <xsl:variable name="VarGroupsAndEntries" select="key('wwindex-groupsandentries-by-sectionposition', $VarSection/@position)" />
       <xsl:for-each select="$VarGroupsAndEntries[1]">
        <xsl:variable name="VarCulture">
        <xsl:choose>
         <xsl:when test="string-length($ParamLocale/wwlocale:Locale/@culture) &gt; 0">
          <xsl:value-of select="$ParamLocale/wwlocale:Locale/@culture" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="$ParamLocale/wwlocale:Locale/@name" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

        <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
        <!--                                                                          -->
        <xsl:for-each select="$VarGroupsAndEntries">
         <xsl:sort select="@sort" data-type="text" order="ascending" lang="{$VarCulture}" />
         <xsl:sort select="@name" data-type="text" order="ascending" lang="{$VarCulture}" />

         <xsl:variable name="VarNode" select="." />
         <xsl:variable name="VarSectionPosition">
          <xsl:value-of select="$VarSection/@position" />
          <xsl:text>_</xsl:text>
          <xsl:value-of select="position()" />
         </xsl:variable>

         <xsl:call-template name="CopyNode">
          <xsl:with-param name="ParamLocale" select="$ParamLocale" />
          <xsl:with-param name="ParamNode" select="$VarNode" />
          <xsl:with-param name="ParamSectionPosition" select="$VarSectionPosition" />
         </xsl:call-template>
        </xsl:for-each>
       </xsl:for-each>

      </wwindex:Section>
     </xsl:for-each>

    </xsl:for-each>
   </xsl:for-each>

  </wwindex:Index>
 </xsl:template>


 <xsl:template name="CopyNode">
  <xsl:param name="ParamLocale" />
  <xsl:param name="ParamNode" />
  <xsl:param name="ParamSectionPosition" />

  <!-- Emit node with sorted children -->
  <!--                                -->
  <xsl:variable name="VarChildren" select="$ParamNode/*" />
  <xsl:choose>
   <xsl:when test="count($VarChildren[1]) = 1">
    <!-- Emit non-empty element -->
    <!--                        -->
    <xsl:for-each select="$ParamNode">
     <xsl:copy>
      <xsl:if test="string-length($ParamSectionPosition) &gt; 0">
       <xsl:attribute name="id">
        <xsl:value-of select="$ParamSectionPosition" />
       </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$ParamNode/@*" />

      <!-- Sort child entries -->
      <!--                    -->
      <xsl:for-each select="$VarChildren[1]">
       <xsl:variable name="VarCulture">
        <xsl:choose>
         <xsl:when test="string-length($ParamLocale/wwlocale:Locale/@culture) &gt; 0">
          <xsl:value-of select="$ParamLocale/wwlocale:Locale/@culture" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="$ParamLocale/wwlocale:Locale/@name" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

       <!-- Attempts to sort empty node sets results in fatal errors on some systems -->
       <!--                                                                          -->
       <xsl:for-each select="$VarChildren">
        <xsl:sort select="@sort" data-type="text" order="ascending" lang="{$VarCulture}" />
        <xsl:sort select="@name" data-type="text" order="ascending" lang="{$VarCulture}" />

        <xsl:call-template name="CopyNode">
         <xsl:with-param name="ParamLocale" select="$ParamLocale" />
         <xsl:with-param name="ParamNode" select="." />
         <xsl:with-param name="ParamSectionPosition" select="''" />
        </xsl:call-template>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:copy>
    </xsl:for-each>
   </xsl:when>

   <xsl:when test="string-length($ParamSectionPosition) &gt; 0">
    <!-- Emit non-empty element -->
    <!--                        -->
    <xsl:for-each select="$ParamNode[1]">
     <xsl:copy>
      <xsl:attribute name="id">
       <xsl:value-of select="$ParamSectionPosition" />
      </xsl:attribute>
      <xsl:copy-of select="$ParamNode/@*" />
     </xsl:copy>
    </xsl:for-each>
   </xsl:when>

   <xsl:otherwise>
    <!-- Emit empty element -->
    <!--                    -->
    <xsl:copy-of select="$ParamNode" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
