<!-- #p100003 -->


<!-- #p100009 -->
title: Security Flaws Management Policy
=======================================

<!-- #p100015 -->
# Security Flaws Management Policy

<!-- #p100021 -->
Zeenea considers with the greatest attention and seriousness the risks induced by the security flaws that can be discovered on the solutions or libraries used in our products.

<!-- #p100027 -->
Thus, we adopt, for all of our products, a strict policy of taking into account vulnerabilities in an extensive way (\*), including those related to software dependencies in our products for which a CVE (Common Vulnerabilities and Exposures) is published.

<!-- #p100033 -->
The severity level is based on external and officially legitimate sources, in particular, but not exclusively, the National Institute of Standards and Technology (NIST - https://nvd.nist.gov/).

<!-- #p100042 -->
For each published CVE, if it affects any part of Zeenea technical ecosystem (**), we consider the following cases:

- <!-- #p100051 -->
  The vulnerability is qualified as **CRITICAL**:

  <!-- #p100057 -->
    It is immediately taken into account with the implementation of an adapted correction method (e.g. : upgrade of the dependency to include the associated patch) within 30 days following the availability of the associated patch.

- <!-- #p100069 -->
  The vulnerability is **lower**:

  <!-- #p100075 -->
    Zeenea proceeds to a contextualized analysis of the exposure of its components and applies an adapted response: if the exposure is qualified as high, the correction will be made within 30 days following the availability of the patch. By default, our policy of regular component updates will allow products to cover even low risk within 3 months.

<!-- #p100087 -->
When a component deployed inside a customer's infrastructure is subject to a security patch, we inform the customer of the availability of the corrected component by indicating that it is an exceptional security delivery.

<!-- #p100093 -->
(\*) Vulnerabilities cover the entire perimeter: infrastructure, managed services, application dependencies, etc.

<!-- #p100102 -->
(**) The monitoring of components used by our products and concerned by published CVEs is automated and thus offers us the best possible reactivity.

