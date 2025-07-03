<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwbehaviors wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterDocumentSplitsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwbehaviors" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-splits-by-documentposition" match="wwsplits:Split" use="@documentposition" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Splits -->
   <!--        -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarDocumentBehaviorsFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressProjectBehaviorsStart" select="wwprogress:Start(count($VarDocumentBehaviorsFiles))" />

    <xsl:for-each select="$VarDocumentBehaviorsFiles">
     <xsl:variable name="VarDocumentBehaviorsFile" select="." />

     <xsl:variable name="VarProgressProjectDocumentStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:for-each select="$GlobalFiles[1]">
       <xsl:variable name="VarDocumentSplitsFile" select="key('wwfiles-files-by-documentid', $VarDocumentBehaviorsFile/@documentID)[@type = $ParameterDocumentSplitsType]" />

       <!-- Up-to-date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentBehaviorsFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentBehaviorsFile/@groupID, $VarDocumentBehaviorsFile/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsXML">
         <xsl:call-template name="Splits">
          <xsl:with-param name="ParamDocumentBehaviorsFile" select="$VarDocumentBehaviorsFile" />
          <xsl:with-param name="ParamDocumentSplitsFile" select="$VarDocumentSplitsFile" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
       </xsl:if>

       <!-- Record file -->
       <!--             -->
       <xsl:if test="not(wwprogress:Abort())">
        <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
         <wwfiles:Depends path="{$VarDocumentBehaviorsFile/@path}" checksum="{$VarDocumentBehaviorsFile/@checksum}" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" />
         <wwfiles:Depends path="{$VarDocumentSplitsFile/@path}" checksum="{$VarDocumentSplitsFile/@checksum}" groupID="{$VarDocumentSplitsFile/@groupID}" documentID="{$VarDocumentSplitsFile/@documentID}" />
        </wwfiles:File>
       </xsl:if>
      </xsl:for-each>
     </xsl:if>

     <xsl:variable name="VarProgressProjectDocumentEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectBehaviorsEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Splits">
  <xsl:param name="ParamDocumentBehaviorsFile" />
  <xsl:param name="ParamDocumentSplitsFile" />

  <!-- Load document behaviors -->
  <!--                         -->
  <xsl:variable name="VarDocumentBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentBehaviorsFile/@path, false())" />

  <!-- Load document splits -->
  <!--                      -->
  <xsl:variable name="VarDocumentSplits" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentSplitsFile/@path, false())" />

  <!-- Behaviors -->
  <!--           -->
  <xsl:apply-templates select="$VarDocumentBehaviors" mode="wwmode:behaviors">
   <xsl:with-param name="ParamFirstDocumentSplit" select="$VarDocumentSplits/wwsplits:Splits[1]/wwsplits:Split[1]" />
  </xsl:apply-templates>
 </xsl:template>


 <!-- wwmode:behaviors -->
 <!--                  -->

 <xsl:template match="/" mode="wwmode:behaviors">
  <xsl:param name="ParamFirstDocumentSplit"  />

  <xsl:apply-templates mode="wwmode:behaviors">
   <xsl:with-param name="ParamFirstDocumentSplit" select="$ParamFirstDocumentSplit" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwbehaviors:Behaviors" mode="wwmode:behaviors">
  <xsl:param name="ParamFirstDocumentSplit"  />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Anything to process? -->
   <!--                      -->
   <xsl:if test="count(./wwbehaviors:*[1]) &gt; 0">
    <xsl:apply-templates mode="wwmode:behaviors">
     <xsl:with-param name="ParamFirstDocumentSplit" select="$ParamFirstDocumentSplit" />
    </xsl:apply-templates>

    <!-- Close last split -->
    <!--                  -->
    <wwexsldoc:Text disable-output-escaping="yes">
     <xsl:text>&lt;</xsl:text>
     <xsl:text>/</xsl:text>
     <xsl:text>Split</xsl:text>
     <xsl:text>&gt;</xsl:text>
     <xsl:text>
</xsl:text>
    </wwexsldoc:Text>
   </xsl:if>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="wwbehaviors:*" mode="wwmode:behaviors">
  <xsl:param name="ParamFirstDocumentSplit"  />
  <xsl:param name="ParamSplitDocumentBehavior" select="." />

  <!-- Inject splits -->
  <!--               -->
  <xsl:for-each select="$ParamFirstDocumentSplit">
   <xsl:variable name="VarDocumentSplit" select="key('wwsplits-splits-by-documentposition', $ParamSplitDocumentBehavior/@documentposition)" />

   <!-- Split found? -->
   <!--              -->
   <xsl:for-each select="$VarDocumentSplit">
    <!-- Close previous split -->
    <!--                      -->
    <xsl:if test="count($VarDocumentSplit | $ParamFirstDocumentSplit) &gt; 1">
     <wwexsldoc:Text disable-output-escaping="yes">
      <xsl:text>&lt;</xsl:text>
      <xsl:text>/</xsl:text>
      <xsl:text>Split</xsl:text>
      <xsl:text>&gt;</xsl:text>
      <xsl:text>
</xsl:text>
     </wwexsldoc:Text>
    </xsl:if>

    <!-- Open new split -->
    <!--                -->
    <wwexsldoc:Text disable-output-escaping="yes">
     <xsl:text>&lt;</xsl:text>
     <xsl:text>Split</xsl:text>
     <xsl:text> id="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute(@id)" /><xsl:text>"</xsl:text>
     <xsl:text> documentposition="</xsl:text><xsl:value-of select="wwstring:EscapeForXMLAttribute(@documentposition)" /><xsl:text>"</xsl:text>
     <xsl:text>&gt;</xsl:text>
     <xsl:text>
</xsl:text>
    </wwexsldoc:Text>
   </xsl:for-each>
  </xsl:for-each>

  <!-- Emit behavior -->
  <!--               -->
  <xsl:copy>
   <xsl:copy-of select="@*[(local-name() != 'window-type')]" />

   <!-- Preserve non-empty window-type attributes -->
   <!--                                           -->
   <xsl:if test="string-length(@window-type) &gt; 0">
    <xsl:copy-of select="@window-type" />
   </xsl:if>

   <!-- Copy children as is -->
   <!--                     -->
   <xsl:copy-of select="$ParamSplitDocumentBehavior/*" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:behaviors">
  <xsl:param name="ParamFirstDocumentSplit"  />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:behaviors">
    <xsl:with-param name="ParamFirstDocumentSplit" select="$ParamFirstDocumentSplit" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:behaviors">
  <xsl:param name="ParamFirstDocumentSplit"  />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
