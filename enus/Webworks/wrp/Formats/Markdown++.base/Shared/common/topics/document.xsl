<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Topics-Schema"
                              xmlns:wwtopics="urn:WebWorks-Topics-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwbehaviors wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwtopics" result-prefix="#default" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwbehaviors-markers-by-behavior" match="wwbehaviors:Marker" use="@behavior" />
 <xsl:key name="wwdoc-paragraphs-by-id" match="wwdoc:Paragraph" use="@id" />


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
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarWifFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressStartBehaviors" select="wwprogress:Start(count($VarWifFiles))" />

    <xsl:for-each select="$VarWifFiles">
     <xsl:variable name="VarWifFile" select="." />
     
     <xsl:variable name="VarWif" select="wwexsldoc:LoadXMLWithoutResolver($VarWifFile/@path, false())" />

     <xsl:variable name="VarProgressStartBehavior" select="wwprogress:Start(1)" />
     
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarBehaviorsFile" select="key('wwfiles-files-by-type', $ParameterBehaviorsType)[@documentID = $VarWifFile/@documentID][1]" />
      
      <xsl:variable name="VarBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Up to date? -->
       <!--             -->
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarWifFile/@path), concat(translate($ParameterType, ':', '_'), '.xml'))" />
       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarWifFile/@groupID, $VarWifFile/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsXML">

         <wwtopics:Topics documentID="{$VarWifFile/@documentID}">
          <xsl:apply-templates select="$VarBehaviors/wwbehaviors:Behaviors/descendant::wwbehaviors:Paragraph">
           <xsl:with-param name="ParamWif" select="$VarWif" />
           <xsl:with-param name="ParamDocumentID" select="$VarWifFile/@documentID" />
          </xsl:apply-templates>
         </wwtopics:Topics>
        </xsl:variable>
        <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
       </xsl:if>

       <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarWifFile/@groupID}" documentID="{$VarWifFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
        <wwfiles:Depends path="{$VarWifFile/@path}" checksum="{$VarWifFile/@checksum}" groupID="{$VarWifFile/@groupID}" documentID="{$VarWifFile/@documentID}" />
       </wwfiles:File>
      </xsl:if>
     
     </xsl:for-each>

     <xsl:variable name="VarProgressEndBehavior" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressEndBehaviors" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template match="wwbehaviors:Paragraph">
  <xsl:param name="ParamParagraph" select="." />
  <xsl:param name="ParamWif" />
  <xsl:param name="ParamDocumentID" />

  <xsl:variable name="VarTopicMarkers" select="$ParamParagraph/wwbehaviors:Marker[@behavior = 'topic' or @behavior = 'filename-and-topic' or @behavior = 'topic-description' or @behavior = 'context-plugin']" />

  <xsl:if test="count($VarTopicMarkers[1]) = 1">
   <xsl:variable name="VarSplitId" select="$ParamParagraph/ancestor::wwbehaviors:Split[1]/@id" />
   
   <wwtopics:Paragraph id="{$ParamParagraph/@id}">

    <xsl:for-each select="$VarTopicMarkers">
     <xsl:variable name="VarTopicMarker" select="." />
     
     <wwtopics:Topic id="{$VarTopicMarker/@id}" type="{$VarTopicMarker/@behavior}" name="{$VarTopicMarker/wwdoc:Marker/@name}" splitID="{$VarSplitId}" documentID="{$ParamDocumentID}">
      <wwtopics:Text>
       <xsl:for-each select="$VarTopicMarker/wwdoc:Marker">
        <xsl:for-each select="wwdoc:TextRun">
         <xsl:for-each select="wwdoc:Text">
          <xsl:value-of select="@value" />
         </xsl:for-each>
        </xsl:for-each>
       </xsl:for-each>
      </wwtopics:Text>
     </wwtopics:Topic>

    </xsl:for-each>
    <wwtopics:ParagraphText>
     <xsl:for-each select="$ParamWif[1]">
      <xsl:variable name="VarWifParagraph" select="key('wwdoc-paragraphs-by-id', $ParamParagraph/@id)[1]" />
      
      <xsl:for-each select="$VarWifParagraph/wwdoc:Number | $VarWifParagraph//wwdoc:TextRun">
       <xsl:for-each select="wwdoc:Text">
        <xsl:value-of select="@value" />
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>
    </wwtopics:ParagraphText>
   </wwtopics:Paragraph>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
