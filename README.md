## NEXSO SmartMap

###Descripción
---

NEXSO es la comunidad del Fondo Multilateral de Inversiones que pretende aumentar el impacto social y económico para el desarrollo de América Latina y el Caribe. NEXSO conecta a los diseñadores de proyectos con soluciones probadas, GeoData y organizaciones para mejorar la calidad y el impacto de los proyectos financiados por el FOMIN. Está compuesto de cuatro herramientas que se integran en una única plataforma en línea. Desde una perspectiva de desarrollo tecnológico, cada herramienta representa un centro de negocios. Una base de datos común permite que todas las herramientas sean integradas permitiendole al usuario una experiencia fluida y amigable.

### Arquitectura de aplicación
---
NEXSO es una aplicación ASP.NET del tipo Web Form construida sobre Dot Net Nuke / Evoq (DNN) 7 Community Edition bajo una arquitectura de aplicación de cinco capas.

Descripción de las capas


Cliente: un conjunto de estilos y piezas de Javascript para proporcionar una experiencia de usuario amigable.
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoV2  Tema utilizado en el 80% de la aplicación
- /VS2013_PROJECT/NZPortalWeb/Portals/0/Skins/NexsoVZ  Tema utilizado en el 20% de la aplicación


Presentación: un conjunto de módulos Dot Net Nuke que exponen todas las funcionalidades.
/VS2013_PROJECT/NZPortalWeb/DesktopModules/Nexso

Business: es una biblioteca que contiene un conjunto de objetos que proporcionan un catálogo de funcionalidades para que la capa de presentación y servicio interactúen con otros objetos dentro de la aplicación.

- /VS2013_PROJECT/NexsoProBLL 


Datos: es una librería que contiene un conjunto de objetos para almacenar y recupera los datos de la aplicación.
- /VS2013_PROJECT/NexsoProBLL
- /VS2013_PROJECT/NEXSO_DB contiene el esquema de la aplicación NEXSO
- /VS2013_PROJECT/DNN_DB esto contiene el esquema para el CMS, Dot Net Nuke

Servicios Adicionales: es un conjunto de objetos auxiliares para consumir servicios adicionales.
- /VS2013_PROJECT/MIFWebServices esta es una interfaz para consumir los Servicios Web del Fondo Multilateral de Inversiones
- /VS2013_PROJECT/NexsoServices es una biblioteca que expone una API REST, utilizando .NET Web Api y DNN para interactuar con la aplicación.


### Vamos más allá, hacer que sea de código abierto social
---
Razón por la que estamos abriendo el código fuente ....

### Requisitos de desarrollo
---

- .NET 4.5
- Visual Studio 2013 o superior

###Comenzar ahora
---

1. Abre la solución NZPortalWeb.sln con Visual Studio 2013 o superior
2. Regenera la base de datos en SQL Server 2012
3. Configura el Web.config con tu propia configuración
4. Ejecuta y depura la aplicación con Visual Studio

Voila!! Estás listo.

Importante:

> El proyecto actual tiene fines demostrativos. Es posible que no se ejecute correctamente porque no se proporciona el script de base de datos y algunas licencias se requieren para correr algunas funcionalidades.

Licencia:

> Para ejecutar el blog, el usuario debe obtener una licencia para Easy DNN News. Las Dll se han removido de la aplicación.

###Desarrollo
---
Durante el desarrollo, debe utilizar Visual Studio y SQL Server 2012


### Análisis de calidad
---

El BID hizo una evaluación de calidad de terceros de este código con el fin de informar a los problemas de la comunidad a resolver. Este código está clasificado como XXXX. Significa, que no es funcional y requiere un trabajo de mejora antes de ser considerado código de desarrollo.

###Por hacer
---

Identificamos varios puntos para mejorar NEXSO.

1. Corregir errores en el código.
2. Actualizar la aplicación a .NET Core
3. Implementar el Proyecto de BD (contacta al dueño del repositorio)
4. Sustituir los componentes de componentes de código abierto
5. Retirar los componentes que ya no son necesarios
6. Actualizar la Web.Api
7. Implementar MVC en algunos módulos
9. Mejorar estilos
10. Implementar HTML5


### Licencias de terceros
---
Para los siguientes componentes de terceros lea cuidadosamente antes de descargar y ejecute el código correctamente.

Licencias de propietarios

- EASY DNN News es necesario obtener una copia válida y licencia para la suite http://www.easydnnsolutions.com/ , debe instalarse en la carpeta / bin

- Los controles de TELERIK Rad Controls son necesarios en la aplicación. DNN ya no soporta los componentes originales de Telerik, http://www.dnnsoftware.com/community-blog/cid/154991/dnn-and-telerik-rad-controls. Además, se debe obtener una copia y licencia válidas para Telerik Rad Control http://www.telerik.com/products/aspnet-ajax.aspx.

- AYLIEN es requerido para indexar internamente los contenidos. Se requiere una cuenta para ejecutar esta funcionalidad. Http://aylien.com/text-api

Licencia MIT

- GhostScript Sharp https://github.com/mephraim/ghostscriptsharp
- Argotic https://argent.codeplex.com/
- SharpZipLib https://github.com/icsharpcode/SharpZipLib
- Tweetsharp https://github.com/shugonta/tweetsharp
- NewtonSoft Json https://github.com/JamesNK/Newtonsoft.Json

Apache

- Luecene https://lucenenet.apache.org/
- Webactivator https://github.com/davidebbo/WebActivator
- ImageProcessor https://github.com/JimBobSquarePants/ImageProcessor


###Licencia
---

Licencia MIT

Se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia de este software y de los archivos de documentación asociados (el "Software"), para utilizar el Software sin restricción, incluyendo sin limitación los derechos a usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender copias del Software, y a permitir a las personas a las que se les proporcione el Software a hacer lo mismo, sujeto a las siguientes condiciones:

El aviso de copyright anterior y este aviso de permiso se incluirán en todas las copias o partes sustanciales del Software.
EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIALIZACIÓN, IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN, DAÑOS U OTRAS RESPONSABILIDADES, YA SEA EN UNA ACCIÓN DE CONTRATO, AGRAVIO O CUALQUIER OTRO MOTIVO, QUE SURJA DE O EN CONEXIÓN CON EL SOFTWARE O EL USO U OTRO TIPO DE ACCIONES EN EL SOFTWARE.

>Está no es una traducción oficial, favor referirse a la licencia original en ingles, https://opensource.org/licenses/MIT


### Autores
---
BID

- Jairo Anaya
- Stephen Chapman

Studio Yellow
- Marina Yofre
- Valeria Ruiz

Flipside
- Olaf Verman
- Daniel Silva
- Ricardo Saavedra

Sinapsis Innovación

- Felipe Villegas
- Juliana Manrique
- Gonzalo Isaza

### Otros enlaces

Http://server.arcgis.com/en/

Http://www.nexso.org/

https://www.fomin.org/