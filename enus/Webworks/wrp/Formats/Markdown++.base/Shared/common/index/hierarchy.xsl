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


 <xsl:namespace-alias stylesheet-prefix="wwindex" result-prefix="#default" />
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

    <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Hierarchy">
        <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Hierarchy">
  <xsl:param name="ParamFilesDocument" />

  <!-- Index -->
  <!--       -->
  <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($ParamFilesDocument/@path, false())" />

  <!-- Create group hierarchies -->
  <!--                          -->
  <wwindex:Index version="1.0">

   <!-- Sections -->
   <!--          -->
   <xsl:for-each select="$VarIndex/wwindex:Index/wwindex:Section">
    <xsl:variable name="VarSection" select="." />

    <wwindex:Section position="{$VarSection/@position}">

     <xsl:for-each select="$VarSection/wwindex:*">
      <xsl:variable name="VarNode" select="." />

      <!-- Handle groups and entries -->
      <!--                           -->
      <xsl:choose>
       <xsl:when test="local-name($VarNode) = 'Group'">
        <!-- Close previous group? -->
        <!--                       -->
        <xsl:if test="position() != 1">
         <wwexsldoc:Text disable-output-escaping="yes">
          <xsl:text>&lt;/Group&gt;</xsl:text>
          <xsl:text>
</xsl:text>
         </wwexsldoc:Text>
        </xsl:if>

        <!-- Open group -->
        <!--            -->
        <wwexsldoc:Text disable-output-escaping="yes">
         <xsl:text>
</xsl:text>
         <xsl:text>&lt;Group id=</xsl:text>
         <xsl:text>&quot;</xsl:text>
         <xsl:value-of select="wwstring:EscapeForXMLAttribute($VarNode/@id)" />
         <xsl:text>&quot;</xsl:text>
         <xsl:text> name=</xsl:text>
         <xsl:text>&quot;</xsl:text>
         <xsl:value-of select="wwstring:EscapeForXMLAttribute($VarNode/@name)" />
         <xsl:text>&quot;</xsl:text>
         <xsl:text> sort=</xsl:text>
         <xsl:text>&quot;</xsl:text>
         <xsl:value-of select="wwstring:EscapeForXMLAttribute($VarNode/@sort)" />
         <xsl:text>&quot;</xsl:text>
         <xsl:text>&gt;</xsl:text>
         <xsl:text>
</xsl:text>
        </wwexsldoc:Text>
       </xsl:when>

       <xsl:when test="local-name($VarNode) = 'Entry'">
        <!-- Entry -->
        <!--       -->
        <wwindex:Entry>
         <xsl:copy-of select="$VarNode/@*[local-name() != 'sectionposition']" />
         <xsl:copy-of select="$VarNode/* | $VarNode/text()" />
        </wwindex:Entry>
        <xsl:text>
</xsl:text>
       </xsl:when>
      </xsl:choose>
     </xsl:for-each>

     <!-- Close last group in section -->
     <!--                             -->
     <wwexsldoc:Text disable-output-escaping="yes">
      <xsl:text>&lt;/Group&gt;</xsl:text>
      <xsl:text>
</xsl:text>
     </wwexsldoc:Text>

    </wwindex:Section>
   </xsl:for-each>

  </wwindex:Index>
 </xsl:template>
</xsl:stylesheet>
