<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:wwaccess="urn:WebWorks-Engine-Accessibility-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
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
                              exclude-result-prefixes="wwsplits xsl msxsl wwbehaviors wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwaccess" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

    <!-- Groups -->
    <!--        -->
    <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
    <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
    <xsl:for-each select="$VarProjectGroups">
     <xsl:variable name="VarProjectGroup" select="." />

     <!-- Splits -->
     <!--        -->
     <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />
     <xsl:for-each select="$GlobalFiles[1]">
      <xsl:variable name="VarSplitsFile" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterSplitsType))[1]" />
      <xsl:variable name="VarBehaviorsFiles" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterBehaviorsType))" />

      <!-- Iterate docs to check behaviors -->
      <!--                                 -->
      <xsl:for-each select="$VarBehaviorsFiles">
       <xsl:variable name="VarBehaviorsFile" select="." />

       <!-- Load behaviors for document -->
       <!--                             -->
       <xsl:variable name="VarBehaviorsNodeSet" select="wwexsldoc:LoadXMLWithoutResolver($VarBehaviorsFile/@path, false())" />

       <!-- Check for long desc text markers -->
       <!--                                  -->
       <xsl:variable name="VarImageLongDescriptionTextMarkers" select="$VarBehaviorsNodeSet/wwbehaviors:Behaviors//wwbehaviors:Marker[@behavior = 'image-long-description-text']" />

       <xsl:for-each select="$VarImageLongDescriptionTextMarkers[1]">
        <xsl:variable name="VarBehaviorFrames" select="$VarBehaviorsNodeSet/wwbehaviors:Behaviors//wwbehaviors:Frame[string-length(@id) &gt; 0]" />
        <xsl:for-each select="$VarBehaviorFrames">
         <xsl:variable name="VarBehaviorFrame" select="." />

         <xsl:variable name="VarImageLongDescTextMarkers" select="$VarBehaviorFrame//wwbehaviors:Marker[@behavior = 'image-long-description-text']" />
         <xsl:variable name="VarImageLongDescByRefMarkers" select="$VarBehaviorFrame//wwbehaviors:Marker[@behavior = 'image-long-description-by-reference']" />

         <xsl:if test="(count($VarImageLongDescTextMarkers[1]) &gt; 0) and (count($VarImageLongDescByRefMarkers[1]) &lt; 1)">
          <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path, false())" />
          <!-- Description path -->
          <!--                  -->
          <xsl:variable name="VarDocumentSplits" select="$VarSplits/wwsplits:Splits/wwsplits:Split[@documentID = $VarBehaviorsFile/@documentID]" />
          <xsl:variable name="VarSplitsFrame" select="$VarDocumentSplits//wwsplits:Frame[@id = $VarBehaviorFrame/@id]" />

          <xsl:for-each select="$VarSplitsFrame//wwsplits:Description[1]">
           <xsl:variable name="VarDescriptionFile" select="." />

           <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarDescriptionFile/@path, '', $VarBehaviorsFile/@groupID, $VarBehaviorsFile/@documentID, $GlobalActionChecksum)" />
           <xsl:if test="not($VarUpToDate)">
            <xsl:variable name="VarDescriptionTextAsXML">
             <!-- Description text -->
             <!--                  -->
             <xsl:variable name="VarLastImageLongDescTextMarker" select="$VarImageLongDescTextMarkers[position() = last()]" />

             <xsl:for-each select="$VarLastImageLongDescTextMarker/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
              <xsl:value-of select="./@value" />
             </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="VarDescriptionText" select="msxsl:node-set($VarDescriptionTextAsXML)" />
            <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarDescriptionText, $VarDescriptionFile/@path, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'text')" />
           </xsl:if>

           <wwfiles:File path="{$VarDescriptionFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarDescriptionFile/@path)}" projectchecksum="" groupID="{$VarBehaviorsFile/@groupID}" documentID="{$VarBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
            <wwfiles:Depends path="{$VarSplitsFile/@path}" checksum="{$VarSplitsFile/@checksum}" groupID="{$VarSplitsFile/@groupID}" documentID="" />
            <wwfiles:Depends path="{$VarBehaviorsFile/@path}" checksum="{$VarBehaviorsFile/@checksum}" groupID="{$VarBehaviorsFile/@groupID}" documentID="{$VarBehaviorsFile/@documentID}" />
           </wwfiles:File>
          </xsl:for-each>
         </xsl:if>
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:for-each>

     <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
  </wwfiles:Files>
 </xsl:template>

</xsl:stylesheet>
