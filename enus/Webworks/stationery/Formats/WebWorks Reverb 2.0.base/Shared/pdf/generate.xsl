<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Files-Schema"
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
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwadapter="urn:WebWorks-XSLT-Extension-Adapter"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwacrodist="urn:WebWorks-Acrobat-Distiller"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwadapter wwimaging wwexsldoc wwacrodist"
>
 <xsl:template name="PDF-UseAcrobatDistiller">
  <xsl:param name="ParamDocumentPath" />

  <!-- Access supported Acrobat Distiller extensions -->
  <!--                                               -->
  <xsl:variable name="VarAcrobatDistillerExtensions">
   <xsl:text> </xsl:text>
   <xsl:value-of select="wwprojext:GetFormatSetting('pdf-acrobat-distiller-extensions')" />
   <xsl:text> </xsl:text>
  </xsl:variable>

  <!-- Define extension search pattern -->
  <!--                        -->
  <xsl:variable name="VarExtensionSearchPattern">
   <xsl:text> </xsl:text>
   <xsl:value-of select="wwfilesystem:GetExtension($ParamDocumentPath)" />
   <xsl:text> </xsl:text>
  </xsl:variable>

  <!-- Supported? -->
  <!--            -->
  <xsl:variable name="VarCanUseAcrobatDistiller" select="contains($VarAcrobatDistillerExtensions, $VarExtensionSearchPattern)" />
  <xsl:value-of select="$VarCanUseAcrobatDistiller" />
 </xsl:template>


<xsl:template name="PDF-UseSaveAsPDF">
  <xsl:param name="ParamDocumentPath" />

  <!-- Access supported Save As PDF extensions -->
  <!--                                         -->
  <xsl:variable name="VarSaveAsPDFExtensions">
   <xsl:text> </xsl:text>
   <xsl:value-of select="wwprojext:GetFormatSetting('pdf-save-as-pdf-extensions')" />
   <xsl:text> </xsl:text>
  </xsl:variable>

  <!-- Define extension search pattern -->
  <!--                        -->
  <xsl:variable name="VarExtensionSearchPattern">
   <xsl:text> </xsl:text>
   <xsl:value-of select="wwfilesystem:GetExtension($ParamDocumentPath)" />
   <xsl:text> </xsl:text>
  </xsl:variable>

  <!-- Supported? -->
  <!--            -->
  <xsl:variable name="VarCanUseSaveAsPDF" select="contains($VarSaveAsPDFExtensions, $VarExtensionSearchPattern)" />
  <xsl:value-of select="$VarCanUseSaveAsPDF" />
 </xsl:template>


 <xsl:template name="PDF-Generate-Default">
  <xsl:param name="ParamOriginalDocumentPath" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamSingleFile" />
  <xsl:param name="ParamTOCStyles" />
  <xsl:param name="ParamAdapterGroupFiles" />
  <xsl:param name="ParamPDFPath" />

  <xsl:variable name="VarPDFJobSettings" select="wwprojext:GetFormatSetting('pdf-job-settings')" />
  <xsl:variable name="VarGeneratePDF" select="wwadapter:GeneratePDF($ParamOriginalDocumentPath, $ParamDocumentPath, $ParamSingleFile, $ParamTOCStyles, $ParamAdapterGroupFiles, $VarPDFJobSettings, $ParamPDFPath)" />
 </xsl:template>


 <xsl:template name="PDF-Generate-AcrobatDistiller">
  <xsl:param name="ParamOriginalDocumentPath" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamSingleFile" />
  <xsl:param name="ParamTOCStyles" />
  <xsl:param name="ParamAdapterGroupFiles" />
  <xsl:param name="ParamPDFPath" />

  <!-- Acrobat Distiller available? -->
  <!--                              -->
  <xsl:variable name="VarAcrobatDistillerAvailable" select="wwacrodist:Available()" />
  <xsl:choose>
   <!-- Use Acrobat Distiller -->
   <!--                       -->
   <xsl:when test="$VarAcrobatDistillerAvailable">
    <!-- Determine PostScript file name -->
    <!--                                -->
    <xsl:variable name="VarPostScriptFilePath" select="wwfilesystem:GetTempFileName()" />

    <!-- Generate PostScript file -->
    <!--                          -->
    <xsl:variable name="VarSetPDFPageNumberOffset" select="wwadapter:SetPDFPageNumberOffset(0)" />
    <xsl:variable name="VarGeneratePostScriptForPDF" select="wwadapter:GeneratePostScriptForPDF($ParamOriginalDocumentPath, $ParamDocumentPath, $ParamSingleFile, $ParamTOCStyles, $ParamAdapterGroupFiles, $VarPostScriptFilePath)" />
    <xsl:if test="wwfilesystem:FileExists($VarPostScriptFilePath)">
     <!-- Invoke Acrobat Distiller -->
     <!--                          -->
     <xsl:variable name="VarAcrobatDistillerJobSettings" select="wwprojext:GetFormatSetting('pdf-acrobat-distiller-job-settings')" />
     <xsl:variable name="VarFileToPDFResult" select="wwacrodist:FileToPDF($VarPostScriptFilePath, $ParamPDFPath, $VarAcrobatDistillerJobSettings)" />

     <!-- Log warnings as required -->
     <!--                          -->
     <xsl:if test="$VarFileToPDFResult &lt;= 0">
      <xsl:variable name="VarAcrobatDistillerParameters">
       <xsl:text>Input PostScript file path: '</xsl:text>
       <xsl:value-of select="$VarPostScriptFilePath" />
       <xsl:text>'</xsl:text>

       <xsl:text>, </xsl:text>
       <xsl:text>Output PDF file path: '</xsl:text>
       <xsl:value-of select="$ParamPDFPath" />
       <xsl:text>'</xsl:text>

       <xsl:text>, </xsl:text>
       <xsl:text>Acrobat Distiller PDF Job Settings: '</xsl:text>
       <xsl:value-of select="$VarAcrobatDistillerJobSettings" />
       <xsl:text>'</xsl:text>
      </xsl:variable>

      <xsl:choose>
       <!-- Invalid parameters -->
       <!--                    -->
       <xsl:when test="$VarFileToPDFResult = 0">
        <xsl:variable name="VarWarnAcrobatDistillerInvalidParameters" select="wwlog:Warning('Acrobat Distiller cannot generate PDF due to invalid parameters (', $VarAcrobatDistillerParameters, ').  Will attempt to process using default PDF generation method.')" />
       </xsl:when>

       <!-- PDF creation failed -->
       <!--                     -->
       <xsl:when test="$VarFileToPDFResult &lt; 0">
        <xsl:variable name="VarWarnAcrobatDistillerPDFCreationFailed" select="wwlog:Warning('Acrobat Distiller PDF generation failed (', $VarAcrobatDistillerParameters, ').  Will attempt to process using default PDF generation method.')" />
       </xsl:when>
      </xsl:choose>
     </xsl:if>

     <!-- Clean up PostScript file -->
     <!--                          -->
     <xsl:variable name="VarDeletePostScriptFile" select="wwfilesystem:DeleteFile($VarPostScriptFilePath)" />
    </xsl:if>
   </xsl:when>

   <!-- Log a warning! -->
   <!--                -->
   <xsl:otherwise>
    <xsl:variable name="VarWarnAcrobatDistillerUnavailable" select="wwlog:Warning('Acrobat Distiller is not available for PDF generation.  Will attempt to process using default PDF generation method.')" />
   </xsl:otherwise>
  </xsl:choose>

  <!-- Fallback to default method if PDF not generated -->
  <!--                                                 -->
  <xsl:if test="not(wwfilesystem:FileExists($ParamPDFPath))">
   <!-- Default method -->
   <!--                -->
   <xsl:call-template name="PDF-Generate-Default">
    <xsl:with-param name="ParamOriginalDocumentPath" select="$ParamOriginalDocumentPath" />
    <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
    <xsl:with-param name="ParamSingleFile" select="$ParamSingleFile" />
    <xsl:with-param name="ParamTOCStyles" select="$ParamTOCStyles" />
    <xsl:with-param name="ParamAdapterGroupFiles" select="$ParamAdapterGroupFiles" />
    <xsl:with-param name="ParamPDFPath" select="$ParamPDFPath" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="PDF-Generate-SaveAsPDF">
  <xsl:param name="ParamOriginalDocumentPath" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamSingleFile" />
  <xsl:param name="ParamTOCStyles" />
  <xsl:param name="ParamAdapterGroupFiles" />
  <xsl:param name="ParamPDFPath" />

  <!-- Generate PDF with Save As PDF -->
  <!--                               -->
  <xsl:variable name="VarPDFJobSettings" select="wwprojext:GetFormatSetting('pdf-save-as-pdf-job-settings')" />
  <xsl:variable name="VarGeneratePostScriptForPDF" select="wwadapter:GeneratePDFWithSaveAs($ParamOriginalDocumentPath, $ParamDocumentPath, $ParamSingleFile, $ParamTOCStyles, $ParamAdapterGroupFiles, $VarPDFJobSettings, $ParamPDFPath)" />

  <!-- Fallback to default method if PDF not generated -->
  <!--                                                 -->
  <xsl:if test="not(wwfilesystem:FileExists($ParamPDFPath))">
   <xsl:variable name="VarWarnPDFCreationFailed" select="wwlog:Warning('Unable to Save As PDF.  Using standard method.')" />

   <!-- Default method -->
   <!--                -->
   <xsl:call-template name="PDF-Generate-Default">
    <xsl:with-param name="ParamOriginalDocumentPath" select="$ParamOriginalDocumentPath" />
    <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
    <xsl:with-param name="ParamSingleFile" select="$ParamSingleFile" />
    <xsl:with-param name="ParamTOCStyles" select="$ParamTOCStyles" />
    <xsl:with-param name="ParamAdapterGroupFiles" select="$ParamAdapterGroupFiles" />
    <xsl:with-param name="ParamPDFPath" select="$ParamPDFPath" />
   </xsl:call-template>
  </xsl:if>
 </xsl:template>


 <xsl:template name="PDF-Generate">
  <xsl:param name="ParamOriginalDocumentPath" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamSingleFile" />
  <xsl:param name="ParamTOCStyles" />
  <xsl:param name="ParamAdapterGroupFiles" />
  <xsl:param name="ParamPDFPath" />

  <!-- Use Acrobat Distiller? -->
  <!--                        -->
  <xsl:variable name="VarUseAcrobatDistillerAsText">
   <xsl:call-template name="PDF-UseAcrobatDistiller">
    <xsl:with-param name="ParamDocumentPath" select="$ParamOriginalDocumentPath" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarUseAcrobatDistiller" select="$VarUseAcrobatDistillerAsText = 'true'" />

  <!-- Use Save As PDF? -->
  <!--                  -->
  <xsl:variable name="VarUseSaveAsPDFAsText">
   <xsl:call-template name="PDF-UseSaveAsPDF">
    <xsl:with-param name="ParamDocumentPath" select="$ParamOriginalDocumentPath" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarUseSaveAsPDF" select="$VarUseSaveAsPDFAsText = 'true'" />

  <xsl:choose>
   <!-- Use Acrobat Distiller -->
   <!--                       -->
   <xsl:when test="$VarUseAcrobatDistiller">
    <xsl:call-template name="PDF-Generate-AcrobatDistiller">
     <xsl:with-param name="ParamOriginalDocumentPath" select="$ParamOriginalDocumentPath" />
     <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
     <xsl:with-param name="ParamSingleFile" select="$ParamSingleFile" />
     <xsl:with-param name="ParamTOCStyles" select="$ParamTOCStyles" />
     <xsl:with-param name="ParamAdapterGroupFiles" select="$ParamAdapterGroupFiles" />
     <xsl:with-param name="ParamPDFPath" select="$ParamPDFPath" />
    </xsl:call-template>
   </xsl:when>

   <!-- Use Save As PDF -->
   <!--                 -->
   <xsl:when test="$VarUseSaveAsPDF">
    <xsl:call-template name="PDF-Generate-SaveAsPDF">
     <xsl:with-param name="ParamOriginalDocumentPath" select="$ParamOriginalDocumentPath" />
     <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
     <xsl:with-param name="ParamSingleFile" select="$ParamSingleFile" />
     <xsl:with-param name="ParamTOCStyles" select="$ParamTOCStyles" />
     <xsl:with-param name="ParamAdapterGroupFiles" select="$ParamAdapterGroupFiles" />
     <xsl:with-param name="ParamPDFPath" select="$ParamPDFPath" />
    </xsl:call-template>
   </xsl:when>

   <!-- Default method -->
   <!--                -->
   <xsl:otherwise>
    <xsl:call-template name="PDF-Generate-Default">
     <xsl:with-param name="ParamOriginalDocumentPath" select="$ParamOriginalDocumentPath" />
     <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
     <xsl:with-param name="ParamSingleFile" select="$ParamSingleFile" />
     <xsl:with-param name="ParamTOCStyles" select="$ParamTOCStyles" />
     <xsl:with-param name="ParamAdapterGroupFiles" select="$ParamAdapterGroupFiles" />
     <xsl:with-param name="ParamPDFPath" select="$ParamPDFPath" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- WebWorks Acrobat Distiller Code Block -->
 <!--                                       -->
 <msxsl:script language="C#" implements-prefix="wwacrodist">
  <![CDATA[
    public bool  Available()
    {
      bool  VarResult = false;

      try
      {
        Type  VarDistillerType;

        // Type is registered?
        //
        VarDistillerType = Type.GetTypeFromProgID("PDFDistiller.PDFDistiller.1", true);

        // Success!
        //
        VarResult = true;
      }
      catch
      {
        // Nothing to do!
        //
      }

      return VarResult;
    }

    public int  FileToPDF(string  ParamPostScriptFilePath,
                          string  ParamPDFFilePath,
                          string  ParamPDFOptions)
    {
      int  VarResult = -1;

      try
      {
        if (System.IO.File.Exists(ParamPostScriptFilePath))
        {
          string  VarParentDirectoryPath;

          // Create parent directories as needed
          //
          VarParentDirectoryPath = System.IO.Path.GetDirectoryName(ParamPDFFilePath);
          while (( ! String.IsNullOrEmpty(VarParentDirectoryPath)) &&
                 ( ! System.IO.Directory.Exists(VarParentDirectoryPath)))
          {
            System.IO.Directory.CreateDirectory(VarParentDirectoryPath);

            VarParentDirectoryPath = System.IO.Path.GetDirectoryName(VarParentDirectoryPath);
          }

          // Parent directory exists?
          //
          VarParentDirectoryPath = System.IO.Path.GetDirectoryName(ParamPDFFilePath);
          if (System.IO.Directory.Exists(VarParentDirectoryPath))
          {
            object  VarDistillerInstance = null;

            try
            {
              Type    VarDistillerType;

              // Instantiate the COM object using late binding
              //
              VarDistillerType = Type.GetTypeFromProgID("PDFDistiller.PDFDistiller.1", true);
              VarDistillerInstance = System.Activator.CreateInstance(VarDistillerType);
              if (VarDistillerInstance != null)
              {
                long    VarBoolean;
                object  VarMethodResult;
                short   VarMethodResultAsInt16;

                // Disable show window
                //
                VarBoolean = 0;
                VarMethodResult = VarDistillerType.InvokeMember("bShowWindow",
                                                                System.Reflection.BindingFlags.SetProperty,
                                                                null,
                                                                VarDistillerInstance,
                                                                new object[]{VarBoolean});

                // Disable job spooling
                //
                VarBoolean = 0;
                VarMethodResult = VarDistillerType.InvokeMember("bSpoolJobs",
                                                                System.Reflection.BindingFlags.SetProperty,
                                                                null,
                                                                VarDistillerInstance,
                                                                new object[]{VarBoolean});

                // Invoke PostScript to PDF VarMethod
                //
                VarMethodResult = VarDistillerType.InvokeMember("FileToPDF",
                                                                System.Reflection.BindingFlags.InvokeMethod,
                                                                null,
                                                                VarDistillerInstance,
                                                                new object[]{ParamPostScriptFilePath, ParamPDFFilePath, ParamPDFOptions});
                VarMethodResultAsInt16 = Convert.ToInt16(VarMethodResult);
                VarResult = VarMethodResultAsInt16;
              }
            }
            finally
            {
              // Clean up COM object
              //
              if (VarDistillerInstance != null)
              {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(VarDistillerInstance);
              }
            }
          }
        }
      }
      catch
      {
        // Nothing to do!
        //
      }

      return VarResult;
    }
  ]]>

 </msxsl:script>
</xsl:stylesheet>