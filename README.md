# About

Get.Software is a simple PowerShell module to get latest version and download URLs for various products. The module consists of a number of simple commands to use in scripts when performing several tasks including:

* Retrieve the latest version of a particular software product when comparing against a version already installed or downloaded
* Return the URL for the latest version of a software product if you need to download it locally

All functions consist of the following

* Get verb - the module provides functions to retrieve data only
* Product name - product names consist of Developer, Product Name (e.g. Adobe Reader, Google Chrome)
* Uri or Version - the function will return either the production version number or numbers, or a URI to download the latest version from

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. Instead the focus is on simple integration for PowerShell scripts to provide product version numbers and download URLs. Data will only be pulled from the vendor web site and never a third party.

## Who

This module is maintained by the following community members

* Aaron Parker, [https://twitter.com/stealthpuppy](@stealthpuppy)
* Bronson Magnan, [https://twitter.com/CIT_Bronson](@CIT_Bronson)
* Trond Eric Haarvarstein, [https://twitter.com/xenappblog](@xenappblog)
