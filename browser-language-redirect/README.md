# About AEM Browser Language Dispatcher
================================

This Dispatcher solution is setting up a a Dispatcher that redirects user to the correct home page of a **multi-language** site based on the **browser's language**. This way a user with a **German** browser will land on **/content/geometrixx/de.html** and not on the English page.

This is how the page resolution works:

* Cookie **aemlanguage** found:
	* /geometrixx.html -> /content/geometrixx/\<aemlanguage>.html
	* / -> /content/geomtrixx/\<aemlanguage>.html
* Accept Language found:
	* /geometrixx.html -> /content/geometrixx/\<accept-language>.html
	* / -> /content/geomtrixx/\<accept-language>.html
* Otherwise
	* /geometrixx.html -> /content/geometrixx/en.html
	* / -> /content/geomtrixx/\en.html

**Attention**: if a Cookie or Accept Language is found but the mapping is not present **en** will be used as default.

This instance installs a local AEM Publish instance on port 4053 and the website can be reached from the **Host** using port **8080**.

So to see Geometrixx homepage use this URL on the Host:

	http://localhost:8080/geometrixx.html

or

	http://localhost:8080/

**Attention**: the initial startup of AEM takes a while and you might want to test the **direct** access to AEM to make sure the site is up and running before hitting the Dispatcher:

	http://localhost:4053/content/geometrixx/en.html

This from the Host as well.

## Rewrite Notes

The rewrites of the language codes are done by using a Rewrite Filter file. This contains the langauge code, space, language node name. If no mapping is found it uses **en** as default.

	RewriteMap languagemap "txt:/etc/httpd/conf.d/dispatcher/language-based-map.txt"
	
	RewriteCond %{HTTP_COOKIE} aemlanguage=(.*) [NC]
	RewriteRule "^/geometrixx.html$" "/content/geometrixx/${languagemap:%1|en}.html" [PT]
	...
	RewriteCond %{HTTP:Accept-Language} ^(..).*$ [NC]
	...

**Attention**: keep in mind that this is not mapping the requests meaning that the browser will be redirected to **/content/geometrixx/en.html** and not stay in /geometrixx/en.html. To make this work the links inside a page must be rewritten with either **ETC Mapping**, **Link Rewriter** or **Transformer**.
