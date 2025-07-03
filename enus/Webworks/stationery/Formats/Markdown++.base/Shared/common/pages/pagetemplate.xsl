<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              exclude-result-prefixes="xsl wwmode msxsl wwlinks wwfiles wwdoc wwsplits wwtoc wwproject wwpage wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwvars"
>
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwpage-files-by-path" match="wwpage:File" use="@path" />
 <xsl:key name="wwpage-conditions-by-name" match="wwpage:Condition" use="@name" />


 <xsl:template name="PageTemplate-Process">
  <xsl:param name="ParamGlobalProject" />
  <xsl:param name="ParamGlobalFiles" />
  <xsl:param name="ParamType" />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamResultPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamActionChecksum" />
  <xsl:param name="ParamProjectChecksum" />
  <xsl:param name="ParamLocaleType" />
  <xsl:param name="ParamProjectVariablesType" />

  <!-- Locale -->
  <!--        -->
  <xsl:variable name="VarLocalePath">
   <xsl:for-each select="$ParamGlobalFiles[1]">
    <xsl:value-of select="key('wwfiles-files-by-type', $ParamLocaleType)[1]/@path" />
   </xsl:for-each>
  </xsl:variable>

  <!-- Mapping Entry Sets -->
  <!--                    -->
  <xsl:variable name="VarMapEntrySetsPath" select="wwuri:AsFilePath('wwtransform:html/mapentrysets.xml')" />
  <xsl:variable name="VarMapEntrySets" select="wwexsldoc:LoadXMLWithoutResolver($VarMapEntrySetsPath)" />

  <!-- Page Template -->
  <!--               -->
  <xsl:variable name="VarPageTemplatePath" select="wwuri:AsFilePath($ParamPageTemplateURI)" />
  <xsl:variable name="VarPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($VarPageTemplatePath)" />

  <!-- Page Template Include files -->
  <!--                             -->
  <xsl:variable name="VarPageTemplateIncludeFilesAsXML">
   <xsl:apply-templates select="$VarPageTemplate" mode="wwmode:pagetemplate-include-files">
    <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarPageTemplateIncludeFiles" select="msxsl:node-set($VarPageTemplateIncludeFilesAsXML)" />

  <xsl:variable name="VarPageIncludeFilesPath">
   <xsl:for-each select="$VarPageTemplateIncludeFiles/wwpage:File">
    <xsl:value-of select="@path" />
    <xsl:value-of select="':'" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPageIncludeFilesPathChecksum" select="wwstring:MD5Checksum($VarPageIncludeFilesPath)" />

  <!-- Project Variables -->
  <!--                   -->
  <xsl:variable name="VarProjectVariablesPath">
   <xsl:for-each select="$ParamGlobalFiles[1]">
    <xsl:value-of select="key('wwfiles-files-by-type', $ParamProjectVariablesType)[1]/@path" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarProjectVariables" select="wwexsldoc:LoadXMLWithoutResolver($VarProjectVariablesPath)" />

  <!-- Target Variables -->
  <!--                  -->
  <xsl:variable name="VarTargetVariablesAsXML" select="$ParamGlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID=wwprojext:GetFormatID()]/wwproject:Variables/wwproject:Variable"/>

  <!-- All Conditions -->
  <!--                -->
  <xsl:variable name="VarAllConditionsAsXML">
   <!-- Target Variables -->
   <!--                  -->
   <xsl:for-each select="$VarTargetVariablesAsXML">
    <wwpage:Condition name="projvars:{./@Name}"/>
   </xsl:for-each>

   <!-- Copy existing as is -->
   <!--                     -->
   <xsl:for-each select="$ParamConditions/*">
    <xsl:copy-of select="." />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarAllConditions" select="msxsl:node-set($VarAllConditionsAsXML)" />

  <!-- All Replacements -->
  <!--                  -->
  <xsl:variable name="VarAllReplacementsAsXML">
   <!-- Target Variables -->
   <!--                   -->
   <xsl:for-each select="$VarTargetVariablesAsXML">
    <wwpage:Replacement name="projvars:{./@Name}" value="{./@Value}"/>
   </xsl:for-each>

   <!-- wwvars:Name Variables -->
   <!--                       -->
   <xsl:variable name="VarVariablesAsXML">
    <xsl:call-template name="Variables-Filter-Last-Unique">
     <xsl:with-param name="ParamVariables" select="$VarProjectVariables//wwvars:Variable" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarVariables" select="msxsl:node-set($VarVariablesAsXML)/wwvars:Variable" />
   <xsl:call-template name="Variables-Page-String-Replacements">
    <xsl:with-param name="ParamVariables" select="$VarVariables" />
   </xsl:call-template>

   <!-- Copy existing as is -->
   <!--                     -->
   <xsl:for-each select="$ParamReplacements/*">
    <xsl:copy-of select="." />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarAllReplacements" select="msxsl:node-set($VarAllReplacementsAsXML)" />

  <xsl:variable name="VarProgressSplashStart" select="wwprogress:Start(1)" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:for-each select="$ParamGlobalProject[1]">

    <!-- Output -->
    <!--        -->
    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($ParamResultPath, concat($ParamGlobalProject/wwproject:Project/@ChangeID, ':', $ParamProjectChecksum, ':', $VarPageIncludeFilesPathChecksum), '', '', $ParamActionChecksum)" />
    <xsl:if test="not($VarUpToDate)">
     <!-- Create results page -->
     <!--                     -->
     <xsl:variable name="VarResultAsXML">
      <!-- Map common characters -->
      <!--                       -->
      <wwexsldoc:MappingContext>
       <xsl:copy-of select="$VarMapEntrySets/wwexsldoc:MapEntrySets/wwexsldoc:MapEntrySet[@name = 'common']/wwexsldoc:MapEntry" />

       <!-- Invoke page template -->
       <!--                      -->
       <xsl:apply-templates select="$VarPageTemplate" mode="wwmode:pagetemplate">
        <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
        <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
        <xsl:with-param name="ParamOutputPath" select="$ParamResultPath" />
        <xsl:with-param name="ParamConditions" select="$VarAllConditions" />
        <xsl:with-param name="ParamReplacements" select="$VarAllReplacements" />
       </xsl:apply-templates>
      </wwexsldoc:MappingContext>
     </xsl:variable>

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarPrettyPrint">
       <xsl:choose>
        <xsl:when test="wwprojext:GetFormatSetting('file-processing-pretty-print') = 'true'">
         <xsl:text>yes</xsl:text>
        </xsl:when>

        <xsl:otherwise>
         <xsl:text>no</xsl:text>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <xsl:variable name="VarWriteResult">
       <xsl:choose>
        <xsl:when test="string-length($ParamType) &gt; 0">
         <xsl:value-of select="wwexsldoc:Document($VarResult, $ParamResultPath, 'utf-8', 'xhtml', '5.0', $VarPrettyPrint, 'yes', 'no', 'urn:WebWorks_DOCTYPE_ElementOnly', '')" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:variable name="VarResultAsBodyFragment" select="$VarResult/wwexsldoc:MappingContext/html:html/html:body"/>
         <xsl:value-of select="wwexsldoc:Document($VarResultAsBodyFragment, $ParamResultPath, 'utf-8')" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
     </xsl:if>
    </xsl:if>

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Record files -->
     <!--              -->
     <xsl:if test="string-length($ParamType) &gt; 0">
      <wwfiles:Depends path="{$VarLocalePath}" checksum="{wwfilesystem:GetChecksum($VarLocalePath)}" groupID="" documentID="" />
      <wwfiles:Depends path="{$VarMapEntrySetsPath}" checksum="{wwfilesystem:GetChecksum($VarMapEntrySetsPath)}" groupID="" documentID="" />
      <wwfiles:Depends path="{$VarPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($VarPageTemplatePath)}" groupID="" documentID="" />
      <wwfiles:Depends path="{$VarProjectVariablesPath}" checksum="{wwfilesystem:GetChecksum($VarProjectVariablesPath)}" groupID="" documentID="" />

      <!-- Page Template Include Files -->
      <!--                             -->
      <xsl:for-each select="$VarPageTemplateIncludeFiles/wwpage:File">
       <xsl:variable name="VarFile" select="." />

       <wwfiles:Depends path="{$VarFile/@path}" checksum="{wwfilesystem:GetChecksum($VarFile/@path)}" groupID="" documentID="" />
      </xsl:for-each>
     </xsl:if>
    </xsl:if>

   </xsl:for-each>
  </xsl:if>

  <xsl:variable name="VarProgressSplashEnd" select="wwprogress:End()" />
 </xsl:template>

 <xsl:template name="PageTemplate-ProcessFragment">
  <xsl:param name="ParamGlobalProject" />
  <xsl:param name="ParamGlobalFiles" />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamResultPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamActionChecksum" />
  <xsl:param name="ParamProjectChecksum" />
  <xsl:param name="ParamLocaleType" />
  <xsl:param name="ParamProjectVariablesType" />

  <xsl:call-template name="PageTemplate-Process">
   <xsl:with-param name="ParamGlobalProject" select="$ParamGlobalProject"/>
   <xsl:with-param name="ParamGlobalFiles" select="$ParamGlobalFiles"/>
   <xsl:with-param name="ParamType" select="''" />
   <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
   <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
   <xsl:with-param name="ParamResultPath" select="$ParamResultPath" />
   <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
   <xsl:with-param name="ParamActionChecksum" select="$ParamActionChecksum" />
   <xsl:with-param name="ParamProjectChecksum" select="$ParamProjectChecksum" />
   <xsl:with-param name="ParamLocaleType" select="$ParamLocaleType" />
   <xsl:with-param name="ParamProjectVariablesType" select="$ParamProjectVariablesType"/>
  </xsl:call-template>
 </xsl:template>

 <xsl:template name="PageTemplate-CopyDependentFiles">
  <xsl:param name="ParamPageTemplateFiles" />
  <xsl:param name="ParamActionChecksum" />
  <xsl:param name="ParamType" />
  <xsl:param name="ParamDeploy" />

  <xsl:variable name="VarPageTemplateFilesDedupedAsXML">
   <!-- Eliminate duplicates -->
   <!--                      -->
   <xsl:for-each select="$ParamPageTemplateFiles/wwpage:File">
    <xsl:variable name="VarPageTemplateFile" select="." />

    <xsl:variable name="VarPageTemplateFilesWithPath" select="key('wwpage-files-by-path', $VarPageTemplateFile/@path)" />
    <xsl:if test="count($VarPageTemplateFilesWithPath[1] | $VarPageTemplateFile) = 1">
     <xsl:copy-of select="$VarPageTemplateFile" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPageTemplateFilesDeduped" select="msxsl:node-set($VarPageTemplateFilesDedupedAsXML)" />

  <xsl:for-each select="$VarPageTemplateFilesDeduped/wwpage:File">
   <xsl:variable name="VarPageTemplateFile" select="." />

   <xsl:call-template name="PageTemplate-CopyDependentFile">
    <xsl:with-param name="ParamPageTemplateFile" select="$VarPageTemplateFile"/>
    <xsl:with-param name="ParamActionChecksum" select="$ParamActionChecksum"/>
    <xsl:with-param name="ParamType" select="$ParamType"/>
    <xsl:with-param name="ParamDeploy" select="$ParamDeploy"/>
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>
 
 <xsl:template name="PageTemplate-CopyDependentFile">
  <xsl:param name="ParamPageTemplateFile" />
  <xsl:param name="ParamActionChecksum" />
  <xsl:param name="ParamType" />
  <xsl:param name="ParamDeploy" />

   <!-- Get source and destination paths -->
   <!--                                  -->
   <xsl:variable name="VarSourcePath">
    <xsl:choose>
     <xsl:when test="$ParamPageTemplateFile/@source-type = 'data'">
      <xsl:value-of select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $ParamPageTemplateFile/@path)"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="wwuri:AsFilePath(concat('wwformat:Pages/', $ParamPageTemplateFile/@path))"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarDestinationPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), $ParamPageTemplateFile/@path)" />

   <!-- Copy -->
   <!--      -->
   <xsl:variable name="VarPageTemplateFileUpToDate" select="wwfilesext:UpToDate($VarDestinationPath, '', '', '', concat($ParamActionChecksum, ':', $VarSourcePath))" />
   <xsl:if test="not($VarPageTemplateFileUpToDate)">
    <xsl:variable name="VarIgnore" select="wwfilesystem:CopyFile($VarSourcePath, $VarDestinationPath)" />
   </xsl:if>

   <!-- Report Files -->
   <!--              -->
   <wwfiles:File path="{$VarDestinationPath}" type="{$ParamType}" checksum="{wwfilesystem:GetChecksum($VarDestinationPath)}" projectchecksum="" groupID="" documentID="" actionchecksum="{concat($ParamActionChecksum, ':', $VarSourcePath)}" category="" use="" deploy="{$ParamDeploy}">
    <wwfiles:Depends path="{$VarSourcePath}" checksum="{wwfilesystem:GetChecksum($VarSourcePath)}" groupID="" documentID="" />
   </wwfiles:File>

 </xsl:template>

 
 <!-- Check Conditions -->
 <!--                  -->

 <xsl:template name="PageTemplates-CheckConditionExpression">
  <xsl:param name="ParamConditionExpression" />
  <xsl:param name="ParamConditions" />

  <xsl:choose>
   <!-- Comma delimited conditions (logical OR) -->
   <!--                                         -->
   <xsl:when test="contains($ParamConditionExpression, ',')">
    <!-- Check prefix expression -->
    <!--                         -->
    <xsl:variable name="VarAllow">
     <xsl:variable name="VarPrefix" select="substring-before($ParamConditionExpression, ',')" />
     <xsl:call-template name="PageTemplates-CheckConditionExpression">
      <xsl:with-param name="ParamConditionExpression" select="normalize-space($VarPrefix)" />
      <xsl:with-param name="ParamConditions" select="$ParamConditions" />
     </xsl:call-template>
    </xsl:variable>

    <!-- Found an answer or check other expressions? -->
    <!--                                             -->
    <xsl:choose>
     <!-- Found an answer -->
     <!--                 -->
     <xsl:when test="$VarAllow = '1'">
      <xsl:value-of select="$VarAllow" />
     </xsl:when>

     <!-- Check suffix expression -->
     <!--                         -->
     <xsl:otherwise>
      <xsl:variable name="VarSuffix" select="substring-after($ParamConditionExpression, ',')" />
      <xsl:call-template name="PageTemplates-CheckConditionExpression">
       <xsl:with-param name="ParamConditionExpression" select="normalize-space($VarSuffix)" />
       <xsl:with-param name="ParamConditions" select="$ParamConditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <!-- Space delimited conditions (logical AND) -->
   <!--                                          -->
   <xsl:when test="contains($ParamConditionExpression, ' ')">
    <!-- Check prefix expression -->
    <!--                         -->
    <xsl:variable name="VarAllowPrefix">
     <xsl:variable name="VarPrefix" select="substring-before($ParamConditionExpression, ' ')" />
     <xsl:call-template name="PageTemplates-CheckConditionExpression">
      <xsl:with-param name="ParamConditionExpression" select="$VarPrefix" />
      <xsl:with-param name="ParamConditions" select="$ParamConditions" />
     </xsl:call-template>
    </xsl:variable>

    <!-- Prefix allowed? -->
    <!--                 -->
    <xsl:if test="$VarAllowPrefix = '1'">
     <!-- Check suffix expression -->
     <!--                         -->
     <xsl:variable name="VarSuffix" select="substring-after($ParamConditionExpression, ' ')" />
     <xsl:call-template name="PageTemplates-CheckConditionExpression">
      <xsl:with-param name="ParamConditionExpression" select="$VarSuffix" />
      <xsl:with-param name="ParamConditions" select="$ParamConditions" />
     </xsl:call-template>
    </xsl:if>
   </xsl:when>
   
   <!-- Exclamation prefixed conditions (logical NOT) -->
   <!--                                               -->
   <xsl:when test="starts-with($ParamConditionExpression, '!')">
    <xsl:variable name="VarCondition" select="substring-after($ParamConditionExpression, '!')" />
    <!-- Check conditions for exact match -->
    <!--                                  -->
    <xsl:for-each select="$ParamConditions[1]">
    <xsl:if test="count(key('wwpage-conditions-by-name', $VarCondition)[1]) = 0">
     <xsl:text>1</xsl:text>
    </xsl:if>
    </xsl:for-each>
   </xsl:when>

   <!-- Exact match on condition name -->
   <!--                               -->
   <xsl:otherwise>
    <xsl:for-each select="$ParamConditions[1]">
     <xsl:if test="count(key('wwpage-conditions-by-name', $ParamConditionExpression)[1]) = 1">
      <xsl:text>1</xsl:text>
     </xsl:if>
    </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="PageTemplates-CheckConditions">
  <xsl:param name="ParamConditionAttribute" />
  <xsl:param name="ParamConditions" />

  <xsl:choose>
   <!-- No condition attribute -->
   <!--                        -->
   <xsl:when test="count($ParamConditionAttribute) = 0">
    <xsl:text>1</xsl:text>
   </xsl:when>

   <!-- Process condition attribute -->
   <!--                             -->
   <xsl:otherwise>
    <xsl:call-template name="PageTemplates-CheckConditionExpression">
     <xsl:with-param name="ParamConditionExpression" select="normalize-space($ParamConditionAttribute)" />
     <xsl:with-param name="ParamConditions" select="$ParamConditions" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="PageTemplates-ExtractAttributeValue">
  <xsl:param name="ParamAttributeValue" />

  <xsl:variable name="VarPattern" select="substring-before(substring-after($ParamAttributeValue, '{'), '}')" />
  <xsl:choose>
   <xsl:when test="string-length($VarPattern) &gt; 0">
    <xsl:value-of select="$VarPattern" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="$ParamAttributeValue" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="PageTemplates-ReplaceAttributeValue">
  <xsl:param name="ParamAttributeValue" />
  <xsl:param name="ParamReplacement" />

  <xsl:variable name="VarPattern" select="substring-before(substring-after($ParamAttributeValue, '{'), '}')" />
  <xsl:choose>
   <xsl:when test="string-length($VarPattern) &gt; 0">
    <xsl:value-of select="substring-before($ParamAttributeValue, '{')" />
    <xsl:value-of select="$ParamReplacement" />
    <xsl:value-of select="substring-after(substring-after($ParamAttributeValue, '{'), '}')" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="$ParamReplacement" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- wwmode:pagetemplate-files -->
 <!--                           -->

 <xsl:template match="/" mode="wwmode:pagetemplate-files">

  <xsl:variable name="VarPageTemplateFilesAsXML">
   <xsl:for-each select="//*[@wwpage:*]">
    <xsl:variable name="VarNode" select="." />

    <xsl:for-each select="$VarNode/@*[starts-with(name(), 'wwpage:attribute-')]">
     <xsl:variable name="VarActionAttribute" select="." />
     <xsl:if test="$VarActionAttribute = 'copy-relative-to-output' or $VarActionAttribute = 'copy-relative-to-output-root' or $VarActionAttribute = 'copy-from-data-relative-to-output' or $VarActionAttribute = 'copy-from-data-relative-to-output-root'">
      <!-- Special handling for the action attributes: -->
      <!-- 'copy-relative-to-output',                  -->
      <!-- 'copy-relative-to-output-root',             -->
      <!-- 'copy-from-data-relative-to-output' and     -->
      <!-- 'copy-from-data-relative-to-output-root'    -->
      <!--                                             -->
      <xsl:variable name="VarAttributeName" select="substring-after(name($VarActionAttribute), 'wwpage:attribute-')" />
      <xsl:variable name="VarAttribute" select="$VarNode/@*[name() = $VarAttributeName][1]" />
      <xsl:for-each select="$VarAttribute">
       <xsl:variable name="VarAttributeValue">
        <xsl:call-template name="PageTemplates-ExtractAttributeValue">
         <xsl:with-param name="ParamAttributeValue" select="string($VarAttribute)" />
        </xsl:call-template>
       </xsl:variable>

       <wwpage:File path="{$VarAttributeValue}">
        <xsl:choose>
         <xsl:when test="$VarActionAttribute = 'copy-from-data-relative-to-output' or $VarActionAttribute = 'copy-from-data-relative-to-output-root'">
          <xsl:attribute name="source-type">data</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
          <xsl:attribute name="source-type">format</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
         <xsl:when test="$VarActionAttribute = 'copy-relative-to-output-root' or $VarActionAttribute = 'copy-from-data-relative-to-output-root'">
          <xsl:attribute name="output-relative">root</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
          <xsl:attribute name="output-relative">group</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>
       </wwpage:File>
      </xsl:for-each>
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPageTemplateFiles" select="msxsl:node-set($VarPageTemplateFilesAsXML)" />

  <!-- Eliminate duplicates -->
  <!--                      -->
  <xsl:for-each select="$VarPageTemplateFiles/wwpage:File">
   <xsl:variable name="VarPageTemplateFile" select="." />

   <xsl:variable name="VarPageTemplateFilesWithPath" select="key('wwpage-files-by-path', $VarPageTemplateFile/@path)" />
   <xsl:if test="count($VarPageTemplateFilesWithPath[1] | $VarPageTemplateFile) = 1">
    <xsl:copy-of select="$VarPageTemplateFile" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:pagetemplate-files">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:pagetemplate-files">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:pagetemplate-include-files -->
 <!--                                   -->

 <xsl:template match="/" mode="wwmode:pagetemplate-include-files">
  <xsl:param name="ParamPageTemplateURI" />

  <!-- Page Template Directory URI -->
  <!--                             -->
  <xsl:variable name="VarPageTemplateDirectoryURI" select="wwuri:MakeAbsolute($ParamPageTemplateURI, '..')" />

  <!-- Locate 'content-from-file' and 'replace-from-file' attributes -->
  <!--                                                               -->
  <xsl:variable name="VarPageTemplateFilesAsXML">
   <xsl:for-each select="//*[@wwpage:*]">
    <xsl:variable name="VarNode" select="." />

    <!-- Include relative URI -->
    <!--                      -->
    <xsl:variable name="VarIncludeRelativeURI">
     <xsl:choose>
      <xsl:when test="string-length($VarNode/wwpage:replace-from-file) &gt; 0">
       <xsl:value-of select="$VarNode/@wwpage:replace-from-file" />
      </xsl:when>

      <xsl:when test="string-length($VarNode/wwpage:content-from-file) &gt; 0">
       <xsl:value-of select="$VarNode/@wwpage:content-from-file" />
      </xsl:when>

      <xsl:when test="string-length($VarNode/wwpage:replace-from-data-file) &gt; 0">
       <xsl:value-of select="$VarNode/@wwpage:replace-from-data-file" />
      </xsl:when>

      <xsl:otherwise>
       <!-- Nothing! -->
       <!--          -->
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Include relative URI defined? -->
    <!--                               -->
    <xsl:if test="string-length($VarIncludeRelativeURI) &gt; 0">
     <!-- Report file -->
     <!--             -->
     <xsl:variable name="VarAbsoluteURI" select="wwuri:MakeAbsolute($VarPageTemplateDirectoryURI, $VarIncludeRelativeURI)" />
     <xsl:variable name="VarAbsolutePath" select="wwuri:AsFilePath($VarAbsoluteURI)" />
     <wwpage:File path="{$VarAbsolutePath}" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPageTemplateFiles" select="msxsl:node-set($VarPageTemplateFilesAsXML)" />

  <!-- Eliminate duplicates -->
  <!--                      -->
  <xsl:for-each select="$VarPageTemplateFiles/wwpage:File">
   <xsl:variable name="VarPageTemplateFile" select="." />

   <xsl:variable name="VarPageTemplateFilesWithPath" select="key('wwpage-files-by-path', $VarPageTemplateFile/@path)" />
   <xsl:if test="count($VarPageTemplateFilesWithPath[1] | $VarPageTemplateFile) = 1">
    <xsl:copy-of select="$VarPageTemplateFile" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:pagetemplate-include-files">
  <xsl:param name="ParamPageTemplateURI" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:pagetemplate-include-files">
  <xsl:param name="ParamPageTemplateURI" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- wwmode:pagetemplate-copynodes -->
 <!--                               -->

 <xsl:template match="*" mode="wwmode:pagetemplate-copynodes">
  <xsl:variable name="VarNode" select="." />

  <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
   <xsl:copy-of select="@*" />

   <xsl:apply-templates mode="wwmode:pagetemplate-copynodes" />
  </xsl:element>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:pagetemplate-copynodes">
  <xsl:copy />
 </xsl:template>


 <!-- wwmode:pagetemplate-replacecontent -->
 <!--                                    -->

 <xsl:template match="*" mode="wwmode:pagetemplate-replacecontent">
  <xsl:param name="ParamContentName" />
  <xsl:param name="ParamReplacements" />

  <xsl:variable name="VarReplacement" select="$ParamReplacements/wwpage:Replacement[@name = $ParamContentName][1]" />
  <xsl:choose>
   <xsl:when test="count($VarReplacement) = 1">
    <xsl:choose>
     <xsl:when test="$VarReplacement/@value">
      <xsl:value-of select="$VarReplacement/@value" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:apply-templates select="$VarReplacement/node() | $VarReplacement/text() | $VarReplacement/comment() | $VarReplacement/processing-instruction()" mode="wwmode:pagetemplate-copynodes" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <!-- Check for settings -->
    <!--                    -->
    <xsl:if test="starts-with($ParamContentName, 'wwsetting:')">
     <xsl:value-of select="wwprojext:GetFormatSetting(substring-after($ParamContentName, 'wwsetting:'))" />
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:pagetemplate-replacecontent">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- wwmode:pagetemplate-replaceattribute -->
 <!--                                      -->

 <xsl:template match="wwpage:ActionAttribute[(@action = 'copy-relative-to-output') or (@action = 'copy-relative-to-output-root') or (@action = 'copy-from-data-relative-to-output') or (@action = 'copy-from-data-relative-to-output-root') or (@action = 'relative-to-output') or (@action = 'relative-to-output-root') or (@action = 'absolute-to-output') or (@action = 'resolved-uri') or (@action = 'resolved-path')]" mode="wwmode:pagetemplate-replaceattribute">
  <xsl:param name="ParamActionAttribute" select="." />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamAttribute" />

  <!-- Extract attribute value -->
  <!--                         -->
  <xsl:variable name="VarAttributeValue">
   <xsl:call-template name="PageTemplates-ExtractAttributeValue">
    <xsl:with-param name="ParamAttributeValue" select="string($ParamAttribute)" />
   </xsl:call-template>
  </xsl:variable>

  <!-- Determine value -->
  <!--                 -->
  <xsl:variable name="VarAbsoluteReferenceURI" select="wwuri:AsURI(wwfilesystem:Combine($ParamOutputDirectoryPath, 'dummy.component'))" />
  <xsl:variable name="VarAbsoluteURI" select="wwuri:MakeAbsolute($VarAbsoluteReferenceURI, $VarAttributeValue)" />
  <xsl:variable name="VarAbsoluteResolvedURI" select="wwuri:AsURI($VarAbsoluteURI)" />
  <xsl:variable name="VarResultURI">
   <xsl:choose>
    <xsl:when test="$ParamActionAttribute/@action = 'resolved-uri'">
     <xsl:value-of select="wwuri:AsURI($VarAttributeValue)" />
    </xsl:when>

    <xsl:when test="$ParamActionAttribute/@action = 'resolved-path'">
     <xsl:value-of select="wwuri:AsFilePath(wwuri:AsURI($VarAttributeValue))" />
    </xsl:when>

    <xsl:when test="$ParamActionAttribute/@action = 'absolute-to-output'">
     <xsl:value-of select="$VarAbsoluteResolvedURI" />
    </xsl:when>

    <xsl:when test="$ParamActionAttribute/@action = 'copy-relative-to-output-root' or $ParamActionAttribute/@action = 'copy-from-data-relative-to-output-root' or $ParamActionAttribute/@action = 'relative-to-output-root'">
     <xsl:variable name="VarOutputRootFolderPath" select="wwprojext:GetTargetOutputDirectoryPath()"/>
     <xsl:variable name="VarOutputRootAbsoluteReferenceURI" select="wwuri:AsURI(wwfilesystem:Combine($VarOutputRootFolderPath, 'dummy.component'))" />
     <xsl:variable name="VarOutputRootAbsoluteURI" select="wwuri:MakeAbsolute($VarOutputRootAbsoluteReferenceURI, $VarAttributeValue)" />
     <xsl:variable name="VarOutputRootAbsoluteResolvedURI" select="wwuri:AsURI($VarOutputRootAbsoluteURI)" />

     <xsl:value-of select="wwuri:GetRelativeTo($VarOutputRootAbsoluteResolvedURI, $ParamOutputPath)" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="wwuri:GetRelativeTo($VarAbsoluteResolvedURI, $ParamOutputPath)" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarReplacement">
   <xsl:call-template name="PageTemplates-ReplaceAttributeValue">
    <xsl:with-param name="ParamAttributeValue" select="string($ParamAttribute)" />
    <xsl:with-param name="ParamReplacement" select="$VarResultURI" />
   </xsl:call-template>
  </xsl:variable>

  <wwpage:Attribute name="{name($ParamAttribute)}" value="{$VarReplacement}" />
 </xsl:template>


 <xsl:template match="wwpage:ActionAttribute[starts-with(@action, 'wwsetting:')]" mode="wwmode:pagetemplate-replaceattribute">
  <xsl:param name="ParamActionAttribute" select="." />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamAttribute" />

  <!-- Settings values -->
  <!--                 -->
  <wwpage:Attribute name="{name($ParamAttribute)}" value="{wwprojext:GetFormatSetting(substring-after($ParamActionAttribute/@action, 'wwsetting:'))}" />
 </xsl:template>


 <xsl:template match="wwpage:ActionAttribute" mode="wwmode:pagetemplate-replaceattribute">
  <xsl:param name="ParamActionAttribute" select="." />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamAttribute" />

  <!-- Replacement values -->
  <!--                    -->
  <xsl:variable name="VarReplacement" select="$ParamReplacements/wwpage:Replacement[@name = $ParamActionAttribute/@action][1]" />
  <xsl:if test="count($VarReplacement) = 1">
   <wwpage:Attribute name="{name($ParamAttribute)}">
    <xsl:attribute name="value">
     <xsl:variable name="VarReplacementText">
      <xsl:choose>
       <xsl:when test="string-length($VarReplacement/@value) &gt; 0">
        <xsl:value-of select="$VarReplacement/@value" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:for-each select="$VarReplacement/text()">
         <xsl:value-of select="normalize-space(.)" />
        </xsl:for-each>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:variable>

     <!-- Replace value -->
     <!--               -->
     <xsl:call-template name="PageTemplates-ReplaceAttributeValue">
      <xsl:with-param name="ParamAttributeValue" select="string($ParamAttribute)" />
      <xsl:with-param name="ParamReplacement" select="$VarReplacementText" />
     </xsl:call-template>
    </xsl:attribute>
   </wwpage:Attribute>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:pagetemplate-replaceattribute">
  <xsl:param name="ParamActionAttribute" select="." />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamAttribute" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:pagetemplate-replaceattribute">
  <xsl:param name="ParamActionAttribute" select="." />
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamReplacements" />
  <xsl:param name="ParamAttribute" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <xsl:template name="PageTemplate-ReplaceAttributes">
  <xsl:param name="ParamPageTemplateURI" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamAttributes" />
  <xsl:param name="ParamReplacements" />

  <!-- Extract action attributes -->
  <!--                                -->
  <xsl:variable name="VarActionAttributesAsXML">
   <xsl:for-each select="$ParamAttributes[starts-with(name(), 'wwpage:attribute-')]">
    <xsl:variable name="VarAttribute" select="." />

    <xsl:variable name="VarName" select="substring-after(name($VarAttribute), 'wwpage:attribute-')" />

    <wwpage:ActionAttribute name="{$VarName}" action="{$VarAttribute}" />

    <!-- Account for attributes with namespace prefixes -->
    <!--                                                -->
    <xsl:if test="contains($VarName, '-')">
     <xsl:variable name="VarPrefix" select="substring-before($VarName, '-')" />
     <xsl:variable name="VarSuffix" select="substring-after($VarName, '-')" />

     <wwpage:ActionAttribute name="{$VarPrefix}:{$VarSuffix}" action="{$VarAttribute}" />
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarActionAttributes" select="msxsl:node-set($VarActionAttributesAsXML)" />

  <!-- Emit new attributes -->
  <!--                     -->
  <xsl:for-each select="$ParamAttributes[not(starts-with(name(), 'wwpage:attribute-'))]">
   <xsl:variable name="VarAttribute" select="." />

   <xsl:variable name="VarActionAttribute" select="$VarActionAttributes/wwpage:ActionAttribute[@name = name($VarAttribute)][1]" />
   <xsl:choose>
    <xsl:when test="count($VarActionAttribute) = 1">
     <!-- Determine replacement value -->
     <!--                             -->
     <xsl:apply-templates select="$VarActionAttribute" mode="wwmode:pagetemplate-replaceattribute">
      <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
      <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
      <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
      <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
      <xsl:with-param name="ParamAttribute" select="$VarAttribute" />
     </xsl:apply-templates>
    </xsl:when>

    <xsl:otherwise>
     <!-- Keep previous value -->
     <!--                     -->
     <wwpage:Attribute name="{name($VarAttribute)}" value="{$VarAttribute}" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <!-- wwmode:pagetemplate -->
 <!--                     -->

 <xsl:template match="/" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:apply-templates select="node() | text() | comment() | processing-instruction()" mode="wwmode:pagetemplate">
   <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
   <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
   <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
   <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="*[(string-length(@wwpage:content) &gt; 0) or (string-length(@wwpage:replace) &gt; 0)] | wwpage:*[(string-length(@wwpage:content) &gt; 0) or (string-length(@wwpage:replace) &gt; 0)]" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:variable name="VarNode" select="." />

  <!-- Allow content? -->
  <!--                -->
  <xsl:variable name="VarAllow">
   <xsl:call-template name="PageTemplates-CheckConditions">
    <xsl:with-param name="ParamConditionAttribute" select="$VarNode/@wwpage:condition" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$VarAllow = '1'">
   <!-- Filter attributes -->
   <!--                   -->
   <xsl:variable name="VarAttributesAsXML">
    <xsl:call-template name="PageTemplate-ReplaceAttributes">
     <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
     <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
     <xsl:with-param name="ParamAttributes" select="$VarNode/@*[(name() != 'wwpage:content') and (name() != 'wwpage:replace') and (name() != 'wwpage:content-from-file') and (name() != 'wwpage:replace-from-file') and (name() != 'wwpage:replace-from-data-file') and (name() != 'wwpage:content-from-lookup') and (name() != 'wwpage:replace-from-lookup') and (name() != 'wwpage:condition')]" />
     <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarAttributes" select="msxsl:node-set($VarAttributesAsXML)" />

   <!-- Extend replacements with attribute values -->
   <!--                                           -->
   <xsl:variable name="VarReplacementsAsXML">
    <!-- Add attribute replacements -->
    <!--                            -->
    <xsl:for-each select="$VarAttributes/wwpage:Attribute">
     <xsl:variable name="VarAttribute" select="." />

     <wwpage:Replacement name="wwattribute:{$VarAttribute/@name}" value="{$VarAttribute/@value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarReplacements" select="$ParamReplacements | msxsl:node-set($VarReplacementsAsXML)" />

   <!-- Handle wwpage:content or wwpage:replace -->
   <!--                                         -->
   <xsl:choose>
    <!-- wwpage:replace                                   -->
    <!-- Suppress emission of wwpage:* elements in result -->
    <!--                                                  -->
    <xsl:when test="(string-length($VarNode/@wwpage:replace) &gt; 0) or ((string-length($VarNode/@wwpage:content) &gt; 0) and (starts-with(name($VarNode), 'wwpage:')))">
     <xsl:apply-templates select="$VarNode" mode="wwmode:pagetemplate-replacecontent">
      <xsl:with-param name="ParamContentName" select="$VarNode/@wwpage:replace" />
      <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
     </xsl:apply-templates>
    </xsl:when>

    <!-- wwpage:content -->
    <!--                -->
    <xsl:otherwise>
     <!-- Copy element -->
     <!--              -->
     <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
      <!-- Update attributes -->
      <!--                   -->
      <xsl:for-each select="$VarAttributes/wwpage:Attribute">
       <xsl:variable name="VarAttribute" select="." />

       <!-- Do not emit empty attribute values -->
       <!--                                    -->
       <xsl:if test="string-length($VarAttribute/@value) &gt; 0">
        <xsl:attribute name="{$VarAttribute/@name}">
         <xsl:value-of select="$VarAttribute/@value" />
        </xsl:attribute>
       </xsl:if>
      </xsl:for-each>

      <!-- Content -->
      <!--         -->
      <xsl:apply-templates select="$VarNode" mode="wwmode:pagetemplate-replacecontent">
       <xsl:with-param name="ParamContentName" select="$VarNode/@wwpage:content" />
       <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
      </xsl:apply-templates>
     </xsl:element>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*[(string-length(@wwpage:content-from-file) &gt; 0) or (string-length(@wwpage:replace-from-file) &gt; 0) or (string-length(@wwpage:replace-from-data-file) &gt; 0)]" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:variable name="VarNode" select="." />

  <!-- Page Template Directory URI -->
  <!--                             -->
  <xsl:variable name="VarPageTemplateDirectoryURI">
   <xsl:if test="string-length($ParamPageTemplateURI) &gt; 0">
    <xsl:value-of select="wwuri:MakeAbsolute($ParamPageTemplateURI, '..')" />
   </xsl:if>
  </xsl:variable>

  <!-- Allow content? -->
  <!--                -->
  <xsl:variable name="VarAllow">
   <xsl:call-template name="PageTemplates-CheckConditions">
    <xsl:with-param name="ParamConditionAttribute" select="$VarNode/@wwpage:condition" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$VarAllow = '1'">
   <!-- Filter attributes -->
   <!--                   -->
   <xsl:variable name="VarAttributesAsXML">
    <xsl:call-template name="PageTemplate-ReplaceAttributes">
     <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
     <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
     <xsl:with-param name="ParamAttributes" select="$VarNode/@*[(name() != 'wwpage:content') and (name() != 'wwpage:replace') and (name() != 'wwpage:content-from-file') and (name() != 'wwpage:replace-from-file') and (name() != 'wwpage:replace-from-data-file') and (name() != 'wwpage:content-from-lookup') and (name() != 'wwpage:replace-from-lookup') and (name() != 'wwpage:condition')]" />
     <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarAttributes" select="msxsl:node-set($VarAttributesAsXML)" />

   <!-- Extend replacements with attribute values -->
   <!--                                           -->
   <xsl:variable name="VarReplacementsAsXML">
    <!-- Copy existing replacements -->
    <!--                            -->
    <xsl:for-each select="$ParamReplacements">
     <xsl:variable name="VarReplacement" select="." />

     <xsl:copy-of select="$VarReplacement" />
    </xsl:for-each>

    <!-- Add attribute replacements -->
    <!--                            -->
    <xsl:for-each select="$VarAttributes/wwpage:Attribute">
     <xsl:variable name="VarAttribute" select="." />

     <wwpage:Replacement name="wwattribute:{$VarAttribute/@name}" value="{$VarAttribute/@value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

   <!-- Handle wwpage:content-from-file or wwpage:replace-from-file or wwpage:replace-from-data-file -->
   <!--                                                                                              -->
   <xsl:choose>
    <!-- wwpage:replace-from-file -->
    <!--                          -->
    <xsl:when test="string-length($VarNode/@wwpage:replace-from-file) &gt; 0">
     <!-- Replace with file contents -->
     <!--                            -->
     <xsl:if test="string-length($VarPageTemplateDirectoryURI) &gt; 0">
      <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($VarPageTemplateDirectoryURI, $VarNode/@wwpage:replace-from-file))" />
      <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
     </xsl:if>
    </xsl:when>

    <!-- wwpage:replace-from-data-file -->
    <!--                               -->
    <xsl:when test="string-length($VarNode/@wwpage:replace-from-data-file) &gt; 0">
     <!-- Replace with file contents -->
     <!--                            -->
     <xsl:if test="string-length(wwprojext:GetTargetDataDirectoryPath()) &gt; 0">
      <xsl:variable name="VarFilePath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $VarNode/@wwpage:replace-from-data-file)" />
      <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
     </xsl:if>
    </xsl:when>

    <!-- Suppress emission of wwpage:* elements in result -->
    <!-- wwpage:content-from-file                         -->
    <!--                                                  -->
    <xsl:when test="(string-length($VarNode/@wwpage:content-from-file) &gt; 0) and (starts-with(name($VarNode), 'wwpage:'))">
     <!-- Replace with file contents -->
     <!--                            -->
     <xsl:if test="string-length($VarPageTemplateDirectoryURI) &gt; 0">
      <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($VarPageTemplateDirectoryURI, $VarNode/@wwpage:content-from-file))" />
      <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
     </xsl:if>
    </xsl:when>

    <!-- wwpage:content-from-file -->
    <!--                          -->
    <xsl:when test="string-length($VarNode/@wwpage:content-from-file) &gt; 0">
     <!-- Copy element -->
     <!--              -->
     <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
      <!-- Update attributes -->
      <!--                   -->
      <xsl:for-each select="$VarAttributes/wwpage:Attribute">
       <xsl:variable name="VarAttribute" select="." />

       <!-- Do not emit empty attribute values -->
       <!--                                    -->
       <xsl:if test="string-length($VarAttribute/@value) &gt; 0">
        <xsl:attribute name="{$VarAttribute/@name}">
         <xsl:value-of select="$VarAttribute/@value" />
        </xsl:attribute>
       </xsl:if>
      </xsl:for-each>

      <!-- Content -->
      <!--         -->
      <xsl:if test="string-length($VarPageTemplateDirectoryURI) &gt; 0">
       <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($VarPageTemplateDirectoryURI, $VarNode/@wwpage:content-from-file))" />
       <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
      </xsl:if>
     </xsl:element>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*[(string-length(@wwpage:content-from-lookup) &gt; 0) or (string-length(@wwpage:replace-from-lookup) &gt; 0)]" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:variable name="VarNode" select="." />

  <!-- Page Template Directory URI -->
  <!--                             -->
  <xsl:variable name="VarPageTemplateDirectoryURI">
   <xsl:if test="string-length($ParamPageTemplateURI) &gt; 0">
    <xsl:value-of select="wwuri:MakeAbsolute($ParamPageTemplateURI, '..')" />
   </xsl:if>
  </xsl:variable>

  <!-- Allow content? -->
  <!--                -->
  <xsl:variable name="VarAllow">
   <xsl:call-template name="PageTemplates-CheckConditions">
    <xsl:with-param name="ParamConditionAttribute" select="$VarNode/@wwpage:condition" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$VarAllow = '1'">
   <!-- Filter attributes -->
   <!--                   -->
   <xsl:variable name="VarAttributesAsXML">
    <xsl:call-template name="PageTemplate-ReplaceAttributes">
     <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
     <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
     <xsl:with-param name="ParamAttributes" select="$VarNode/@*[(name() != 'wwpage:content') and (name() != 'wwpage:replace') and (name() != 'wwpage:content-from-file') and (name() != 'wwpage:replace-from-file') and (name() != 'wwpage:replace-from-data-file') and (name() != 'wwpage:content-from-lookup') and (name() != 'wwpage:replace-from-lookup') and (name() != 'wwpage:condition')]" />
     <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarAttributes" select="msxsl:node-set($VarAttributesAsXML)" />

   <!-- Extend replacements with attribute values -->
   <!--                                           -->
   <xsl:variable name="VarReplacementsAsXML">
    <!-- Copy existing replacements -->
    <!--                            -->
    <xsl:for-each select="$ParamReplacements">
     <xsl:variable name="VarReplacement" select="." />

     <xsl:copy-of select="$VarReplacement" />
    </xsl:for-each>

    <!-- Add attribute replacements -->
    <!--                            -->
    <xsl:for-each select="$VarAttributes/wwpage:Attribute">
     <xsl:variable name="VarAttribute" select="." />

     <wwpage:Replacement name="wwattribute:{$VarAttribute/@name}" value="{$VarAttribute/@value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

   <!-- Handle wwpage:content-from-lookup or wwpage:replace-from-lookup -->
   <!--                                                                 -->
   <xsl:choose>
    <!-- wwpage:replace-from-lookup -->
    <!--                            -->
    <xsl:when test="string-length($VarNode/@wwpage:replace-from-lookup) &gt; 0">
     <!-- Replace with file contents -->
     <!--                            -->
     <xsl:variable name="VarLookup">
      <xsl:apply-templates select="$VarNode" mode="wwmode:pagetemplate-replacecontent">
       <xsl:with-param name="ParamContentName" select="$VarNode/@wwpage:replace-from-lookup" />
       <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
      </xsl:apply-templates>
     </xsl:variable>
     <xsl:if test="string-length($VarLookup) &gt; 0">
      <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($ParamOutputPath, $VarLookup))" />
      <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
     </xsl:if>
    </xsl:when>

    <!-- Suppress emission of wwpage:* elements in result -->
    <!-- wwpage:content-from-lookup                       -->
    <!--                                                  -->
    <xsl:when test="(string-length($VarNode/@wwpage:content-from-lookup) &gt; 0) and (starts-with(name($VarNode), 'wwpage:'))">
     <!-- Replace with file contents -->
     <!--                            -->
     <xsl:variable name="VarLookup">
      <xsl:apply-templates select="$VarNode" mode="wwmode:pagetemplate-replacecontent">
       <xsl:with-param name="ParamContentName" select="$VarNode/@wwpage:content-from-lookup" />
       <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
      </xsl:apply-templates>
     </xsl:variable>
     <xsl:if test="string-length($VarLookup) &gt; 0">
      <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($ParamOutputPath, $VarLookup))" />
      <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
     </xsl:if>
    </xsl:when>

    <!-- wwpage:content-from-lookup -->
    <!--                            -->
    <xsl:when test="string-length($VarNode/@wwpage:content-from-lookup) &gt; 0">
     <!-- Copy element -->
     <!--              -->
     <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
      <!-- Update attributes -->
      <!--                   -->
      <xsl:for-each select="$VarAttributes/wwpage:Attribute">
       <xsl:variable name="VarAttribute" select="." />

       <!-- Do not emit empty attribute values -->
       <!--                                    -->
       <xsl:if test="string-length($VarAttribute/@value) &gt; 0">
        <xsl:attribute name="{$VarAttribute/@name}">
         <xsl:value-of select="$VarAttribute/@value" />
        </xsl:attribute>
       </xsl:if>
      </xsl:for-each>

      <!-- Content -->
      <!--         -->
      <xsl:variable name="VarLookup">
       <xsl:apply-templates select="$VarNode" mode="wwmode:pagetemplate-replacecontent">
        <xsl:with-param name="ParamContentName" select="$VarNode/@wwpage:content-from-lookup" />
        <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
       </xsl:apply-templates>
      </xsl:variable>
      <xsl:if test="string-length($VarLookup) &gt; 0">
       <xsl:variable name="VarFilePath" select="wwuri:AsFilePath(wwuri:MakeAbsolute($ParamOutputPath, $VarLookup))" />
       <xsl:value-of select="wwstring:FromFile($VarFilePath, 'UTF-8')" />
      </xsl:if>
     </xsl:element>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template match="wwpage:*" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:variable name="VarNode" select="." />

  <!-- Allow content? -->
  <!--                -->
  <xsl:variable name="VarAllow">
   <xsl:call-template name="PageTemplates-CheckConditions">
    <xsl:with-param name="ParamConditionAttribute" select="$VarNode/@wwpage:condition" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$VarAllow = '1'">
   <!-- Suppress emission of wwpage:* elements in result -->
   <!--                                                  -->

   <!-- Process children -->
   <!--                  -->
   <xsl:variable name="VarChildren" select="$VarNode/node() | $VarNode/text() | $VarNode/comment() | $VarNode/processing-instruction()" />
   <xsl:apply-templates select="$VarChildren" mode="wwmode:pagetemplate">
    <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
    <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
    <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
    <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
   </xsl:apply-templates>
  </xsl:if>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:variable name="VarNode" select="." />

  <!-- Allow content? -->
  <!--                -->
  <xsl:variable name="VarAllow">
   <xsl:call-template name="PageTemplates-CheckConditions">
    <xsl:with-param name="ParamConditionAttribute" select="$VarNode/@wwpage:condition" />
    <xsl:with-param name="ParamConditions" select="$ParamConditions" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$VarAllow = '1'">
   <!-- Filter attributes -->
   <!--                   -->
   <xsl:variable name="VarAttributesAsXML">
    <xsl:call-template name="PageTemplate-ReplaceAttributes">
     <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
     <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
     <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
     <xsl:with-param name="ParamAttributes" select="$VarNode/@*[name() != 'wwpage:condition']" />
     <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarAttributes" select="msxsl:node-set($VarAttributesAsXML)" />

   <!-- Process -->
   <!--         -->
   <xsl:choose>
    <xsl:when test="$VarNode/node()[1] | $VarNode/text()[1] | $VarNode/comment()[1] | $VarNode/processing-instruction()[1]">
     <xsl:choose>
      <xsl:when test="count($VarNode/@wwpage:*[name() != 'wwpage:condition'][1]) = 1">
       <!-- Copy element -->
       <!--              -->
       <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
        <xsl:for-each select="$VarAttributes/wwpage:Attribute">
         <xsl:variable name="VarAttribute" select="." />

         <!-- Do not emit empty attribute values -->
         <!--                                    -->
         <xsl:if test="string-length($VarAttribute/@value) &gt; 0">
          <xsl:attribute name="{$VarAttribute/@name}">
           <xsl:value-of select="$VarAttribute/@value" />
          </xsl:attribute>
         </xsl:if>
        </xsl:for-each>

        <!-- Process children -->
        <!--                  -->
        <xsl:variable name="VarChildren" select="$VarNode/node() | $VarNode/text() | $VarNode/comment() | $VarNode/processing-instruction()" />
        <xsl:apply-templates select="$VarChildren" mode="wwmode:pagetemplate">
         <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
         <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
         <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
         <xsl:with-param name="ParamConditions" select="$ParamConditions" />
         <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
        </xsl:apply-templates>
       </xsl:element>
      </xsl:when>

      <xsl:otherwise>
       <!-- Copy element -->
       <!--              -->
       <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
        <xsl:copy-of select="$VarNode/@*[name() != 'wwpage:condition']" />

        <!-- Process children -->
        <!--                  -->
        <xsl:variable name="VarChildren" select="$VarNode/node() | $VarNode/text() | $VarNode/comment() | $VarNode/processing-instruction()" />
        <xsl:apply-templates select="$VarChildren" mode="wwmode:pagetemplate">
         <xsl:with-param name="ParamPageTemplateURI" select="$ParamPageTemplateURI" />
         <xsl:with-param name="ParamOutputDirectoryPath" select="$ParamOutputDirectoryPath" />
         <xsl:with-param name="ParamOutputPath" select="$ParamOutputPath" />
         <xsl:with-param name="ParamConditions" select="$ParamConditions" />
         <xsl:with-param name="ParamReplacements" select="$ParamReplacements" />
        </xsl:apply-templates>
       </xsl:element>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
     <!-- Element has no children -->
     <!--                         -->
     <xsl:variable name="VarEmptyElementAsXML">
      <!-- Copy element -->
      <!--              -->
      <xsl:element name="{local-name($VarNode)}" namespace="{namespace-uri($VarNode)}">
       <xsl:for-each select="$VarAttributes/wwpage:Attribute">
        <xsl:variable name="VarAttribute" select="." />

        <!-- Do not emit empty attribute values -->
        <!--                                    -->
        <xsl:if test="string-length($VarAttribute/@value) &gt; 0">
         <xsl:attribute name="{$VarAttribute/@name}">
          <xsl:value-of select="$VarAttribute/@value" />
         </xsl:attribute>
        </xsl:if>
       </xsl:for-each>
      </xsl:element>
     </xsl:variable>
     <xsl:variable name="VarEmptyElement" select="msxsl:node-set($VarEmptyElementAsXML)/*[1]" />

     <!-- Emit element -->
     <!--              -->
     <xsl:copy-of select="$VarEmptyElement" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template match="text()" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:copy />
 </xsl:template>


 <xsl:template match="comment()" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:copy />
 </xsl:template>


 <xsl:template match="processing-instruction()" mode="wwmode:pagetemplate">
  <xsl:param name="ParamPageTemplateURI" select="''" />
  <xsl:param name="ParamOutputDirectoryPath" />
  <xsl:param name="ParamOutputPath" />
  <xsl:param name="ParamConditions" />
  <xsl:param name="ParamReplacements" select="msxsl:node-set('')" />

  <xsl:copy />
 </xsl:template>
</xsl:stylesheet>
