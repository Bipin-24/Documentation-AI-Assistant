// Copyright (c) 2004-2005 Quadralay Corporation.  All rights reserved.
//
// The information in this file is confidential and proprietary to
// Quadralay Corporation.  Unauthorized use or duplication is
// strictly prohibited.
//

function WWDocInfo_Object()
{
  this.mProperties       = new Array();
  this.mNumberProperties = new Array();
  
  this.fAddProperty          = WWDocInfo_AddProperty;
  this.fAddNumberData        = WWDocInfo_AddNumberData;
  this.fPreWriteBulletImages = WWDocInfo_PreWriteBulletImages;
  this.fUpdateProperties     = WWDocInfo_UpdateDocumentProperties;
}

function WWDocInfo_AddProperty(ParamPropertyContextID,
                      ParamPropertyName,
                      ParamPropertyValue)
{
  var PropertyObject = new Object();
  
  PropertyObject["context-id"] = ParamPropertyContextID;
  PropertyObject["name"] = ParamPropertyName;
  PropertyObject["value"] = ParamPropertyValue;
  
  this.mProperties[this.mProperties.length] = PropertyObject;
}

function WWDocInfo_AddNumberData(ParamPropertyContextID,
                                 ParamBulletCharacter,
                                 ParamBulletImagePath,
                                 ParamBulletSeparator,
                                 ParamWifNumberData)
{
  var PropertyObject = new Object();
  
  PropertyObject["contextId"]       = ParamPropertyContextID;
  PropertyObject["bulletCharacter"] = ParamBulletCharacter;
  PropertyObject["bulletImagePath"] = ParamBulletImagePath;
  PropertyObject["bulletSeparator"] = ParamBulletSeparator;
  PropertyObject["numberData"]      = ParamWifNumberData;
  
  this.mNumberProperties[this.mNumberProperties.length] = PropertyObject;
}

function WWDocInfo_PreWriteBulletImages()
{
    // Handle paragraph numbering
  //
  for (VarIndex = 0, VarMaxIndex = this.mNumberProperties.length; VarIndex < VarMaxIndex; VarIndex++)
  {
    VarNumberProperty  = this.mNumberProperties[VarIndex];
    VarBulletImagePath = VarNumberProperty["bulletImagePath"];
    
    if (VarBulletImagePath.length > 0)
    {
      document.write('<img src="' + VarBulletImagePath + '" style="visibility: hidden; display: none" />\n');
    }
  }
}

function WWDocInfo_UpdateDocumentProperties()
{
  var VarProperty;
  var VarNumberProperty;
  var VarPropertyContextID;
  var VarPropertyName;
  var VarPropertyValue;
  var VarContextElement;

  // Handle paragraph numbering
  //
  for (VarIndex = 0, VarMaxIndex = this.mNumberProperties.length; VarIndex < VarMaxIndex; VarIndex++)
  {
    VarNumberProperty  = this.mNumberProperties[VarIndex];
    VarNumberID        = VarNumberProperty["contextId"];
    VarBulletCharacter = VarNumberProperty["bulletCharacter"];
    VarBulletImagePath = VarNumberProperty["bulletImagePath"];
    VarBulletSeparator = VarNumberProperty["bulletSeparator"];
    VarNumberData      = VarNumberProperty["numberData"];

    VarNumberElement = document.getElementById(VarNumberID);
    VarParameters = "?" + (new Date() * 1);
    
    if ((typeof(VarNumberElement) != 'undefined') && (VarNumberElement != null))
    {
      if ((VarBulletCharacter.length > 0) || (VarBulletImagePath.length > 0) || (VarBulletSeparator.length > 0))
      {
        VarBulletCharacterElement = document.createTextNode(VarBulletCharacter);
        VarBulletSeparatorElement = document.createTextNode(VarBulletSeparator);

        // Append number from UI
        //
        if (VarBulletImagePath.length > 0)
        {
          VarBulletImageElement = document.getElementById(VarNumberID.split('_')[0] + '_BulletImage');
          if ((typeof(VarBulletImageElement) != 'undefined') && (VarBulletImageElement != null))
          {
            VarBulletImageElement.src              = VarBulletImagePath;
            VarBulletImageElement.style.display    = 'inline';
            VarBulletImageElement.style.visibility = 'visible';
          }
        }
        if (VarBulletCharacter.length > 0)
        {
          VarNumberElement.appendChild(VarBulletCharacterElement);
        }
        if (VarBulletSeparator.length > 0)
        {
          VarNumberElement.appendChild(VarBulletSeparatorElement);
        }
      }
      else if (VarNumberData.length > 0)
      {
        VarNumberDataElement = document.createTextNode(VarNumberData);

        // Append number from WIF
        //
        VarNumberElement.appendChild(VarNumberDataElement);
      }
    }
  }

  // Handle table cell spacing
  //
  for (VarIndex = 0, VarMaxIndex = this.mProperties.length; VarIndex < VarMaxIndex; VarIndex++)
  {
    VarProperty = this.mProperties[VarIndex];
    VarPropertyContextID = VarProperty["context-id"];
    VarPropertyName = VarProperty["name"];
    VarPropertyValue = VarProperty["value"];
    
    if (typeof(document.all) != "undefined")
    {
      VarContextElement = document.all[VarPropertyContextID];
      if (VarContextElement)
      {
        VarContextElement[VarPropertyName] = VarPropertyValue;
      }
    }
    else if (typeof(document.getElementById) != "undefined")
    {
      VarContextElement = document.getElementById(VarPropertyContextID);
      if (VarContextElement)
      {
        VarContextElement.setAttribute(VarPropertyName, VarPropertyValue);
      } 
    }
  }

  return true;
}
