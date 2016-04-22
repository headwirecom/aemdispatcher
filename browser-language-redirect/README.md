# About AEM Plain Dispatcher
======================

This Dispatcher solution is setting up a plain and simple Dispatcher with **no rewrites**, mappings etc and can be used as a generic base to develop your own Dispatcher solution.

This instance installs a local AEM Publish instance on port 4053 and the website can be reached from the **Host** using port **8080**.

So to see Geometrixx English homepage use this URL on the Host:

	http://localhost:8080/content/geometrixx/en.html

**Attention**: the initial startup of AEM takes a while and you might want to test the **direct** access to AEM to make sure the site is up and running before hitting the Dispatcher:

	http://localhost:4053/content/geometrixx/en.html

This from the Host as well.