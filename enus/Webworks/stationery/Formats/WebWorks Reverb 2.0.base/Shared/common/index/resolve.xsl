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
 <xsl:key name="wwindex-top-level-entries-by-sort" match="wwindex:Group/wwindex:Entry" use="@sort" />
 <xsl:key name="wwindex-top-level-entries-by-name" match="wwindex:Group/wwindex:Entry" use="@name" />


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

    <!-- Determine see/see also prefix search order -->
    <!--                                            -->
    <xsl:variable name="VarSeeAlsoPrefixesAsXML">
     <xsl:call-template name="SeeAlsoPrefixes">
      <xsl:with-param name="ParamLocale" select="$VarLocale" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarSeeAlsoPrefixes" select="msxsl:node-set($VarSeeAlsoPrefixesAsXML)/wwlocale:SeeAlsoPrefix" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Redirect">
        <xsl:with-param name="ParamSeeAlsoPrefixes" select="$VarSeeAlsoPrefixes" />
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


 <xsl:template name="SeeAlsoPrefixes">
  <xsl:param name="ParamLocale" />

  <!-- Determine see/see also prefix search order -->
  <!--                                            -->
  <xsl:variable name="VarSeeAlsoPrefixesAsXML">
   <xsl:for-each select="$ParamLocale/wwlocale:Locale/wwlocale:Index/wwlocale:SeeAlsoExpressions/wwlocale:SeeAlsoPrefix">
    <xsl:variable name="VarSeeAlsoPrefix" select="." />

    <wwlocale:SeeAlsoPrefix length="{string-length($VarSeeAlsoPrefix/@value)}" value="{$VarSeeAlsoPrefix/@value}" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarSeeAlsoPrefixes" select="msxsl:node-set($VarSeeAlsoPrefixesAsXML)/wwlocale:SeeAlsoPrefix" />

  <!-- Emit in search order -->
  <!--                      -->
  <xsl:for-each select="$VarSeeAlsoPrefixes[1]">
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
   <xsl:for-each select="$VarSeeAlsoPrefixes">
    <xsl:sort select="@length" data-type="number" order="descending" lang="{$VarCulture}" />
    <xsl:sort select="@value" data-type="text" order="ascending" lang="{$VarCulture}" />

    <wwlocale:SeeAlsoPrefix value="{@value}" />
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Redirect">
  <xsl:param name="ParamSeeAlsoPrefixes" />
  <xsl:param name="ParamFilesDocument" />

  <!-- Index -->
  <!--       -->
  <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path, false())" />

  <!-- Add see/see also redirect directives -->
  <!--                                      -->
  <wwindex:Index version="1.0">

   <xsl:for-each select="$VarIndex/wwindex:Index/wwindex:Section">
    <xsl:variable name="VarSection" select="." />

    <!-- Sections -->
    <!--          -->
    <wwindex:Section>
     <xsl:copy-of select="$VarSection/@*" />

     <xsl:for-each select="$VarSection/wwindex:Group">
      <xsl:variable name="VarGroup" select="." />

      <!-- Groups, skip empty ones -->
      <!--                         -->
      <xsl:for-each select="$VarGroup/wwindex:Entry[1]">
       <wwindex:Group>
        <xsl:copy-of select="$VarGroup/@*" />

        <!-- Entries -->
        <!--         -->
        <xsl:call-template name="Entries">
         <xsl:with-param name="ParamSeeAlsoPrefixes" select="$ParamSeeAlsoPrefixes" />
         <xsl:with-param name="ParamEntries" select="$VarGroup/wwindex:Entry" />
        </xsl:call-template>
       </wwindex:Group>
      </xsl:for-each>
     </xsl:for-each>

    </wwindex:Section>
   </xsl:for-each>

  </wwindex:Index>
 </xsl:template>


 <xsl:template name="Entries">
  <xsl:param name="ParamSeeAlsoPrefixes" />
  <xsl:param name="ParamEntries" />

  <xsl:for-each select="$ParamEntries">
   <xsl:variable name="VarEntry" select="." />

   <!-- Entry -->
   <!--       -->
   <wwindex:Entry>
    <xsl:copy-of select="$VarEntry/@*" />

    <!-- See/see also entry? -->
    <!--                        -->
    <xsl:call-template name="See">
     <xsl:with-param name="ParamSeeAlsoPrefixes" select="$ParamSeeAlsoPrefixes" />
     <xsl:with-param name="ParamEntry" select="$VarEntry" />
     <xsl:with-param name="ParamName" select="$VarEntry/@name" />
    </xsl:call-template>

    <!-- Copy all non-entry and non-link nodes -->
    <!--                                       -->
    <xsl:copy-of select="$VarEntry/*[(local-name() != 'Entry') and (local-name() != 'Link')] | $VarEntry/text()" />

    <!-- Process links -->
    <!--               -->
    <xsl:for-each select="$VarEntry/wwindex:Link">
     <xsl:variable name="VarLink" select="." />

     <!-- Link -->
     <!--      -->
     <wwindex:Link>
      <xsl:copy-of select="$VarLink/@*" />

      <!-- See/see also link? -->
      <!--                    -->
      <xsl:variable name="VarLinkName">
       <xsl:for-each select="$VarLink/wwdoc:Content/wwdoc:TextRun/wwdoc:Text">
        <xsl:value-of select="@value" />
       </xsl:for-each>
      </xsl:variable>
      <xsl:if test="string-length($VarLinkName) &gt; 0">
       <xsl:call-template name="See">
        <xsl:with-param name="ParamSeeAlsoPrefixes" select="$ParamSeeAlsoPrefixes" />
        <xsl:with-param name="ParamEntry" select="$VarEntry" />
        <xsl:with-param name="ParamName" select="$VarLinkName" />
       </xsl:call-template>
      </xsl:if>

      <!-- Copy children -->
      <!--               -->
      <xsl:copy-of select="$VarLink/* | $VarLink/text()" />
     </wwindex:Link>
    </xsl:for-each>

    <!-- Process child entries -->
    <!--                       -->
    <xsl:call-template name="Entries">
     <xsl:with-param name="ParamSeeAlsoPrefixes" select="$ParamSeeAlsoPrefixes" />
     <xsl:with-param name="ParamEntries" select="$VarEntry/wwindex:Entry" />
    </xsl:call-template>
   </wwindex:Entry>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="See">
  <xsl:param name="ParamSeeAlsoPrefixes" />
  <xsl:param name="ParamEntry" />
  <xsl:param name="ParamName" />

  <!-- Search for see/see also redirects -->
  <!--                                   -->
  <xsl:variable name="VarSeeRedirectsAsXML">
   <xsl:choose>
    <!-- DITA 1.1 explicit index-see, index-see-also support -->
    <!--                                                     -->
    <xsl:when test="string-length($ParamEntry/@see) &gt; 0">
     <wwindex:See value="{$ParamEntry/@see}" />
    </xsl:when>

    <!-- String prefix -->
    <!--               -->
    <xsl:otherwise>
     <xsl:for-each select="$ParamSeeAlsoPrefixes">
      <xsl:variable name="VarSeeAlsoPrefix" select="." />

      <!-- See, See also prefix match -->
      <!--                            -->
      <xsl:if test="starts-with($ParamName, $VarSeeAlsoPrefix/@value)">
       <wwindex:See value="{substring-after($ParamName, $VarSeeAlsoPrefix/@value)}" />
      </xsl:if>
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarSeeRedirects" select="msxsl:node-set($VarSeeRedirectsAsXML)/wwindex:See" />

  <!-- Redirect found? -->
  <!--                 -->
  <xsl:for-each select="$VarSeeRedirects[1]">
   <!-- Find redirect section and group -->
   <!--                                 -->
   <xsl:variable name="VarSee" select="@value" />
   <xsl:for-each select="$ParamEntry[1]">
    <xsl:variable name="VarSeeEntries" select="key('wwindex-top-level-entries-by-sort', $VarSee) | key('wwindex-top-level-entries-by-name', $VarSee)" />
    <xsl:for-each select="$VarSeeEntries[1]">
     <xsl:variable name="VarSeeEntry" select="." />

     <wwindex:See sectionposition="{$VarSeeEntry/../../@position}" groupID="{$VarSeeEntry/../@id}" group="{$VarSeeEntry/../@name}" groupsort="{$VarSeeEntry/../@sort}" entry="{$VarSee}" entryID="{$VarSeeEntry/@id}" />
    </xsl:for-each>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
