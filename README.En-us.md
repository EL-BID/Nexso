##NEXSO SmartMap

###Description
---

NEXSO is the Multilateral Investment Fund's community driven platform that increase the systemic social and economic impact throughout the development community in Latin America and Caribbean. NEXSO connects project designers to tested solutions, GeoData and organizations to improve the quality and impact of projects funded by the MIF. NEXSO is already composed of four tools that will be integrated into a single online platform. From a technological development perspective, each tool represents a business center. A common database allows all the tools to be integrated in a smooth and friendly user experience.

###Application Architecture
---
NEXSO is an ASP.NET Web Form application built on top of Dot Net Nuke /Evoq (DNN) 7 Community Edition under a five layer-application architecture.

Layers Description


Client: a set of styles and Javascript pieces to provide a rich user experience.
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoV2 Theme used in the 80% of the application
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoVZ Theme used in the 20% of the application


Presentation: a set of custom Dot Net Nuke module that expose all functionalities.
/VS2013_PROJECT/NZPortalWeb/DesktopModules/Nexso

Business: it is a library that contains a set of objects that provide a catalog of functionalities for the presentation and service layer to interact with other objects inside the application.

- /VS2013_PROJECT/NexsoProBLL 


Data: it is a library that contains a set of of objects to store a recover the application data.
- /VS2013_PROJECT/NexsoProBLL
- /VS2013_PROJECT/NEXSO_DB this contains the schema for the NEXSO Application
- /VS2013_PROJECT/DNN_DB this contains the schema for the CMS, Dot Net Nuke

Additonal Services: a set of helper objects to provide additional services.
- /VS2013_PROJECT/MIFWebServices this is an interface to consume the Multilateral Investment Fund Web Services
- /VS2013_PROJECT/NexsoServices this is library that exposes a REST API, using .NET Web Api and DNN to interact with the application. 


###Go beyond, make it social open source
---
Reason why we are opening the source code ....

###Development Requirements
---

- .NET 4.5
- Visual Studio 2013 or higher

###Getting Started
---

1. Open the solution NZPortalWeb.sln with Visual Studio 2013 or higher
2. Regenerate the Data Base in SQL Server 2012
3. Configure the Web.config with your own configuration
4. Run and debug the application with Visual Studio

Voila!! You are all set and running.

Important:

>The current project is for demonstrative purposes. It might not run because, the database script is not provided and some licenses are required to expose some functionalities. 

License: 

> To execute the blog the user must get a license for Easy DNN News. Please refer to Third Party licenses section.

###Development
---
During the development, you should use Visual Studio and SQL Server 2012


###Quality Analysis
---

The IDB made a third-party quality assessment of this code in order to inform to the community issues to resolve. This code is rated as XXXX. It means, it is not functional and requires a load work prior to be a development code grade. 

###To do's
---

We identify several points to improve NEXSO.

1. Fix bugs in the code.
2. Update the application to .NET Core
3. Implement the DB Project (contact repository owner)
4. Replace paid components for open source components
5. Update the Web.Api
6. Implement MVC approach in some modules
7. Improve CSS styles
8. Implement HTML5


###Third Party licenses
---
For following third party components read carefully prior to download and run the code properly.

Proprietor licenses

- EASY DNN News is required, you should get a valid copy and license key for the suite http://www.easydnnsolutions.com/ and install it in the folder /bin

- TELERIK Rad Controls are required in the application. DNN does not longer support the original Telerik components, http://www.dnnsoftware.com/community-blog/cid/154991/dnn-and-telerik-rad-controls. Additionally, you should get a valid copy and license key for Telerik Rad Control http://www.telerik.com/products/aspnet-ajax.aspx. 

- AYLIEN is require for indexing internal solution contents. An account is required to execute this functionality.  http://aylien.com/text-api 

MIT License

- GhostScript Sharp https://github.com/mephraim/ghostscriptsharp
- Argotic https://argotic.codeplex.com/
- SharpZipLib https://github.com/icsharpcode/SharpZipLib
- Tweetsharp https://github.com/shugonta/tweetsharp
- NewtonSoft Json https://github.com/JamesNK/Newtonsoft.Json

Apache

- Luecene https://lucenenet.apache.org/
- Webactivator https://github.com/davidebbo/WebActivator
- ImageProcessor https://github.com/JimBobSquarePants/ImageProcessor


###License
---


MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.



###Authors
---
IADB

- Jairo Anaya 
- Stephen Chapman

Studio Yellow
- Marina Yofre
- Valeria Ruiz

Flipside
- Olaf Verman
- Daniel Silva
- Ricardo Saavedra

Sinapsis Innovation

- Felipe Villegas
- Juliana Manrique
- Gonzalo Isaza

###Other Links

http://server.arcgis.com/en/

http://www.nexso.org/

https://www.fomin.org/