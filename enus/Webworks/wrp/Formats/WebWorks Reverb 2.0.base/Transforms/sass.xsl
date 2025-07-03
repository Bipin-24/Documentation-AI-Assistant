<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwsplitpriorities="urn:WebWorks-Engine-Split-Priorities-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwsass="urn:WebWorks-XSLT-Extension-Sass"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              exclude-result-prefixes="xsl wwsplits wwsplitpriorities wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri
                              wwstring wwunits wwfilesext wwprojext wwexsldoc wwsass msxsl"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDestinationFolderName" />


 <xsl:strip-space elements="*" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_borders.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_borders.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_colors.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_colors.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_fonts.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_fonts.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_functions.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_functions.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_icons.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_icons.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/_sizes.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/_sizes.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/connect.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/connect.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_closed.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_closed.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_open.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_open.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/print.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/print.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/search.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/search.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/skin.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/skin.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/social.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/social.scss')))" />
   <xsl:value-of select="concat(wwuri:AsFilePath('wwformat:Pages/sass/webworks.scss'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Pages/sass/webworks.scss')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Load paths -->
   <!--            -->
   <xsl:variable name="VarSassInputFiles">
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_borders.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_colors.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_fonts.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_functions.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_icons.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/_sizes.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/connect.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_closed.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/menu_initial_open.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/print.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/search.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/skin.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/social.scss'))/wwfiles:Files/wwfiles:File"/>
    <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath('wwformat:Pages/sass/webworks.scss'))/wwfiles:Files/wwfiles:File"/>
   </xsl:variable>

    <xsl:variable name="VarTargetsPath" select="wwprojext:GetProjectTargetOverrideDirectoryPath()"/>
    <xsl:variable name="VarTargetsSassPath" select="wwfilesystem:Combine($VarTargetsPath, 'Pages/sass')"/>
    <xsl:variable name="VarFormatsPath" select="wwprojext:GetProjectFormatDirectoryPath()"/>
    <xsl:variable name="VarFormatsSassPath" select="wwfilesystem:Combine($VarFormatsPath, 'Pages/sass')"/>

    <!-- Making sure there is no duplicate files from Target folder-->
    <!--                                                           -->
    <xsl:variable name="VarSassCustomTargetFiles">
     <xsl:if test="wwfilesystem:DirectoryExists($VarTargetsSassPath)">
      <xsl:for-each select="wwfilesystem:GetFiles($VarTargetsSassPath)/wwfiles:Files/wwfiles:File">

        <!-- Get the file name of the current node -->
        <!--                                       -->
        <xsl:variable name="VarFileName" select="string(wwfilesystem:GetFileName(./@path))"/>
        
        <!-- Try to select an existing SASS file with the same file name -->
        <!--                                                             -->
        <xsl:variable name="VarExistingNode" select="msxsl:node-set($VarSassInputFiles)/wwfiles:File[substring(@path, string-length(@path) + 1 - string-length($VarFileName)) = $VarFileName]"/>
        
        <!-- Is filename unique? -->
        <!--                     -->
        <xsl:if test="not($VarExistingNode)">
          
          <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath(./@path))/wwfiles:Files/wwfiles:File"/>
        </xsl:if>
      </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- Making sure there is no duplicate files from Formats folder-->
    <!--                                                            -->
    <xsl:variable name="VarSassCustomFormatFiles">
     <xsl:if test="wwfilesystem:DirectoryExists($VarFormatsSassPath)">
      <xsl:for-each select="wwfilesystem:GetFiles($VarFormatsSassPath)/wwfiles:Files/wwfiles:File">

        <!-- Get the file name of the current node -->
        <!--                                       -->
        <xsl:variable name="VarFileName" select="string(wwfilesystem:GetFileName(./@path))"/>

        <!-- Try to select an existing SASS file with the same file name -->
        <!--                                                             -->
        <xsl:variable name="VarExistingNode" select="msxsl:node-set($VarSassInputFiles)/wwfiles:File[substring(@path, string-length(@path) + 1 - string-length($VarFileName)) = $VarFileName]"/>

        <!-- Is filename unique? -->
        <!--                     -->
        <xsl:if test="not($VarExistingNode)">
          <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath(./@path))/wwfiles:Files/wwfiles:File"/>
        </xsl:if>
      </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- Combining Target file nodes with Format file nodes -->
    <!--                                                    -->
    <xsl:variable name="VarSassCustomCombinedFiles">

      <!-- Target nodes -->
      <!--              -->
      <xsl:copy-of select="$VarSassCustomTargetFiles"/>

      <!-- Comparing Format files to Target Fils for duplicates -->
      <!--                                                        -->
      <xsl:for-each select="msxsl:node-set($VarSassCustomFormatFiles)/*">

        <!-- Get the file name of the current node -->
        <!--                                       -->
        <xsl:variable name="VarFileName" select="string(wwfilesystem:GetFileName(./@path))"/>

        <!-- Try to select an existing SASS file with the same file name -->
        <!--                                                             -->
        <xsl:variable name="VarExistingNode" select="msxsl:node-set($VarSassCustomTargetFiles)/wwfiles:File[substring(@path, string-length(@path) + 1 - string-length($VarFileName)) = $VarFileName]"/>

        <!-- Is filename unique? -->
        <!--                     -->
        <xsl:if test="not($VarExistingNode)">
          <xsl:copy-of select="wwfilesystem:GetFiles(wwuri:AsFilePath(./@path))/wwfiles:Files/wwfiles:File"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Combining the new scss file paths with the preset ones -->
    <!--                                                        -->
    <xsl:variable name="VarSassCombinedInputFiles">
      <xsl:copy-of select="$VarSassInputFiles"/>
      <xsl:copy-of select="$VarSassCustomCombinedFiles"/>
    </xsl:variable>

   <!-- Copy to Temp directory -->
   <!--                        -->
   <xsl:variable name="VarTempFolderPath" select="wwfilesystem:GetDirectoryName(wwfilesystem:GetTempFileName())"/>
   <xsl:for-each select="msxsl:node-set($VarSassCombinedInputFiles)/*">
    <xsl:variable name="VarSASSFileSourcePath" select="./@path"/>

    <!-- Allow import of custom sass files in sub-folders -->
    <xsl:variable name="VarSASSFileName">
     <xsl:variable name="VarSASSPathFromFormats" select="wwfilesystem:GetRelativeTo($VarSASSFileSourcePath, wwfilesystem:Combine($VarFormatsSassPath, 'dummy.file'))" />
     <xsl:variable name="VarSASSPathFromTargets" select="wwfilesystem:GetRelativeTo($VarSASSFileSourcePath, wwfilesystem:Combine($VarTargetsSassPath, 'dummy.file'))" />

     <!-- Trick to determine if SASS paths are relative to Formats/Targets override folder -->
     <!--                                                                                  -->
     <xsl:variable name="VarSASSPathFromFormatsAbsolute" select="wwfilesystem:GetAbsoluteFrom($VarSASSPathFromFormats, wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), 'dummy2.component'))" />
     <xsl:variable name="VarSASSPathFromFormatsIsRelative" select="$VarSASSPathFromFormats != $VarSASSPathFromFormatsAbsolute" />
     <xsl:variable name="VarSASSPathFromTargetsAbsolute" select="wwfilesystem:GetAbsoluteFrom($VarSASSPathFromTargets, wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), 'dummy2.component'))" />
     <xsl:variable name="VarSASSPathFromTargetsIsRelative" select="$VarSASSPathFromTargets != $VarSASSPathFromTargetsAbsolute" />

     <!-- Relative and within the Targets/Formats override folder? -->
     <!--                                                          -->
     <xsl:choose>
      <!-- relative path and in same or child folder -->
      <!--                                           -->
      <xsl:when test="$VarSASSPathFromTargetsIsRelative and not(starts-with($VarSASSPathFromTargets, '..'))">
       <xsl:value-of select="$VarSASSPathFromTargets" />
      </xsl:when>

      <!-- relative path and in same or child folder -->
      <!--                                           -->
      <xsl:when test="$VarSASSPathFromFormatsIsRelative and not(starts-with($VarSASSPathFromFormats, '..'))">
       <xsl:value-of select="$VarSASSPathFromFormats" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="wwfilesystem:GetFileName($VarSASSFileSourcePath)" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <xsl:variable name="VarSASSFileDestinationPath" select="wwfilesystem:Combine($VarTempFolderPath, $VarSASSFileName)"/>
    <xsl:variable name="VarCopyFile" select="wwfilesystem:CopyFile($VarSASSFileSourcePath, $VarSASSFileDestinationPath)"/>
   </xsl:for-each>

   <xsl:variable name="VarSassTempFolderFiles" select="wwfilesystem:GetFiles($VarTempFolderPath)/wwfiles:Files/wwfiles:File"/>

   <!-- Get Replacement Variables -->
   <!--                           -->
   <xsl:variable name="VarSassVariableReplacementsAsXML">

    <!-- Header -->
    <!--        -->
    <wwsass:Variable name="header_generate" value="{wwprojext:GetFormatSetting('header-generate')}"/>

    <!-- Toolbar Buttons -->
    <!--                 -->
    <wwsass:Variable name="button_home_generate" value="{wwprojext:GetFormatSetting('button-home')}"/>
    <wwsass:Variable name="button_translate_generate" value="{wwprojext:GetFormatSetting('google-translate')}"/>

    <!-- Menu -->
    <!--      -->
    <wwsass:Variable name="menu_generate" value="{wwprojext:GetFormatSetting('menu-generate')}"/>
    <wwsass:Variable name="index_generate" value="{wwprojext:GetFormatSetting('index-generate')}"/>
    <wwsass:Variable name="toc_generate" value="{wwprojext:GetFormatSetting('toc-generate')}"/>

    <!-- Page -->
    <!--        -->
    <xsl:if test="string(number(wwprojext:GetFormatSetting('reverb-2.0-minimum-page-width'))) != 'NaN'">
     <wwsass:Variable name="initial_state_query_wide" value="'3&quot;only screen and (min-width : {wwprojext:GetFormatSetting('reverb-2.0-minimum-page-width')}px)'3&quot;" />
     <wwsass:Variable name="initial_state_query_narrow" value="'3&quot;only screen and (max-width : {wwprojext:GetFormatSetting('reverb-2.0-minimum-page-width')}px)'3&quot;" />
    </xsl:if>

    <!-- Footer -->
    <!--        -->
    <wwsass:Variable name="footer_generate" value="{wwprojext:GetFormatSetting('footer-generate')}"/>
    <wwsass:Variable name="footer_location" value="{wwprojext:GetFormatSetting('footer-location')}"/>

    <!-- Toolbar Tabs -->
    <!--              -->
    <wwsass:Variable name="toolbar_tabs_generate" value="{wwprojext:GetFormatSetting('toolbar-tabs')}"/>

   </xsl:variable>
   <xsl:variable name="VarSassVariableReplacements" select="msxsl:node-set($VarSassVariableReplacementsAsXML)/*" />

   <!-- Run replacements on files -->
   <!--                           -->
   <xsl:for-each select="$VarSassTempFolderFiles">
    <xsl:variable name="VarSassFilePathForReplacements" select="./@path"/>
    <xsl:variable name="VarFileName" select="wwfilesystem:GetFileNameWithoutExtension($VarSassFilePathForReplacements)"/>
    <xsl:if test="starts-with($VarFileName, '_') and wwstring:EndsWith($VarSassFilePathForReplacements, '.scss')">
     <xsl:variable name="VarReplaceVariables" select="wwsass:ReplaceAllVariablesInFile($VarSassFilePathForReplacements, $VarSassVariableReplacements)"/>
    </xsl:if>
   </xsl:for-each>

   <xsl:variable name="VarDestinationFolderPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $ParameterDestinationFolderName)"/>
   <xsl:variable name="VarCreateDirectory" select="wwfilesystem:CreateDirectory($VarDestinationFolderPath)" />

   <xsl:for-each select="$VarSassTempFolderFiles">
    <xsl:variable name="VarSassFilePath" select="./@path"/>
    <xsl:variable name="VarFileName" select="wwfilesystem:GetFileNameWithoutExtension($VarSassFilePath)"/>

    <xsl:if test="not(starts-with($VarFileName, '_')) and wwstring:EndsWith($VarSassFilePath, '.scss')">

     <xsl:variable name="VarCssResultPath" select="wwfilesystem:Combine($VarDestinationFolderPath, concat($VarFileName, '.css'))"/>
     <xsl:variable name="SassResult" select="wwsass:SassToCss($VarSassFilePath, $VarCssResultPath)"/>

     <wwfiles:File path="{$VarCssResultPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarCssResultPath)}" actionchecksum="{$GlobalActionChecksum}" title="">
      <wwfiles:Depends path="{$VarSassFilePath}" checksum="{wwfilesystem:GetChecksum($VarSassFilePath)}" />
     </wwfiles:File>

    </xsl:if>
   </xsl:for-each>

   <!-- Delete Temp Files -->
   <!--                   -->
   <xsl:for-each select="$VarSassTempFolderFiles">
    <xsl:variable name="VarSassFilePathToDelete" select="./@path"/>
    <xsl:if test="wwstring:EndsWith($VarSassFilePathToDelete, '.scss')">
     <xsl:variable name="VarDeleteTempFile" select="wwfilesystem:DeleteFile($VarSassFilePathToDelete)"/>
    </xsl:if>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
